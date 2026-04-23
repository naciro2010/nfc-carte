# Déploiement — NFC Carte

Ce document décrit le pipeline CI/CD complet : tests en PR, release
automatique App Store et Play Store sur tag `vX.Y.Z`.

## Vue d'ensemble

```
┌─────────────┐   push / PR     ┌──────────────────────┐
│ Développeur │────────────────▶│ .github/workflows/   │
└─────────────┘                 │   ci.yml             │
                                │  - format            │
                                │  - flutter analyze   │
                                │  - flutter test      │
                                │  - build iOS/Android │
                                └──────────┬───────────┘
                                           │ vert
                                           ▼
                                   git tag v1.2.3
                                           │
                    ┌──────────────────────┼──────────────────────┐
                    ▼                                             ▼
        ┌─────────────────────┐                       ┌─────────────────────┐
        │ release-ios.yml     │                       │ release-android.yml │
        │ Fastlane ios beta   │                       │ Fastlane android    │
        │ → TestFlight        │                       │   internal → Play   │
        └─────────────────────┘                       └─────────────────────┘
```

**Règle d'or** : aucun workflow de release ne s'exécute si `ci.yml` n'est
pas vert sur le commit taggé (action `fountainhead/action-wait-for-check`).

## 1. Vérifier la santé avant de taguer

```bash
# Local
flutter analyze
flutter test
flutter test integration_test
```

Sur PR, la CI lance exactement les mêmes commandes plus un seuil de
couverture (60 % par défaut, ajustable via `COVERAGE_THRESHOLD` dans le
workflow).

## 2. Déclencher un déploiement

### Automatique (recommandé)

```bash
git tag v1.2.3
git push origin v1.2.3
```

- `release-android.yml` lane `internal` → piste **Internal testing**
- `release-ios.yml` lane `beta` → **TestFlight**

Promotion manuelle depuis l'onglet *Actions* de GitHub :
- Workflow *Release — Android* → **Run workflow** → lane `beta` puis
  `production` (rollout staged 20 %).
- Workflow *Release — iOS* → **Run workflow** → lane `release` (soumet la
  version TestFlight courante à la review App Store).

### Manuel d'urgence

`gh workflow run release-android.yml -f lane=internal`

## 3. Environnements GitHub

Deux environnements GitHub à créer dans **Settings → Environments** :

| Nom                 | Protection                      | Secrets nécessaires |
|---------------------|----------------------------------|---------------------|
| `ios-production`    | required reviewer(s)             | voir liste ci-dessous |
| `android-production`| required reviewer(s) + rollout  | voir liste ci-dessous |

La protection par reviewer oblige une approbation humaine avant le push
vers les stores, même si la CI est verte — filet de sécurité.

## 4. Secrets à renseigner

### Secrets communs (repository)

| Secret                | Description                                                    |
|-----------------------|-----------------------------------------------------------------|
| `IOS_BUNDLE_ORG`      | Prefix d'organisation, ex. `com.votredomaine`                   |
| `ANDROID_PACKAGE_NAME`| Package name complet, ex. `com.votredomaine.nfc_carte`         |

### Secrets iOS (environnement `ios-production`)

| Secret                               | Comment l'obtenir |
|--------------------------------------|-------------------|
| `IOS_BUNDLE_ID`                      | Ex. `com.votredomaine.nfc_carte` (identique à Info.plist). |
| `APPLE_ID`                           | Email Apple ID du compte développeur. |
| `APPLE_TEAM_ID`                      | 10 caractères, Apple Developer → Membership. |
| `APPLE_ITC_TEAM_ID`                  | Numérique, App Store Connect → Users & Access → Team ID. |
| `APP_STORE_CONNECT_KEY_ID`           | App Store Connect → Users & Access → Keys → Key ID. |
| `APP_STORE_CONNECT_ISSUER_ID`        | Même page, Issuer ID. |
| `APP_STORE_CONNECT_KEY_CONTENT`      | Contenu du `.p8`, **base64 encodé** (`base64 -w0 AuthKey.p8`). |
| `MATCH_GIT_URL`                      | URL du repo git privé contenant les certs (ex. `https://github.com/org/certs.git`). |
| `MATCH_GIT_BASIC_AUTH`               | `base64(username:personal_access_token)` pour accès au repo certs. |
| `MATCH_PASSWORD`                     | Passphrase choisie au `fastlane match init`. |
| `KEYCHAIN_PASSWORD`                  | Passphrase pour la keychain temporaire CI (chaîne aléatoire). |
| `FASTLANE_PASSWORD`                  | Mot de passe Apple ID (si nécessaire pour `deliver`). |
| `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` | Mot de passe app-spécifique (appleid.apple.com). |

