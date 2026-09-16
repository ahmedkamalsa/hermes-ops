# Progress - Hermes و alforaij

## 2026-09-16
- أنشئت ملفات خطة محلية داخل `hermes-ops` لهذه الجولة حتى لا تختلط بخطة أغسطس القديمة في جذر workspace.
- بدأت بتلخيص المرفقات واعتبارها مواد مرجعية.
- أصلحت `scripts/hermes-run.ps1`: أضيف subcommand `chat` صراحة واستبدل `-z` بـ`-Q -q` عند التشغيل عبر `hermes chat`.
- تحقق syntax نجح لـ`Start-HermesPro-OneClick.ps1` و`hermes-run.ps1`.
- تحقق تشغيل verified-free نجح: `RUN_FREE_OK` عبر `openrouter/dots-studio/dots-3-note-preview:free`، session `20260916_014621_34f705`.
- أعيد `terminal.cwd` إلى `D:\foraj_social\287\alforaijboard` بعد اكتشاف أنه بقي مؤقتًا على `hermes-ops` عقب إيقاف اختبار محلي يدوي.
- حدث `Start-HermesPro-OneClick.ps1` ليعيد `terminal.cwd` مباشرة بعد إنشاء الجلسة وقبل فتح Desktop.
- أنشئ التقرير العربي الشامل: `ARABIC_MASTER_REPORT.md`.
# 2026-09-16 Progress

- Read current `FINAL_OPERATIONS.md`, `HANDOFF.md`, `hermes-run.ps1`, and `Start-HermesPro-OneClick.ps1`.
- Ran local `alforaijboard` validator successfully.
- Queried GitHub Actions failures for `ahmedkamalsa/alforaijboard`.
- Confirmed remote `main` differs from local safety branch and explains validator discrepancy.
- Patched `hermes-ops/scripts/hermes-run.ps1` to log routed Hermes `session_id`.
- Patched `hermes-run.ps1` and `Start-HermesPro-OneClick.ps1` to capture Hermes through `System.Diagnostics.Process`, avoiding PowerShell 5.1 `NativeCommandError` formatting around harmless stderr.
- Verified `hermes-run.ps1` with `TaskClass REASONING`: provider `openrouter`, model `dots-studio/dots-3-note-preview:free`, session `20260916_015905_d8f94c`, exit code `0`, output `PROCESS_CAPTURE_OK`.
- Confirmed `terminal.cwd` restored to `D:\foraj_social\287\alforaijboard`.
- No secrets printed, no repository push performed, no generated JSON touched.

## 2026-09-16 Live Alforaij Count Fix
- Confirmed `الفريج 182` came from static `dashboard-summary.json` records with `source == "الفريج"`.
- Confirmed public Alforaij API works without a new key: `search.alforaij.com/api/internallistings/search`.
- Current live Alforaij totals: type 1=220, type 2=50, type 3=38, type 4=5, type 5=6, total=319.
- Patched `gh-pages` deployed `app.js` to read live Alforaij count with fallback to static snapshot.
- Patched `alforaijboard/site/app.js` on safety branch with the same live-count fallback.
- Verified published GitHub Pages shows `5140` total with `الفريج 319 حي` and `المواقع الخارجية 4821`.
- Fixed markdownlint MD034/MD022 style issues in root `arabic_all.md` and synced copies.
