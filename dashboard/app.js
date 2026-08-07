/* =========================================================
   instaROSA Dispatch Command — Operator-side functionality
   Barangay-level (community) vs LGU emergency (distress)
   response triage, per the project brief.
   ========================================================= */

// ---- ICONS (reused per category) ----
const ICONS = {
  distress: `<svg viewBox="0 0 24 24" fill="none"><path d="M12 2L2 7L12 12L22 7L12 2Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><path d="M2 17L12 22L22 17" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><path d="M2 12L12 17L22 12" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/></svg>`,
  community: `<svg viewBox="0 0 24 24" fill="none"><path d="M3 10V14H6L11 18V6L6 10H3Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><path d="M15 8.5C16 9.5 16 14.5 15 15.5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/><path d="M17.5 6C19.5 8 19.5 16 17.5 18" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg>`,
  loc: `<svg viewBox="0 0 24 24" fill="none"><path d="M12 21C12 21 19 14.5 19 9.5C19 5.5 16 2 12 2C8 2 5 5.5 5 9.5C5 14.5 12 21 12 21Z" stroke="currentColor" stroke-width="1.5"/><circle cx="12" cy="9.5" r="2.2" stroke="currentColor" stroke-width="1.4"/></svg>`,
  check: `<svg viewBox="0 0 24 24" fill="none"><path d="M4 12L9 17L20 6" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>`
};

// ---- UNITS AVAILABLE FOR DISPATCH ----
// Sourced live from unitsRegistry (the Units Registry page) so any unit
// added, edited, or removed there is immediately reflected in the
// Dispatch modal — no separate trial/seed list to keep in sync.

// ---- ANALYTICS: DOMAIN KNOWLEDGE BASE ----
// Static rules used to auto-generate the Preventative Analysis report on the
// Analytics tab: likely root cause, prevention actions per timeframe, who's
// responsible, and (for traffic-impacting incidents) a base clearance-time
// estimate in hours per severity level used for the traffic prediction.
const INCIDENT_INSIGHTS = {
  "CDRRMO": {
    rootCause: "Varies by case — CDRRMO handles disaster/rescue-level emergencies (flooding, landslides, large-scale accidents) where the underlying cause is situational.",
    immediate: "Dispatch CDRRMO rescue/response team; reroute traffic and push a geofenced alert to app users in the affected barangay if the incident is disruptive.",
    medium: "Review the specific incident type once resolved to identify a recurring pattern (e.g. same flood-prone street, same accident corridor).",
    longTerm: "Escalate chronically recurring hazards to the LGU for infrastructure review (drainage, road engineering, etc.).",
    responsible: "CDRRMO",
    impact: "Faster mobilization and clearer post-incident pattern tracking.",
    trafficImpact: true,
    baseHours: { high: 4, medium: 2.5, low: 1, info: 0.5 }
  },
  "BFP": {
    rootCause: "Fire-related — commonly faulty electrical wiring, unsafe cooking practices, or unmaintained fire hazards.",
    immediate: "Cut power to the affected structure if safe to do so; evacuate and cordon the block; dispatch BFP.",
    medium: "Conduct fire-safety inspections of nearby structures in the same barangay.",
    longTerm: "Run a barangay-wide electrical safety and fire-prevention education campaign.",
    responsible: "BFP",
    impact: "Lowers ignition risk and improves evacuation readiness.",
    trafficImpact: true,
    baseHours: { high: 3, medium: 2, low: 1, info: 0.5 }
  },
  "EMS": {
    rootCause: "Situational — varies by case (health condition, accident, or environmental exposure).",
    immediate: "Prioritize EMS dispatch and keep the route clear for the ambulance.",
    medium: "Review response times to this barangay and pre-position a unit if it's a recurring hotspot.",
    longTerm: "Coordinate with barangay health workers on at-risk household check-ins.",
    responsible: "EMS",
    impact: "Improves survival odds and response consistency.",
    trafficImpact: false
  },
  "POSO": {
    rootCause: "Public order/safety concern — road conditions, traffic control gaps, or peacekeeping matters depending on the report.",
    immediate: "Dispatch POSO personnel to manage the scene and, if traffic-related, alert nearby drivers via geofence.",
    medium: "Review signage, lighting, or patrol coverage at the location if the issue recurs.",
    longTerm: "Petition for infrastructure or policy review if the same location generates repeat reports.",
    responsible: "POSO",
    impact: "Reduces recurrence and clears the scene faster.",
    trafficImpact: true,
    baseHours: { high: 2.5, medium: 1.5, low: 0.75, info: 0.5 }
  },
  "Parking": {
    rootCause: "Illegal or obstructive parking, often due to insufficient designated parking or lack of enforcement.",
    immediate: "Send barangay tanod/traffic aide to the location to clear the obstruction and log the complaint.",
    medium: "Increase enforcement visibility at repeat-offender locations.",
    longTerm: "Push for designated parking zones or stricter towing policy in chronic hotspots.",
    responsible: "Barangay Tanod / Traffic Unit",
    impact: "Reduces road obstruction and repeat complaints.",
    trafficImpact: true,
    baseHours: { high: 1, medium: 0.5, low: 0.25, info: 0.25 }
  },
  "Noise": {
    rootCause: "Lack of enforced noise ordinance / no curfew compliance in the area.",
    immediate: "Send barangay tanod to issue a verbal warning and log the complaint.",
    medium: "Post visible noise-ordinance signage in repeat-offender areas.",
    longTerm: "Push a consistent enforcement policy with escalating penalties for repeat violations.",
    responsible: "Barangay Tanod",
    impact: "Reduces repeat complaints and neighbor conflict.",
    trafficImpact: false
  },
  "Disorder": {
    rootCause: "Alcohol-related or unsupervised public gatherings, or general public-disturbance/conflict situations.",
    immediate: "Dispatch barangay police to de-escalate and disperse if needed; ensure reporter safety if it's a conflict situation.",
    medium: "Increase patrol frequency at recurring locations during peak hours.",
    longTerm: "Coordinate with venue owners/organizers on crowd-management requirements, or strengthen community outreach for conflict-related reports.",
    responsible: "Barangay Police",
    impact: "Prevents escalation into violence and repeat disturbances.",
    trafficImpact: false
  },
  "Infrastructure": {
    rootCause: "Damaged or deteriorating public infrastructure — potholes, broken streetlights, damaged facilities, or similar — often from wear, weather, or lack of maintenance.",
    immediate: "Assess the report and assign it to Barangay Engineering or the City Engineering Office / Public Works, depending on severity and scope.",
    medium: "Schedule a repair crew visit within the barangay's standard maintenance window.",
    longTerm: "Log recurring infrastructure issues at the same location to support a capital-improvement or maintenance-budget request.",
    responsible: "Assigned by dispatch operator (Barangay Engineering or City Engineering / Public Works)",
    impact: "Prevents further deterioration and reduces safety hazards from unaddressed damage.",
    trafficImpact: true,
    baseHours: { high: 3, medium: 1.5, low: 0.75, info: 0.5 }
  }
};

// Fallback for any incident title not yet mapped above.
const DEFAULT_INSIGHT = {
  rootCause: "Not yet mapped — add this incident type to INCIDENT_INSIGHTS in app.js for a tailored analysis.",
  immediate: "Triage per standard operating procedure for its severity level.",
  medium: "Review after-action notes once resolved to look for a pattern.",
  longTerm: "Add a dedicated prevention rule for this incident type once enough reports accumulate.",
  responsible: "Dispatch Operator",
  impact: "Establishes a baseline for this incident type.",
  trafficImpact: false
};

function getInsight(title) {
  return INCIDENT_INSIGHTS[title] || DEFAULT_INSIGHT;
}

// ---- ANALYTICS: PREDICTED TRAFFIC / DISRUPTION IMPACT ----
// Rule-based estimate (not a live model): base clearance hours by severity,
// plus a compounding factor when multiple traffic-impacting reports cluster
// in the same barangay at once (e.g. flooding + an accident nearby).
function estimateImpactHours(insight, severity, clusterCount) {
  const base = (insight.baseHours && insight.baseHours[severity]) || 2;
  const clusterBonus = Math.min(Math.max(clusterCount - 1, 0), 3) * 0.5;
  const low = Math.max(0.5, base + clusterBonus - 0.5);
  const high = base + clusterBonus + 1;
  return { low: Math.round(low * 10) / 10, high: Math.round(high * 10) / 10 };
}

// ---- INCIDENT DATA (in-memory store) ----
let incidents = [];

let activityLog = [];

// ---- STATE ----
let state = {
  filter: "all",
  district: "All Barangays",
  sort: "newest",
  search: "",
  activeIncidentId: null,   // for dispatch modal
  dispatchScope: "barangay", // "barangay" | "city" — selected scope in dispatch modal
  pendingAction: null,      // for confirm modal {id, action}
  historyFilter: "all"      // "all" | "unresolved" | "resolved" | "cancelled" — History view filter
};

// ---- UTIL ----
function timeLabel(mins) {
  if (mins < 60) return `${mins} min${mins === 1 ? "" : "s"} ago`;
  const h = Math.floor(mins / 60);
  return `${h} hr${h === 1 ? "" : "s"} ago`;
}

function severityRank(sev) {
  return { high: 0, medium: 1, low: 2, info: 3 }[sev] ?? 4;
}

function showToast(msg) {
  const t = document.getElementById("toast");
  t.textContent = msg;
  t.classList.add("show");
  clearTimeout(showToast._timer);
  showToast._timer = setTimeout(() => t.classList.remove("show"), 2800);
}

// ---- FILTERING / SORTING ----
function getFilteredIncidents() {
  // Closed cases (resolved/cancelled) leave the Live Incident Queue
  // automatically the moment they're closed — they live in History instead.
  let list = incidents.filter(i => i.status !== "resolved" && i.status !== "cancelled");

  // tab filter
  if (state.filter === "high") list = list.filter(i => i.severity === "high");
  if (state.filter === "active") list = list.filter(i => i.status === "pending" || i.status === "dispatched");

  // district filter
  if (state.district !== "All Barangays") {
    list = list.filter(i => i.district === state.district);
  }

  // search
  if (state.search.trim()) {
    const q = state.search.trim().toLowerCase();
    list = list.filter(i =>
      i.title.toLowerCase().includes(q) ||
      i.location.toLowerCase().includes(q) ||
      i.id.toLowerCase().includes(q) ||
      i.reporter.toLowerCase().includes(q)
    );
  }

  // sort
  if (state.sort === "newest") list.sort((a, b) => a.minsAgo - b.minsAgo);
  if (state.sort === "oldest") list.sort((a, b) => b.minsAgo - a.minsAgo);
  if (state.sort === "severity") list.sort((a, b) => severityRank(a.severity) - severityRank(b.severity));

  return list;
}

