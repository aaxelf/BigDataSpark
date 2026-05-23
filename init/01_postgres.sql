CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS dwh;

DROP TABLE IF EXISTS staging.mock_data CASCADE;

CREATE TABLE staging.mock_data (
    id BIGINT,
    customer_first_name TEXT,
    customer_last_name TEXT,
    customer_age INTEGER,
    customer_email TEXT,
    customer_country TEXT,
    customer_postal_code TEXT,
    customer_pet_type TEXT,
    customer_pet_name TEXT,
    customer_pet_breed TEXT,
    seller_first_name TEXT,
    seller_last_name TEXT,
    seller_email TEXT,
    seller_country TEXT,
    seller_postal_code TEXT,
    product_name TEXT,
    product_category TEXT,
    product_price DECIMAL(10,2),
    product_quantity INTEGER,
    sale_date DATE,
    sale_customer_id BIGINT,
    sale_seller_id BIGINT,
    sale_product_id BIGINT,
    sale_quantity INTEGER,
    sale_total_price DECIMAL(10,2),
    store_name TEXT,
    store_location TEXT,
    store_city TEXT,
    store_state TEXT,
    store_country TEXT,
    store_phone TEXT,
    store_email TEXT,
    pet_category TEXT,
    product_weight DECIMAL(10,2),
    product_color TEXT,
    product_size TEXT,
    product_brand TEXT,
    product_material TEXT,
    product_description TEXT,
    product_rating DECIMAL(3,2),
    product_reviews INTEGER,
    product_release_date DATE,
    product_expiry_date DATE,
    supplier_name TEXT,
    supplier_contact TEXT,
    supplier_email TEXT,
    supplier_phone TEXT,
    supplier_address TEXT,
    supplier_city TEXT,
    supplier_country TEXT
);

DROP TABLE IF EXISTS dwh.dim_customers CASCADE;
DROP TABLE IF EXISTS dwh.dim_pets CASCADE;
DROP TABLE IF EXISTS dwh.dim_sellers CASCADE;
DROP TABLE IF EXISTS dwh.dim_products CASCADE;
DROP TABLE IF EXISTS dwh.dim_stores CASCADE;
DROP TABLE IF EXISTS dwh.dim_suppliers CASCADE;
DROP TABLE IF EXISTS dwh.fact_sales CASCADE;
DROP TABLE IF EXISTS dwh.dim_date CASCADE;

-- добавлена дата для отчёта по времени
CREATE TABLE dwh.dim_date (
    date_id BIGINT PRIMARY KEY,
    full_date DATE,
    day_num INTEGER,
    month_num INTEGER,
    year_num INTEGER
);

CREATE TABLE dwh.dim_customers (
    customer_id BIGINT PRIMARY KEY,
    customer_first_name VARCHAR,
    customer_last_name VARCHAR,
    customer_age INTEGER,
    customer_email VARCHAR,
    customer_country VARCHAR,
    customer_postal_code VARCHAR
);

CREATE TABLE dwh.dim_suppliers (
    supplier_id BIGINT PRIMARY KEY,
    supplier_name VARCHAR,
    supplier_contact VARCHAR,
    supplier_email VARCHAR,
    supplier_phone VARCHAR,
    supplier_address VARCHAR,
    supplier_city VARCHAR,
    supplier_country VARCHAR
);

CREATE TABLE dwh.dim_stores (
    store_id BIGINT PRIMARY KEY,
    store_name VARCHAR,
    store_location VARCHAR,
    store_city VARCHAR,
    store_state VARCHAR,
    store_country VARCHAR,
    store_phone VARCHAR,
    store_email VARCHAR
);

CREATE TABLE dwh.dim_sellers (
    seller_id BIGINT PRIMARY KEY,
    seller_first_name VARCHAR,
    seller_last_name VARCHAR,
    seller_email VARCHAR,
    seller_country VARCHAR,
    seller_postal_code VARCHAR
);

CREATE TABLE dwh.dim_products (
    product_id BIGINT PRIMARY KEY,
    product_name VARCHAR,
    product_category VARCHAR,
    product_price DECIMAL(10,2),
    product_brand VARCHAR,
    product_rating DECIMAL(10,2),
    product_reviews INTEGER
);

CREATE TABLE dwh.dim_pets (
    customer_id BIGINT PRIMARY KEY,
    pet_name VARCHAR,
    pet_type VARCHAR,
    pet_breed VARCHAR,
    pet_category VARCHAR
);

CREATE TABLE dwh.fact_sales (
    sale_id BIGINT PRIMARY KEY,
    date_id BIGINT,
    customer_id BIGINT,
    seller_id BIGINT,
    product_id BIGINT,
    supplier_id BIGINT,
    store_id BIGINT,
    quantity INTEGER,
    total_price DECIMAL(10,2)
);