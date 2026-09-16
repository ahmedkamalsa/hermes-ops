# دليل مشروع hermes-ops

آخر تحديث: 2026-09-16

## وظيفة المشروع

تشغيل Hermes Pro محليًا وإدارة routing بين النماذج.

## أهم ملفات

- `FINAL_OPERATIONS.md`: أوامر التشغيل اليومية.
- `ARABIC_MASTER_REPORT.md`: تقرير عربي شامل.
- `scripts/hermes-run.ps1`: تنفيذ مهمة عبر Hermes.
- `scripts/Start-HermesPro-OneClick.ps1`: تشغيل Hermes Pro.
- `improvement/registry.json`: سجل التحسينات.

## سياسة التشغيل

- LOCAL_SIMPLE يستخدم Qwen/local.
- CODING/RESEARCH/REASONING يستخدم verified-free healthy أولًا.
- paid/unknown ممنوع بدون موافقة.
- لا تطبع secrets.

## أمر اختبار

```powershell
cd D:\foraj_social\287\hermes-ops
.\scripts\hermes-run.ps1 -Task "اختبار قصير" -WorkingDirectory "D:\foraj_social\287"
```

