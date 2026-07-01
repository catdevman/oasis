# Competitive Research: SIS Market Gaps & OASIS Opportunity

## Overview

Research into the three major Student Information System (SIS) competitors — PowerSchool, Skyward, and Harmony — reveals systemic failures across security, educator experience, parent/student portals, accessibility, and pricing. This document captures findings to inform OASIS product direction with students, parents, and educators at the forefront.

Research conducted: February 2026. Sources include Capterra, TrustRadius, Gartner Peer Insights, K-12 Dive, EdWeek, TechCrunch, BleepingComputer, court records, and district-level reporting.

---

## 1. PowerSchool

### 1.1 The December 2024 Data Breach — Largest in Children's Data History

- On December 19-28, 2024, an attacker used stolen contractor credentials to access `PowerSource`, PowerSchool's support portal, which contained a maintenance tool allowing direct access to any customer's SIS instance.
- Two core database tables were exfiltrated: students and staff. Multiple districts confirmed hackers stole **all** historical data — not just current records, but every record since the district began using PowerSchool.
- CrowdStrike's post-mortem confirmed the attacker had access as early as August 2024 — undetected for ~4 months. Log retention was too short to preserve earlier evidence.
- **Scale:** ~62,488,628 student records and ~9,506,624 educator records stolen — the largest breach of children's data in US history. Affected 16,000+ school customers across the US, Canada, and UK.
- **Data stolen:** Names, addresses, Social Security Numbers, dates of birth, medical information, grades, behavioral records, parent/guardian contact details — 150 unique fields per student, 97 per staff member.
- **Root cause:** The breached `PowerSource` portal had **no multi-factor authentication**. PowerSchool explicitly acknowledged this.
- PowerSchool paid ~$2.85M in Bitcoin ransom, receiving only a video claiming deletion. That claim was false.
- By May 2025, individual districts in Canada and North Carolina received extortion texts with stolen data samples as proof.
- Matthew Lane (age 20) was sentenced to 4 years federal prison in October 2025 for the breach.

**Legal fallout:**
- 23 class-action lawsuits filed against PowerSchool.
- Texas Attorney General sued PowerSchool over 880,000 exposed Texas children and teachers.
- North Carolina ended its PowerSchool contract and transitioned all schools to Infinite Campus (completed July 1, 2025).

### 1.2 Commercial Surveillance of Children

- A May 2024 class-action alleges PowerSchool collected and monetized data on millions of children, selling data to 100+ third-party "partners." PowerSchool has amassed 345TB of data from 440 school districts including health, behavioral, and academic records.
- A separate class action (Naviance platform) alleges PowerSchool "surreptitiously intercepted, monitored, captured and recorded" student actions without consent, violating FERPA. A San Francisco federal court allowed this lawsuit to proceed in March 2025.
- PowerSchool's products (Naviance, Schoology, SchoolMessenger, core SIS) touch over 80% of US and Canadian K-12 students — a data monopoly families cannot opt out of.

### 1.3 Educator Usability Failures

- Gradebook fails to load or save for teachers managing 12+ class sections, causing data loss.
- Documented bugs: grade scales fail to attach, dropdowns fail to populate, elementary standards lists don't display reliably, teachers cannot modify previously entered grades.
- No "fill down" or copy feature for entering the same grade across multiple students.
- Navigation is described as "confusing and misleading" — e.g., the distinction between "Grade History" and "Historical Grades" is unclear.
- Features are buried deep in menus; most integrations require support staff to complete.
- Mobile app is significantly less capable than the browser version — many features absent entirely.
- Training is expensive and not included in base license. Numerous add-on plugins required at additional cost.
- Co-teaching requires double scheduling: once in PowerScheduler and again on the live side, with no automated workflow.
- One documented account: teachers were "so frustrated they would forfeit their imminent pay raise just to have a computer system that worked." (NC John Locke Foundation)

### 1.4 Parent & Student Experience

- Parent-facing portal has substantially less functionality than the desktop browser version.
- Parents cannot understand why a grade was assigned or communicate with teachers through the same interface.
- Students have no data ownership or self-service capabilities — no student-facing data export or portability mechanism.
- Tens of millions of students now have permanently compromised identity data (SSNs, medical records) with no way to un-expose it.

### 1.5 Vendor Lock-In & Private Equity

