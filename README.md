FinTrack Analytics — Projet Intermédiaire

Data Engineering & Business Intelligence avec Snowflake et dbt

## Présentation du projet

FinTrack Analytics est un projet de Data Engineering et de Business Intelligence consacré à l'analyse des données financières des clients.

Dans cette deuxième partie, l'objectif est de faire évoluer une première architecture dbt vers un pipeline analytique plus performant, fiable et industrialisé.

Le projet répond à plusieurs besoins métier :

Suivre les transactions et les virements entre comptes. Analyser les soldes mensuels des clients. Comparer les budgets prévisionnels aux dépenses réelles. Historiser les modifications des comptes clients. Améliorer la qualité et la traçabilité des données.

Environnement technique :

Entrepôt de données : Snowflake Outil de transformation : dbt Core Langages : **SQL** et Jinja Versionnement : Git / GitHub Visualisation : Metabase ## Architecture du projet

Le projet repose sur une architecture analytique organisée en plusieurs couches.

**RAW** — Données brutes

Les données sources sont stockées dans Snowflake :

raw_comptes raw_transactions raw_budgets raw_categories raw_virements raw_alertes **STAGING** — Nettoyage et standardisation

Cette couche permet de renommer les colonnes, de normaliser les données et de préparer les sources pour les transformations suivantes.

Modèles :

stg_comptes stg_transactions stg_budgets stg_categories stg_virements stg_alertes **INTERMEDIATE** — Transformations métier

Cette couche regroupe les transformations intermédiaires et les enrichissements nécessaires aux modèles analytiques.

Principal modèle :

int_transactions_enrichies **MARTS** — Modèles analytiques

Cette couche expose les données préparées pour l'analyse métier et les outils de reporting.

Modèles :

dim_comptes dim_categories dim_comptes_historique fct_transactions fct_virements mart_solde_mensuel mart_budget_vs_reel ## Fonctionnalités techniques implémentées Modèles incrémentaux

Les modèles fct_transactions et fct_virements utilisent une matérialisation incrémentale avec une stratégie merge.

Cette approche permet de ne traiter que les données nouvelles ou récemment modifiées, plutôt que de reconstruire entièrement les tables à chaque exécution.

Le modèle fct_virements transforme chaque virement exécuté en deux mouvements :

Un mouvement sortant correspondant au débit du compte source. Un mouvement entrant correspondant au crédit du compte destinataire. Historisation **SCD** Type 2

Un snapshot dbt nommé snap_comptes permet de conserver l'historique des modifications des comptes clients.

La stratégie check surveille les changements de certaines colonnes, notamment le statut, l'adresse email et le type de compte.

Les colonnes techniques dbt_valid_from et dbt_valid_to permettent de connaître la période de validité de chaque version.

Le modèle dim_comptes_historique exploite cet historique pour faciliter les analyses temporelles.

### Macros Jinja

Des macros réutilisables permettent de factoriser les traitements **SQL** :

convertir_centimes : conversion des montants en euros vers des centimes. generer_periode : génération d'une période mensuelle au format **YYYY**-MM. test_taux_null : contrôle du pourcentage de valeurs nulles selon un seuil paramétrable. Seeds et packages

Les seeds permettent de gérer des données de référence, notamment les seuils d'alerte et les correspondances entre groupes de catégories.

Les packages dbt-utils et dbt-expectations apportent des fonctionnalités complémentaires pour les transformations et les contrôles de qualité.

Tests et qualité des données

Des tests génériques, singuliers et avancés permettent de contrôler :

L'unicité des identifiants. L'absence de valeurs nulles non autorisées. La cohérence des montants financiers. La validité des opérations entrantes et sortantes. La cohérence des budgets et des soldes. La fraîcheur des données sources. Hooks et traçabilité

Des hooks permettent de journaliser les exécutions et de suivre les traitements incrémentaux.

Le hook pre-hook de fct_transactions enregistre le dernier watermark traité avant l'exécution du modèle.

Exposures

Les exposures documentent les principaux consommateurs des données :

Dashboard Metabase « Suivi budgétaire client ». Rapport automatisé « Synthèse mensuelle ». Gestion des environnements

Le projet distingue deux environnements :

**DEV** : développement et validation des transformations. **PROD** : exécution des modèles validés dans un environnement dédié.

Une macro generate_schema_name adapte la génération des schémas selon l'environnement cible afin de limiter les risques de mélange entre développement et production.

## Rapport technique et bilan du projet

4.1 Pourquoi utiliser des modèles incrémentaux ?

