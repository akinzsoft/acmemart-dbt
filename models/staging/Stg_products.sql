WITH source AS (

    -- product rows only: have PRODUCT_NAME but no TRANSACTION_ID or FIRST_NAME
    SELECT * FROM {{ source('bronze', 'acmemart_data') }}
    WHERE PRODUCT_NAME IS NOT NULL
      AND TRANSACTION_ID IS NULL
      AND FIRST_NAME IS NULL

),

cleaned AS (

    SELECT
        PRODUCT_ID                                                          AS product_id,
        PRODUCT_NAME                                                        AS product_name,

        -- fix: standardise category casing ('grocery' -> 'Groceries')
        CASE
            WHEN LOWER(CATEGORY) IN ('grocery', 'groceries') THEN 'Groceries'
            WHEN LOWER(CATEGORY) = 'personal care'           THEN 'Personal Care'
            WHEN LOWER(CATEGORY) = 'household'               THEN 'Household'
            ELSE INITCAP(CATEGORY)
        END                                                                 AS category,

        SUB_CATEGORY                                                        AS sub_category,
        TRY_TO_DECIMAL(UNIT_PRICE, 10, 2)                                  AS unit_price,
        TRY_TO_DECIMAL(COST_PRICE, 10, 2)                                  AS cost_price,
        SUPPLIER_NAME                                                       AS supplier_name,
        CASE
            WHEN UPPER(IS_ACTIVE) = 'TRUE'  THEN TRUE
            WHEN UPPER(IS_ACTIVE) = 'FALSE' THEN FALSE
            ELSE NULL
        END                                                                 AS is_active,

        _AIRBYTE_EXTRACTED_AT                                               AS _loaded_at

    FROM source

)

SELECT * FROM cleaned