// ---- HISTORY: FILTERING ----
// The History view lists every report ever made — pending, dispatched,
// resolved, and cancelled alike — with its own filter separate from the
// Live Incident Queue's filters above.
function getHistoryIncidents() {
  let list = incidents.slice();

  if (state.historyFilter === "unresolved") {
    list = list.filter(i => i.status === "pending" || i.status === "dispatched");
  } else if (state.historyFilter === "resolved") {
    list = list.filter(i => i.status === "resolved");
  } else if (state.historyFilter === "cancelled") {
    list = list.filter(i => i.status === "cancelled");
  }
  // "all" — no filtering, every report shows

  // newest first
  list.sort((a, b) => a.minsAgo - b.minsAgo);
  return list;
}

// ---- RENDER: HISTORY LIST ----
function renderHistory() {
  const list = getHistoryIncidents();
  const listEl = document.getElementById("historyList");
  const emptyEl = document.getElementById("historyEmptyState");

  if (list.length === 0) {
    listEl.innerHTML = "";
    emptyEl.style.display = "block";
  } else {
    emptyEl.style.display = "none";
    listEl.innerHTML = list.map(cardHtml).join("");
  }

  const all = incidents.length;
  const unresolved = incidents.filter(i => i.status === "pending" || i.status === "dispatched").length;
  const resolved = incidents.filter(i => i.status === "resolved").length;
  const cancelled = incidents.filter(i => i.status === "cancelled").length;

  document.getElementById("histCountAll").textContent = `(${all})`;
  document.getElementById("histCountUnresolved").textContent = `(${unresolved})`;
  document.getElementById("histCountResolved").textContent = `(${resolved})`;
  document.getElementById("histCountCancelled").textContent = `(${cancelled})`;
}

// ---- HISTORY TABS ----
function setupHistoryTabs() {
  document.getElementById("historyTabs").addEventListener("click", (e) => {
    const tab = e.target.closest(".tab");
    if (!tab) return;
    document.querySelectorAll("#historyTabs .tab").forEach(t => t.classList.remove("active"));
    tab.classList.add("active");
    state.historyFilter = tab.dataset.historyFilter;
    renderHistory();
  });
}

// ---- RENDER: INCIDENT CARD ----
function cardHtml(inc) {
  const iconClass = inc.category === "distress" ? "icon-distress" : "icon-community";
  const tagClass = inc.category === "distress" ? "tag-distress" : "tag-community";
  const icon = inc.category === "distress" ? ICONS.distress : ICONS.community;
  const highlighted = (inc.severity === "high" && inc.status === "pending") ? "highlighted" : "";

  const statusLabel = {
    pending: "PENDING",
    dispatched: "DISPATCHED",
    resolved: "RESOLVED",
    cancelled: "CANCELLED"
  }[inc.status];

  const statusClass = {
    pending: "status-pending",
    dispatched: "status-dispatched",
    resolved: "status-resolved",
    cancelled: "status-cancelled"
  }[inc.status];

  let actions = "";
  if (inc.status === "pending") {
    actions = inc.category === "distress"
      ? `<button class="btn btn-primary" data-action="dispatch" data-id="${inc.id}">Dispatch Unit</button>
         <button class="btn btn-secondary" data-action="resolve" data-id="${inc.id}">Resolve</button>`
      : `<button class="btn btn-resolve" data-action="resolve" data-id="${inc.id}">Resolve</button>
         <button class="btn btn-dismiss" data-action="dismiss" data-id="${inc.id}">Dismiss</button>`;
  } else if (inc.status === "dispatched") {
    actions = `<button class="btn btn-resolve" data-action="resolve" data-id="${inc.id}">Mark Resolved</button>`;
  } else {
    actions = `<span class="closed-label">${inc.status === "resolved" ? "Closed" : "Cancelled"}</span>`;
  }

  const unitLine = inc.unit
    ? `<p class="incident-unit">Assigned: <strong>${inc.unit}</strong> <span class="scope-pill scope-pill-${inc.dispatchScope}">${inc.dispatchScope === "city" ? "City-Wide" : "Barangay"}</span></p>`
    : "";

  return `
  <div class="incident-card ${highlighted}" data-card-id="${inc.id}">
    <div class="incident-icon ${iconClass}">${icon}</div>
    <div class="incident-body">
      <div class="incident-tag-row">
        <span class="tag ${tagClass}">${inc.tag}</span>
        <span class="incident-time">${timeLabel(inc.minsAgo)}</span>
      </div>
      <h3 class="incident-title">${inc.title}</h3>
      <p class="incident-loc">${ICONS.loc}${inc.location}</p>
      <p class="incident-reporter">Reporter: ${inc.reporter} (${inc.phone})</p>
      <p class="incident-report-id">Report ID: ${inc.id}</p>
      ${unitLine}
      <div class="incident-meta-row">
        <span class="meta-label">Severity: <strong class="sev-${inc.severity}">${inc.severity.toUpperCase()}</strong></span>
        <span class="meta-label">Status: <strong class="${statusClass}">${statusLabel}</strong></span>
      </div>
    </div>
    <div class="incident-actions">${actions}</div>
  </div>`;
}

function renderIncidents() {
  const list = getFilteredIncidents();
  const listEl = document.getElementById("incidentList");
  const emptyEl = document.getElementById("emptyState");

  if (list.length === 0) {
    listEl.innerHTML = "";
    emptyEl.style.display = "block";
  } else {
    emptyEl.style.display = "none";
    listEl.innerHTML = list.map(cardHtml).join("");
  }

  attachCardListeners();
}

// ---- RENDER: TABS / COUNTS ----
function renderCounts() {
  const totalAll = incidents.length; // all-time total, for the sidebar summary
  // "all" tab reflects the Live Incident Queue itself — closed cases don't
  // count here since they've already moved to History.
  const queueAll = incidents.filter(i => i.status !== "resolved" && i.status !== "cancelled").length;
  const high = incidents.filter(i => i.severity === "high" && i.status !== "resolved" && i.status !== "cancelled").length;
  const active = incidents.filter(i => i.status === "pending" || i.status === "dispatched").length;
  const resolved = incidents.filter(i => i.status === "resolved").length;
  const cancelled = incidents.filter(i => i.status === "cancelled").length;

  document.getElementById("countAll").textContent = `(${queueAll})`;
  document.getElementById("countHigh").textContent = `(${high})`;
  document.getElementById("countActive").textContent = `(${active})`;

  document.getElementById("sumTotal").textContent = totalAll;
  document.getElementById("sumHigh").textContent = high;
  document.getElementById("sumActive").textContent = active;
  document.getElementById("sumResolved").textContent = resolved;
  document.getElementById("sumCancelled").textContent = cancelled;
}

// ---- RENDER: SEVERITY DONUT ----
function renderDonut() {
  const total = incidents.length || 1;
  const counts = { high: 0, medium: 0, low: 0, info: 0 };
  incidents.forEach(i => { counts[i.severity] = (counts[i.severity] || 0) + 1; });

  const pct = {
    high: Math.round((counts.high / total) * 100),
    medium: Math.round((counts.medium / total) * 100),
    low: Math.round((counts.low / total) * 100),
    info: Math.round((counts.info / total) * 100)
  };

  document.getElementById("legHigh").textContent = `${counts.high} (${pct.high}%)`;
  document.getElementById("legMedium").textContent = `${counts.medium} (${pct.medium}%)`;
  document.getElementById("legLow").textContent = `${counts.low} (${pct.low}%)`;
  document.getElementById("legInfo").textContent = `${counts.info} (${pct.info}%)`;

  // build stroke-dasharray segments around 100 circumference units
  let offset = 25; // start at top (circle rotated -90deg in CSS)
  const segments = [
    { id: "donutHigh", val: pct.high },
    { id: "donutMedium", val: pct.medium },
    { id: "donutLow", val: pct.low },
    { id: "donutInfo", val: pct.info }
  ];
  segments.forEach(seg => {
    const el = document.getElementById(seg.id);
    el.setAttribute("stroke-dasharray", `${seg.val} ${100 - seg.val}`);
    el.setAttribute("stroke-dashoffset", offset);
    offset -= seg.val;
  });
}

// ---- RENDER: RECENT ACTIVITY ----
function renderActivity() {
  const el = document.getElementById("activityList");
  const recent = activityLog.slice(0, 5);
  el.innerHTML = recent.map(a => {
    const cls = a.type === "resolved" ? "activity-green" : a.type === "community" ? "activity-blue" : "activity-red";
    const icon = a.type === "resolved" ? ICONS.check : ICONS.distress;
    return `
    <div class="activity-item">
      <span class="activity-icon ${cls}">${icon}</span>
      <div class="activity-text">
        <strong>${a.title}</strong>
        <span>${a.note}</span>
      </div>
      <span class="activity-time">${timeLabel(a.minsAgo)}</span>
    </div>`;
  }).join("");
}

function logActivity(title, note, type) {
  activityLog.unshift({ title, note, minsAgo: 0, type });
  activityLog = activityLog.slice(0, 20);
}

// ---- ANALYTICS: PREDICTED IMPACT CALLOUTS ----
// e.g. "Heavy traffic in Sinalhan — Flooding. Estimated disruption: 3.5–6 hrs."
function renderImpactCallouts() {
  const wrap = document.getElementById("impactCalloutWrap");
  const list = document.getElementById("impactCalloutList");
  if (!wrap || !list) return;

  const active = incidents.filter(i => i.status === "pending" || i.status === "dispatched");
  const trafficActive = active.filter(i => getInsight(i.title).trafficImpact);

  if (trafficActive.length === 0) {
    wrap.style.display = "none";
    list.innerHTML = "";
    return;
  }

  wrap.style.display = "block";
  list.innerHTML = trafficActive.map(inc => {
    const insight = getInsight(inc.title);
    const clusterCount = active.filter(i => i.district === inc.district && getInsight(i.title).trafficImpact).length;
    const { low, high } = estimateImpactHours(insight, inc.severity, clusterCount);
    const sevClass = inc.severity === "high" ? "severity-high" : "";
    const clusterNote = clusterCount > 1 ? ` and ${clusterCount} related reports nearby` : "";

    return `
    <div class="impact-callout ${sevClass}">
      <span class="impact-callout-icon">${ICONS.distress}</span>
      <div class="impact-callout-body">
        <strong>Heavy traffic likely in ${inc.district || "the area"} — ${inc.title}</strong>
        <span>Estimated disruption: <strong>${low}–${high} hrs</strong>, based on ${inc.severity} severity${clusterNote}. Suggest rerouting traffic and monitoring until cleared.</span>
      </div>
    </div>`;
  }).join("");
}

