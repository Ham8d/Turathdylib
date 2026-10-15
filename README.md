# Turath Store Overlay (Theos)

مصدر tweak لأجهزة iOS المكسورة الحماية. يعرض بطاقة عربية فوق تطبيقات iOS، ويدعم اتجاه الشاشة بالطولي والعرضي. زر OFF/ON يبدأ بالأحمر، وعند تشغيله يصبح أخضر ويفتح قناة Telegram. زر القناة يفتح الرابط نفسه.

## المتطلبات والحدود

- هذا **ليس تطبيق iOS عاديًا**. حزمة `.deb` تعمل فقط على جهاز jailbreak متوافق، وبـrootless iOS 15 أو أحدث حسب إعداد المشروع.
- هذا المشروع لا يتجاوز sandbox أو حماية iOS على جهاز عادي، ولا يثبت نفسه على جهاز المستخدم.
- فلتر `com.apple.Security` مقصود به التحميل الواسع مع injectors المتوافقة مع سلوك Cydia Substrate. قد تختلف النتيجة باختلاف jailbreak وinjector؛ اختبر على جهاز تملكه، وقد يسبب التحميل الواسع مشاكل توافق.
- الكود لا يرسم الواجهة إلا في عملية تطبيق UIKit يكون مسارها `.app`، ويتجاهل SpringBoard والعمليات غير التطبيقية.
- Codemagic يبني حزمة `.deb` فقط؛ لا يثبتها ولا يفعّلها على الهاتف.
- الشعار يُحمّل من الرابط الذي زودتني به. إذا تعذر الاتصال، يظهر حرف «ت» كبديل.

## التعديل

في `Tweak.xm` يمكنك تعديل:

- رابط الشعار في `TSLogoURLString`
- رابط Telegram في `TSTelegramURLString` ورابط الويب الاحتياطي في `TSTelegramFallbackURLString`
- نص الترحيب وألوان OFF/ON وزر القناة داخل `buildOverlay`

حالة ON/OFF محفوظة محليًا لكل تطبيق على حدة.

## البناء محليًا على macOS

ثبّت Xcode وTheos، ثم من مجلد المشروع:

```sh
export THEOS="$HOME/theos"
make package FINALPACKAGE=1
```

تُنتج Theos الحزمة داخل `packages/`. عدّل `TARGET` و`THEOS_PACKAGE_SCHEME` وقيود `firmware` إذا كان jailbreak لديك rootful أو يستهدف إصدار iOS مختلفًا.

## البناء عبر Codemagic

1. ارفع محتويات هذا المجلد إلى جذر مستودع GitHub، مع إبقاء `codemagic.yaml` في الجذر.
2. اربط المستودع بحساب Codemagic، وتأكد من تفعيل فرع `main` أو عدّل `branch_patterns` في الملف.
3. شغّل workflow باسم **Build Turath Store jailbreak tweak**.
4. نزّل artifact بصيغة `.deb` من نتيجة البناء. ثبّته فقط على جهاز jailbreak متوافق عبر مدير الحزم المناسب لجهازك.

Codemagic يتطلب وجود `codemagic.yaml` في جذر المستودع، والـworkflow هنا يستخدم عامل macOS لتشغيل Theos.
