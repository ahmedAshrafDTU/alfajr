# SecurePortal — دليل التوثيق والمواصفات التقنية الشاملة للمشروع (Comprehensive Technical Documentation)

> **الغرض من هذا الملف:** توفير مرجع تقني مفصل وشامل بنسبة 100% لكافة جوانب المشروع المعمارية، البرمجية، الأمنية، وقواعد البيانات لتقديمه لنماذج الذكاء الاصطناعي (مثل ChatGPT) أو مطوري الـ Backend للمراجعة، التطوير، واقتراح أحدث الممارسات.

---

## 1. نبذة عامة عن المشروع (Executive Summary)

**اسم المشروع:** SecurePortal (بوابة الاشتراكات والمصادقة المتقدمة)  
**نوع المشروع:** Enterprise SaaS & Membership Management Platform (منصة اشتراكات وخدمات مع لوحة تحكم إدارية ومصادقة متعددة المراحل وواجهات RESTful API).  
**الهدف الأساسي:** توفير نظام متكامل ومحكم أمنياً لإدارة المستخدمين، الاشتراكات الدورية (Subscriptions)، بوابات الدفع (PayPal)، الفواتير (Invoicing)، الكوبونات والخصومات (Coupons & Discounts)، مع نظام مصادقة هجين يجمع بين OTP عبر البريد الإلكتروني و Laravel Sanctum للـ API، مع سجل تدقيق أمني مفصل (Audit Logging).

---

## 2. حزمة التقنيات المستخدمة (Tech Stack & Environment)

* **لغة البرمجة وبيئة التشغيل:** PHP 8.3+
* **إطار العمل الرئيسي:** Laravel 11 / 13
* **نظام إدارة قواعد البيانات:** MySQL 8.0+ (InnoDB, UTF8mb4)
* **واجهات المستخدم (Web Frontend):** Blade Templates + Tailwind CSS + Alpine.js / Vite
* **مصادقة الـ API:** Laravel Sanctum (Personal Access Tokens)
* **إدارة الصلاحيات والأدوار:** Spatie Laravel Permission (Roles & Permissions)
* **بوابة الدفع:** PayPal REST API SDK / v2 Checkout API (Orders & Captures & Webhooks)
* **تصدير الفواتير:** Barryvdh Laravel DomPDF
* **أدوات التطوير المحلية:** Laragon / Composer / NPM / PHPUnit

---

## 3. المعمارية البرمجية وهيكل المشروع (Architecture & Design Patterns)

المشروع مبني باتباع نمط **Clean Layered Architecture (Service-Repository / Action-Oriented)** داخل معمارية Laravel MVC:

1. **Controllers Layer (`app/Http/Controllers/`):**
   * **Web Controllers:** إدارة طلبات المتصفح مع حماية الجلسات (Sessions & CSRF).
   * **Admin Controllers (`app/Http/Controllers/Admin/`):** لوحة تحكم الإدارة وعمليات الـ CRUD.
   * **API Controllers (`app/Http/Controllers/Api/`):** واجهات RESTful ترجع JSON موحد باستخدام API Resources.
   * **Webhook Controller (`app/Http/Controllers/WebhookController.php`):** استقبال ومعالجة أحداث PayPal الخارجية بصورة غير متزامنة مع فحص التوقيع الرقمي (Signature Verification).
2. **Business Logic & Services Layer (`app/Services/`):**
   * عزل منطق الأعمال تماماً عن المتحكمات (Controllers) لسهولة الاختبار وإعادة الاستخدام.
   * تشمل: `OtpService`, `PayPalService`, `SubscriptionService`, `CouponService`, `InvoiceService`, `SettingService`, `AuditLogService`.
3. **Security & Middleware Pipeline (`app/Http/Middleware/`):**
   * فلترة وتأمين الطلبات (Rate Limiting, Security Headers, Role Check, Subscription Verification).
4. **Data Access & Eloquent Models (`app/Models/`):**
   * نماذج مترابطة بعلاقات Eloquent قوية مع Soft Deletes و Scopes و Mutators.
5. **Form Requests & Validation (`app/Http/Requests/`):**
   * عزل عمليات التحقق من صحة البيانات (Validation) وقواعد الأمان لكل طلب منفصل.
6. **Authorization Policies (`app/Policies/`):**
   * حماية الموارد على مستوى الكود باستخدام Laravel Gate & Spatie Permissions.
