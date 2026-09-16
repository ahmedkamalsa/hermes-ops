---
name: real-estate-intelligence
description: Use this skill for property opportunity analysis, comparable-property evaluation, Kuwait real-estate market trends, Supabase/local dataset analysis, scoring/ranking, evidence tracking, and structured real-estate reports. Use whenever the user asks to evaluate a property, compare prices, rank opportunities, explain market evidence, or prepare an investment/research report from Alforaij data.
---

# Real Estate Intelligence

## Operating Rules

- Prefer local project data first.
- Use Supabase only when credentials and access are already configured.
- Use external research only when explicitly needed.
- Never make unsupported price claims.
- Distinguish asking price, transaction evidence, model estimate, and opinion.
- Preserve source URLs, timestamps, and confidence notes.

## Workflow

1. Identify property type, area, transaction type, size, condition, and time window.
2. Load local datasets or static exports before web research.
3. Find comparable records by area, type, size band, and recency.
4. Score each comparable for similarity and source confidence.
5. Compute ranges, not a single unsupported value.
6. Flag missing evidence and stale data.
7. Produce a structured report with assumptions, evidence, risks, and next checks.

## Output Shape

- Summary decision.
- Comparable table.
- Price/rent range with evidence quality.
- Opportunity score and reason codes.
- Risks and missing data.
- Source list.
