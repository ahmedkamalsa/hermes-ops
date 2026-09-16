# تقرير عربي شامل - Hermes Pro و alforaij

تاريخ التحديث: 2026-09-16  
النطاق: `D:\foraj_social\287`  
المبدأ: الحفاظ على النظام العامل أولًا، ثم إضافة تحسينات صغيرة قابلة للتحقق.

## 1. رأيي المختصر في الكلام المرفق

الكلام جيد جدًا كاتجاه معماري، خصوصًا في نقطتين:

- لا يتم استبدال Supabase، بل يبقى هو العمود الفقري: PostgreSQL، Auth، Storage، Realtime، RLS، وAPIs.
- الإضافات مثل Firebase وCloudflare وUpstash يجب أن تكون طبقات مساعدة فقط، لا قواعد بيانات بديلة ولا تعقيدًا زائدًا.

أهم تعديل على الكلام: لا ننفذ كل الخدمات دفعة واحدة. الأفضل تحويله إلى خارطة طريق:

1. تثبيت المصدر الحقيقي للبيانات والنشر.
2. حماية التكلفة والاستخدام: rate limit، logging، cache.
3. مراقبة المنتج: analytics/errors/performance.
4. بعدها فقط نبني Property Intelligence وAVM تدريجيًا.

## 2. حالة Hermes الحالية

Hermes Pro مضبوط ليعمل بفلسفة Free-first / Preserve-first:

- Profile المستخدم: `alforaij-pro`.
- النموذج المحلي الأساسي للمهام البسيطة: `lmstudio/qwen3.5-4b`.
- المهام البرمجية/البحثية/الاستدلالية تستخدم أفضل verified-free cloud route متاح أولًا.
- Codex/ChatGPT route موجود كتصعيد اختياري فقط، وليس تلقائيًا للمهام العادية.
- Paid/unknown models ممنوعة بدون موافقة صريحة.
- لا يتم طباعة أو نسخ أو تسجيل secrets.

## 3. ما تم تنفيذه في Hermes

تم سابقًا إنشاء وتشغيل هذه القطع:

- `scripts/hermes-smart.py`: تصنيف المهام واختيار route حسب health registry.
- `model-health-registry.json`: سجل صحة للنماذج والحالة والسعر والقدرات.
- `scripts/hermes-run.ps1`: wrapper للتنفيذ بأمر واحد مع logging.
- `scripts/Start-HermesPro-OneClick.ps1`: مدخل Hermes Pro، يشغل gateway/LM Studio، يختار route، وينشئ session.
- `scripts/install-automation.ps1` و`scripts/uninstall-automation.ps1`: تثبيت/إزالة Scheduled Tasks بدون تفعيل تلقائي.
- `improvement/registry.json` و`scripts/improvement-manager.py`: سجل تحسينات controlled، لا يفعل التغييرات إلا بموافقة بشرية.
- Desktop shortcut باسم `Hermes Pro`.

## 4. إصلاح تم الآن

كان في `scripts/hermes-run.ps1` خلل بعد تحويله لاستخدام profile صريح:

- قائمة الوسائط بدأت بـ`-p alforaij-pro` لكنها لم تضف subcommand `chat`.
- كان يستخدم `-z` بعد `chat`، وهذا غير صحيح لأن `hermes chat` يستخدم `-Q -q` للـquiet query.

الإصلاح:

```powershell
hermes -p alforaij-pro chat --provider ... --model ... -Q -q "task"
```

التحقق:

- Syntax OK لـ:
  - `scripts/Start-HermesPro-OneClick.ps1`
  - `scripts/hermes-run.ps1`
- اختبار verified-free نجح:
  - provider: `openrouter`
  - model: `dots-studio/dots-3-note-preview:free`
  - session: `20260916_014621_34f705`
  - النتيجة: `RUN_FREE_OK`

ملاحظة: PowerShell 5.1 ما زال يعرض `NativeCommandError` عند وجود stderr تحذيري من Hermes، لكن wrapper الآن يعتمد على exit code الحقيقي لا مجرد وجود stderr.

ملاحظة cwd مهمة: profile `alforaij-pro` لديه `terminal.cwd` أصلي يشير إلى `D:\foraj_social\287\alforaijboard`. عند تشغيل sandbox أو مسار عمل مختلف، wrappers تضبط `terminal.cwd` مؤقتًا إلى `WorkingDirectory` ثم تعيده. آخر تحقق أعاد القيمة الأصلية إلى `D:\foraj_social\287\alforaijboard`.

## 5. حالة alforaijboard

الهيكل الحالي كما ظهر من الفحص:

- Frontend static في `site/`.
- Python backend/maintenance scripts في الجذر.
- Supabase integration في:
  - `supabase_integration.py`
  - `site/supabase-client.js`
  - `site/live-supabase-client.js`
- SQL في `sql/`.
- Static generated data في `site/static-data/`.
- Vercel وNetlify مضبوطين الآن لخدمة `site/` مباشرة:

```json
{
  "buildCommand": "echo Static dashboard ready",
  "outputDirectory": "site"
}
```

```toml
[build]
  publish = "site"
  command = "echo Static dashboard ready"
```

سبب هذا القرار: `agent/build_static_site.py` يعتمد على artifact محلي غير موجود `agent/output/.../03_*.xlsx`، لذلك البناء في Vercel لا يجب أن يعيد توليد الموقع من pipeline غير مكتمل.

## 6. حالة Git المهمة

في `alforaijboard` توجد تعديلات مسبقة لم ألمسها:

- `site/analysis-engine.js`
- `site/live-supabase-client.js`

لا يجب عكسها أو تعديلها بدون طلب واضح لأنها قد تكون عملًا سابقًا للمستخدم أو لوكيل آخر.

## 7. التوصية المعمارية لـ Supabase والخدمات المجانية

| الوظيفة | الحل الحالي/المفضل | التوصية |
|---|---|---|
| Database | Supabase PostgreSQL | إبقاؤه الأساسي |
| Auth | Supabase Auth | لا تضف Firebase Auth |
| Storage | Supabase Storage | إبقاؤه ما لم تظهر تكلفة/حجم يبرر R2 |
| Realtime | Supabase Realtime | إبقاؤه |
| RLS | Supabase RLS | أولوية أمنية عالية |
| Analytics | غير واضح/محدود | Firebase Analytics أو Cloudflare Web Analytics |
| Crash/Error monitoring | غير واضح | Firebase Crashlytics للتطبيقات، أو Sentry/Logflare لاحقًا |
| Push notifications | غير واضح | Firebase FCM مناسب إذا يوجد mobile/PWA |
| Rate limiting | غير واضح | Upstash Redis أو Cloudflare Turnstile/Workers |
| AI keys | يجب أن تكون server-side | لا اتصال مباشر من client إلى AI secrets |
| RAG/vector | Supabase pgvector أولًا | لا تضف vector DB خارجي الآن |
| MongoDB | غير مطلوب حاليًا | استخدم PostgreSQL JSONB أولًا |
| Neon | يكرر Supabase | لا أنصح به الآن |
| Turso | مفيد فقط لـedge/local-first/tenant DB | لا أنصح به الآن بدون use case |

