# NFC Carte — Carte de visite numérique iOS/Android

Application Flutter open-source équivalente à *NFC Cool Business Card Maker* :
créez plusieurs cartes de visite personnalisables, partagez-les via **NFC**,
**QR code**, **vCard** ou lien, **100 % local-first**, conforme **RGPD**,
prête à être publiée sur l'**App Store** et le **Play Store**.

## 1. Stack

| Domaine         | Choix                                            |
|-----------------|--------------------------------------------------|
| Framework       | Flutter 3.22+, Dart 3.4+                         |
| État            | Riverpod                                         |
| Routage         | go_router                                        |
| Stockage local  | Hive (AES-256) + flutter_secure_storage (clé)    |
| NFC             | `nfc_manager` (écriture NDEF `text/vcard`)       |
| QR              | `qr_flutter`                                     |
| Partage         | `share_plus`, `url_launcher`                     |
| i18n            | `flutter_localizations` + ARB (fr/en)            |

Flutter est choisi parce qu'il couvre iOS + Android avec un seul codebase,
qu'il offre un accès natif au NFC des deux côtés, et qu'il produit des
binaires signés acceptés directement par l'App Store et Google Play.

## 2. Arborescence

```
lib/
├── main.dart
├── app.dart                  # MaterialApp + router + thème
├── models/
│   └── business_card.dart    # entité + TypeAdapter Hive
├── providers/
│   ├── cards_provider.dart
│   └── preferences_provider.dart
├── services/
│   ├── storage_service.dart  # Hive chiffré + clé Keychain/Keystore
│   ├── consent_service.dart  # RGPD art. 7
│   ├── vcard_service.dart    # vCard 3.0 (RFC 2426)
│   ├── nfc_service.dart      # écriture NDEF
│   └── share_service.dart
├── theme/app_theme.dart
├── widgets/card_preview.dart
└── screens/
    ├── splash_screen.dart
    ├── consent_screen.dart
    ├── home_screen.dart
    ├── card_editor_screen.dart
    ├── card_view_screen.dart
    ├── settings_screen.dart
    └── privacy_screen.dart

platform_config/               # à copier après `flutter create`
├── ios/Runner/Info.plist
├── ios/Runner/Runner.entitlements
├── ios/Runner/PrivacyInfo.xcprivacy
└── android/app/src/main/AndroidManifest.xml
```

## 3. Installation locale

Prérequis : Flutter SDK ≥ 3.22 (`flutter --version`), Xcode 15+ pour iOS,
Android Studio / JDK 17 pour Android.

```bash
# 1. Générer les dossiers ios/ et android/ autour du code Dart existant
flutter create . \
  --project-name nfc_carte \
  --org com.votredomaine \
  --platforms ios,android

# 2. Écraser les configs plateforme par les versions RGPD/NFC prêtes
cp platform_config/ios/Runner/Info.plist               ios/Runner/Info.plist
cp platform_config/ios/Runner/Runner.entitlements      ios/Runner/Runner.entitlements
cp platform_config/ios/Runner/PrivacyInfo.xcprivacy    ios/Runner/PrivacyInfo.xcprivacy
cp platform_config/android/app/src/main/AndroidManifest.xml \
   android/app/src/main/AndroidManifest.xml
mkdir -p android/app/src/main/res/xml
cp platform_config/android/app/src/main/res/xml/data_extraction_rules.xml \
   android/app/src/main/res/xml/data_extraction_rules.xml

# 3. Dépendances
flutter pub get

# 4. Lancer sur un appareil (NFC ne fonctionne PAS en simulateur)
flutter run
```

### Étapes manuelles dans Xcode

1. Ouvrir `ios/Runner.xcworkspace`.
2. Cible **Runner** → onglet **Signing & Capabilities**
   → **+ Capability** → **Near Field Communication Tag Reading**.
   Cela lie `Runner.entitlements`.
3. Toujours dans Xcode, ajouter `PrivacyInfo.xcprivacy` au target Runner
   (glisser-déposer dans le groupe Runner, cocher Runner).
4. Signing : sélectionner votre Team.

### Étapes manuelles Android

- `minSdkVersion` : au moins 21 (Flutter par défaut).
- Signature release : suivez la doc officielle Flutter pour créer un
  `upload-keystore.jks` et remplir `android/key.properties`.

## 4. Fonctionnalités

- [x] Plusieurs cartes par utilisateur
- [x] Champs : nom, poste, entreprise, email, téléphone, site, adresse,
      LinkedIn, X, Instagram, notes, photo
