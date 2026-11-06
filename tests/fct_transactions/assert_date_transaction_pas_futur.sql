select *
from {{ ref('fct_transactions') }}
where date_transaction > current_date()