7. **Scheduled Jobs & Commands (`app/Console/Commands/`):**
   * أتمتة العمليات الدورية (انتهاء الاشتراكات، تذكيرات البريد، تنظيف السجلات والـ OTPs).

---

## 4. المكونات والأنظمة التفصيلية (Core Subsystems)

### 4.1. نظام المصادقة المتقدم والأمان (Authentication & Security)

* **آلية التسجيل والدخول (2FA Email OTP):**
  1. المستخدم يدخل بريده الإلكتروني وكلمة المرور.
  2. يقوم النظام بفحص الاعتمادات وحالة الحساب (`is_active`).
  3. يتم توليد رمز OTP عشوائي وآمن مكون من 6 أرقام.
  4. يتم تخزين الرمز بصيغة **Hash مشفرة** فقط في جدول `otp_verifications` (لا يُحفظ الرمز خاماً لحماية البيانات).
  5. يتم إرسال الرمز للمستخدم عبر البريد الإلكتروني (`SendOtpMail`).
  6. نافذة الصلاحية: 5 دقائق فقط. الحد الأقصى للمحاولات الخاطئة: 5 محاولات قبل حظر الرمز.
  7. بعد التحقق بنجاح: يتم تدمير الرمز، تسجيل وقت الدخول و الـ IP، وإنشاء الجلسة (`Auth::login`).
* **Rate Limiting مخصص للـ Brute Force (`RateLimitLogin`):**
  * تقييد عدد محاولات الدخول والتسجيل وطلب الـ OTP لكل عنوان IP وبريد إلكتروني.
  * تسجيل أي محاولات مشبوهة أو تجاوز للحدود تلقائياً في سجل التدقيق (`AuditLog`).
* **ترويسات الأمان الصارمة (`SecurityHeaders` Middleware):**
  * `X-Frame-Options: SAMEORIGIN` (حماية من Clickjacking).
  * `X-Content-Type-Options: nosniff` (منع MIME-sniffing).
  * `X-XSS-Protection: 1; mode=block`.
  * `Referrer-Policy: strict-origin-when-cross-origin`.
  * `Content-Security-Policy` و `Permissions-Policy`.
  * `Strict-Transport-Security` (HSTS) للاتصالات المشفرة.
* **التحكم بالوصول:**
  * `EnsureAdmin`: التحقق من رتبة المسؤول وتوثيق أي محاولة دخول غير مصرح بها.
  * `EnsureSubscription`: التحقق من وجود اشتراك نشط أو خطة معينة قبل السماح بدخول صفحات الخدمة المدفوعة.

---

### 4.2. نظام الأدوار والصلاحيات (Spatie Laravel Permission)

* **الأدوار الافتراضية (Roles):**
  * `admin`: يمتلك كامل الصلاحيات لإدارة المستخدمين، الاشتراكات، الخطط، الكوبونات، الفواتير، الإعدادات، وسجلات الأمان.
  * `user`: المستخدم العادي، يمتلك صلاحيات إدارة حسابه الشخصي، الاشتراك في الخطط، الدفع، واستعراض فواتيره.
* **مجموعات الصلاحيات (Permissions):**
  * `users.view`, `users.create`, `users.edit`, `users.delete`
  * `roles.view`, `roles.create`, `roles.edit`, `roles.delete`
  * `permissions.view`, `permissions.create`, `permissions.edit`, `permissions.delete`
  * `plans.view`, `plans.create`, `plans.edit`, `plans.delete`
  * `payments.view`, `payments.refund`
  * `coupons.view`, `coupons.create`, `coupons.edit`, `coupons.delete`
  * `invoices.view`, `invoices.download`
  * `audit-logs.view`
  * `settings.view`, `settings.edit`

---

### 4.3. نظام الخطط والاشتراكات (Plans & Subscriptions)

* **نموذج الخطط (`Plan`):**
  * يدعم فترات الفوترة: شهري (`monthly`)، سنوي (`yearly`).
  * الحقول: `name`, `slug`, `description`, `price`, `currency`, `billing_cycle`, `features` (مصفوفة JSON للمميزات)، `is_active`, `trial_period_days`.
  * الخطط الافتراضية: Free ($0)، Basic ($9.99/mo)، Premium ($29.99/mo)، Enterprise ($99.99/mo).