// ---- ANALYTICS: ROOT CAUSE TABLE ----
function renderRootCauseTable() {
  const body = document.getElementById("rootCauseBody");
  if (!body) return;

  const counts = {};
  incidents.forEach(i => { counts[i.title] = (counts[i.title] || 0) + 1; });
  const rows = Object.entries(counts).sort((a, b) => b[1] - a[1]);

  body.innerHTML = rows.map(([title, count]) => {
    const insight = getInsight(title);
    return `<tr><td class="cell-strong">${title}</td><td>${count}</td><td>${insight.rootCause}</td></tr>`;
  }).join("");
}

// ---- ANALYTICS: SPATIO-TEMPORAL HOTSPOTS ----
function renderHotspotTable() {
  const body = document.getElementById("hotspotBody");
  const note = document.getElementById("hotspotNote");
  if (!body) return;

  const byDistrict = {};
  incidents.forEach(i => {
    const d = i.district || "Unassigned";
    (byDistrict[d] = byDistrict[d] || []).push(i);
  });

  const rows = Object.entries(byDistrict).sort((a, b) => b[1].length - a[1].length).slice(0, 8);
  const rank = { high: 0, medium: 1, low: 2, info: 3 };

  body.innerHTML = rows.map(([district, list]) => {
    const worst = list.reduce((a, b) => (rank[b.severity] < rank[a.severity] ? b : a));
    return `<tr><td class="cell-strong">${district}</td><td>${list.length}</td><td class="sev-${worst.severity}">${worst.severity.toUpperCase()}</td></tr>`;
  }).join("");

  if (note) {
    note.textContent = rows.length
      ? `${rows[0][0]} has the most reports on record (${rows[0][1].length}) — prioritize patrol coverage there. Connect full report timestamps via Firestore for hour/day-of-week pattern analysis.`
      : "";
  }
}

// ---- ANALYTICS: ESCALATION & HAZARD WARNINGS ----
// Flags repeat low-severity community complaints (same type + barangay)
// that risk escalating into disorderly conduct or violence if ignored.
function renderEscalationWarnings() {
  const wrap = document.getElementById("escalationList");
  if (!wrap) return;

  const communityTitles = ["Noisy Karaoke", "Noise Complaint", "Disorderly Conduct", "Public Disturbance"];
  const grouped = {};
  incidents.forEach(i => {
    if (!communityTitles.includes(i.title)) return;
    const key = `${i.title}::${i.district || "Unassigned"}`;
    grouped[key] = (grouped[key] || 0) + 1;
  });

  const warnings = Object.entries(grouped).filter(([, count]) => count >= 2).sort((a, b) => b[1] - a[1]);

  if (warnings.length === 0) {
    wrap.innerHTML = `<p class="escalation-empty">No repeat low-severity patterns detected yet — nothing flagged for escalation risk.</p>`;
    return;
  }

  wrap.innerHTML = warnings.map(([key, count]) => {
    const [title, district] = key.split("::");
    return `
    <div class="escalation-item">
      ${ICONS.check}
      <span><strong>${count}× ${title}</strong> reports in <strong>${district}</strong> — repeat low-severity complaints like this risk escalating into disorderly conduct or altercations if left unaddressed. Consider a scheduled tanod patrol during peak hours.</span>
    </div>`;
  }).join("");
}

// ---- ANALYTICS: PREVENTION ROADMAP ----
function renderRoadmap() {
  const immEl = document.getElementById("roadmapImmediate");
  const medEl = document.getElementById("roadmapMedium");
  const longEl = document.getElementById("roadmapLongTerm");
  if (!immEl || !medEl || !longEl) return;

  const active = incidents.filter(i => i.status === "pending" || i.status === "dispatched");
  const source = active.length ? active : incidents;
  const titles = [...new Set(source.map(i => i.title))];

  if (titles.length === 0) {
    immEl.innerHTML = medEl.innerHTML = longEl.innerHTML = `<li>No incident data yet.</li>`;
    return;
  }

  immEl.innerHTML = titles.map(t => `<li>${getInsight(t).immediate}</li>`).join("");
  medEl.innerHTML = titles.map(t => `<li>${getInsight(t).medium}</li>`).join("");
  longEl.innerHTML = titles.map(t => `<li>${getInsight(t).longTerm}</li>`).join("");
}

// ---- ANALYTICS: PRIORITY ACTION MATRIX ----
function renderPriorityMatrix() {
  const body = document.getElementById("priorityMatrixBody");
  if (!body) return;

  const titles = [...new Set(incidents.map(i => i.title))];
  body.innerHTML = titles.map(t => {
    const insight = getInsight(t);
    return `<tr>
      <td class="cell-strong">${t}</td>
      <td>${insight.rootCause}</td>
      <td>${insight.medium}</td>
      <td>${insight.responsible}</td>
      <td>${insight.impact}</td>
    </tr>`;
  }).join("");
}

// ---- ANALYTICS: FULL REPORT RENDER ----
function renderAnalytics() {
  renderImpactCallouts();
  renderRootCauseTable();
  renderHotspotTable();
  renderEscalationWarnings();
  renderRoadmap();
  renderPriorityMatrix();

  const stamp = document.getElementById("analysisTimestamp");
  if (stamp) {
    stamp.textContent = incidents.length
      ? `Auto-updates with live data · ${incidents.length} report${incidents.length === 1 ? "" : "s"} analyzed`
      : "Auto-updates with live data";
  }

  const emptyEl = document.getElementById("analysisEmptyState");
  if (emptyEl) emptyEl.style.display = incidents.length === 0 ? "block" : "none";
}

// ---- FULL RE-RENDER ----
function renderAll() {
  renderIncidents();
  renderCounts();
  renderDonut();
  renderActivity();
  renderHistory();
  renderAnalytics();
  if (gmap) renderMapMarkers();
  if (document.getElementById("mapPinList") && document.getElementById("mapPinList").style.display === "flex") {
    renderFallbackPinList();
  }
}

// ---- CARD ACTION LISTENERS ----
// Uses one-time event delegation on the document so it works correctly
// for cards re-rendered in both the Live Incident Queue and the History
// view, without stacking duplicate listeners on every re-render.
function attachCardListeners() {
  if (attachCardListeners._bound) return;
  attachCardListeners._bound = true;

  document.addEventListener("click", (e) => {
    const btn = e.target.closest("[data-action]");
    if (!btn) return;
    const action = btn.dataset.action;
    const id = btn.dataset.id;
    if (action === "dispatch") openDispatchModal(id);
    if (action === "resolve") openConfirmModal(id, "resolve");
    if (action === "dismiss") openConfirmModal(id, "dismiss");
  });
}

// ---- DISPATCH MODAL ----
function renderUnitOptions() {
  const relevantUnits = unitsRegistry.filter(u => u.scope === state.dispatchScope && u.status === "available");
  if (relevantUnits.length === 0) {
    document.getElementById("unitOptions").innerHTML =
      `<p class="modal-incident-loc">No available ${state.dispatchScope === "city" ? "city-wide" : "barangay"} units. Add one in the Units page first.</p>`;
    return;
  }
  const unitsHtml = relevantUnits.map((u, idx) => `
    <label class="unit-option">
      <input type="radio" name="unit" value="${u.id}" ${idx === 0 ? "checked" : ""}>
      <span class="unit-option-body">
        <strong>${u.name}</strong>
        <small>${u.type}</small>
      </span>
    </label>`).join("");
  document.getElementById("unitOptions").innerHTML = unitsHtml;
}

function setDispatchScope(scope) {
  state.dispatchScope = scope;
  document.querySelectorAll(".scope-btn").forEach(b => {
    b.classList.toggle("active", b.dataset.scope === scope);
  });
  renderUnitOptions();
}

function openDispatchModal(id) {
  const inc = incidents.find(i => i.id === id);
  if (!inc) return;
  state.activeIncidentId = id;

  document.getElementById("modalIncidentTitle").textContent = `${inc.title} — ${inc.id}`;
  document.getElementById("modalIncidentLoc").textContent = inc.location;
  document.getElementById("dispatchNote").value = "";

  // High-severity distress defaults to city-wide assistance; everything
  // else defaults to barangay assistance, but the operator can switch.
  const defaultScope = (inc.category === "distress" && inc.severity === "high") ? "city" : "barangay";
  setDispatchScope(defaultScope);

  document.getElementById("dispatchModal").classList.add("show");
}

function closeDispatchModal() {
  document.getElementById("dispatchModal").classList.remove("show");
  state.activeIncidentId = null;
}

function confirmDispatch() {
  const id = state.activeIncidentId;
  const inc = incidents.find(i => i.id === id);
  if (!inc) return;

  const selected = document.querySelector('input[name="unit"]:checked');
  if (!selected) { showToast("Select a unit before confirming dispatch."); return; }

  const unit = unitsRegistry.find(u => u.id === selected.value);
  if (!unit) { showToast("Selected unit is no longer available."); return; }
  inc.status = "dispatched";
  inc.unit = unit.name;
  inc.dispatchScope = state.dispatchScope;

  // Mark the unit as deployed in the registry
  unit.status = "deployed";

  logActivity(inc.title, `${unit.name} dispatched (${state.dispatchScope === "city" ? "City-Wide" : "Barangay"})`, "distress");
  showToast(`${unit.name} dispatched to ${inc.title} (${inc.id})`);

  closeDispatchModal();
  renderAll();
}

// ---- CONFIRM MODAL (resolve / dismiss) ----
function openConfirmModal(id, action) {
  const inc = incidents.find(i => i.id === id);
  if (!inc) return;
  state.pendingAction = { id, action };

  const verb = action === "resolve" ? "resolve" : "dismiss";
  document.getElementById("confirmTitle").textContent = action === "resolve" ? "Resolve Incident" : "Dismiss Report";
  document.getElementById("confirmMessage").textContent =
    `Are you sure you want to ${verb} "${inc.title}" (${inc.id})? This will update the incident status and move it out of the active queue.`;

  document.getElementById("confirmModal").classList.add("show");
}

