with alertes as (
    select * from {{ source('pj_fintrack_raw', 'raw_alertes') }}
),

seuil as (
    select * from {{ ref('seuils_alerte') }}
)

select 
    a.id as alert_id,
    a.compte_id,
    a.categorie_id,
    cast (a.mois as DATE) as mois,
    a.type_alerte,
    a.montant_prevu,
    a.montant_reel,
    a.date_generation,
    a.acquittee,
    
    s.seuil_pct,
    s.severite,
    s.description as description_alertes
    
from alertes a

left join seuil s on a.type_alerte = s.code_alerte