- [x] 3 templates visuels (modern/classic/minimal)
- [x] Sélecteur de couleur
- [x] Photo de profil locale
- [x] Aperçu temps réel
- [x] Partage NFC (écriture NDEF `text/vcard` sur tag réinscriptible)
- [x] Partage QR code (vCard intégrée)
- [x] Partage vCard (.vcf)
- [x] Partage texte
- [x] Export JSON de toutes les cartes
- [x] Suppression totale des données
- [x] FR / EN
- [x] Thème clair / sombre / système

## 5. Conformité RGPD

| Exigence RGPD                               | Implémentation                                |
|---------------------------------------------|-----------------------------------------------|
| Art. 6(1)(a) — base légale : consentement   | `ConsentScreen` bloquant au 1er lancement     |
| Art. 7(3) — retrait du consentement         | Paramètres → Supprimer toutes mes données     |
| Art. 13/14 — information                    | `PrivacyScreen` intégré + lien accessible     |
| Art. 15 — droit d'accès                     | Export JSON lisible                           |
| Art. 16 — droit de rectification            | Modification libre de chaque champ            |
| Art. 17 — droit à l'effacement              | Suppression par carte ou globale              |
| Art. 20 — portabilité                       | Export JSON structuré, standard vCard         |
| Art. 25 — privacy by design/default         | Local-first, chiffrement AES-256 au repos     |
| Art. 32 — sécurité                          | Clé dans Keychain iOS / Keystore Android      |
| Apple Privacy Manifest (mai 2024)           | `PrivacyInfo.xcprivacy` fourni                |
| Google Data Safety                          | Rien à déclarer : aucune collecte             |

**Aucune** donnée ne quitte l'appareil. Aucun SDK d'analytics, de publicité
ou de tracking n'est embarqué.

### Avant publication — à personnaliser

1. Remplacer `dpo@example.com` dans `lib/screens/privacy_screen.dart` par
   votre vrai contact de DPO / de l'éditeur.
2. Mettre à jour la date de *dernière mise à jour* si vous modifiez la
   politique.
3. Incrémenter `ConsentService.currentPrivacyVersion` à chaque modif
   substantielle → les utilisateurs existants seront re-sollicités.
4. Adapter `com.votredomaine` à votre Bundle ID réel.

## 6. Déploiement App Store

```bash
# 1. Build archive iOS
flutter build ipa --release

# 2. Monter dans App Store Connect via Transporter ou :
xcrun altool --upload-app -f build/ios/ipa/*.ipa \
  -t ios -u "votre@apple.id" -p "@keychain:AC_PASSWORD"
```

Checklist App Store Review :

- [x] `NFCReaderUsageDescription` (raison claire en FR)
- [x] Capability "Near Field Communication Tag Reading" activée
- [x] `PrivacyInfo.xcprivacy` présent avec `NSPrivacyTracking = false`
- [x] Icône 1024×1024, captures d'écran 6.7" et 6.1"
- [x] URL vers politique de confidentialité publique (hébergée sur votre
      domaine, idem texte que `PrivacyScreen`)
- [x] Export Compliance : l'app n'utilise pas de chiffrement propriétaire
      (uniquement AES standard fourni par l'OS) → cocher *standard
      encryption exempt*

## 7. Déploiement Play Store

```bash
flutter build appbundle --release
# => build/app/outputs/bundle/release/app-release.aab
```

Checklist :

- [x] Formulaire *Data Safety* : aucune donnée collectée / partagée
- [x] Permission `NFC` documentée (elle ne déclenche pas de dialog user)
- [x] Cible API ≥ 34 (vérifier `android/app/build.gradle`)
- [x] Lien vers la politique de confidentialité publique

## 8. Tests manuels recommandés

| Scénario                                        | Attendu                           |
|------------------------------------------------|-----------------------------------|
| 1er lancement                                   | Écran consentement, app bloquée   |
| Refus consentement → ré-ouverture               | Écran consentement à nouveau      |
| Création carte, app quittée puis relancée       | Carte persistée                   |
| Écriture NFC sur tag NTAG215 vierge             | Lecture via Contacts iOS OK       |
| Scan du QR avec iPhone Camera                   | Propose d'ajouter le contact      |
| Paramètres → Supprimer tout                     | Box vidée, retour consentement    |
| Mode avion + partage vCard                      | Fonctionne (pas de réseau requis) |

## 9. Licence & contributions

MIT. Le code est volontairement minimal et lisible pour faciliter un audit
RGPD/sécurité. PRs bienvenues sur la branche
`claude/digital-business-card-app-AvutP`.
