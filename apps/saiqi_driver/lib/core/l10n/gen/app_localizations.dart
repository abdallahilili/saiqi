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

  /// No description provided for @adminBadge.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق المشرف'**
  String get adminBadge;

  /// No description provided for @noPermission.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك صلاحية لهذه الصفحة'**
  String get noPermission;

  /// No description provided for @more.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get more;

  /// No description provided for @dashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get dashboard;

  /// No description provided for @driversTitle.
  ///
  /// In ar, this message translates to:
  /// **'السائقون'**
  String get driversTitle;

  /// No description provided for @bookingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحجوزات'**
  String get bookingsTitle;

  /// No description provided for @walletsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحافظ'**
  String get walletsTitle;

  /// No description provided for @kpiPendingDrivers.
  ///
  /// In ar, this message translates to:
  /// **'ملفات بانتظار المراجعة'**
  String get kpiPendingDrivers;

  /// No description provided for @kpiNewDrivers.
  ///
  /// In ar, this message translates to:
  /// **'سائقون جدد (7 أيام)'**
  String get kpiNewDrivers;

  /// No description provided for @kpiApprovedDrivers.
  ///
  /// In ar, this message translates to:
  /// **'سائقون معتمدون'**
  String get kpiApprovedDrivers;

  /// No description provided for @kpiClients.
  ///
  /// In ar, this message translates to:
  /// **'العملاء'**
  String get kpiClients;

  /// No description provided for @kpiBookingsToday.
  ///
  /// In ar, this message translates to:
  /// **'حجوزات اليوم'**
  String get kpiBookingsToday;

  /// No description provided for @kpiPendingBookings.
  ///
  /// In ar, this message translates to:
  /// **'حجوزات قيد الانتظار'**
  String get kpiPendingBookings;

  /// No description provided for @kpiCommissionsToday.
  ///
  /// In ar, this message translates to:
  /// **'عمولات اليوم'**
  String get kpiCommissionsToday;

  /// No description provided for @kpiCommissionsTotal.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي العمولات'**
  String get kpiCommissionsTotal;

  /// No description provided for @kpiOpenComplaints.
  ///
  /// In ar, this message translates to:
  /// **'شكاوى مفتوحة'**
  String get kpiOpenComplaints;

  /// No description provided for @kpiPendingTopups.
  ///
  /// In ar, this message translates to:
  /// **'طلبات شحن معلقة'**
  String get kpiPendingTopups;

  /// No description provided for @searchPeople.
  ///
  /// In ar, this message translates to:
  /// **'بحث بالاسم أو الرقم'**
  String get searchPeople;

  /// No description provided for @addDriver.
  ///
  /// In ar, this message translates to:
  /// **'إضافة سائق'**
  String get addDriver;

  /// No description provided for @addDriverIntro.
  ///
  /// In ar, this message translates to:
  /// **'يُنشأ الحساب بحالة مسودة؛ يكمل السائق ملفه ثم يقدّمه للمراجعة.'**
  String get addDriverIntro;

  /// No description provided for @driverCreatedMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء حساب السائق'**
  String get driverCreatedMsg;

  /// No description provided for @driverDetail.
  ///
  /// In ar, this message translates to:
  /// **'ملف السائق'**
  String get driverDetail;

  /// No description provided for @approveDriver.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد السائق'**
  String get approveDriver;

  /// No description provided for @rejectDriver.
  ///
  /// In ar, this message translates to:
  /// **'رفض الملف'**
  String get rejectDriver;

  /// No description provided for @rejectReasonTitle.
  ///
  /// In ar, this message translates to:
  /// **'سبب الرفض (يظهر للسائق)'**
  String get rejectReasonTitle;

  /// No description provided for @driverApprovedMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم اعتماد السائق'**
  String get driverApprovedMsg;

  /// No description provided for @driverRejectedMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض الملف'**
  String get driverRejectedMsg;

  /// No description provided for @suspendDriver.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف السائق'**
  String get suspendDriver;

  /// No description provided for @reinstateDriver.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تفعيل السائق'**
  String get reinstateDriver;

  /// No description provided for @suspendReasonTitle.
  ///
  /// In ar, this message translates to:
  /// **'سبب الإيقاف'**
  String get suspendReasonTitle;

  /// No description provided for @accountActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات الحساب'**
  String get accountActions;

  /// No description provided for @suspendAccount.
  ///
  /// In ar, this message translates to:
  /// **'تعليق الحساب'**
  String get suspendAccount;

  /// No description provided for @blockAccount.
  ///
  /// In ar, this message translates to:
  /// **'حظر الحساب'**
  String get blockAccount;

  /// No description provided for @reactivateAccount.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تفعيل الحساب'**
  String get reactivateAccount;

  /// No description provided for @accountStatusChanged.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث حالة الحساب'**
  String get accountStatusChanged;

  /// No description provided for @noDocuments.
  ///
  /// In ar, this message translates to:
  /// **'لم يرفع السائق مستندات بعد'**
  String get noDocuments;

  /// No description provided for @noVehicle.
  ///
  /// In ar, this message translates to:
  /// **'لم تُسجَّل سيارة بعد'**
  String get noVehicle;

  /// No description provided for @noServicesAdmin.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد خدمات'**
  String get noServicesAdmin;

  /// No description provided for @approveDocument.
  ///
  /// In ar, this message translates to:
  /// **'قبول المستند'**
  String get approveDocument;

  /// No description provided for @rejectDocument.
  ///
  /// In ar, this message translates to:
  /// **'رفض المستند'**
  String get rejectDocument;

  /// No description provided for @documentApprovedMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم قبول المستند'**
  String get documentApprovedMsg;

  /// No description provided for @documentRejectedMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض المستند'**
  String get documentRejectedMsg;

  /// No description provided for @rejectDocReasonTitle.
  ///
  /// In ar, this message translates to:
  /// **'سبب رفض المستند'**
  String get rejectDocReasonTitle;

  /// No description provided for @filterPending.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار المراجعة'**
  String get filterPending;

  /// No description provided for @documentsProgress.
  ///
  /// In ar, this message translates to:
  /// **'{count} مستند'**
  String documentsProgress(String count);

  /// No description provided for @joinedOn.
  ///
  /// In ar, this message translates to:
  /// **'انضم في {date}'**
  String joinedOn(String date);

  /// No description provided for @driverNotFound.
  ///
  /// In ar, this message translates to:
  /// **'السائق غير موجود'**
  String get driverNotFound;

  /// No description provided for @filterStatus.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get filterStatus;

  /// No description provided for @filterChannel.
  ///
  /// In ar, this message translates to:
  /// **'القناة'**
  String get filterChannel;

  /// No description provided for @filterCity.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get filterCity;

  /// No description provided for @filterDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get filterDate;

  /// No description provided for @clearFilters.
  ///
  /// In ar, this message translates to:
  /// **'مسح التصفية'**
  String get clearFilters;

  /// No description provided for @bookingDetail.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الحجز'**
  String get bookingDetail;

  /// No description provided for @noBookings.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حجوزات'**
  String get noBookings;

  /// No description provided for @offersSent.
  ///
  /// In ar, this message translates to:
  /// **'العروض المرسلة'**
  String get offersSent;

  /// No description provided for @offerStatus_pending.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الرد'**
  String get offerStatus_pending;

  /// No description provided for @offerStatus_accepted.
  ///
  /// In ar, this message translates to:
  /// **'قبل'**
  String get offerStatus_accepted;

  /// No description provided for @offerStatus_declined.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get offerStatus_declined;

  /// No description provided for @offerStatus_expired.
  ///
  /// In ar, this message translates to:
  /// **'منتهٍ'**
  String get offerStatus_expired;

  /// No description provided for @reassignDriver.
  ///
  /// In ar, this message translates to:
  /// **'تغيير السائق'**
  String get reassignDriver;

  /// No description provided for @reassignedMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الطلب للسائقين المختارين'**
  String get reassignedMsg;

  /// No description provided for @cancelBookingAdmin.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الحجز'**
  String get cancelBookingAdmin;

  /// No description provided for @cancelReasonPrompt.
  ///
  /// In ar, this message translates to:
  /// **'سبب الإلغاء'**
  String get cancelReasonPrompt;

  /// No description provided for @bookingCancelledMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الحجز'**
  String get bookingCancelledMsg;

  /// No description provided for @contactClient.
  ///
  /// In ar, this message translates to:
  /// **'اتصال بالعميل'**
  String get contactClient;

  /// No description provided for @contactDriver.
  ///
  /// In ar, this message translates to:
  /// **'اتصال بالسائق'**
  String get contactDriver;

  /// No description provided for @guestClient.
  ///
  /// In ar, this message translates to:
  /// **'عميل بدون حساب'**
  String get guestClient;

  /// No description provided for @registeredClient.
  ///
  /// In ar, this message translates to:
  /// **'عميل مسجّل'**
  String get registeredClient;

  /// No description provided for @noDriverAssigned.
  ///
  /// In ar, this message translates to:
  /// **'لم يُعيَّن سائق بعد'**
  String get noDriverAssigned;

  /// No description provided for @createRequest.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء طلب'**
  String get createRequest;

  /// No description provided for @newRequest.
  ///
  /// In ar, this message translates to:
  /// **'طلب جديد لعميل'**
  String get newRequest;

  /// No description provided for @newRequestIntro.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ طلبًا لعميل اتصل بك أو راسلك، ثم أرسله لسائق أو لعدة سائقين.'**
  String get newRequestIntro;

  /// No description provided for @clientNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم العميل'**
  String get clientNameLabel;

  /// No description provided for @clientPhoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'هاتف العميل'**
  String get clientPhoneLabel;

  /// No description provided for @agreedPriceField.
  ///
  /// In ar, this message translates to:
  /// **'السعر المتفق عليه (أوقية)'**
  String get agreedPriceField;

  /// No description provided for @originChannel.
  ///
  /// In ar, this message translates to:
  /// **'قناة الطلب'**
  String get originChannel;

  /// No description provided for @chooseDrivers.
  ///
  /// In ar, this message translates to:
  /// **'اختر السائقين'**
  String get chooseDrivers;

  /// No description provided for @driversInCityHint.
  ///
  /// In ar, this message translates to:
  /// **'السائقون المعتمدون الذين يقدمون هذه الخدمة في المدينة المختارة'**
  String get driversInCityHint;

  /// No description provided for @onlyAvailable.
  ///
  /// In ar, this message translates to:
  /// **'المتاحون فقط'**
  String get onlyAvailable;

  /// No description provided for @noDriversFound.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سائقون مطابقون'**
  String get noDriversFound;

  /// No description provided for @selectedCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} محدد'**
  String selectedCount(String count);

  /// No description provided for @selectAtLeastOneDriver.
  ///
  /// In ar, this message translates to:
  /// **'اختر سائقًا واحدًا على الأقل'**
  String get selectAtLeastOneDriver;

  /// No description provided for @sendRequest.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء وإرسال الطلب'**
  String get sendRequest;

  /// No description provided for @requestCreatedMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الطلب وإرساله'**
  String get requestCreatedMsg;

  /// No description provided for @multiDriverHint.
  ///
  /// In ar, this message translates to:
  /// **'عند اختيار عدة سائقين، الأول الذي يقبل يحصل على الطلب.'**
  String get multiDriverHint;

  /// No description provided for @selectAll.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل'**
  String get selectAll;

  /// No description provided for @topupsTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الشحن'**
  String get topupsTitle;

  /// No description provided for @noTopupsAdmin.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات شحن'**
  String get noTopupsAdmin;

  /// No description provided for @approveTopup.
  ///
  /// In ar, this message translates to:
  /// **'قبول الشحن'**
  String get approveTopup;

  /// No description provided for @rejectTopup.
  ///
  /// In ar, this message translates to:
  /// **'رفض الشحن'**
  String get rejectTopup;

  /// No description provided for @topupApprovedMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم شحن المحفظة'**
  String get topupApprovedMsg;

  /// No description provided for @topupRejectedMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض الطلب'**
  String get topupRejectedMsg;

  /// No description provided for @topupNoteHint.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة (اختياري)'**
  String get topupNoteHint;

  /// No description provided for @proofImage.
  ///
  /// In ar, this message translates to:
  /// **'إثبات الدفع'**
  String get proofImage;

  /// No description provided for @noProof.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد إثبات'**
  String get noProof;

  /// No description provided for @adjustWallet.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الرصيد يدويًا'**
  String get adjustWallet;

  /// No description provided for @adjustAmountHint.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ موجب للإضافة أو سالب للخصم'**
  String get adjustAmountHint;

  /// No description provided for @adjustNote.
  ///
  /// In ar, this message translates to:
  /// **'سبب التعديل'**
  String get adjustNote;

  /// No description provided for @adjustDone.
  ///
  /// In ar, this message translates to:
  /// **'تم تعديل الرصيد'**
  String get adjustDone;

  /// No description provided for @walletHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل المحفظة'**
  String get walletHistory;

  /// No description provided for @driversWallets.
  ///
  /// In ar, this message translates to:
  /// **'محافظ السائقين'**
  String get driversWallets;

  /// No description provided for @referenceLabel.
  ///
  /// In ar, this message translates to:
  /// **'المرجع'**
  String get referenceLabel;

  /// No description provided for @methodLabel.
  ///
  /// In ar, this message translates to:
  /// **'الطريقة'**
  String get methodLabel;

  /// No description provided for @commissionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'العمولات'**
  String get commissionsTitle;

  /// No description provided for @defaultRate.
  ///
  /// In ar, this message translates to:
  /// **'النسبة الافتراضية'**
  String get defaultRate;

  /// No description provided for @rateOverrides.
  ///
  /// In ar, this message translates to:
  /// **'نسب مخصصة'**
  String get rateOverrides;

  /// No description provided for @rateByService.
  ///
  /// In ar, this message translates to:
  /// **'حسب الخدمة'**
  String get rateByService;

  /// No description provided for @rateByCity.
  ///
  /// In ar, this message translates to:
  /// **'حسب المدينة'**
  String get rateByCity;

  /// No description provided for @rateByServiceCity.
  ///
  /// In ar, this message translates to:
  /// **'حسب الخدمة والمدينة'**
  String get rateByServiceCity;

  /// No description provided for @addRate.
  ///
  /// In ar, this message translates to:
  /// **'إضافة نسبة'**
  String get addRate;

  /// No description provided for @rateField.
  ///
  /// In ar, this message translates to:
  /// **'النسبة (%)'**
  String get rateField;

  /// No description provided for @rateInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل نسبة بين 0 و 100'**
  String get rateInvalid;

  /// No description provided for @rateSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ النسبة'**
  String get rateSaved;

  /// No description provided for @rateNeedsScope.
  ///
  /// In ar, this message translates to:
  /// **'اختر خدمة أو مدينة أو كليهما'**
  String get rateNeedsScope;

  /// No description provided for @ratePriorityNote.
  ///
  /// In ar, this message translates to:
  /// **'الأولوية: خدمة+مدينة، ثم خدمة، ثم مدينة، ثم النسبة الافتراضية.'**
  String get ratePriorityNote;

  /// No description provided for @commissionHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل العمولات'**
  String get commissionHistory;

  /// No description provided for @noCommissions.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عمولات بعد'**
  String get noCommissions;

  /// No description provided for @refundedLabel.
  ///
  /// In ar, this message translates to:
  /// **'مستردة'**
  String get refundedLabel;

  /// No description provided for @generalSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات عامة'**
  String get generalSettings;

  /// No description provided for @responseTimeout.
  ///
  /// In ar, this message translates to:
  /// **'مهلة رد السائق (دقائق)'**
  String get responseTimeout;

  /// No description provided for @lowBalanceThresholdField.
  ///
  /// In ar, this message translates to:
  /// **'حد تنبيه الرصيد المنخفض (أوقية)'**
  String get lowBalanceThresholdField;

  /// No description provided for @minTopupField.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى للشحن (أوقية)'**
  String get minTopupField;

  /// No description provided for @supportPhoneField.
  ///
  /// In ar, this message translates to:
  /// **'هاتف الدعم'**
  String get supportPhoneField;

  /// No description provided for @supportWhatsappField.
  ///
  /// In ar, this message translates to:
  /// **'واتساب الدعم'**
  String get supportWhatsappField;

  /// No description provided for @topupAccountsTitle.
  ///
  /// In ar, this message translates to:
  /// **'حسابات استلام الشحن'**
  String get topupAccountsTitle;

  /// No description provided for @accountHint.
  ///
  /// In ar, this message translates to:
  /// **'رقم الحساب'**
  String get accountHint;

  /// No description provided for @settingsSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الإعدادات'**
  String get settingsSaved;

  /// No description provided for @complaintsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الشكاوى'**
  String get complaintsTitle;

  /// No description provided for @noComplaints.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد شكاوى'**
  String get noComplaints;

  /// No description provided for @complaintDetail.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الشكوى'**
  String get complaintDetail;

  /// No description provided for @complaintAuthor.
  ///
  /// In ar, this message translates to:
  /// **'المُبلِّغ'**
  String get complaintAuthor;

  /// No description provided for @complaintAgainst.
  ///
  /// In ar, this message translates to:
  /// **'المشكو منه'**
  String get complaintAgainst;

  /// No description provided for @resolutionField.
  ///
  /// In ar, this message translates to:
  /// **'القرار / الرد'**
  String get resolutionField;

  /// No description provided for @markInReview.
  ///
  /// In ar, this message translates to:
  /// **'قيد المعالجة'**
  String get markInReview;

  /// No description provided for @resolveComplaint.
  ///
  /// In ar, this message translates to:
  /// **'تمت المعالجة'**
  String get resolveComplaint;

  /// No description provided for @dismissComplaint.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الشكوى'**
  String get dismissComplaint;

  /// No description provided for @complaintUpdatedMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الشكوى'**
  String get complaintUpdatedMsg;

  /// No description provided for @warnUser.
  ///
  /// In ar, this message translates to:
  /// **'إرسال تنبيه'**
  String get warnUser;

  /// No description provided for @warnMessageHint.
  ///
  /// In ar, this message translates to:
  /// **'نص التنبيه'**
  String get warnMessageHint;

  /// No description provided for @warnSentMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال التنبيه'**
  String get warnSentMsg;

  /// No description provided for @warningTitle.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه من الإدارة'**
  String get warningTitle;

  /// No description provided for @reviewsModeration.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة التقييمات'**
  String get reviewsModeration;

  /// No description provided for @hideReview.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء'**
  String get hideReview;

  /// No description provided for @showReview.
  ///
  /// In ar, this message translates to:
  /// **'إظهار'**
  String get showReview;

  /// No description provided for @reviewHidden.
  ///
  /// In ar, this message translates to:
  /// **'مخفي'**
  String get reviewHidden;

  /// No description provided for @noReviewsAdmin.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تقييمات'**
  String get noReviewsAdmin;

  /// No description provided for @reviewFor.
  ///
  /// In ar, this message translates to:
  /// **'عن السائق {name}'**
  String reviewFor(String name);

  /// No description provided for @clientsTitle.
  ///
  /// In ar, this message translates to:
  /// **'العملاء'**
  String get clientsTitle;

  /// No description provided for @noClients.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد عملاء'**
  String get noClients;

  /// No description provided for @resetPassword.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين كلمة المرور'**
  String get resetPassword;

  /// No description provided for @newPasswordPrompt.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة (8 أحرف على الأقل)'**
  String get newPasswordPrompt;

  /// No description provided for @passwordResetDone.
  ///
  /// In ar, this message translates to:
  /// **'تمت إعادة تعيين كلمة المرور'**
  String get passwordResetDone;

  /// No description provided for @userDetail.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الحساب'**
  String get userDetail;

  /// No description provided for @catalogTitle.
  ///
  /// In ar, this message translates to:
  /// **'المدن والخدمات'**
  String get catalogTitle;

  /// No description provided for @citiesTitle.
  ///
  /// In ar, this message translates to:
  /// **'المدن'**
  String get citiesTitle;

  /// No description provided for @servicesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخدمات'**
  String get servicesTitle;

  /// No description provided for @addCity.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مدينة'**
  String get addCity;

  /// No description provided for @editCity.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المدينة'**
  String get editCity;

  /// No description provided for @addServiceType.
  ///
  /// In ar, this message translates to:
  /// **'إضافة خدمة'**
  String get addServiceType;

  /// No description provided for @editServiceType.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الخدمة'**
  String get editServiceType;

  /// No description provided for @nameArField.
  ///
  /// In ar, this message translates to:
  /// **'الاسم بالعربية'**
  String get nameArField;

  /// No description provided for @nameFrField.
  ///
  /// In ar, this message translates to:
  /// **'الاسم بالفرنسية'**
  String get nameFrField;

  /// No description provided for @iconField.
  ///
  /// In ar, this message translates to:
  /// **'الأيقونة'**
  String get iconField;

  /// No description provided for @activeField.
  ///
  /// In ar, this message translates to:
  /// **'مفعّل'**
  String get activeField;

  /// No description provided for @deleteBlocked.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الحذف لوجود بيانات مرتبطة. عطّله بدلًا من ذلك.'**
  String get deleteBlocked;

  /// No description provided for @deleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف نهائي؟'**
  String get deleteConfirm;

  /// No description provided for @teamTitle.
  ///
  /// In ar, this message translates to:
  /// **'فريق الإدارة'**
  String get teamTitle;

  /// No description provided for @addMember.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عضو'**
  String get addMember;

  /// No description provided for @roleField.
  ///
  /// In ar, this message translates to:
  /// **'الدور'**
  String get roleField;

  /// No description provided for @memberCreated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الحساب'**
  String get memberCreated;

  /// No description provided for @changeRole.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الدور'**
  String get changeRole;

  /// No description provided for @roleChanged.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير الدور'**
  String get roleChanged;

  /// No description provided for @roleSuperAdminDesc.
  ///
  /// In ar, this message translates to:
  /// **'كل الصلاحيات'**
  String get roleSuperAdminDesc;

  /// No description provided for @roleValidatorDesc.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة ملفات السائقين'**
  String get roleValidatorDesc;

  /// No description provided for @roleSupportDesc.
  ///
  /// In ar, this message translates to:
  /// **'الحجوزات والشحن والشكاوى والعملاء'**
  String get roleSupportDesc;

  /// No description provided for @auditTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل التدقيق'**
  String get auditTitle;

  /// No description provided for @noAudit.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عمليات مسجلة'**
  String get noAudit;

  /// No description provided for @by.
  ///
  /// In ar, this message translates to:
  /// **'بواسطة {name}'**
  String by(String name);

  /// No description provided for @announcementsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعلانات'**
  String get announcementsTitle;

  /// No description provided for @newAnnouncement.
  ///
  /// In ar, this message translates to:
  /// **'إعلان جديد'**
  String get newAnnouncement;

  /// No description provided for @audienceField.
  ///
  /// In ar, this message translates to:
  /// **'الفئة المستهدفة'**
  String get audienceField;

  /// No description provided for @announcementTitleField.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get announcementTitleField;

  /// No description provided for @announcementBodyField.
  ///
  /// In ar, this message translates to:
  /// **'النص'**
  String get announcementBodyField;

  /// No description provided for @announcementSentMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الإعلان'**
  String get announcementSentMsg;

  /// No description provided for @recipientsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} مستلم'**
  String recipientsCount(String count);

  /// No description provided for @noAnnouncements.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات'**
  String get noAnnouncements;

  /// No description provided for @audit_approve_driver.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد سائق'**
  String get audit_approve_driver;

  /// No description provided for @audit_reject_driver.
  ///
  /// In ar, this message translates to:
  /// **'رفض ملف سائق'**
  String get audit_reject_driver;

  /// No description provided for @audit_review_document.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة مستند'**
  String get audit_review_document;

  /// No description provided for @audit_set_driver_status.
  ///
  /// In ar, this message translates to:
  /// **'تغيير حالة سائق'**
  String get audit_set_driver_status;

  /// No description provided for @audit_set_account_status.
  ///
  /// In ar, this message translates to:
  /// **'تغيير حالة حساب'**
  String get audit_set_account_status;

  /// No description provided for @audit_set_admin_role.
  ///
  /// In ar, this message translates to:
  /// **'تغيير دور مشرف'**
  String get audit_set_admin_role;

  /// No description provided for @audit_review_topup.
  ///
  /// In ar, this message translates to:
  /// **'معالجة طلب شحن'**
  String get audit_review_topup;

  /// No description provided for @audit_adjust_wallet.
  ///
  /// In ar, this message translates to:
  /// **'تعديل رصيد'**
  String get audit_adjust_wallet;

  /// No description provided for @audit_create_booking.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء طلب'**
  String get audit_create_booking;

  /// No description provided for @audit_reassign_booking.
  ///
  /// In ar, this message translates to:
  /// **'تغيير سائق حجز'**
  String get audit_reassign_booking;

  /// No description provided for @audit_cancel_booking.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء حجز'**
  String get audit_cancel_booking;

  /// No description provided for @audit_handle_complaint.
  ///
  /// In ar, this message translates to:
  /// **'معالجة شكوى'**
  String get audit_handle_complaint;

  /// No description provided for @audit_moderate_review.
  ///
  /// In ar, this message translates to:
  /// **'إدارة تقييم'**
  String get audit_moderate_review;

  /// No description provided for @audit_send_announcement.
  ///
  /// In ar, this message translates to:
  /// **'إرسال إعلان'**
  String get audit_send_announcement;

  /// No description provided for @audit_reset_password.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين كلمة مرور'**
  String get audit_reset_password;

  /// No description provided for @audit_create_admin.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء مشرف'**
  String get audit_create_admin;

  /// No description provided for @audit_create_driver.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء سائق'**
  String get audit_create_driver;

  /// No description provided for @audit_warn_user.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه مستخدم'**
  String get audit_warn_user;

  /// No description provided for @audit_insert.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get audit_insert;

  /// No description provided for @audit_update.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get audit_update;

  /// No description provided for @audit_delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get audit_delete;

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

  /// No description provided for @clientBadge.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق العميل'**
  String get clientBadge;

  /// No description provided for @findDriverTitle.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن سائقك'**
  String get findDriverTitle;

  /// No description provided for @findDriverSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سائقون موثّقون في مدينتك، بأسعار واضحة'**
  String get findDriverSubtitle;

  /// No description provided for @chooseCity.
  ///
  /// In ar, this message translates to:
  /// **'اختر مدينتك'**
  String get chooseCity;

  /// No description provided for @whatDoYouNeed.
  ///
  /// In ar, this message translates to:
  /// **'ماذا تحتاج؟'**
  String get whatDoYouNeed;

  /// No description provided for @searchDrivers.
  ///
  /// In ar, this message translates to:
  /// **'عرض السائقين'**
  String get searchDrivers;

  /// No description provided for @noServiceTypes.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد خدمات متاحة حاليًا'**
  String get noServiceTypes;

  /// No description provided for @driversFoundCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} سائق'**
  String driversFoundCount(String count);

  /// No description provided for @noDriversHint.
  ///
  /// In ar, this message translates to:
  /// **'جرّب تغيير الفلاتر أو المدينة أو إظهار غير المتاحين.'**
  String get noDriversHint;

  /// No description provided for @driversListTitle.
  ///
  /// In ar, this message translates to:
  /// **'السائقون'**
  String get driversListTitle;

  /// No description provided for @priceRangeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نطاق السعر (أوقية)'**
  String get priceRangeLabel;

  /// No description provided for @minPriceField.
  ///
  /// In ar, this message translates to:
  /// **'الأدنى'**
  String get minPriceField;

  /// No description provided for @maxPriceField.
  ///
  /// In ar, this message translates to:
  /// **'الأقصى'**
  String get maxPriceField;

  /// No description provided for @minRatingLabel.
  ///
  /// In ar, this message translates to:
  /// **'التقييم الأدنى'**
  String get minRatingLabel;

  /// No description provided for @minSeatsLabel.
  ///
  /// In ar, this message translates to:
  /// **'عدد المقاعد الأدنى'**
  String get minSeatsLabel;

  /// No description provided for @anyValue.
  ///
  /// In ar, this message translates to:
  /// **'أي'**
  String get anyValue;

  /// No description provided for @showUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'إظهار غير المتاحين أيضًا'**
  String get showUnavailable;

  /// No description provided for @activeFilters.
  ///
  /// In ar, this message translates to:
  /// **'{count} فلتر نشط'**
  String activeFilters(String count);

  /// No description provided for @aboutDriver.
  ///
  /// In ar, this message translates to:
  /// **'نبذة'**
  String get aboutDriver;

  /// No description provided for @tariffs.
  ///
  /// In ar, this message translates to:
  /// **'الأسعار'**
  String get tariffs;

  /// No description provided for @noTariffs.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أسعار منشورة'**
  String get noTariffs;

  /// No description provided for @reviewsTitle.
  ///
  /// In ar, this message translates to:
  /// **'التقييمات'**
  String get reviewsTitle;

  /// No description provided for @noReviewsClient.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تقييمات بعد'**
  String get noReviewsClient;

  /// No description provided for @bookNow.
  ///
  /// In ar, this message translates to:
  /// **'احجز الآن'**
  String get bookNow;

  /// No description provided for @addFavorite.
  ///
  /// In ar, this message translates to:
  /// **'أضف إلى المفضلة'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In ar, this message translates to:
  /// **'إزالة من المفضلة'**
  String get removeFavorite;

  /// No description provided for @favoriteAdded.
  ///
  /// In ar, this message translates to:
  /// **'أُضيف إلى المفضلة'**
  String get favoriteAdded;

  /// No description provided for @favoriteRemoved.
  ///
  /// In ar, this message translates to:
  /// **'أُزيل من المفضلة'**
  String get favoriteRemoved;

  /// No description provided for @servesCities.
  ///
  /// In ar, this message translates to:
  /// **'المدن'**
  String get servesCities;

  /// No description provided for @tripsDone.
  ///
  /// In ar, this message translates to:
  /// **'رحلات منجزة'**
  String get tripsDone;

  /// No description provided for @driverNotFoundClient.
  ///
  /// In ar, this message translates to:
  /// **'هذا السائق غير متاح حاليًا'**
  String get driverNotFoundClient;

  /// No description provided for @bookingRequestTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب حجز'**
  String get bookingRequestTitle;

  /// No description provided for @estimatedPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر التقديري'**
  String get estimatedPrice;

  /// No description provided for @payDriverDirectly.
  ///
  /// In ar, this message translates to:
  /// **'تدفع المبلغ للسائق مباشرة (نقدًا أو دفع هاتفي). التطبيق لا يستلم أي مبلغ.'**
  String get payDriverDirectly;

  /// No description provided for @submitBooking.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الطلب'**
  String get submitBooking;

  /// No description provided for @bookingSentMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلبك إلى السائق'**
  String get bookingSentMsg;

  /// No description provided for @pickupHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: المطار، تفرغ زينة…'**
  String get pickupHint;

  /// No description provided for @serviceNotInCity.
  ///
  /// In ar, this message translates to:
  /// **'هذا السائق لا يخدم هذه المدينة'**
  String get serviceNotInCity;

  /// No description provided for @maxPassengersHint.
  ///
  /// In ar, this message translates to:
  /// **'حتى {count} راكب'**
  String maxPassengersHint(String count);

  /// No description provided for @completeNameFirst.
  ///
  /// In ar, this message translates to:
  /// **'أضف اسمك ليعرفك السائق'**
  String get completeNameFirst;

  /// No description provided for @myBookings.
  ///
  /// In ar, this message translates to:
  /// **'حجوزاتي'**
  String get myBookings;

  /// No description provided for @bookingsActive.
  ///
  /// In ar, this message translates to:
  /// **'الحالية'**
  String get bookingsActive;

  /// No description provided for @bookingsPast.
  ///
  /// In ar, this message translates to:
  /// **'السابقة'**
  String get bookingsPast;

  /// No description provided for @noBookingsClient.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حجوزات بعد'**
  String get noBookingsClient;

  /// No description provided for @noBookingsClientHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن سائق وأرسل أول طلب.'**
  String get noBookingsClientHint;

  /// No description provided for @trackBooking.
  ///
  /// In ar, this message translates to:
  /// **'تتبع الحجز'**
  String get trackBooking;

  /// No description provided for @waitingDriverTitle.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار رد السائق'**
  String get waitingDriverTitle;

  /// No description provided for @waitingDriverHint.
  ///
  /// In ar, this message translates to:
  /// **'سنُعلمك فور الرد. إن لم يرد في الوقت المحدد ستنتهي المهلة.'**
  String get waitingDriverHint;

  /// No description provided for @yourDriver.
  ///
  /// In ar, this message translates to:
  /// **'سائقك'**
  String get yourDriver;

  /// No description provided for @contactDriverTitle.
  ///
  /// In ar, this message translates to:
  /// **'التواصل مع السائق'**
  String get contactDriverTitle;

  /// No description provided for @contactAfterAccept.
  ///
  /// In ar, this message translates to:
  /// **'يظهر رقم السائق بعد قبول الطلب.'**
  String get contactAfterAccept;

  /// No description provided for @cancelBooking.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الحجز'**
  String get cancelBooking;

  /// No description provided for @cancelBookingConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إلغاء هذا الحجز؟'**
  String get cancelBookingConfirm;

  /// No description provided for @cancelUnavailableEnRoute.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن الإلغاء بعد انطلاق السائق.'**
  String get cancelUnavailableEnRoute;

  /// No description provided for @bookingCancelledClient.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الحجز'**
  String get bookingCancelledClient;

  /// No description provided for @suggestOthers.
  ///
  /// In ar, this message translates to:
  /// **'سائقون آخرون مقترحون'**
  String get suggestOthers;

  /// No description provided for @bookingRejectedHint.
  ///
  /// In ar, this message translates to:
  /// **'رفض السائق طلبك. اختر سائقًا آخر:'**
  String get bookingRejectedHint;

  /// No description provided for @bookingExpiredHint.
  ///
  /// In ar, this message translates to:
  /// **'انتهت المهلة دون رد. جرّب سائقًا آخر:'**
  String get bookingExpiredHint;

  /// No description provided for @noAlternatives.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سائقون بديلون الآن'**
  String get noAlternatives;

  /// No description provided for @rateDriver.
  ///
  /// In ar, this message translates to:
  /// **'قيّم السائق'**
  String get rateDriver;

  /// No description provided for @ratingCommentHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب تعليقك (اختياري)'**
  String get ratingCommentHint;

  /// No description provided for @submitReview.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التقييم'**
  String get submitReview;

  /// No description provided for @reviewThanks.
  ///
  /// In ar, this message translates to:
  /// **'شكرًا على تقييمك'**
  String get reviewThanks;

  /// No description provided for @yourReview.
  ///
  /// In ar, this message translates to:
  /// **'تقييمك'**
  String get yourReview;

  /// No description provided for @tapStarToRate.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على نجمة للتقييم'**
  String get tapStarToRate;

  /// No description provided for @fileComplaint.
  ///
  /// In ar, this message translates to:
  /// **'تقديم شكوى'**
  String get fileComplaint;

  /// No description provided for @complaintHint.
  ///
  /// In ar, this message translates to:
  /// **'اشرح المشكلة…'**
  String get complaintHint;

  /// No description provided for @complaintSentMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال شكواك وسنراجعها'**
  String get complaintSentMsg;

  /// No description provided for @favoritesTitle.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favoritesTitle;

  /// No description provided for @noFavorites.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سائقون مفضلون'**
  String get noFavorites;

  /// No description provided for @noFavoritesHint.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على القلب في ملف أي سائق لحفظه هنا.'**
  String get noFavoritesHint;

  /// No description provided for @myAccount.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get myAccount;

  /// No description provided for @editName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get editName;

  /// No description provided for @nameHelp.
  ///
  /// In ar, this message translates to:
  /// **'يظهر اسمك للسائق عند الحجز'**
  String get nameHelp;

  /// No description provided for @helpClient.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة والدعم'**
  String get helpClient;

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

  /// No description provided for @driverBadge.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق السائق'**
  String get driverBadge;

  /// No description provided for @saved.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ'**
  String get saved;

  /// No description provided for @applicationTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملف السائق'**
  String get applicationTitle;

  /// No description provided for @applicationIntro.
  ///
  /// In ar, this message translates to:
  /// **'أكمل ملفك ليراجعه فريقنا. التسجيل مجاني، وتُحتسب عمولة فقط على كل خدمة تقبلها.'**
  String get applicationIntro;

  /// No description provided for @stepPersonal.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الشخصية'**
  String get stepPersonal;

  /// No description provided for @stepDocuments.
  ///
  /// In ar, this message translates to:
  /// **'المستندات'**
  String get stepDocuments;

  /// No description provided for @stepVehicle.
  ///
  /// In ar, this message translates to:
  /// **'السيارة'**
  String get stepVehicle;

  /// No description provided for @stepServices.
  ///
  /// In ar, this message translates to:
  /// **'الخدمات والأسعار'**
  String get stepServices;

  /// No description provided for @stepAvailability.
  ///
  /// In ar, this message translates to:
  /// **'أوقات العمل'**
  String get stepAvailability;

  /// No description provided for @stepComplete.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get stepComplete;

  /// No description provided for @stepTodo.
  ///
  /// In ar, this message translates to:
  /// **'غير مكتمل'**
  String get stepTodo;

  /// No description provided for @stepOptional.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get stepOptional;

  /// No description provided for @submitApplication.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الملف للمراجعة'**
  String get submitApplication;

  /// No description provided for @submitApplicationConfirm.
  ///
  /// In ar, this message translates to:
  /// **'بعد الإرسال لن تتمكن من التعديل حتى تتم المراجعة.'**
  String get submitApplicationConfirm;

  /// No description provided for @applicationSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال ملفك. سنراجعه قريبًا.'**
  String get applicationSubmitted;

  /// No description provided for @applicationRejectedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض ملفك'**
  String get applicationRejectedTitle;

  /// No description provided for @applicationRejectedHint.
  ///
  /// In ar, this message translates to:
  /// **'صحّح ما يلزم ثم أعد إرسال الملف.'**
  String get applicationRejectedHint;

  /// No description provided for @missingItems.
  ///
  /// In ar, this message translates to:
  /// **'ينقص: {items}'**
  String missingItems(String items);

  /// No description provided for @yearsExperienceLabel.
  ///
  /// In ar, this message translates to:
  /// **'سنوات الخبرة'**
  String get yearsExperienceLabel;

  /// No description provided for @bioLabel.
  ///
  /// In ar, this message translates to:
  /// **'نبذة عنك'**
  String get bioLabel;

  /// No description provided for @bioHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: سائق محترف أعرف المدينة جيدًا…'**
  String get bioHint;

  /// No description provided for @profilePhoto.
  ///
  /// In ar, this message translates to:
  /// **'الصورة الشخصية'**
  String get profilePhoto;

  /// No description provided for @changePhoto.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الصورة'**
  String get changePhoto;

  /// No description provided for @cityOfWork.
  ///
  /// In ar, this message translates to:
  /// **'مدينة العمل الرئيسية'**
  String get cityOfWork;

  /// No description provided for @documentsIntro.
  ///
  /// In ar, this message translates to:
  /// **'التقط صورًا واضحة ومقروءة لكل مستند.'**
  String get documentsIntro;

  /// No description provided for @docRejectedReason.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض: {reason}'**
  String docRejectedReason(String reason);

  /// No description provided for @vehicleTitle.
  ///
  /// In ar, this message translates to:
  /// **'معلومات السيارة'**
  String get vehicleTitle;

  /// No description provided for @vehicleType.
  ///
  /// In ar, this message translates to:
  /// **'نوع السيارة'**
  String get vehicleType;

  /// No description provided for @vehicleBrand.
  ///
  /// In ar, this message translates to:
  /// **'الماركة'**
  String get vehicleBrand;

  /// No description provided for @vehicleModel.
  ///
  /// In ar, this message translates to:
  /// **'الطراز'**
  String get vehicleModel;

  /// No description provided for @vehicleYear.
  ///
  /// In ar, this message translates to:
  /// **'سنة الصنع'**
  String get vehicleYear;

  /// No description provided for @vehicleColor.
  ///
  /// In ar, this message translates to:
  /// **'اللون'**
  String get vehicleColor;

  /// No description provided for @vehicleSeats.
  ///
  /// In ar, this message translates to:
  /// **'عدد المقاعد'**
  String get vehicleSeats;

  /// No description provided for @vehiclePlate.
  ///
  /// In ar, this message translates to:
  /// **'رقم اللوحة'**
  String get vehiclePlate;

  /// No description provided for @vehiclePhotos.
  ///
  /// In ar, this message translates to:
  /// **'صور السيارة'**
  String get vehiclePhotos;

  /// No description provided for @addVehiclePhoto.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صورة'**
  String get addVehiclePhoto;

  /// No description provided for @maxPhotosReached.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى 5 صور.'**
  String get maxPhotosReached;

  /// No description provided for @servicesIntro.
  ///
  /// In ar, this message translates to:
  /// **'اختر الخدمات التي تقدمها ومدنها وسعر كل منها.'**
  String get servicesIntro;

  /// No description provided for @addService.
  ///
  /// In ar, this message translates to:
  /// **'إضافة خدمة'**
  String get addService;

  /// No description provided for @editService.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الخدمة'**
  String get editService;

  /// No description provided for @serviceCities.
  ///
  /// In ar, this message translates to:
  /// **'المدن التي تخدمها'**
  String get serviceCities;

  /// No description provided for @servicePriceField.
  ///
  /// In ar, this message translates to:
  /// **'السعر (أوقية)'**
  String get servicePriceField;

  /// No description provided for @priceUnitField.
  ///
  /// In ar, this message translates to:
  /// **'وحدة السعر'**
  String get priceUnitField;

  /// No description provided for @serviceActive.
  ///
  /// In ar, this message translates to:
  /// **'مفعّلة'**
  String get serviceActive;

  /// No description provided for @noServicesYet.
  ///
  /// In ar, this message translates to:
  /// **'لم تضف أي خدمة بعد'**
  String get noServicesYet;

  /// No description provided for @noServicesHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف خدمة واحدة على الأقل لتظهر للعملاء.'**
  String get noServicesHint;

  /// No description provided for @deleteServiceConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذه الخدمة؟'**
  String get deleteServiceConfirm;

  /// No description provided for @selectAtLeastOneCity.
  ///
  /// In ar, this message translates to:
  /// **'اختر مدينة واحدة على الأقل'**
  String get selectAtLeastOneCity;

  /// No description provided for @serviceAlreadyAdded.
  ///
  /// In ar, this message translates to:
  /// **'هذه الخدمة مضافة مسبقًا'**
  String get serviceAlreadyAdded;

  /// No description provided for @availabilityIntro.
  ///
  /// In ar, this message translates to:
  /// **'حدد الأيام والساعات التي تعمل فيها.'**
  String get availabilityIntro;

  /// No description provided for @dayOff.
  ///
  /// In ar, this message translates to:
  /// **'عطلة'**
  String get dayOff;

  /// No description provided for @timeFrom.
  ///
  /// In ar, this message translates to:
  /// **'من'**
  String get timeFrom;

  /// No description provided for @timeTo.
  ///
  /// In ar, this message translates to:
  /// **'إلى'**
  String get timeTo;

  /// No description provided for @invalidTimeRange.
  ///
  /// In ar, this message translates to:
  /// **'وقت النهاية يجب أن يكون بعد البداية'**
  String get invalidTimeRange;

  /// No description provided for @pendingTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملفك قيد المراجعة'**
  String get pendingTitle;

  /// No description provided for @pendingBody.
  ///
  /// In ar, this message translates to:
  /// **'يراجع فريق سائقي ملفك. سنخبرك فور اعتماده وستنتقل الشاشة تلقائيًا.'**
  String get pendingBody;

  /// No description provided for @pendingSince.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل في {date}'**
  String pendingSince(String date);

  /// No description provided for @suspendedTitle.
  ///
  /// In ar, this message translates to:
  /// **'حسابك موقوف'**
  String get suspendedTitle;

  /// No description provided for @suspendedBody.
  ///
  /// In ar, this message translates to:
  /// **'تم تعليق حسابك مؤقتًا. تواصل مع الدعم لمعرفة التفاصيل.'**
  String get suspendedBody;

  /// No description provided for @hello.
  ///
  /// In ar, this message translates to:
  /// **'مرحبًا، {name}'**
  String hello(String name);

  /// No description provided for @availabilityOn.
  ///
  /// In ar, this message translates to:
  /// **'أنت متاح لاستقبال الطلبات'**
  String get availabilityOn;

  /// No description provided for @availabilityOff.
  ///
  /// In ar, this message translates to:
  /// **'أنت غير متاح حاليًا'**
  String get availabilityOff;

  /// No description provided for @availabilityToggleHint.
  ///
  /// In ar, this message translates to:
  /// **'فعّل الزر لتصلك الطلبات الجديدة.'**
  String get availabilityToggleHint;

  /// No description provided for @walletBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيد المحفظة'**
  String get walletBalance;

  /// No description provided for @lowBalanceWarning.
  ///
  /// In ar, this message translates to:
  /// **'رصيدك منخفض. اشحن محفظتك حتى لا تفوتك الطلبات.'**
  String get lowBalanceWarning;

  /// No description provided for @topUp.
  ///
  /// In ar, this message translates to:
  /// **'شحن المحفظة'**
  String get topUp;

  /// No description provided for @incomingRequests.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات الواردة'**
  String get incomingRequests;

  /// No description provided for @noIncomingRequests.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات حاليًا'**
  String get noIncomingRequests;

  /// No description provided for @noIncomingHint.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر الطلبات الجديدة هنا فورًا.'**
  String get noIncomingHint;

  /// No description provided for @upcomingTrips.
  ///
  /// In ar, this message translates to:
  /// **'رحلاتك القادمة'**
  String get upcomingTrips;

  /// No description provided for @seeAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get seeAll;

  /// No description provided for @requestDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الطلب'**
  String get requestDetails;

  /// No description provided for @commissionLabel.
  ///
  /// In ar, this message translates to:
  /// **'العمولة'**
  String get commissionLabel;

  /// No description provided for @acceptRequest.
  ///
  /// In ar, this message translates to:
  /// **'قبول الطلب'**
  String get acceptRequest;

  /// No description provided for @rejectRequest.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get rejectRequest;

  /// No description provided for @commissionNotice.
  ///
  /// In ar, this message translates to:
  /// **'ستُخصم عمولة {amount} ({rate}) من محفظتك عند القبول.'**
  String commissionNotice(String amount, String rate);

  /// No description provided for @balanceAfterAccept.
  ///
  /// In ar, this message translates to:
  /// **'رصيدك بعد القبول: {amount}'**
  String balanceAfterAccept(String amount);

  /// No description provided for @insufficientBalanceBlock.
  ///
  /// In ar, this message translates to:
  /// **'رصيدك ({balance}) لا يكفي لعمولة هذا الطلب ({commission}). اشحن محفظتك لتتمكن من القبول.'**
  String insufficientBalanceBlock(String balance, String commission);

  /// No description provided for @rechargeToAccept.
  ///
  /// In ar, this message translates to:
  /// **'شحن المحفظة'**
  String get rechargeToAccept;

  /// No description provided for @requestAccepted.
  ///
  /// In ar, this message translates to:
  /// **'تم قبول الطلب'**
  String get requestAccepted;

  /// No description provided for @requestRejectedMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض الطلب'**
  String get requestRejectedMsg;

  /// No description provided for @rejectConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد رفض هذا الطلب؟'**
  String get rejectConfirm;

  /// No description provided for @requestGone.
  ///
  /// In ar, this message translates to:
  /// **'لم يعد هذا الطلب متاحًا.'**
  String get requestGone;

  /// No description provided for @requestedBy.
  ///
  /// In ar, this message translates to:
  /// **'طلب من'**
  String get requestedBy;

  /// No description provided for @clientPaysDriver.
  ///
  /// In ar, this message translates to:
  /// **'يدفع العميل المبلغ للسائق مباشرة (نقدًا أو دفع هاتفي).'**
  String get clientPaysDriver;

  /// No description provided for @firstAcceptWins.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل هذا الطلب لعدة سائقين، والأول الذي يقبل يحصل عليه.'**
  String get firstAcceptWins;

  /// No description provided for @myTrips.
  ///
  /// In ar, this message translates to:
  /// **'رحلاتي'**
  String get myTrips;

  /// No description provided for @tripsUpcoming.
  ///
  /// In ar, this message translates to:
  /// **'القادمة'**
  String get tripsUpcoming;

  /// No description provided for @tripsHistory.
  ///
  /// In ar, this message translates to:
  /// **'السابقة'**
  String get tripsHistory;

  /// No description provided for @noTrips.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رحلات'**
  String get noTrips;

  /// No description provided for @tripDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الرحلة'**
  String get tripDetails;

  /// No description provided for @startEnRoute.
  ///
  /// In ar, this message translates to:
  /// **'أنا في الطريق'**
  String get startEnRoute;

  /// No description provided for @startTrip.
  ///
  /// In ar, this message translates to:
  /// **'بدء الرحلة'**
  String get startTrip;

  /// No description provided for @finishTrip.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء الرحلة'**
  String get finishTrip;

  /// No description provided for @cancelTrip.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الرحلة'**
  String get cancelTrip;

  /// No description provided for @cancelTripConfirm.
  ///
  /// In ar, this message translates to:
  /// **'ستُرجع العمولة إلى محفظتك. هل تريد الإلغاء؟'**
  String get cancelTripConfirm;

  /// No description provided for @tripCancelled.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الرحلة'**
  String get tripCancelled;

  /// No description provided for @statusUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الحالة'**
  String get statusUpdated;

  /// No description provided for @clientContact.
  ///
  /// In ar, this message translates to:
  /// **'التواصل مع العميل'**
  String get clientContact;

  /// No description provided for @scheduledFor.
  ///
  /// In ar, this message translates to:
  /// **'الموعد'**
  String get scheduledFor;

  /// No description provided for @agreedPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get agreedPrice;

  /// No description provided for @commissionDeducted.
  ///
  /// In ar, this message translates to:
  /// **'العمولة المخصومة'**
  String get commissionDeducted;

  /// No description provided for @wallet.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة'**
  String get wallet;

  /// No description provided for @transactions.
  ///
  /// In ar, this message translates to:
  /// **'العمليات'**
  String get transactions;

  /// No description provided for @noTransactions.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عمليات بعد'**
  String get noTransactions;

  /// No description provided for @topupRequests.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الشحن'**
  String get topupRequests;

  /// No description provided for @noTopups.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات شحن'**
  String get noTopups;

  /// No description provided for @requestTopup.
  ///
  /// In ar, this message translates to:
  /// **'طلب شحن'**
  String get requestTopup;

  /// No description provided for @topupAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ (أوقية)'**
  String get topupAmount;

  /// No description provided for @topupMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get topupMethod;

  /// No description provided for @topupReference.
  ///
  /// In ar, this message translates to:
  /// **'رقم العملية / المرجع'**
  String get topupReference;

  /// No description provided for @topupProof.
  ///
  /// In ar, this message translates to:
  /// **'صورة إثبات التحويل'**
  String get topupProof;

  /// No description provided for @topupSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب الشحن. سيُعتمد قريبًا.'**
  String get topupSubmitted;

  /// No description provided for @topupHowTo.
  ///
  /// In ar, this message translates to:
  /// **'أرسل المبلغ إلى أحد الحسابات التالية ثم أرفق إثبات التحويل.'**
  String get topupHowTo;

  /// No description provided for @minTopup.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى للشحن: {amount}'**
  String minTopup(String amount);

  /// No description provided for @accountNumber.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get accountNumber;

  /// No description provided for @balanceAfterTx.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد: {amount}'**
  String balanceAfterTx(String amount);

  /// No description provided for @howCommissionWorks.
  ///
  /// In ar, this message translates to:
  /// **'تُخصم العمولة من رصيدك عند قبول كل خدمة، وتُسترجع إذا أُلغيت.'**
  String get howCommissionWorks;

  /// No description provided for @noAccountConfigured.
  ///
  /// In ar, this message translates to:
  /// **'لم يحدد المشرف حسابات الدفع بعد.'**
  String get noAccountConfigured;

  /// No description provided for @refInPayment.
  ///
  /// In ar, this message translates to:
  /// **'رقم الحساب منسوخ'**
  String get refInPayment;

  /// No description provided for @myProfile.
  ///
  /// In ar, this message translates to:
  /// **'ملفي'**
  String get myProfile;

  /// No description provided for @statistics.
  ///
  /// In ar, this message translates to:
  /// **'الإحصاءات'**
  String get statistics;

  /// No description provided for @completedTrips.
  ///
  /// In ar, this message translates to:
  /// **'رحلات منجزة'**
  String get completedTrips;

  /// No description provided for @revenueGross.
  ///
  /// In ar, this message translates to:
  /// **'المبالغ المحصّلة'**
  String get revenueGross;

  /// No description provided for @commissionsPaid.
  ///
  /// In ar, this message translates to:
  /// **'العمولات المدفوعة'**
  String get commissionsPaid;

  /// No description provided for @revenueNet.
  ///
  /// In ar, this message translates to:
  /// **'الصافي'**
  String get revenueNet;

  /// No description provided for @ratingLabel.
  ///
  /// In ar, this message translates to:
  /// **'التقييم'**
  String get ratingLabel;

  /// No description provided for @reviewsReceived.
  ///
  /// In ar, this message translates to:
  /// **'التقييمات المستلمة'**
  String get reviewsReceived;

  /// No description provided for @noReviewsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تقييمات بعد'**
  String get noReviewsYet;

  /// No description provided for @publicProfile.
  ///
  /// In ar, this message translates to:
  /// **'ملفي العام'**
  String get publicProfile;

  /// No description provided for @publicProfileHint.
  ///
  /// In ar, this message translates to:
  /// **'هذا ما يراه العملاء عنك.'**
  String get publicProfileHint;

  /// No description provided for @editPersonalInfo.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المعلومات'**
  String get editPersonalInfo;

  /// No description provided for @myDocuments.
  ///
  /// In ar, this message translates to:
  /// **'مستنداتي'**
  String get myDocuments;

  /// No description provided for @helpAndReport.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة والإبلاغ'**
  String get helpAndReport;

  /// No description provided for @reportProblem.
  ///
  /// In ar, this message translates to:
  /// **'الإبلاغ عن مشكلة'**
  String get reportProblem;

  /// No description provided for @reportHint.
  ///
  /// In ar, this message translates to:
  /// **'صِف المشكلة بالتفصيل…'**
  String get reportHint;

  /// No description provided for @reportSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال بلاغك. سنتواصل معك.'**
  String get reportSent;

  /// No description provided for @contactSupportCall.
  ///
  /// In ar, this message translates to:
  /// **'اتصال بالدعم'**
  String get contactSupportCall;

  /// No description provided for @contactSupportWhatsapp.
  ///
  /// In ar, this message translates to:
  /// **'واتساب الدعم'**
  String get contactSupportWhatsapp;

  /// No description provided for @tapToEdit.
  ///
  /// In ar, this message translates to:
  /// **'اضغط للتعديل'**
  String get tapToEdit;

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

  /// No description provided for @err_driver_row_missing.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إنشاء ملف السائق.'**
  String get err_driver_row_missing;

  /// No description provided for @city.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get city;

  /// No description provided for @cities.
  ///
  /// In ar, this message translates to:
  /// **'المدن'**
  String get cities;

  /// No description provided for @serviceType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الخدمة'**
  String get serviceType;

  /// No description provided for @dateAndTime.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ والوقت'**
  String get dateAndTime;

  /// No description provided for @pickup.
  ///
  /// In ar, this message translates to:
  /// **'مكان الانطلاق'**
  String get pickup;

  /// No description provided for @dropoff.
  ///
  /// In ar, this message translates to:
  /// **'الوجهة'**
  String get dropoff;

  /// No description provided for @passengers.
  ///
  /// In ar, this message translates to:
  /// **'عدد الركاب'**
  String get passengers;

  /// No description provided for @notes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get notes;

  /// No description provided for @price.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get price;

  /// No description provided for @client.
  ///
  /// In ar, this message translates to:
  /// **'العميل'**
  String get client;

  /// No description provided for @driver.
  ///
  /// In ar, this message translates to:
  /// **'السائق'**
  String get driver;

  /// No description provided for @status.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get status;

  /// No description provided for @channel.
  ///
  /// In ar, this message translates to:
  /// **'القناة'**
  String get channel;

  /// No description provided for @createdBy.
  ///
  /// In ar, this message translates to:
  /// **'أنشأه'**
  String get createdBy;

  /// No description provided for @createdByAdmin.
  ///
  /// In ar, this message translates to:
  /// **'أنشأه المشرف'**
  String get createdByAdmin;

  /// No description provided for @reason.
  ///
  /// In ar, this message translates to:
  /// **'السبب'**
  String get reason;

  /// No description provided for @reasonHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب السبب'**
  String get reasonHint;

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