function closeConfirmModal() {
  document.getElementById("confirmModal").classList.remove("show");
  state.pendingAction = null;
}

async function runConfirmedAction() {
  if (!state.pendingAction) return;
  const { id, action } = state.pendingAction;
  const inc = incidents.find(i => i.id === id);
  if (!inc) return;

  const newStatus = action === "resolve" ? "resolved" : "cancelled";

  // Optimistically update local state so the dashboard UI feels instant.
  inc.status = newStatus;
  if (inc.unit) {
    const regUnit = unitsRegistry.find(u => u.name === inc.unit);
    if (regUnit && regUnit.status === "deployed") regUnit.status = "available";
  }

  if (action === "resolve") {
    logActivity(inc.title, `Resolved${inc.unit ? " by " + inc.unit : ""}`, "resolved");
    showToast(`${inc.title} (${inc.id}) marked resolved.`);
  } else if (action === "dismiss") {
    logActivity(inc.title, "Report dismissed", "community");
    showToast(`${inc.title} (${inc.id}) dismissed.`);
  }

  closeConfirmModal();
  renderAll();

  // Push the status change to Firestore so the mobile app sees it too.
  // Only applies to live (Firestore-backed) incidents — seed/demo data
  // has no matching document to write to.
  if (inc._live && window.instaRosaFirebase && window.instaRosaFirebase.isConfigured) {
    const result = await window.instaRosaFirebase.updateStatus(inc.id, newStatus);
    if (!result.ok) {
      showToast(`Warning: "${inc.title}" updated locally but failed to sync to Firebase.`);
    }
  }
}

// ---- TABS ----
function setupTabs() {
  document.getElementById("tabs").addEventListener("click", (e) => {
    const tab = e.target.closest(".tab");
    if (!tab) return;
    document.querySelectorAll(".tab").forEach(t => t.classList.remove("active"));
    tab.classList.add("active");
    state.filter = tab.dataset.filter;
    renderIncidents();
  });
}

// ---- SEARCH ----
function setupSearch() {
  const input = document.getElementById("searchInput");
  input.addEventListener("input", () => {
    state.search = input.value;
    renderIncidents();
  });
}

// ---- DROPDOWNS (district / sort / notif / msg / user) ----
function setupDropdown(anchorBtnId, panelId, { onSelect } = {}) {
  const btn = document.getElementById(anchorBtnId);
  const panel = document.getElementById(panelId);

  btn.addEventListener("click", (e) => {
    e.stopPropagation();
    const isOpen = panel.classList.contains("show");
    document.querySelectorAll(".dropdown-panel.show").forEach(p => p.classList.remove("show"));
    if (!isOpen) panel.classList.add("show");
  });

  if (onSelect) {
    panel.querySelectorAll(".dropdown-option").forEach(opt => {
      opt.addEventListener("click", () => {
        panel.querySelectorAll(".dropdown-option").forEach(o => o.classList.remove("selected"));
        opt.classList.add("selected");
        onSelect(opt.dataset.value);
        panel.classList.remove("show");
      });
    });
  }
}

function closeAllDropdowns() {
  document.querySelectorAll(".dropdown-panel.show").forEach(p => p.classList.remove("show"));
}

// ---- BARANGAY COORDINATES (City of Santa Rosa, Laguna) ----
// Approximate centroids, used to recenter the map per barangay.
const SANTA_ROSA_CENTER = { lat: 14.3122, lng: 121.1114 };
const BARANGAY_COORDS = {
  "Aplaya": { lat: 14.2965, lng: 121.1041 },
  "Balibago": { lat: 14.2967, lng: 121.0716 },
  "Caingin": { lat: 14.3155, lng: 121.0972 },
  "Dila": { lat: 14.3204, lng: 121.0827 },
  "Dita": { lat: 14.3282, lng: 121.1102 },
  "Don Jose": { lat: 14.2803, lng: 121.0699 },
  "Ibaba": { lat: 14.3129, lng: 121.1152 },
  "Kanluran": { lat: 14.3143, lng: 121.1090 },
  "Labas": { lat: 14.3161, lng: 121.1128 },
  "Macabling": { lat: 14.3059, lng: 121.1046 },
  "Malitlit": { lat: 14.3287, lng: 121.0937 },
  "Malusak": { lat: 14.3117, lng: 121.1074 },
  "Market Area": { lat: 14.3126, lng: 121.1121 },
  "Pooc": { lat: 14.3092, lng: 121.1105 },
  "Pulong Santa Cruz": { lat: 14.2926, lng: 121.0839 },
  "Santo Domingo": { lat: 14.3226, lng: 121.1189 },
  "Sinalhan": { lat: 14.3011, lng: 121.1157 },
  "Tagapo": { lat: 14.3186, lng: 121.1054 }
};

// ---- MAP STATE ----
let gmap = null;                 // google.maps.Map instance, once loaded
let mapMarkers = {};             // incident id -> google.maps.Marker
let mapInfoWindow = null;        // shared info window for pin clicks
let mapApiKey = null;            // key entered by the operator this session

// Pins only ever represent incidents still open — resolved/cancelled
// reports are excluded and any existing marker for them is removed.
function pinnableIncidents() {
  return incidents.filter(i => i.status !== "resolved" && i.status !== "cancelled" && i.lat && i.lng);
}

function severityPinColor(sev) {
  return { high: "#D6483F", medium: "#F0A93E", low: "#5B8DEF", info: "#9AA5B1" }[sev] || "#9AA5B1";
}

// ---- GOOGLE MAPS JS API LOADING ----
function loadGoogleMapsScript(key) {
  return new Promise((resolve, reject) => {
    if (window.google && window.google.maps) { resolve(); return; }
    const existing = document.getElementById("gmapsScript");
    if (existing) { existing.addEventListener("load", () => resolve()); return; }
    const script = document.createElement("script");
    script.id = "gmapsScript";
    script.src = `https://maps.googleapis.com/maps/api/js?key=${encodeURIComponent(key)}`;
    script.async = true;
    script.onload = () => resolve();
    script.onerror = () => reject(new Error("Failed to load Google Maps."));
    document.head.appendChild(script);
  });
}

async function initGoogleMap(key) {
  try {
    await loadGoogleMapsScript(key);
  } catch (err) {
    showToast("Couldn't load Google Maps with that key. Check the key and try again.");
    return;
  }
  if (!window.google || !window.google.maps) {
    showToast("Google Maps failed to initialize.");
    return;
  }

  mapApiKey = key;
  document.getElementById("mapKeyNotice").classList.add("hidden");
  document.getElementById("mapPinList").style.display = "none";
  document.getElementById("mapCanvas").style.display = "block";

  gmap = new google.maps.Map(document.getElementById("mapCanvas"), {
    center: SANTA_ROSA_CENTER,
    zoom: 13,
    mapTypeControl: false,
    streetViewControl: false,
    fullscreenControl: false
  });
  mapInfoWindow = new google.maps.InfoWindow();

  renderMapMarkers();
}

// ---- RENDER MARKERS (JS API mode) ----
function renderMapMarkers() {
  if (!gmap) return;

  const openIncidents = pinnableIncidents();
  const openIds = new Set(openIncidents.map(i => i.id));

  // remove markers for incidents that are resolved/cancelled or gone
  Object.keys(mapMarkers).forEach(id => {
    if (!openIds.has(id)) {
      mapMarkers[id].setMap(null);
      delete mapMarkers[id];
    }
  });

  // add/update markers for open incidents
  openIncidents.forEach(inc => {
    if (mapMarkers[inc.id]) return; // already placed
    const marker = new google.maps.Marker({
      position: { lat: inc.lat, lng: inc.lng },
      map: gmap,
      title: `${inc.title} — ${inc.id}`,
      icon: {
        path: google.maps.SymbolPath.CIRCLE,
        fillColor: severityPinColor(inc.severity),
        fillOpacity: 1,
        strokeColor: "#ffffff",
        strokeWeight: 2,
        scale: 9
      }
    });

    marker.addListener("click", () => {
      mapInfoWindow.setContent(`
        <div style="font-family:Inter,sans-serif;min-width:180px;">
          <strong style="font-size:13px;">${inc.title}</strong><br>
          <span style="font-size:11.5px;color:#7A7368;">${inc.location}</span><br>
          <span style="font-size:11px;color:#A79E92;">${inc.id} · ${inc.severity.toUpperCase()}</span>
        </div>
      `);
      mapInfoWindow.open(gmap, marker);
      goToReport(inc.id);
    });

    mapMarkers[inc.id] = marker;
  });
}

// ---- RENDER FALLBACK PIN LIST (no API key) ----
function renderFallbackPinList() {
  const list = document.getElementById("mapPinList");
  const openIncidents = pinnableIncidents();

  if (openIncidents.length === 0) {
    list.innerHTML = `<div class="map-pin-list-empty">No active reports with a pinned location right now.</div>`;
    return;
  }

  list.innerHTML = openIncidents.map(inc => `
    <div class="map-pin-item" data-pin-id="${inc.id}">
      <span class="map-pin-marker pin-${inc.severity}">${ICONS.loc}</span>
      <div class="map-pin-body">
        <strong>${inc.title}</strong>
        <span>${inc.location}</span>
      </div>
      <span class="map-pin-coords">${inc.lat.toFixed(4)}, ${inc.lng.toFixed(4)}</span>
    </div>
  `).join("");

  list.querySelectorAll("[data-pin-id]").forEach(el => {
    el.addEventListener("click", () => goToReport(el.dataset.pinId));
  });
}

function showFallbackPinList() {
  document.getElementById("mapKeyNotice").classList.add("hidden");
  document.getElementById("mapCanvas").style.display = "none";
  document.getElementById("mapPinList").style.display = "flex";
  renderFallbackPinList();
}

// ---- GO TO REPORT (pin click -> queue view, scrolled + highlighted) ----
function goToReport(id) {
  switchView("queue");
  document.querySelectorAll(".nav-item").forEach(n => n.classList.remove("active"));
  document.querySelector('.nav-item[data-view="queue"]').classList.add("active");

  // reset filters so the target incident is guaranteed to be visible
  state.filter = "all";
  state.search = "";
  state.district = "All Barangays";
  document.querySelectorAll(".tab").forEach(t => t.classList.remove("active"));
  document.querySelector('.tab[data-filter="all"]').classList.add("active");
  document.getElementById("searchInput").value = "";
  document.getElementById("districtLabel").textContent = "All Barangays";

  renderIncidents();

  requestAnimationFrame(() => {
    const card = document.querySelector(`[data-card-id="${id}"]`);
    if (card) {
      card.scrollIntoView({ behavior: "smooth", block: "center" });
      card.classList.add("card-flash");
      setTimeout(() => card.classList.remove("card-flash"), 1600);
    }
  });
}

