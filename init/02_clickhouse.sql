CREATE DATABASE IF NOT EXISTS reports;

CREATE TABLE IF NOT EXISTS reports.sales_products
(
    product_id Int64,
    product_name String,
    product_category String,
    total_revenue Float64,
    total_quantity Int64,
    avg_rating Float64,
    total_reviews Float64
)
ENGINE = MergeTree()
ORDER BY product_id;

CREATE TABLE IF NOT EXISTS reports.sales_customers
(
    customer_id Int64,
    customer_first_name String,
    customer_last_name String,
    customer_country String,
    total_spent Float64,
    avg_check Float64
)
ENGINE = MergeTree()
ORDER BY customer_id;

CREATE TABLE IF NOT EXISTS reports.sales_time
(
    year_num Int32,
    month_num Int32,
    total_revenue Float64,
    total_orders Int64,
    avg_order_value Float64
)
ENGINE = MergeTree()
ORDER BY (year_num, month_num);

CREATE TABLE IF NOT EXISTS reports.sales_stores
(
    store_id Int64,
    store_name String,
    store_city String,
    store_country String,
    total_revenue Float64,
    avg_check Float64
)
ENGINE = MergeTree()
ORDER BY store_id;

CREATE TABLE IF NOT EXISTS reports.sales_suppliers
(
    supplier_id Int64,
    supplier_name String,
    supplier_country String,
    total_revenue Float64,
    total_quantity_sold Int64
)
ENGINE = MergeTree()
ORDER BY supplier_id;

CREATE TABLE IF NOT EXISTS reports.product_quality
(
    product_id Int64,
    product_name String,
    avg_rating Float64,
    total_reviews Float64,
    total_quantity_sold Int64,
    total_revenue Float64
)
ENGINE = MergeTree()
ORDER BY product_id;
