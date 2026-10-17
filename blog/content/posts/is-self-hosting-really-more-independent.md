+++
title = 'Self-Hosting: Updates, Backups, and Maintenance'
date = 2026-10-17
draft = true
+++

## Writing notes

- **Alternative title:** What Needs Maintaining After a Self-Hosted App Is Installed?
- **Subtitle:** The ongoing tasks behind running a small service yourself.
- **Angle:** Identify the updates, monitoring, backups, and recovery work required after installing a self-hosted application.
- **Indirect connection:** Systems administration, service reliability, and operational responsibility.
- **Reader:** A fellow IT student considering a small self-hosted service as a learning project.
- **Core question:** What needs maintaining, how often should it be checked, and how would the service be recovered?
- **Working position:** Self-hosting can provide meaningful autonomy when the responsibilities are understood and sustainable.
- **Boundaries:** Use one low-stakes application, not a complete homelab design or a claim that self-hosting is always better. Do not invent details about Karl's setup.
- **Course-sized scope:** Choose a small notes or file-sharing service and draft a maintenance checklist covering updates, backups, restore checks, and handover instructions.

## Context and distinctions

- Separate self-hosting from physical ownership: rented infrastructure, home hardware, and managed software offer different kinds of control.
- Distinguish software freedom, data portability, operational access, and service availability. Improving one does not guarantee the others.
- Contrast a hobby service with something other people depend on. Learning through breakage is different when someone else misses an important document.
- Define independence as the ability to make and change choices, not the absence of networks, maintainers, suppliers, or help.

## Possible opening

- Use a hypothetical service migration: the interface looks familiar, but responsibility for the next outage has changed hands.
- Prompt: place two lists beside each other, headed decisions gained and duties inherited. Do not supply an invented personal migration story.

## Section-by-section outline

### 1. Define the service and its maintenance needs

- Offer possible motives: avoiding unilateral changes, controlling retention, learning, or keeping an exportable copy. Keep these motives separate.
- Ask readers to name their actual frustration before choosing infrastructure; a different hosted provider might solve some problems more simply.

### 2. Draw the dependency map

- Trace a hypothetical service through software maintainers, hardware, power, connectivity, domain registration, and any external messaging service it uses.
- Compare which dependencies are replaceable and which are concentrated. Avoid implying that listing dependencies disproves the value of self-hosting.

### 3. Follow the work after installation

- Enumerate updates, monitoring, recovery testing, access management, and incident response; ask who performs each task and when.
- Contrast enthusiasm during setup with a busy month or an illness. Include time and attention alongside equipment costs.

### 4. Consider everyone relying on the service

- Explore a shared calendar or document store as a hypothetical example; ask who can restore access if its operator is unavailable.
- Examine whether household members have real choice, understandable support, and an exit route, rather than becoming involuntary users of someone else's hobby.

### 5. Check backup restoration and data export

- Propose a practical test: export data, document recovery, and describe how to move elsewhere. Treat an untested backup as an unanswered question.
- Ask whether another person could interpret the instructions without the operator; discuss documentation and usable credentials without publishing sensitive details.

### 6. Choose a sustainable amount of responsibility

- Sketch selective self-hosting: keep low-stakes learning projects separate from services whose failure would cause serious disruption.
- Leave room for managed services, shared administration, or returning to hosted provision. Present these as choices rather than admissions of defeat.

## Counterarguments worth taking seriously

- **Large providers have specialist teams:** Acknowledge their resources; compare the actual service and risks instead of assuming either model is always safer.
- **Learning is itself worthwhile:** Agree that education and enjoyment count; distinguish a rewarding hobby from an obligation silently imposed on others.
- **Ownership is worth inconvenience:** Respect that value; ask whether the inconvenience remains acceptable when the operator's time or circumstances change.

## Examples and research to gather

- Choose one self-hostable application's official administrator documentation; list maintenance and recovery tasks it actually requires, with version and date.
- Compare its documented export format with a hosted alternative's current export process; verify provider claims rather than assuming portability.
- Gather a published incident report or maintainer postmortem with a clear timeline; use it to examine responsibilities, not infer general failure rates.
- Build a hypothetical dependency and cost inventory, explicitly labelling assumptions; seek actual quotations only if the article needs concrete prices.

## Personal prompts

- What do I actually want more control over, and what evidence would show that I gained it?
- Which maintenance work do I enjoy, and which work would I postpone when life became difficult?
- If I stopped looking after a shared service tomorrow, who would notice and what could they do?

## Possible ending

- **Takeaway:** Installing the application is only the start; running it requires a manageable plan for updates, backups, recovery, and access.
- **Possible final question:** If this service failed next week, would I know which backup to restore and which steps to follow?

## Connections to other drafts

- [Smart Home Devices: Local Control vs. Cloud Services](./what-happens-to-a-smart-home-when-the-company-shuts-down.md) — compare failure and exit paths without equating them.
- [Digital Legacy Features: Account Access and Privacy](./what-happens-to-our-digital-lives-after-we-die.md) — continuity when the usual operator is absent.

## Draft
