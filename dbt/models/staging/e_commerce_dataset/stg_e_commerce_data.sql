with 

source as (

    select * from {{ source('e_commerce_dataset', 'e-commerce-data') }}

),

renamed as (

    select
        event_time,
        event_type,
        product_id,
        category_id,
        COALESCE( category_code, "unknown") as category_code,
        COALESCE( brand, "unknown") as brand,
        price,
        user_id,
        user_session
    from source

)

select * from renamed

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=false) %}

  limit 1000

{% endif %}