// ---- MAP CONTROLS (barangay jump / recenter) ----
function setMapToSantaRosa() {
  document.getElementById("mapBarangayLabel").textContent = "All Barangays";
  document.querySelectorAll("#mapBarangayPanel .dropdown-option").forEach(o => {
    o.classList.toggle("selected", o.dataset.value === "All Barangays");
  });
  if (gmap) {
    gmap.setCenter(SANTA_ROSA_CENTER);
    gmap.setZoom(13);
  }
}

function setMapToBarangay(name) {
  if (name === "All Barangays") { setMapToSantaRosa(); return; }
  document.getElementById("mapBarangayLabel").textContent = name;
  const coords = BARANGAY_COORDS[name];
  if (gmap && coords) {
    gmap.setCenter(coords);
    gmap.setZoom(15);
  }
}

function setupMapView() {
  document.getElementById("recenterBtn").addEventListener("click", setMapToSantaRosa);

  setupDropdown("mapBarangayBtn", "mapBarangayPanel", {
    onSelect: (val) => setMapToBarangay(val)
  });

  document.getElementById("mapKeyBtn").addEventListener("click", () => {
    const key = document.getElementById("mapKeyInput").value.trim();
    if (!key) { showToast("Enter a Google Maps API key first."); return; }
    initGoogleMap(key);
  });

  document.getElementById("mapFallbackLink").addEventListener("click", (e) => {
    e.preventDefault();
    showFallbackPinList();
  });
}

// ============================================================
//  UNITS REGISTRY
// ============================================================

// SVG icons per unit type (inline, matches existing icon style)
const UNIT_ICONS = {
  "Barangay Tanod": `<svg viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="3.5" stroke="currentColor" stroke-width="1.6"/><path d="M5 20c0-3.5 3-6 7-6s7 2.5 7 6" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg>`,
  "Barangay Police": `<svg viewBox="0 0 24 24" fill="none"><path d="M12 3L4 7V12C4 16.4 7.4 20.5 12 21C16.6 20.5 20 16.4 20 12V7L12 3Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/></svg>`,
  "Ambulance": `<svg viewBox="0 0 24 24" fill="none"><rect x="2" y="8" width="16" height="10" rx="2" stroke="currentColor" stroke-width="1.6"/><path d="M18 11H21L22 14V18H18" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><circle cx="7" cy="19" r="2" stroke="currentColor" stroke-width="1.5"/><circle cx="17" cy="19" r="2" stroke="currentColor" stroke-width="1.5"/><path d="M8 12H12M10 10V14" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg>`,
  "Emergency Medical": `<svg viewBox="0 0 24 24" fill="none"><rect x="2" y="8" width="16" height="10" rx="2" stroke="currentColor" stroke-width="1.6"/><path d="M18 11H21L22 14V18H18" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><circle cx="7" cy="19" r="2" stroke="currentColor" stroke-width="1.5"/><circle cx="17" cy="19" r="2" stroke="currentColor" stroke-width="1.5"/><path d="M8 12H12M10 10V14" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg>`,
  "Fire & Rescue": `<svg viewBox="0 0 24 24" fill="none"><path d="M12 2C12 2 7 7 7 12.5C7 15.5 9.5 18 12 18C14.5 18 17 15.5 17 12.5C17 9 14 5 12 2Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><path d="M12 14C12 14 10 12.5 10 11C10 9.5 11 8 12 7C13 8.5 14 9.5 14 11C14 12.5 13 14 12 14Z" fill="currentColor"/></svg>`,
  "Police Response": `<svg viewBox="0 0 24 24" fill="none"><path d="M12 3L4 7V12C4 16.4 7.4 20.5 12 21C16.6 20.5 20 16.4 20 12V7L12 3Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><path d="M9 12L11 14L15 10" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>`,
  "Public Order & Safety": `<svg viewBox="0 0 24 24" fill="none"><path d="M4 17L9 12L13 15L20 7" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/><path d="M14 7H20V13" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>`,
  "Disaster Response": `<svg viewBox="0 0 24 24" fill="none"><path d="M12 2L2 7L12 12L22 7L12 2Z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><path d="M2 17L12 22L22 17" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><path d="M2 12L12 17L22 12" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/></svg>`,
  "Other": `<svg viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="1.6"/><path d="M12 8V12" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/><circle cx="12" cy="16" r="0.8" fill="currentColor"/></svg>`
};

function unitIconClass(type) {
  const map = {
    "Barangay Tanod": "unit-icon-tanod",
    "Barangay Police": "unit-icon-police",
    "Ambulance": "unit-icon-ems",
    "Emergency Medical": "unit-icon-ems",
    "Fire & Rescue": "unit-icon-fire",
    "Disaster Response": "unit-icon-disaster",
    "Public Order & Safety": "unit-icon-poso",
    "Police Response": "unit-icon-police"
  };
  return map[type] || "unit-icon-default";
}

// ---- UNITS DATA STORE ----
// Populated by dispatchers via the Units page (Add Unit) or by real
// operational data — starts empty, no seed/trial entries.
// plus placeholder barangay entries where actual count is unknown.
// New units added via the Add Unit modal are pushed here.
let unitsRegistry = [];

let unitsFilter = { scope: "all", barangay: "all" };
let unitModalMode = null; // "add" | "edit"
let unitEditId = null;
let unitDeleteId = null;
let unitFormScope = "barangay";
let _unitIdCounter = 1000;

function generateUnitId() {
  return "unit-" + (++_unitIdCounter);
}

// ---- STATUS LABEL / CLASS HELPERS ----
function unitStatusLabel(s) {
  return { available: "Available", deployed: "Deployed", unavailable: "Unavailable" }[s] || s;
}
function unitStatusClass(s) {
  return { available: "status-available", deployed: "status-deployed", unavailable: "status-unavailable" }[s] || "";
}

// ---- RENDER: SUMMARY BAR ----
function renderUnitsSummary() {
  const bar = document.getElementById("unitsSummaryBar");
  if (!bar) return;
  const total = unitsRegistry.length;
  const available = unitsRegistry.filter(u => u.status === "available").length;
  const deployed = unitsRegistry.filter(u => u.status === "deployed").length;
  const unavail = unitsRegistry.filter(u => u.status === "unavailable").length;
  bar.innerHTML = `
    <div class="units-stat-pill"><span class="pill-dot" style="background:#2B2420;"></span><span>Total</span><strong>${total}</strong></div>
    <div class="units-stat-pill"><span class="pill-dot pill-dot-available"></span><span>Available</span><strong>${available}</strong></div>
    <div class="units-stat-pill"><span class="pill-dot pill-dot-deployed"></span><span>Deployed</span><strong>${deployed}</strong></div>
    <div class="units-stat-pill"><span class="pill-dot pill-dot-unavailable"></span><span>Unavailable</span><strong>${unavail}</strong></div>
  `;
}

// ---- RENDER: UNIT CARD HTML ----
function unitCardHtml(u) {
  const iconSvg = UNIT_ICONS[u.type] || UNIT_ICONS["Other"];
  const iconCls = unitIconClass(u.type);
  const statusCls = unitStatusClass(u.status);
  const statusLbl = unitStatusLabel(u.status);
  const isUnknown = u.personnel === null;

  const plateRow = u.plate
    ? `<div class="unit-meta-row"><svg viewBox="0 0 24 24" fill="none"><rect x="2" y="7" width="20" height="10" rx="2" stroke="currentColor" stroke-width="1.5"/><path d="M7 12H17" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/></svg><span>Plate / ID: <strong>${u.plate}</strong></span></div>`
    : "";
  const personnelRow = isUnknown
    ? `<div class="unit-meta-row"><svg viewBox="0 0 24 24" fill="none"><circle cx="9" cy="8" r="3" stroke="currentColor" stroke-width="1.5"/><path d="M3 20c0-3.3 2.7-6 6-6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/><circle cx="17" cy="9" r="2.2" stroke="currentColor" stroke-width="1.4"/><path d="M15 14.5c2.5.2 4.5 2 4.5 4.8" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/></svg><span style="color:var(--text-light);font-style:italic;">Personnel count unknown</span></div>`
    : `<div class="unit-meta-row"><svg viewBox="0 0 24 24" fill="none"><circle cx="9" cy="8" r="3" stroke="currentColor" stroke-width="1.5"/><path d="M3 20c0-3.3 2.7-6 6-6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/><circle cx="17" cy="9" r="2.2" stroke="currentColor" stroke-width="1.4"/><path d="M15 14.5c2.5.2 4.5 2 4.5 4.8" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/></svg><span>Personnel: <strong>${u.personnel}</strong></span></div>`;
  const notesHtml = u.notes ? `<div class="unit-card-notes">${u.notes}</div>` : "";

  return `
  <div class="unit-card${isUnknown ? " unit-card-unknown" : ""}" data-unit-id="${u.id}">
    <div class="unit-card-top">
      <div class="unit-card-icon ${iconCls}">${iconSvg}</div>
      <div class="unit-card-name">${u.name}</div>
      <span class="unit-status-badge ${statusCls}">${statusLbl}</span>
    </div>
    <div class="unit-card-meta">
      <div class="unit-meta-row">
        <svg viewBox="0 0 24 24" fill="none"><path d="M7 7h4M7 12h8M7 17h5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/><rect x="3" y="3" width="18" height="18" rx="3" stroke="currentColor" stroke-width="1.5"/></svg>
        <span>Type: <strong>${u.type}</strong></span>
      </div>
      ${plateRow}
      ${personnelRow}
    </div>
    ${notesHtml}
    <div class="unit-card-actions">
      <button class="unit-action-btn btn-edit" data-unit-action="edit" data-unit-id="${u.id}">Edit</button>
      <button class="unit-action-btn btn-delete" data-unit-action="delete" data-unit-id="${u.id}">Remove</button>
    </div>
  </div>`;
}

