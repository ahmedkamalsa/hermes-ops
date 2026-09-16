# Findings - Hermes و alforaij

## 2026-09-16
- المستخدم وافق على تنفيذ الأفضل لهيرمس والمشاريع وطلب ملف Markdown عربي شامل.
- المرفق الأول يقترح طبقة Property Intelligence/AVM، Comparable Properties، نطاق ثقة، ومصادر بيانات عقارية مثل ATTOM وHouseCanary وCoreLogic وPriceHubble وRentCast وغيرها.
- المرفق الثاني يوصي بالحفاظ على Supabase كـBackend أساسي، وتقييم Firebase للتحليلات والتنبيهات، Upstash للـrate limiting/cache، Cloudflare للحماية/CDN/Workers، وتجنب إضافة Turso/MongoDB/Neon إلا عند وجود use case واضح.
- آخر عمل مثبت: Hermes free tool agent نجح باستخدام `openrouter/dots-studio/dots-3-note-preview:free` في session `20260915_032959_13bf99` بعد إصلاح cwd المؤقت في wrappers.

## ملاحظات أمان
- لا يجب نسخ credentials أو auth tokens.
- التغييرات المؤقتة على `terminal.cwd` يجب أن تعاد دائمًا إلى قيمتها الأصلية.

## نتائج فحص سريعة
- `alforaijboard` لديه تعديلات موجودة مسبقًا في `site/analysis-engine.js` و`site/live-supabase-client.js`; لم يتم لمسها.
- `vercel.json` و`netlify.toml` في `alforaijboard` يقدمان `site/` مباشرة بأمر `echo Static dashboard ready`.
- `hermes-run.ps1` كان يحتوي خللًا: بعد إضافة `-p alforaij-pro` لم يمرر subcommand `chat` ثم كان يستخدم `-z` في موضع لا يقبله `hermes chat`. تم تصحيحه إلى `hermes -p alforaij-pro chat ... -Q -q`.
- تحقق `hermes-run.ps1 -TaskClass REASONING` باستخدام verified-free أعاد `RUN_FREE_OK` في session `20260916_014621_34f705`.
# 2026-09-16 Targeted Findings

- `alforaijboard` local branch: `safety/pre-reorg-20260914-163154`.
- Local dirty files in `alforaijboard` are pre-existing and preserved: `site/analysis-engine.js`, `site/live-supabase-client.js`.
- Local `python agent\validate_static_site.py` passes and reports `records=230`, `metadata_records=3912`, status `ok`.
- GitHub `ahmedkamalsa/alforaijboard` default branch `main` is not equivalent to local safety branch:
  - Remote workflows on `main`: `daily-sync.yml`, `deploy.yml`, `health-check.yml`, `update-dashboard.yml`.
  - Local branch has only `.github/workflows/update-dashboard.yml`.
  - Remote `site/index.html` does not contain `id="boardPlatformFilter"`, while local `site/index.html` does.
- GitHub `Validate dashboard site` failure is therefore a remote-main artifact mismatch, not reproduced locally.
- GitHub `System Health Check` failure is caused by invalid inline `python -c "\n..."` quoting in remote `.github/workflows/health-check.yml`; the literal escaped newlines and malformed quote terminate Python parsing.
- `hermes-run.ps1` did not persist `session_id` in its JSONL log; patched to pass `--pass-session-id`, parse `session_id: ...`, and write it to `hermes-run-log.jsonl`.

## 2026-09-16 Live Alforaij Count Findings
- The dashboard list snapshot may still contain 182 local rows; the displayed status count now comes from the live public Alforaij search API.
- Full row/detail synchronization requires a separate pipeline to paginate Alforaij API and normalize/store records in Supabase or static-data.
- No new secret is required for the live count. Optional future keys: Upstash, Firebase, Cloudflare, Netlify, and paid/third-party real-estate APIs only if those integrations are explicitly activated.
