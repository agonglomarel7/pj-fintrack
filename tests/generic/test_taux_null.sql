
{% test test_taux_null(model, column_name, seuil_pct) %}

    select
        count(*) as total_lignes,
        count_if({{ column_name }} is null) as valeurs_nulles

    from {{ model }}

    having
        count_if({{ column_name }} is null)
        * 100.0 / nullif(count(*), 0) > {{ seuil_pct }}

{% endtest %}
