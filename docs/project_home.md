
{% docs project_home %}

# Bienvenue dans PJ_FINTRACK

## Présentation du projet

PJ_FINTRACK est un projet de Data Engineering et de Business Intelligence destiné au suivi financier des clients.

Il permet de centraliser les données bancaires, de suivre les transactions et les virements, de contrôler les budgets et d'analyser l'évolution des soldes.

## Architecture du projet

Le projet repose sur une architecture analytique en plusieurs couches :

### 1. RAW
Les données brutes sont stockées dans Snowflake :
- raw_comptes
- raw_transactions
- raw_budgets
- raw_categories
- raw_virements
- raw_alertes

### 2. STAGING
Les données sont nettoyées, renommées et standardisées.

Principaux modèles :
- stg_comptes
- stg_transactions
- stg_budgets
- stg_categories
- stg_virements
- stg_alertes

### 3. MARTS
Cette couche contient les modèles analytiques :
- dim_comptes
- dim_categories
- fct_transactions
- fct_virements
- mart_solde_mensuel
- mart_budget_vs_reel
- dim_comptes_historique

## Fonctionnalités techniques

Le projet utilise :
- dbt Core pour les transformations SQL.
- Snowflake comme entrepôt de données.
- Des modèles incrémentaux pour optimiser les chargements.
- Des snapshots pour historiser les changements (SCD Type 2).
- Des macros Jinja pour factoriser les traitements.
- Des tests de qualité de données.
- Des hooks pour journaliser les exécutions.
- Des exposures pour documenter les usages BI.
- Des seeds pour enrichir les données.

## Environnements

Deux environnements sont disponibles :

- DEV : développement et validation.
- PROD : environnement de production.

## Objectifs métier

Le projet permet notamment :
- Le suivi des transactions et des virements.
- Le calcul des soldes mensuels.
- Le contrôle des dépassements budgétaires.
- Le suivi historique des comptes.
- L'analyse de rétention des clients.

## Technologies

Snowflake | dbt Core | SQL | Jinja | Git | Metabase

{% enddocs %}
