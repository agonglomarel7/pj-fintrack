
-- dbt va mettre à jour la table au lieu de la recréer entièrement
-- Si un ID existe déjà, dbt le met à jour. S'il est nouveau, dbt l'ajoute
-- Stratégie "fusion" : combine les mises à jour et les insertions
-- Si la structure change (ex: nouvelle colonne), dbt adapte la table


{{ config(

    materialized='incremental',
    unique_key='mouvement_virement_id',
    incremental_strategy='merge',
    on_schema_change='sync_all_columns'
) }}
-- ÉTAPE 1 : Récupération des données brutes (Sources)
with virements as (
    select *
    from {{ ref('stg_virements') }} -- On charge la liste de tous les virements
),

comptes as (
    select *
    from {{ ref('stg_comptes') }}   -- On charge la liste des comptes des clients
),

-- ÉTAPE 2 : Filtrage
virements_executes as (
    select *
    from virements
    where lower(statut_virement) = 'execute' -- On ne garde QUE les virements réussis/exécutés
),

-- ÉTAPE 3 : Création de la ligne "Débit" (L'argent qui sort du compte source)
mouvements_sortants as (
    select
        v.virement_id,
        concat(v.virement_id, '_sortant') as mouvement_virement_id, -- Clé unique pour le virement sortant
        v.compte_source_id as compte_id,                            -- Le compte qui est débité
        c.nom_client,                                               -- Nom du propriétaire du compte source
        v.date_virement,
        v.montant_virement,
        -v.montant_virement as montant_signe,                       -- Moins (-) devant le montant car c'est une sortie
        'sortant' as sens                                           -- Étiquette pour identifier le type de mouvement

    from virements_executes v
    left join comptes c
        on v.compte_source_id = c.compte_id                         -- On cherche le nom du client source
),

-- ÉTAPE 4 : Création de la ligne "Crédit" (L'argent qui arrive sur le compte destination)
mouvements_entrants as (
    select
        v.virement_id,
        concat(v.virement_id, '_entrant') as mouvement_virement_id, -- Clé unique pour le virement entrant
        v.compte_destination_id as compte_id,                       -- Le compte qui est crédité
        c.nom_client,                                               -- Nom du propriétaire du compte destination
        v.date_virement,
        v.montant_virement,
        v.montant_virement as montant_signe,                        -- Montant positif (+) car c'est une entrée
        'entrant' as sens                                           -- Étiquette pour identifier le type de mouvement

    from virements_executes v
    left join comptes c
        on v.compte_destination_id = c.compte_id                    -- On cherche le nom du client de destination
),

-- ÉTAPE 5 : Fusion des deux listes
union_mouvements as (
    select * from mouvements_sortants
    union all
    select * from mouvements_entrants -- On colle les lignes entrantes sous les lignes sortantes
)

-- ÉTAPE 6 : Sélection finale et filtre de performance (Incrémental)
select *
from union_mouvements

{% if is_incremental() %}
-- Ce filtre ne s'active que si la table existe déjà. 
-- Il évite de recharger tout l'historique en ne prenant que les virements des 7 derniers jours.
where date_virement >= (
    select coalesce(
        dateadd(day, -7, max(date_virement)),
        '1900-01-01'::timestamp
    )
    from {{ this }} -- Référence à cette table elle-même
)
{% endif %}
