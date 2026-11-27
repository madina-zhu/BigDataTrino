-- ============================================================================
-- ETL: источники (PostgreSQL + ClickHouse) -> модель «Звезда» в ClickHouse
-- Запуск: docker exec lab_trino trino --file /scripts/01_etl_star_schema.sql
--
-- Суррогатный ключ измерения = xxhash64 от ВСЕХ атрибутов измерения (concat_ws '|').
-- Поэтому DISTINCT-строка измерения <-> один ключ (дублей ключей нет, JOIN не размножает факты),
-- а таблица фактов вычисляет ровно те же ключи из тех же атрибутов.
-- ============================================================================

-- dim_customers
INSERT INTO clickhouse.star_schema.dim_customers
WITH all_data AS (
    SELECT 'pg' AS src, * FROM postgresql.public.mock_data
    UNION ALL
    SELECT 'ch' AS src, * FROM clickhouse.default.mock_data
),
norm AS (
    SELECT DISTINCT
        COALESCE(customer_first_name, '') AS customer_first_name,
        COALESCE(customer_last_name, '') AS customer_last_name,
        COALESCE(customer_age, 0) AS customer_age,
        COALESCE(customer_email, '') AS customer_email,
        COALESCE(customer_country, '') AS customer_country,
        COALESCE(customer_postal_code, '') AS customer_postal_code,
        COALESCE(customer_pet_type, '') AS customer_pet_type,
        COALESCE(customer_pet_name, '') AS customer_pet_name,
        COALESCE(customer_pet_breed, '') AS customer_pet_breed
    FROM all_data
)
SELECT
    from_big_endian_64(xxhash64(to_utf8(concat_ws('|', customer_first_name, customer_last_name, CAST(customer_age AS VARCHAR), customer_email, customer_country, customer_postal_code, customer_pet_type, customer_pet_name, customer_pet_breed)))) AS customer_sk,
    customer_first_name AS first_name,
    customer_last_name AS last_name,
    customer_age AS age,
    customer_email AS email,
    customer_country AS country,
    customer_postal_code AS postal_code,
    customer_pet_type AS pet_type,
    customer_pet_name AS pet_name,
    customer_pet_breed AS pet_breed
FROM norm;

-- dim_sellers
INSERT INTO clickhouse.star_schema.dim_sellers
WITH all_data AS (
    SELECT 'pg' AS src, * FROM postgresql.public.mock_data
    UNION ALL
    SELECT 'ch' AS src, * FROM clickhouse.default.mock_data
),
norm AS (
    SELECT DISTINCT
        COALESCE(seller_first_name, '') AS seller_first_name,
        COALESCE(seller_last_name, '') AS seller_last_name,
        COALESCE(seller_email, '') AS seller_email,
        COALESCE(seller_country, '') AS seller_country,
        COALESCE(seller_postal_code, '') AS seller_postal_code
    FROM all_data
)
SELECT
    from_big_endian_64(xxhash64(to_utf8(concat_ws('|', seller_first_name, seller_last_name, seller_email, seller_country, seller_postal_code)))) AS seller_sk,
    seller_first_name AS first_name,
    seller_last_name AS last_name,
    seller_email AS email,
    seller_country AS country,
    seller_postal_code AS postal_code
FROM norm;

-- dim_products
INSERT INTO clickhouse.star_schema.dim_products
WITH all_data AS (
    SELECT 'pg' AS src, * FROM postgresql.public.mock_data
    UNION ALL
    SELECT 'ch' AS src, * FROM clickhouse.default.mock_data
),
norm AS (
    SELECT DISTINCT
        COALESCE(product_name, '') AS product_name,
        COALESCE(product_category, '') AS product_category,
        COALESCE(pet_category, '') AS pet_category,
        COALESCE(product_price, DECIMAL '0.00') AS product_price,
        COALESCE(product_weight, DECIMAL '0.00') AS product_weight,
        COALESCE(product_color, '') AS product_color,
        COALESCE(product_size, '') AS product_size,
        COALESCE(product_brand, '') AS product_brand,
        COALESCE(product_material, '') AS product_material,
        COALESCE(product_description, '') AS product_description,
        COALESCE(product_rating, DECIMAL '0.00') AS product_rating,
        COALESCE(product_reviews, 0) AS product_reviews,
        COALESCE(product_release_date, '') AS product_release_date,
        COALESCE(product_expiry_date, '') AS product_expiry_date
    FROM all_data
)
SELECT
    from_big_endian_64(xxhash64(to_utf8(concat_ws('|', product_name, product_category, pet_category, CAST(product_price AS VARCHAR), CAST(product_weight AS VARCHAR), product_color, product_size, product_brand, product_material, product_description, CAST(product_rating AS VARCHAR), CAST(product_reviews AS VARCHAR), product_release_date, product_expiry_date)))) AS product_sk,
    product_name AS product_name,
    product_category AS category,
    pet_category AS pet_category,
    product_price AS price,
    product_weight AS weight,
    product_color AS color,
    product_size AS size,
    product_brand AS brand,
    product_material AS material,
    product_description AS description,
    product_rating AS rating,
    product_reviews AS reviews,
    product_release_date AS release_date,
    product_expiry_date AS expiry_date
