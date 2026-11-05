select *
from {{ ref('fct_transactions') }}
where
    (
        type_operation = 'debit'
        and montant_signe >= 0
    )
    or
    (
        type_operation = 'credit'
        and montant_signe <= 0
    )
    or montant_signe is null