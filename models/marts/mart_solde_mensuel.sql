
{{
    config(
        materialized='table'
    )
}}

-- 1. Récupération des transactions validées
with transactions as (

    select
        compte_id,
        {{ generer_periode('mois_transaction') }} as periode,

        sum(case
            when type_operation = 'credit' then montant
            else 0
        end) as total_credits,

        sum(case
            when type_operation = 'debit' then montant
            else 0
        end) as total_debits,

        sum(montant_signe) as solde_net_mois

    from {{ ref('fct_transactions') }}

    where statut = 'validee'

    group by
        compte_id,
        {{ generer_periode('mois_transaction') }}

),

-- 2. Récupération des virements
virements as (

    select
        compte_id,
        {{ generer_periode("date_virement") }} as periode,

        sum(case
            when sens = 'entrant' then montant_virement
            else 0
        end) as total_credits,

        sum(case
            when sens = 'sortant' then montant_virement
            else 0
        end) as total_debits,

        sum(montant_signe) as solde_net_mois

    from {{ ref('fct_virements') }}

    group by
        compte_id,
        {{ generer_periode("date_virement") }}

),

-- 3. Regroupement des mouvements
tous_les_mouvements as (

    select * from transactions

    union all

    select * from virements

),

-- 4. Agrégation mensuelle
transactions_mensuelles as (

    select
        compte_id,
        periode,
        sum(total_credits) as total_credits,
        sum(total_debits) as total_debits,
        sum(solde_net_mois) as solde_net_mois

    from tous_les_mouvements

    group by
        compte_id,
        periode

),

-- 5. Informations des comptes
comptes as (

    select
        compte_id,
        nom_client,
        type_compte,
        solde_initial

    from {{ ref('dim_comptes') }}

)

-- 6. Calcul des soldes et conversion en centimes
select
    tm.compte_id,
    c.nom_client,
    c.type_compte,

    tm.periode,
    to_date(tm.periode || '-01') as mois,

    tm.total_credits,
    tm.total_debits,
    tm.solde_net_mois,

    -- Conversion des montants en centimes
    {{ convertir_centimes('tm.total_credits') }} as total_credits_centimes,
    {{ convertir_centimes('tm.total_debits') }} as total_debits_centimes,
    {{ convertir_centimes('tm.solde_net_mois') }} as solde_net_centimes,

    -- Solde cumulé en euros
    c.solde_initial + sum(tm.solde_net_mois) over (
        partition by tm.compte_id
        order by tm.periode
        rows between unbounded preceding and current row
    ) as solde_cumule,

    -- Solde cumulé en centimes
    {{ convertir_centimes(
        'c.solde_initial + sum(tm.solde_net_mois) over (
            partition by tm.compte_id
            order by tm.periode
            rows between unbounded preceding and current row
        )'
    ) }} as solde_cumule_centimes

from transactions_mensuelles tm

inner join comptes c
    on tm.compte_id = c.compte_id