* **نموذج الاشتراكات (`Subscription`):**
  * يربط المستخدم بالخطة مع تواريخ البدء والانتهاء (`starts_at`, `ends_at`, `trial_ends_at`, `canceled_at`).
  * الحالات (`status`): `active`, `trialing`, `past_due`, `canceled`, `expired`.
  * دوال مساعدة في `User`:
    * `hasActiveSubscription()`
    * `onPlan($planSlug)`
    * `activeSubscription()`

---

### 4.4. بوابة الدفع والتكامل مع PayPal (PayPal Payments & Webhooks)

* **دورة الدفع (Payment Flow):**
  1. اختيار الخطة وتطبيق الكوبون إن وجد.
  2. إنشاء طلب دفع في PayPal عبر `PayPalService::createOrder()`.
  3. تسجيل عملية دفع بحالة `pending` في جدول `payments`.
  4. توجيه العميل لرابط الموافقة في PayPal (`approval_url`).
  5. عند العودة (`/payments/paypal/capture`): يتم التقاط المبلغ عبر `PayPalService::capturePayment()`.
  6. عند نجاح الالتقاط:
     * تحديث حالة الدفع إلى `completed`.
     * إنشاء أو تجديد اشتراك المستخدم (`SubscriptionService::createOrRenew()`).
     * إنشاء فاتورة رسمية للمستخدم (`InvoiceService::generate()`).
     * إرسال إشعار فوري بنجاح الدفع بالبريد وقاعدة البيانات (`PaymentSuccessNotification`).
     * تسجيل العملية في سجل التدقيق (`AuditLog`).
* **استرداد الأموال (Refunds):**
  * دعم استرداد كامل أو جزئي من لوحة تحكم المسؤول عبر `PayPalService::refundPayment()`.
  * تحديث حالة الدفع إلى `refunded` وتسجيل سبب الاسترداد.
* **معالج الـ Webhooks المتكامل (`WebhookController`):**
  * يستقبل إشعارات باي بال اللحظية دون انتظار عودة المتصفح:
    * `PAYMENT.CAPTURE.COMPLETED`
    * `PAYMENT.CAPTURE.DENIED` / `PAYMENT.CAPTURE.DECLINED`
    * `PAYMENT.CAPTURE.REFUNDED`
    * `CUSTOMER.DISPUTE.CREATED`
  * فحص التوقيع الرقمي عبر الـ Headers الرسمية لباي بال (`PAYPAL-TRANSMISSION-ID`, `PAYPAL-CERT-URL`, `PAYPAL-SIGNATURE`, etc.).

---

### 4.5. نظام الكوبونات والخصومات (Coupons & Discounts)

* **النموذج (`Coupon`):**
  * الأنواع: نسبة مئوية (`percentage`) أو خصم ثابت (`fixed`).
  * القيود: الحد الأقصى للاستخدام العام (`max_uses`)، الحد الأقصى للاستخدام لكل مستخدم (`max_uses_per_user`)، الحد الأدنى للطلب (`minimum_amount`)، تقييد خطط معينة (`applicable_plans`)، وتاريخ بداية ونهاية الصلاحية.
* **تتبع الاستخدام (`CouponUsage`):**
  * تسجيل كل عملية استخدام مربوطة بـ `user_id`, `coupon_id`, `payment_id`, والمبلغ المخصوم.
* **خدمة التحقق والتطبيق (`CouponService`):**
  * فحص صلاحية الكود، عدد المرات المستهلكة، انتهاء التاريخ، ومطابقة الشروط بدقة رياضية.

---

### 4.6. نظام الفواتير (Invoicing System)

* **النموذج (`Invoice`):**
  * رقم فاتورة تسلسلي فريد (مثال: `INV-2026-00001`).
  * تسجيل: بيانات العميل، الخطة، المبلغ الأصلي (Subtotal)، الخصم (Discount)، الضريبة (Tax)، الإجمالي (Total)، وبيانات الدفع.
* **خدمة الفواتير (`InvoiceService`):**
  * إنشاء تلقائي فور نجاح الدفع.
  * إنشاء ملف PDF بتصميم رسمي أنيق يضم شعار الشركة وبيانات الفوترة عبر `Barryvdh\DomPDF`.
  * إمكانية تحميل الفاتورة أو إرسالها مرفقة في البريد الإلكتروني.

---

### 4.7. واجهة البرمجة RESTful API (API Layer & Sanctum)

