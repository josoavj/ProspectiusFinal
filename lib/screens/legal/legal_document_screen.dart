import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';

enum LegalDocumentType { terms, privacy }

class LegalDocumentScreen extends StatelessWidget {
  final LegalDocumentType type;

  const LegalDocumentScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isPrivacy = type == LegalDocumentType.privacy;
    return Scaffold(
      appBar: AppBar(
        title: Text(isPrivacy ? 'Politique de confidentialité' : 'Conditions d’utilisation'),
      ),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: isPrivacy ? _privacySections(context) : _termsSections(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _termsSections(BuildContext context) => [
        _Header(
          title: 'Conditions d’utilisation de Prospectius',
          subtitle: 'Version 1.0 — dernière mise à jour : 29 octobre 2026',
        ),
        _Section(
          title: '1. Éditeur et objet',
          paragraphs: [
            'Prospectius est une application de gestion de prospects, de tâches, d’interactions et de documents. APEXNova Labs est uniquement le nom d’une organisation GitHub associée au projet ; cette organisation n’est pas présentée comme une société, une association ou une autre personne morale.',
            'L’identité, la forme juridique, l’adresse légale, les numéros d’immatriculation et les coordonnées du responsable de publication ou de l’éditeur doivent être définis avant toute exploitation commerciale. L’adresse de contact actuellement indiquée est Antananarivo 101, Madagascar, et l’e-mail est josoavonjiniaina13@gmail.com.',
          ],
        ),
        _Section(
          title: '2. Acceptation et capacité',
          paragraphs: [
            'L’utilisation de Prospectius implique l’acceptation des présentes conditions et de la Politique de confidentialité. Lors de l’inscription, l’utilisateur doit accepter séparément ces deux documents. Le refus empêche la création du compte.',
            'L’utilisateur déclare avoir la capacité juridique de contracter. Si le compte est créé pour une organisation, il déclare être autorisé à l’engager. Les utilisateurs mineurs ne doivent utiliser le service qu’avec l’autorisation et sous la responsabilité de leur représentant légal.',
          ],
        ),
        _Section(
          title: '3. Création et sécurité du compte',
          paragraphs: [
            'Les informations fournies à l’inscription doivent être exactes, à jour et ne pas usurper l’identité d’un tiers. L’utilisateur est responsable de la confidentialité de ses identifiants, de toute activité réalisée depuis son compte et de la notification rapide de toute utilisation non autorisée.',
            'Le mot de passe doit respecter les exigences affichées dans l’application. Il ne doit pas être réutilisé sur un autre service. Le responsable légal ou l’administrateur de l’installation peut suspendre un compte en cas de fraude, d’abus, de risque de sécurité ou de violation des présentes conditions, en limitant la mesure à ce qui est nécessaire.',
          ],
        ),
        _Section(
          title: '4. Utilisation autorisée',
          paragraphs: [
            'Prospectius doit être utilisé conformément à la loi, aux droits des personnes et aux règles professionnelles applicables. L’utilisateur est seul responsable des prospects, contacts, notes, documents et autres contenus qu’il saisit.',
            'Il est interdit d’utiliser le service pour envoyer des communications illicites ou non sollicitées, collecter des données sans base légale, traiter des données sensibles sans garanties appropriées, contourner une mesure de sécurité, introduire un logiciel malveillant, perturber le service, revendre l’accès sans autorisation ou porter atteinte aux droits de tiers.',
          ],
        ),
        _Section(
          title: '5. Données de prospection et conformité',
          paragraphs: [
            'L’utilisateur doit disposer d’une base légale pour chaque collecte et utilisation de données de prospects et respecter les obligations d’information, d’opposition, de consentement lorsque requis, de conservation et de prospection commerciale applicables à la personne concernée.',
            'Lorsque l’utilisateur saisit des données pour le compte de son organisation, il reste responsable du respect de la réglementation applicable. APEXNova Labs, en tant qu’organisation GitHub du projet, ne doit pas être considéré comme le responsable de traitement ou le sous-traitant juridique tant qu’une entité ou une personne responsable n’a pas été formellement désignée.',
          ],
        ),
        _Section(
          title: '6. Documents et propriété intellectuelle',
          paragraphs: [
            'L’utilisateur conserve ses droits sur les contenus qu’il saisit et garantit qu’il dispose des autorisations nécessaires. Prospectius est conçu pour enregistrer ces contenus dans la base de données configurée par l’utilisateur, généralement installée localement ou sur l’infrastructure de son organisation. L’organisation GitHub du projet n’en reçoit pas une copie en ligne par défaut.',
            'Le logiciel, son interface, sa marque, sa documentation et ses éléments graphiques sont protégés par les droits applicables. Toute reproduction, extraction, modification, ingénierie inverse ou exploitation non autorisée est interdite, sauf disposition impérative contraire.',
          ],
        ),
        _Section(
          title: '7. Disponibilité, sauvegardes et limites',
          paragraphs: [
            'L’application est fournie avec des obligations de moyens. Des indisponibilités peuvent résulter de la maintenance, d’un problème sur l’ordinateur ou le réseau local, d’une défaillance de la base configurée ou d’événements hors du contrôle raisonnable de l’éditeur.',
            'L’utilisateur doit conserver ses propres sauvegardes des informations importantes. Sauf faute prouvée du responsable légal identifié ou disposition légale impérative, aucune garantie n’est donnée quant à l’absence totale d’interruption ni à l’exactitude des décisions commerciales prises à partir des données du service.',
            'Aucune disposition ne limite les responsabilités qui ne peuvent pas l’être légalement, notamment en cas de dol, faute lourde, atteinte aux droits fondamentaux ou obligation impérative de sécurité.',
          ],
        ),
        _Section(
          title: '8. Suspension, suppression et réversibilité',
          paragraphs: [
            'L’utilisateur peut cesser d’utiliser le service et demander la suppression de son compte en écrivant à josoavonjiniaina13@gmail.com. Les données peuvent être conservées pendant la durée nécessaire à la sécurité, à la preuve, au respect d’une obligation légale ou au règlement d’un litige.',
            'Avant toute suppression, l’utilisateur doit exporter ou récupérer les éléments dont il a besoin. Les modalités techniques de restitution dépendent de la base locale ou de l’infrastructure choisie par l’organisation. MariaDB est la solution recommandée ; MySQL peut également être utilisé lorsqu’il est compatible avec l’installation.',
          ],
        ),
        _Section(
          title: '9. Évolutions et droit applicable',
          paragraphs: [
            'Les conditions peuvent être mises à jour pour refléter une évolution du service ou du droit. En cas de changement substantiel, une information sera présentée dans l’application et une nouvelle acceptation pourra être demandée.',
            'Les règles impératives de protection des consommateurs et des données du pays de l’utilisateur restent applicables. Sous cette réserve, les parties rechercheront d’abord une solution amiable ; la juridiction compétente sera déterminée selon les règles impératives applicables au lieu de résidence de l’utilisateur et au siège de l’éditeur.',
          ],
        ),
        const _ProjectLinkCard(),
        const _ContactSection(),
      ];

  List<Widget> _privacySections(BuildContext context) => [
        _Header(
          title: 'Politique de confidentialité de Prospectius',
          subtitle: 'Version 1.0 — dernière mise à jour : 29 octobre 2026',
        ),
        _Section(
          title: '1. Responsable et périmètre',
          paragraphs: [
            'APEXNova Labs est uniquement l’organisation GitHub associée au projet et ne constitue pas, à elle seule, le responsable juridique du traitement. Le responsable du traitement, l’éditeur ou le responsable de publication doit être identifié séparément avant déploiement commercial. Le contact actuellement indiqué est à Antananarivo 101, Madagascar.',
            'Cette politique décrit les traitements réalisés par l’application. Elle s’applique aux utilisateurs de Madagascar, d’Afrique, de l’Union européenne et des autres pays où Prospectius est proposé, sous réserve des règles locales impératives.',
          ],
        ),
        _Section(
          title: '2. Données collectées',
          paragraphs: [
            'Compte : nom, prénom, adresse e-mail, nom d’utilisateur, type de compte, mot de passe sous forme protégée et date de création.',
            'Activité : prospects, coordonnées professionnelles ou personnelles saisies par l’utilisateur, notes, tâches, interactions, historique, documents, champs personnalisés, journaux d’audit et paramètres de l’application.',
            'Configuration technique : paramètres de connexion à la base de données choisie, journaux techniques et informations nécessaires au diagnostic et à la sécurité. MariaDB est recommandée ; MySQL peut être utilisé selon la compatibilité de l’installation. Les mots de passe de base de données sont stockés dans le stockage sécurisé prévu par la plateforme lorsqu’il est disponible.',
            'L’application ne demande pas volontairement de données sensibles. N’en saisissez pas, sauf nécessité légale et garanties documentées. Les données de prospects appartiennent à l’organisation qui les collecte et doivent être traitées selon ses propres obligations.',
          ],
        ),
        _Section(
          title: '3. Finalités et bases légales',
          paragraphs: [
            'Créer et administrer le compte, authentifier l’utilisateur et fournir les fonctionnalités : exécution du contrat ou mesures précontractuelles.',
            'Sécuriser l’accès, prévenir la fraude, enregistrer les opérations importantes et diagnostiquer les erreurs : intérêt légitime ou obligation légale, selon le pays.',
            'Conserver les preuves d’acceptation, répondre aux demandes et respecter les obligations comptables, judiciaires ou réglementaires : obligation légale ou intérêt légitime.',
            'Les communications commerciales, si elles sont activées ultérieurement, nécessiteront une base légale appropriée et un moyen simple de retrait. Prospectius ne doit pas être utilisé pour prospecter illégalement.',
          ],
        ),
        _Section(
          title: '4. Destinataires et sous-traitants',
          paragraphs: [
            'Les données sont accessibles aux utilisateurs autorisés de l’organisation, à l’éditeur dans la mesure nécessaire au support et à la sécurité, et aux prestataires techniques strictement nécessaires.',
            'Prospectius ne fournit pas de stockage cloud centralisé : les données sont enregistrées dans la base configurée par l’utilisateur, généralement sur son ordinateur ou son réseau local. MariaDB est la base recommandée, mais l’utilisateur peut choisir une installation compatible selon ses besoins. L’organisation qui déploie l’application reste responsable de la sécurité de cette base, de ses sauvegardes, de ses accès et de son éventuelle exposition réseau. Aucun partage avec des régies publicitaires n’est prévu par la présente application.',
            'Les données peuvent être communiquées à une autorité légalement habilitée ou à un conseil professionnel lorsque la loi l’impose ou pour défendre des droits.',
          ],
        ),
        _Section(
          title: '5. Durées de conservation',
          paragraphs: [
            'Les données du compte et de l’espace de travail restent dans la base locale ou l’infrastructure choisie par l’utilisateur pendant la durée d’utilisation. Leur suppression relève de l’utilisateur ou de l’organisation qui administre cette base, sous réserve des sauvegardes et obligations légales.',
            'Les journaux de sécurité et preuves d’opérations sont conservés pendant la durée nécessaire à la prévention des abus et à la défense en justice. Les durées exactes doivent être fixées dans la politique interne de l’organisation selon ses obligations locales.',
            'Les données de prospects doivent être supprimées par l’organisation dès qu’elles ne sont plus nécessaires à la finalité pour laquelle elles ont été collectées.',
          ],
        ),
        _Section(
          title: '6. Droits des personnes',
          paragraphs: [
            'Selon la loi applicable, vous pouvez demander l’accès, la rectification, l’effacement, la limitation, la portabilité, vous opposer à certains traitements et retirer votre consentement à tout moment. Vous pouvez également définir des directives post-mortem lorsque ce mécanisme existe dans votre pays.',
            'Pour exercer vos droits, utilisez le contact indiqué en bas de page en précisant votre demande et le compte concerné. Une vérification raisonnable de l’identité peut être demandée. Une réponse sera fournie dans le délai légal applicable.',
            'Pour les personnes relevant du RGPD, une réclamation peut être adressée à l’autorité de contrôle compétente de leur résidence, lieu de travail ou lieu de l’infraction présumée. Les personnes à Madagascar peuvent se rapprocher de l’autorité nationale compétente en matière de protection des données selon les procédures en vigueur.',
          ],
        ),
        _Section(
          title: '7. Sécurité et incidents',
          paragraphs: [
            'Des mesures techniques et organisationnelles raisonnables sont mises en œuvre : contrôle des accès, authentification, hachage ou protection des mots de passe, stockage sécurisé lorsque disponible, limitation des privilèges et journalisation des opérations importantes.',
            'Aucune transmission ni aucun stockage ne peut être garanti comme absolument sûr. En cas de violation présentant un risque, l’éditeur ou l’organisation responsable prendra les mesures et notifications exigées par la loi applicable.',
          ],
        ),
        _Section(
          title: '8. Transferts internationaux et mineurs',
          paragraphs: [
            'Lorsque la base reste sur l’ordinateur ou le réseau local de l’utilisateur, Prospectius n’effectue pas de transfert international de ces données vers l’organisation GitHub du projet. Si l’utilisateur choisit de placer sa base sur un serveur distant, il devient responsable de vérifier les garanties de sécurité, de confidentialité et de transfert international requises par la réglementation applicable, notamment le RGPD pour les utilisateurs européens.',
            'Prospectius n’est pas destiné aux enfants. Les mineurs ne doivent pas créer de compte sans l’autorisation et la supervision de leur représentant légal lorsque la loi l’exige.',
          ],
        ),
        _Section(
          title: '9. Mise à jour',
          paragraphs: [
            'Cette politique peut évoluer pour refléter une modification du service, de l’hébergement ou de la réglementation. La version et la date de mise à jour figurent en tête du document. En cas de changement important, une information sera affichée et une nouvelle acceptation pourra être requise.',
          ],
        ),
        const _ProjectLinkCard(),
        const _ContactSection(),
      ];
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.azureDark.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.policy_outlined, color: Colors.white, size: 30),
            const SizedBox(height: 18),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      );
}

