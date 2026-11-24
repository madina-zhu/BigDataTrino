INSERT INTO clickhouse.star_schema.dim_customers
WITH all_data AS (
    SELECT * FROM postgresql.public.mock_data
    UNION ALL
    SELECT * FROM clickhouse.default.mock_data
),
unique_customers AS (
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
    from_big_endian_64(xxhash64(to_utf8(concat(
        customer_email, '|', customer_first_name, '|', customer_last_name
    )))) AS customer_sk,
    customer_first_name, customer_last_name, customer_age, customer_email,
    customer_country, customer_postal_code, customer_pet_type, customer_pet_name, customer_pet_breed
FROM unique_customers;

INSERT INTO clickhouse.star_schema.dim_sellers
WITH all_data AS (
    SELECT * FROM postgresql.public.mock_data
    UNION ALL
    SELECT * FROM clickhouse.default.mock_data
),
unique_sellers AS (
    SELECT DISTINCT
        COALESCE(seller_first_name, '') AS seller_first_name,
        COALESCE(seller_last_name, '') AS seller_last_name,
        COALESCE(seller_email, '') AS seller_email,
        COALESCE(seller_country, '') AS seller_country,
        COALESCE(seller_postal_code, '') AS seller_postal_code
    FROM all_data
)
SELECT
    from_big_endian_64(xxhash64(to_utf8(concat(
        seller_email, '|', seller_first_name, '|', seller_last_name
    )))) AS seller_sk,
    seller_first_name, seller_last_name, seller_email, seller_country, seller_postal_code
FROM unique_sellers;

INSERT INTO clickhouse.star_schema.dim_products
WITH all_data AS (
    SELECT * FROM postgresql.public.mock_data
    UNION ALL
    SELECT * FROM clickhouse.default.mock_data
),
unique_products AS (
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
    from_big_endian_64(xxhash64(to_utf8(concat(
        product_name, '|', product_brand, '|', CAST(product_price AS VARCHAR)
    )))) AS product_sk,
    product_name, product_category, pet_category, product_price, product_weight,
    product_color, product_size, product_brand, product_material, product_description,
    product_rating, product_reviews, product_release_date, product_expiry_date
FROM unique_products;

INSERT INTO clickhouse.star_schema.dim_stores
WITH all_data AS (
    SELECT * FROM postgresql.public.mock_data
    UNION ALL
    SELECT * FROM clickhouse.default.mock_data
),
unique_stores AS (
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
    from_big_endian_64(xxhash64(to_utf8(concat(
        store_name, '|', store_city, '|', store_email
    )))) AS store_sk,
    store_name, store_location, store_city, store_state, store_country, store_phone, store_email
FROM unique_stores;

INSERT INTO clickhouse.star_schema.dim_suppliers
WITH all_data AS (
    SELECT * FROM postgresql.public.mock_data
    UNION ALL
    SELECT * FROM clickhouse.default.mock_data
),
unique_suppliers AS (
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
    from_big_endian_64(xxhash64(to_utf8(concat(
        supplier_name, '|', supplier_email
    )))) AS supplier_sk,
    supplier_name, supplier_contact, supplier_email, supplier_phone, supplier_address, supplier_city, supplier_country
FROM unique_suppliers;

INSERT INTO clickhouse.star_schema.dim_dates
WITH all_data AS (
    SELECT * FROM postgresql.public.mock_data
    UNION ALL
    SELECT * FROM clickhouse.default.mock_data
),
parsed_dates AS (
    SELECT DISTINCT CAST(date_parse(sale_date, '%m/%d/%Y') AS DATE) AS full_date
    FROM all_data
    WHERE sale_date IS NOT NULL AND sale_date <> ''
)
SELECT
    CAST(date_format(full_date, '%Y%m%d') AS BIGINT) AS date_sk,
    full_date,
    year(full_date) AS year,
    month(full_date) AS month,
    day(full_date) AS day,
    quarter(full_date) AS quarter,
    day_of_week(full_date) AS day_of_week
FROM parsed_dates;

INSERT INTO clickhouse.star_schema.fact_sales
WITH all_data AS (
    SELECT 'pg' AS src, * FROM postgresql.public.mock_data
    UNION ALL
    SELECT 'ch' AS src, * FROM clickhouse.default.mock_data
)
SELECT
    from_big_endian_64(xxhash64(to_utf8(concat(
        src, '|', coalesce(CAST(id AS VARCHAR), ''), '|', coalesce(sale_date, ''), '|', coalesce(customer_email, ''), '|', coalesce(product_name, '')
    )))) AS sale_sk,
    from_big_endian_64(xxhash64(to_utf8(concat(
        coalesce(customer_email, ''), '|', coalesce(customer_first_name, ''), '|', coalesce(customer_last_name, '')
    )))) AS customer_sk,
    from_big_endian_64(xxhash64(to_utf8(concat(
        coalesce(seller_email, ''), '|', coalesce(seller_first_name, ''), '|', coalesce(seller_last_name, '')
    )))) AS seller_sk,
    from_big_endian_64(xxhash64(to_utf8(concat(
        coalesce(product_name, ''), '|', coalesce(product_brand, ''), '|', coalesce(CAST(product_price AS VARCHAR), '')
    )))) AS product_sk,
    from_big_endian_64(xxhash64(to_utf8(concat(
        coalesce(store_name, ''), '|', coalesce(store_city, ''), '|', coalesce(store_email, '')
    )))) AS store_sk,
    from_big_endian_64(xxhash64(to_utf8(concat(
        coalesce(supplier_name, ''), '|', coalesce(supplier_email, '')
    )))) AS supplier_sk,
    CAST(date_format(CAST(date_parse(sale_date, '%m/%d/%Y') AS DATE), '%Y%m%d') AS BIGINT) AS date_sk,
    COALESCE(sale_quantity, 0),
    COALESCE(sale_total_price, DECIMAL '0.00'),
    COALESCE(product_price, DECIMAL '0.00') AS unit_price
FROM all_data;
