{% macro log_dbt_run(results) %}

    {% if execute %}

        {% set nb_models = results
            | selectattr('node.resource_type', 'equalto', 'model')
            | list
            | length
        %}

        {% set failures = results
            | selectattr('status', 'in', ['error', 'fail'])
            | list
            | length
        %}

        {% if failures > 0 %}
            {% set run_status = 'ERROR' %}
        {% else %}
            {% set run_status = 'SUCCESS' %}
        {% endif %}

        {% set sql %}

            insert into {{ target.database }}.MARTS.DBT_RUN_LOG
            (
                run_id,
                started_at,
                completed_at,
                status,
                nb_models
            )
            values
            (
                '{{ invocation_id }}',
                '{{ run_started_at }}'::timestamp_ntz,
                current_timestamp(),
                '{{ run_status }}',
                {{ nb_models }}
            )

        {% endset %}

        {% do run_query(sql) %}

    {% endif %}

{% endmacro %}