## 8. Property Intelligence المقترحة

الفكرة الممتازة هي بناء طبقة ذكاء عقاري بدل نسخ Zillow:

1. Property Data: نوع العقار، المساحة، العمر، الغرف، التشطيب، الدور، المواقف.
2. Market Data: العروض، الصفقات، السعر/م2، سرعة البيع، مدة بقاء الإعلان.
3. Location Intelligence: الحي، الخدمات، المدارس، الطرق، التطويرات المستقبلية.
4. Comparable Engine: مقارنة 10-30 عقارًا مشابهًا مع similarity score.
5. AVM/AI Valuation: نطاق تقييم، ثقة، وليس رقمًا واحدًا فقط.
6. Investment Engine: العائد، المخاطر، الفرق عن القيمة العادلة.

الأولوية العملية:

- MVP أولًا داخل Supabase: جداول comps، valuation_runs، valuation_features.
- نموذج بسيط قابل للتفسير: price_per_m2 + adjustments.
- بعدها نضيف ensemble/ML عندما تتوفر بيانات كافية ونظيفة.

## 9. الخدمات الخارجية المقترحة بحذر

### Firebase

مناسب كطبقة:

- Analytics.
- Crashlytics.
- FCM.
- Performance Monitoring.
- Remote Config.

غير مناسب حاليًا كبديل لـSupabase DB/Auth/Storage.

### Upstash

مناسب جدًا لـ:

- Rate limiting للـAPI وAI.
- منع abuse.
- cache قصير العمر.
- idempotency keys.
- counters.

لا يستخدم كقاعدة بيانات دائمة.

### Cloudflare

مناسب لـ:

- CDN/DNS.
- Turnstile.
- Workers كطبقة حماية أو proxy خفيف.
- Cache.
- Bot protection.

D1 لا يضاف إلا لو عندنا edge-local small data حقيقية. R2 لا يستخدم بدل Supabase Storage إلا إذا ظهر سبب تكلفة/حجم واضح.

### Turso / MongoDB / Neon

لا أنصح بإضافتها الآن:

- Turso ممتاز لحالات SQLite/edge/local-first، لكنها ليست واضحة هنا.
- MongoDB يضيف قاعدة ثانية؛ PostgreSQL JSONB يكفي غالبًا.
- Neon يكرر PostgreSQL الموجود في Supabase.

## 10. سياسة AI المقترحة

أي AI في alforaij يجب أن يمر عبر backend:

```text
Client
 -> API / Supabase Edge Function / Worker
 -> Rate Limit
 -> Cache
 -> AI Provider Abstraction
 -> Usage/Cost Tracking
 -> Supabase
```

المطلوب:

- مفاتيح AI في server-side فقط.
- provider abstraction: OpenAI/Gemini/Groq/OpenRouter/HuggingFace/Cloudflare AI.
- daily/monthly limits لكل user.
- timeout/retry/fallback.
- token/cost tracking.
- cache للنتائج المكلفة.

## 11. أولويات التنفيذ القادمة

أوصي بهذا الترتيب:

1. تثبيت ownership: هل المصدر الحقيقي `alforaij-research-assistant/frontend` أم `alforaijboard/site`.
2. تنظيف pipeline: Vercel/Netlify/GitHub Pages يجب أن يخدموا نفس artifact بوضوح.
3. إصلاح/مراجعة RLS warnings المهمة في Supabase.
4. إضافة usage/rate limiting حول أي endpoints مكلفة.
5. إضافة analytics خفيفة.
6. تصميم جداول Property Intelligence داخل Supabase.
7. بناء Comparable Engine بسيط قبل أي ML ثقيل.
8. إضافة AI abstraction بعد وجود rate limiting وusage tracking.

## 12. ما لا أنصح به الآن

- لا أنصح بنقل قاعدة البيانات من Supabase.
- لا أنصح بإضافة MongoDB أو Neon أو Turso الآن.
- لا أنصح بجعل Vercel يشغل generator يعتمد على ملفات محلية مفقودة.
- لا أنصح بتفعيل paid AI fallback تلقائيًا.
- لا أنصح بتعديل `alforaij-research-assistant` وهو dirty إلا بخطة صغيرة ومحددة.

## 13. مصادر رسمية راجعتها سريعًا

- Firebase Pricing: https://firebase.google.com/pricing
- Firestore quotas: https://firebase.google.com/docs/firestore/quotas
- Cloudflare Workers pricing: https://www.cloudflare.com/developer-platform/products/workers/
- Cloudflare docs/pricing pages: https://developers.cloudflare.com/
- Turso pricing: https://turso.tech/pricing
- MongoDB Atlas pricing: https://www.mongodb.com/pricing
- Neon pricing: https://neon.com/
- Supabase/pgvector: https://supabase.com/

## 14. الخلاصة

الاتجاه الصحيح هو:

- Hermes: يبقى Free-first وPreserve-first مع smart routing مضبوط ومتحقق.
- alforaijboard: يبقى static deployment artifact إلى أن نحسم مصدر التوليد الوحيد.
- Supabase: يبقى القلب.
- Firebase/Cloudflare/Upstash: تضاف كطبقات مساعدة فقط عند وجود حاجة واضحة.
- Property Intelligence: تبدأ بمحرك comparable قابل للتفسير داخل Supabase، ثم ML/AI لاحقًا.

## 15. الحالة النهائية لهذه الجولة

- تم إنشاء هذا التقرير: `hermes-ops/ARABIC_MASTER_REPORT.md`.
- تم تحديث خطة العمل: `hermes-ops/task_plan.md`, `hermes-ops/findings.md`, `hermes-ops/progress.md`.
- تم إصلاح `hermes-ops/scripts/hermes-run.ps1`.
- تم تقليل نافذة تغيير `terminal.cwd` في `Start-HermesPro-OneClick.ps1` بحيث يعود قبل فتح Desktop.
- لم يتم تعديل أسرار أو credentials.
- لم يتم تعديل `alforaij-research-assistant`.
- لم يتم لمس تعديلات `alforaijboard` الموجودة مسبقًا في `site/analysis-engine.js` و`site/live-supabase-client.js`.

