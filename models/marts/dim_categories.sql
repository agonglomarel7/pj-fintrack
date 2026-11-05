with categories as (
    select * from {{ ref('stg_categories') }}
), 

mapping as (
    select * from {{ ref('mapping_groupes') }}
)

select
    c.categorie_id,
    c.nom_categorie,
    c.type_categorie,
    c.groupe,
    
    m.ordre_affichage,
    m.priorite_dashboard

from categories c

left join mapping m
    on c.groupe = m.groupe