- Serves 23% of K-12 SIS market by implementation count; 90%+ of top 100 US districts by enrollment.
- Bain Capital completed a $5.6B acquisition in October 2024, taking PowerSchool private and reducing public disclosure obligations.
- Growth-through-acquisition strategy (17+ acquisitions) means districts buy more PowerSchool products to avoid integration costs — structural lock-in reinforcement.
- ESSER pandemic funding cliff (September 2024) froze many districts into existing contracts; 68% of systems delayed tech replacements in 2024.

---

## 2. Skyward

### 2.1 The Legacy Platform Crisis

- Skyward has been running thousands of districts on SMS 2.0, a platform built on an OS becoming too outdated to upgrade. Migration to Qmlativ (development started ~2017) is a forced, years-long disruption.
- Multiple districts went fully offline for 2+ weeks during summer 2025 data migrations (e.g., Snohomish School District, Cheney School District: July 16-28, 2025).
- Districts not yet on Qmlativ were running end-of-life software. Skyward's own response to negative reviews frequently notes: "you may not be on our newest platform."
- This creates a two-tier user base: modern Qmlativ vs. end-of-life SMS 2.0.

### 2.2 Qmlativ Launch Failures (2025-26 School Year)

- **GPA miscalculations:** Qmlativ incorrectly calculated GPAs for some students. Seniors applying to colleges required manual counselor verification before submission.
- **Class rank invisibility:** Counselors cannot view individual student class rankings — only the valedictorian's rank is visible. Seniors forced to enter "none" on college applications.
- **Transcript integration failure:** Skyward's Parchment integration broke during transition, preventing on-demand transcript pulls and directly impacting college application deadlines.
- **Canvas gradebook sync failure:** For the first weeks of the 2025-26 school year, grades entered in Canvas did not transfer to Skyward at all. Students and parents checking grades saw nothing.
- **Data export regressions:** Bulk student record exports, routine weekly operations in SMS 2.0, became "confusing and difficult" in Qmlativ with no equivalent functionality.
- **Lost institutional configuration:** Templates, forms, and custom configurations built over years in SMS 2.0 did not transfer. Districts rebuilt from scratch.
- **Support inadequacy:** Skyward provided only tutorial videos rather than on-site engineering support during the transition.

### 2.3 Educator Usability Failures

- SMS 2.0 interface is broadly described as outdated and unintuitive, requiring significant training.
- A/B day schedules create multiple rosters per class rather than a unified view, complicating attendance and grading.
- Accessing messages within Skyward is described as "extremely difficult."
- Correcting attendance retroactively (e.g., student arrives late) requires a cumbersome multi-step workflow.
- Manually inputting grades during 6-week grading periods described as "unnecessarily arduous."
- Standards-based gradebook is not supported by Canvas grade passback, forcing parallel grade maintenance.

### 2.4 Parent & Student Experience

- Parents explicitly describe Skyward as "clunky, not user friendly, not family friendly — only a repository of data that is very uneasily accessed."
- Elementary parents find the interface non-intuitive with too many clicks to reach basic grade or attendance information.
- Mobile app: "Open in App" button for grade viewing requires repeated taps over 5-15 minutes before opening.
- The mobile app **cannot complete online forms** — parents and students are forced back to a desktop browser for routine tasks.
- A 2024-25 upgrade required users to re-link accounts. Many parents received inadequate notification, resulting in effective lockouts.
- Students have essentially no self-service capabilities for requesting records, viewing historical transcripts, or exercising any data access rights.

### 2.5 Pricing & Vendor Lock-In

- No published pricing. Entirely quote-based. ITQlick rates pricing transparency at 3.6/10.
- Small schools consistently find cost prohibitive with no small-enrollment discounts.
- Several states (Tennessee, Washington, Rhode Island) mandate Skyward as a preferred provider — regulatory-level lock-in.
- Forced migration from SMS 2.0 to Qmlativ is not optional. Districts absorb migration costs, disruption, and retraining on Skyward's timeline.

---

## 3. Harmony SIS

Harmony SIS does not emerge as a major player with a reviewable public user base on standard platforms (G2, Capterra, TrustRadius, Gartner Peer Insights). Search results are dominated by "Harmony Public Schools" (a Texas charter network) and other unrelated products sharing the name. No 2024-2026 failure reports, security incidents, or pattern complaints were surfaced.

