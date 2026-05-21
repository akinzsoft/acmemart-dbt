WITH transactions AS (

    SELECT * FROM {{ ref('stg_transactions') }}

),

customers AS (

    SELECT * FROM {{ ref('stg_customers') }}

),

products AS (

    SELECT * FROM {{ ref('stg_products') }}

),

final AS (

    SELECT
        t.transaction_id,
        t.transaction_date,
        t.store_id,
        t.store_name,
        t.store_city,
        t.customer_id,
        t.product_id,
        t.quantity,
        t.unit_price,
        t.discount_amount,
        t.total_amount,
        t.payment_method,
        t.channel,

        -- customer attributes
        c.first_name || ' ' || c.last_name      AS customer_full_name,
        c.loyalty_tier,
        c.city                                   AS customer_city,

        -- product attributes
        p.product_name,
        p.category,
        p.sub_category,
        p.cost_price,

        -- calculated metrics
        ROUND(t.total_amount - (p.cost_price * t.quantity), 2)  AS gross_profit,
        ROUND(
            (t.total_amount - (p.cost_price * t.quantity))
            / NULLIF(t.total_amount, 0) * 100, 2
        )                                                        AS gross_margin_pct,

        t._loaded_at

    FROM transactions t
    LEFT JOIN customers c ON t.customer_id = c.customer_id
    LEFT JOIN products  p ON t.product_id  = p.product_id

)

SELECT * FROM final