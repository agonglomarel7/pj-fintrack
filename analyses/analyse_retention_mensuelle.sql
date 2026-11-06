with clients_actifs as (

    select distinct
        compte_id,
        nom_client,
        date_trunc('month', date_transaction)::date as mois

    from {{ ref('fct_transactions') }}

    where statut = 'validee'

),

retention as (

    select
        actuel.mois,
        count(distinct actuel.compte_id) as clients_actifs,

        count(distinct suivant.compte_id) as clients_retenus

    from clients_actifs actuel

    left join clients_actifs suivant
        on actuel.compte_id = suivant.compte_id
        and suivant.mois = dateadd(month, 1, actuel.mois)

    group by actuel.mois

)

select
    mois,
    clients_actifs,
    clients_retenus,

    round(
        clients_retenus * 100.0
        / nullif(clients_actifs, 0),
        2
    ) as taux_retention_pct

from retention

order by mois