select *
from {{ ref('mart_budget_vs_reel') }}
where montant_prevu < 0
   or montant_prevu is null