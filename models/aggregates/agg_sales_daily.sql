WITH fct_sales AS (

    SELECT * FROM {{ ref('fct_sales') }}

),

final AS (

    SELECT
        transaction_date,
        store_id,
        store_name,
        store_city,
        channel,
        COUNT(transaction_id)               AS transaction_count,
        SUM(quantity)                       AS total_units_sold,
        ROUND(SUM(total_amount), 2)         AS total_revenue,
        ROUND(AVG(total_amount), 2)         AS avg_transaction_value,
        ROUND(SUM(discount_amount), 2)      AS total_discounts,
        ROUND(SUM(gross_profit), 2)         AS total_gross_profit
    FROM fct_sales
    GROUP BY
        transaction_date,
        store_id,
        store_name,
        store_city,
        channel

)

SELECT * FROM final