* **المصادقة:** مبنية على توكنات `Laravel Sanctum`.
* **نقاط النهاية العامة (Public Endpoints):**
  * `POST /api/auth/login`: تسجيل دخول أولي وإرسال OTP.
  * `POST /api/auth/register`: تسجيل حساب جديد وإرسال OTP للتفعيل.
  * `POST /api/auth/otp/verify`: إرسال الـ OTP والحصول على توكن الصلاحية (`Bearer Token`).
  * `GET /api/plans`: عرض الخطط المتاحة.
  * `GET /api/plans/{plan}`: عرض تفاصيل خطة محددة.
* **نقاط النهاية المحمية (`auth:sanctum`):**
  * `POST /api/auth/logout`: إبطال التوكن الحالي.
  * `POST /api/auth/logout-all`: إبطال جميع التوكنات لجميع الأجهزة.
  * `GET /api/user/profile`: جلب بيانات الملف الشخصي.
  * `PUT /api/user/profile`: تحديث الاسم والهاتف والصورة.
  * `PUT /api/user/password`: تغيير كلمة المرور.
  * `GET /api/subscription`: حالة الاشتراك الحالي وتفاصيل الخطة.
  * `POST /api/subscription/cancel`: إلغاء الاشتراك.
  * `GET /api/payments`: سجل عمليات الدفع السابقة.
  * `POST /api/payments/create`: بدء عملية دفع جديدة عبر باي بال (مع دعم الكوبون).
  * `GET /api/invoices`: قائمة الفواتير الخاصة بالمستخدم ورابط تحميلها.
* **توحيد المخرجات (API Resources):**
  * مخرجات مهيكلة وموحدة باستخدام: `UserResource`, `PlanResource`, `PaymentResource`, `SubscriptionResource`, `InvoiceResource`.

---

### 4.8. نظام الإشعارات والبريد (Notifications & Mails)

* قنوات الإرسال: البريد الإلكتروني (`mail`) + قاعدة البيانات (`database`).
* قائمة الإشعارات الجاهزة:
  1. `WelcomeNotification`: ترحيب بالمستخدم بعد تأكيد حسابه.
  2. `PaymentSuccessNotification`: إشعار بنجاح الدفع وتفاصيل الخطة ورقم الفاتورة.
  3. `PaymentFailedNotification`: تنبيه عند فشل عملية الدفع.
  4. `SubscriptionExpiringNotification`: تنبيه استباقي قبل انتهاء الاشتراك بـ 3 أيام لتجديده.
  5. `SubscriptionExpiredNotification`: إشعار عند انتهاء صلاحية الاشتراك وتوقف المزايا.
  6. `NewLoginNotification`: تنبيه أمني عند تسجيل الدخول من جهاز جديد أو عنوان IP مختلف.
  7. `ResetPasswordNotification`: رابط استعادة وتعيين كلمة المرور.

---

### 4.9. نظام سجل التدقيق الأمني (Audit Logging)

* **النموذج (`AuditLog`):**
  * الحقول: `user_id`, `event` (login, logout, payment, role_changed, settings_updated, etc.), `auditable_type`, `auditable_id`, `old_values` (JSON), `new_values` (JSON), `ip_address`, `user_agent`, `url`.
* **الخدمة (`AuditLogService`):**
  * تسجيل فوري لأي حدث حرج في النظام.
  * واجهة تصفح متقدمة للإدارة مع إمكانية الفلترة بالحدث أو المستخدم أو التاريخ.

---

### 4.10. المهام المجدولة والأتمتة (Scheduled Commands & Cron)

مسجلة في `routes/console.php`:
* `subscriptions:expire` (تشغيل يومي): فحص الاشتراكات المنتهية وتحديث حالتها إلى `expired` وإرسال إشعار للمستخدم.
* `subscriptions:remind-expiry` (تشغيل يومي): فحص الاشتراكات التي ستنتهي بعد 3 أيام وإرسال تنبيه للتجديد.
* `audit-logs:cleanup` (تشغيل أسبوعي): أرشفة أو حذف السجلات الأقدم من 90 يوماً للحفاظ على أداء وسرعة قاعدة البيانات.
* `otp:cleanup` (تشغيل كل ساعة): تنظيف وحذف رموز الـ OTP المنتهية صلاحيتها.

---

### 4.11. نظام الإعدادات الديناميكية (Dynamic Settings System)

* **النموذج (`Setting`):**
  * مخزن مفتاح-قيمة (`key`, `value`, `group`, `type`, `description`).
