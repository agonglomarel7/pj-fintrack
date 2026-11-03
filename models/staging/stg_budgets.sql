with source as (
    select * from {{ source('pj_fintrack_raw', 'raw_budgets') }}
)


select
    id as budget_id,
    compte_id,
    categorie_id,
    cast(mois as DATE) as mois,
    montant_prevu

from source