## 16. تحديث تنفيذي إضافي - 2026-09-16

بناء على طلب التنفيذ الشامل، تم عمل مرور محدود ومفيد بدون إعادة الفحص القديم:

### ما تم تعديله

- تم تحديث `hermes-ops/scripts/hermes-run.ps1` ليضيف `--pass-session-id` عند تشغيل `hermes chat`.
- أصبح السكربت يقرأ السطر `session_id: ...` من خرج Hermes ويحفظه في `hermes-ops/hermes-run-log.jsonl`.
- تم تشديد التقاط أوامر Hermes في `hermes-run.ps1` و`Start-HermesPro-OneClick.ps1` باستخدام `System.Diagnostics.Process` بدل الاعتماد على `2>&1` في PowerShell، حتى لا يتحول stderr التحذيري إلى `NativeCommandError` في Windows PowerShell 5.1.
- لم يتم تغيير الراوتر، ولا profile، ولا credentials، ولا ترتيب النماذج، ولا سياسة منع paid/unknown.

سبب التعديل: التشغيل اليومي يحتاج trace واضح يربط كل مهمة بـ provider/model/session id/exit code/latency.

تم التحقق بعد التعديل بأمر صغير بدون Codex:

```powershell
.\scripts\hermes-run.ps1 -Task "Reply with exactly PROCESS_CAPTURE_OK" -WorkingDirectory "D:\foraj_social\287\hermes-ops" -TaskClass REASONING
```

النتيجة:

```text
PROCESS_CAPTURE_OK
session_id: 20260916_015905_d8f94c
```

آخر سجل في `hermes-run-log.jsonl`:

```json
{
  "task_class": "REASONING",
  "provider": "openrouter",
  "model": "dots-studio/dots-3-note-preview:free",
  "session_id": "20260916_015905_d8f94c",
  "paid_allowed": false,
  "ok": true,
  "exit_code": 0
}
```

كما تم التأكد أن `terminal.cwd` عاد إلى:

```text
D:\foraj_social\287\alforaijboard
```

### نتيجة فحص alforaijboard المحلي

تم تشغيل:

```powershell
python agent\validate_static_site.py
```

داخل:

```text
D:\foraj_social\287\alforaijboard
```

والنتيجة المحلية ناجحة:

```json
{
  "records": 230,
  "metadata_records": 3912,
  "opportunities_scored": 181,
  "opportunities_visible": 58,
  "market_requests": 36,
  "status": "ok"
}
```

حالة Git المحلية في `alforaijboard`:

```text
## safety/pre-reorg-20260914-163154
 M site/analysis-engine.js
 M site/live-supabase-client.js
```

هاتان الملفان كانتا معدلتين مسبقًا، ولم يتم لمسهما.

### نتيجة فحص GitHub Actions

تم فحص آخر failures في `ahmedkamalsa/alforaijboard`.

النتيجة المهمة:

- فشل `Validate dashboard site` على GitHub لأن نسخة `main` البعيدة من `site/index.html` لا تحتوي `id="boardPlatformFilter"`.
- النسخة المحلية الحالية تحتوي هذا العنصر، ولذلك validator ينجح محليًا.
- إذن هذا ليس bug في validator المحلي الحالي؛ السبب العملي هو اختلاف `main` البعيد عن branch المحلي `safety/pre-reorg-20260914-163154` أو عدم دفع/دمج نسخة الموقع الحالية.

كما تم فحص فشل `System Health Check` على GitHub:

- workflow البعيد `.github/workflows/health-check.yml` يحتوي inline command من نوع `python -c "\n..."`.
- GitHub/bash يمرر `\n` حرفيًا داخل الأمر، فيفشل Python بـ `SyntaxError: unexpected character after line continuation character`.
- يوجد أيضًا quoting خاطئ في header lines داخل نفس الأمر كما ظهر في log.
- المحلي لا يحتوي نفس مجموعة workflows؛ المحلي يحتوي فقط `update-dashboard.yml`، بينما `main` البعيد يحتوي `daily-sync.yml`, `deploy.yml`, `health-check.yml`, `update-dashboard.yml`.

القرار: لا يجب تعديل الفرع المحلي أو عمل push عشوائي الآن؛ المطلوب قبل إصلاح GitHub هو توحيد branch المصدر أو جلب/مراجعة ملفات `main` البعيدة ضمن خطة صغيرة مستقلة.

### التشغيل المحلي الموصى به للوكيل

للمهام اليومية:

```powershell
.\hermes-ops\scripts\Start-HermesPro-OneClick.ps1 -Task "اكتب المهمة هنا" -WorkingDirectory "D:\foraj_social\287" -TaskClass AUTO
```

للتنفيذ المباشر القابل للتسجيل:

```powershell
.\hermes-ops\scripts\hermes-run.ps1 -Task "اكتب المهمة هنا" -WorkingDirectory "D:\foraj_social\287" -TaskClass AUTO
```

للمهام البرمجية:

```powershell
.\hermes-ops\scripts\hermes-run.ps1 -Task "نفذ تعديلًا صغيرًا واختبره" -WorkingDirectory "D:\foraj_social\287\اسم_المشروع" -TaskClass CODING
```

سياسة الاختيار:

- `LOCAL_SIMPLE` -> `lmstudio/qwen3.5-4b`.
- `CODING/RESEARCH/REASONING` -> أفضل HEALTHY verified-free tool-capable model من registry.
- fallback مجاني آخر ثم Qwen.
- `openai-codex/gpt-5.5` لا يستخدم إلا بطلب صريح أو بعد فشل المسارات المجانية وكان المحلي غير كاف.
- paid/unknown ممنوع بدون موافقة صريحة.

### مفاتيح البيئة المجانية/المفيدة المقترحة بالاسم فقط

لا تضع هذه القيم في frontend ولا تطبعها في logs:

- `OPENROUTER_API_KEY`: مفيد للموديلات المجانية عبر OpenRouter.
- `GEMINI_API_KEY` أو `GOOGLE_API_KEY`: مفيد لمسارات Gemini المجانية عند إضافتها رسميًا.
- `GROQ_API_KEY`: مفيد لبعض المسارات المجانية/السريعة إذا كانت متاحة رسميًا.
- `HUGGINGFACE_API_KEY` أو `HF_TOKEN`: مفيد لبعض نماذج Hugging Face.
- `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_KEY` أو `SUPABASE_SERVICE_ROLE_KEY`: للبيانات والـbackend فقط حسب الصلاحية.
- `UPSTASH_REDIS_REST_URL`, `UPSTASH_REDIS_REST_TOKEN`: rate limiting/cache عند تطبيق AI endpoints.
- `CLOUDFLARE_API_TOKEN`: فقط لو تم اعتماد Worker/Turnstile/CDN رسميًا.