The absence of data is itself a signal: Harmony lacks market presence and scrutiny, suggesting a niche product that does not currently compete at scale.

---

## 4. Cross-Cutting Issues Affecting All Major Platforms

### 4.1 Accessibility — A Legal Deadline Creating Immediate Urgency

On April 24, 2024, the US Department of Justice published final ADA Title II regulations requiring all public K-12 schools to ensure their digital tools meet **WCAG 2.1 Level AA** accessibility standards. The compliance deadline is **April 24, 2026**.

Schools are legally responsible for the accessibility of third-party products they deploy. Neither PowerSchool nor Skyward has made prominent public commitments to full WCAG 2.1 AA compliance for their student/parent-facing portals.

Common accessibility gaps across SIS platforms:
- Missing alternative text for images
- No keyboard navigation support
- Lack of video captioning
- Non-compliant color contrast ratios
- Mobile apps not meeting touch target size requirements

### 4.2 Integration Fragmentation

- Most K-12 districts run parallel systems (LMS, SIS, HR, finance, communications) not designed to interoperate.
- The Canvas-to-Skyward grade passback failure during Qmlativ's rollout is a documented, high-impact instance of this problem.
- Proprietary data formats and non-standard APIs increase switching costs and lock-in.

### 4.3 Budget Constraints Post-ESSER

- ESSER pandemic funding expired September 2024. 68% of school systems delayed technology replacements in 2024.
- This freezes districts in failing contracts they cannot afford to exit — even when they want to.

---

## 5. Severity Summary

| Issue Area | PowerSchool | Skyward | Harmony |
|---|---|---|---|
| Data Security | Catastrophic (62M breach, ongoing extortion) | No documented incidents | No data |
| Student Data Privacy | Severe (lawsuits, data broker allegations) | No documented incidents | No data |
| Educator UX / Gradebook | Significant (freezes, hidden features, poor mobile) | Significant (GPA errors, sync failures in Qmlativ) | No data |
| Parent / Student Portal | Poor (limited app, no self-service, no data portability) | Poor (clunky, app crashes, forms require desktop) | No data |
| Pricing Transparency | Opaque with hidden add-on costs | Fully opaque, quote-only | Unknown |
| Vendor Lock-In | Severe (market dominance, PE acquisition) | Moderate (state mandates, forced migration) | Unknown |
| Technical Debt | Moderate (aging UI, gradebook bugs) | Severe (SMS 2.0 end-of-life forcing migration) | Unknown |
| Recent Platform Failures | Dec 2024 breach + ongoing extortion | Qmlativ launch: GPA errors, sync failures, lost config | No data |

---

## 6. OASIS Strategic Opportunity

### 6.1 Security & Data Trust

PowerSchool's breach was caused by a missing MFA check on a support portal. OASIS's open-source nature means schools can audit exactly what the system does with data — there is no opaque commercial data broker relationship.

**Action items:**
- Enforce authentication at the Host gateway level (currently unimplemented per PRD)
- MFA requirement for all administrative access
- No third-party data sharing by design — document this explicitly
- Publish a transparent data handling policy before any district conversation

### 6.2 Educator Experience

The incumbent gradebook bar is embarrassingly low. PowerSchool's gradebook freezes under normal load. Skyward's broke GPAs at the start of the 2025-26 school year, directly harming seniors' college applications.

**Action items:**
- Ship a gradebook plugin that works reliably under load — this alone differentiates
- Fill-down / bulk grade entry as a baseline feature
- Mobile-first, not mobile-ported
- Build a teacher feedback loop into the product from day one

### 6.3 Parent & Student Portal

Parents using Skyward have explicitly told their districts the system is "not family friendly." PowerSchool's parent app is a stripped-down afterthought.

**Action items:**
- Mobile-first parent/student plugin as a first-class deliverable — not a checkbox
- Forms completable within the mobile app (neither incumbent offers this)
- Plain language grade and attendance views — under 3 taps to any key information
- Student self-service FERPA data export — no incumbent offers this

### 6.4 Accessibility

The ADA Title II WCAG 2.1 AA compliance deadline is April 24, 2026. Schools are legally liable for non-compliant third-party tools. Neither major incumbent has made public compliance commitments.

**Action item:** Build WCAG 2.1 AA compliance into all user-facing plugins from the start. This is an active procurement lever in every district that has received legal counsel warnings — which is most of them.

