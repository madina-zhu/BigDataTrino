-- Очистка звезды и витрин перед повторным запуском ETL (делает запуск идемпотентным).
TRUNCATE TABLE star_schema.dim_customers;
TRUNCATE TABLE star_schema.dim_sellers;
TRUNCATE TABLE star_schema.dim_products;
TRUNCATE TABLE star_schema.dim_stores;
TRUNCATE TABLE star_schema.dim_suppliers;
TRUNCATE TABLE star_schema.dim_dates;
TRUNCATE TABLE star_schema.fact_sales;
TRUNCATE TABLE reports.report_products;
TRUNCATE TABLE reports.report_customers;
TRUNCATE TABLE reports.report_time;
TRUNCATE TABLE reports.report_stores;
TRUNCATE TABLE reports.report_suppliers;
TRUNCATE TABLE reports.report_product_quality;
