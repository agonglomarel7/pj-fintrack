{% macro log_incremental_watermark() %}

    {% if is_incremental() %}

        insert into {{ target.database }}.MARTS.DBT_INCREMENTAL_LOG
        (
            RUN_ID,
            MODEL_NAME,
            LAST_MAX_DATE,
            LOGGED_AT
        )

        select
            '{{ invocation_id }}',
            'fct_transactions',
            max(date_transaction),
            current_timestamp()

        from {{ this }}

    {% endif %}

{% endmacro %}