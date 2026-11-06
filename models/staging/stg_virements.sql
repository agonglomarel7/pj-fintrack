with virement  as (
    select * from {{ source('pj_fintrack_raw', 'raw_virements') }}
)

select 
    id  as virement_id,
    compte_source_id,
    compte_dest_id as compte_destination_id,
    montant as montant_virement,
    cast(date_virement as TIMESTAMP) as date_virement,
    motif as motif_virement,
    statut as statut_virement

from virement