select
    virement_id
from {{ ref('fct_virements') }}
group by virement_id
having
    count(distinct compte_id) < 2
    or count(*) != 2