FROM norm;

-- dim_stores
INSERT INTO clickhouse.star_schema.dim_stores
WITH all_data AS (
    SELECT 'pg' AS src, * FROM postgresql.public.mock_data
    UNION ALL
    SELECT 'ch' AS src, * FROM clickhouse.default.mock_data
),
norm AS (
    SELECT DISTINCT
        COALESCE(store_name, '') AS store_name,
        COALESCE(store_location, '') AS store_location,
        COALESCE(store_city, '') AS store_city,
        COALESCE(store_state, '') AS store_state,
        COALESCE(store_country, '') AS store_country,
        COALESCE(store_phone, '') AS store_phone,
        COALESCE(store_email, '') AS store_email
    FROM all_data
)
SELECT
    from_big_endian_64(xxhash64(to_utf8(concat_ws('|', store_name, store_location, store_city, store_state, store_country, store_phone, store_email)))) AS store_sk,
    store_name AS store_name,
    store_location AS location,
    store_city AS city,
    store_state AS state,
    store_country AS country,
    store_phone AS phone,
    store_email AS email
FROM norm;

-- dim_suppliers
INSERT INTO clickhouse.star_schema.dim_suppliers
WITH all_data AS (
    SELECT 'pg' AS src, * FROM postgresql.public.mock_data
    UNION ALL
    SELECT 'ch' AS src, * FROM clickhouse.default.mock_data
),
norm AS (
    SELECT DISTINCT
        COALESCE(supplier_name, '') AS supplier_name,
        COALESCE(supplier_contact, '') AS supplier_contact,
        COALESCE(supplier_email, '') AS supplier_email,
        COALESCE(supplier_phone, '') AS supplier_phone,
        COALESCE(supplier_address, '') AS supplier_address,
        COALESCE(supplier_city, '') AS supplier_city,
        COALESCE(supplier_country, '') AS supplier_country
    FROM all_data
)
SELECT
    from_big_endian_64(xxhash64(to_utf8(concat_ws('|', supplier_name, supplier_contact, supplier_email, supplier_phone, supplier_address, supplier_city, supplier_country)))) AS supplier_sk,
    supplier_name AS supplier_name,
    supplier_contact AS contact,
    supplier_email AS email,
    supplier_phone AS phone,
    supplier_address AS address,
    supplier_city AS city,
    supplier_country AS country
FROM norm;

-- dim_dates
INSERT INTO clickhouse.star_schema.dim_dates
WITH all_data AS (
    SELECT 'pg' AS src, * FROM postgresql.public.mock_data
    UNION ALL
    SELECT 'ch' AS src, * FROM clickhouse.default.mock_data
),
parsed_dates AS (
    SELECT DISTINCT CAST(date_parse(sale_date, '%m/%d/%Y') AS DATE) AS full_date
    FROM all_data
    WHERE sale_date IS NOT NULL AND sale_date <> ''
)
SELECT
    CAST(date_format(full_date, '%Y%m%d') AS BIGINT) AS date_sk,
    full_date,
    CAST(year(full_date) AS INTEGER) AS year,
    CAST(month(full_date) AS INTEGER) AS month,
    CAST(day(full_date) AS INTEGER) AS day,
    CAST(quarter(full_date) AS INTEGER) AS quarter,
    CAST(day_of_week(full_date) AS INTEGER) AS day_of_week
FROM parsed_dates;