// ---- RENDER: UNITS GRID (grouped by barangay/city) ----
function renderUnits() {
  renderUnitsSummary();
  renderDeploymentBoard();
  renderAvailabilityBreakdown();

  const grid = document.getElementById("unitsGrid");
  const empty = document.getElementById("unitsEmptyState");
  if (!grid) return;

  // Apply filters
  let list = unitsRegistry.slice();
  if (unitsFilter.scope !== "all") list = list.filter(u => u.scope === unitsFilter.scope);
  if (unitsFilter.barangay !== "all") {
    list = list.filter(u => {
      if (unitsFilter.barangay === "City-Wide") return u.barangay === "City-Wide";
      return u.barangay === unitsFilter.barangay;
    });
  }

  if (list.length === 0) {
    grid.innerHTML = "";
    empty.style.display = "block";
    return;
  }
  empty.style.display = "none";

  // Group by barangay, city-wide first
  const groups = {};
  list.forEach(u => {
    const key = u.barangay || "Unassigned";
    (groups[key] = groups[key] || []).push(u);
  });

  // Sort: City-Wide first, then alphabetical
  const sortedKeys = Object.keys(groups).sort((a, b) => {
    if (a === "City-Wide") return -1;
    if (b === "City-Wide") return 1;
    return a.localeCompare(b);
  });

  grid.innerHTML = sortedKeys.map(key => {
    const units = groups[key];
    const isCity = key === "City-Wide";
    const badgeCls = isCity ? "scope-city-badge" : "scope-barangay-badge";
    const badgeLbl = isCity ? "City-Wide" : "Barangay";
    const avail = units.filter(u => u.status === "available").length;
    const countNote = `${avail} available · ${units.length} total`;

    const cards = units.map(unitCardHtml).join("");
    return `
    <div class="units-section-header">
      <h2>${key} <span class="units-section-scope ${badgeCls}">${badgeLbl}</span></h2>
      <span class="units-section-count">${countNote}</span>
    </div>
    <div class="units-cards">${cards}</div>`;
  }).join("");

  attachUnitCardListeners();
}

// ---- CARD ACTION LISTENERS (edit / delete) ----
function attachUnitCardListeners() {
  const grid = document.getElementById("unitsGrid");
  if (!grid || grid._unitListenerBound) return;
  grid._unitListenerBound = true;

  grid.addEventListener("click", e => {
    const btn = e.target.closest("[data-unit-action]");
    if (!btn) return;
    const id = btn.dataset.unitId;
    if (btn.dataset.unitAction === "edit") openUnitModal("edit", id);
    if (btn.dataset.unitAction === "delete") openDeleteUnitModal(id);
  });
}

// ---- ADD / EDIT MODAL ----
function openUnitModal(mode, id) {
  unitModalMode = mode;
  unitEditId = id || null;

  const modal = document.getElementById("unitModal");
  const title = document.getElementById("unitModalTitle");

  if (mode === "edit" && id) {
    const u = unitsRegistry.find(x => x.id === id);
    if (!u) return;
    title.textContent = "Edit Unit";
    document.getElementById("unitFormName").value = u.name;
    document.getElementById("unitFormType").value = u.type;
    document.getElementById("unitFormPlate").value = u.plate || "";
    document.getElementById("unitFormPersonnel").value = u.personnel !== null ? u.personnel : "";
    document.getElementById("unitFormStatus").value = u.status;
    document.getElementById("unitFormNotes").value = u.notes || "";
    document.getElementById("unitFormBarangay").value = u.barangay === "City-Wide" ? "" : u.barangay;
    setUnitFormScope(u.scope);
  } else {
    title.textContent = "Add Unit";
    document.getElementById("unitFormName").value = "";
    document.getElementById("unitFormType").value = "";
    document.getElementById("unitFormPlate").value = "";
    document.getElementById("unitFormPersonnel").value = "";
    document.getElementById("unitFormStatus").value = "available";
    document.getElementById("unitFormNotes").value = "";
    document.getElementById("unitFormBarangay").value = "";
    setUnitFormScope("barangay");
  }

  modal.classList.add("show");
}

function closeUnitModal() {
  document.getElementById("unitModal").classList.remove("show");
  unitModalMode = null;
  unitEditId = null;
}

function setUnitFormScope(scope) {
  unitFormScope = scope;
  document.querySelectorAll("#unitFormScopeToggle .scope-btn").forEach(b => {
    b.classList.toggle("active", b.dataset.scope === scope);
  });
  const wrap = document.getElementById("unitFormBarangayWrap");
  wrap.style.display = scope === "barangay" ? "block" : "none";
}

function saveUnit() {
  const name = document.getElementById("unitFormName").value.trim();
  const type = document.getElementById("unitFormType").value;
  const plate = document.getElementById("unitFormPlate").value.trim() || null;
  const personnelRaw = document.getElementById("unitFormPersonnel").value.trim();
  const personnel = personnelRaw === "" ? null : parseInt(personnelRaw, 10);
  const status = document.getElementById("unitFormStatus").value;
  const notes = document.getElementById("unitFormNotes").value.trim();
  const barangayField = document.getElementById("unitFormBarangay").value;
  const barangay = unitFormScope === "city" ? "City-Wide" : barangayField;

  if (!name) { showToast("Enter a unit name."); return; }
  if (!type) { showToast("Select a unit type."); return; }
  if (unitFormScope === "barangay" && !barangay) { showToast("Select an assigned barangay."); return; }

  if (unitModalMode === "edit" && unitEditId) {
    const u = unitsRegistry.find(x => x.id === unitEditId);
    if (u) {
      u.name = name; u.type = type; u.scope = unitFormScope;
      u.barangay = barangay; u.plate = plate; u.personnel = personnel;
      u.status = status; u.notes = notes;
    }
    showToast(`"${name}" updated.`);
  } else {
    unitsRegistry.push({ id: generateUnitId(), name, type, scope: unitFormScope, barangay, plate, personnel, status, notes });
    showToast(`"${name}" added to the registry.`);
  }

  closeUnitModal();
  // Re-bind listener since grid innerHTML is replaced
  const grid = document.getElementById("unitsGrid");
  if (grid) grid._unitListenerBound = false;
  renderUnits();
}

// ---- DELETE MODAL ----
function openDeleteUnitModal(id) {
  unitDeleteId = id;
  const u = unitsRegistry.find(x => x.id === id);
  if (!u) return;
  document.getElementById("deleteUnitMessage").textContent =
    `Remove "${u.name}" from the registry? This cannot be undone.`;
  document.getElementById("deleteUnitModal").classList.add("show");
}

function closeDeleteUnitModal() {
  document.getElementById("deleteUnitModal").classList.remove("show");
  unitDeleteId = null;
}

function confirmDeleteUnit() {
  if (!unitDeleteId) return;
  const idx = unitsRegistry.findIndex(x => x.id === unitDeleteId);
  const name = idx >= 0 ? unitsRegistry[idx].name : "Unit";
  if (idx >= 0) unitsRegistry.splice(idx, 1);
  showToast(`"${name}" removed.`);
  closeDeleteUnitModal();
  const grid = document.getElementById("unitsGrid");
  if (grid) grid._unitListenerBound = false;
  renderUnits();
}

// ---- RENDER: DEPLOYMENT BOARD (right panel) ----
function renderDeploymentBoard() {
  const list = document.getElementById("deploymentList");
  const empty = document.getElementById("deployBoardEmpty");
  const countEl = document.getElementById("deployBoardCount");
  if (!list) return;

  // Find all units marked as deployed, cross-reference with active incidents
  const deployedUnits = unitsRegistry.filter(u => u.status === "deployed");

  if (deployedUnits.length === 0) {
    list.innerHTML = "";
    empty.style.display = "flex";
    countEl.textContent = "0 deployed";
    countEl.className = "deploy-board-count none";
    return;
  }

  empty.style.display = "none";
  countEl.textContent = `${deployedUnits.length} deployed`;
  countEl.className = "deploy-board-count";

  list.innerHTML = deployedUnits.map(u => {
    // Try to find matching incident by unit name
    const matchedInc = incidents.find(i =>
      i.unit && i.unit.toLowerCase().includes(u.name.toLowerCase().split(" - ")[0]) &&
      i.status === "dispatched"
    ) || incidents.find(i => i.status === "dispatched"); // fallback: any dispatched incident

    const incidentBlock = matchedInc
      ? `<div class="deploy-entry-incident">
           <svg viewBox="0 0 24 24" fill="none"><path d="M12 21C12 21 19 14.5 19 9.5C19 5.5 16 2 12 2C8 2 5 5.5 5 9.5C5 14.5 12 21 12 21Z" stroke="currentColor" stroke-width="1.5"/><circle cx="12" cy="9.5" r="2.2" stroke="currentColor" stroke-width="1.4"/></svg>
           <span><strong>${matchedInc.title}</strong> — ${matchedInc.location}</span>
         </div>
         <div class="deploy-entry-meta">
           <span class="deploy-meta-chip chip-${matchedInc.dispatchScope || 'barangay'}">${matchedInc.dispatchScope === 'city' ? 'City-Wide' : 'Barangay'}</span>
           <span class="deploy-meta-chip" style="background:#FDF1E3;color:var(--orange-dark);">ID: ${matchedInc.id}</span>
           <button class="deploy-entry-goto" data-goto-id="${matchedInc.id}">View report →</button>
         </div>`
      : `<div class="deploy-entry-incident">
           <svg viewBox="0 0 24 24" fill="none"><path d="M12 21C12 21 19 14.5 19 9.5C19 5.5 16 2 12 2C8 2 5 5.5 5 9.5C5 14.5 12 21 12 21Z" stroke="currentColor" stroke-width="1.5"/><circle cx="12" cy="9.5" r="2.2" stroke="currentColor" stroke-width="1.4"/></svg>
           <span style="color:var(--text-light);font-style:italic;">Deployed — incident details not linked yet</span>
         </div>`;

    return `
    <div class="deploy-entry">
      <div class="deploy-entry-top">
        <span class="deploy-entry-name">${u.name}</span>
        <span class="deploy-live-dot" title="Currently deployed"></span>
      </div>
      ${incidentBlock}
    </div>`;
  }).join("");

  // Wire "View report" buttons
  list.querySelectorAll("[data-goto-id]").forEach(btn => {
    btn.addEventListener("click", () => {
      goToReport(btn.dataset.gotoId);
      // Switch nav to queue view
      document.querySelectorAll(".nav-item").forEach(n => n.classList.remove("active"));
      document.querySelector('.nav-item[data-view="queue"]').classList.add("active");
    });
  });
}

