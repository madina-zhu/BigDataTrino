-- ============================================================================
-- ETL: модель «Звезда» (ClickHouse) -> 6 витрин отчётов (ClickHouse, БД reports)
-- Запуск: docker exec lab_trino trino --file /scripts/02_create_reports.sql
--
-- Все значения явно приводятся к типам колонок целевых таблиц (Trino не делает
-- сужающее приведение DECIMAL(38,2) -> DECIMAL(18,2) при INSERT).
-- Ранги «топ-N» считаются через ROW_NUMBER с детерминированным разрешением ничьих,
-- поэтому фильтр rank <= N всегда возвращает ровно N строк.
-- ============================================================================

-- 1. Витрина продаж по продуктам
INSERT INTO clickhouse.reports.report_products
WITH prod_agg AS (
    SELECT
        p.product_sk,
        p.product_name,
        p.category,
        SUM(f.sale_quantity) AS total_quantity,
        SUM(f.sale_total_price) AS total_revenue,
        AVG(p.rating) AS avg_rating,
        MAX(p.reviews) AS total_reviews
    FROM clickhouse.star_schema.fact_sales f
    JOIN clickhouse.star_schema.dim_products p ON f.product_sk = p.product_sk
    GROUP BY p.product_sk, p.product_name, p.category
)
SELECT
    product_sk,
    product_name,
    category,
    CAST(total_quantity AS BIGINT) AS total_quantity,
    CAST(total_revenue AS DECIMAL(18, 2)) AS total_revenue,
    CAST(SUM(total_revenue) OVER (PARTITION BY category) AS DECIMAL(18, 2)) AS category_total_revenue,
    CAST(avg_rating AS DECIMAL(5, 2)) AS avg_rating,
    CAST(total_reviews AS INTEGER) AS total_reviews,
    ROW_NUMBER() OVER (ORDER BY total_quantity DESC, total_revenue DESC, product_sk) AS sales_rank
FROM prod_agg;

-- 2. Витрина продаж по клиентам
INSERT INTO clickhouse.reports.report_customers
WITH cust_agg AS (
    SELECT
        c.customer_sk,
        c.first_name,
        c.last_name,
        c.country,
        SUM(f.sale_total_price) AS total_spent,
        COUNT(f.sale_sk) AS orders_count,
        AVG(f.sale_total_price) AS avg_check
    FROM clickhouse.star_schema.fact_sales f
    JOIN clickhouse.star_schema.dim_customers c ON f.customer_sk = c.customer_sk
    GROUP BY c.customer_sk, c.first_name, c.last_name, c.country
)
SELECT
    customer_sk,
    first_name,
    last_name,
    country,
    CAST(total_spent AS DECIMAL(18, 2)) AS total_spent,
    CAST(orders_count AS BIGINT) AS orders_count,
    CAST(avg_check AS DECIMAL(18, 2)) AS avg_check,
    CAST(COUNT(customer_sk) OVER (PARTITION BY country) AS BIGINT) AS customers_in_country,
    ROW_NUMBER() OVER (ORDER BY total_spent DESC, customer_sk) AS spent_rank
FROM cust_agg;

-- 3. Витрина продаж по времени
INSERT INTO clickhouse.reports.report_time
WITH time_agg AS (
    SELECT
        d.year,
        d.month,
        SUM(f.sale_total_price) AS monthly_revenue,
        COUNT(f.sale_sk) AS orders_count,
        AVG(f.sale_total_price) AS avg_order_size
    FROM clickhouse.star_schema.fact_sales f
    JOIN clickhouse.star_schema.dim_dates d ON f.date_sk = d.date_sk
    GROUP BY d.year, d.month
),
time_calc AS (
    SELECT
        year,
        month,
        monthly_revenue,
        SUM(monthly_revenue) OVER (PARTITION BY year) AS yearly_revenue,
        LAG(monthly_revenue) OVER (ORDER BY year, month) AS prev_month_revenue,
        orders_count,
        avg_order_size
    FROM time_agg
)
SELECT
    year,
    month,
    CAST(monthly_revenue AS DECIMAL(18, 2)) AS monthly_revenue,
    CAST(yearly_revenue AS DECIMAL(18, 2)) AS yearly_revenue,
    CAST(prev_month_revenue AS DECIMAL(18, 2)) AS prev_month_revenue,
    ROUND(
        (CAST(monthly_revenue AS DOUBLE) - CAST(prev_month_revenue AS DOUBLE))
        / NULLIF(CAST(prev_month_revenue AS DOUBLE), 0) * 100, 2
    ) AS mom_growth_pct,
    CAST(orders_count AS BIGINT) AS orders_count,
    CAST(avg_order_size AS DECIMAL(18, 2)) AS avg_order_size