**Initialisation match** (à faire une fois sur votre machine) :

```bash
cd fastlane/ios
bundle exec fastlane match appstore --git_url https://github.com/org/certs.git
```

### Secrets Android (environnement `android-production`)

| Secret                    | Comment l'obtenir |
|---------------------------|-------------------|
| `UPLOAD_KEYSTORE_BASE64`  | `base64 -w0 nfc_carte_upload.jks` — keystore créé via `keytool -genkey -v -keystore nfc_carte_upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`. |
| `UPLOAD_STORE_PASSWORD`   | Mot de passe du keystore. |
| `UPLOAD_KEY_PASSWORD`     | Mot de passe de la clé. |
| `UPLOAD_KEY_ALIAS`        | `upload` (par défaut). |
| `PLAY_STORE_CONFIG_JSON`  | JSON complet du service account Google Cloud avec rôle *Release Manager* sur Play Console. |

**Créer le service account** :

1. Play Console → Users & permissions → Invite new user → cocher
   *Release Manager* pour l'app NFC Carte.
2. Google Cloud Console → IAM → Service Accounts → *Create service account*.
3. Générer une clé JSON → coller le contenu dans `PLAY_STORE_CONFIG_JSON`.

## 5. Premier upload manuel

Pour les **toutes premières** builds, il faut un upload humain pour que
l'app existe dans App Store Connect / Play Console (nom, catégorie,
politique de confidentialité). Après ça, tout est automatique.

### iOS — premier build

```bash
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
# Puis Transporter.app ou :
xcrun altool --upload-app -f build/ios/ipa/nfc_carte.ipa \
  -t ios -u "$APPLE_ID" -p "@env:FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD"
```

### Android — premier build

```bash
flutter build appbundle --release
# Upload manuel via Play Console, remplir "Store listing", "Content rating",
# "Data safety" (tout décoché : pas de collecte).
```

## 6. Matrice de tests exécutée en CI

| Niveau      | Cible                                               | Dossier |
|-------------|-----------------------------------------------------|---------|
| Unitaires   | `VCardService`, `BusinessCard`, `ConsentService`, `DeepLinkService` | `test/services/`, `test/models/` |
| Widgets     | `ConsentScreen`, `HomeScreen`, `CardPreview`        | `test/screens/`, `test/widgets/` |
| Intégration | Flow consent → create → save → display             | `integration_test/` |
| Statique    | `flutter analyze --fatal-infos`, `dart format`      | CI step |
| Couverture  | seuil configurable (défaut 60 %), artefact LCOV     | CI step |
| Sécurité    | `gitleaks`, `dart pub outdated --mode=security`     | workflow hebdomadaire |

Les tests d'intégration (dossier `integration_test/`) tournent sur un
émulateur/simulateur. En CI ils sont couverts par le job `build-ios` et
`build-android` qui vérifient au moins que l'app compile ; l'exécution
complète sur simulateur iOS peut être ajoutée avec
`flutter test integration_test --device-id <simulator>`.

## 7. Checklist RGPD & review stores

À re-vérifier avant chaque **release** (lane `production` / `release`) :

- [ ] `lib/screens/privacy_screen.dart` — contact DPO réel
- [ ] `PrivacyInfo.xcprivacy` — toujours `NSPrivacyTracking = false`
- [ ] Versioning politique : `ConsentService.currentPrivacyVersion`
      incrémenté si le texte a bougé substantiellement
- [ ] Release notes TestFlight en FR + EN
- [ ] `pubspec.yaml` `version:` bumpé (le `+build` est auto-géré via
      `git rev-list --count HEAD`)

## 8. Rollback

### iOS

Dans App Store Connect → TestFlight → *Previous Build* → promouvoir
l'ancienne version ; ou rejeter la version en review.

### Android

Play Console → *Release → Production → Releases* → le rollout staged
permet de geler à X % en cas d'incident, puis de publier une version
correctrice qui supersède l'ancienne.
