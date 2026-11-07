// Libellés des énumérations (statuts, types, unités…)
export default {
  bookingStatus_pending: ['قيد الانتظار', 'En attente'],
  bookingStatus_accepted: ['مقبول', 'Acceptée'],
  bookingStatus_enRoute: ['السائق في الطريق', 'Chauffeur en route'],
  bookingStatus_inProgress: ['الرحلة جارية', 'En cours'],
  bookingStatus_completed: ['منتهية', 'Terminée'],
  bookingStatus_cancelled: ['ملغاة', 'Annulée'],
  bookingStatus_rejected: ['مرفوضة', 'Refusée'],
  bookingStatus_expired: ['انتهت المهلة', 'Expirée'],

  driverStatus_draft: ['مسودة', 'Brouillon'],
  driverStatus_pending: ['قيد المراجعة', 'En validation'],
  driverStatus_approved: ['معتمد', 'Validé'],
  driverStatus_rejected: ['مرفوض', 'Refusé'],
  driverStatus_suspended: ['موقوف', 'Suspendu'],

  accountStatus_active: ['نشط', 'Actif'],
  accountStatus_suspended: ['موقوف', 'Suspendu'],
  accountStatus_blocked: ['محظور', 'Bloqué'],

  documentType_idCard: ['بطاقة التعريف', 'Carte d\'identité'],
  documentType_drivingLicense: ['رخصة القيادة', 'Permis de conduire'],
  documentType_vehicleRegistration: ['البطاقة الرمادية', 'Carte grise'],
  documentType_insurance: ['التأمين', 'Assurance'],
  documentType_photo: ['صورة شخصية', 'Photo d\'identité'],

  documentStatus_pending: ['قيد المراجعة', 'En attente'],
  documentStatus_approved: ['مقبول', 'Validé'],
  documentStatus_rejected: ['مرفوض', 'Refusé'],

  channel_app: ['التطبيق', 'Application'],
  channel_phone: ['هاتف', 'Téléphone'],
  channel_whatsapp: ['واتساب', 'WhatsApp'],
  channel_other: ['أخرى', 'Autre'],

  txType_topup: ['شحن', 'Recharge'],
  txType_commission: ['عمولة', 'Commission'],
  txType_refund: ['استرجاع عمولة', 'Remboursement'],
  txType_adjustment: ['تعديل', 'Ajustement'],

  topupStatus_pending: ['قيد المراجعة', 'En attente'],
  topupStatus_approved: ['مقبول', 'Validée'],
  topupStatus_rejected: ['مرفوض', 'Refusée'],

  complaintStatus_open: ['مفتوحة', 'Ouverte'],
  complaintStatus_inReview: ['قيد المعالجة', 'En cours'],
  complaintStatus_resolved: ['تمت المعالجة', 'Résolue'],
  complaintStatus_dismissed: ['مرفوضة', 'Classée'],

  priceUnit_perTrip: ['للرحلة', 'par course'],
  priceUnit_perHour: ['للساعة', 'par heure'],
  priceUnit_perDay: ['لليوم', 'par jour'],
  priceUnitLabel_perTrip: ['السعر للرحلة', 'Prix par course'],
  priceUnitLabel_perHour: ['السعر للساعة', 'Prix par heure'],
  priceUnitLabel_perDay: ['السعر لليوم', 'Prix par jour'],

  adminRole_superAdmin: ['مشرف عام', 'Super admin'],
  adminRole_validator: ['مدقق ملفات', 'Validateur'],
  adminRole_support: ['دعم', 'Support'],

  vehicleType_sedan: ['سيدان', 'Berline'],
  vehicleType_suv: ['سيارة دفع (SUV)', 'SUV'],
  vehicleType_4x4: ['دفع رباعي', '4×4'],
  vehicleType_van: ['فان', 'Van'],
  vehicleType_minibus: ['حافلة صغيرة', 'Minibus'],
  vehicleType_bus: ['حافلة', 'Bus'],
  vehicleType_pickup: ['بيك أب', 'Pick-up'],

  weekday_1: ['الإثنين', 'Lundi'],
  weekday_2: ['الثلاثاء', 'Mardi'],
  weekday_3: ['الأربعاء', 'Mercredi'],
  weekday_4: ['الخميس', 'Jeudi'],
  weekday_5: ['الجمعة', 'Vendredi'],
  weekday_6: ['السبت', 'Samedi'],
  weekday_7: ['الأحد', 'Dimanche'],

  audience_drivers: ['السائقون', 'Chauffeurs'],
  audience_clients: ['العملاء', 'Clients'],
  audience_all: ['الجميع', 'Tout le monde'],

  sort_rating: ['الأعلى تقييمًا', 'Mieux notés'],
  sort_priceAsc: ['الأرخص أولًا', 'Prix croissant'],
  sort_priceDesc: ['الأغلى أولًا', 'Prix décroissant'],
  sort_trips: ['الأكثر رحلات', 'Plus de courses'],
};
