# instaROSA Dispatch Command — User Guide

A guide for barangay and city staff using the Dispatch Command dashboard to
receive, respond to, and track reports submitted through the instaROSA app.

---

## Signing In

1. Go to the dashboard login page.
2. Enter your email and password, then select **Log In**.

**Don't have an account yet?**
1. Select **Register**.
2. Add a profile photo (optional).
3. Fill in your full name, email, and a password (at least 6 characters).
4. Confirm your password and select **Create Account**.

You can switch between the Log In and Register tabs at any time using the
links at the bottom of the form.

---

## Getting Around

The dashboard is organized into six sections, accessible from the sidebar on
the left:

| Section | What it's for |
|---|---|
| **Live Incident Queue** | See and respond to new reports as they come in |
| **Map View** | See where active reports are located on a map |
| **History** | Look back at past reports — resolved, cancelled, or still open |
| **Analytics** | Trends, hotspots, and prevention recommendations |
| **Units** | Manage response units and see who's deployed |
| **Users** | Look up registered app users and their report activity |

At the top of the screen, you'll also find:
- A **search bar** to quickly find an incident by location or report ID.
- A **notification bell** 🔔 for new activity.
- A **messages icon** ✉️ for new messages.
- Your **profile menu** (top right) — showing your name and role, with a
  **Log Out** option.

A red **Emergency Dispatch** button is always available at the bottom of the
sidebar for reaching the full department base line.

---

## Live Incident Queue

This is your main workspace — a real-time list of every report coming in
from the community, organized as cards.

### Reading an incident card

Each card shows:
- **Category tag** — Distress (emergency) or Community (non-emergency)
- **How long ago** it was reported
- **Title** — the type of incident
- **Location**
- **Reporter's name and phone number**
- **Report ID**
- **Assigned unit** (once dispatched)
- **Severity** — High, Medium, Low, or Info
- **Status** — Pending, Dispatched, Resolved, or Cancelled

High-severity reports that are still pending are visually highlighted so
they stand out.

### Filtering and sorting

- Use the **All / High Priority / Active** tabs to narrow the list.
- Filter by **barangay** using the dropdown at the top.
- **Sort** by Newest First, Oldest First, or Severity (High First).
- Use the **search bar** to find a specific incident by location or report ID.

### Responding to a report

What you can do depends on the type of report:

**Distress (emergency) reports:**
- **Dispatch Unit** — opens a form to assign a responding unit.
- **Resolve** — mark the report as handled.

**Community reports:**
- **Resolve** — mark the report as addressed.
- **Dismiss** — close the report without further action.

#### Dispatching a unit

1. Select **Dispatch Unit** on an incident card.
2. Choose the **response scope** — Barangay Assistance or City-Wide
   Assistance. (High-severity emergencies default to City-Wide, but you can
   change this.)
3. Pick an **available unit** from the list.
4. Optionally add a **dispatch note** — for example, a warning about a
   blocked road.
5. Select **Confirm Dispatch**.

The incident's status updates to "Dispatched," the assigned unit is shown on
the card, and that unit is marked as deployed in the Units section.

#### Resolving or dismissing a report

1. Select **Resolve** or **Dismiss** on the incident card.
2. Confirm the action in the popup that appears.

Once resolved or dismissed, the report moves out of the Live Incident Queue
and into **History**. If a unit was assigned, it automatically becomes
available again.

---

## Map View

See all active reports plotted on a map of Santa Rosa.

- Filter by **barangay** using the dropdown.
- Select **Recenter to Santa Rosa** to reset the map view.
- Click any pin to jump to that report in the Live Incident Queue.
- If a map key hasn't been set up yet, you can view the same reports as a
  simple list instead.

Resolved or cancelled reports are automatically removed from the map.

---

## History

A record of every report that's no longer active.

Filter using the tabs at the top:
- **All**
- **Unresolved** — still pending or dispatched
- **Resolved**
- **Cancelled**

Each entry shows the same details as an incident card, so you can review
what happened and who responded.

---

## Analytics

A summary of incident trends and an automatically generated set of
recommendations based on current report data — useful for spotting patterns
and planning ahead, separate from day-to-day dispatch work.

### What you'll find here

- **Incident Summary** — total, high priority, active, resolved, and
  cancelled counts.
- **Severity Breakdown** — a chart showing the split between High, Medium,
  Low, and Info reports.
- **Recent Activity** — a running log of dispatch actions.
- **Predicted Impact** — for reports likely to affect traffic, an estimate of
  how long disruption may last.
- **Root Cause & Vulnerability Breakdown** — likely causes behind each type
  of incident.
- **Spatio-Temporal Hotspots** — which barangays are seeing the most (and
  most severe) reports.
- **Escalation & Hazard Warnings** — flags repeat low-severity issues (like
  the same complaint happening again and again in one area) that could
  escalate if left unaddressed.
- **Actionable Prevention Roadmap** — suggested next steps grouped into
  Immediate (0–24 hours), Medium-Term (1–4 weeks), and Long-Term actions.
- **Priority Action Matrix** — a full table pairing each incident pattern
  with its root cause, recommended action, responsible party, and expected
  impact.

This tab updates automatically as new reports come in — no manual setup
needed.

---

## Units

Manage the response units (barangay tanod, police, ambulance, fire, and
more) available for dispatch.

### Viewing units

- Units are grouped by barangay (with City-Wide units listed first).
- Filter by **scope** (Barangay or City-Wide) or by **specific barangay**.
- A summary bar shows how many units are Total, Available, Deployed, and
  Unavailable.

### Adding a unit

1. Select **+ Add Unit**.
2. Fill in:
   - **Unit Name** (required)
   - **Unit Type** (required) — e.g. Barangay Tanod, Ambulance, Fire & Rescue
   - **Scope** (required) — Barangay or City-Wide
   - **Assigned Barangay** (required if scope is Barangay)
   - **Plate Number / Unit ID** (optional)
   - **Personnel Count** (optional)
   - **Status** — Available, Deployed, or Unavailable/Off-duty
   - **Notes** (optional)
3. Select **Save Unit**.

### Editing or removing a unit

- Select **Edit** on a unit's card to update its details.
- Select **Remove** to delete it, then confirm.

### Deployment Board

On the right side of the Units page, the **Deployment Board** shows every
unit currently assigned to an active incident in real time, so you can see
at a glance who's out and where.

The **Availability Overview** below it gives a quick breakdown of how many
units are ready to respond.

---

## Users

A directory of everyone registered on the instaROSA app.

- Search by **name or phone number**.
- Filter by **barangay**.
- A summary bar shows total registered users, how many have filed at least
  one report, and the total number of reports filed.

Each user's card shows their name, phone number, barangay, the date they
joined, how many reports they've filed, and their emergency contact (if
provided).

---

## Tips

- Cards highlighted in the queue are high-severity and still pending —
  prioritize these first.
- Always double-check the response scope before confirming a dispatch —
  city-wide assistance pulls from a different unit pool than barangay-level.
- Check the Analytics tab periodically, not just during active incidents —
  it's designed to help you catch patterns before they become bigger
  problems.
- Keep the Units list up to date; the dispatch form only shows units marked
  as **Available**.

---

## Need Help?

If something looks wrong or isn't updating:
1. Check your internet connection.
2. Refresh the page.
3. Log out and log back in.

For an active, life-threatening emergency, use the **Emergency Dispatch**
button in the sidebar to reach the full department base line directly.