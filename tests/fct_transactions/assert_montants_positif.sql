select *
from {{ ref('fct_transactions') }}
where montant <= 0
   or montant is null