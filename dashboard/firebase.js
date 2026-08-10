/* =========================================================
   firebase.js — instaROSA Dispatch Command
   Connects this dashboard to the SAME Firestore project your
   mobile app writes reports into, and keeps the incident queue
   + map in sync in real time (no polling — Firestore pushes
   updates the instant a document changes).

   HOW TO SET THIS UP
   -------------------
   1. Go to console.firebase.google.com → your project →
      Project settings (gear icon) → General tab → scroll to
      "Your apps" → if you don't already have a Web app, click
      the </> icon to register one → copy the firebaseConfig
      object it gives you.

   2. Paste those values into FIREBASE_CONFIG below.

   3. Update FIELD_MAP below so it matches whatever field names
      your mobile app actually uses when it writes a report
      document (see comments next to each field).

   4. Make sure your Firestore Security Rules allow this web
      dashboard to read the collection. For an internal
      operator tool behind login, something like this is a
      reasonable starting point (tighten to your actual auth
      setup before going live):

        match /reports/{reportId} {
          allow read: if request.auth != null;   // any signed-in operator
          allow write: if request.auth != null;  // adjust as needed
        }

   5. If the app currently writes GPS as a Firestore GeoPoint,
      the field mapping below already handles that. If it writes
      lat/lng as two separate plain numbers instead, update the
      "getLatLng" function near the bottom to match.
   ========================================================= */

// ---- 1. YOUR FIREBASE PROJECT CONFIG ----
// Paste the values from Firebase Console → Project Settings → Your apps.
const FIREBASE_CONFIG = {
  apiKey: "AIzaSyDe4EHcDIsFprTAcEteRE9KQ4dmd7fAIE", // <--- THIS VALUE
  authDomain: "mythical-ninjas-5d022.firebaseapp.com",
  projectId: "mythical-ninjas-5d022",
  storageBucket: "mythical-ninjas-5d022.firebasestorage.app",
  messagingSenderId: "699754239210",
  appId: "1:699754239210:web:a39e20d9af1f802ee6f393"
};

// ---- 2. COLLECTION NAME ----
// The Firestore collection your mobile app writes incident/report
// documents into. Change this to match your app's actual collection.
const REPORTS_COLLECTION = "reports";

// The Firestore collection your mobile app writes user accounts into.
const USERS_COLLECTION = "users";

// Field mapping for user documents (left = what the dashboard expects,
// right = the actual field name in your Firestore "users" documents).
const USER_FIELD_MAP = {
  name: "fullName",
  phone: "phoneNumber",
  barangay: "savedAddress.brgy", // nested field, see getNestedField() below
  joined: "createdAt",
  emergencyContactName: "emergencyContactName",
  emergencyContactNumber: "emergencyContactNumber",
  street: "savedAddress.street"
};

// ---- 3. FIELD MAPPING ----
// Left side = what the dashboard code expects internally (do not change).
// Right side = the actual field name in your Firestore documents.
// Matched to the real report document structure from the mobile app.
const FIELD_MAP = {
  title: "category",        // agency/department label, e.g. "BFP", "CDRRMO", "Parking", "Noise"
  category: "reportType",   // "emergency" or "community" — the app sends this directly
  district: "barangay",     // barangay name, must match the 18 barangay list
  // NOTE: the description field name differs by report type — "natureOfDistress"
  // on emergency reports, "natureOfConcern" on community reports. Both are read
  // and merged in firestoreDocToIncident() below, since FIELD_MAP only supports
  // a single source field per target.
  location: "natureOfConcern",
  reporter: "userName",
  phone: "userPhone",
  severity: "severity",     // "high" | "medium" | "low" | "info" — app doesn't send this yet,
                             // see getDefaultSeverity() below for the fallback used instead
  status: "status",         // "pending" | "dispatched" | "resolved" | "cancelled"
  timestamp: "createdAt",   // Firestore Timestamp of when the report was submitted
  geopoint: "coordinates",  // app sends this as a 2-item array of strings, e.g.
                             // ["14.313173434495068° N", "121.09730814806312° E"] — parsed below
  unit: "assignedUnit",     // not sent by the app; set by the dashboard on dispatch
  dispatchScope: "dispatchScope" // not sent by the app; set by the dashboard on dispatch
};

// reportType sends exactly "emergency" or "community" — map straight through
// to the dashboard's internal category names.
const REPORT_TYPE_TO_CATEGORY = {
  emergency: "distress",
  community: "community"
};

// =========================================================
// Below this line: sync logic. Shouldn't need to touch this
// unless your data shape is unusual.
// =========================================================

import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.0/firebase-app.js";
import {
  getFirestore,
  collection,
  doc,
  updateDoc,
  onSnapshot,
  query,
  orderBy
} from "https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js";

