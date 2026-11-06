{% test solde_epargne_non_negatif(model) %}

select *
from {{ model }}
where type_compte = 'epargne'
  and solde_cumule < 0

{% endtest %}