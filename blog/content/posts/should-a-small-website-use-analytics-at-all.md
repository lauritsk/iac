+++
title = 'Choosing Analytics for a Personal Blog'
date = 2026-10-13
draft = true
+++

## Writing notes

- **Alternative title:** What Data Does a Personal Blog Need?
- **Subtitle:** Comparing useful visitor metrics with the data needed to collect them.
- **Angle to explore:** How to decide whether a personal blog needs analytics and which information is necessary for one specific purpose.
- **Indirect connection:** Privacy-conscious decisions.
- **Reader:** A fellow IT student building a personal site and considering analytics for the first time.
- **Core question:** What decision would these numbers change, and what is the least intrusive way to answer it?
- **Working position:** Start without analytics unless there is a concrete question; if measurement is justified, keep its scope and retention proportionate.
- **Boundaries:** Focus on a small static blog, not commercial conversion tracking or an exhaustive analytics-product comparison.
- **Course-sized scope:** Choose one useful metric, compare server-log analysis with one analytics tool and no additional collection, and summarise their data and retention tradeoffs.

## Context and distinctions

- Separate editorial curiosity, operational monitoring, and commercial reporting. Whether people enjoy a post is not the same question as whether a page loads successfully.
- Distinguish aggregate counts, session-level analysis, and tracking across visits or sites; avoid treating everything labelled analytics as identical.
- “Cookieless” does not by itself explain what is collected, whether visitors are distinguishable, or how long data remains available.
- Server, hosting, proxy, or CDN logs may already contain visitor information; adding no analytics script is not proof that nothing is recorded.
- Counts are estimates shaped by bots, blocking, caching, and definitions. A page view is not the same as a person reading or valuing a post.

## Possible opening

- Begin with the original question: before installing analytics, what would the numbers actually change?
- Consider an illustrative dashboard showing a small audience; ask what the writer would do differently if the count doubled or halved.
- If using this blog as the example, first check its current configuration and upstream services rather than claiming it collects nothing.

## Section-by-section outline

### 1. Explain the temptation to measure

- Name reasonable motivations: reassurance that someone is reading, curiosity about referrals, and wanting to improve the site.
- Ask whether a dashboard supplies useful feedback or mainly makes publishing feel measurable. Avoid shaming the desire for an audience.

### 2. Write down one decision before choosing a tool

- Contrast “I want more data” with a bounded question, such as whether a moved page still receives requests or whether a navigation link is broken.
- Sketch a decision rule: what observation would lead to what action? If no plausible result changes anything, question the collection.

### 3. Map what answering it would collect

- Trace a request through browser, hosting infrastructure, and any analytics provider; identify who receives which information.
- Separate raw events from published aggregates and retention from collection. Ask whether data can be aggregated or discarded earlier.

### 4. Test lighter alternatives

- Consider direct feedback, occasional reader conversations, manual accessibility checks, and narrowly scoped uptime or error monitoring.
- Admit their limits: feedback is selective, and monitoring availability cannot reveal every usability problem. Choose an alternative because it fits the question, not because it sounds purer.

### 5. Give measurement its strongest case

- Explore a specific example where counts could change a useful decision; explain why the task needs this evidence instead of assuming all numbers are vanity.
- Discuss whether a short measurement period or aggregate-only result is enough. Account for logs and providers rather than focusing only on cookies.

### 6. Define a small, revisable policy

- If collecting: specify the question, necessary fields, access, retention, and review date; explain it plainly to visitors.
- If not collecting: acknowledge the uncertainty being accepted. Revisit the choice when the site's needs change, rather than making permanent ignorance a principle.

## Counterarguments worth taking seriously

- **Without data, improvements become guesswork:** Agree where a decision genuinely needs evidence; distinguish that from collecting everything in case it becomes useful.
- **Privacy-friendly analytics are available:** Evaluate actual behaviour, configuration, and provider access instead of accepting a label or rejecting every tool.
- **Infrastructure already creates logs:** Treat that as a reason to review existing collection, not an automatic justification for adding another dataset.

## Examples and research to gather

- Inventory the site's current scripts, request destinations, and documented host/CDN logging. Record what is verified and what remains unknown.
- Draft a tiny comparison of two questions, the minimum evidence each needs, and an option that does not require visitor profiling.
- Check chosen providers' current field collection, retention, aggregation, and deletion documentation; separate configurable features from actual defaults.
- If discussing consent or exemptions, consult current guidance for the relevant jurisdiction. Do not infer legal compliance from “anonymous” or “cookieless” marketing.

## Personal prompts

- Would I publish a different post if only five people read the previous one? Would that be a better editorial decision?
- Which reader response has genuinely changed something I made?
- Am I seeking evidence for a decision, reassurance about my work, or both?

## Possible ending

- **Takeaway:** A small website can begin without analytics, or measure one justified thing with clear limits; neither choice should hide its tradeoffs.
- **Possible final question:** Which metric would change a decision about this blog, and what is the minimum data needed to produce it?
- Return to the dashboard: identify a concrete decision worth measuring, or accept that publishing can proceed without a number.

## Connections to other drafts

- [Privacy Settings: Defaults, Labels, and User Control](./is-it-fair-to-expect-everyone-to-understand-privacy-settings.md) — reducing collection before shifting responsibility onto visitor controls.
- [Self-Hosting: Updates, Backups, and Maintenance](./is-self-hosting-really-more-independent.md) — knowing where data goes does not remove the work of handling it responsibly.

## Draft
