import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('fr'),
  ];

  /// No description provided for @phoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: 36 12 34 56'**
  String get phoneHint;

  /// No description provided for @phonePrefix.
  ///
  /// In ar, this message translates to:
  /// **'+222'**
  String get phonePrefix;

  /// No description provided for @passwordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPasswordLabel;

  /// No description provided for @fullNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullNameLabel;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @register.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get register;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get alreadyHaveAccount;

  /// No description provided for @noAccountYet.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get noAccountYet;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تسجيل الخروج؟'**
  String get logoutConfirm;

  /// No description provided for @loginTitle.
  ///
  /// In ar, this message translates to:
  /// **'مرحبًا بعودتك'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول برقم هاتفك وكلمة المرور'**
  String get loginSubtitle;

  /// No description provided for @registerTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتفك واختر كلمة مرور'**
  String get registerSubtitle;

  /// No description provided for @changePassword.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور الجديدة'**
  String get confirmNewPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير كلمة المرور'**
  String get passwordChanged;

  /// No description provided for @passwordHint.
  ///
  /// In ar, this message translates to:
  /// **'8 أحرف على الأقل'**
  String get passwordHint;

  /// No description provided for @vFieldRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get vFieldRequired;

  /// No description provided for @vPhoneInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقمًا موريتانيًا صحيحًا من 8 أرقام'**
  String get vPhoneInvalid;

  /// No description provided for @vPasswordMin.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور 8 أحرف على الأقل'**
  String get vPasswordMin;

  /// No description provided for @vPasswordsMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get vPasswordsMismatch;

  /// No description provided for @vNumberInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقمًا صحيحًا'**
  String get vNumberInvalid;

  /// No description provided for @vAmountPositive.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مبلغًا أكبر من صفر'**
  String get vAmountPositive;

  /// No description provided for @accountSuspendedTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحساب موقوف'**
  String get accountSuspendedTitle;

  /// No description provided for @accountSuspendedBody.
  ///
  /// In ar, this message translates to:
  /// **'تم تعليق حسابك. تواصل مع الدعم لمزيد من المعلومات.'**
  String get accountSuspendedBody;

  /// No description provided for @accountBlockedBody.
  ///
  /// In ar, this message translates to:
  /// **'تم حظر حسابك. تواصل مع الدعم لمزيد من المعلومات.'**
  String get accountBlockedBody;

  /// No description provided for @roleDriver.
  ///
  /// In ar, this message translates to:
  /// **'سائق'**
  String get roleDriver;

  /// No description provided for @roleClient.
  ///
  /// In ar, this message translates to:
  /// **'عميل'**
  String get roleClient;

  /// No description provided for @roleAdmin.
  ///
  /// In ar, this message translates to:
  /// **'مشرف'**
  String get roleAdmin;

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'سائقي'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In ar, this message translates to:
  /// **'سائقك الموثوق في موريتانيا'**
  String get appTagline;

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'موافق'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get no;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @filters.
  ///
  /// In ar, this message translates to:
  /// **'تصفية'**
  String get filters;

  /// No description provided for @sortBy.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب حسب'**
  String get sortBy;

  /// No description provided for @apply.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In ar, this message translates to:
  /// **'إعادة ضبط'**
  String get reset;

  /// No description provided for @done.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get done;

  /// No description provided for @send.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get send;

  /// No description provided for @submit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get submit;

  /// No description provided for @refresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get refresh;

  /// No description provided for @details.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get details;

  /// No description provided for @call.
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get call;

  /// No description provided for @whatsapp.
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get whatsapp;

  /// No description provided for @copy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In ar, this message translates to:
  /// **'تم النسخ'**
  String get copied;

  /// No description provided for @select.
  ///
  /// In ar, this message translates to:
  /// **'اختيار'**
  String get select;

  /// No description provided for @change.
  ///
  /// In ar, this message translates to:
  /// **'تغيير'**
  String get change;

  /// No description provided for @optional.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get optional;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @none.
  ///
  /// In ar, this message translates to:
  /// **'لا شيء'**
  String get none;

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In ar, this message translates to:
  /// **'غدًا'**
  String get tomorrow;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل…'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get noData;

  /// No description provided for @somethingWrong.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ ما'**
  String get somethingWrong;

  /// No description provided for @currencyMru.
  ///
  /// In ar, this message translates to:
  /// **'أوقية'**
  String get currencyMru;

  /// No description provided for @amountMru.
  ///
  /// In ar, this message translates to:
  /// **'{amount} أوقية'**
  String amountMru(String amount);

  /// No description provided for @pickPhoto.
  ///
  /// In ar, this message translates to:
  /// **'اختيار صورة'**
  String get pickPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In ar, this message translates to:
  /// **'التقاط صورة'**
  String get takePhoto;

  /// No description provided for @fromGallery.
  ///
  /// In ar, this message translates to:
  /// **'من المعرض'**
  String get fromGallery;

  /// No description provided for @photoUploaded.
  ///
  /// In ar, this message translates to:
  /// **'تم رفع الصورة'**
  String get photoUploaded;

  /// No description provided for @uploading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الرفع…'**
  String get uploading;

  /// No description provided for @viewDocument.
  ///
  /// In ar, this message translates to:
  /// **'عرض المستند'**
  String get viewDocument;

  /// No description provided for @pinchToZoom.
  ///
  /// In ar, this message translates to:
  /// **'قرّب بإصبعين للتكبير'**
  String get pinchToZoom;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageFrench.
  ///
  /// In ar, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @chooseLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر لغتك'**
  String get chooseLanguage;

  /// No description provided for @theme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In ar, this message translates to:
  /// **'حسب النظام'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get themeDark;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @help.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة'**
  String get help;

  /// No description provided for @contactSupport.
  ///
  /// In ar, this message translates to:
  /// **'اتصل بالدعم'**
  String get contactSupport;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In ar, this message translates to:
  /// **'تعيين الكل كمقروء'**
  String get markAllRead;

  /// No description provided for @newNotification.
  ///
  /// In ar, this message translates to:
  /// **'إشعار جديد'**
  String get newNotification;

  /// No description provided for @notificationChannelName.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات سائقي'**
  String get notificationChannelName;

  /// No description provided for @day.
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get day;

  /// No description provided for @minutesShort.
  ///
  /// In ar, this message translates to:
  /// **'د'**
  String get minutesShort;

  /// No description provided for @secondsShort.
  ///
  /// In ar, this message translates to:
  /// **'ث'**
  String get secondsShort;

  /// No description provided for @expiresIn.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي خلال {time}'**
  String expiresIn(String time);

  /// No description provided for @expired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت المهلة'**
  String get expired;

  /// No description provided for @dateTimeAt.
  ///
  /// In ar, this message translates to:
  /// **'{date} - {time}'**
  String dateTimeAt(String date, String time);

  /// No description provided for @confirmActionTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد العملية'**
  String get confirmActionTitle;

  /// No description provided for @areYouSure.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد؟'**
  String get areYouSure;

  /// No description provided for @configMissingTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعداد ناقص'**
  String get configMissingTitle;

  /// No description provided for @configMissingBody.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تحديد SUPABASE_URL و SUPABASE_PUBLISHABLE_KEY. شغّل التطبيق مع --dart-define-from-file=.env'**
  String get configMissingBody;

  /// No description provided for @bookingStatus_pending.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get bookingStatus_pending;

  /// No description provided for @bookingStatus_accepted.
  ///
  /// In ar, this message translates to:
  /// **'مقبول'**
  String get bookingStatus_accepted;

  /// No description provided for @bookingStatus_enRoute.
  ///
  /// In ar, this message translates to:
  /// **'السائق في الطريق'**
  String get bookingStatus_enRoute;

  /// No description provided for @bookingStatus_inProgress.
  ///
  /// In ar, this message translates to:
  /// **'الرحلة جارية'**
  String get bookingStatus_inProgress;

  /// No description provided for @bookingStatus_completed.
  ///
  /// In ar, this message translates to:
  /// **'منتهية'**
  String get bookingStatus_completed;

  /// No description provided for @bookingStatus_cancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get bookingStatus_cancelled;

  /// No description provided for @bookingStatus_rejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوضة'**
  String get bookingStatus_rejected;

  /// No description provided for @bookingStatus_expired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت المهلة'**
  String get bookingStatus_expired;

  /// No description provided for @driverStatus_draft.
  ///
  /// In ar, this message translates to:
  /// **'مسودة'**
  String get driverStatus_draft;

  /// No description provided for @driverStatus_pending.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get driverStatus_pending;

  /// No description provided for @driverStatus_approved.
  ///
  /// In ar, this message translates to:
  /// **'معتمد'**
  String get driverStatus_approved;

  /// No description provided for @driverStatus_rejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get driverStatus_rejected;

  /// No description provided for @driverStatus_suspended.
  ///
  /// In ar, this message translates to:
  /// **'موقوف'**
  String get driverStatus_suspended;

  /// No description provided for @accountStatus_active.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get accountStatus_active;

  /// No description provided for @accountStatus_suspended.
  ///
  /// In ar, this message translates to:
  /// **'موقوف'**
  String get accountStatus_suspended;

  /// No description provided for @accountStatus_blocked.
  ///
  /// In ar, this message translates to:
  /// **'محظور'**
  String get accountStatus_blocked;

  /// No description provided for @documentType_idCard.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة التعريف'**
  String get documentType_idCard;

  /// No description provided for @documentType_drivingLicense.
  ///
  /// In ar, this message translates to:
  /// **'رخصة القيادة'**
  String get documentType_drivingLicense;

  /// No description provided for @documentType_vehicleRegistration.
  ///
  /// In ar, this message translates to:
  /// **'البطاقة الرمادية'**
  String get documentType_vehicleRegistration;

  /// No description provided for @documentType_insurance.
  ///
  /// In ar, this message translates to:
  /// **'التأمين'**
  String get documentType_insurance;

  /// No description provided for @documentType_photo.
  ///
  /// In ar, this message translates to:
  /// **'صورة شخصية'**
  String get documentType_photo;

  /// No description provided for @documentStatus_pending.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get documentStatus_pending;

  /// No description provided for @documentStatus_approved.
  ///
  /// In ar, this message translates to:
  /// **'مقبول'**
  String get documentStatus_approved;

  /// No description provided for @documentStatus_rejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get documentStatus_rejected;

  /// No description provided for @channel_app.
  ///
  /// In ar, this message translates to:
  /// **'التطبيق'**
  String get channel_app;

  /// No description provided for @channel_phone.
  ///
  /// In ar, this message translates to:
  /// **'هاتف'**
  String get channel_phone;

  /// No description provided for @channel_whatsapp.
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get channel_whatsapp;

  /// No description provided for @channel_other.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get channel_other;

  /// No description provided for @txType_topup.
  ///
  /// In ar, this message translates to:
  /// **'شحن'**
  String get txType_topup;

  /// No description provided for @txType_commission.
  ///
  /// In ar, this message translates to:
  /// **'عمولة'**
  String get txType_commission;

  /// No description provided for @txType_refund.
  ///
  /// In ar, this message translates to:
  /// **'استرجاع عمولة'**
  String get txType_refund;

  /// No description provided for @txType_adjustment.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get txType_adjustment;

  /// No description provided for @topupStatus_pending.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get topupStatus_pending;

  /// No description provided for @topupStatus_approved.
  ///
  /// In ar, this message translates to:
  /// **'مقبول'**
  String get topupStatus_approved;

  /// No description provided for @topupStatus_rejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get topupStatus_rejected;

  /// No description provided for @complaintStatus_open.
  ///
  /// In ar, this message translates to:
  /// **'مفتوحة'**
  String get complaintStatus_open;

  /// No description provided for @complaintStatus_inReview.
  ///
  /// In ar, this message translates to:
  /// **'قيد المعالجة'**
  String get complaintStatus_inReview;

  /// No description provided for @complaintStatus_resolved.
  ///
  /// In ar, this message translates to:
  /// **'تمت المعالجة'**
  String get complaintStatus_resolved;

  /// No description provided for @complaintStatus_dismissed.
  ///
  /// In ar, this message translates to:
  /// **'مرفوضة'**
  String get complaintStatus_dismissed;

  /// No description provided for @priceUnit_perTrip.
  ///
  /// In ar, this message translates to:
  /// **'للرحلة'**
  String get priceUnit_perTrip;

  /// No description provided for @priceUnit_perHour.
  ///
  /// In ar, this message translates to:
  /// **'للساعة'**
  String get priceUnit_perHour;

  /// No description provided for @priceUnit_perDay.
  ///
  /// In ar, this message translates to:
  /// **'لليوم'**
  String get priceUnit_perDay;

  /// No description provided for @priceUnitLabel_perTrip.
  ///
  /// In ar, this message translates to:
  /// **'السعر للرحلة'**
  String get priceUnitLabel_perTrip;

  /// No description provided for @priceUnitLabel_perHour.
  ///
  /// In ar, this message translates to:
  /// **'السعر للساعة'**
  String get priceUnitLabel_perHour;

  /// No description provided for @priceUnitLabel_perDay.
  ///
  /// In ar, this message translates to:
  /// **'السعر لليوم'**
  String get priceUnitLabel_perDay;

  /// No description provided for @adminRole_superAdmin.
  ///
  /// In ar, this message translates to:
  /// **'مشرف عام'**
  String get adminRole_superAdmin;

  /// No description provided for @adminRole_validator.
  ///
  /// In ar, this message translates to:
  /// **'مدقق ملفات'**
  String get adminRole_validator;

  /// No description provided for @adminRole_support.
  ///
  /// In ar, this message translates to:
  /// **'دعم'**
  String get adminRole_support;

  /// No description provided for @vehicleType_sedan.
  ///
  /// In ar, this message translates to:
  /// **'سيدان'**
  String get vehicleType_sedan;

  /// No description provided for @vehicleType_suv.
  ///
  /// In ar, this message translates to:
  /// **'سيارة دفع (SUV)'**
  String get vehicleType_suv;

  /// No description provided for @vehicleType_4x4.
  ///
  /// In ar, this message translates to:
  /// **'دفع رباعي'**
  String get vehicleType_4x4;

  /// No description provided for @vehicleType_van.
  ///
  /// In ar, this message translates to:
  /// **'فان'**
  String get vehicleType_van;

  /// No description provided for @vehicleType_minibus.
  ///
  /// In ar, this message translates to:
  /// **'حافلة صغيرة'**
  String get vehicleType_minibus;

  /// No description provided for @vehicleType_bus.
  ///
  /// In ar, this message translates to:
  /// **'حافلة'**
  String get vehicleType_bus;

  /// No description provided for @vehicleType_pickup.
  ///
  /// In ar, this message translates to:
  /// **'بيك أب'**
  String get vehicleType_pickup;

  /// No description provided for @weekday_1.
  ///
  /// In ar, this message translates to:
  /// **'الإثنين'**
  String get weekday_1;

  /// No description provided for @weekday_2.
  ///
  /// In ar, this message translates to:
  /// **'الثلاثاء'**
  String get weekday_2;

  /// No description provided for @weekday_3.
  ///
  /// In ar, this message translates to:
  /// **'الأربعاء'**
  String get weekday_3;

  /// No description provided for @weekday_4.
  ///
  /// In ar, this message translates to:
  /// **'الخميس'**
  String get weekday_4;

  /// No description provided for @weekday_5.
  ///
  /// In ar, this message translates to:
  /// **'الجمعة'**
  String get weekday_5;

  /// No description provided for @weekday_6.
  ///
  /// In ar, this message translates to:
  /// **'السبت'**
  String get weekday_6;

  /// No description provided for @weekday_7.
  ///
  /// In ar, this message translates to:
  /// **'الأحد'**
  String get weekday_7;

  /// No description provided for @audience_drivers.
  ///
  /// In ar, this message translates to:
  /// **'السائقون'**
  String get audience_drivers;

  /// No description provided for @audience_clients.
  ///
  /// In ar, this message translates to:
  /// **'العملاء'**
  String get audience_clients;

  /// No description provided for @audience_all.
  ///
  /// In ar, this message translates to:
  /// **'الجميع'**
  String get audience_all;

  /// No description provided for @sort_rating.
  ///
  /// In ar, this message translates to:
  /// **'الأعلى تقييمًا'**
  String get sort_rating;

  /// No description provided for @sort_priceAsc.
  ///
  /// In ar, this message translates to:
  /// **'الأرخص أولًا'**
  String get sort_priceAsc;

  /// No description provided for @sort_priceDesc.
  ///
  /// In ar, this message translates to:
  /// **'الأغلى أولًا'**
  String get sort_priceDesc;

  /// No description provided for @sort_trips.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر رحلات'**
  String get sort_trips;

  /// No description provided for @err_unknown.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع. حاول مرة أخرى.'**
  String get err_unknown;

  /// No description provided for @err_network_error.
  ///
  /// In ar, this message translates to:
  /// **'تعذر الاتصال بالإنترنت. تحقق من الشبكة وحاول مجددًا.'**
  String get err_network_error;

  /// No description provided for @err_session_expired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الجلسة. سجّل الدخول من جديد.'**
  String get err_session_expired;

  /// No description provided for @err_permission_denied.
  ///
  /// In ar, this message translates to:
  /// **'غير مسموح لك بهذه العملية.'**
  String get err_permission_denied;

  /// No description provided for @err_invalid_credentials.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف أو كلمة المرور غير صحيحة.'**
  String get err_invalid_credentials;

  /// No description provided for @err_phone_already_registered.
  ///
  /// In ar, this message translates to:
  /// **'هذا الرقم مسجَّل مسبقًا.'**
  String get err_phone_already_registered;

  /// No description provided for @err_invalid_phone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف غير صالح.'**
  String get err_invalid_phone;

  /// No description provided for @err_password_too_short.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تكون 8 أحرف على الأقل.'**
  String get err_password_too_short;

  /// No description provided for @err_signup_failed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إنشاء الحساب. تحقق من البيانات وحاول مجددًا.'**
  String get err_signup_failed;

  /// No description provided for @err_account_suspended.
  ///
  /// In ar, this message translates to:
  /// **'حسابك موقوف. تواصل مع الدعم.'**
  String get err_account_suspended;

  /// No description provided for @err_account_blocked.
  ///
  /// In ar, this message translates to:
  /// **'حسابك محظور. تواصل مع الدعم.'**
  String get err_account_blocked;

  /// No description provided for @err_wrong_app_role.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحساب غير مخصص لهذا التطبيق.'**
  String get err_wrong_app_role;

  /// No description provided for @err_not_authenticated.
  ///
  /// In ar, this message translates to:
  /// **'يجب تسجيل الدخول أولًا.'**
  String get err_not_authenticated;

  /// No description provided for @err_not_client.
  ///
  /// In ar, this message translates to:
  /// **'هذه العملية مخصصة للعملاء.'**
  String get err_not_client;

  /// No description provided for @err_not_driver.
  ///
  /// In ar, this message translates to:
  /// **'هذه العملية مخصصة للسائقين.'**
  String get err_not_driver;

  /// No description provided for @err_driver_not_available.
  ///
  /// In ar, this message translates to:
  /// **'السائق غير متاح حاليًا.'**
  String get err_driver_not_available;

  /// No description provided for @err_service_not_offered.
  ///
  /// In ar, this message translates to:
  /// **'هذا السائق لا يقدم هذه الخدمة في المدينة المختارة.'**
  String get err_service_not_offered;

  /// No description provided for @err_pickup_required.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مكان الانطلاق.'**
  String get err_pickup_required;

  /// No description provided for @err_invalid_schedule.
  ///
  /// In ar, this message translates to:
  /// **'اختر موعدًا صالحًا.'**
  String get err_invalid_schedule;

  /// No description provided for @err_invalid_passengers.
  ///
  /// In ar, this message translates to:
  /// **'عدد الركاب غير صالح.'**
  String get err_invalid_passengers;

  /// No description provided for @err_too_many_passengers.
  ///
  /// In ar, this message translates to:
  /// **'عدد الركاب يتجاوز مقاعد السيارة.'**
  String get err_too_many_passengers;

  /// No description provided for @err_too_many_pending.
  ///
  /// In ar, this message translates to:
  /// **'لديك طلبات كثيرة قيد الانتظار. انتظر الردود أولًا.'**
  String get err_too_many_pending;

  /// No description provided for @err_invalid_service_or_city.
  ///
  /// In ar, this message translates to:
  /// **'الخدمة أو المدينة غير صالحة.'**
  String get err_invalid_service_or_city;

  /// No description provided for @err_booking_not_found.
  ///
  /// In ar, this message translates to:
  /// **'الحجز غير موجود.'**
  String get err_booking_not_found;

  /// No description provided for @err_booking_not_available.
  ///
  /// In ar, this message translates to:
  /// **'لم يعد هذا الطلب متاحًا (قبله سائق آخر أو أُلغي).'**
  String get err_booking_not_available;

  /// No description provided for @err_booking_expired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة هذا الطلب.'**
  String get err_booking_expired;

  /// No description provided for @err_offer_not_available.
  ///
  /// In ar, this message translates to:
  /// **'هذا العرض لم يعد متاحًا.'**
  String get err_offer_not_available;

  /// No description provided for @err_insufficient_balance.
  ///
  /// In ar, this message translates to:
  /// **'رصيد محفظتك غير كافٍ لدفع العمولة. اشحن محفظتك أولًا.'**
  String get err_insufficient_balance;

  /// No description provided for @err_insufficient_balance_detail.
  ///
  /// In ar, this message translates to:
  /// **'رصيدك {balance} أوقية والعمولة المطلوبة {required} أوقية.'**
  String err_insufficient_balance_detail(String balance, String required);

  /// No description provided for @err_driver_not_approved.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم اعتماد حسابك كسائق بعد.'**
  String get err_driver_not_approved;

  /// No description provided for @err_wallet_not_found.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة غير موجودة.'**
  String get err_wallet_not_found;

  /// No description provided for @err_invalid_transition.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن تغيير الحالة إلى هذه المرحلة.'**
  String get err_invalid_transition;

  /// No description provided for @err_not_allowed.
  ///
  /// In ar, this message translates to:
  /// **'غير مسموح لك بهذه العملية.'**
  String get err_not_allowed;

  /// No description provided for @err_booking_not_cancellable.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن إلغاء هذا الحجز.'**
  String get err_booking_not_cancellable;

  /// No description provided for @err_cancel_not_allowed_after_en_route.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن الإلغاء بعد انطلاق السائق.'**
  String get err_cancel_not_allowed_after_en_route;

  /// No description provided for @err_contact_not_available.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف يظهر بعد قبول الطلب فقط.'**
  String get err_contact_not_available;

  /// No description provided for @err_amount_too_low.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ أقل من الحد الأدنى للشحن.'**
  String get err_amount_too_low;

  /// No description provided for @err_method_required.
  ///
  /// In ar, this message translates to:
  /// **'اختر طريقة الدفع.'**
  String get err_method_required;

  /// No description provided for @err_invalid_path.
  ///
  /// In ar, this message translates to:
  /// **'ملف غير صالح.'**
  String get err_invalid_path;

  /// No description provided for @err_booking_not_completed.
  ///
  /// In ar, this message translates to:
  /// **'يمكن التقييم بعد انتهاء الرحلة فقط.'**
  String get err_booking_not_completed;

  /// No description provided for @err_already_reviewed.
  ///
  /// In ar, this message translates to:
  /// **'لقد قيّمت هذه الرحلة من قبل.'**
  String get err_already_reviewed;

  /// No description provided for @err_invalid_rating.
  ///
  /// In ar, this message translates to:
  /// **'اختر تقييمًا من 1 إلى 5.'**
  String get err_invalid_rating;

  /// No description provided for @err_text_too_short.
  ///
  /// In ar, this message translates to:
  /// **'النص قصير جدًا.'**
  String get err_text_too_short;

  /// No description provided for @err_text_required.
  ///
  /// In ar, this message translates to:
  /// **'أدخل العنوان والنص.'**
  String get err_text_required;

  /// No description provided for @err_invalid_driver_status.
  ///
  /// In ar, this message translates to:
  /// **'حالة السائق لا تسمح بهذه العملية.'**
  String get err_invalid_driver_status;

  /// No description provided for @err_application_incomplete.
  ///
  /// In ar, this message translates to:
  /// **'الملف غير مكتمل. أكمل البيانات المطلوبة قبل الإرسال.'**
  String get err_application_incomplete;

  /// No description provided for @err_reason_required.
  ///
  /// In ar, this message translates to:
  /// **'السبب مطلوب.'**
  String get err_reason_required;

  /// No description provided for @err_admin_forbidden.
  ///
  /// In ar, this message translates to:
  /// **'صلاحياتك لا تسمح بهذه العملية.'**
  String get err_admin_forbidden;

  /// No description provided for @err_driver_not_found.
  ///
  /// In ar, this message translates to:
  /// **'السائق غير موجود.'**
  String get err_driver_not_found;

  /// No description provided for @err_document_not_found.
  ///
  /// In ar, this message translates to:
  /// **'المستند غير موجود.'**
  String get err_document_not_found;

  /// No description provided for @err_topup_not_found.
  ///
  /// In ar, this message translates to:
  /// **'طلب الشحن غير موجود.'**
  String get err_topup_not_found;

  /// No description provided for @err_topup_already_reviewed.
  ///
  /// In ar, this message translates to:
  /// **'تمت معالجة هذا الطلب مسبقًا.'**
  String get err_topup_already_reviewed;

  /// No description provided for @err_invalid_amount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ غير صالح.'**
  String get err_invalid_amount;

  /// No description provided for @err_client_name_required.
  ///
  /// In ar, this message translates to:
  /// **'اسم العميل مطلوب.'**
  String get err_client_name_required;

  /// No description provided for @err_invalid_channel.
  ///
  /// In ar, this message translates to:
  /// **'قناة الطلب غير صالحة.'**
  String get err_invalid_channel;

  /// No description provided for @err_invalid_price.
  ///
  /// In ar, this message translates to:
  /// **'السعر غير صالح.'**
  String get err_invalid_price;

  /// No description provided for @err_drivers_required.
  ///
  /// In ar, this message translates to:
  /// **'اختر سائقًا واحدًا على الأقل (حتى 20).'**
  String get err_drivers_required;

  /// No description provided for @err_booking_not_reassignable.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن تغيير سائق هذا الحجز.'**
  String get err_booking_not_reassignable;

  /// No description provided for @err_complaint_not_found.
  ///
  /// In ar, this message translates to:
  /// **'الشكوى غير موجودة.'**
  String get err_complaint_not_found;

  /// No description provided for @err_review_not_found.
  ///
  /// In ar, this message translates to:
  /// **'التقييم غير موجود.'**
  String get err_review_not_found;

  /// No description provided for @err_invalid_audience.
  ///
  /// In ar, this message translates to:
  /// **'الفئة المستهدفة غير صالحة.'**
  String get err_invalid_audience;

  /// No description provided for @err_cannot_modify_self.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكنك تعديل حسابك بنفسك من هنا.'**
  String get err_cannot_modify_self;

  /// No description provided for @err_profile_not_found.
  ///
  /// In ar, this message translates to:
  /// **'الحساب غير موجود.'**
  String get err_profile_not_found;

  /// No description provided for @err_upload_failed.
  ///
  /// In ar, this message translates to:
  /// **'فشل رفع الملف. حاول مجددًا.'**
  String get err_upload_failed;

  /// No description provided for @err_name_required.
  ///
  /// In ar, this message translates to:
  /// **'الاسم مطلوب.'**
  String get err_name_required;

  /// No description provided for @err_invalid_admin_role.
  ///
  /// In ar, this message translates to:
  /// **'دور المشرف غير صالح.'**
  String get err_invalid_admin_role;

  /// No description provided for @err_server_not_configured.
  ///
  /// In ar, this message translates to:
  /// **'الخادم غير مهيأ بعد.'**
  String get err_server_not_configured;

  /// No description provided for @err_create_user_failed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إنشاء الحساب.'**
  String get err_create_user_failed;

  /// No description provided for @err_invalid_token.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الجلسة. سجّل الدخول من جديد.'**
  String get err_invalid_token;

  /// No description provided for @err_missing_token.
  ///
  /// In ar, this message translates to:
  /// **'يجب تسجيل الدخول.'**
  String get err_missing_token;

  /// No description provided for @err_internal_error.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الخادم. حاول لاحقًا.'**
  String get err_internal_error;

  /// No description provided for @err_duplicate.
  ///
  /// In ar, this message translates to:
  /// **'هذا العنصر موجود مسبقًا.'**
  String get err_duplicate;

  /// No description provided for @err_rate_limited.
  ///
  /// In ar, this message translates to:
  /// **'محاولات كثيرة. انتظر قليلًا ثم حاول مجددًا.'**
  String get err_rate_limited;

  /// No description provided for @verified.
  ///
  /// In ar, this message translates to:
  /// **'موثّق'**
  String get verified;

  /// No description provided for @availableNow.
  ///
  /// In ar, this message translates to:
  /// **'متاح الآن'**
  String get availableNow;

  /// No description provided for @unavailableNow.
  ///
  /// In ar, this message translates to:
  /// **'غير متاح'**
  String get unavailableNow;

  /// No description provided for @seatsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} مقاعد'**
  String seatsCount(String count);

  /// No description provided for @tripsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} رحلة'**
  String tripsCount(String count);

  /// No description provided for @yearsExperience.
  ///
  /// In ar, this message translates to:
  /// **'{count} سنوات خبرة'**
  String yearsExperience(String count);

  /// No description provided for @reviewsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} تقييم'**
  String reviewsCount(String count);

  /// No description provided for @noRatingYet.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get noRatingYet;

  /// No description provided for @fromPrice.
  ///
  /// In ar, this message translates to:
  /// **'ابتداءً من {price}'**
  String fromPrice(String price);

  /// No description provided for @priceWithUnit.
  ///
  /// In ar, this message translates to:
  /// **'{price} {unit}'**
  String priceWithUnit(String price, String unit);

  /// No description provided for @documentUploaded.
  ///
  /// In ar, this message translates to:
  /// **'تم الرفع'**
  String get documentUploaded;

  /// No description provided for @documentMissing.
  ///
  /// In ar, this message translates to:
  /// **'لم يُرفع بعد'**
  String get documentMissing;

  /// No description provided for @documentReplace.
  ///
  /// In ar, this message translates to:
  /// **'استبدال'**
  String get documentReplace;

  /// No description provided for @documentView.
  ///
  /// In ar, this message translates to:
  /// **'عرض'**
  String get documentView;

  /// No description provided for @documentRequired.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب'**
  String get documentRequired;

  /// No description provided for @imageLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل الصورة'**
  String get imageLoadFailed;

  /// No description provided for @openNotification.
  ///
  /// In ar, this message translates to:
  /// **'فتح'**
  String get openNotification;

  /// No description provided for @notificationsEmptyHint.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر هنا تنبيهات حجوزاتك ومحفظتك.'**
  String get notificationsEmptyHint;

  /// No description provided for @welcomeContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get welcomeContinue;

  /// No description provided for @splashLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل…'**
  String get splashLoading;

  /// No description provided for @signedInAs.
  ///
  /// In ar, this message translates to:
  /// **'مسجّل الدخول باسم'**
  String get signedInAs;

  /// No description provided for @supportNotConfigured.
  ///
  /// In ar, this message translates to:
  /// **'رقم الدعم غير متوفر حاليًا.'**
  String get supportNotConfigured;

  /// No description provided for @cannotOpenLink.
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح الرابط.'**
  String get cannotOpenLink;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