Les modèles incrémentaux sont particulièrement pertinents lorsque les volumes de données deviennent importants et que les tables reçoivent régulièrement de nouvelles lignes. Contrairement à une matérialisation en table classique, ils évitent de recalculer systématiquement tout l'historique. Dans FinTrack, cette approche est utilisée pour fct_transactions et fct_virements. La stratégie merge permet d'insérer les nouveaux enregistrements et de mettre à jour ceux qui existent déjà. Cependant, plusieurs précautions sont nécessaires : choisir une clé unique fiable, définir correctement le filtre incrémental et prévoir le traitement des données modifiées tardivement. Une fenêtre de reprise de sept jours permet notamment de récupérer certaines modifications récentes, mais ne garantit pas la détection de toutes les modifications anciennes.

4.2 Quel est l'intérêt du **SCD** Type 2 ?

Le **SCD** Type 2 est une méthode de gestion des dimensions historiques qui conserve les différentes versions d'un enregistrement au lieu d'écraser ses anciennes valeurs. Dans FinTrack, le snapshot snap_comptes permet de suivre les modifications des comptes clients, notamment celles du statut, de l'email et du type de compte. Chaque changement détecté entraîne la création d'une nouvelle version. Les colonnes dbt_valid_from et dbt_valid_to définissent la période pendant laquelle chaque version est valide. Cette historisation répond à un besoin métier important : retrouver l'état d'un compte à une date passée et comprendre son évolution.

4.3 Pourquoi utiliser des macros Jinja ?

Les macros Jinja permettent de centraliser des traitements **SQL** réutilisables dans plusieurs modèles. Elles évitent les répétitions et facilitent la maintenance du projet. Dans FinTrack, convertir_centimes permet de standardiser les conversions monétaires, tandis que generer_periode uniformise la création des périodes mensuelles. Le test générique test_taux_null permet également de contrôler la qualité des colonnes avec un seuil configurable. En cas de modification d'une règle métier, il suffit ainsi d'adapter la macro concernée plutôt que de modifier plusieurs requêtes **SQL** indépendamment.

4.4 Comment le multi-environnement protège-t-il la production ?

La séparation entre **DEV** et **PROD** permet de distinguer les développements et les traitements réellement destinés à la production. L'environnement **DEV** sert à tester les modèles, les macros et les règles de qualité sans intervenir directement sur les tables de production. L'environnement **PROD** utilise une configuration de connexion et des schémas dédiés. La macro generate_schema_name adapte la destination des modèles selon la cible dbt sélectionnée. Cette organisation réduit les risques d'écrasement accidentel des données, facilite les validations avant déploiement et améliore la reproductibilité des traitements.

## Livrables et documentation

Les éléments de preuve du projet sont regroupés dans le dossier docs/ :

lineage.png : représentation graphique des dépendances entre les sources et les modèles dbt. snapshot_historisation.png : preuve de l'historisation des comptes avec plusieurs versions et leurs dates de validité.

La documentation technique du projet peut être générée avec :

bash dbt docs generate dbt docs serve

## Installation et exécution

Prérequis Python et dbt Core installés. Un compte Snowflake configuré. Un profil dbt Snowflake fonctionnel. Configuration

Copier le fichier profiles.yml.example dans le répertoire ~/.dbt/ sous le nom profiles.yml, puis renseigner les paramètres de connexion Snowflake.

Vérifier la connexion :

bash dbt debug

Installation des dépendances bash dbt deps

Chargement des seeds bash dbt seed

Exécution des modèles bash dbt run

Exécution des snapshots bash dbt snapshot

Exécution des tests bash dbt test

Construction et validation du projet bash dbt build

Documentation dbt bash dbt docs generate dbt docs serve

## Organisation du dépôt

text pj-fintrack/ │ ├── models/ │   ├── staging/ │   ├── intermediate/ │   ├── marts/ │   └── exposures.yml │ ├── snapshots/ ├── macros/ ├── tests/ ├── seeds/ ├── analyses/ ├── docs/ │   ├── lineage.png │   └── snapshot_historisation.png │ ├── scripts/ ├── dbt_project.yml ├── packages.yml ├── profiles.yml.example └── **README**.md

## Conclusion

Ce projet a permis de faire évoluer FinTrack Analytics vers une architecture dbt plus industrialisée. L'utilisation des modèles incrémentaux améliore l'efficacité des traitements, les snapshots assurent la conservation de l'historique des comptes et les macros facilitent la réutilisation des règles métier. Les tests, les hooks, les exposures et la séparation des environnements renforcent la qualité, la traçabilité et la maintenabilité du pipeline.

Le projet constitue ainsi une base analytique permettant de répondre aux besoins de suivi financier et de reporting de FinTrack Analytics.