* **الخدمة (`SettingService`):**
  * مدعومة بنظام **Caching** تلقائي في الذاكرة لمنع الضغط على قاعدة البيانات عند قراءة الإعدادات في كل طلب.
  * تغطي إعدادات النظام: اسم المنصة، حالة الصيانة، مدة صلاحية الـ OTP، العملة الافتراضية، ومفاتيح بوابات الدفع.

---

## 5. هيكل قاعدة البيانات والجداول (Database Schema & Relationships)

```text
+------------------+         +------------------+         +-------------------+
|      users       |1       *|  subscriptions   |*       1|       plans       |
+------------------+---------+------------------+---------+-------------------+
| id               |         | id               |         | id                |
| name             |         | user_id (FK)     |         | name              |
| email            |         | plan_id (FK)     |         | slug              |
| password         |         | status           |         | price             |
| phone            |         | starts_at        |         | billing_cycle     |
| avatar           |         | ends_at          |         | features (JSON)   |
| is_active        |         | trial_ends_at    |         | is_active         |
| last_login_at    |         | canceled_at      |         +-------------------+
| last_login_ip    |         +------------------+
| deleted_at (Soft)|
+------------------+
         |1
         |
         |*
+------------------+         +------------------+         +-------------------+
|     payments     |1       1|     invoices     |         |      coupons      |
+------------------+---------+------------------+         +-------------------+
| id               |         | id               |         | id                |
| user_id (FK)     |         | user_id (FK)     |         | code              |
| plan_id (FK)     |         | payment_id (FK)  |         | type (percent/fix)|
| coupon_id (FK)   |         | invoice_number   |         | value             |
| transaction_id   |         | subtotal         |         | max_uses          |
| amount           |         | discount         |         | uses_count        |
| currency         |         | total            |         | valid_until       |
| status           |         | status           |         +-------------------+
| payment_method   |         | pdf_path         |                   |1
+------------------+         +------------------+                   |
                                                                    |*
+----------------------+     +----------------------+     +-------------------+
|   otp_verifications  |     |      audit_logs      |     |   coupon_usages   |
+----------------------+     +----------------------+     +-------------------+
| id                   |     | id                   |     | id                |
| email                |     | user_id (FK)         |     | coupon_id (FK)    |
| otp_hash             |     | event                |     | user_id (FK)      |
| expires_at           |     | auditable_type       |     | payment_id (FK)   |
| attempts             |     | old_values (JSON)    |     | discount_amount   |
+----------------------+     | new_values (JSON)    |     +-------------------+
                             | ip_address           |
                             +----------------------+
```

---

## 6. شجرة وهيكل مجلدات المشروع (Directory Map)

```text
SecurePortal/
├── app/
│   ├── Console/
│   │   └── Commands/
│   │       ├── CleanupAuditLogs.php
│   │       ├── CleanupExpiredOtps.php
│   │       ├── ExpireSubscriptions.php
│   │       └── SendExpiryReminders.php
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── Admin/
│   │   │   │   ├── AuditLogController.php
│   │   │   │   ├── CouponController.php
│   │   │   │   ├── DashboardController.php
│   │   │   │   ├── InvoiceController.php
│   │   │   │   ├── PaymentController.php
│   │   │   │   ├── PermissionController.php
│   │   │   │   ├── PlanController.php
│   │   │   │   ├── RoleController.php
│   │   │   │   ├── SettingController.php
│   │   │   │   └── UserController.php
│   │   │   ├── Api/
│   │   │   │   ├── AuthController.php
│   │   │   │   ├── PaymentController.php
│   │   │   │   ├── PlanController.php
│   │   │   │   ├── ProfileController.php
│   │   │   │   └── SubscriptionController.php
│   │   │   ├── Auth/
│   │   │   │   ├── ForgotPasswordController.php
│   │   │   │   ├── LoginController.php
│   │   │   │   ├── OtpController.php
│   │   │   │   ├── RegisterController.php
│   │   │   │   └── ResetPasswordController.php
│   │   │   ├── PayPalController.php
│   │   │   ├── ProfileController.php
│   │   │   ├── UserDashboardController.php
│   │   │   └── WebhookController.php
│   │   ├── Middleware/
│   │   │   ├── EnsureAdmin.php
│   │   │   ├── EnsureSubscription.php
│   │   │   ├── RateLimitLogin.php
│   │   │   └── SecurityHeaders.php
│   │   ├── Requests/ (StoreUserRequest, LoginRequest, VerifyOtpRequest, ...)
│   │   └── Resources/ (UserResource, PlanResource, PaymentResource, ...)
│   ├── Models/
│   │   ├── AuditLog.php
│   │   ├── Coupon.php
│   │   ├── CouponUsage.php
│   │   ├── Invoice.php
│   │   ├── OtpVerification.php
│   │   ├── Payment.php
│   │   ├── Plan.php
│   │   ├── Setting.php
│   │   ├── Subscription.php
│   │   └── User.php
│   ├── Notifications/ (PaymentSuccess, Expiring, Welcome, NewLogin, ...)
│   ├── Policies/ (UserPolicy, RolePolicy, PermissionPolicy, ...)
│   └── Services/
│       ├── AuditLogService.php
│       ├── CouponService.php
│       ├── InvoiceService.php
│       ├── OtpService.php
│       ├── PayPalService.php
│       ├── SettingService.php
│       └── SubscriptionService.php
├── config/
│   ├── paypal.php
│   └── permission.php
├── database/
│   ├── migrations/ (17 migrations تغطي الجداول والـ indexes)
│   └── seeders/
│       └── DatabaseSeeder.php (Seeds: Admin, User, Roles, Permissions, Plans, Coupons, Settings)
└── routes/
    ├── api.php (RESTful API routes)
    ├── console.php (Artisan schedule commands)
    └── web.php (Web frontend & Admin routes)
```

