-- =============================================================================
-- SAIQI — 10 : données de référence (idempotentes) indispensables en production
-- (réglages par défaut, villes, types de services, modèles de notification)
-- =============================================================================

insert into public.app_settings (key, value) values
  ('default_commission_rate', '0.10'::jsonb),
  ('response_timeout_minutes', '10'::jsonb),
  ('low_balance_threshold', '100'::jsonb),
  ('min_topup_amount', '100'::jsonb),
  ('support_phone', '""'::jsonb),
  ('support_whatsapp', '""'::jsonb),
  ('topup_methods', '[
      {"id":"bankily","name_ar":"بنكيلي","name_fr":"Bankily","account":""},
      {"id":"masrvi","name_ar":"مصرفي","name_fr":"Masrvi","account":""},
      {"id":"sedad","name_ar":"سداد","name_fr":"Sedad","account":""},
      {"id":"cash","name_ar":"نقدًا","name_fr":"Espèces","account":""}
    ]'::jsonb)
on conflict (key) do nothing;

insert into public.cities (name_ar, name_fr, sort_order) values
  ('نواكشوط', 'Nouakchott', 1),
  ('نواذيبو', 'Nouadhibou', 2),
  ('كيفه', 'Kiffa', 3),
  ('روصو', 'Rosso', 4),
  ('أطار', 'Atar', 5),
  ('ازويرات', 'Zouérat', 6)
on conflict (name_fr) do nothing;

insert into public.service_types (name_ar, name_fr, icon, is_active, sort_order) values
  ('سيارة أجرة', 'Taxi', 'local_taxi', true, 1),
  ('سيارة خاصة', 'Voiture privée', 'directions_car', true, 2),
  ('دفع رباعي', '4×4', 'terrain', true, 3),
  ('نقل بين المدن', 'Interurbain', 'route', true, 4),
  ('سائق أعمال', 'Chauffeur d''affaires', 'business_center', true, 5),
  ('أعراس ومناسبات', 'Mariages / Événements', 'celebration', true, 6),
  ('نقل الموظفين', 'Transport du personnel', 'groups', true, 7),
  ('توصيل', 'Livraison', 'delivery_dining', false, 8)
on conflict (name_fr) do nothing;

