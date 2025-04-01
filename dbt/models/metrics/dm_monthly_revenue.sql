with
    purchases as (
        select
            user_id,
            event_time,
            event_type,
            price,
            split(category_code, '.')[0] as main_category_code
        from {{ ref("stg_e_commerce_data") }}
        where event_type = 'purchase'
    ),
    customers as (
        select user_id, state from {{ ref("dim_customers") }}
    ),
    joined_data as (
        select event_time, event_type, price, main_category_code, state
        from purchases p
        join customers c on p.user_id = c.user_id
    )
select
    {{ dbt.date_trunc("month", "event_time") }} as event_month,
    state,
    main_category_code,
    sum(price) as revenue,
    count(price) as purchases_count
from joined_data
group by 1, 2, 3
