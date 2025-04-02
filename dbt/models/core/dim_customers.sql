 WITH user_data AS(
    SELECT DISTINCT(user_id) FROM {{ source('e_commerce_dataset', 'e-commerce-data') }}
    -- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
    {% if var('is_test_run', default=true) %}
        limit 1000
    {% endif %}
  ),
  fake_data AS (
    SELECT 
        user_id,
        ARRAY<STRING> {{ var('us_states') }}[
            SAFE_OFFSET(
                CAST(
                    POW( -- making unequal distribution over states
                        RAND()*13.5,
                        1.5
                    )
                    AS INT64
                )
            )
        ] AS state,
        ARRAY<STRING>['Male', 'Female'][
            SAFE_OFFSET(
                CAST(
                    FLOOR(
                        RAND()*2
                    ) AS INT64
                )
            )
        ] AS gender
    FROM user_data
  )

SELECT * FROM fake_data