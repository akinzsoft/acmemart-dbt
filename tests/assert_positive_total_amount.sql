-- Test: all transaction total_amount values must be greater than zero
SELECT
    transaction_id,
    total_amount
FROM {{ ref('stg_transactions') }}
WHERE total_amount <= 0