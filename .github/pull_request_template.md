## Résumé

<!-- En 1-3 phrases, qu'est-ce qui change et pourquoi ? -->

## Type de changement

- [ ] Fix
- [ ] Feature
- [ ] Refactor (pas de changement fonctionnel visible)
- [ ] Doc / CI
- [ ] RGPD : modifie la politique ou le traitement des données
      (→ penser à bumper `ConsentService.currentPrivacyVersion`)

## Checklist

- [ ] `flutter analyze` passe sans warning
- [ ] `flutter test` passe (unit + widget)
- [ ] Si changement RGPD : `PrivacyScreen` et `DEPLOY.md` mis à jour
- [ ] Si nouvelle dépendance : rationale ajouté dans la description de la PR
- [ ] Pas de secret, clé, ou donnée personnelle commis

## Test manuel

<!-- Étapes pour valider sur appareil réel. Écran, flow, cas d'erreur. -->
