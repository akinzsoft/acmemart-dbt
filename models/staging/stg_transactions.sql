WITH source AS (

    SELECT * FROM {{ source('bronze', 'acmemart_data') }}
    WHERE TRANSACTION_ID IS NOT NULL          -- transactions only
      AND TRY_TO_NUMBER(QUANTITY) > 0         -- fix: remove zero quantity rows (TXN021)

),

deduplicated AS (

    -- fix: remove duplicate TXN020 - keep the latest loaded record
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY TRANSACTION_ID
            ORDER BY _AIRBYTE_EXTRACTED_AT DESC
        ) AS row_num
    FROM source

),

cleaned AS (

    SELECT
        TRANSACTION_ID                                                      AS transaction_id,

        -- fix: standardise mixed date formats (YYYY-MM-DD and DD/MM/YYYY)
        COALESCE(
            TRY_TO_DATE(TRANSACTION_DATE, 'YYYY-MM-DD'),
            TRY_TO_DATE(TRANSACTION_DATE, 'DD/MM/YYYY'),
            TRY_TO_DATE(TRANSACTION_DATE, 'DD-MM-YYYY')
        )                                                                   AS transaction_date,

        STORE_ID                                                            AS store_id,
        STORE_NAME                                                          AS store_name,
        STORE_CITY                                                          AS store_city,
        CUSTOMER_ID                                                         AS customer_id,
        PRODUCT_ID                                                          AS product_id,
        TRY_TO_NUMBER(QUANTITY)::INT                                        AS quantity,

        -- fix: strip GBP currency symbol from unit_price (TXN010)
        TRY_TO_DECIMAL(REPLACE(REPLACE(UNIT_PRICE, '£', ''), 'GBP', ''), 10, 2)
                                                                            AS unit_price,

        COALESCE(TRY_TO_DECIMAL(DISCOUNT_AMOUNT, 10, 2), 0.00)             AS discount_amount,
        TRY_TO_DECIMAL(TOTAL_AMOUNT, 10, 2)                                AS total_amount,

        -- fix: coalesce null payment_method to 'unknown' (TXN012, TXN018)
        COALESCE(LOWER(PAYMENT_METHOD), 'unknown')                          AS payment_method,

        -- fix: standardise channel casing ('In-Store' -> 'in-store')
        LOWER(CHANNEL)                                                      AS channel,

        _AIRBYTE_EXTRACTED_AT                                               AS _loaded_at

    FROM deduplicated
    WHERE row_num = 1  -- keep only one record per transaction_id

)

SELECT * FROM cleaned