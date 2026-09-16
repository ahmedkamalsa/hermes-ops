# Self Improvement Design

## Skill Lifecycle Manager

Statuses:

- `candidate`
- `testing`
- `approved`
- `active`
- `rejected`
- `deprecated`

## Loop

1. Capture session/task result.
2. Classify success/failure.
3. Detect recurring problem.
4. Propose skill/config improvement.
5. Test in sandbox.
6. Run regression check.
7. Require human approval.
8. Install/activate.
9. Keep rollback path.

## Promotion Criteria

A skill can become active only if:

- it solves a repeated problem,
- tests pass,
- it measurably improves outcome or latency/cost,
- it does not duplicate an existing skill,
- rollback is available.

## Existing Hermes Signals

Useful existing mechanisms: memory, skills, curator, sessions, checkpoints, prompt-size, logs, verification evidence DB.

Guardrail: do not allow silent core rewrites, arbitrary code install, or skill promotion without validation.
