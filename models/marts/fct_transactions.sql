
{{
    config(
        materialized='incremental',
        unique_key='transaction_id',
        incremental_strategy='merge',
        on_schema_change='sync_all_columns',
        full_refresh = false 
    
    )
}}


with enrichies as (
    select * from {{ ref('int_transactions_enrichies') }}
)

select 
    transaction_id,
    compte_id,
    categorie_id,
    date_transaction,
    mois_transaction,
    montant,
    montant_signe,
    type_operation,
    nom_client,
    nom_categorie,
    groupe,
    statut 
    
from enrichies

{% if is_incremental() %} 
    where date_transaction >= ( select coalesce(dateadd(day,-7,max(date_transaction)),'1900-01-01'::timestamp) from {{this}} )
{% endif %}