### الربط المناسب بالموقع أو البرنامج

الربط الآمن المقترح:

```text
Frontend / Desktop
 -> backend endpoint أو Supabase Edge Function أو Cloudflare Worker
 -> rate limit/cache
 -> Hermes/AI provider abstraction
 -> usage logging
 -> Supabase
```

لا ينصح بأن يتصل الموقع مباشرة بمفاتيح AI. أي API key خاص يجب أن يبقى server-side فقط.

### مراجع رسمية مفيدة

- Firebase pricing: https://firebase.google.com/pricing
- Firestore quotas: https://firebase.google.com/docs/firestore/quotas
- Cloudflare Workers: https://www.cloudflare.com/developer-platform/products/workers/
- Turso pricing: https://turso.tech/pricing
- MongoDB Atlas pricing: https://www.mongodb.com/pricing
- Neon pricing: https://neon.com/
- Supabase pgvector/docs: https://supabase.com/

### ما لم يتم فعله

- لم يتم push إلى GitHub.
- لم يتم تعديل `alforaij-research-assistant`.
- لم يتم تنظيم المجلدات أو نقل ملفات.
- لم يتم لمس generated JSON.
- لم يتم كشف أي secret.
- لم يتم حذف Hermes Desktop أو إنشاء profile جديد.

### الخطوة التالية الآمنة

الخطوة التالية الأفضل هي فرع صغير مستقل لإصلاح GitHub `main` workflows:

1. جلب نسخة `main` أو إنشاء worktree نظيف منها.
2. إصلاح `health-check.yml` باستبدال inline `python -c "\n..."` بملف Python صغير أو heredoc صحيح.
3. دمج نسخة `site/index.html` التي تحتوي `boardPlatformFilter` أو تعديل validator إذا تغيرت الواجهة عمدًا.

## 17. كيفية العمل بالنظامين: Hermes + موقع alforaij

هذا القسم هو دليل تشغيل مختصر لوكيل آخر أو لك أنت لاحقًا. المفاتيح والتوكن الموجودة لا يتم حذفها ولا تدويرها ولا طباعتها. أي ربط جديد يجب أن يستخدم أسماء المتغيرات فقط، والقيم تبقى داخل بيئة التشغيل أو مخزن Hermes/Vercel/Supabase/Cloudflare.

### أ. تشغيل Hermes المحلي اليومي

المدخل اليومي الموصى به هو اختصار سطح المكتب:

```text
Hermes Pro
```

أو من PowerShell:

```powershell
.\hermes-ops\scripts\Start-HermesPro-OneClick.ps1 -WorkingDirectory "D:\foraj_social\287" -TaskClass AUTO
```

لو تريد أمرًا مباشرًا بدون فتح الواجهة:

```powershell
.\hermes-ops\scripts\hermes-run.ps1 -Task "اكتب المهمة هنا" -WorkingDirectory "D:\foraj_social\287" -TaskClass AUTO
```

للمهام البرمجية داخل مشروع محدد:

```powershell
.\hermes-ops\scripts\hermes-run.ps1 `
  -Task "نفذ تعديلًا صغيرًا واختبره" `
  -WorkingDirectory "D:\foraj_social\287\alforaijboard" `
  -TaskClass CODING
```

للمهام العقارية:

```powershell
.\hermes-ops\scripts\hermes-run.ps1 `
  -Task "حلل فرصة عقارية أو ابنِ comparable analysis" `
  -WorkingDirectory "D:\foraj_social\287" `
  -TaskClass REAL_ESTATE
```

### ب. سياسة اختيار النماذج

السياسة الحالية التي يجب الحفاظ عليها:

```text
LOCAL_SIMPLE
 -> lmstudio/qwen3.5-4b

CODING / RESEARCH / REASONING / REAL_ESTATE
 -> أفضل HEALTHY verified-free model مناسب
 -> بديل verified-free
 -> qwen3.5-4b

CODEX_HEAVY
 -> openai-codex/gpt-5.5 فقط عند طلب صريح أو بعد فشل المسارات المجانية وعدم كفاية المحلي
```

ممنوع تلقائيًا:

- paid models.
- unknown pricing.
- embedding-only models في chat/agent routes.
- إعادة توليد static API keys.
- طباعة secrets أو تسجيلها.

### ج. الملفات التشغيلية المهمة في Hermes

```text
hermes-ops\scripts\hermes-smart.py
hermes-ops\scripts\hermes-run.ps1
hermes-ops\scripts\Start-HermesPro-OneClick.ps1
hermes-ops\model-health-registry.json
hermes-ops\hermes-run-log.jsonl
hermes-ops\FINAL_OPERATIONS.md
hermes-ops\HANDOFF.md
hermes-ops\ARABIC_MASTER_REPORT.md
```

دور كل ملف:

- `hermes-smart.py`: يصنف المهمة ويختار route.
- `hermes-run.ps1`: ينفذ مهمة واحدة ويسجل provider/model/session/exit code/latency.
- `Start-HermesPro-OneClick.ps1`: يشغل Gateway وLM Studio/Qwen عند الحاجة ثم يبدأ Hermes Pro.
- `model-health-registry.json`: مصدر قرار الصحة والسعر والقدرات.
- `hermes-run-log.jsonl`: سجل التنفيذ العملي.

### د. ربط Hermes بقاعدة البيانات

الربط الأفضل ليس أن يقرأ Hermes مفاتيح الموقع مباشرة من frontend. الربط الصحيح:

```text
Hermes local agent
 -> backend script أو API داخلي
 -> Supabase service role عند الحاجة للمهام الإدارية
 -> Supabase anon key فقط للقراءات العامة المسموحة
 -> logs/usage/audit tables
```

الأسماء التي يجب استخدامها بدون طباعة قيمها:

```text
SUPABASE_URL
SUPABASE_ANON_KEY
SUPABASE_SERVICE_KEY
SUPABASE_SERVICE_ROLE_KEY
```

اقتراحي الاحترافي:

1. إنشاء طبقة Python صغيرة داخل المشروع اسمها مثلًا `services/db_client.py`.
2. تقرأ المتغيرات من البيئة فقط.
3. تمنع أي logging للقيم.
4. توفر دوال واضحة مثل:
   - `get_market_summary()`
   - `get_recent_listings(limit)`
   - `write_agent_audit_event(event)`
   - `write_ai_usage(provider, model, task_class, tokens, cost)`
5. Hermes يستدعي هذه الدوال بدل أن يفتح اتصال عشوائي بقاعدة البيانات.

### هـ. ربط الموقع بالـAI أو Hermes

لا أنصح بوضع مفتاح AI في JavaScript داخل `site/`. الربط الصحيح:

```text
site/
 -> /api/ai أو Supabase Edge Function أو Cloudflare Worker
 -> rate limit
 -> cache عند الحاجة
 -> provider abstraction
 -> Supabase logging
 -> response للواجهة
```

أسماء مفاتيح AI المقترحة، مع بقاء القيم كما هي في البيئة:

```text
OPENROUTER_API_KEY
GEMINI_API_KEY
GOOGLE_API_KEY
GROQ_API_KEY
HUGGINGFACE_API_KEY
HF_TOKEN
```

أسماء rate-limit/cache المقترحة:

```text
UPSTASH_REDIS_REST_URL
UPSTASH_REDIS_REST_TOKEN
```

لو اخترنا Cloudflare Worker:

```text
CLOUDFLARE_API_TOKEN
CLOUDFLARE_ACCOUNT_ID
```

### و. أفضل اختيار معماري الآن

الأفضل الآن:

```text
Supabase = المصدر الأساسي للبيانات والصلاحيات
Vercel/Netlify = استضافة static site فقط
Hermes = وكيل محلي للتطوير والصيانة والتحليل
OpenRouter/free cloud + Qwen = تشغيل AI منخفض التكلفة
Upstash أو Cloudflare = rate limiting لاحقًا عند فتح AI للمستخدمين
```

لا أنصح الآن بإضافة Firebase كقاعدة بيانات ثانية. يمكن استخدام Firebase لاحقًا فقط لـAnalytics/FCM/Crash reporting إذا ظهرت حاجة واضحة.

لا أنصح الآن بإضافة MongoDB/Neon/Turso إلا لو ظهر use case واضح؛ Supabase PostgreSQL يكفي، وJSONB/pgvector يعطيان مرونة كبيرة بدون تعقيد قاعدة ثانية.

### ز. روابط رسمية للعمل

Supabase:

- المنصة والميزات: https://supabase.com/
- Edge Functions: https://supabase.com/docs/guides/functions
- Row Level Security: https://supabase.com/docs/guides/database/postgres/row-level-security
- Vector/pgvector: https://supabase.com/docs/guides/ai

Vercel:

- Project/build settings: https://vercel.com/docs/deployments/configure-a-build
- Environment variables: https://vercel.com/docs/environment-variables

Cloudflare:

- Workers docs: https://developers.cloudflare.com/workers/
- Environment variables/secrets: https://developers.cloudflare.com/workers/configuration/secrets/
- Turnstile: https://developers.cloudflare.com/turnstile/
- Web Analytics: https://developers.cloudflare.com/web-analytics/

Upstash:

- Redis docs: https://upstash.com/docs/redis
- Rate limiting: https://upstash.com/docs/redis/sdks/ratelimit-ts

Firebase:

- Pricing: https://firebase.google.com/pricing
- Cloud Messaging: https://firebase.google.com/docs/cloud-messaging
- Analytics: https://firebase.google.com/docs/analytics

OpenRouter:

- Models: https://openrouter.ai/models
- API docs: https://openrouter.ai/docs

Google Gemini:

- API docs: https://ai.google.dev/gemini-api/docs
- Pricing: https://ai.google.dev/pricing

Groq:

- Docs: https://console.groq.com/docs
- Pricing: https://groq.com/pricing/

Hugging Face:

- Inference Providers: https://huggingface.co/docs/inference-providers

### ح. خطوات التنفيذ المقترحة بدون مخاطرة

1. لا نغير المفاتيح الحالية.
2. نضيف backend/edge endpoint واحد فقط للـAI بدل ربط مباشر من الموقع.
3. نضيف جدول `agent_audit_events` في Supabase لتسجيل تشغيل Hermes/AI بدون secrets.
4. نضيف جدول `ai_usage_events` لتتبع provider/model/task_class/tokens/cost.
5. نضيف rate limit قبل أي endpoint يستدعي AI.
6. نضيف cache للطلبات المتكررة مثل تحليل السوق أو ملخص المنطقة.
7. نربط الواجهة بزر أو panel واحد مبدئيًا مثل "تحليل ذكي" بدل نشر AI في كل الشاشة.
8. بعد نجاحه، نوسع إلى Property Intelligence وComparable Engine.

### ط. قاعدة أمان مهمة

أي كود frontend يجب أن يرى فقط:

```text
SUPABASE_URL
SUPABASE_ANON_KEY
```

أي شيء مثل:

```text
SUPABASE_SERVICE_ROLE_KEY
OPENROUTER_API_KEY
GEMINI_API_KEY
GROQ_API_KEY
UPSTASH_REDIS_REST_TOKEN
```

يبقى server-side فقط.

### ي. قرار نهائي

أنا موافق على ربط Hermes والموقع بقاعدة البيانات، لكن التنفيذ الصحيح يكون تدريجيًا:

```text
أولًا: تثبيت مصدر البيانات والنشر
ثانيًا: backend AI endpoint محمي
ثالثًا: usage/rate-limit/audit
رابعًا: واجهة AI صغيرة
خامسًا: Property Intelligence
```

هذا يعطيك نظامًا احترافيًا، قابلًا للتوسع، ويحمي المفاتيح والتكلفة.
## تحديث تنفيذي نهائي - تجربة الربط المباشر والرفع - 2026-09-16

### ما تم تنفيذه فعليًا

- تم تشغيل Hermes عبر `hermes-run.ps1` باستخدام profile `alforaij-pro`.
- آخر اختبار مباشر ناجح:
  - provider: `openrouter`
  - model: `dots-studio/dots-3-note-preview:free`
  - session id: `20260916_022944_1a0ba8`
  - exit code: `0`
  - paid allowed: `false`
  - النتيجة: `DIRECT_HERMES_OK`
- تم التحقق من أن LM Studio يعمل وبداخله `qwen3.5-4b` كمسار محلي للمهام البسيطة.
- تم التحقق من أن `hermes-smart.py` يختار:
  - `LOCAL_SIMPLE` إلى Qwen المحلي.
  - `CODING` و`RESEARCH` إلى verified-free cloud route عند توفره.