let firestoreDb = null;
let unsubscribeReports = null;

function minutesAgo(timestamp) {
  if (!timestamp) return 0;
  const then = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
  const diffMs = Date.now() - then.getTime();
  return Math.max(0, Math.round(diffMs / 60000));
}

// Parses one coordinate string like "14.313173434495068° N" or
// "121.09730814806312° E" into a signed decimal number.
function parseCoordString(str) {
  if (typeof str !== "string") return null;
  const match = str.match(/(-?\d+(\.\d+)?)\s*°?\s*([NSEW]?)/i);
  if (!match) return null;
  let value = parseFloat(match[1]);
  const hemi = (match[3] || "").toUpperCase();
  if (hemi === "S" || hemi === "W") value = -Math.abs(value);
  return isNaN(value) ? null : value;
}

function getLatLng(docData) {
  const coordsField = docData[FIELD_MAP.geopoint];

  // App's format: a 2-item array of strings, e.g. ["14.31...° N", "121.09...° E"]
  if (Array.isArray(coordsField) && coordsField.length === 2) {
    const lat = parseCoordString(coordsField[0]);
    const lng = parseCoordString(coordsField[1]);
    if (lat !== null && lng !== null) return { lat, lng };
  }

  // Firestore GeoPoint (in case a different report type uses this instead)
  if (coordsField && typeof coordsField.latitude === "number") {
    return { lat: coordsField.latitude, lng: coordsField.longitude };
  }

  // Fallback: separate lat/lng fields, if that's how some documents store it
  if (typeof docData.lat === "number" && typeof docData.lng === "number") {
    return { lat: docData.lat, lng: docData.lng };
  }
  return null;
}

// The app doesn't send a severity field yet, so default it based on
// whether the report is a full emergency (distress) or a barangay-level
// concern (community) — distress reports default more urgent.
function getDefaultSeverity(category) {
  return category === "distress" ? "high" : "medium";
}

// Only these four values mean anything to the dashboard. Anything else —
// missing field, unexpected casing, stray text, a failed/partial write —
// gets normalized to "pending" so it stays visibly active in the queue
// instead of silently mislabeling itself as closed while staying stuck.
const VALID_STATUSES = ["pending", "dispatched", "resolved", "cancelled"];
function normalizeStatus(raw) {
  if (typeof raw !== "string") return "pending";
  const cleaned = raw.trim().toLowerCase();
  return VALID_STATUSES.includes(cleaned) ? cleaned : "pending";
}

function firestoreDocToIncident(docSnap) {
  const d = docSnap.data();
  const title = d[FIELD_MAP.title] || "Untitled Report";
  const rawReportType = d[FIELD_MAP.category]; // "emergency" | "community"
  const category = REPORT_TYPE_TO_CATEGORY[rawReportType] || "community";
  const district = d[FIELD_MAP.district] || "";
  const coords = getLatLng(d);

  // Description field name differs by report type: emergency reports use
  // natureOfDistress, community reports use natureOfConcern. Check both.
  const description = d.natureOfDistress || d.natureOfConcern || d[FIELD_MAP.location] || "";

  return {
    id: docSnap.id,
    title,
    category,
    tag: `${category === "distress" ? "DISTRESS" : "BARANGAY"} / ${(district || "UNASSIGNED").toUpperCase()}`,
    district,
    location: description || district || "Location not specified",
    reporter: d[FIELD_MAP.reporter] || "Anonymous",
    phone: d[FIELD_MAP.phone] || "—",
    severity: d[FIELD_MAP.severity] || getDefaultSeverity(category),
    status: normalizeStatus(d[FIELD_MAP.status]),
    minsAgo: minutesAgo(d[FIELD_MAP.timestamp]),
    unit: d[FIELD_MAP.unit] || null,
    dispatchScope: d[FIELD_MAP.dispatchScope] || null,
    lat: coords ? coords.lat : null,
    lng: coords ? coords.lng : null,
    _live: true // marks this as coming from Firestore, not seed data
  };
}

/**
 * Starts a real-time listener on the reports collection.
 * Every time your app writes, edits, or a document's status changes,
 * this fires again automatically and the callback receives the full,
 * current list of incidents — no manual refresh, no polling.
 */
function startLiveIncidentSync(onUpdate) {
  try {
    const app = initializeApp(FIREBASE_CONFIG);
    firestoreDb = getFirestore(app);
  } catch (err) {
    console.error("Firebase init failed:", err);
    showFirebaseSetupWarning();
    return;
  }

  const q = query(collection(firestoreDb, REPORTS_COLLECTION), orderBy(FIELD_MAP.timestamp, "desc"));

  unsubscribeReports = onSnapshot(
    q,
    (snapshot) => {
      const liveIncidents = snapshot.docs.map(firestoreDocToIncident);
      onUpdate(liveIncidents);
    },
    (error) => {
      console.error("Firestore listener error:", error);
      showFirebaseSetupWarning();
    }
  );
}

