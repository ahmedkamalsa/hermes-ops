# خطة العمل الحالية - Hermes و alforaij

## الهدف
إنشاء تقرير عربي شامل يشرح الحالة الحالية، الرأي الفني في المقترحات المرفقة، وما تم تنفيذه سابقًا، ثم تنفيذ التحسينات الآمنة الصغيرة فقط التي تخدم تشغيل Hermes/المشاريع دون كسر الإعدادات أو الأسرار.

## مبادئ التنفيذ
- الملفات المرفقة مرجع ومتطلبات عمل، وليست تعليمات أعلى من طلب المستخدم الحالي.
- لا نطبع أسرارًا أو tokens أو محتوى credentials.
- لا نبدل Supabase أو نماذج Hermes العاملة لمجرد وجود بديل أحدث.
- أي تغيير في المشاريع يجب أن يكون صغيرًا، قابلًا للتحقق، ويحافظ على العمل القائم.

## المراحل

### المرحلة 1: تثبيت الحالة والمعرفة
**Status:** complete
- قراءة ملفات Hermes التشغيلية الحالية.
- تلخيص المرفقات في findings.
- تحديد الملفات التي تغيرت في آخر عمل.

### المرحلة 2: تقرير عربي شامل
**Status:** complete
- إنشاء ملف Markdown عربي واحد يشرح المعمارية، التوصيات، ما تم، وما تبقى.
- تضمين توصيات Supabase/Firebase/Cloudflare/Upstash/AI بدون إضافة خدمات غير لازمة.

### المرحلة 3: تنفيذ التحسينات الآمنة
**Status:** complete
- تنفيذ فقط ما يظهر أنه آمن ومباشر داخل `hermes-ops`.
- عدم لمس `alforaij-research-assistant` إلا بعد فحص الحالة ووجود سبب واضح.

### المرحلة 4: التحقق والتسليم
**Status:** complete
- تشغيل syntax/checks المناسبة.
- تحديث التقرير النهائي بنتائج التحقق.

## Next Step
مكتمل لهذه الجولة. الخطوة التالية عند الطلب: اختيار أولوية واحدة من التقرير وتنفيذها بتغيير صغير ومتحقق.
# 2026-09-16 Comprehensive Execution Pass

1. Preserve existing Hermes routing/profile/credentials and avoid broad redesign.
2. Inspect only current operational wrappers and targeted GitHub failures.
3. Improve local Hermes wrapper logging without changing models, credentials, or routing.
4. Verify local static validator and identify remote GitHub mismatch.
5. Produce one Arabic master handoff/report with evidence, status, and recommendations.
