# AcmeMart dbt Project

## Overview
This dbt project transforms raw AcmeMart retail data from the Snowflake BRONZE schema
into clean, structured staging, gold, and aggregate layers for analytics.

## Project Structure
```
acmemart_dbt/
models/
  staging/       -- Clean and type-cast raw BRONZE data
  gold/          -- Fact and dimension tables
  aggregates/    -- Pre-summarised reporting tables
tests/           -- Custom data quality tests
macros/          -- Reusable SQL macros
seeds/           -- Static reference data
```

## Layers

| Layer | Schema | Materialisation | Purpose |
|---|---|---|---|
| Staging | STAGING | View | Clean, rename, type-cast BRONZE data |
| Gold | GOLD | Table | Fact and dimension tables |
| Aggregates | AGGREGATES | Table | Pre-summarised reporting datasets |

## Data Sources
- Google Drive CSV files ingested via Airbyte
- Landing schema: ACMEMART_DB.BRONZE

## Key Models
- `stg_transactions` - Cleaned transaction data
- `stg_customers` - Cleaned customer profiles
- `stg_products` - Cleaned product catalogue
- `fct_sales` - Sales fact table
- `dim_customer` - Customer dimension
- `dim_product` - Product dimension
- `agg_sales_daily` - Daily sales aggregates
- `agg_store_performance` - Store performance summary

## Running the Project
```bash
dbt deps          # Install packages
dbt debug         # Test Snowflake connection
dbt run           # Run all models
dbt test          # Run all tests
dbt docs generate # Generate documentation
dbt docs serve    # View lineage graph
```

## Data Quality Issues Fixed in Staging
- Duplicate transaction TXN020 removed
- Mixed date formats standardised to YYYY-MM-DD
- NULL payment_method coalesced to 'unknown'
- Currency symbol stripped from unit_price
- Zero quantity rows filtered out
- Channel and loyalty_tier casing standardised
