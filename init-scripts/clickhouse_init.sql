SET input_format_csv_empty_as_default = 1;

CREATE DATABASE IF NOT EXISTS star_schema;
CREATE DATABASE IF NOT EXISTS reports;

CREATE TABLE IF NOT EXISTS default.mock_data (
    id Int32,
    customer_first_name String,
    customer_last_name String,
    customer_age Int32,
    customer_email String,
    customer_country String,
    customer_postal_code String,
    customer_pet_type String,
    customer_pet_name String,
    customer_pet_breed String,
    seller_first_name String,
    seller_last_name String,
    seller_email String,
    seller_country String,
    seller_postal_code String,
    product_name String,
    product_category String,
    product_price Decimal(10, 2),
    product_quantity Int32,
    sale_date String,
    sale_customer_id Int32,
    sale_seller_id Int32,
    sale_product_id Int32,
    sale_quantity Int32,
    sale_total_price Decimal(10, 2),
    store_name String,
    store_location String,
    store_city String,
    store_state String,
    store_country String,
    store_phone String,
    store_email String,
    pet_category String,
    product_weight Decimal(10, 2),
    product_color String,
    product_size String,
    product_brand String,
    product_material String,
    product_description String,
    product_rating Decimal(3, 2),
    product_reviews Int32,
    product_release_date String,
    product_expiry_date String,
    supplier_name String,
    supplier_contact String,
    supplier_email String,
    supplier_phone String,
    supplier_address String,
    supplier_city String,
    supplier_country String
) ENGINE = MergeTree()
ORDER BY id;

