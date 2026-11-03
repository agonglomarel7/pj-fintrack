
with source as (
    select * from {{ source('pj_fintrack_raw', 'raw_transactions') }}
)

select
    id as transaction_id,
    compte_id,
    cast(date_transaction as timestamp) as date_transaction,
    montant,
    type_operation,
    categorie_id,
    description,
    statut,
    case
        when type_operation = 'credit' then montant
        when type_operation = 'debit'  then -montant    
    end as montant_signe  


from source 