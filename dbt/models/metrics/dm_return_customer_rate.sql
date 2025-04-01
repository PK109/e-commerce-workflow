-- returning customer rate is the number of customers who have made more than one
-- purchase from your shop.
-- Reference: https://www.shopify.com/blog/basic-ecommerce-metrics#5
with
    source as (
        select user_id, user_session, event_type from {{ ref("stg_e_commerce_data") }}
    ),
    filter_purchase as (
        select user_session, min(user_id) as user_id
        from source
        where event_type = "purchase"
        group by 1
    ),
    purchase_counts as (
        select user_id, count(user_session) as purchases_count
        from filter_purchase
        group by 1
    )
select
    round(
        countif(purchases_count > 1) * 100 / count(purchases_count), 1
    ) as return_customer_rate
from purchase_counts
