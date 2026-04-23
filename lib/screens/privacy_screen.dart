import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Politique de confidentialite')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            'Politique de confidentialite',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Derniere mise a jour : avril 2026',
              style: TextStyle(fontStyle: FontStyle.italic)),
          SizedBox(height: 24),
          _P(
            'NFC Carte est une application de carte de visite numerique concue '
            'autour du principe de confidentialite dite "local-first". '
            'Cette politique explique quelles donnees sont traitees, ou, comment et pourquoi.',
          ),
          _H('1. Responsable du traitement'),
          _P(
            'L\'editeur de l\'application agit en tant que responsable du traitement '
            'au sens de l\'article 4(7) du RGPD. Contact : dpo@example.com '
            '(a remplacer avec votre adresse reelle avant publication).',
          ),
          _H('2. Donnees traitees'),
          _P(
            'L\'application stocke uniquement les donnees que vous y saisissez : '
            'nom, titre, entreprise, email, telephone, site web, adresse, '
            'liens reseaux sociaux, photo, notes. '
            'Ces donnees sont conservees localement sur votre appareil, dans une '
            'base chiffree (AES-256) dont la cle reside dans le coffre-fort du systeme '
            '(Keychain iOS / Keystore Android).',
          ),
          _H('3. Finalites et base legale'),
          _P(
            'Les donnees sont utilisees pour generer votre carte, un QR code, un fichier '
            'vCard et, a votre demande, pour ecrire ces informations sur un tag NFC '
            'que vous approchez de l\'appareil. La base legale est votre consentement '
            '(art. 6(1)(a) RGPD), recueilli au premier lancement.',
          ),
          _H('4. Partage'),
          _P(
            'Aucune donnee n\'est envoyee a un serveur distant. Aucune connexion reseau '
            'n\'est initiee par l\'application hors des partages que vous declenchez '
            'explicitement (ex. envoi d\'une vCard par messagerie).',
          ),
          _H('5. Tiers'),
          _P(
            'L\'application n\'integre ni traceur, ni SDK publicitaire, ni outil d\'analytics. '
            'Les SDK utilises (Flutter, nfc_manager, qr_flutter, share_plus, etc.) '
            'sont strictement fonctionnels et s\'executent localement.',
          ),
          _H('6. Duree de conservation'),
          _P(
            'Les donnees restent sur votre appareil tant que vous ne les supprimez pas. '
            'Vous pouvez a tout moment supprimer une carte individuellement, ou effacer '
            'toutes les donnees via Parametres > Supprimer toutes mes donnees.',
          ),
          _H('7. Vos droits (RGPD)'),
          _P(
            'Vous disposez des droits d\'acces, de rectification, d\'effacement, de '
            'portabilite et d\'opposition. Ces droits s\'exercent directement depuis '
            'l\'application :\n'
            '- Acces / portabilite : Parametres > Exporter mes donnees (JSON).\n'
            '- Rectification : modification libre de chaque carte.\n'
            '- Effacement : suppression individuelle ou globale.\n'
            '- Retrait du consentement : Parametres > Supprimer toutes mes donnees.\n'
            'Vous pouvez aussi contacter notre DPO. Vous avez le droit d\'introduire '
            'une reclamation aupres de la CNIL (www.cnil.fr).',
          ),
          _H('8. Securite'),
          _P(
            'Chiffrement AES-256 au repos, cle stockee dans le Secure Enclave / Keystore, '
            'aucune connexion serveur. Les fichiers temporaires generes pour le partage '
            '(vCard, export JSON) sont ecrits dans le repertoire temporaire de '
            'l\'application et nettoyes par le systeme.',
          ),
          _H('9. Enfants'),
          _P(
            'L\'application n\'est pas destinee aux enfants de moins de 15 ans et '
            'ne collecte sciemment aucune donnee les concernant.',
          ),
          _H('10. Modifications'),
          _P(
            'Toute modification substantielle de la presente politique entraine un '
            'nouveau recueil de consentement au prochain lancement.',
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _H extends StatelessWidget {
  const _H(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _P extends StatelessWidget {
  const _P(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(height: 1.5)),
    );
  }
}
