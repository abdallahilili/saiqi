// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get adminBadge => 'Espace admin';

  @override
  String get noPermission => 'Vous n\'avez pas accès à cette page';

  @override
  String get more => 'Plus';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get driversTitle => 'Chauffeurs';

  @override
  String get bookingsTitle => 'Réservations';

  @override
  String get walletsTitle => 'Portefeuilles';

  @override
  String get kpiPendingDrivers => 'Dossiers en attente';

  @override
  String get kpiNewDrivers => 'Nouveaux chauffeurs (7 j)';

  @override
  String get kpiApprovedDrivers => 'Chauffeurs validés';

  @override
  String get kpiClients => 'Clients';

  @override
  String get kpiBookingsToday => 'Réservations du jour';

  @override
  String get kpiPendingBookings => 'Réservations en attente';

  @override
  String get kpiCommissionsToday => 'Commissions du jour';

  @override
  String get kpiCommissionsTotal => 'Commissions totales';

  @override
  String get kpiOpenComplaints => 'Plaintes ouvertes';

  @override
  String get kpiPendingTopups => 'Recharges en attente';

  @override
  String get searchPeople => 'Rechercher un nom ou un numéro';

  @override
  String get addDriver => 'Ajouter un chauffeur';

  @override
  String get addDriverIntro =>
      'Le compte est créé en brouillon ; le chauffeur complète son dossier puis le soumet.';

  @override
  String get driverCreatedMsg => 'Compte chauffeur créé';

  @override
  String get driverDetail => 'Dossier chauffeur';

  @override
  String get approveDriver => 'Valider le chauffeur';

  @override
  String get rejectDriver => 'Refuser le dossier';

  @override
  String get rejectReasonTitle => 'Motif du refus (visible par le chauffeur)';

  @override
  String get driverApprovedMsg => 'Chauffeur validé';

  @override
  String get driverRejectedMsg => 'Dossier refusé';

  @override
  String get suspendDriver => 'Suspendre le chauffeur';

  @override
  String get reinstateDriver => 'Réactiver le chauffeur';

  @override
  String get suspendReasonTitle => 'Motif de la suspension';

  @override
  String get accountActions => 'Actions sur le compte';

  @override
  String get suspendAccount => 'Suspendre le compte';

  @override
  String get blockAccount => 'Bloquer le compte';

  @override
  String get reactivateAccount => 'Réactiver le compte';

  @override
  String get accountStatusChanged => 'Statut du compte mis à jour';

  @override
  String get noDocuments => 'Aucun document envoyé';

  @override
  String get noVehicle => 'Aucun véhicule enregistré';

  @override
  String get noServicesAdmin => 'Aucun service';

  @override
  String get approveDocument => 'Valider le document';

  @override
  String get rejectDocument => 'Refuser le document';

  @override
  String get documentApprovedMsg => 'Document validé';

  @override
  String get documentRejectedMsg => 'Document refusé';

  @override
  String get rejectDocReasonTitle => 'Motif du refus du document';

  @override
  String get filterPending => 'En attente';

  @override
  String documentsProgress(String count) {
    return '$count document(s)';
  }

  @override
  String joinedOn(String date) {
    return 'Inscrit le $date';
  }

  @override
  String get driverNotFound => 'Chauffeur introuvable';

  @override
  String get filterStatus => 'Statut';

  @override
  String get filterChannel => 'Canal';

  @override
  String get filterCity => 'Ville';

  @override
  String get filterDate => 'Date';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get bookingDetail => 'Détail de la réservation';

  @override
  String get noBookings => 'Aucune réservation';

  @override
  String get offersSent => 'Offres envoyées';

  @override
  String get offerStatus_pending => 'En attente';

  @override
  String get offerStatus_accepted => 'A accepté';

  @override
  String get offerStatus_declined => 'A refusé';

  @override
  String get offerStatus_expired => 'Expiré';

  @override
  String get reassignDriver => 'Changer de chauffeur';

  @override
  String get reassignedMsg => 'Demande renvoyée aux chauffeurs choisis';

  @override
  String get cancelBookingAdmin => 'Annuler la réservation';

  @override
  String get cancelReasonPrompt => 'Motif de l\'annulation';

  @override
  String get bookingCancelledMsg => 'Réservation annulée';

  @override
  String get contactClient => 'Contacter le client';

  @override
  String get contactDriver => 'Contacter le chauffeur';

  @override
  String get guestClient => 'Client sans compte';

  @override
  String get registeredClient => 'Client inscrit';

  @override
  String get noDriverAssigned => 'Aucun chauffeur assigné';

  @override
  String get createRequest => 'Créer une demande';

  @override
  String get newRequest => 'Nouvelle demande client';

  @override
  String get newRequestIntro =>
      'Créez une demande pour un client qui vous a appelé ou écrit, puis envoyez-la à un ou plusieurs chauffeurs.';

  @override
  String get clientNameLabel => 'Nom du client';

  @override
  String get clientPhoneLabel => 'Téléphone du client';

  @override
  String get agreedPriceField => 'Prix convenu (MRU)';

  @override
  String get originChannel => 'Canal d\'origine';

  @override
  String get chooseDrivers => 'Choisir les chauffeurs';

  @override
  String get driversInCityHint =>
      'Chauffeurs validés proposant ce service dans la ville choisie';

  @override
  String get onlyAvailable => 'Disponibles seulement';

  @override
  String get noDriversFound => 'Aucun chauffeur correspondant';

  @override
  String selectedCount(String count) {
    return '$count sélectionné(s)';
  }

  @override
  String get selectAtLeastOneDriver => 'Choisissez au moins un chauffeur';

  @override
  String get sendRequest => 'Créer et envoyer la demande';

  @override
  String get requestCreatedMsg => 'Demande créée et envoyée';

  @override
  String get multiDriverHint =>
      'Avec plusieurs chauffeurs, le premier qui accepte obtient la demande.';

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String get topupsTitle => 'Demandes de recharge';

  @override
  String get noTopupsAdmin => 'Aucune demande de recharge';

  @override
  String get approveTopup => 'Valider la recharge';

  @override
  String get rejectTopup => 'Refuser la recharge';

  @override
  String get topupApprovedMsg => 'Portefeuille crédité';

  @override
  String get topupRejectedMsg => 'Demande refusée';

  @override
  String get topupNoteHint => 'Note (facultatif)';

  @override
  String get proofImage => 'Preuve de paiement';

  @override
  String get noProof => 'Aucune preuve jointe';

  @override
  String get adjustWallet => 'Ajuster le solde';

  @override
  String get adjustAmountHint =>
      'Montant positif pour créditer, négatif pour débiter';

  @override
  String get adjustNote => 'Motif de l\'ajustement';

  @override
  String get adjustDone => 'Solde ajusté';

  @override
  String get walletHistory => 'Historique du portefeuille';

  @override
  String get driversWallets => 'Portefeuilles des chauffeurs';

  @override
  String get referenceLabel => 'Référence';

  @override
  String get methodLabel => 'Méthode';

  @override
  String get commissionsTitle => 'Commissions';

  @override
  String get defaultRate => 'Taux par défaut';

  @override
  String get rateOverrides => 'Taux spécifiques';

  @override
  String get rateByService => 'Par service';

  @override
  String get rateByCity => 'Par ville';

  @override
  String get rateByServiceCity => 'Par service et ville';

  @override
  String get addRate => 'Ajouter un taux';

  @override
  String get rateField => 'Taux (%)';

  @override
  String get rateInvalid => 'Saisissez un taux entre 0 et 100';

  @override
  String get rateSaved => 'Taux enregistré';

  @override
  String get rateNeedsScope => 'Choisissez un service, une ville ou les deux';

  @override
  String get ratePriorityNote =>
      'Priorité : service+ville, puis service, puis ville, puis taux par défaut.';

  @override
  String get commissionHistory => 'Historique des commissions';

  @override
  String get noCommissions => 'Aucune commission';

  @override
  String get refundedLabel => 'Remboursée';

  @override
  String get generalSettings => 'Réglages généraux';

  @override
  String get responseTimeout => 'Délai de réponse du chauffeur (min)';

  @override
  String get lowBalanceThresholdField => 'Seuil d\'alerte solde faible (MRU)';

  @override
  String get minTopupField => 'Recharge minimale (MRU)';

  @override
  String get supportPhoneField => 'Téléphone du support';

  @override
  String get supportWhatsappField => 'WhatsApp du support';

  @override
  String get topupAccountsTitle => 'Comptes de réception des recharges';

  @override
  String get accountHint => 'Numéro de compte';

  @override
  String get settingsSaved => 'Réglages enregistrés';

  @override
  String get complaintsTitle => 'Plaintes';

  @override
  String get noComplaints => 'Aucune plainte';

  @override
  String get complaintDetail => 'Détail de la plainte';

  @override
  String get complaintAuthor => 'Auteur';

  @override
  String get complaintAgainst => 'Concerné';

  @override
  String get resolutionField => 'Décision / réponse';

  @override
  String get markInReview => 'Mettre en cours';

  @override
  String get resolveComplaint => 'Marquer résolue';

  @override
  String get dismissComplaint => 'Classer sans suite';

  @override
  String get complaintUpdatedMsg => 'Plainte mise à jour';

  @override
  String get warnUser => 'Envoyer un avertissement';

  @override
  String get warnMessageHint => 'Texte de l\'avertissement';

  @override
  String get warnSentMsg => 'Avertissement envoyé';

  @override
  String get warningTitle => 'Avertissement de l\'administration';

  @override
  String get reviewsModeration => 'Modération des avis';

  @override
  String get hideReview => 'Masquer';

  @override
  String get showReview => 'Afficher';

  @override
  String get reviewHidden => 'Masqué';

  @override
  String get noReviewsAdmin => 'Aucun avis';

  @override
  String reviewFor(String name) {
    return 'Sur le chauffeur $name';
  }

  @override
  String get clientsTitle => 'Clients';

  @override
  String get noClients => 'Aucun client';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get newPasswordPrompt => 'Nouveau mot de passe (8 caractères min.)';

  @override
  String get passwordResetDone => 'Mot de passe réinitialisé';

  @override
  String get userDetail => 'Détail du compte';

  @override
  String get catalogTitle => 'Villes et services';

  @override
  String get citiesTitle => 'Villes';

  @override
  String get servicesTitle => 'Services';

  @override
  String get addCity => 'Ajouter une ville';

  @override
  String get editCity => 'Modifier la ville';

  @override
  String get addServiceType => 'Ajouter un service';

  @override
  String get editServiceType => 'Modifier le service';

  @override
  String get nameArField => 'Nom en arabe';

  @override
  String get nameFrField => 'Nom en français';

  @override
  String get iconField => 'Icône';

  @override
  String get activeField => 'Actif';

  @override
  String get deleteBlocked =>
      'Suppression impossible : des données y sont liées. Désactivez-le plutôt.';

  @override
  String get deleteConfirm => 'Supprimer définitivement ?';

  @override
  String get teamTitle => 'Équipe admin';

  @override
  String get addMember => 'Ajouter un membre';

  @override
  String get roleField => 'Rôle';

  @override
  String get memberCreated => 'Compte créé';

  @override
  String get changeRole => 'Changer le rôle';

  @override
  String get roleChanged => 'Rôle modifié';

  @override
  String get roleSuperAdminDesc => 'Tous les droits';

  @override
  String get roleValidatorDesc => 'Validation des dossiers chauffeurs';

  @override
  String get roleSupportDesc => 'Réservations, recharges, plaintes, clients';

  @override
  String get auditTitle => 'Journal d\'audit';

  @override
  String get noAudit => 'Aucune opération enregistrée';

  @override
  String by(String name) {
    return 'par $name';
  }

  @override
  String get announcementsTitle => 'Annonces';

  @override
  String get newAnnouncement => 'Nouvelle annonce';

  @override
  String get audienceField => 'Public cible';

  @override
  String get announcementTitleField => 'Titre';

  @override
  String get announcementBodyField => 'Texte';

  @override
  String get announcementSentMsg => 'Annonce envoyée';

  @override
  String recipientsCount(String count) {
    return '$count destinataire(s)';
  }

  @override
  String get noAnnouncements => 'Aucune annonce';

  @override
  String get audit_approve_driver => 'Validation chauffeur';

  @override
  String get audit_reject_driver => 'Refus dossier chauffeur';

  @override
  String get audit_review_document => 'Revue de document';

  @override
  String get audit_set_driver_status => 'Statut chauffeur modifié';

  @override
  String get audit_set_account_status => 'Statut de compte modifié';

  @override
  String get audit_set_admin_role => 'Rôle admin modifié';

  @override
  String get audit_review_topup => 'Traitement de recharge';

  @override
  String get audit_adjust_wallet => 'Ajustement de solde';

  @override
  String get audit_create_booking => 'Création de demande';

  @override
  String get audit_reassign_booking => 'Changement de chauffeur';

  @override
  String get audit_cancel_booking => 'Annulation de réservation';

  @override
  String get audit_handle_complaint => 'Traitement de plainte';

  @override
  String get audit_moderate_review => 'Modération d\'avis';

  @override
  String get audit_send_announcement => 'Envoi d\'annonce';

  @override
  String get audit_reset_password => 'Réinitialisation de mot de passe';

  @override
  String get audit_create_admin => 'Création d\'admin';

  @override
  String get audit_create_driver => 'Création de chauffeur';

  @override
  String get audit_warn_user => 'Avertissement utilisateur';

  @override
  String get audit_insert => 'Ajout';

  @override
  String get audit_update => 'Modification';

  @override
  String get audit_delete => 'Suppression';

  @override
  String get phoneLabel => 'Numéro de téléphone';

  @override
  String get phoneHint => 'ex. 36 12 34 56';

  @override
  String get phonePrefix => '+222';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get confirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get fullNameLabel => 'Nom complet';

  @override
  String get login => 'Se connecter';

  @override
  String get register => 'Créer un compte';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get noAccountYet => 'Pas encore de compte ?';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get logoutConfirm => 'Voulez-vous vous déconnecter ?';

  @override
  String get loginTitle => 'Bon retour';

  @override
  String get loginSubtitle =>
      'Connectez-vous avec votre numéro et votre mot de passe';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get registerSubtitle =>
      'Saisissez votre numéro et choisissez un mot de passe';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmNewPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get passwordChanged => 'Mot de passe modifié';

  @override
  String get passwordHint => '8 caractères minimum';

  @override
  String get vFieldRequired => 'Ce champ est obligatoire';

  @override
  String get vPhoneInvalid =>
      'Saisissez un numéro mauritanien valide de 8 chiffres';

  @override
  String get vPasswordMin =>
      'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get vPasswordsMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get vNumberInvalid => 'Saisissez un nombre valide';

  @override
  String get vAmountPositive => 'Saisissez un montant supérieur à zéro';

  @override
  String get accountSuspendedTitle => 'Compte suspendu';

  @override
  String get accountSuspendedBody =>
      'Votre compte est suspendu. Contactez le support pour plus d\'informations.';

  @override
  String get accountBlockedBody =>
      'Votre compte est bloqué. Contactez le support pour plus d\'informations.';

  @override
  String get roleDriver => 'Chauffeur';

  @override
  String get roleClient => 'Client';

  @override
  String get roleAdmin => 'Administrateur';

  @override
  String get clientBadge => 'Espace client';

  @override
  String get findDriverTitle => 'Trouvez votre chauffeur';

  @override
  String get findDriverSubtitle =>
      'Des chauffeurs vérifiés dans votre ville, à tarifs clairs';

  @override
  String get chooseCity => 'Choisissez votre ville';

  @override
  String get whatDoYouNeed => 'De quoi avez-vous besoin ?';

  @override
  String get searchDrivers => 'Voir les chauffeurs';

  @override
  String get noServiceTypes => 'Aucun service disponible pour le moment';

  @override
  String driversFoundCount(String count) {
    return '$count chauffeur(s)';
  }

  @override
  String get noDriversHint =>
      'Essayez d\'élargir les filtres, de changer de ville ou d\'afficher les indisponibles.';

  @override
  String get driversListTitle => 'Chauffeurs';

  @override
  String get priceRangeLabel => 'Fourchette de prix (MRU)';

  @override
  String get minPriceField => 'Min';

  @override
  String get maxPriceField => 'Max';

  @override
  String get minRatingLabel => 'Note minimale';

  @override
  String get minSeatsLabel => 'Places minimum';

  @override
  String get anyValue => 'Tous';

  @override
  String get showUnavailable => 'Afficher aussi les indisponibles';

  @override
  String activeFilters(String count) {
    return '$count filtre(s) actif(s)';
  }

  @override
  String get aboutDriver => 'À propos';

  @override
  String get tariffs => 'Tarifs';

  @override
  String get noTariffs => 'Aucun tarif publié';

  @override
  String get reviewsTitle => 'Avis';

  @override
  String get noReviewsClient => 'Aucun avis pour le moment';

  @override
  String get bookNow => 'Réserver';

  @override
  String get addFavorite => 'Ajouter aux favoris';

  @override
  String get removeFavorite => 'Retirer des favoris';

  @override
  String get favoriteAdded => 'Ajouté aux favoris';

  @override
  String get favoriteRemoved => 'Retiré des favoris';

  @override
  String get servesCities => 'Villes';

  @override
  String get tripsDone => 'courses réalisées';

  @override
  String get driverNotFoundClient => 'Ce chauffeur n\'est plus disponible';

  @override
  String get bookingRequestTitle => 'Demande de réservation';

  @override
  String get estimatedPrice => 'Prix estimé';

  @override
  String get payDriverDirectly =>
      'Vous payez directement le chauffeur (espèces ou paiement mobile). L\'application ne reçoit aucun paiement.';

  @override
  String get submitBooking => 'Envoyer la demande';

  @override
  String get bookingSentMsg => 'Votre demande a été envoyée au chauffeur';

  @override
  String get pickupHint => 'ex. Aéroport, Tevragh Zeina…';

  @override
  String get serviceNotInCity => 'Ce chauffeur ne dessert pas cette ville';

  @override
  String maxPassengersHint(String count) {
    return 'Jusqu\'à $count passager(s)';
  }

  @override
  String get completeNameFirst =>
      'Ajoutez votre nom pour que le chauffeur vous identifie';

  @override
  String get myBookings => 'Mes réservations';

  @override
  String get bookingsActive => 'En cours';

  @override
  String get bookingsPast => 'Passées';

  @override
  String get noBookingsClient => 'Aucune réservation pour l\'instant';

  @override
  String get noBookingsClientHint =>
      'Trouvez un chauffeur et envoyez votre première demande.';

  @override
  String get trackBooking => 'Suivi de la réservation';

  @override
  String get waitingDriverTitle => 'En attente de la réponse du chauffeur';

  @override
  String get waitingDriverHint =>
      'Nous vous prévenons dès sa réponse. Sans réponse dans le délai, la demande expire.';

  @override
  String get yourDriver => 'Votre chauffeur';

  @override
  String get contactDriverTitle => 'Contacter le chauffeur';

  @override
  String get contactAfterAccept =>
      'Le numéro du chauffeur apparaît après acceptation.';

  @override
  String get cancelBooking => 'Annuler la réservation';

  @override
  String get cancelBookingConfirm => 'Voulez-vous annuler cette réservation ?';

  @override
  String get cancelUnavailableEnRoute =>
      'L\'annulation n\'est plus possible une fois le chauffeur en route.';

  @override
  String get bookingCancelledClient => 'Réservation annulée';

  @override
  String get suggestOthers => 'Autres chauffeurs suggérés';

  @override
  String get bookingRejectedHint =>
      'Le chauffeur a refusé. Choisissez-en un autre :';

  @override
  String get bookingExpiredHint =>
      'Délai écoulé sans réponse. Essayez un autre chauffeur :';

  @override
  String get noAlternatives => 'Aucun chauffeur alternatif pour le moment';

  @override
  String get rateDriver => 'Évaluer le chauffeur';

  @override
  String get ratingCommentHint => 'Votre commentaire (facultatif)';

  @override
  String get submitReview => 'Envoyer l\'avis';

  @override
  String get reviewThanks => 'Merci pour votre avis';

  @override
  String get yourReview => 'Votre avis';

  @override
  String get tapStarToRate => 'Touchez une étoile pour noter';

  @override
  String get fileComplaint => 'Déposer une plainte';

  @override
  String get complaintHint => 'Expliquez le problème…';

  @override
  String get complaintSentMsg => 'Plainte envoyée, nous l\'examinons';

  @override
  String get favoritesTitle => 'Favoris';

  @override
  String get noFavorites => 'Aucun chauffeur favori';

  @override
  String get noFavoritesHint =>
      'Touchez le cœur sur la fiche d\'un chauffeur pour le retrouver ici.';

  @override
  String get myAccount => 'Mon compte';

  @override
  String get editName => 'Nom';

  @override
  String get nameHelp =>
      'Votre nom est visible du chauffeur lors d\'une réservation';

  @override
  String get helpClient => 'Aide et support';

  @override
  String get appName => 'SAIQI';

  @override
  String get appTagline => 'Votre chauffeur de confiance en Mauritanie';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get add => 'Ajouter';

  @override
  String get retry => 'Réessayer';

  @override
  String get close => 'Fermer';

  @override
  String get back => 'Retour';

  @override
  String get next => 'Suivant';

  @override
  String get confirm => 'Confirmer';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get search => 'Rechercher';

  @override
  String get filters => 'Filtres';

  @override
  String get sortBy => 'Trier par';

  @override
  String get apply => 'Appliquer';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get done => 'Terminé';

  @override
  String get send => 'Envoyer';

  @override
  String get submit => 'Soumettre';

  @override
  String get refresh => 'Actualiser';

  @override
  String get details => 'Détails';

  @override
  String get call => 'Appeler';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get copy => 'Copier';

  @override
  String get copied => 'Copié';

  @override
  String get select => 'Choisir';

  @override
  String get change => 'Changer';

  @override
  String get optional => 'Facultatif';

  @override
  String get all => 'Tous';

  @override
  String get none => 'Aucun';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get tomorrow => 'Demain';

  @override
  String get loading => 'Chargement…';

  @override
  String get noData => 'Aucune donnée';

  @override
  String get somethingWrong => 'Une erreur est survenue';

  @override
  String get currencyMru => 'MRU';

  @override
  String amountMru(String amount) {
    return '$amount MRU';
  }

  @override
  String get pickPhoto => 'Choisir une photo';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get fromGallery => 'Depuis la galerie';

  @override
  String get photoUploaded => 'Photo envoyée';

  @override
  String get uploading => 'Envoi en cours…';

  @override
  String get viewDocument => 'Voir le document';

  @override
  String get pinchToZoom => 'Pincez pour zoomer';

  @override
  String get language => 'Langue';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageFrench => 'Français';

  @override
  String get chooseLanguage => 'Choisissez votre langue';

  @override
  String get theme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get settings => 'Paramètres';

  @override
  String get profile => 'Profil';

  @override
  String get home => 'Accueil';

  @override
  String get help => 'Aide';

  @override
  String get contactSupport => 'Contacter le support';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get newNotification => 'Nouvelle notification';

  @override
  String get notificationChannelName => 'Notifications SAIQI';

  @override
  String get day => 'jour';

  @override
  String get minutesShort => 'min';

  @override
  String get secondsShort => 'sec';

  @override
  String expiresIn(String time) {
    return 'Expire dans $time';
  }

  @override
  String get expired => 'Délai écoulé';

  @override
  String dateTimeAt(String date, String time) {
    return '$date à $time';
  }

  @override
  String get confirmActionTitle => 'Confirmer l\'action';

  @override
  String get areYouSure => 'Êtes-vous sûr ?';

  @override
  String get configMissingTitle => 'Configuration manquante';

  @override
  String get configMissingBody =>
      'SUPABASE_URL et SUPABASE_PUBLISHABLE_KEY ne sont pas définis. Lancez l\'app avec --dart-define-from-file=.env';

  @override
  String get driverBadge => 'Espace chauffeur';

  @override
  String get saved => 'Enregistré';

  @override
  String get applicationTitle => 'Dossier chauffeur';

  @override
  String get applicationIntro =>
      'Complétez votre dossier pour validation. L\'inscription est gratuite : SAIQI prélève une commission uniquement sur chaque service accepté.';

  @override
  String get stepPersonal => 'Informations personnelles';

  @override
  String get stepDocuments => 'Documents';

  @override
  String get stepVehicle => 'Véhicule';

  @override
  String get stepServices => 'Services et tarifs';

  @override
  String get stepAvailability => 'Disponibilités';

  @override
  String get stepComplete => 'Complet';

  @override
  String get stepTodo => 'À compléter';

  @override
  String get stepOptional => 'Facultatif';

  @override
  String get submitApplication => 'Envoyer le dossier pour validation';

  @override
  String get submitApplicationConfirm =>
      'Après l\'envoi, vous ne pourrez plus modifier le dossier avant la validation.';

  @override
  String get applicationSubmitted =>
      'Dossier envoyé. Nous le vérifions rapidement.';

  @override
  String get applicationRejectedTitle => 'Dossier refusé';

  @override
  String get applicationRejectedHint =>
      'Corrigez les éléments indiqués puis renvoyez le dossier.';

  @override
  String missingItems(String items) {
    return 'Manquant : $items';
  }

  @override
  String get yearsExperienceLabel => 'Années d\'expérience';

  @override
  String get bioLabel => 'À propos de vous';

  @override
  String get bioHint =>
      'ex. Chauffeur professionnel, je connais bien la ville…';

  @override
  String get profilePhoto => 'Photo de profil';

  @override
  String get changePhoto => 'Changer la photo';

  @override
  String get cityOfWork => 'Ville principale';

  @override
  String get documentsIntro =>
      'Prenez des photos nettes et lisibles de chaque document.';

  @override
  String docRejectedReason(String reason) {
    return 'Refusé : $reason';
  }

  @override
  String get vehicleTitle => 'Informations du véhicule';

  @override
  String get vehicleType => 'Type de véhicule';

  @override
  String get vehicleBrand => 'Marque';

  @override
  String get vehicleModel => 'Modèle';

  @override
  String get vehicleYear => 'Année';

  @override
  String get vehicleColor => 'Couleur';

  @override
  String get vehicleSeats => 'Nombre de places';

  @override
  String get vehiclePlate => 'Immatriculation';

  @override
  String get vehiclePhotos => 'Photos du véhicule';

  @override
  String get addVehiclePhoto => 'Ajouter une photo';

  @override
  String get maxPhotosReached => 'Maximum 5 photos.';

  @override
  String get servicesIntro =>
      'Choisissez vos services, les villes desservies et le tarif de chacun.';

  @override
  String get addService => 'Ajouter un service';

  @override
  String get editService => 'Modifier le service';

  @override
  String get serviceCities => 'Villes desservies';

  @override
  String get servicePriceField => 'Prix (MRU)';

  @override
  String get priceUnitField => 'Unité de prix';

  @override
  String get serviceActive => 'Active';

  @override
  String get noServicesYet => 'Aucun service ajouté';

  @override
  String get noServicesHint =>
      'Ajoutez au moins un service pour apparaître auprès des clients.';

  @override
  String get deleteServiceConfirm => 'Supprimer ce service ?';

  @override
  String get selectAtLeastOneCity => 'Choisissez au moins une ville';

  @override
  String get serviceAlreadyAdded => 'Ce service est déjà ajouté';

  @override
  String get availabilityIntro => 'Indiquez vos jours et horaires de travail.';

  @override
  String get dayOff => 'Repos';

  @override
  String get timeFrom => 'De';

  @override
  String get timeTo => 'À';

  @override
  String get invalidTimeRange => 'L\'heure de fin doit être après le début';

  @override
  String get pendingTitle => 'Dossier en cours de validation';

  @override
  String get pendingBody =>
      'L\'équipe SAIQI vérifie votre dossier. Vous serez prévenu dès sa validation et cet écran se mettra à jour automatiquement.';

  @override
  String pendingSince(String date) {
    return 'Envoyé le $date';
  }

  @override
  String get suspendedTitle => 'Compte suspendu';

  @override
  String get suspendedBody =>
      'Votre compte est temporairement suspendu. Contactez le support pour en savoir plus.';

  @override
  String hello(String name) {
    return 'Bonjour, $name';
  }

  @override
  String get availabilityOn =>
      'Vous êtes disponible pour recevoir des demandes';

  @override
  String get availabilityOff => 'Vous êtes actuellement indisponible';

  @override
  String get availabilityToggleHint =>
      'Activez le bouton pour recevoir de nouvelles demandes.';

  @override
  String get walletBalance => 'Solde du portefeuille';

  @override
  String get lowBalanceWarning =>
      'Solde faible. Rechargez pour ne pas manquer de demandes.';

  @override
  String get topUp => 'Recharger';

  @override
  String get incomingRequests => 'Demandes entrantes';

  @override
  String get noIncomingRequests => 'Aucune demande pour le moment';

  @override
  String get noIncomingHint =>
      'Les nouvelles demandes apparaîtront ici instantanément.';

  @override
  String get upcomingTrips => 'Vos prochaines courses';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get requestDetails => 'Détails de la demande';

  @override
  String get commissionLabel => 'Commission';

  @override
  String get acceptRequest => 'Accepter';

  @override
  String get rejectRequest => 'Refuser';

  @override
  String commissionNotice(String amount, String rate) {
    return 'Une commission de $amount ($rate) sera déduite de votre portefeuille à l\'acceptation.';
  }

  @override
  String balanceAfterAccept(String amount) {
    return 'Solde après acceptation : $amount';
  }

  @override
  String insufficientBalanceBlock(String balance, String commission) {
    return 'Votre solde ($balance) ne couvre pas la commission de cette demande ($commission). Rechargez votre portefeuille pour accepter.';
  }

  @override
  String get rechargeToAccept => 'Recharger mon portefeuille';

  @override
  String get requestAccepted => 'Demande acceptée';

  @override
  String get requestRejectedMsg => 'Demande refusée';

  @override
  String get rejectConfirm => 'Voulez-vous refuser cette demande ?';

  @override
  String get requestGone => 'Cette demande n\'est plus disponible.';

  @override
  String get requestedBy => 'Demandé par';

  @override
  String get clientPaysDriver =>
      'Le client vous paie directement (espèces ou paiement mobile).';

  @override
  String get firstAcceptWins =>
      'Cette demande a été envoyée à plusieurs chauffeurs : le premier qui accepte l\'obtient.';

  @override
  String get myTrips => 'Mes courses';

  @override
  String get tripsUpcoming => 'À venir';

  @override
  String get tripsHistory => 'Historique';

  @override
  String get noTrips => 'Aucune course';

  @override
  String get tripDetails => 'Détails de la course';

  @override
  String get startEnRoute => 'Je suis en route';

  @override
  String get startTrip => 'Démarrer la course';

  @override
  String get finishTrip => 'Terminer la course';

  @override
  String get cancelTrip => 'Annuler la course';

  @override
  String get cancelTripConfirm =>
      'La commission sera restituée à votre portefeuille. Annuler la course ?';

  @override
  String get tripCancelled => 'Course annulée';

  @override
  String get statusUpdated => 'Statut mis à jour';

  @override
  String get clientContact => 'Contacter le client';

  @override
  String get scheduledFor => 'Rendez-vous';

  @override
  String get agreedPrice => 'Prix';

  @override
  String get commissionDeducted => 'Commission déduite';

  @override
  String get wallet => 'Portefeuille';

  @override
  String get transactions => 'Opérations';

  @override
  String get noTransactions => 'Aucune opération';

  @override
  String get topupRequests => 'Demandes de recharge';

  @override
  String get noTopups => 'Aucune demande de recharge';

  @override
  String get requestTopup => 'Demander une recharge';

  @override
  String get topupAmount => 'Montant (MRU)';

  @override
  String get topupMethod => 'Moyen de paiement';

  @override
  String get topupReference => 'Référence de la transaction';

  @override
  String get topupProof => 'Photo de la preuve de paiement';

  @override
  String get topupSubmitted => 'Demande envoyée. Elle sera validée rapidement.';

  @override
  String get topupHowTo =>
      'Envoyez le montant à l\'un des comptes ci-dessous puis joignez la preuve de paiement.';

  @override
  String minTopup(String amount) {
    return 'Recharge minimale : $amount';
  }

  @override
  String get accountNumber => 'Compte';

  @override
  String balanceAfterTx(String amount) {
    return 'Solde : $amount';
  }

  @override
  String get howCommissionWorks =>
      'La commission est déduite de votre solde à chaque service accepté, et restituée en cas d\'annulation.';

  @override
  String get noAccountConfigured =>
      'Aucun compte de paiement n\'est encore configuré.';

  @override
  String get refInPayment => 'Numéro copié';

  @override
  String get myProfile => 'Mon profil';

  @override
  String get statistics => 'Statistiques';

  @override
  String get completedTrips => 'Courses terminées';

  @override
  String get revenueGross => 'Montants encaissés';

  @override
  String get commissionsPaid => 'Commissions payées';

  @override
  String get revenueNet => 'Net';

  @override
  String get ratingLabel => 'Note';

  @override
  String get reviewsReceived => 'Avis reçus';

  @override
  String get noReviewsYet => 'Aucun avis pour le moment';

  @override
  String get publicProfile => 'Mon profil public';

  @override
  String get publicProfileHint => 'Voici ce que voient les clients.';

  @override
  String get editPersonalInfo => 'Modifier mes informations';

  @override
  String get myDocuments => 'Mes documents';

  @override
  String get helpAndReport => 'Aide et signalement';

  @override
  String get reportProblem => 'Signaler un problème';

  @override
  String get reportHint => 'Décrivez le problème en détail…';

  @override
  String get reportSent => 'Signalement envoyé. Nous reviendrons vers vous.';

  @override
  String get contactSupportCall => 'Appeler le support';

  @override
  String get contactSupportWhatsapp => 'WhatsApp du support';

  @override
  String get tapToEdit => 'Touchez pour modifier';

  @override
  String get bookingStatus_pending => 'En attente';

  @override
  String get bookingStatus_accepted => 'Acceptée';

  @override
  String get bookingStatus_enRoute => 'Chauffeur en route';

  @override
  String get bookingStatus_inProgress => 'En cours';

  @override
  String get bookingStatus_completed => 'Terminée';

  @override
  String get bookingStatus_cancelled => 'Annulée';

  @override
  String get bookingStatus_rejected => 'Refusée';

  @override
  String get bookingStatus_expired => 'Expirée';

  @override
  String get driverStatus_draft => 'Brouillon';

  @override
  String get driverStatus_pending => 'En validation';

  @override
  String get driverStatus_approved => 'Validé';

  @override
  String get driverStatus_rejected => 'Refusé';

  @override
  String get driverStatus_suspended => 'Suspendu';

  @override
  String get accountStatus_active => 'Actif';

  @override
  String get accountStatus_suspended => 'Suspendu';

  @override
  String get accountStatus_blocked => 'Bloqué';

  @override
  String get documentType_idCard => 'Carte d\'identité';

  @override
  String get documentType_drivingLicense => 'Permis de conduire';

  @override
  String get documentType_vehicleRegistration => 'Carte grise';

  @override
  String get documentType_insurance => 'Assurance';

  @override
  String get documentType_photo => 'Photo d\'identité';

  @override
  String get documentStatus_pending => 'En attente';

  @override
  String get documentStatus_approved => 'Validé';

  @override
  String get documentStatus_rejected => 'Refusé';

  @override
  String get channel_app => 'Application';

  @override
  String get channel_phone => 'Téléphone';

  @override
  String get channel_whatsapp => 'WhatsApp';

  @override
  String get channel_other => 'Autre';

  @override
  String get txType_topup => 'Recharge';

  @override
  String get txType_commission => 'Commission';

  @override
  String get txType_refund => 'Remboursement';

  @override
  String get txType_adjustment => 'Ajustement';

  @override
  String get topupStatus_pending => 'En attente';

  @override
  String get topupStatus_approved => 'Validée';

  @override
  String get topupStatus_rejected => 'Refusée';

  @override
  String get complaintStatus_open => 'Ouverte';

  @override
  String get complaintStatus_inReview => 'En cours';

  @override
  String get complaintStatus_resolved => 'Résolue';

  @override
  String get complaintStatus_dismissed => 'Classée';

  @override
  String get priceUnit_perTrip => 'par course';

  @override
  String get priceUnit_perHour => 'par heure';

  @override
  String get priceUnit_perDay => 'par jour';

  @override
  String get priceUnitLabel_perTrip => 'Prix par course';

  @override
  String get priceUnitLabel_perHour => 'Prix par heure';

  @override
  String get priceUnitLabel_perDay => 'Prix par jour';

  @override
  String get adminRole_superAdmin => 'Super admin';

  @override
  String get adminRole_validator => 'Validateur';

  @override
  String get adminRole_support => 'Support';

  @override
  String get vehicleType_sedan => 'Berline';

  @override
  String get vehicleType_suv => 'SUV';

  @override
  String get vehicleType_4x4 => '4×4';

  @override
  String get vehicleType_van => 'Van';

  @override
  String get vehicleType_minibus => 'Minibus';

  @override
  String get vehicleType_bus => 'Bus';

  @override
  String get vehicleType_pickup => 'Pick-up';

  @override
  String get weekday_1 => 'Lundi';

  @override
  String get weekday_2 => 'Mardi';

  @override
  String get weekday_3 => 'Mercredi';

  @override
  String get weekday_4 => 'Jeudi';

  @override
  String get weekday_5 => 'Vendredi';

  @override
  String get weekday_6 => 'Samedi';

  @override
  String get weekday_7 => 'Dimanche';

  @override
  String get audience_drivers => 'Chauffeurs';

  @override
  String get audience_clients => 'Clients';

  @override
  String get audience_all => 'Tout le monde';

  @override
  String get sort_rating => 'Mieux notés';

  @override
  String get sort_priceAsc => 'Prix croissant';

  @override
  String get sort_priceDesc => 'Prix décroissant';

  @override
  String get sort_trips => 'Plus de courses';

  @override
  String get err_unknown => 'Une erreur inattendue est survenue. Réessayez.';

  @override
  String get err_network_error =>
      'Connexion impossible. Vérifiez votre réseau et réessayez.';

  @override
  String get err_session_expired => 'Session expirée. Reconnectez-vous.';

  @override
  String get err_permission_denied =>
      'Vous n\'avez pas le droit d\'effectuer cette action.';

  @override
  String get err_invalid_credentials => 'Numéro ou mot de passe incorrect.';

  @override
  String get err_phone_already_registered => 'Ce numéro est déjà enregistré.';

  @override
  String get err_invalid_phone => 'Numéro de téléphone invalide.';

  @override
  String get err_password_too_short =>
      'Le mot de passe doit contenir au moins 8 caractères.';

  @override
  String get err_signup_failed =>
      'Impossible de créer le compte. Vérifiez les informations.';

  @override
  String get err_account_suspended =>
      'Votre compte est suspendu. Contactez le support.';

  @override
  String get err_account_blocked =>
      'Votre compte est bloqué. Contactez le support.';

  @override
  String get err_wrong_app_role =>
      'Ce compte n\'est pas destiné à cette application.';

  @override
  String get err_not_authenticated => 'Vous devez vous connecter.';

  @override
  String get err_not_client => 'Cette action est réservée aux clients.';

  @override
  String get err_not_driver => 'Cette action est réservée aux chauffeurs.';

  @override
  String get err_driver_not_available =>
      'Ce chauffeur n\'est pas disponible actuellement.';

  @override
  String get err_service_not_offered =>
      'Ce chauffeur ne propose pas ce service dans cette ville.';

  @override
  String get err_pickup_required => 'Indiquez le lieu de départ.';

  @override
  String get err_invalid_schedule =>
      'Choisissez une date et une heure valides.';

  @override
  String get err_invalid_passengers => 'Nombre de passagers invalide.';

  @override
  String get err_too_many_passengers =>
      'Le nombre de passagers dépasse les places du véhicule.';

  @override
  String get err_too_many_pending =>
      'Vous avez trop de demandes en attente. Patientez les réponses.';

  @override
  String get err_invalid_service_or_city => 'Service ou ville invalide.';

  @override
  String get err_booking_not_found => 'Réservation introuvable.';

  @override
  String get err_booking_not_available =>
      'Cette demande n\'est plus disponible (déjà prise ou annulée).';

  @override
  String get err_booking_expired => 'Le délai de cette demande est écoulé.';

  @override
  String get err_offer_not_available => 'Cette offre n\'est plus disponible.';

  @override
  String get err_insufficient_balance =>
      'Solde insuffisant pour la commission. Rechargez votre portefeuille.';

  @override
  String err_insufficient_balance_detail(String balance, String required) {
    return 'Votre solde est de $balance MRU, la commission requise est de $required MRU.';
  }

  @override
  String get err_driver_not_approved =>
      'Votre compte chauffeur n\'est pas encore validé.';

  @override
  String get err_wallet_not_found => 'Portefeuille introuvable.';

  @override
  String get err_invalid_transition =>
      'Ce changement de statut n\'est pas autorisé.';

  @override
  String get err_not_allowed => 'Opération non autorisée.';

  @override
  String get err_booking_not_cancellable =>
      'Cette réservation ne peut plus être annulée.';

  @override
  String get err_cancel_not_allowed_after_en_route =>
      'Annulation impossible une fois le chauffeur en route.';

  @override
  String get err_contact_not_available =>
      'Le numéro n\'est visible qu\'après acceptation.';

  @override
  String get err_amount_too_low =>
      'Le montant est inférieur au minimum de recharge.';

  @override
  String get err_method_required => 'Choisissez un moyen de paiement.';

  @override
  String get err_invalid_path => 'Fichier invalide.';

  @override
  String get err_booking_not_completed =>
      'Vous pouvez évaluer seulement une course terminée.';

  @override
  String get err_already_reviewed => 'Vous avez déjà évalué cette course.';

  @override
  String get err_invalid_rating => 'Choisissez une note de 1 à 5.';

  @override
  String get err_text_too_short => 'Le texte est trop court.';

  @override
  String get err_text_required => 'Saisissez le titre et le texte.';

  @override
  String get err_invalid_driver_status =>
      'Le statut du chauffeur ne permet pas cette action.';

  @override
  String get err_application_incomplete =>
      'Dossier incomplet. Complétez les éléments requis avant l\'envoi.';

  @override
  String get err_reason_required => 'Le motif est obligatoire.';

  @override
  String get err_admin_forbidden =>
      'Vos droits ne permettent pas cette action.';

  @override
  String get err_driver_not_found => 'Chauffeur introuvable.';

  @override
  String get err_document_not_found => 'Document introuvable.';

  @override
  String get err_topup_not_found => 'Demande de recharge introuvable.';

  @override
  String get err_topup_already_reviewed => 'Cette demande a déjà été traitée.';

  @override
  String get err_invalid_amount => 'Montant invalide.';

  @override
  String get err_client_name_required => 'Le nom du client est obligatoire.';

  @override
  String get err_invalid_channel => 'Canal de la demande invalide.';

  @override
  String get err_invalid_price => 'Prix invalide.';

  @override
  String get err_drivers_required =>
      'Choisissez au moins un chauffeur (maximum 20).';

  @override
  String get err_booking_not_reassignable =>
      'Le chauffeur de cette réservation ne peut pas être changé.';

  @override
  String get err_complaint_not_found => 'Plainte introuvable.';

  @override
  String get err_review_not_found => 'Avis introuvable.';

  @override
  String get err_invalid_audience => 'Public cible invalide.';

  @override
  String get err_cannot_modify_self =>
      'Vous ne pouvez pas modifier votre propre compte ici.';

  @override
  String get err_profile_not_found => 'Compte introuvable.';

  @override
  String get err_upload_failed => 'Échec de l\'envoi du fichier. Réessayez.';

  @override
  String get err_name_required => 'Le nom est obligatoire.';

  @override
  String get err_invalid_admin_role => 'Rôle administrateur invalide.';

  @override
  String get err_server_not_configured =>
      'Le serveur n\'est pas encore configuré.';

  @override
  String get err_create_user_failed => 'Impossible de créer le compte.';

  @override
  String get err_invalid_token => 'Session expirée. Reconnectez-vous.';

  @override
  String get err_missing_token => 'Connexion requise.';

  @override
  String get err_internal_error => 'Erreur serveur. Réessayez plus tard.';

  @override
  String get err_duplicate => 'Cet élément existe déjà.';

  @override
  String get err_rate_limited =>
      'Trop de tentatives. Patientez un instant puis réessayez.';

  @override
  String get err_driver_row_missing =>
      'Impossible de créer le dossier chauffeur.';

  @override
  String get city => 'Ville';

  @override
  String get cities => 'Villes';

  @override
  String get serviceType => 'Type de service';

  @override
  String get dateAndTime => 'Date et heure';

  @override
  String get pickup => 'Lieu de départ';

  @override
  String get dropoff => 'Destination';

  @override
  String get passengers => 'Passagers';

  @override
  String get notes => 'Remarques';

  @override
  String get price => 'Prix';

  @override
  String get client => 'Client';

  @override
  String get driver => 'Chauffeur';

  @override
  String get status => 'Statut';

  @override
  String get channel => 'Canal';

  @override
  String get createdBy => 'Créé par';

  @override
  String get createdByAdmin => 'Créé par l\'admin';

  @override
  String get reason => 'Motif';

  @override
  String get reasonHint => 'Indiquez le motif';

  @override
  String get verified => 'Vérifié';

  @override
  String get availableNow => 'Disponible';

  @override
  String get unavailableNow => 'Indisponible';

  @override
  String seatsCount(String count) {
    return '$count places';
  }

  @override
  String tripsCount(String count) {
    return '$count courses';
  }

  @override
  String yearsExperience(String count) {
    return '$count ans d\'expérience';
  }

  @override
  String reviewsCount(String count) {
    return '$count avis';
  }

  @override
  String get noRatingYet => 'Nouveau';

  @override
  String fromPrice(String price) {
    return 'À partir de $price';
  }

  @override
  String priceWithUnit(String price, String unit) {
    return '$price $unit';
  }

  @override
  String get documentUploaded => 'Envoyé';

  @override
  String get documentMissing => 'Non envoyé';

  @override
  String get documentReplace => 'Remplacer';

  @override
  String get documentView => 'Voir';

  @override
  String get documentRequired => 'Obligatoire';

  @override
  String get imageLoadFailed => 'Impossible de charger l\'image';

  @override
  String get openNotification => 'Ouvrir';

  @override
  String get notificationsEmptyHint =>
      'Les alertes de vos réservations et de votre portefeuille apparaîtront ici.';

  @override
  String get welcomeContinue => 'Continuer';

  @override
  String get splashLoading => 'Chargement…';

  @override
  String get signedInAs => 'Connecté en tant que';

  @override
  String get supportNotConfigured =>
      'Le numéro du support n\'est pas encore disponible.';

  @override
  String get cannotOpenLink => 'Impossible d\'ouvrir le lien.';
}