class _Section extends StatelessWidget {
  final String title;
  final List<String> paragraphs;

  const _Section({required this.title, required this.paragraphs});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final separator = title.indexOf(' ');
    final number = separator == -1 ? '' : title.substring(0, separator);
    final heading = separator == -1 ? title : title.substring(separator + 1);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(18, 18, 20, 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  number.replaceAll('.', ''),
                  style: TextStyle(color: colors.onPrimaryContainer, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    heading,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...paragraphs.map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(paragraph, style: const TextStyle(height: 1.55)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Toute question relative à ces documents ou à vos données peut être envoyée à :'),
          const SizedBox(height: 6),
          const _DocumentLink(
            label: 'Écrire à APEXNova Labs',
            uri: 'mailto:josoavonjiniaina13@gmail.com',
            icon: Icons.mail_outline_rounded,
          ),
          const SizedBox(height: 4),
          const Text('Antananarivo 101, Madagascar'),
        ],
      ),
    );
  }
}

class _ProjectLinkCard extends StatelessWidget {
  const _ProjectLinkCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6, bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const _DocumentLink(
        label: 'Voir l’organisation GitHub APEXNova Labs',
        uri: 'https://github.com/APEXNovaLabs',
        icon: Icons.open_in_new_rounded,
      ),
    );
  }
}

class _DocumentLink extends StatelessWidget {
  final String label;
  final String uri;
  final IconData icon;

  const _DocumentLink({
    required this.label,
    required this.uri,
    required this.icon,
  });

  Future<void> _open() async {
    final launched = await launchUrl(
      Uri.parse(uri),
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      throw StateError('Impossible d’ouvrir le lien');
    }
  }

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: _open,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
