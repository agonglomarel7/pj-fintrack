select *
from {{ ref('fct_virements') }}
where montant_virement <= 0
   or montant_virement is null