- تم اختبار `alforaij-research-assistant` محليًا:
  - `/api/health` رجع `status=ok`
  - عدد السجلات المقروءة من Supabase: `182`
- تم اختبار Supabase قراءة فقط بدون تعديل:
  - service role read: OK
  - anon read: OK
- تم التحقق من روابط النشر:
  - `https://ahmedkamalsa.github.io/alforaij/`
  - `https://ahmedkamalsa.github.io/alforaijboard/`

### ما تم رفعه إلى GitHub

- `alforaij-research-assistant`
  - branch: `main`
  - آخر commit: `f663180 docs: record direct integration test results [skip ci]`
- `alforaijboard`
  - branch: `safety/pre-reorg-20260914-163154`
  - آخر commit: `301ba78 docs: record direct integration test results [skip ci]`

### طريقة التشغيل اليومية

للمهام البرمجية أو البحثية:

```powershell
cd D:\foraj_social\287
.\hermes-ops\scripts\hermes-run.ps1 -Task "اكتب المهمة هنا" -WorkingDirectory "D:\foraj_social\287\alforaij-research-assistant" -TaskClass CODING
```

للمهام البسيطة محليًا:

```powershell
cd D:\foraj_social\287
.\hermes-ops\scripts\hermes-run.ps1 -Task "اكتب المهمة البسيطة هنا" -WorkingDirectory "D:\foraj_social\287" -TaskClass LOCAL_SIMPLE
```

لتشغيل الموقع محليًا:

```powershell
cd D:\foraj_social\287\alforaij-research-assistant
.\start-local.ps1
```

ثم افتح:

```text
http://127.0.0.1:8000
```

### مفاتيح قد تحتاجها لاحقًا

لم يتم عرض أو تغيير أي مفتاح موجود. المطلوب لاحقًا فقط عند تفعيل الميزات المقابلة:

- `GOOGLE_CLIENT_ID`: لتفعيل Google Login.
- `GEMINI_API_KEY` أو `GOOGLE_API_KEY`: لإضافة Gemini كمسار إضافي.
- `GROQ_API_KEY`: لإضافة Groq كمسار سريع إضافي.
- `HUGGINGFACE_API_KEY` أو `HF_TOKEN`: لمسارات Hugging Face.
- `UPSTASH_REDIS_REST_URL` و`UPSTASH_REDIS_REST_TOKEN`: للـ rate limit/cache.
- `CLOUDFLARE_API_TOKEN` و`CLOUDFLARE_ACCOUNT_ID`: عند استخدام Cloudflare Workers/Pages.
- `VERCEL_TOKEN`: عند استخدام Vercel CLI/CI.

### القرار الفني

النظام الحالي صالح كوكيل يومي عملي:

1. Qwen المحلي للمهام البسيطة.
2. verified-free cloud للبرمجة والبحث عند الحاجة.
3. عدم استخدام paid/unknown تلقائيًا.
4. Supabase يبقى قاعدة البيانات الأساسية.
5. أي AI عام للمستخدمين يجب أن يمر عبر backend/edge endpoint مع rate limit وتسجيل استخدام.

## تصحيح مهم حول المفاتيح داخل Hermes - 2026-09-16

بعد التنبيه إلى أن المفاتيح موجودة داخل ملفات/بروفايل Hermes Agent على الجهاز، تم التحقق بدون عرض أي قيمة سرية.

النتيجة:

- Hermes يعمل من:
  - `C:\Users\hello\AppData\Local\hermes\bin\hermes.exe`
- مخزن Hermes المحلي يحتوي ملفات إعداد واعتماد مثل:
  - `C:\Users\hello\AppData\Local\Hermes\.env`
  - `C:\Users\hello\AppData\Local\Hermes\auth.json`
  - `C:\Users\hello\AppData\Local\Hermes\supabase.env`
  - `C:\Users\hello\AppData\Roaming\Hermes\secure-token-storage.json`
- `hermes -p alforaij-pro auth list` أظهر credentials موجودة داخل profile `alforaij-pro` لعدة providers، منها:
  - `openrouter`
  - `gemini`
  - `huggingface`
  - `lmstudio`
  - `openai-codex`
  - `novita`
  - `xai`
  - `upstage`

التصحيح الفني:

```text
المفاتيح ليست مفقودة من Hermes.
الفحص السابق كان عن OS environment variables العامة فقط.
Hermes لديه credential store وملفات env محلية ويستخدمها بالفعل.
```

قرار التشغيل:

1. لا نطلب مفاتيح جديدة إلا إذا ظهر provider بحالة `AUTH_REQUIRED` أو فشل صريح.
2. لا نطبع ولا ننسخ محتوى `.env` أو `auth.json`.
3. لا نغير credential store الحالي.
4. `openrouter` مثبت عمليًا كمسار verified-free ناجح.
5. `gemini` و`huggingface` موجودان كاعتمادات، لكن يحتاجان health check قبل الاعتماد التلقائي.
6. `openai-codex` موجود، لكنه يبقى escalation اختياريًا وليس route افتراضيًا.

الخلاصة: المطلوب ليس البحث عن مفاتيح جديدة، بل إدارة ذكية للصحة والتوجيه والتكلفة فوق المفاتيح الموجودة بالفعل داخل Hermes.

## تحسين Windows User Environment Variables - 2026-09-16

تم تنفيذ تحسين محلي اختياري بعد الموافقة: مزامنة المفاتيح المفيدة من ملفات Hermes env إلى Windows User environment variables، بدون عرض أي قيمة سرية.

السكربت:

```powershell
D:\foraj_social\287\hermes-ops\scripts\sync-hermes-env-to-user.ps1
```

المصادر:

```text
C:\Users\hello\AppData\Local\Hermes\.env
C:\Users\hello\AppData\Local\Hermes\supabase.env
```

ما لا يفعله السكربت:

- لا يقرأ `auth.json`.
- لا ينسخ OAuth tokens.
- لا يطبع القيم.
- لا يغير Hermes credential store.

المتغيرات التي تمت مزامنتها كـ User environment variables:

```text
BROWSER_USE_API_KEY
GITHUB_TOKEN
HERMES_LANGFUSE_PUBLIC_KEY
HERMES_LANGFUSE_SECRET_KEY
LM_API_KEY
OPENCODE_ZEN_API_KEY
OPENROUTER_API_KEY
SUPABASE_ANON_KEY
SUPABASE_KEY
SUPABASE_PROJECT_REF
SUPABASE_PUBLISHABLE_KEY
SUPABASE_SECRET_KEY
SUPABASE_SERVICE_KEY
SUPABASE_SERVICE_ROLE_KEY
SUPABASE_URL
TERMINAL_ENV
```

