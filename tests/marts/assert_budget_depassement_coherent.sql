select *
from {{ ref('mart_budget_vs_reel') }}
where
    (montant_reel > montant_prevu) != ( (montant_prevu - montant_reel) < 0)