FROM time_calc;

-- 4. Витрина продаж по магазинам
INSERT INTO clickhouse.reports.report_stores
WITH store_agg AS (
    SELECT
        s.store_sk,
        s.store_name,
        s.city,
        s.country,
        SUM(f.sale_total_price) AS store_revenue,
        COUNT(f.sale_sk) AS orders_count,
        AVG(f.sale_total_price) AS avg_check
    FROM clickhouse.star_schema.fact_sales f
    JOIN clickhouse.star_schema.dim_stores s ON f.store_sk = s.store_sk
    GROUP BY s.store_sk, s.store_name, s.city, s.country
)
SELECT
    store_sk,
    store_name,
    city,
    country,
    CAST(store_revenue AS DECIMAL(18, 2)) AS store_revenue,
    CAST(orders_count AS BIGINT) AS orders_count,
    CAST(avg_check AS DECIMAL(18, 2)) AS avg_check,
    CAST(SUM(store_revenue) OVER (PARTITION BY city, country) AS DECIMAL(18, 2)) AS city_revenue,
    CAST(SUM(store_revenue) OVER (PARTITION BY country) AS DECIMAL(18, 2)) AS country_revenue,
    ROW_NUMBER() OVER (ORDER BY store_revenue DESC, store_sk) AS revenue_rank
FROM store_agg;

-- 5. Витрина продаж по поставщикам
INSERT INTO clickhouse.reports.report_suppliers
WITH sup_agg AS (
    SELECT
        sup.supplier_sk,
        sup.supplier_name,
        sup.country,
        SUM(f.sale_total_price) AS supplier_revenue,
        AVG(f.unit_price) AS avg_product_price
    FROM clickhouse.star_schema.fact_sales f
    JOIN clickhouse.star_schema.dim_suppliers sup ON f.supplier_sk = sup.supplier_sk
    GROUP BY sup.supplier_sk, sup.supplier_name, sup.country
)
SELECT
    supplier_sk,
    supplier_name,
    country,
    CAST(supplier_revenue AS DECIMAL(18, 2)) AS supplier_revenue,
    CAST(avg_product_price AS DECIMAL(18, 2)) AS avg_product_price,
    CAST(SUM(supplier_revenue) OVER (PARTITION BY country) AS DECIMAL(18, 2)) AS country_revenue,
    ROW_NUMBER() OVER (ORDER BY supplier_revenue DESC, supplier_sk) AS revenue_rank
FROM sup_agg;

-- 6. Витрина качества продукции
INSERT INTO clickhouse.reports.report_product_quality
WITH qual_agg AS (
    SELECT
        p.product_sk,
        p.product_name,
        p.category,
        AVG(p.rating) AS avg_rating,
        MAX(p.reviews) AS total_reviews,
        SUM(f.sale_quantity) AS total_quantity_sold
    FROM clickhouse.star_schema.fact_sales f
    JOIN clickhouse.star_schema.dim_products p ON f.product_sk = p.product_sk
    GROUP BY p.product_sk, p.product_name, p.category
)
SELECT
    product_sk,
    product_name,
    category,
    CAST(avg_rating AS DECIMAL(5, 2)) AS avg_rating,
    CAST(total_reviews AS INTEGER) AS total_reviews,
    CAST(total_quantity_sold AS BIGINT) AS total_quantity_sold,
    COALESCE(CORR(CAST(avg_rating AS DOUBLE), CAST(total_quantity_sold AS DOUBLE)) OVER (), 0.0) AS rating_volume_correlation,
    ROW_NUMBER() OVER (ORDER BY avg_rating DESC, total_reviews DESC, product_sk) AS highest_rating_rank,
    ROW_NUMBER() OVER (ORDER BY avg_rating ASC, total_reviews DESC, product_sk) AS lowest_rating_rank,
    ROW_NUMBER() OVER (ORDER BY total_reviews DESC, avg_rating DESC, product_sk) AS most_reviewed_rank
FROM qual_agg;
