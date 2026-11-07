<div dir="rtl">

# SpotPalette

نسخة معدّلة من **Command Palette** في PowerToys تجعلها شريط بحث بسيطاً مثل **Spotlight** في macOS: يظهر شريط البحث فقط، ويتوسع لعرض النتائج عندما تبدأ بالكتابة. ويمكنك من الإعدادات الاختيار بين هذا التصميم والتصميم الرسمي، مع خيارات تخصيص إضافية للتصميم الجديد.

> **الحالة:** التعديلات مكتوبة ومراجعة، لكنها لم تُبنَ أو تُجرَّب بعد على Windows. إذا ظهر خطأ في البناء فافتح Issue أو أرسل رسالة الخطأ.

## ماذا يضيف؟

في **الإعدادات ← Appearance ← How Command Palette opens** يوجد خياران:

| الخيار | الوصف |
|---|---|
| **Official (full palette)** | التصميم الرسمي كما هو دون أي تغيير |
| **Spotlight search bar** | شريط بحث فقط يتوسع عند الكتابة (أو عند الضغط على ↓ أو Tab) |

وعند اختيار **Spotlight search bar** تتفعل مجموعة **Spotlight search bar style**:

| الخيار | الافتراضي | الوصف |
|---|---|---|
| Visible result rows | 8 | عدد أسطر النتائج الظاهرة قبل التمرير (0 = حتى أسفل الشاشة) |
| Search text size | 22 | حجم خط نص البحث (12 – 36) |
| Search bar height | 14 | المسافة فوق نص البحث وتحته (4 – 32) |
| Corner roundness | 14 | استدارة زوايا الشريط والنتائج (0 – 32) |
| Show Command Palette icon | مفعّل | أيقونة البرنامج في بداية الشريط |
| Show section headers | مفعّل | عناوين المجموعات مثل Pinned و Commands |
| Show command bar | معطّل | الشريط السفلي (Settings و Run و More). الاختصارات تبقى تعمل حين يكون مخفياً |
| Reset to defaults | — | يعيد كل الخيارات السابقة إلى قيمها الافتراضية |

خيارات موجودة أصلاً وتعمل مع التصميم الجديد: موضع الشريط العمودي على الشاشة (Vertical search box position)، و Quick access shelf، وعرض النافذة (اسحب حافتها لتغييره).

## طريقة العمل

المستودع لا يحتوي نسخة كاملة من PowerToys (حجمها كبير جداً)، بل يحتوي:

- `UPSTREAM_COMMIT`: رقم الـ commit الرسمي الذي بُنيت عليه التعديلات.
- `patches/`: التعديلات نفسها كملف patch.
- `scripts/setup.ps1`: ينزّل PowerToys عند ذلك الـ commit ويطبّق التعديلات.
- `scripts/export-patch.ps1`: يحفظ تعديلاتك الجديدة من مجلد PowerToys إلى `patches/`.

## التثبيت والبناء

1. ثبّت متطلبات بناء PowerToys (Visual Studio مع حزم ‎.NET desktop و Desktop development with C++ و Windows App SDK) حسب [توثيق PowerToys](https://github.com/microsoft/PowerToys/tree/main/doc/devdocs#compiling-powertoys). لا تحتاج إلى بناء PowerToys كاملاً.
2. من PowerShell داخل مجلد هذا المستودع:

</div>

```powershell
.\scripts\setup.ps1 -OpenVisualStudio
```

<div dir="rtl">

   سينشئ مجلد `PowerToys` بجانب هذا المستودع ويطبّق التعديلات عليه.

3. في Visual Studio اختر `Debug` والمنصة المناسبة لجهازك (`x64` أو `ARM64`)، ثم انقر بالزر الأيمن على `Microsoft.CmdPal.UI` واختر **Build** ثم **Deploy**.
4. شغّل Command Palette من قائمة Start، ثم اذهب إلى **Settings ← Appearance** واختر **Spotlight search bar**.

> إذا كانت نسخة PowerToys الرسمية مثبتة، فقد يتعارض الاختصار `Win+Alt+Space` بين النسختين. عطّل Command Palette في إعدادات PowerToys الرسمية أو غيّر اختصار إحداهما.

## تعديل الكود بنفسك

1. عدّل الملفات داخل `PowerToys\src\modules\cmdpal`.
2. احفظ التعديلات في هذا المستودع:

</div>

```powershell
.\scripts\export-patch.ps1
```

<div dir="rtl">

3. اعمل commit لملف الـ patch الجديد.

## التحديث إلى أحدث إصدار من PowerToys

</div>

```powershell
.\scripts\setup.ps1 -Latest
```

<div dir="rtl">

إذا غيّرت Microsoft الأسطر نفسها فلن يُطبَّق الـ patch، وسيخبرك السكربت بذلك. عندها يلزم تعديل الـ patch يدوياً، أو البقاء على الـ commit المثبّت.

## الملفات المعدّلة

| الملف | التعديل |
|---|---|
| `Microsoft.CmdPal.UI.ViewModels/SettingsModel.cs` | إعدادات Spotlight الجديدة وحدودها |
| `Microsoft.CmdPal.UI.ViewModels/SettingsViewModel.cs` | ربط الإعدادات بواجهة صفحة الإعدادات وزر Reset |
| `Microsoft.CmdPal.UI/Settings/AppearancePage.xaml(.cs)` | مجموعة "Spotlight search bar style" |
| `Microsoft.CmdPal.UI/Pages/ShellPage.xaml(.cs)` | حجم الخط وارتفاع الشريط وعدد الأسطر وإخفاء الأيقونة والشريط السفلي |
| `Microsoft.CmdPal.UI/Controls/SearchBar.xaml(.cs)` | خاصية `SearchFontSize` لمربع البحث |
| `Microsoft.CmdPal.UI/ExtViews/ListItemsView.xaml` و `Converters/ListItemContainerStyleSelector.cs` | إخفاء عناوين المجموعات |
| `Microsoft.CmdPal.UI/MainWindow.xaml.cs` | استدارة الزوايا |
| `Microsoft.CmdPal.UI/Strings/en-us/Resources.resw` | نصوص الإعدادات |
| `Tests/.../SettingsServiceTests.cs` | اختبارات للقيم الافتراضية والحدود |

## الترخيص

PowerToys مرخّص بموجب [MIT](https://github.com/microsoft/PowerToys/blob/main/LICENSE)، والتعديلات هنا بالترخيص نفسه.

</div>