نتيجة التحقق:

```text
16/16 variables present as User environment variables.
DryRun after sync: changed_count=0, unchanged_count=16.
```

الاستخدام لاحقًا:

```powershell
cd D:\foraj_social\287
.\hermes-ops\scripts\sync-hermes-env-to-user.ps1
```

للفحص فقط:

```powershell
.\hermes-ops\scripts\sync-hermes-env-to-user.ps1 -DryRun
```

ملاحظة: افتح Terminal جديدًا إذا أردت أن ترث البرامج الجديدة هذه المتغيرات تلقائيًا.

## طريقة الاستخدام العملية بعد التطبيق الشامل - 2026-09-16

تم إنشاء اختصار سطح مكتب لتسهيل تشغيل Hermes:

```text
C:\Users\hello\Desktop\Hermes Pro.lnk
```

الاختصار يشغل:

```text
D:\foraj_social\287\hermes-ops\scripts\Start-HermesPro.cmd
```

الفائدة العملية:

```text
دبل كليك على Hermes Pro
اكتب المهمة الأولى
Hermes يصنف المهمة محليًا
يختار local/free route
يشغل gateway وLM Studio عند الحاجة
يفتح/يشغل Hermes بنفس profile alforaij-pro
```

أوامر بديلة من PowerShell:

```powershell
cd D:\foraj_social\287
.\hermes-ops\scripts\Start-HermesPro.cmd
```

تشغيل مباشر بمهمة محددة:

```powershell
.\hermes-ops\scripts\hermes-run.ps1 -Task "راجع الكود وشغل الاختبارات" -WorkingDirectory "D:\foraj_social\287\alforaij-research-assistant" -TaskClass CODING
```

مثال صيغة طلب جيدة:

```text
أنت داخل D:\foraj_social\287\alforaij-research-assistant.
افحص git status.
أصلح المشكلة التالية فقط.
لا تطبع secrets.
لا تستخدم paid models.
شغل الاختبارات المناسبة.
اكتب ملخصًا بالعربي لما غيرته.
```

سياسة التوجيه:

```text
LOCAL_SIMPLE -> lmstudio/qwen3.5-4b
CODING/RESEARCH/REASONING -> verified-free healthy route -> free fallback -> local Qwen
CODEX_HEAVY -> فقط بطلب صريح أو بعد فشل free/local مع سبب واضح
```

الخلاصة: Hermes Pro أصبح مدخل الاستخدام اليومي العملي. تكلمه بالمهمة مثل الشات، لكنه يعمل داخل ملفات المشروع ومعه terminal/tools حسب route، مع منع paid/unknown تلقائيًا وحماية الأسرار.
---

## تحديث تنفيذ فعلي - إصلاح عداد الفريج الحي 2026-09-16

### المشكلة

كان الموقع يعرض `الفريج 182` لأن الكود كان يحسب سجلات الفريج من لقطة `dashboard-summary.json` الثابتة. هذه اللقطة ليست API الفريج الأصلي ولا تتحدث تلقائيًا مع `front.alforaij.com`.

### السبب الفني

- مصدر `182`: عدد السجلات داخل `dashboard-summary.json` التي تحمل `source == "الفريج"`.
- مصدر الفريج الحي الصحيح موجود في API عام مستخدم أصلًا داخل سكربتات المشروع:
  - `search.alforaij.com/api/internallistings/search`
- تم اختبار API بدون مفتاح، وكانت النتائج الحالية:
  - transactionType=1: `220`
  - transactionType=2: `50`
  - transactionType=3: `38`
  - transactionType=4: `5`
  - transactionType=5: `6`
  - الإجمالي الحي: `319`

### ما تم إصلاحه

1. تم تحديث GitHub Pages branch `gh-pages` ليقرأ عدد الفريج الحي من API العام بدل الاعتماد على لقطة `182`.
2. تم تحديث فرع العمل الآمن `safety/pre-reorg-20260914-163154` في `alforaijboard/site/app.js` بنفس المنطق.
3. بقيت اللقطة الثابتة fallback فقط إذا تعذر الاتصال بـ API الفريج.
4. لا توجد أسرار أو مفاتيح جديدة مطلوبة لهذا الإصلاح.

### نتيجة التحقق

- اختبار GitHub Pages المنشور بعد النشر أعطى:
  - `البيانات: 5140 إعلان مباشر من القاعدة`
  - `الفريج 319 حي`
  - `المواقع الخارجية 4821`
- اختبار الفرع المحلي الآمن أعطى:
  - `السوق الخارجي: ٤٬٨٢١`
  - `الفريج: ٣١٩`

### ملاحظة مهمة

هذا الإصلاح يحدث **العداد** مباشرة من API الفريج، لكنه لا يستبدل كل جدول السجلات المحلي بلقطة كاملة جديدة. للحصول على تحديث كامل لكل تفاصيل سجلات الفريج داخل اللوحة، نحتاج pipeline يجلب صفحات API كلها ويحفظ نسخة normalized في Supabase أو static-data.

### مفاتيح مطلوبة للتحسينات الاحترافية القادمة

لا أحتاج مفاتيح لإصلاح عداد الفريج. للتحسينات القادمة فقط:

- `UPSTASH_REDIS_REST_URL` و `UPSTASH_REDIS_REST_TOKEN`: من لوحة Upstash Redis لاستخدام rate limit/cache لطلبات AI.
- `FIREBASE_API_KEY` و `FIREBASE_APP_ID` و `FIREBASE_MESSAGING_SENDER_ID`: من Firebase Project Settings إذا أردنا Analytics/FCM/Remote Config.
- `CLOUDFLARE_API_TOKEN`: من Cloudflare API Tokens إذا أردنا Worker/Pages/CDN automation.
- `NETLIFY_AUTH_TOKEN`: من Netlify User Settings إذا أردنا فرض deploy والتحقق من Netlify CLI بدل انتظار الربط التلقائي.

## تحديث تشغيلي أخير - 2026-09-16

### alforaijboard

- تم إصلاح عداد الفريج القديم `182` بجلب العدد الحي من API الفريج.
- العدد الحي الحالي للفريج: `319`.
- عدد المواقع الخارجية من Supabase: `4821`.
- إجمالي العرض الصحيح: `5140`.
- GitHub Pages تم دفعه والتحقق منه على `https://ahmedkamalsa.github.io/alforaijboard/`.
- Netlify تم نشره عبر API deploy مباشر:
  - site: `alforaijboard`
  - deploy id: `6aaa02d7ccd47698f977237f`
  - API state: `ready`
