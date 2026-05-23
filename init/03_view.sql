-- 1. Витрина продаж по продуктам
-- Топ-10 самых продаваемых продуктов
SELECT 
    product_name, 
    product_category, 
    total_quantity 
FROM reports.sales_products 
ORDER BY total_quantity DESC 
LIMIT 10;

-- Общая выручка по категориям продуктов
SELECT 
    product_category, 
    SUM(total_revenue) as total_revenue 
FROM reports.sales_products 
GROUP BY product_category 
ORDER BY total_revenue DESC;

-- Средний рейтинг и количество отзывов для каждого продукта
SELECT 
    product_name, 
    avg_rating, 
    total_reviews 
FROM reports.sales_products 
LIMIT 10;

-- 2. Витрина продаж по клиентам
-- Топ-10 клиентов с наибольшей общей суммой покупок
SELECT 
    customer_first_name, 
    customer_last_name, 
    total_spent 
FROM reports.sales_customers 
ORDER BY total_spent DESC 
LIMIT 10;

-- Распределение клиентов по странам
SELECT 
    customer_country, 
    COUNT(*) as customers, 
    SUM(total_spent) as total_revenue 
FROM reports.sales_customers 
GROUP BY customer_country 
ORDER BY total_revenue DESC;

-- Средний чек для каждого клиента
SELECT 
    customer_first_name, 
    customer_last_name, 
    avg_check 
FROM reports.sales_customers 
LIMIT 10;

-- 3. Витрина продаж по времени
-- Месячные и годовые тренды продаж
SELECT 
    year_num, 
    month_num, 
    total_revenue, 
    total_orders 
FROM reports.sales_time 
ORDER BY year_num, month_num;

-- Сравнение выручки за разные периоды
SELECT 
    year_num, 
    SUM(total_revenue) as year_revenue 
FROM reports.sales_time 
GROUP BY year_num 
ORDER BY year_num;

-- Средний размер заказа по месяцам
SELECT 
    year_num, 
    month_num, 
    avg_order_value 
FROM reports.sales_time 
ORDER BY year_num, month_num;

-- 4. Витрина продаж по магазинам
-- Топ-5 магазинов с наибольшей выручкой
SELECT 
    store_name, 
    total_revenue 
FROM reports.sales_stores 
ORDER BY total_revenue DESC 
LIMIT 5;

-- Распределение продаж по городам и странам
SELECT 
    store_country, 
    store_city, 
    SUM(total_revenue) as city_revenue 
FROM reports.sales_stores 
GROUP BY store_country, store_city 
ORDER BY city_revenue DESC 
LIMIT 20;

-- Средний чек для каждого магазина
SELECT 
    store_name, 
    avg_check 
FROM reports.sales_stores 
ORDER BY avg_check DESC 
LIMIT 10;

-- 5. Витрина продаж по поставщикам
-- Топ-5 поставщиков с наибольшей выручкой
SELECT 
    supplier_name, 
    total_revenue 
FROM reports.sales_suppliers 
ORDER BY total_revenue DESC 
LIMIT 5;

-- Средняя цена товаров от каждого поставщика
SELECT 
    supplier_name, 
    total_revenue / total_quantity_sold as avg_price 
FROM reports.sales_suppliers 
ORDER BY avg_price DESC 
LIMIT 10;

-- Распределение продаж по странам поставщиков
SELECT 
    supplier_country, 
    COUNT(*) as suppliers, 
    SUM(total_revenue) as total_revenue 
FROM reports.sales_suppliers 
GROUP BY supplier_country 
ORDER BY total_revenue DESC;

-- 6. Витрина качества продуктов
-- Продукты с наивысшим и наименьшим рейтингом
SELECT 
    product_name, 
    avg_rating 
FROM reports.product_quality 
ORDER BY avg_rating DESC 
LIMIT 5;

SELECT 
    product_name, 
    avg_rating 
FROM reports.product_quality 
ORDER BY avg_rating ASC 
LIMIT 5;

-- Корреляция между рейтингом и объемом продаж
SELECT 
    product_name,
    avg_rating, 
    total_quantity_sold, 
    total_revenue 
FROM reports.product_quality 
ORDER BY avg_rating DESC;

-- Продукты с наибольшим количеством отзывов
SELECT 
    product_name, 
    total_reviews 
FROM reports.product_quality 
ORDER BY total_reviews DESC 
LIMIT 10;