-- Импорт первых 5 файлов из user_files/data (структура задана явно - без вывода типов по данным)
SET input_format_csv_empty_as_default = 1;
INSERT INTO default.mock_data SELECT * FROM file('data/MOCK_DATA.csv', 'CSVWithNames', 'id Int32, customer_first_name String, customer_last_name String, customer_age Int32, customer_email String, customer_country String, customer_postal_code String, customer_pet_type String, customer_pet_name String, customer_pet_breed String, seller_first_name String, seller_last_name String, seller_email String, seller_country String, seller_postal_code String, product_name String, product_category String, product_price Decimal(10, 2), product_quantity Int32, sale_date String, sale_customer_id Int32, sale_seller_id Int32, sale_product_id Int32, sale_quantity Int32, sale_total_price Decimal(10, 2), store_name String, store_location String, store_city String, store_state String, store_country String, store_phone String, store_email String, pet_category String, product_weight Decimal(10, 2), product_color String, product_size String, product_brand String, product_material String, product_description String, product_rating Decimal(3, 2), product_reviews Int32, product_release_date String, product_expiry_date String, supplier_name String, supplier_contact String, supplier_email String, supplier_phone String, supplier_address String, supplier_city String, supplier_country String');
INSERT INTO default.mock_data SELECT * FROM file('data/MOCK_DATA (1).csv', 'CSVWithNames', 'id Int32, customer_first_name String, customer_last_name String, customer_age Int32, customer_email String, customer_country String, customer_postal_code String, customer_pet_type String, customer_pet_name String, customer_pet_breed String, seller_first_name String, seller_last_name String, seller_email String, seller_country String, seller_postal_code String, product_name String, product_category String, product_price Decimal(10, 2), product_quantity Int32, sale_date String, sale_customer_id Int32, sale_seller_id Int32, sale_product_id Int32, sale_quantity Int32, sale_total_price Decimal(10, 2), store_name String, store_location String, store_city String, store_state String, store_country String, store_phone String, store_email String, pet_category String, product_weight Decimal(10, 2), product_color String, product_size String, product_brand String, product_material String, product_description String, product_rating Decimal(3, 2), product_reviews Int32, product_release_date String, product_expiry_date String, supplier_name String, supplier_contact String, supplier_email String, supplier_phone String, supplier_address String, supplier_city String, supplier_country String');
INSERT INTO default.mock_data SELECT * FROM file('data/MOCK_DATA (2).csv', 'CSVWithNames', 'id Int32, customer_first_name String, customer_last_name String, customer_age Int32, customer_email String, customer_country String, customer_postal_code String, customer_pet_type String, customer_pet_name String, customer_pet_breed String, seller_first_name String, seller_last_name String, seller_email String, seller_country String, seller_postal_code String, product_name String, product_category String, product_price Decimal(10, 2), product_quantity Int32, sale_date String, sale_customer_id Int32, sale_seller_id Int32, sale_product_id Int32, sale_quantity Int32, sale_total_price Decimal(10, 2), store_name String, store_location String, store_city String, store_state String, store_country String, store_phone String, store_email String, pet_category String, product_weight Decimal(10, 2), product_color String, product_size String, product_brand String, product_material String, product_description String, product_rating Decimal(3, 2), product_reviews Int32, product_release_date String, product_expiry_date String, supplier_name String, supplier_contact String, supplier_email String, supplier_phone String, supplier_address String, supplier_city String, supplier_country String');
INSERT INTO default.mock_data SELECT * FROM file('data/MOCK_DATA (3).csv', 'CSVWithNames', 'id Int32, customer_first_name String, customer_last_name String, customer_age Int32, customer_email String, customer_country String, customer_postal_code String, customer_pet_type String, customer_pet_name String, customer_pet_breed String, seller_first_name String, seller_last_name String, seller_email String, seller_country String, seller_postal_code String, product_name String, product_category String, product_price Decimal(10, 2), product_quantity Int32, sale_date String, sale_customer_id Int32, sale_seller_id Int32, sale_product_id Int32, sale_quantity Int32, sale_total_price Decimal(10, 2), store_name String, store_location String, store_city String, store_state String, store_country String, store_phone String, store_email String, pet_category String, product_weight Decimal(10, 2), product_color String, product_size String, product_brand String, product_material String, product_description String, product_rating Decimal(3, 2), product_reviews Int32, product_release_date String, product_expiry_date String, supplier_name String, supplier_contact String, supplier_email String, supplier_phone String, supplier_address String, supplier_city String, supplier_country String');
INSERT INTO default.mock_data SELECT * FROM file('data/MOCK_DATA (4).csv', 'CSVWithNames', 'id Int32, customer_first_name String, customer_last_name String, customer_age Int32, customer_email String, customer_country String, customer_postal_code String, customer_pet_type String, customer_pet_name String, customer_pet_breed String, seller_first_name String, seller_last_name String, seller_email String, seller_country String, seller_postal_code String, product_name String, product_category String, product_price Decimal(10, 2), product_quantity Int32, sale_date String, sale_customer_id Int32, sale_seller_id Int32, sale_product_id Int32, sale_quantity Int32, sale_total_price Decimal(10, 2), store_name String, store_location String, store_city String, store_state String, store_country String, store_phone String, store_email String, pet_category String, product_weight Decimal(10, 2), product_color String, product_size String, product_brand String, product_material String, product_description String, product_rating Decimal(3, 2), product_reviews Int32, product_release_date String, product_expiry_date String, supplier_name String, supplier_contact String, supplier_email String, supplier_phone String, supplier_address String, supplier_city String, supplier_country String');

-- 1. Измерение: Клиенты
CREATE TABLE IF NOT EXISTS star_schema.dim_customers (
    customer_sk Int64,
    first_name String,
    last_name String,
    age Int32,
    email String,
    country String,
    postal_code String,
    pet_type String,
    pet_name String,
    pet_breed String
) ENGINE = MergeTree() ORDER BY customer_sk;

-- 2. Измерение: Продавцы
CREATE TABLE IF NOT EXISTS star_schema.dim_sellers (
    seller_sk Int64,
    first_name String,
    last_name String,
    email String,
    country String,
    postal_code String
) ENGINE = MergeTree() ORDER BY seller_sk;

-- 3. Измерение: Продукты
CREATE TABLE IF NOT EXISTS star_schema.dim_products (
    product_sk Int64,
    product_name String,
    category String,
    pet_category String,
    price Decimal(10, 2),
    weight Decimal(10, 2),
    color String,
    size String,
    brand String,
    material String,
    description String,
    rating Decimal(3, 2),
    reviews Int32,
    release_date String,
    expiry_date String
) ENGINE = MergeTree() ORDER BY product_sk;