-- fact_sales
INSERT INTO clickhouse.star_schema.fact_sales
WITH all_data AS (
    SELECT 'pg' AS src, * FROM postgresql.public.mock_data
    UNION ALL
    SELECT 'ch' AS src, * FROM clickhouse.default.mock_data
),
norm AS (
    SELECT
        src,
        COALESCE(customer_first_name, '') AS customer_first_name,
        COALESCE(customer_last_name, '') AS customer_last_name,
        COALESCE(customer_age, 0) AS customer_age,
        COALESCE(customer_email, '') AS customer_email,
        COALESCE(customer_country, '') AS customer_country,
        COALESCE(customer_postal_code, '') AS customer_postal_code,
        COALESCE(customer_pet_type, '') AS customer_pet_type,
        COALESCE(customer_pet_name, '') AS customer_pet_name,
        COALESCE(customer_pet_breed, '') AS customer_pet_breed,
        COALESCE(seller_first_name, '') AS seller_first_name,
        COALESCE(seller_last_name, '') AS seller_last_name,
        COALESCE(seller_email, '') AS seller_email,
        COALESCE(seller_country, '') AS seller_country,
        COALESCE(seller_postal_code, '') AS seller_postal_code,
        COALESCE(product_name, '') AS product_name,
        COALESCE(product_category, '') AS product_category,
        COALESCE(pet_category, '') AS pet_category,
        COALESCE(product_price, DECIMAL '0.00') AS product_price,
        COALESCE(product_weight, DECIMAL '0.00') AS product_weight,
        COALESCE(product_color, '') AS product_color,
        COALESCE(product_size, '') AS product_size,
        COALESCE(product_brand, '') AS product_brand,
        COALESCE(product_material, '') AS product_material,
        COALESCE(product_description, '') AS product_description,
        COALESCE(product_rating, DECIMAL '0.00') AS product_rating,
        COALESCE(product_reviews, 0) AS product_reviews,
        COALESCE(product_release_date, '') AS product_release_date,
        COALESCE(product_expiry_date, '') AS product_expiry_date,
        COALESCE(store_name, '') AS store_name,
        COALESCE(store_location, '') AS store_location,
        COALESCE(store_city, '') AS store_city,
        COALESCE(store_state, '') AS store_state,
        COALESCE(store_country, '') AS store_country,
        COALESCE(store_phone, '') AS store_phone,
        COALESCE(store_email, '') AS store_email,
        COALESCE(supplier_name, '') AS supplier_name,
        COALESCE(supplier_contact, '') AS supplier_contact,
        COALESCE(supplier_email, '') AS supplier_email,
        COALESCE(supplier_phone, '') AS supplier_phone,
        COALESCE(supplier_address, '') AS supplier_address,
        COALESCE(supplier_city, '') AS supplier_city,
        COALESCE(supplier_country, '') AS supplier_country,
        COALESCE(sale_quantity, 0) AS sale_quantity,
        COALESCE(sale_total_price, DECIMAL '0.00') AS sale_total_price,
        COALESCE(sale_date, '') AS sale_date,
        id
    FROM all_data
)
SELECT
    from_big_endian_64(xxhash64(to_utf8(concat_ws('|', src, CAST(id AS VARCHAR), sale_date, customer_email, seller_email, store_email, supplier_email, product_name, product_brand)))) AS sale_sk,
    from_big_endian_64(xxhash64(to_utf8(concat_ws('|', customer_first_name, customer_last_name, CAST(customer_age AS VARCHAR), customer_email, customer_country, customer_postal_code, customer_pet_type, customer_pet_name, customer_pet_breed)))) AS customer_sk,
    from_big_endian_64(xxhash64(to_utf8(concat_ws('|', seller_first_name, seller_last_name, seller_email, seller_country, seller_postal_code)))) AS seller_sk,
    from_big_endian_64(xxhash64(to_utf8(concat_ws('|', product_name, product_category, pet_category, CAST(product_price AS VARCHAR), CAST(product_weight AS VARCHAR), product_color, product_size, product_brand, product_material, product_description, CAST(product_rating AS VARCHAR), CAST(product_reviews AS VARCHAR), product_release_date, product_expiry_date)))) AS product_sk,
    from_big_endian_64(xxhash64(to_utf8(concat_ws('|', store_name, store_location, store_city, store_state, store_country, store_phone, store_email)))) AS store_sk,
    from_big_endian_64(xxhash64(to_utf8(concat_ws('|', supplier_name, supplier_contact, supplier_email, supplier_phone, supplier_address, supplier_city, supplier_country)))) AS supplier_sk,
    CAST(date_format(CAST(date_parse(sale_date, '%m/%d/%Y') AS DATE), '%Y%m%d') AS BIGINT) AS date_sk,
    sale_quantity,
    sale_total_price,
    product_price AS unit_price
FROM norm;
