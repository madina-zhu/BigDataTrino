-- Контрольные проверки результата ETL (ClickHouse). Колонка ok = 1, если факт совпал с ожиданием.
SELECT 'source mock_data (ClickHouse), ожидается 5000' AS check_name, toInt64(count()) AS actual, toInt64(5000) AS expected, toUInt8(actual = expected) AS ok FROM default.mock_data
UNION ALL SELECT 'fact_sales, ожидается 10000', toInt64(count()), toInt64(10000), toUInt8(toInt64(count()) = 10000) FROM star_schema.fact_sales
UNION ALL SELECT 'dim_customers = 10000', toInt64(count()), toInt64(10000), toUInt8(toInt64(count()) = 10000) FROM star_schema.dim_customers
UNION ALL SELECT 'dim_sellers = 10000', toInt64(count()), toInt64(10000), toUInt8(toInt64(count()) = 10000) FROM star_schema.dim_sellers
UNION ALL SELECT 'dim_products = 10000', toInt64(count()), toInt64(10000), toUInt8(toInt64(count()) = 10000) FROM star_schema.dim_products
UNION ALL SELECT 'dim_stores = 10000', toInt64(count()), toInt64(10000), toUInt8(toInt64(count()) = 10000) FROM star_schema.dim_stores
UNION ALL SELECT 'dim_suppliers = 10000', toInt64(count()), toInt64(10000), toUInt8(toInt64(count()) = 10000) FROM star_schema.dim_suppliers
UNION ALL SELECT 'dim_dates = 364 (уникальных дат продаж)', toInt64(count()), toInt64(364), toUInt8(toInt64(count()) = 364) FROM star_schema.dim_dates
UNION ALL SELECT 'суррогатные ключи dim_products уникальны', toInt64(count() - uniqExact(product_sk)), toInt64(0), toUInt8(toInt64(count() - uniqExact(product_sk)) = 0) FROM star_schema.dim_products
UNION ALL SELECT 'суррогатные ключи dim_customers уникальны', toInt64(count() - uniqExact(customer_sk)), toInt64(0), toUInt8(toInt64(count() - uniqExact(customer_sk)) = 0) FROM star_schema.dim_customers
UNION ALL SELECT 'sale_sk уникален', toInt64(count() - uniqExact(sale_sk)), toInt64(0), toUInt8(toInt64(count() - uniqExact(sale_sk)) = 0) FROM star_schema.fact_sales
UNION ALL SELECT 'факты без клиента в dim_customers', toInt64(count()), toInt64(0), toUInt8(toInt64(count()) = 0) FROM star_schema.fact_sales WHERE customer_sk NOT IN (SELECT customer_sk FROM star_schema.dim_customers)
UNION ALL SELECT 'факты без продавца в dim_sellers', toInt64(count()), toInt64(0), toUInt8(toInt64(count()) = 0) FROM star_schema.fact_sales WHERE seller_sk NOT IN (SELECT seller_sk FROM star_schema.dim_sellers)
UNION ALL SELECT 'факты без продукта в dim_products', toInt64(count()), toInt64(0), toUInt8(toInt64(count()) = 0) FROM star_schema.fact_sales WHERE product_sk NOT IN (SELECT product_sk FROM star_schema.dim_products)
UNION ALL SELECT 'факты без магазина в dim_stores', toInt64(count()), toInt64(0), toUInt8(toInt64(count()) = 0) FROM star_schema.fact_sales WHERE store_sk NOT IN (SELECT store_sk FROM star_schema.dim_stores)
UNION ALL SELECT 'факты без поставщика в dim_suppliers', toInt64(count()), toInt64(0), toUInt8(toInt64(count()) = 0) FROM star_schema.fact_sales WHERE supplier_sk NOT IN (SELECT supplier_sk FROM star_schema.dim_suppliers)
UNION ALL SELECT 'факты без даты в dim_dates', toInt64(count()), toInt64(0), toUInt8(toInt64(count()) = 0) FROM star_schema.fact_sales WHERE date_sk NOT IN (SELECT date_sk FROM star_schema.dim_dates)
UNION ALL SELECT 'выручка fact_sales (x100) = 252985212', toInt64(toInt64(sum(sale_total_price) * 100)), toInt64(252985212), toUInt8(toInt64(toInt64(sum(sale_total_price) * 100)) = 252985212) FROM star_schema.fact_sales
UNION ALL SELECT 'report_products = 10000 строк', toInt64(count()), toInt64(10000), toUInt8(toInt64(count()) = 10000) FROM reports.report_products
UNION ALL SELECT 'report_products: топ-10', toInt64(count()), toInt64(10), toUInt8(toInt64(count()) = 10) FROM reports.report_products WHERE sales_rank <= 10
UNION ALL SELECT 'report_customers = 10000 строк', toInt64(count()), toInt64(10000), toUInt8(toInt64(count()) = 10000) FROM reports.report_customers
UNION ALL SELECT 'report_customers: топ-10', toInt64(count()), toInt64(10), toUInt8(toInt64(count()) = 10) FROM reports.report_customers WHERE spent_rank <= 10
UNION ALL SELECT 'report_time = 12 месяцев', toInt64(count()), toInt64(12), toUInt8(toInt64(count()) = 12) FROM reports.report_time
UNION ALL SELECT 'report_stores = 10000 строк', toInt64(count()), toInt64(10000), toUInt8(toInt64(count()) = 10000) FROM reports.report_stores
UNION ALL SELECT 'report_stores: топ-5', toInt64(count()), toInt64(5), toUInt8(toInt64(count()) = 5) FROM reports.report_stores WHERE revenue_rank <= 5
UNION ALL SELECT 'report_suppliers = 10000 строк', toInt64(count()), toInt64(10000), toUInt8(toInt64(count()) = 10000) FROM reports.report_suppliers
UNION ALL SELECT 'report_suppliers: топ-5', toInt64(count()), toInt64(5), toUInt8(toInt64(count()) = 5) FROM reports.report_suppliers WHERE revenue_rank <= 5
UNION ALL SELECT 'report_product_quality = 10000 строк', toInt64(count()), toInt64(10000), toUInt8(toInt64(count()) = 10000) FROM reports.report_product_quality
UNION ALL SELECT 'выручка report_time (x100) = выручке фактов', toInt64(toInt64(sum(monthly_revenue) * 100)), toInt64(252985212), toUInt8(toInt64(toInt64(sum(monthly_revenue) * 100)) = 252985212) FROM reports.report_time;