// ---- RENDER: AVAILABILITY BREAKDOWN (right panel) ----
function renderAvailabilityBreakdown() {
  const el = document.getElementById("availabilityBreakdown");
  if (!el) return;

  const total = unitsRegistry.length || 1;
  const avail = unitsRegistry.filter(u => u.status === "available").length;
  const deployed = unitsRegistry.filter(u => u.status === "deployed").length;
  const unavail = unitsRegistry.filter(u => u.status === "unavailable").length;

  const row = (label, count, barClass) => {
    const pct = Math.round((count / total) * 100);
    return `
    <div class="avail-row">
      <span class="avail-label">${label}</span>
      <div class="avail-bar-wrap"><div class="avail-bar ${barClass}" style="width:${pct}%"></div></div>
      <span class="avail-count">${count}</span>
    </div>`;
  };

  el.innerHTML =
    row("Available", avail, "") +
    row("Deployed", deployed, "bar-deployed") +
    row("Unavailable", unavail, "bar-unavail");
}

// ---- UNITS FILTER DROPDOWNS ----
function setupUnitsView() {
  document.getElementById("addUnitBtn").addEventListener("click", () => openUnitModal("add"));

  // Scope toggle inside the Add/Edit form
  document.querySelectorAll("#unitFormScopeToggle .scope-btn").forEach(btn => {
    btn.addEventListener("click", () => setUnitFormScope(btn.dataset.scope));
  });

  document.getElementById("unitModalClose").addEventListener("click", closeUnitModal);
  document.getElementById("unitModalCancel").addEventListener("click", closeUnitModal);
  document.getElementById("unitModalSave").addEventListener("click", saveUnit);
  document.getElementById("unitModal").addEventListener("click", e => {
    if (e.target.id === "unitModal") closeUnitModal();
  });

  document.getElementById("deleteUnitClose").addEventListener("click", closeDeleteUnitModal);
  document.getElementById("deleteUnitCancel").addEventListener("click", closeDeleteUnitModal);
  document.getElementById("deleteUnitConfirm").addEventListener("click", confirmDeleteUnit);
  document.getElementById("deleteUnitModal").addEventListener("click", e => {
    if (e.target.id === "deleteUnitModal") closeDeleteUnitModal();
  });

  setupDropdown("unitsScopeBtn", "unitsScopePanel", {
    onSelect: val => {
      unitsFilter.scope = val;
      document.getElementById("unitsScopeLabel").textContent =
        { all: "All Scopes", barangay: "Barangay", city: "City-Wide" }[val];
      renderUnits();
    }
  });

  setupDropdown("unitsBarangayBtn", "unitsBarangayPanel", {
    onSelect: val => {
      unitsFilter.barangay = val;
      document.getElementById("unitsBarangayLabel").textContent =
        val === "all" ? "All Barangays" : val;
      renderUnits();
    }
  });
}

// =========================================================
// ---- REGISTERED USERS (mobile app account holders) ----
// =========================================================
// Each entry is a resident who has an account on the mobile app.
// "reportCount" is NOT stored here — it's always computed live from
// the `incidents` list (matched by phone) so it stays accurate as
// new reports come in from Firestore.
let usersRegistry = [];

let usersFilter = { barangay: "all" };

// Count how many reports (in the current incidents list) came from this user.
// Matched by phone number (digits only, so "0917 123 4567" and "09171234567"
// still match) since that's the more reliable unique identifier.
function normalizePhone(phone) {
  return (phone || "").replace(/\D/g, "");
}
function countUserReports(phone) {
  const target = normalizePhone(phone);
  if (!target) return 0;
  return incidents.filter(i => normalizePhone(i.phone) === target).length;
}

function userInitials(name) {
  const parts = name.trim().split(/\s+/);
  const first = parts[0] ? parts[0][0] : "";
  const last = parts.length > 1 ? parts[parts.length - 1][0] : "";
  return (first + last).toUpperCase();
}

// ---- RENDER: USERS SUMMARY BAR ----
function renderUsersSummary() {
  const bar = document.getElementById("usersSummaryBar");
  if (!bar) return;
  const totalUsers = usersRegistry.length;
  const totalReports = usersRegistry.reduce((sum, u) => sum + countUserReports(u.phone), 0);
  const activeReporters = usersRegistry.filter(u => countUserReports(u.phone) > 0).length;
  bar.innerHTML = `
    <div class="units-stat-pill"><span class="pill-dot" style="background:#2B2420;"></span><span>Registered Users</span><strong>${totalUsers}</strong></div>
    <div class="units-stat-pill"><span class="pill-dot pill-dot-available"></span><span>Have Filed Reports</span><strong>${activeReporters}</strong></div>
    <div class="units-stat-pill"><span class="pill-dot pill-dot-deployed"></span><span>Total Reports Filed</span><strong>${totalReports}</strong></div>
  `;
}

// ---- RENDER: USER CARD HTML ----
function userCardHtml(u) {
  const count = countUserReports(u.phone);
  const reportLabel = count === 1 ? "1 report filed" : `${count} reports filed`;
  const reportCls = count > 0 ? "status-available" : "status-unavailable";

  return `
  <div class="unit-card" data-user-id="${u.id}">
    <div class="unit-card-top">
      <div class="unit-card-icon unit-icon-default" style="border-radius:50%;">${userInitials(u.name)}</div>
      <div class="unit-card-name">${u.name}</div>
      <span class="unit-status-badge ${reportCls}">${reportLabel}</span>
    </div>
    <div class="unit-card-meta">
      <div class="unit-meta-row">
        <svg viewBox="0 0 24 24" fill="none"><path d="M4 5H20V17H8L4 21V5Z" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/></svg>
        <span>Phone: <strong>${u.phone}</strong></span>
      </div>
      <div class="unit-meta-row">
        <svg viewBox="0 0 24 24" fill="none"><path d="M12 2L2 8.5V21H9V14H15V21H22V8.5L12 2Z" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/></svg>
        <span>Barangay: <strong>${u.barangay}</strong></span>
      </div>
      <div class="unit-meta-row">
        <svg viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="1.5"/><path d="M12 7V12L15.5 14" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg>
        <span>Joined: <strong>${u.joined}</strong></span>
      </div>
      ${u.emergencyContactName ? `
      <div class="unit-meta-row">
        <svg viewBox="0 0 24 24" fill="none"><path d="M4 5H20V17H8L4 21V5Z" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/></svg>
        <span>Emergency Contact: <strong>${u.emergencyContactName}${u.emergencyContactNumber ? " (" + u.emergencyContactNumber + ")" : ""}</strong></span>
      </div>` : ""}
    </div>
  </div>`;
}

// ---- RENDER: USERS GRID (grouped by barangay) ----
function renderUsers() {
  renderUsersSummary();

  const grid = document.getElementById("usersGrid");
  const empty = document.getElementById("usersEmptyState");
  if (!grid) return;

  const searchInput = document.getElementById("usersSearchInput");
  const q = searchInput ? searchInput.value.trim().toLowerCase() : "";

  let list = usersRegistry.slice();
  if (usersFilter.barangay !== "all") list = list.filter(u => u.barangay === usersFilter.barangay);
  if (q) list = list.filter(u => u.name.toLowerCase().includes(q) || u.phone.includes(q));

  if (list.length === 0) {
    grid.innerHTML = "";
    empty.style.display = "block";
    return;
  }
  empty.style.display = "none";

  const groups = {};
  list.forEach(u => {
    const key = u.barangay || "Unassigned";
    (groups[key] = groups[key] || []).push(u);
  });

  const sortedKeys = Object.keys(groups).sort((a, b) => a.localeCompare(b));

  grid.innerHTML = sortedKeys.map(key => {
    const usersInGroup = groups[key];
    const cards = usersInGroup.map(userCardHtml).join("");
    return `
    <div class="units-section-header">
      <h2>${key} <span class="units-section-scope scope-barangay-badge">Barangay</span></h2>
      <span class="units-section-count">${usersInGroup.length} registered</span>
    </div>
    <div class="units-cards">${cards}</div>`;
  }).join("");
}

// ---- USERS VIEW SETUP ----
function setupUsersView() {
  const search = document.getElementById("usersSearchInput");
  if (search) search.addEventListener("input", renderUsers);

  setupDropdown("usersBarangayBtn", "usersBarangayPanel", {
    onSelect: val => {
      usersFilter.barangay = val;
      document.getElementById("usersBarangayLabel").textContent =
        val === "all" ? "All Barangays" : val;
      renderUsers();
    }
  });
}

// ---- VIEW SWITCHING ----
function switchView(view) {
  const queueView = document.getElementById("queueView");
  const mapView = document.getElementById("mapView");
  const historyView = document.getElementById("historyView");
  const analyticsView = document.getElementById("analyticsView");
  const unitsView = document.getElementById("unitsView");
  const usersView = document.getElementById("usersView");

  queueView.style.display = "none";
  mapView.style.display = "none";
  historyView.style.display = "none";
  analyticsView.style.display = "none";
  unitsView.style.display = "none";
  usersView.style.display = "none";

  if (view === "map") {
    mapView.style.display = "flex";
    if (gmap) {
      renderMapMarkers();
      setMapToSantaRosa();
    } else if (document.getElementById("mapPinList").style.display === "flex") {
      renderFallbackPinList();
    }
  } else if (view === "history") {
    historyView.style.display = "flex";
    renderHistory();
  } else if (view === "analytics") {
    analyticsView.style.display = "flex";
    renderAnalytics();
  } else if (view === "units") {
    unitsView.style.display = "flex";
    renderUnits();
  } else if (view === "users") {
    usersView.style.display = "flex";
    renderUsers();
  } else {
    queueView.style.display = "flex";
  }
}

// ---- SIDEBAR NAV ----
function setupNav() {
  document.querySelectorAll(".nav-item").forEach(item => {
    item.addEventListener("click", (e) => {
      e.preventDefault();
      document.querySelectorAll(".nav-item").forEach(n => n.classList.remove("active"));
      item.classList.add("active");
      const view = item.dataset.view;

      if (view === "queue" || view === "map" || view === "history" || view === "analytics" || view === "units" || view === "users") {
        switchView(view);
      } else {
        switchView("queue");
        document.querySelector('.nav-item[data-view="queue"]').classList.add("active");
        item.classList.remove("active");
        showToast(`${item.textContent.trim()} view is not part of this build yet.`);
      }
    });
  });
}

