WITH stg_products AS (

    SELECT * FROM {{ ref('stg_products') }}

),

final AS (

    SELECT
        product_id,
        product_name,
        category,
        sub_category,
        unit_price,
        cost_price,
        ROUND(unit_price - cost_price, 2)                                   AS gross_margin,
        ROUND((unit_price - cost_price) / NULLIF(unit_price, 0) * 100, 2)  AS margin_pct,
        supplier_name,
        is_active,
        _loaded_at
    FROM stg_products

)

SELECT * FROM final