---

## 7. بيانات الدخول الافتراضية للاختبار (Default Credentials)

* **حساب المسؤول (Admin):**
  * البريد: `admin@example.com`
  * كلمة المرور: `password`
  * الدور: `admin` (صلاحيات غير مقيدة)
* **حساب المستخدم العادي (Normal User):**
  * البريد: `user@example.com`
  * كلمة المرور: `password`
  * الدور: `user`
* **الخطط الأولية المغروسة (Seeded Plans):**
  * Free ($0/mo), Basic ($9.99/mo), Premium ($29.99/mo), Enterprise ($99.99/mo).
* **كوبونات تجريبية مغروسة:**
  * `WELCOME50` (خصم 50% لمرة واحدة).
  * `LAUNCH2026` (خصم ثابت $10).

---

## 8. نقاط الاستشارة المقترحة لـ ChatGPT (Topics & Questions for ChatGPT)

> **ملاحظة للمستخدم:** يمكنك نسخ أي من الأسئلة التالية مباشرة إلى ChatGPT للاستفادة القصوى من خبرته في تحسين المشروع:

1. **المعمارية والأداء العالي (High Availability & Scalability):**
   * *كيف نحول معالجة الـ Webhooks وإرسال الإشعارات والبريد لتعتمد على Redis Queues و Laravel Horizon لتحمل آلاف المعاملات في الثانية دون تأخير؟*
2. **إضافة بوابات دفع إضافية (Multi-Gateway Architecture):**
   * *كيف نعيد هيكلة `PaymentService` لتتبع نمط الـ Strategy Pattern أو Adapter Pattern لدعم Stripe و Moyasar و Paymob بجانب PayPal بسلاسة؟*
3. **الأمان والاختراق (Penetration Testing & Security Hardening):**
   * *راجع نظام الـ OTP والـ Rate Limiting والـ Headers في هذا التوثيق؛ هل توجد أي ثغرات محتملة (مثل Race Conditions في استهلاك الكوبونات أو فحص الـ OTP) وكيف نحصنها باستخدام Database Transactions و Locks؟*
4. **تكامل تطبيقات الموبايل (Flutter / Mobile Integration):**
   * *ما هي أفضل الممارسات لربط تطبيق Flutter بهذه الـ APIs (Sanctum Tokens، معالجة الدفع عبر WebView أو Deep Links لباي بال، واستقبال الـ Push Notifications عبر Firebase FCM)؟*
5. **لوحة التحكم المتقدمة (Analytics & BI):**
   * *كيف نبني محرك تقارير مالية متقدم لحساب MRR (Monthly Recurring Revenue)، ARR، و Churn Rate، و LTV بدقة من جداول `subscriptions` و `payments`؟*
6. **استراتيجية الاختبار الشاملة (Testing Strategy):**
   * *اقترح قائمة Feature Tests و Unit Tests لاختبار كافة مسارات الفشل والنجاح لبوابة الدفع ونظام الـ Webhook مع Mocking لردود PayPal.*
