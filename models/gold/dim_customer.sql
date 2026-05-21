WITH stg_customers AS (

    SELECT * FROM {{ ref('stg_customers') }}

),

final AS (

    SELECT
        customer_id,
        first_name,
        last_name,
        first_name || ' ' || last_name      AS full_name,
        email,
        phone,
        city,
        country,
        registration_date,
        loyalty_tier,
        _loaded_at
    FROM stg_customers

)

SELECT * FROM final