-- Modèles de notification (placeholders {nom} remplacés par public.notify)
insert into public.notification_templates (key, lang, title, body) values
  ('booking_requested', 'ar', 'طلب حجز جديد', '{client} — {price} أوقية'),
  ('booking_requested', 'fr', 'Nouvelle demande', '{client} — {price} MRU'),
  ('booking_accepted', 'ar', 'تم قبول حجزك', 'قبل السائق طلبك. يمكنك الآن التواصل معه.'),
  ('booking_accepted', 'fr', 'Réservation acceptée', 'Le chauffeur a accepté votre demande. Vous pouvez le contacter.'),
  ('booking_accepted_admin', 'ar', 'تم قبول الطلب', 'قبل سائق طلب {client}.'),
  ('booking_accepted_admin', 'fr', 'Demande acceptée', 'Un chauffeur a accepté la demande de {client}.'),
  ('wallet_low', 'ar', 'رصيدك منخفض', 'رصيدك الحالي {balance} أوقية. اشحن محفظتك لتتمكن من قبول الطلبات.'),
  ('wallet_low', 'fr', 'Solde faible', 'Votre solde est de {balance} MRU. Rechargez pour continuer à accepter des demandes.'),
  ('booking_rejected', 'ar', 'تعذر تأكيد الحجز', 'رفض السائق طلبك. يمكنك اختيار سائق آخر.'),
  ('booking_rejected', 'fr', 'Demande refusée', 'Le chauffeur a refusé votre demande. Vous pouvez en choisir un autre.'),
  ('booking_rejected_admin', 'ar', 'رُفض الطلب', 'رفض جميع السائقين طلب {client}.'),
  ('booking_rejected_admin', 'fr', 'Demande refusée', 'Tous les chauffeurs ont refusé la demande de {client}.'),
  ('booking_en_route', 'ar', 'السائق في الطريق', 'السائق في طريقه إليك.'),
  ('booking_en_route', 'fr', 'Chauffeur en route', 'Votre chauffeur est en route.'),
  ('booking_in_progress', 'ar', 'بدأت الرحلة', 'الرحلة جارية الآن.'),
  ('booking_in_progress', 'fr', 'Course démarrée', 'Votre course est en cours.'),
  ('booking_completed', 'ar', 'انتهت الرحلة', 'قيّم السائق لمساعدة الآخرين.'),
  ('booking_completed', 'fr', 'Course terminée', 'Pensez à évaluer votre chauffeur.'),
  ('booking_cancelled', 'ar', 'تم إلغاء الحجز', 'السبب: {reason}'),
  ('booking_cancelled', 'fr', 'Réservation annulée', 'Motif : {reason}'),
  ('booking_cancelled_admin', 'ar', 'تم إلغاء الطلب', 'أُلغي طلب {client}.'),
  ('booking_cancelled_admin', 'fr', 'Demande annulée', 'La demande de {client} a été annulée.'),
  ('booking_expired', 'ar', 'انتهت مهلة الطلب', 'لم يرد أي سائق في الوقت المحدد. جرّب سائقًا آخر.'),
  ('booking_expired', 'fr', 'Demande expirée', 'Aucun chauffeur n''a répondu à temps. Essayez un autre chauffeur.'),
  ('booking_expired_admin', 'ar', 'انتهت مهلة طلب', 'لم يرد أي سائق على طلب {client}.'),
  ('booking_expired_admin', 'fr', 'Demande expirée', 'Aucun chauffeur n''a répondu à la demande de {client}.'),
  ('topup_requested', 'ar', 'طلب شحن جديد', 'طلب سائق شحن {amount} أوقية.'),
  ('topup_requested', 'fr', 'Nouvelle recharge', 'Un chauffeur demande une recharge de {amount} MRU.'),
  ('new_review', 'ar', 'تقييم جديد', 'حصلت على {rating} من 5.'),
  ('new_review', 'fr', 'Nouvel avis', 'Vous avez reçu {rating}/5.'),
  ('complaint_filed', 'ar', 'شكوى جديدة', 'تم تقديم شكوى جديدة.'),
  ('complaint_filed', 'fr', 'Nouvelle plainte', 'Une nouvelle plainte a été déposée.'),
  ('driver_submitted', 'ar', 'ملف سائق جديد', '{name} أرسل ملفه للمراجعة.'),
  ('driver_submitted', 'fr', 'Nouveau dossier chauffeur', '{name} a soumis son dossier.'),
  ('driver_approved', 'ar', 'تم قبول ملفك', 'مرحبًا بك في سائقي! اشحن محفظتك لبدء استقبال الطلبات.'),
  ('driver_approved', 'fr', 'Dossier validé', 'Bienvenue sur SAIQI ! Rechargez votre portefeuille pour recevoir des demandes.'),
  ('driver_rejected', 'ar', 'تم رفض ملفك', 'السبب: {reason}'),
  ('driver_rejected', 'fr', 'Dossier refusé', 'Motif : {reason}'),
  ('document_rejected', 'ar', 'وثيقة مرفوضة', 'السبب: {reason}'),
  ('document_rejected', 'fr', 'Document refusé', 'Motif : {reason}'),
  ('driver_suspended', 'ar', 'تم تعليق حسابك', 'السبب: {reason}'),
  ('driver_suspended', 'fr', 'Compte suspendu', 'Motif : {reason}'),
  ('driver_reinstated', 'ar', 'تمت إعادة تفعيل حسابك', 'يمكنك استقبال الطلبات من جديد.'),
  ('driver_reinstated', 'fr', 'Compte réactivé', 'Vous pouvez de nouveau recevoir des demandes.'),
  ('account_status_changed', 'ar', 'تغيير حالة الحساب', 'الحالة: {status}. {reason}'),
  ('account_status_changed', 'fr', 'Statut du compte modifié', 'Statut : {status}. {reason}'),
  ('topup_approved', 'ar', 'تم شحن محفظتك', 'تمت إضافة {amount} أوقية إلى رصيدك.'),
  ('topup_approved', 'fr', 'Recharge validée', '{amount} MRU ajoutés à votre solde.'),
  ('topup_rejected', 'ar', 'تم رفض طلب الشحن', 'السبب: {reason}'),
  ('topup_rejected', 'fr', 'Recharge refusée', 'Motif : {reason}'),
  ('wallet_adjusted', 'ar', 'تعديل على محفظتك', '{amount} أوقية — {reason}'),
  ('wallet_adjusted', 'fr', 'Ajustement du portefeuille', '{amount} MRU — {reason}'),
  ('booking_reassigned_away', 'ar', 'تم تحويل الحجز', 'تم تحويل الطلب إلى سائق آخر وأُعيدت العمولة.'),
  ('booking_reassigned_away', 'fr', 'Réservation réaffectée', 'La demande a été confiée à un autre chauffeur ; la commission a été restituée.'),
  ('booking_reassigned', 'ar', 'تغيير السائق', 'نبحث لك عن سائق جديد لحجزك.'),
  ('booking_reassigned', 'fr', 'Changement de chauffeur', 'Nous recherchons un nouveau chauffeur pour votre réservation.'),
  ('complaint_updated', 'ar', 'تحديث بشأن شكواك', 'الحالة: {status}'),
  ('complaint_updated', 'fr', 'Mise à jour de votre plainte', 'Statut : {status}')
on conflict (key, lang) do update set title = excluded.title, body = excluded.body;
