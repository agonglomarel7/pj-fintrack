
{% snapshot snap_comptes %}

{{
    config(
        target_schema='snapshots',
        unique_key='id',
        strategy='check',
        check_cols=['status', 'email', 'type_compte']
    )
}}

-- target_schema Schéma Snowflake dans lequel dbt crée le snapshot

-- unique_key Identifiant unique du compte

-- strategy='check' Compare les colonnes surveillées

-- check_cols Colonnes dont les modifications doivent être historisées

select
    id,
    nom_client,
    email,
    type_compte,
    date_ouverture,
    solde_initial,
    status

from {{ source('pj_fintrack_raw', 'raw_comptes') }}

{% endsnapshot %}
