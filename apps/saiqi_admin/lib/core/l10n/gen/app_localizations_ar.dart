// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

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
