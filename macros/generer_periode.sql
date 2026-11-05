
{% macro generer_periode(colonne_date) %}

    TO_CHAR({{ colonne_date }}, 'YYYY-MM')

{% endmacro %}
