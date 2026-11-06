
{{
    config(
        materialized='table'
    )
}}

with historique as (

    select *
    from {{ ref('snap_comptes') }}

)

select

    id as compte_id,
    nom_client,
    email,
    type_compte,
    date_ouverture,
    solde_initial,
    status as statut,

    dbt_valid_from,
    dbt_valid_to,

    case
        when dbt_valid_to is null then true
        else false
    end as est_version_courante,

    datediff(
        day,
        dbt_valid_from,
        coalesce(dbt_valid_to, current_timestamp())
    ) as duree_jours

from historique