- ملاحظة Netlify: الموقع غير مربوط بفرع Git حاليًا. تم النشر يدويًا عبر API، وأداة الويب الخارجية فتحت الصفحة الصحيحة. فشل Playwright المحلي على Netlify بسبب timeout من شبكة الجهاز، لكن اختبار artifact نفسه محليًا أكد أن JavaScript يعرض `5140` و`الفريج 319` ولا يعرض `الفريج 182`.

### Environment والربط

- Upstash Redis REST تم اختباره بنجاح.
- Netlify token يعمل مع API.
- Firebase Web config تم حفظه كـWindows User Environment بدون كتابة القيم داخل Git.
- Cloudflare token الحالي غير صالح للاستخدام الآلي (`401 Unauthorized`) ويحتاج token جديد من Cloudflare.

### Gemini وHugging Face

- `hermes -p alforaij-pro auth list` يذكر provider entries لـ`gemini` و`huggingface`.
- الاختبار الفعلي فشل لأن متغيرات البيئة غير موجودة في Windows/User/Process:
  - `GOOGLE_API_KEY` أو `GEMINI_API_KEY`
  - `HF_TOKEN`
- تم تحديث `hermes-smart.py` ليضع Gemini وHugging Face ضمن candidates بعد OpenRouter وقبل الرجوع إلى Qwen.
- تم تحديث `model-health-registry.json`:
  - `gemini/gemini-2.5-flash`: `AUTH_REQUIRED`
  - `huggingface/inclusionAI/Ling-3.0-flash-VL`: `AUTH_REQUIRED`
- لا يتم استخدامهما تلقائيًا إلا بعد نجاح health check فعلي وتحولهما إلى `HEALTHY`.
- route الصحي الحالي للبرمجة والبحث هو:
  - `openrouter/dots-studio/dots-3-note-preview:free`

### أمان

- لا توجد أسرار محفوظة في Git من هذا التحديث.
- لأن بعض المفاتيح أُرسلت داخل الشات، يوصى بتدويرها لاحقًا من لوحات الخدمات ثم تحديث Windows User Environment/Hermes credentials.
- مفاتيح عقارية خارجية مثل RentCast/ATTOM/HouseCanary فقط إذا أردت مصادر تقييم عقاري خارج الكويت/الخليج؛ ليست مطلوبة للإصلاح الحالي.


## تحديث اعتماد Gemini وHugging Face وCloudflare - 2026-09-16

تم حفظ مفاتيح التشغيل في Windows User Environment بدون كتابتها داخل Git أو عرضها في التقارير.

### نتائج الاختبار

- Gemini:
  - المتغيرات المستخدمة: `GOOGLE_API_KEY` و`GEMINI_API_KEY`.
  - اختبار Hermes صغير نجح.
  - الحالة في `model-health-registry.json`: `HEALTHY`.
  - النموذج المعتمد كمرشح مجاني: `gemini/gemini-2.5-flash`.
- Hugging Face:
  - المتغير المستخدم: `HF_TOKEN`.
  - اختبار Hermes صغير نجح.
  - الحالة في `model-health-registry.json`: `HEALTHY`.
  - النموذج المعتمد كمرشح مجاني: `huggingface/inclusionAI/Ling-3.0-flash-VL`.
- Cloudflare:
  - تم حفظ Global API Key كمتغير بيئة.
  - اختبار Cloudflare API نجح.
  - يظل الاستخدام العملي المقترح لاحقًا هو Workers AI/Workers/Pages حسب الحاجة، مع تفضيل Account/User scoped tokens عند الإنشاء الجديد.

### سياسة routing بعد التحديث

- `LOCAL_SIMPLE` ما زال يستخدم `lmstudio/qwen3.5-4b` أولًا.
- `CODING/RESEARCH/REASONING`:
  1. أفضل OpenRouter verified-free صحي.
  2. بدائل OpenRouter المجانية الصحية.
  3. Gemini المجاني الصحي.
  4. Hugging Face المجاني الصحي.
  5. Qwen المحلي.
- `openai-codex/gpt-5.5` لا يستخدم تلقائيًا، ويظل تصعيدًا صريحًا فقط.

### تحقق فعلي

- `python hermes-ops\scripts\hermes-smart.py select --task-class CODING` اختار:
  - `openrouter/dots-studio/dots-3-note-preview:free`
- البدائل الصحية تضمنت:
  - `gemini/gemini-2.5-flash`
  - `huggingface/inclusionAI/Ling-3.0-flash-VL`
- `LOCAL_SIMPLE` بقي:
  - `lmstudio/qwen3.5-4b`

## نشر Hermes Ops الشامل - 2026-09-16

تم تحويل مجلد `hermes-ops` إلى Git repository مستقل ورفعه على GitHub بعد استبعاد logs/cache/pyc والملفات الحساسة.

الرابط:

- `https://github.com/ahmedkamalsa/hermes-ops`

ما يحتويه repo:

- `scripts/hermes-smart.py`: اختيار route مجاني/محلي حسب الصحة والسعر.
- `scripts/hermes-run.ps1`: تشغيل مهمة واحدة عبر Hermes مع logging آمن.
- `scripts/Start-HermesPro-OneClick.ps1`: مدخل Hermes Pro اليومي.
- `model-health-registry.json`: سجل صحة النماذج، وفيه OpenRouter/Gemini/Hugging Face/Qwen.
- `FINAL_OPERATIONS.md` و`ARABIC_MASTER_REPORT.md`: دليل التشغيل النهائي.
- `skills/real-estate-intelligence/SKILL.md`: skill عقاري جاهز للتثبيت/الرجوع.

ملاحظات أمان:

- لم يتم رفع أي مفاتيح أو tokens.
- تم تجاهل `*.jsonl` و`__pycache__` و`logs/` و`tmp-*` و`.env`.
- المفاتيح تبقى في Windows User Environment أو مخزن Hermes المحلي فقط.

Cloudflare:

- المفتاح الموجود في الصورة/المدخل هو مفتاح Cloudflare API، مفيد لـWorkers AI/Workers/Pages وليس هو المسؤول الوحيد عن Hermes.
- المسؤول الفعلي عن تشغيل Hermes الشامل الآن هو `hermes-ops` مع registry وscripts، بينما Cloudflare مجرد provider/infra يمكن Hermes الاستفادة منه.