### 6.5 Pricing & Beachhead Market

Incumbents refuse to publish pricing. Small districts (under 1,000 students) are explicitly underserved and pay prohibitive per-student rates with no discount options.

**Action item:** Publish transparent, honest pricing for support and hosting. Small districts are the beachhead. They are actively looking for exits from incumbent contracts and have the most flexibility to move.

---

## 7. Sources

- [PowerSchool breach — TechCrunch (March 2025)](https://techcrunch.com/2025/03/10/what-powerschool-isnt-saying-about-its-massive-student-data-breach/)
- [PowerSchool 62M students stolen — BleepingComputer](https://www.bleepingcomputer.com/news/security/powerschool-hacker-claims-they-stole-data-of-62-million-students/)
- [PowerSchool extortion of individual schools — K-12 Dive](https://www.k12dive.com/news/powerschool-data-breach-school-extortion-attempts/747690/)
- [PowerSchool breach explainer — TechTarget](https://www.techtarget.com/whatis/feature/PowerSchool-data-breach-Explaining-how-it-happened)
- [PowerSchool "all historical data" stolen — TechCrunch Jan 2025](https://techcrunch.com/2025/01/15/powerschool-data-breach-victims-say-hackers-stole-all-historical-student-data/)
- [NC won't renew PowerSchool contract — WBTV](https://www.wbtv.com/2025/05/08/north-carolina-wont-renew-powerschool-contract-after-data-breach-texts-threat-actors/)
- [NC transitions to Infinite Campus — WBTV Jul 2025](https://www.wbtv.com/2025/07/29/north-carolina-schools-finalize-transition-powerschool-infinite-campus/)
- [PowerSchool 23 lawsuits — BankInfoSecurity](https://www.bankinfosecurity.com/powerschool-faces-23-lawsuits-over-schools-mega-data-breach-a-27331)
- [Texas AG sues PowerSchool](https://www.texasattorneygeneral.gov/news/releases/attorney-general-paxton-sues-big-tech-company-catastrophic-data-breach-compromised-personal)
- [PowerSchool data broker class action — Local News Matters](https://localnewsmatters.org/2024/05/09/class-action-suit-targets-widespread-mining-and-sale-of-student-data-without-consent/)
- [Naviance privacy class action — ClassAction.org](https://www.classaction.org/news/class-action-accuses-powerschool-of-extreme-invasion-of-student-privacy-via-naviance-platform)
- [EdTech surveillance infrastructure — TechPolicy.Press](https://www.techpolicy.press/unmasking-edtechs-surveillance-infrastructure-in-the-age-of-ai/)
- [PowerSchool educator UX — John Locke Foundation](https://lockerroom.johnlocke.org/2014/02/07/powerschool-teachers-biggest-nightmare)
- [PowerSchool reviews — Capterra](https://www.capterra.com/p/154883/PowerSchool-Student-Information-System/reviews/)
- [PowerSchool Bain Capital acquisition](https://www.baincapital.com/news/powerschool-be-acquired-bain-capital-56-billion-transaction)
- [Skyward Qmlativ launch problems — Bloomington South Optimist](https://www.bloomingtonsouthoptimist.org/20506/news/skyward-update-brings-problems-for-counselors-and-college-applications/)
- [Skyward reviews — Capterra](https://www.capterra.com/p/2185/Skyward-School-Management/reviews/)
- [Skyward pricing — ITQlick](https://www.itqlick.com/skyward-student-suite/pricing)
- [Skyward mobile app problems — JustUseApp](https://justuseapp.com/en/app/502635374/skyward-mobile-access/problems)
- [Snohomish Qmlativ migration](https://www.sno.wednet.edu/resources/qmlativ-migration)
- [Cheney School District Qmlativ migration](https://www.cheneysd.org/our-district/qmlativ-migration)
- [ADA Title II K-12 accessibility requirements — K-12 Dive](https://www.k12dive.com/news/schools-colleges-title-ii-digital-accessibility/715184/)
- [K-12 SIS interoperability — SchoolDay](https://www.schoolday.com/interoperability-in-k-12-building-a-seamless-data-ecosystem-for-schools/)
- [K-12 SIS market share — Listed Tech](https://listedtech.com/blog/update-k12-student-information-system/)