-- 4. Измерение: Магазины
CREATE TABLE IF NOT EXISTS star_schema.dim_stores (
    store_sk Int64,
    store_name String,
    location String,
    city String,
    state String,
    country String,
    phone String,
    email String
) ENGINE = MergeTree() ORDER BY store_sk;

-- 5. Измерение: Поставщики
CREATE TABLE IF NOT EXISTS star_schema.dim_suppliers (
    supplier_sk Int64,
    supplier_name String,
    contact String,
    email String,
    phone String,
    address String,
    city String,
    country String
) ENGINE = MergeTree() ORDER BY supplier_sk;

-- 6. Измерение: Время
CREATE TABLE IF NOT EXISTS star_schema.dim_dates (
    date_sk Int64,
    full_date Date,
    year Int32,
    month Int32,
    day Int32,
    quarter Int32,
    day_of_week Int32
) ENGINE = MergeTree() ORDER BY date_sk;

-- 7. Таблица фактов: Продажи
CREATE TABLE IF NOT EXISTS star_schema.fact_sales (
    sale_sk Int64,
    customer_sk Int64,
    seller_sk Int64,
    product_sk Int64,
    store_sk Int64,
    supplier_sk Int64,
    date_sk Int64,
    sale_quantity Int32,
    sale_total_price Decimal(10, 2),
    unit_price Decimal(10, 2)
) ENGINE = MergeTree() ORDER BY (date_sk, sale_sk);

CREATE TABLE IF NOT EXISTS reports.report_products (
    product_sk Int64,
    product_name String,
    category String,
    total_quantity Int64,
    total_revenue Decimal(18, 2),
    category_total_revenue Decimal(18, 2),
    avg_rating Decimal(5, 2),
    total_reviews Int32,
    sales_rank Int64
) ENGINE = MergeTree() ORDER BY (sales_rank, product_sk);

CREATE TABLE IF NOT EXISTS reports.report_customers (
    customer_sk Int64,
    first_name String,
    last_name String,
    country String,
    total_spent Decimal(18, 2),
    orders_count Int64,
    avg_check Decimal(18, 2),
    customers_in_country Int64,
    spent_rank Int64
) ENGINE = MergeTree() ORDER BY (spent_rank, customer_sk);

CREATE TABLE IF NOT EXISTS reports.report_time (
    year Int32,
    month Int32,
    monthly_revenue Decimal(18, 2),
    yearly_revenue Decimal(18, 2),
    prev_month_revenue Nullable(Decimal(18, 2)),
    mom_growth_pct Nullable(Float64),
    orders_count Int64,
    avg_order_size Decimal(18, 2)
) ENGINE = MergeTree() ORDER BY (year, month);

CREATE TABLE IF NOT EXISTS reports.report_stores (
    store_sk Int64,
    store_name String,
    city String,
    country String,
    store_revenue Decimal(18, 2),
    orders_count Int64,
    avg_check Decimal(18, 2),
    city_revenue Decimal(18, 2),
    country_revenue Decimal(18, 2),
    revenue_rank Int64
) ENGINE = MergeTree() ORDER BY (revenue_rank, store_sk);

CREATE TABLE IF NOT EXISTS reports.report_suppliers (
    supplier_sk Int64,
    supplier_name String,
    country String,
    supplier_revenue Decimal(18, 2),
    avg_product_price Decimal(18, 2),
    country_revenue Decimal(18, 2),
    revenue_rank Int64
) ENGINE = MergeTree() ORDER BY (revenue_rank, supplier_sk);

CREATE TABLE IF NOT EXISTS reports.report_product_quality (
    product_sk Int64,
    product_name String,
    category String,
    avg_rating Decimal(5, 2),
    total_reviews Int32,
    total_quantity_sold Int64,
    rating_volume_correlation Float64,
    highest_rating_rank Int64,
    lowest_rating_rank Int64,
    most_reviewed_rank Int64
) ENGINE = MergeTree() ORDER BY (highest_rating_rank, product_sk);
