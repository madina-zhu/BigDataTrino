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
    total_quantity,
    total_revenue,
    SUM(total_revenue) OVER (PARTITION BY category) AS category_total_revenue,
    CAST(avg_rating AS DECIMAL(5, 2)) AS avg_rating,
    total_reviews,
    RANK() OVER (ORDER BY total_quantity DESC) AS sales_rank
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
    total_spent,
    orders_count,
    CAST(avg_check AS DECIMAL(18, 2)) AS avg_check,
    COUNT(customer_sk) OVER (PARTITION BY country) AS customers_in_country,
    RANK() OVER (ORDER BY total_spent DESC) AS spent_rank
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
)
SELECT
    year,
    month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (PARTITION BY year) AS yearly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY year, month) AS prev_month_revenue,
    ROUND(
        (CAST(monthly_revenue AS DOUBLE) - CAST(LAG(monthly_revenue) OVER (ORDER BY year, month) AS DOUBLE))
        / NULLIF(CAST(LAG(monthly_revenue) OVER (ORDER BY year, month) AS DOUBLE), 0) * 100, 2
    ) AS mom_growth_pct,
    orders_count,
    CAST(avg_order_size AS DECIMAL(18, 2)) AS avg_order_size
FROM time_agg;

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
    store_revenue,
    orders_count,
    CAST(avg_check AS DECIMAL(18, 2)) AS avg_check,
    SUM(store_revenue) OVER (PARTITION BY city, country) AS city_revenue,
    SUM(store_revenue) OVER (PARTITION BY country) AS country_revenue,
    RANK() OVER (ORDER BY store_revenue DESC) AS revenue_rank
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
    supplier_revenue,
    CAST(avg_product_price AS DECIMAL(18, 2)) AS avg_product_price,
    SUM(supplier_revenue) OVER (PARTITION BY country) AS country_revenue,
    RANK() OVER (ORDER BY supplier_revenue DESC) AS revenue_rank
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
    total_reviews,
    total_quantity_sold,
    COALESCE(CORR(CAST(avg_rating AS DOUBLE), CAST(total_quantity_sold AS DOUBLE)) OVER (), 0.0) AS rating_volume_correlation,
    RANK() OVER (ORDER BY avg_rating DESC) AS highest_rating_rank,
    RANK() OVER (ORDER BY avg_rating ASC) AS lowest_rating_rank,
    RANK() OVER (ORDER BY total_reviews DESC) AS most_reviewed_rank
FROM qual_agg;
