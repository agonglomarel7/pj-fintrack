
{% macro convertir_centimes(colonne) %}

    ROUND({{ colonne }} * 100, 0)

{% endmacro %}
