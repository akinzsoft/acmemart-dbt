-- Test: cost_price must be less than unit_price
SELECT
    product_id,
    product_name,
    unit_price,
    cost_price,
    cost_price - unit_price AS margin_deficit
FROM {{ ref('stg_products') }}
WHERE cost_price > unit_price