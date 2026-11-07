// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get adminBadge => 'تطبيق المشرف';

  @override
  String get noPermission => 'ليس لديك صلاحية لهذه الصفحة';

  @override
  String get more => 'المزيد';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get driversTitle => 'السائقون';

  @override
  String get bookingsTitle => 'الحجوزات';

  @override
  String get walletsTitle => 'المحافظ';

  @override
  String get kpiPendingDrivers => 'ملفات بانتظار المراجعة';

  @override
  String get kpiNewDrivers => 'سائقون جدد (7 أيام)';

  @override
  String get kpiApprovedDrivers => 'سائقون معتمدون';

  @override
  String get kpiClients => 'العملاء';

  @override
  String get kpiBookingsToday => 'حجوزات اليوم';

  @override
  String get kpiPendingBookings => 'حجوزات قيد الانتظار';

  @override
  String get kpiCommissionsToday => 'عمولات اليوم';

  @override
  String get kpiCommissionsTotal => 'إجمالي العمولات';

  @override
  String get kpiOpenComplaints => 'شكاوى مفتوحة';

  @override
  String get kpiPendingTopups => 'طلبات شحن معلقة';

  @override
  String get searchPeople => 'بحث بالاسم أو الرقم';

  @override
  String get driverDetail => 'ملف السائق';

  @override
  String get approveDriver => 'اعتماد السائق';

  @override
  String get rejectDriver => 'رفض الملف';

  @override
  String get rejectReasonTitle => 'سبب الرفض (يظهر للسائق)';

  @override
  String get driverApprovedMsg => 'تم اعتماد السائق';

  @override
  String get driverRejectedMsg => 'تم رفض الملف';

  @override
  String get suspendDriver => 'إيقاف السائق';

  @override
  String get reinstateDriver => 'إعادة تفعيل السائق';

  @override
  String get suspendReasonTitle => 'سبب الإيقاف';

  @override
  String get accountActions => 'إجراءات الحساب';

  @override
  String get suspendAccount => 'تعليق الحساب';

  @override
  String get blockAccount => 'حظر الحساب';

  @override
  String get reactivateAccount => 'إعادة تفعيل الحساب';

  @override
  String get accountStatusChanged => 'تم تحديث حالة الحساب';

  @override
  String get noDocuments => 'لم يرفع السائق مستندات بعد';

  @override
  String get noVehicle => 'لم تُسجَّل سيارة بعد';

  @override
  String get noServicesAdmin => 'لا توجد خدمات';

  @override
  String get approveDocument => 'قبول المستند';

  @override
  String get rejectDocument => 'رفض المستند';

  @override
  String get documentApprovedMsg => 'تم قبول المستند';

  @override
  String get documentRejectedMsg => 'تم رفض المستند';

  @override
  String get rejectDocReasonTitle => 'سبب رفض المستند';

  @override
  String get filterPending => 'بانتظار المراجعة';

  @override
  String documentsProgress(String count) {
    return '$count مستند';
  }

  @override
  String joinedOn(String date) {
    return 'انضم في $date';
  }

  @override
  String get driverNotFound => 'السائق غير موجود';

  @override
  String get filterStatus => 'الحالة';

  @override
  String get filterChannel => 'القناة';

  @override
  String get filterCity => 'المدينة';

  @override
  String get filterDate => 'التاريخ';

  @override
  String get clearFilters => 'مسح التصفية';

  @override
  String get bookingDetail => 'تفاصيل الحجز';

  @override
  String get noBookings => 'لا توجد حجوزات';

  @override
  String get offersSent => 'العروض المرسلة';

  @override
  String get offerStatus_pending => 'بانتظار الرد';

  @override
  String get offerStatus_accepted => 'قبل';

  @override
  String get offerStatus_declined => 'رفض';

  @override
  String get offerStatus_expired => 'منتهٍ';

  @override
  String get reassignDriver => 'تغيير السائق';

  @override
  String get reassignedMsg => 'تم إرسال الطلب للسائقين المختارين';

  @override
  String get cancelBookingAdmin => 'إلغاء الحجز';

  @override
  String get cancelReasonPrompt => 'سبب الإلغاء';

  @override
  String get bookingCancelledMsg => 'تم إلغاء الحجز';

  @override
  String get contactClient => 'اتصال بالعميل';

  @override
  String get contactDriver => 'اتصال بالسائق';

  @override
  String get guestClient => 'عميل بدون حساب';

  @override
  String get registeredClient => 'عميل مسجّل';

  @override
  String get noDriverAssigned => 'لم يُعيَّن سائق بعد';

  @override
  String get createRequest => 'إنشاء طلب';

  @override
  String get newRequest => 'طلب جديد لعميل';

  @override
  String get newRequestIntro =>
      'أنشئ طلبًا لعميل اتصل بك أو راسلك، ثم أرسله لسائق أو لعدة سائقين.';

  @override
  String get clientNameLabel => 'اسم العميل';

  @override
  String get clientPhoneLabel => 'هاتف العميل';

  @override
  String get agreedPriceField => 'السعر المتفق عليه (أوقية)';

  @override
  String get originChannel => 'قناة الطلب';

  @override
  String get chooseDrivers => 'اختر السائقين';

  @override
  String get driversInCityHint =>
      'السائقون المعتمدون الذين يقدمون هذه الخدمة في المدينة المختارة';

  @override
  String get onlyAvailable => 'المتاحون فقط';

  @override
  String get noDriversFound => 'لا يوجد سائقون مطابقون';

  @override
  String selectedCount(String count) {
    return '$count محدد';
  }

  @override
  String get selectAtLeastOneDriver => 'اختر سائقًا واحدًا على الأقل';

  @override
  String get sendRequest => 'إنشاء وإرسال الطلب';

  @override
  String get requestCreatedMsg => 'تم إنشاء الطلب وإرساله';

  @override
  String get multiDriverHint =>
      'عند اختيار عدة سائقين، الأول الذي يقبل يحصل على الطلب.';

  @override
  String get selectAll => 'تحديد الكل';

  @override
  String get topupsTitle => 'طلبات الشحن';

  @override
  String get noTopupsAdmin => 'لا توجد طلبات شحن';

  @override
  String get approveTopup => 'قبول الشحن';

  @override
  String get rejectTopup => 'رفض الشحن';

  @override
  String get topupApprovedMsg => 'تم شحن المحفظة';

  @override
  String get topupRejectedMsg => 'تم رفض الطلب';

  @override
  String get topupNoteHint => 'ملاحظة (اختياري)';

  @override
  String get proofImage => 'إثبات الدفع';

  @override
  String get noProof => 'لا يوجد إثبات';

  @override
  String get adjustWallet => 'تعديل الرصيد يدويًا';

  @override
  String get adjustAmountHint => 'مبلغ موجب للإضافة أو سالب للخصم';

  @override
  String get adjustNote => 'سبب التعديل';

  @override
  String get adjustDone => 'تم تعديل الرصيد';

  @override
  String get walletHistory => 'سجل المحفظة';

  @override
  String get driversWallets => 'محافظ السائقين';

  @override
  String get referenceLabel => 'المرجع';

  @override
  String get methodLabel => 'الطريقة';

  @override
  String get commissionsTitle => 'العمولات';

  @override
  String get defaultRate => 'النسبة الافتراضية';

  @override
  String get rateOverrides => 'نسب مخصصة';

  @override
  String get rateByService => 'حسب الخدمة';

  @override
  String get rateByCity => 'حسب المدينة';

  @override
  String get rateByServiceCity => 'حسب الخدمة والمدينة';

  @override
  String get addRate => 'إضافة نسبة';

  @override
  String get rateField => 'النسبة (%)';

  @override
  String get rateInvalid => 'أدخل نسبة بين 0 و 100';

  @override
  String get rateSaved => 'تم حفظ النسبة';

  @override
  String get rateNeedsScope => 'اختر خدمة أو مدينة أو كليهما';

  @override
  String get ratePriorityNote =>
      'الأولوية: خدمة+مدينة، ثم خدمة، ثم مدينة، ثم النسبة الافتراضية.';

  @override
  String get commissionHistory => 'سجل العمولات';

  @override
  String get noCommissions => 'لا توجد عمولات بعد';

  @override
  String get refundedLabel => 'مستردة';

  @override
  String get generalSettings => 'إعدادات عامة';

  @override
  String get responseTimeout => 'مهلة رد السائق (دقائق)';

  @override
  String get lowBalanceThresholdField => 'حد تنبيه الرصيد المنخفض (أوقية)';

  @override
  String get minTopupField => 'الحد الأدنى للشحن (أوقية)';

  @override
  String get supportPhoneField => 'هاتف الدعم';

  @override
  String get supportWhatsappField => 'واتساب الدعم';

  @override
  String get topupAccountsTitle => 'حسابات استلام الشحن';

  @override
  String get accountHint => 'رقم الحساب';

  @override
  String get settingsSaved => 'تم حفظ الإعدادات';

  @override
  String get complaintsTitle => 'الشكاوى';

  @override
  String get noComplaints => 'لا توجد شكاوى';

  @override
  String get complaintDetail => 'تفاصيل الشكوى';

  @override
  String get complaintAuthor => 'المُبلِّغ';

  @override
  String get complaintAgainst => 'المشكو منه';

  @override
  String get resolutionField => 'القرار / الرد';

  @override
  String get markInReview => 'قيد المعالجة';

  @override
  String get resolveComplaint => 'تمت المعالجة';

  @override
  String get dismissComplaint => 'حفظ الشكوى';

  @override
  String get complaintUpdatedMsg => 'تم تحديث الشكوى';

  @override
  String get warnUser => 'إرسال تنبيه';

  @override
  String get warnMessageHint => 'نص التنبيه';

  @override
  String get warnSentMsg => 'تم إرسال التنبيه';

  @override
  String get warningTitle => 'تنبيه من الإدارة';

  @override
  String get reviewsModeration => 'مراجعة التقييمات';

  @override
  String get hideReview => 'إخفاء';

  @override
  String get showReview => 'إظهار';

  @override
  String get reviewHidden => 'مخفي';

  @override
  String get noReviewsAdmin => 'لا توجد تقييمات';

  @override
  String reviewFor(String name) {
    return 'عن السائق $name';
  }

  @override
  String get clientsTitle => 'العملاء';

  @override
  String get noClients => 'لا يوجد عملاء';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get newPasswordPrompt => 'كلمة المرور الجديدة (8 أحرف على الأقل)';

  @override
  String get passwordResetDone => 'تمت إعادة تعيين كلمة المرور';

  @override
  String get userDetail => 'تفاصيل الحساب';

  @override
  String get catalogTitle => 'المدن والخدمات';

  @override
  String get citiesTitle => 'المدن';

  @override
  String get servicesTitle => 'الخدمات';

  @override
  String get addCity => 'إضافة مدينة';

  @override
  String get editCity => 'تعديل المدينة';

  @override
  String get addServiceType => 'إضافة خدمة';

  @override
  String get editServiceType => 'تعديل الخدمة';

  @override
  String get nameArField => 'الاسم بالعربية';

  @override
  String get nameFrField => 'الاسم بالفرنسية';

  @override
  String get iconField => 'الأيقونة';

  @override
  String get activeField => 'مفعّل';

  @override
  String get deleteBlocked =>
      'تعذّر الحذف لوجود بيانات مرتبطة. عطّله بدلًا من ذلك.';

  @override
  String get deleteConfirm => 'حذف نهائي؟';

  @override
  String get teamTitle => 'فريق الإدارة';

  @override
  String get addMember => 'إضافة عضو';

  @override
  String get roleField => 'الدور';

  @override
  String get memberCreated => 'تم إنشاء الحساب';

  @override
  String get changeRole => 'تغيير الدور';

  @override
  String get roleChanged => 'تم تغيير الدور';

  @override
  String get roleSuperAdminDesc => 'كل الصلاحيات';

  @override
  String get roleValidatorDesc => 'مراجعة ملفات السائقين';

  @override
  String get roleSupportDesc => 'الحجوزات والشحن والشكاوى والعملاء';

  @override
  String get auditTitle => 'سجل التدقيق';

  @override
  String get noAudit => 'لا توجد عمليات مسجلة';

  @override
  String by(String name) {
    return 'بواسطة $name';
  }

  @override
  String get announcementsTitle => 'الإعلانات';

  @override
  String get newAnnouncement => 'إعلان جديد';

  @override
  String get audienceField => 'الفئة المستهدفة';

  @override
  String get announcementTitleField => 'العنوان';

  @override
  String get announcementBodyField => 'النص';

  @override
  String get announcementSentMsg => 'تم إرسال الإعلان';

  @override
  String recipientsCount(String count) {
    return '$count مستلم';
  }

  @override
  String get noAnnouncements => 'لا توجد إعلانات';

  @override
  String get audit_approve_driver => 'اعتماد سائق';

  @override
  String get audit_reject_driver => 'رفض ملف سائق';

  @override
  String get audit_review_document => 'مراجعة مستند';

  @override
  String get audit_set_driver_status => 'تغيير حالة سائق';

  @override
  String get audit_set_account_status => 'تغيير حالة حساب';

  @override
  String get audit_set_admin_role => 'تغيير دور مشرف';

  @override
  String get audit_review_topup => 'معالجة طلب شحن';

  @override
  String get audit_adjust_wallet => 'تعديل رصيد';

  @override
  String get audit_create_booking => 'إنشاء طلب';

  @override
  String get audit_reassign_booking => 'تغيير سائق حجز';

  @override
  String get audit_cancel_booking => 'إلغاء حجز';

  @override
  String get audit_handle_complaint => 'معالجة شكوى';

  @override
  String get audit_moderate_review => 'إدارة تقييم';

  @override
  String get audit_send_announcement => 'إرسال إعلان';

  @override
  String get audit_reset_password => 'إعادة تعيين كلمة مرور';

  @override
  String get audit_create_admin => 'إنشاء مشرف';

  @override
  String get audit_warn_user => 'تنبيه مستخدم';

  @override
  String get audit_insert => 'إضافة';

  @override
  String get audit_update => 'تعديل';

  @override
  String get audit_delete => 'حذف';

  @override
  String get phoneLabel => 'رقم الهاتف';

  @override
  String get phoneHint => 'مثال: 36 12 34 56';

  @override
  String get phonePrefix => '+222';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get noAccountYet => 'ليس لديك حساب؟';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'هل تريد تسجيل الخروج؟';

  @override
  String get loginTitle => 'مرحبًا بعودتك';

  @override
  String get loginSubtitle => 'سجّل الدخول برقم هاتفك وكلمة المرور';

  @override
  String get registerTitle => 'إنشاء حساب جديد';

  @override
  String get registerSubtitle => 'أدخل رقم هاتفك واختر كلمة مرور';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get passwordChanged => 'تم تغيير كلمة المرور';

  @override
  String get passwordHint => '8 أحرف على الأقل';

  @override
  String get vFieldRequired => 'هذا الحقل مطلوب';

  @override
  String get vPhoneInvalid => 'أدخل رقمًا موريتانيًا صحيحًا من 8 أرقام';

  @override
  String get vPasswordMin => 'كلمة المرور 8 أحرف على الأقل';

  @override
  String get vPasswordsMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get vNumberInvalid => 'أدخل رقمًا صحيحًا';

  @override
  String get vAmountPositive => 'أدخل مبلغًا أكبر من صفر';

  @override
  String get accountSuspendedTitle => 'الحساب موقوف';

  @override
  String get accountSuspendedBody =>
      'تم تعليق حسابك. تواصل مع الدعم لمزيد من المعلومات.';

  @override
  String get accountBlockedBody =>
      'تم حظر حسابك. تواصل مع الدعم لمزيد من المعلومات.';

  @override
  String get roleDriver => 'سائق';

  @override
  String get roleClient => 'عميل';

  @override
  String get roleAdmin => 'مشرف';

  @override
  String get appName => 'سائقي';

  @override
  String get appTagline => 'سائقك الموثوق في موريتانيا';

  @override
  String get ok => 'موافق';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get close => 'إغلاق';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get confirm => 'تأكيد';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get search => 'بحث';

  @override
  String get filters => 'تصفية';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get apply => 'تطبيق';

  @override
  String get reset => 'إعادة ضبط';

  @override
  String get done => 'تم';

  @override
  String get send => 'إرسال';

  @override
  String get submit => 'إرسال';

  @override
  String get refresh => 'تحديث';

  @override
  String get details => 'التفاصيل';

  @override
  String get call => 'اتصال';

  @override
  String get whatsapp => 'واتساب';

  @override
  String get copy => 'نسخ';

  @override
  String get copied => 'تم النسخ';

  @override
  String get select => 'اختيار';

  @override
  String get change => 'تغيير';

  @override
  String get optional => 'اختياري';

  @override
  String get all => 'الكل';

  @override
  String get none => 'لا شيء';

  @override
  String get today => 'اليوم';

  @override
  String get tomorrow => 'غدًا';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get somethingWrong => 'حدث خطأ ما';

  @override
  String get currencyMru => 'أوقية';

  @override
  String amountMru(String amount) {
    return '$amount أوقية';
  }

  @override
  String get pickPhoto => 'اختيار صورة';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get fromGallery => 'من المعرض';

  @override
  String get photoUploaded => 'تم رفع الصورة';

  @override
  String get uploading => 'جارٍ الرفع…';

  @override
  String get viewDocument => 'عرض المستند';

  @override
  String get pinchToZoom => 'قرّب بإصبعين للتكبير';

  @override
  String get language => 'اللغة';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageFrench => 'Français';

  @override
  String get chooseLanguage => 'اختر لغتك';

  @override
  String get theme => 'المظهر';

  @override
  String get themeSystem => 'حسب النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get settings => 'الإعدادات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get home => 'الرئيسية';

  @override
  String get help => 'المساعدة';

  @override
  String get contactSupport => 'اتصل بالدعم';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get markAllRead => 'تعيين الكل كمقروء';

  @override
  String get newNotification => 'إشعار جديد';

  @override
  String get notificationChannelName => 'إشعارات سائقي';

  @override
  String get day => 'يوم';

  @override
  String get minutesShort => 'د';

  @override
  String get secondsShort => 'ث';

  @override
  String expiresIn(String time) {
    return 'ينتهي خلال $time';
  }

  @override
  String get expired => 'انتهت المهلة';

  @override
  String dateTimeAt(String date, String time) {
    return '$date - $time';
  }

  @override
  String get confirmActionTitle => 'تأكيد العملية';

  @override
  String get areYouSure => 'هل أنت متأكد؟';

  @override
  String get configMissingTitle => 'إعداد ناقص';

  @override
  String get configMissingBody =>
      'لم يتم تحديد SUPABASE_URL و SUPABASE_PUBLISHABLE_KEY. شغّل التطبيق مع --dart-define-from-file=.env';

  @override
  String get driverBadge => 'تطبيق السائق';

  @override
  String get saved => 'تم الحفظ';

  @override
  String get applicationTitle => 'ملف السائق';

  @override
  String get applicationIntro =>
      'أكمل ملفك ليراجعه فريقنا. التسجيل مجاني، وتُحتسب عمولة فقط على كل خدمة تقبلها.';

  @override
  String get stepPersonal => 'المعلومات الشخصية';

  @override
  String get stepDocuments => 'المستندات';

  @override
  String get stepVehicle => 'السيارة';

  @override
  String get stepServices => 'الخدمات والأسعار';

  @override
  String get stepAvailability => 'أوقات العمل';

  @override
  String get stepComplete => 'مكتمل';

  @override
  String get stepTodo => 'غير مكتمل';

  @override
  String get stepOptional => 'اختياري';

  @override
  String get submitApplication => 'إرسال الملف للمراجعة';

  @override
  String get submitApplicationConfirm =>
      'بعد الإرسال لن تتمكن من التعديل حتى تتم المراجعة.';

  @override
  String get applicationSubmitted => 'تم إرسال ملفك. سنراجعه قريبًا.';

  @override
  String get applicationRejectedTitle => 'تم رفض ملفك';

  @override
  String get applicationRejectedHint => 'صحّح ما يلزم ثم أعد إرسال الملف.';

  @override
  String missingItems(String items) {
    return 'ينقص: $items';
  }

  @override
  String get yearsExperienceLabel => 'سنوات الخبرة';

  @override
  String get bioLabel => 'نبذة عنك';

  @override
  String get bioHint => 'مثال: سائق محترف أعرف المدينة جيدًا…';

  @override
  String get profilePhoto => 'الصورة الشخصية';

  @override
  String get changePhoto => 'تغيير الصورة';

  @override
  String get cityOfWork => 'مدينة العمل الرئيسية';

  @override
  String get documentsIntro => 'التقط صورًا واضحة ومقروءة لكل مستند.';

  @override
  String docRejectedReason(String reason) {
    return 'مرفوض: $reason';
  }

  @override
  String get vehicleTitle => 'معلومات السيارة';

  @override
  String get vehicleType => 'نوع السيارة';

  @override
  String get vehicleBrand => 'الماركة';

  @override
  String get vehicleModel => 'الطراز';

  @override
  String get vehicleYear => 'سنة الصنع';

  @override
  String get vehicleColor => 'اللون';

  @override
  String get vehicleSeats => 'عدد المقاعد';

  @override
  String get vehiclePlate => 'رقم اللوحة';

  @override
  String get vehiclePhotos => 'صور السيارة';

  @override
  String get addVehiclePhoto => 'إضافة صورة';

  @override
  String get maxPhotosReached => 'الحد الأقصى 5 صور.';

  @override
  String get servicesIntro => 'اختر الخدمات التي تقدمها ومدنها وسعر كل منها.';

  @override
  String get addService => 'إضافة خدمة';

  @override
  String get editService => 'تعديل الخدمة';

  @override
  String get serviceCities => 'المدن التي تخدمها';

  @override
  String get servicePriceField => 'السعر (أوقية)';

  @override
  String get priceUnitField => 'وحدة السعر';

  @override
  String get serviceActive => 'مفعّلة';

  @override
  String get noServicesYet => 'لم تضف أي خدمة بعد';

  @override
  String get noServicesHint => 'أضف خدمة واحدة على الأقل لتظهر للعملاء.';

  @override
  String get deleteServiceConfirm => 'حذف هذه الخدمة؟';

  @override
  String get selectAtLeastOneCity => 'اختر مدينة واحدة على الأقل';

  @override
  String get serviceAlreadyAdded => 'هذه الخدمة مضافة مسبقًا';

  @override
  String get availabilityIntro => 'حدد الأيام والساعات التي تعمل فيها.';

  @override
  String get dayOff => 'عطلة';

  @override
  String get timeFrom => 'من';

  @override
  String get timeTo => 'إلى';

  @override
  String get invalidTimeRange => 'وقت النهاية يجب أن يكون بعد البداية';

  @override
  String get pendingTitle => 'ملفك قيد المراجعة';

  @override
  String get pendingBody =>
      'يراجع فريق سائقي ملفك. سنخبرك فور اعتماده وستنتقل الشاشة تلقائيًا.';

  @override
  String pendingSince(String date) {
    return 'أُرسل في $date';
  }

  @override
  String get suspendedTitle => 'حسابك موقوف';

  @override
  String get suspendedBody =>
      'تم تعليق حسابك مؤقتًا. تواصل مع الدعم لمعرفة التفاصيل.';

  @override
  String hello(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String get availabilityOn => 'أنت متاح لاستقبال الطلبات';

  @override
  String get availabilityOff => 'أنت غير متاح حاليًا';

  @override
  String get availabilityToggleHint => 'فعّل الزر لتصلك الطلبات الجديدة.';

  @override
  String get walletBalance => 'رصيد المحفظة';

  @override
  String get lowBalanceWarning =>
      'رصيدك منخفض. اشحن محفظتك حتى لا تفوتك الطلبات.';

  @override
  String get topUp => 'شحن المحفظة';

  @override
  String get incomingRequests => 'الطلبات الواردة';

  @override
  String get noIncomingRequests => 'لا توجد طلبات حاليًا';

  @override
  String get noIncomingHint => 'ستظهر الطلبات الجديدة هنا فورًا.';

  @override
  String get upcomingTrips => 'رحلاتك القادمة';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get requestDetails => 'تفاصيل الطلب';

  @override
  String get commissionLabel => 'العمولة';

  @override
  String get acceptRequest => 'قبول الطلب';

  @override
  String get rejectRequest => 'رفض';

  @override
  String commissionNotice(String amount, String rate) {
    return 'ستُخصم عمولة $amount ($rate) من محفظتك عند القبول.';
  }

  @override
  String balanceAfterAccept(String amount) {
    return 'رصيدك بعد القبول: $amount';
  }

  @override
  String insufficientBalanceBlock(String balance, String commission) {
    return 'رصيدك ($balance) لا يكفي لعمولة هذا الطلب ($commission). اشحن محفظتك لتتمكن من القبول.';
  }

  @override
  String get rechargeToAccept => 'شحن المحفظة';

  @override
  String get requestAccepted => 'تم قبول الطلب';

  @override
  String get requestRejectedMsg => 'تم رفض الطلب';

  @override
  String get rejectConfirm => 'هل تريد رفض هذا الطلب؟';

  @override
  String get requestGone => 'لم يعد هذا الطلب متاحًا.';

  @override
  String get requestedBy => 'طلب من';

  @override
  String get clientPaysDriver =>
      'يدفع العميل المبلغ للسائق مباشرة (نقدًا أو دفع هاتفي).';

  @override
  String get firstAcceptWins =>
      'أُرسل هذا الطلب لعدة سائقين، والأول الذي يقبل يحصل عليه.';

  @override
  String get myTrips => 'رحلاتي';

  @override
  String get tripsUpcoming => 'القادمة';

  @override
  String get tripsHistory => 'السابقة';

  @override
  String get noTrips => 'لا توجد رحلات';

  @override
  String get tripDetails => 'تفاصيل الرحلة';

  @override
  String get startEnRoute => 'أنا في الطريق';

  @override
  String get startTrip => 'بدء الرحلة';

  @override
  String get finishTrip => 'إنهاء الرحلة';

  @override
  String get cancelTrip => 'إلغاء الرحلة';

  @override
  String get cancelTripConfirm => 'ستُرجع العمولة إلى محفظتك. هل تريد الإلغاء؟';

  @override
  String get tripCancelled => 'تم إلغاء الرحلة';

  @override
  String get statusUpdated => 'تم تحديث الحالة';

  @override
  String get clientContact => 'التواصل مع العميل';

  @override
  String get scheduledFor => 'الموعد';

  @override
  String get agreedPrice => 'السعر';

  @override
  String get commissionDeducted => 'العمولة المخصومة';

  @override
  String get wallet => 'المحفظة';

  @override
  String get transactions => 'العمليات';

  @override
  String get noTransactions => 'لا توجد عمليات بعد';

  @override
  String get topupRequests => 'طلبات الشحن';

  @override
  String get noTopups => 'لا توجد طلبات شحن';

  @override
  String get requestTopup => 'طلب شحن';

  @override
  String get topupAmount => 'المبلغ (أوقية)';

  @override
  String get topupMethod => 'طريقة الدفع';

  @override
  String get topupReference => 'رقم العملية / المرجع';

  @override
  String get topupProof => 'صورة إثبات التحويل';

  @override
  String get topupSubmitted => 'تم إرسال طلب الشحن. سيُعتمد قريبًا.';

  @override
  String get topupHowTo =>
      'أرسل المبلغ إلى أحد الحسابات التالية ثم أرفق إثبات التحويل.';

  @override
  String minTopup(String amount) {
    return 'الحد الأدنى للشحن: $amount';
  }

  @override
  String get accountNumber => 'الحساب';

  @override
  String balanceAfterTx(String amount) {
    return 'الرصيد: $amount';
  }

  @override
  String get howCommissionWorks =>
      'تُخصم العمولة من رصيدك عند قبول كل خدمة، وتُسترجع إذا أُلغيت.';

  @override
  String get noAccountConfigured => 'لم يحدد المشرف حسابات الدفع بعد.';

  @override
  String get refInPayment => 'رقم الحساب منسوخ';

  @override
  String get myProfile => 'ملفي';

  @override
  String get statistics => 'الإحصاءات';

  @override
  String get completedTrips => 'رحلات منجزة';

  @override
  String get revenueGross => 'المبالغ المحصّلة';

  @override
  String get commissionsPaid => 'العمولات المدفوعة';

  @override
  String get revenueNet => 'الصافي';

  @override
  String get ratingLabel => 'التقييم';

  @override
  String get reviewsReceived => 'التقييمات المستلمة';

  @override
  String get noReviewsYet => 'لا توجد تقييمات بعد';

  @override
  String get publicProfile => 'ملفي العام';

  @override
  String get publicProfileHint => 'هذا ما يراه العملاء عنك.';

  @override
  String get editPersonalInfo => 'تعديل المعلومات';

  @override
  String get myDocuments => 'مستنداتي';

  @override
  String get helpAndReport => 'المساعدة والإبلاغ';

  @override
  String get reportProblem => 'الإبلاغ عن مشكلة';

  @override
  String get reportHint => 'صِف المشكلة بالتفصيل…';

  @override
  String get reportSent => 'تم إرسال بلاغك. سنتواصل معك.';

  @override
  String get contactSupportCall => 'اتصال بالدعم';

  @override
  String get contactSupportWhatsapp => 'واتساب الدعم';

  @override
  String get tapToEdit => 'اضغط للتعديل';

  @override
  String get bookingStatus_pending => 'قيد الانتظار';

  @override
  String get bookingStatus_accepted => 'مقبول';

  @override
  String get bookingStatus_enRoute => 'السائق في الطريق';

  @override
  String get bookingStatus_inProgress => 'الرحلة جارية';

  @override
  String get bookingStatus_completed => 'منتهية';

  @override
  String get bookingStatus_cancelled => 'ملغاة';

  @override
  String get bookingStatus_rejected => 'مرفوضة';

  @override
  String get bookingStatus_expired => 'انتهت المهلة';

  @override
  String get driverStatus_draft => 'مسودة';

  @override
  String get driverStatus_pending => 'قيد المراجعة';

  @override
  String get driverStatus_approved => 'معتمد';

  @override
  String get driverStatus_rejected => 'مرفوض';

  @override
  String get driverStatus_suspended => 'موقوف';

  @override
  String get accountStatus_active => 'نشط';

  @override
  String get accountStatus_suspended => 'موقوف';

  @override
  String get accountStatus_blocked => 'محظور';

  @override
  String get documentType_idCard => 'بطاقة التعريف';

  @override
  String get documentType_drivingLicense => 'رخصة القيادة';

  @override
  String get documentType_vehicleRegistration => 'البطاقة الرمادية';

  @override
  String get documentType_insurance => 'التأمين';

  @override
  String get documentType_photo => 'صورة شخصية';

  @override
  String get documentStatus_pending => 'قيد المراجعة';

  @override
  String get documentStatus_approved => 'مقبول';

  @override
  String get documentStatus_rejected => 'مرفوض';

  @override
  String get channel_app => 'التطبيق';

  @override
  String get channel_phone => 'هاتف';

  @override
  String get channel_whatsapp => 'واتساب';

  @override
  String get channel_other => 'أخرى';

  @override
  String get txType_topup => 'شحن';

  @override
  String get txType_commission => 'عمولة';

  @override
  String get txType_refund => 'استرجاع عمولة';

  @override
  String get txType_adjustment => 'تعديل';

  @override
  String get topupStatus_pending => 'قيد المراجعة';

  @override
  String get topupStatus_approved => 'مقبول';

  @override
  String get topupStatus_rejected => 'مرفوض';

  @override
  String get complaintStatus_open => 'مفتوحة';

  @override
  String get complaintStatus_inReview => 'قيد المعالجة';

  @override
  String get complaintStatus_resolved => 'تمت المعالجة';

  @override
  String get complaintStatus_dismissed => 'مرفوضة';

  @override
  String get priceUnit_perTrip => 'للرحلة';

  @override
  String get priceUnit_perHour => 'للساعة';

  @override
  String get priceUnit_perDay => 'لليوم';

  @override
  String get priceUnitLabel_perTrip => 'السعر للرحلة';

  @override
  String get priceUnitLabel_perHour => 'السعر للساعة';

  @override
  String get priceUnitLabel_perDay => 'السعر لليوم';

  @override
  String get adminRole_superAdmin => 'مشرف عام';

  @override
  String get adminRole_validator => 'مدقق ملفات';

  @override
  String get adminRole_support => 'دعم';

  @override
  String get vehicleType_sedan => 'سيدان';

  @override
  String get vehicleType_suv => 'سيارة دفع (SUV)';

  @override
  String get vehicleType_4x4 => 'دفع رباعي';

  @override
  String get vehicleType_van => 'فان';

  @override
  String get vehicleType_minibus => 'حافلة صغيرة';

  @override
  String get vehicleType_bus => 'حافلة';

  @override
  String get vehicleType_pickup => 'بيك أب';

  @override
  String get weekday_1 => 'الإثنين';

  @override
  String get weekday_2 => 'الثلاثاء';

  @override
  String get weekday_3 => 'الأربعاء';

  @override
  String get weekday_4 => 'الخميس';

  @override
  String get weekday_5 => 'الجمعة';

  @override
  String get weekday_6 => 'السبت';

  @override
  String get weekday_7 => 'الأحد';

  @override
  String get audience_drivers => 'السائقون';

  @override
  String get audience_clients => 'العملاء';

  @override
  String get audience_all => 'الجميع';

  @override
  String get sort_rating => 'الأعلى تقييمًا';

  @override
  String get sort_priceAsc => 'الأرخص أولًا';

  @override
  String get sort_priceDesc => 'الأغلى أولًا';

  @override
  String get sort_trips => 'الأكثر رحلات';

  @override
  String get err_unknown => 'حدث خطأ غير متوقع. حاول مرة أخرى.';

  @override
  String get err_network_error =>
      'تعذر الاتصال بالإنترنت. تحقق من الشبكة وحاول مجددًا.';

  @override
  String get err_session_expired => 'انتهت الجلسة. سجّل الدخول من جديد.';

  @override
  String get err_permission_denied => 'غير مسموح لك بهذه العملية.';

  @override
  String get err_invalid_credentials => 'رقم الهاتف أو كلمة المرور غير صحيحة.';

  @override
  String get err_phone_already_registered => 'هذا الرقم مسجَّل مسبقًا.';

  @override
  String get err_invalid_phone => 'رقم الهاتف غير صالح.';

  @override
  String get err_password_too_short =>
      'كلمة المرور يجب أن تكون 8 أحرف على الأقل.';

  @override
  String get err_signup_failed =>
      'تعذر إنشاء الحساب. تحقق من البيانات وحاول مجددًا.';

  @override
  String get err_account_suspended => 'حسابك موقوف. تواصل مع الدعم.';

  @override
  String get err_account_blocked => 'حسابك محظور. تواصل مع الدعم.';

  @override
  String get err_wrong_app_role => 'هذا الحساب غير مخصص لهذا التطبيق.';

  @override
  String get err_not_authenticated => 'يجب تسجيل الدخول أولًا.';

  @override
  String get err_not_client => 'هذه العملية مخصصة للعملاء.';

  @override
  String get err_not_driver => 'هذه العملية مخصصة للسائقين.';

  @override
  String get err_driver_not_available => 'السائق غير متاح حاليًا.';

  @override
  String get err_service_not_offered =>
      'هذا السائق لا يقدم هذه الخدمة في المدينة المختارة.';

  @override
  String get err_pickup_required => 'أدخل مكان الانطلاق.';

  @override
  String get err_invalid_schedule => 'اختر موعدًا صالحًا.';

  @override
  String get err_invalid_passengers => 'عدد الركاب غير صالح.';

  @override
  String get err_too_many_passengers => 'عدد الركاب يتجاوز مقاعد السيارة.';

  @override
  String get err_too_many_pending =>
      'لديك طلبات كثيرة قيد الانتظار. انتظر الردود أولًا.';

  @override
  String get err_invalid_service_or_city => 'الخدمة أو المدينة غير صالحة.';

  @override
  String get err_booking_not_found => 'الحجز غير موجود.';

  @override
  String get err_booking_not_available =>
      'لم يعد هذا الطلب متاحًا (قبله سائق آخر أو أُلغي).';

  @override
  String get err_booking_expired => 'انتهت مهلة هذا الطلب.';

  @override
  String get err_offer_not_available => 'هذا العرض لم يعد متاحًا.';

  @override
  String get err_insufficient_balance =>
      'رصيد محفظتك غير كافٍ لدفع العمولة. اشحن محفظتك أولًا.';

  @override
  String err_insufficient_balance_detail(String balance, String required) {
    return 'رصيدك $balance أوقية والعمولة المطلوبة $required أوقية.';
  }

  @override
  String get err_driver_not_approved => 'لم يتم اعتماد حسابك كسائق بعد.';

  @override
  String get err_wallet_not_found => 'المحفظة غير موجودة.';

  @override
  String get err_invalid_transition => 'لا يمكن تغيير الحالة إلى هذه المرحلة.';

  @override
  String get err_not_allowed => 'غير مسموح لك بهذه العملية.';

  @override
  String get err_booking_not_cancellable => 'لا يمكن إلغاء هذا الحجز.';

  @override
  String get err_cancel_not_allowed_after_en_route =>
      'لا يمكن الإلغاء بعد انطلاق السائق.';

  @override
  String get err_contact_not_available => 'رقم الهاتف يظهر بعد قبول الطلب فقط.';

  @override
  String get err_amount_too_low => 'المبلغ أقل من الحد الأدنى للشحن.';

  @override
  String get err_method_required => 'اختر طريقة الدفع.';

  @override
  String get err_invalid_path => 'ملف غير صالح.';

  @override
  String get err_booking_not_completed => 'يمكن التقييم بعد انتهاء الرحلة فقط.';

  @override
  String get err_already_reviewed => 'لقد قيّمت هذه الرحلة من قبل.';

  @override
  String get err_invalid_rating => 'اختر تقييمًا من 1 إلى 5.';

  @override
  String get err_text_too_short => 'النص قصير جدًا.';

  @override
  String get err_text_required => 'أدخل العنوان والنص.';

  @override
  String get err_invalid_driver_status => 'حالة السائق لا تسمح بهذه العملية.';

  @override
  String get err_application_incomplete =>
      'الملف غير مكتمل. أكمل البيانات المطلوبة قبل الإرسال.';

  @override
  String get err_reason_required => 'السبب مطلوب.';

  @override
  String get err_admin_forbidden => 'صلاحياتك لا تسمح بهذه العملية.';

  @override
  String get err_driver_not_found => 'السائق غير موجود.';

  @override
  String get err_document_not_found => 'المستند غير موجود.';

  @override
  String get err_topup_not_found => 'طلب الشحن غير موجود.';

  @override
  String get err_topup_already_reviewed => 'تمت معالجة هذا الطلب مسبقًا.';

  @override
  String get err_invalid_amount => 'المبلغ غير صالح.';

  @override
  String get err_client_name_required => 'اسم العميل مطلوب.';

  @override
  String get err_invalid_channel => 'قناة الطلب غير صالحة.';

  @override
  String get err_invalid_price => 'السعر غير صالح.';

  @override
  String get err_drivers_required => 'اختر سائقًا واحدًا على الأقل (حتى 20).';

  @override
  String get err_booking_not_reassignable => 'لا يمكن تغيير سائق هذا الحجز.';

  @override
  String get err_complaint_not_found => 'الشكوى غير موجودة.';

  @override
  String get err_review_not_found => 'التقييم غير موجود.';

  @override
  String get err_invalid_audience => 'الفئة المستهدفة غير صالحة.';

  @override
  String get err_cannot_modify_self => 'لا يمكنك تعديل حسابك بنفسك من هنا.';

  @override
  String get err_profile_not_found => 'الحساب غير موجود.';

  @override
  String get err_upload_failed => 'فشل رفع الملف. حاول مجددًا.';

  @override
  String get err_name_required => 'الاسم مطلوب.';

  @override
  String get err_invalid_admin_role => 'دور المشرف غير صالح.';

  @override
  String get err_server_not_configured => 'الخادم غير مهيأ بعد.';

  @override
  String get err_create_user_failed => 'تعذر إنشاء الحساب.';

  @override
  String get err_invalid_token => 'انتهت الجلسة. سجّل الدخول من جديد.';

  @override
  String get err_missing_token => 'يجب تسجيل الدخول.';

  @override
  String get err_internal_error => 'خطأ في الخادم. حاول لاحقًا.';

  @override
  String get err_duplicate => 'هذا العنصر موجود مسبقًا.';

  @override
  String get err_rate_limited => 'محاولات كثيرة. انتظر قليلًا ثم حاول مجددًا.';

  @override
  String get city => 'المدينة';

  @override
  String get cities => 'المدن';

  @override
  String get serviceType => 'نوع الخدمة';

  @override
  String get dateAndTime => 'التاريخ والوقت';

  @override
  String get pickup => 'مكان الانطلاق';

  @override
  String get dropoff => 'الوجهة';

  @override
  String get passengers => 'عدد الركاب';

  @override
  String get notes => 'ملاحظات';

  @override
  String get price => 'السعر';

  @override
  String get client => 'العميل';

  @override
  String get driver => 'السائق';

  @override
  String get status => 'الحالة';

  @override
  String get channel => 'القناة';

  @override
  String get createdBy => 'أنشأه';

  @override
  String get createdByAdmin => 'أنشأه المشرف';

  @override
  String get reason => 'السبب';

  @override
  String get reasonHint => 'اكتب السبب';

  @override
  String get verified => 'موثّق';

  @override
  String get availableNow => 'متاح الآن';

  @override
  String get unavailableNow => 'غير متاح';

  @override
  String seatsCount(String count) {
    return '$count مقاعد';
  }

  @override
  String tripsCount(String count) {
    return '$count رحلة';
  }

  @override
  String yearsExperience(String count) {
    return '$count سنوات خبرة';
  }

  @override
  String reviewsCount(String count) {
    return '$count تقييم';
  }

  @override
  String get noRatingYet => 'جديد';

  @override
  String fromPrice(String price) {
    return 'ابتداءً من $price';
  }

  @override
  String priceWithUnit(String price, String unit) {
    return '$price $unit';
  }

  @override
  String get documentUploaded => 'تم الرفع';

  @override
  String get documentMissing => 'لم يُرفع بعد';

  @override
  String get documentReplace => 'استبدال';

  @override
  String get documentView => 'عرض';

  @override
  String get documentRequired => 'مطلوب';

  @override
  String get imageLoadFailed => 'تعذر تحميل الصورة';

  @override
  String get openNotification => 'فتح';

  @override
  String get notificationsEmptyHint => 'ستظهر هنا تنبيهات حجوزاتك ومحفظتك.';

  @override
  String get welcomeContinue => 'متابعة';

  @override
  String get splashLoading => 'جارٍ التحميل…';

  @override
  String get signedInAs => 'مسجّل الدخول باسم';

  @override
  String get supportNotConfigured => 'رقم الدعم غير متوفر حاليًا.';

  @override
  String get cannotOpenLink => 'تعذر فتح الرابط.';
}