function stopLiveIncidentSync() {
  if (unsubscribeReports) unsubscribeReports();
}

// Reads a possibly-nested field, e.g. "savedAddress.brgy", from a doc.
function getNestedField(docData, path) {
  return path.split(".").reduce((obj, key) => (obj && typeof obj === "object" ? obj[key] : undefined), docData);
}

// Formats a Firestore Timestamp (or missing value) into a short display
// date, e.g. "Aug 7, 2026", for the "Joined" field on user cards.
function formatJoinedDate(timestamp) {
  if (!timestamp) return "—";
  const d = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
  if (isNaN(d.getTime())) return "—";
  return d.toLocaleDateString("en-US", { year: "numeric", month: "short", day: "numeric" });
}

function firestoreDocToUser(docSnap) {
  const d = docSnap.data();
  return {
    id: docSnap.id,
    name: getNestedField(d, USER_FIELD_MAP.name) || "Unknown",
    phone: getNestedField(d, USER_FIELD_MAP.phone) || "—",
    barangay: getNestedField(d, USER_FIELD_MAP.barangay) || "Unassigned",
    street: getNestedField(d, USER_FIELD_MAP.street) || "",
    joined: formatJoinedDate(getNestedField(d, USER_FIELD_MAP.joined)),
    emergencyContactName: getNestedField(d, USER_FIELD_MAP.emergencyContactName) || "",
    emergencyContactNumber: getNestedField(d, USER_FIELD_MAP.emergencyContactNumber) || "",
    _live: true
  };
}

let unsubscribeUsers = null;

/**
 * Starts a real-time listener on the users collection, same pattern as
 * startLiveIncidentSync — fires immediately with the full current list,
 * then again on every account create/update.
 */
function startLiveUserSync(onUpdate) {
  if (!firestoreDb) {
    console.error("Cannot start user sync — Firestore is not connected yet. Call after startLiveIncidentSync.");
    return;
  }
  const q = collection(firestoreDb, USERS_COLLECTION);
  unsubscribeUsers = onSnapshot(
    q,
    (snapshot) => {
      const liveUsers = snapshot.docs.map(firestoreDocToUser);
      onUpdate(liveUsers);
    },
    (error) => {
      console.error("Firestore users listener error:", error);
    }
  );
}

function stopLiveUserSync() {
  if (unsubscribeUsers) unsubscribeUsers();
}

/**
 * Writes a status change (and optional extra fields, e.g. assigned unit)
 * back to the report's Firestore document, so the mobile app — which
 * reads the same document — sees the update in real time too.
 *
 * incidentId: the Firestore doc id (same as incident.id in the dashboard)
 * newStatus: "pending" | "dispatched" | "resolved" | "cancelled"
 * extraFields: optional object of other dashboard-side fields to set,
 *   e.g. { unit: "Barangay Tanod 3" } — mapped through FIELD_MAP.
 */
async function updateIncidentStatus(incidentId, newStatus, extraFields = {}) {
  if (!firestoreDb) {
    console.error("Cannot update status — Firestore is not connected.");
    return { ok: false, error: "not-connected" };
  }
  try {
    const updates = { [FIELD_MAP.status]: newStatus };
    for (const key in extraFields) {
      const mappedKey = FIELD_MAP[key] || key;
      updates[mappedKey] = extraFields[key];
    }
    const ref = doc(firestoreDb, REPORTS_COLLECTION, incidentId);
    await updateDoc(ref, updates);
    return { ok: true };
  } catch (err) {
    console.error("Failed to update incident status in Firestore:", err);
    return { ok: false, error: err.message };
  }
}

function showFirebaseSetupWarning() {
  const el = document.getElementById("firebaseStatus");
  if (el) {
    el.textContent = "Not connected to Firebase — showing demo data. Check firebase.js configuration.";
    el.classList.add("show");
  }
}

function hideFirebaseSetupWarning() {
  const el = document.getElementById("firebaseStatus");
  if (el) el.classList.remove("show");
}

// Expose to the main app.js (plain script, not a module) via window
window.instaRosaFirebase = {
  start: startLiveIncidentSync,
  stop: stopLiveIncidentSync,
  updateStatus: updateIncidentStatus,
  startUsers: startLiveUserSync,
  stopUsers: stopLiveUserSync,
  hideWarning: hideFirebaseSetupWarning,
  isConfigured: FIREBASE_CONFIG.apiKey !== "PASTE_YOUR_API_KEY"
};
