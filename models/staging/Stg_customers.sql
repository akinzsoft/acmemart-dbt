WITH source AS (

    -- customer rows only: have FIRST_NAME but no TRANSACTION_ID
    SELECT * FROM {{ source('bronze', 'acmemart_data') }}
    WHERE FIRST_NAME IS NOT NULL
      AND TRANSACTION_ID IS NULL

),

cleaned AS (

    SELECT
        CUSTOMER_ID                                                         AS customer_id,

        -- fix: standardise name casing (james -> James, THOMAS -> Thomas)
        INITCAP(FIRST_NAME)                                                 AS first_name,
        INITCAP(LAST_NAME)                                                  AS last_name,

        LOWER(EMAIL)                                                        AS email,
        PHONE                                                               AS phone,
        CITY                                                                AS city,
        COUNTRY                                                             AS country,

        -- fix: standardise mixed date formats (YYYY-MM-DD and DD-MM-YYYY)
        COALESCE(
            TRY_TO_DATE(REGISTRATION_DATE, 'YYYY-MM-DD'),
            TRY_TO_DATE(REGISTRATION_DATE, 'DD-MM-YYYY'),
            TRY_TO_DATE(REGISTRATION_DATE, 'DD/MM/YYYY')
        )                                                                   AS registration_date,

        -- fix: standardise loyalty tier casing ('GOLD' -> 'Gold')
        INITCAP(LOYALTY_TIER)                                               AS loyalty_tier,

        _AIRBYTE_EXTRACTED_AT                                               AS _loaded_at

    FROM source

)

SELECT * FROM cleaned