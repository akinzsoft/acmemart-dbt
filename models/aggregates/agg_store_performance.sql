WITH fct_sales AS (

    SELECT * FROM {{ ref('fct_sales') }}

),

final AS (

    SELECT
        store_id,
        store_name,
        store_city,
        COUNT(DISTINCT transaction_date)    AS trading_days,
        COUNT(transaction_id)               AS total_transactions,
        COUNT(DISTINCT customer_id)         AS unique_customers,
        SUM(quantity)                       AS total_units_sold,
        ROUND(SUM(total_amount), 2)         AS total_revenue,
        ROUND(AVG(total_amount), 2)         AS avg_transaction_value,
        ROUND(SUM(gross_profit), 2)         AS total_gross_profit,
        ROUND(AVG(gross_margin_pct), 2)     AS avg_gross_margin_pct
    FROM fct_sales
    GROUP BY
        store_id,
        store_name,
        store_city
    ORDER BY total_revenue DESC

)

SELECT * FROM final