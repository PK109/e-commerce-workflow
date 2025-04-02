-- conversion rate (CVR) is the number of people who made a purchase out of the total
-- number of people who accessed your website
-- Reference: https://www.shopify.com/blog/basic-ecommerce-metrics#1
with
    source as (select user_session, event_type from {{ ref("stg_e_commerce_data") }}),
    purchase_done as (
        select
            user_session,
            count(case when event_type = 'purchase' then 1 end) > 0 as has_purchase
        from source
        group by 1
    )
select round(countif(has_purchase) * 100.0 / count(*), 1) as cvr
from purchase_done