// ---- EMERGENCY DISPATCH BUTTON ----
function setupEmergencyButton() {
  document.getElementById("emergencyBtn").addEventListener("click", () => {
    showToast("Connecting to Full Department Base Line...");
  });
}

// ---- VIEW ALL ACTIVITY ----
function setupViewAllActivity() {
  document.getElementById("viewAllActivity").addEventListener("click", (e) => {
    e.preventDefault();
    showToast("Full activity log is not part of this build yet.");
  });
}

// ---- INIT ----
// ---- LIVE FIREBASE SYNC HOOK ----
// firebase.js calls window.instaRosaOnLiveIncidents(list) every time
// the Firestore listener fires (initial load + every subsequent change).
function applyLiveIncidents(liveIncidents) {
  incidents = liveIncidents;
  document.getElementById("firebaseStatus").classList.remove("show");
  document.getElementById("firebaseStatus").classList.add("connected");
  document.getElementById("firebaseStatus").textContent =
    `Connected to Firebase — showing ${liveIncidents.length} live report${liveIncidents.length === 1 ? "" : "s"}.`;
  document.getElementById("firebaseStatus").classList.add("show");
  renderAll();
}
window.instaRosaOnLiveIncidents = applyLiveIncidents;

// Fires with the full, current list of registered users every time the
// "users" collection changes (initial load + every account create/update).
function applyLiveUsers(liveUsers) {
  usersRegistry = liveUsers;
  renderUsers();
}

function initFirebaseSync() {
  // firebase.js is a module script and may not have attached
  // window.instaRosaFirebase yet by the time app.js runs — poll briefly.
  let attempts = 0;
  const tryStart = () => {
    attempts++;
    if (window.instaRosaFirebase) {
      if (window.instaRosaFirebase.isConfigured) {
        window.instaRosaFirebase.start(applyLiveIncidents);
        window.instaRosaFirebase.startUsers(applyLiveUsers);
      } else {
        const el = document.getElementById("firebaseStatus");
        el.textContent = "Firebase not configured yet — showing demo data. Add your project keys in firebase.js.";
        el.classList.add("show");
      }
    } else if (attempts < 40) {
      setTimeout(tryStart, 125);
    }
  };
  tryStart();
}

// =========================================================
// ---- DISPATCH OPERATOR AUTH (Log In / Register) ----
// =========================================================
// Client-side only for now: operator accounts + session live in
// localStorage. NOTE: this is fine for getting the flow working, but
// storing passwords in localStorage is NOT secure for a real deployment —
// swap this for Firebase Authentication (or another real auth backend)
// before this goes live with real dispatch operators.
const OPERATORS_KEY = "instarosa_operators";
const SESSION_KEY = "instarosa_session";
let registerPhotoDataUrl = null;

function loadOperators() {
  try { return JSON.parse(localStorage.getItem(OPERATORS_KEY)) || []; }
  catch { return []; }
}
function saveOperators(list) {
  localStorage.setItem(OPERATORS_KEY, JSON.stringify(list));
}
function getSession() {
  try { return JSON.parse(localStorage.getItem(SESSION_KEY)); }
  catch { return null; }
}
function setSession(operatorId) {
  localStorage.setItem(SESSION_KEY, JSON.stringify({ operatorId }));
}
function clearSession() {
  localStorage.removeItem(SESSION_KEY);
}

function operatorInitials(name) {
  const parts = name.trim().split(/\s+/);
  const first = parts[0] ? parts[0][0] : "";
  const last = parts.length > 1 ? parts[parts.length - 1][0] : "";
  return (first + last).toUpperCase();
}

function currentOperator() {
  const session = getSession();
  if (!session) return null;
  return loadOperators().find(o => o.id === session.operatorId) || null;
}

function registerOperator(name, email, password, photo) {
  const operators = loadOperators();
  const emailLower = email.trim().toLowerCase();
  if (operators.some(o => o.email === emailLower)) {
    return { ok: false, message: "An account with this email already exists." };
  }
  const operator = { id: "op-" + Date.now(), name: name.trim(), email: emailLower, password, photo: photo || null };
  operators.push(operator);
  saveOperators(operators);
  setSession(operator.id);
  return { ok: true };
}

function loginOperator(email, password) {
  const operators = loadOperators();
  const emailLower = email.trim().toLowerCase();
  const operator = operators.find(o => o.email === emailLower && o.password === password);
  if (!operator) return { ok: false, message: "Incorrect email or password." };
  setSession(operator.id);
  return { ok: true };
}

function logoutOperator() {
  clearSession();
  showAuthScreen();
}

// ---- RENDER: TOPBAR USER CHIP ----
function renderOperatorChip() {
  const op = currentOperator();
  const avatarEl = document.getElementById("userAvatar");
  const nameEl = document.getElementById("userNameDisplay");
  if (!op || !avatarEl || !nameEl) return;
  nameEl.textContent = op.name;
  avatarEl.innerHTML = op.photo
    ? `<img src="${op.photo}" alt="${op.name}">`
    : operatorInitials(op.name);
}

function showApp() {
  document.getElementById("authScreen").style.display = "none";
  document.getElementById("appRoot").style.display = "flex";
  renderOperatorChip();
}

function showAuthScreen() {
  document.getElementById("appRoot").style.display = "none";
  document.getElementById("authScreen").style.display = "flex";
  const loginForm = document.getElementById("loginForm");
  const registerForm = document.getElementById("registerForm");
  if (loginForm) loginForm.reset();
  if (registerForm) registerForm.reset();
  document.getElementById("loginError").textContent = "";
  document.getElementById("registerError").textContent = "";
  document.getElementById("registerPhotoPreview").innerHTML =
    `<svg viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="3.2" stroke="currentColor" stroke-width="1.6"/><path d="M6 20C6 16.5 8.5 14 12 14C15.5 14 18 16.5 18 20" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg>`;
  registerPhotoDataUrl = null;
}

// ---- AUTH SCREEN SETUP ----
function setupAuthScreen() {
  const tabs = document.querySelectorAll(".auth-tab, .auth-link");
  const loginForm = document.getElementById("loginForm");
  const registerForm = document.getElementById("registerForm");

  function switchTab(target) {
    document.querySelectorAll(".auth-tab").forEach(t => t.classList.toggle("active", t.dataset.tab === target));
    loginForm.style.display = target === "login" ? "flex" : "none";
    registerForm.style.display = target === "register" ? "flex" : "none";
  }

  tabs.forEach(el => {
    el.addEventListener("click", () => switchTab(el.dataset.tab));
  });

  const photoBtn = document.getElementById("registerPhotoBtn");
  const photoInput = document.getElementById("registerPhotoInput");
  const photoPreview = document.getElementById("registerPhotoPreview");

  photoBtn.addEventListener("click", () => photoInput.click());
  photoInput.addEventListener("change", () => {
    const file = photoInput.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => {
      registerPhotoDataUrl = reader.result;
      photoPreview.innerHTML = `<img src="${reader.result}" alt="Preview">`;
    };
    reader.readAsDataURL(file);
  });

  loginForm.addEventListener("submit", (e) => {
    e.preventDefault();
    const email = document.getElementById("loginEmail").value;
    const password = document.getElementById("loginPassword").value;
    const errorEl = document.getElementById("loginError");
    const result = loginOperator(email, password);
    if (!result.ok) { errorEl.textContent = result.message; return; }
    errorEl.textContent = "";
    showApp();
  });

  registerForm.addEventListener("submit", (e) => {
    e.preventDefault();
    const name = document.getElementById("registerName").value;
    const email = document.getElementById("registerEmail").value;
    const password = document.getElementById("registerPassword").value;
    const confirmPassword = document.getElementById("registerConfirmPassword").value;
    const errorEl = document.getElementById("registerError");

    if (!name.trim()) { errorEl.textContent = "Enter your full name."; return; }
    if (password.length < 6) { errorEl.textContent = "Password must be at least 6 characters."; return; }
    if (password !== confirmPassword) { errorEl.textContent = "Passwords do not match."; return; }

    const result = registerOperator(name, email, password, registerPhotoDataUrl);
    if (!result.ok) { errorEl.textContent = result.message; return; }
    errorEl.textContent = "";
    showApp();
  });

  const logOutBtn = document.getElementById("logOutBtn");
  if (logOutBtn) logOutBtn.addEventListener("click", logoutOperator);
}

document.addEventListener("DOMContentLoaded", () => {
  setupAuthScreen();
  if (currentOperator()) {
    showApp();
  } else {
    showAuthScreen();
  }

  renderAll();
  setupTabs();
  setupHistoryTabs();
  setupSearch();
  setupNav();
  setupMapView();
  setupUnitsView();
  setupUsersView();
  setupEmergencyButton();
  setupViewAllActivity();
  initFirebaseSync();

  setupDropdown("districtBtn", "districtPanel", {
    onSelect: (val) => {
      state.district = val;
      document.getElementById("districtLabel").textContent = val;
      renderIncidents();
    }
  });

  setupDropdown("sortBtn", "sortPanel", {
    onSelect: (val) => {
      state.sort = val;
      const labels = { newest: "Newest First", oldest: "Oldest First", severity: "Severity (High First)" };
      document.getElementById("sortLabel").textContent = labels[val];
      renderIncidents();
    }
  });

  setupDropdown("notifBtn", "notifPanel");
  setupDropdown("msgBtn", "msgPanel");
  setupDropdown("userChip", "userPanel");

  document.addEventListener("click", closeAllDropdowns);

  // modal wiring
  document.querySelectorAll(".scope-btn").forEach(btn => {
    btn.addEventListener("click", () => setDispatchScope(btn.dataset.scope));
  });

  document.getElementById("dispatchClose").addEventListener("click", closeDispatchModal);
  document.getElementById("dispatchCancel").addEventListener("click", closeDispatchModal);
  document.getElementById("dispatchConfirm").addEventListener("click", confirmDispatch);
  document.getElementById("dispatchModal").addEventListener("click", (e) => {
    if (e.target.id === "dispatchModal") closeDispatchModal();
  });

  document.getElementById("confirmClose").addEventListener("click", closeConfirmModal);
  document.getElementById("confirmCancel").addEventListener("click", closeConfirmModal);
  document.getElementById("confirmOk").addEventListener("click", runConfirmedAction);
  document.getElementById("confirmModal").addEventListener("click", (e) => {
    if (e.target.id === "confirmModal") closeConfirmModal();
  });
});