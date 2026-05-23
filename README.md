# BigDataSpark

Что необходимо сделать? 

Необходимо реализовать ETL-пайплайн с помощью Spark, который трансформирует данные из источника (файлы mock_data.csv с номерами) в модель данных звезда в PostgreSQL, а затем на основе модели данных звезда создать ряд отчетов по данным в одной из NoSQL базах данных обязательно и в нескольких других опционально (будет бонусом). Каждый отчет представляет собой отдельную таблицу в NoSQL БД.

### Запуск

```cmd
docker-compose up -d
```

### Подготовка данных и составление отчётов

```cmd
docker exec -i bigdata_spark /opt/spark/bin/spark-submit --master local[*] --jars /opt/spark_jars/postgresql-42.7.3.jar /opt/spark_jobs/etl_to_dwh.py

docker exec -i bigdata_spark /opt/spark/bin/spark-submit --master local[*] --jars /opt/spark_jars/postgresql-42.7.3.jar,/opt/spark_jars/clickhouse-jdbc-0.6.0-patch3-all.jar /opt/spark_jobs/etl_to_clickhouse.py
```

### Какие отчеты надо создать?
1. Витрина продаж по продуктам
Цель: Анализ выручки, количества продаж и популярности продуктов.
 - Топ-10 самых продаваемых продуктов.
 ```sql
docker exec -i bigdata_clickhouse clickhouse-client -q "SELECT product_name, product_category, total_quantity FROM reports.sales_products ORDER BY total_quantity DESC LIMIT 10;"
 ```
 - Общая выручка по категориям продуктов.
```sql
docker exec -i bigdata_clickhouse clickhouse-client -q "SELECT product_category, total_revenue FROM reports.sales_products ORDER BY total_revenue DESC;"

docker exec -i bigdata_clickhouse clickhouse-client -q "SELECT product_category, SUM(total_revenue) as total_revenue FROM reports.sales_products GROUP BY product_category ORDER BY total_revenue DESC;"
```
 - Средний рейтинг и количество отзывов для каждого продукта.
 ```sql
 docker exec -i bigdata_clickhouse clickhouse-client -q "SELECT product_name, avg_rating, total_reviews FROM reports.sales_products LIMIT 10;"
 ```

2. Витрина продаж по клиентам
Цель: Анализ покупательского поведения и сегментация клиентов.
 - Топ-10 клиентов с наибольшей общей суммой покупок.
 ```sql
docker exec -i bigdata_clickhouse clickhouse-client -q "SELECT customer_first_name, customer_last_name, total_spent FROM reports.sales_customers ORDER BY total_spent DESC LIMIT 10;"
 ```
 - Распределение клиентов по странам.
 ```sql
docker exec -i bigdata_clickhouse clickhouse-client -q "SELECT customer_country, COUNT(*) as customers, SUM(total_spent) as total_revenue FROM reports.sales_customers GROUP BY customer_country ORDER BY total_revenue DESC;"
 ```
 - Средний чек для каждого клиента.
 ```sql
docker exec -i bigdata_clickhouse clickhouse-client -q "SELECT customer_first_name, customer_last_name, avg_check FROM reports.sales_customers LIMIT 10;"
 ```

3. Витрина продаж по времени
Цель: Анализ сезонности и трендов продаж.
 - Месячные и годовые тренды продаж.
 ```sql
docker exec -i bigdata_clickhouse clickhouse-client -q "SELECT year_num, month_num, total_revenue, total_orders FROM reports.sales_time ORDER BY year_num, month_num;"
 ```
 - Сравнение выручки за разные периоды.
 ```sql
docker exec -i bigdata_clickhouse clickhouse-client -q "SELECT year_num, SUM(total_revenue) as year_revenue FROM reports.sales_time GROUP BY year_num ORDER BY year_num;"
 ```
 - Средний размер заказа по месяцам.
 ```sql
docker exec -i bigdata_clickhouse clickhouse-client -q "SELECT year_num, month_num, avg_order_value FROM reports.sales_time ORDER BY year_num, month_num;"
 ```

4. Витрина продаж по магазинам
Цель: Анализ эффективности магазинов.
 - Топ-5 магазинов с наибольшей выручкой.
 ```sql
docker exec -i bigdata_clickhouse clickhouse-client -q "SELECT store_name, total_revenue FROM reports.sales_stores ORDER BY total_revenue DESC LIMIT 5;"
 ```
 - Распределение продаж по городам и странам.
 ```sql
docker exec -i bigdata_clickhouse clickhouse-client -q "SELECT store_country, store_city, SUM(total_revenue) as city_revenue FROM reports.sales_stores GROUP BY store_country, store_city ORDER BY city_revenue DESC LIMIT 20;"
 ```
 - Средний чек для каждого магазина.
 ```sql
docker exec -i bigdata_clickhouse clickhouse-client -q "SELECT store_name, avg_check FROM reports.sales_stores ORDER BY avg_check DESC LIMIT 10;"
 ```

5. Витрина продаж по поставщикам
Цель: Анализ эффективности поставщиков.
 - Топ-5 поставщиков с наибольшей выручкой.
 ```sql
docker exec -i bigdata_clickhouse clickhouse-client -q "SELECT supplier_name, total_revenue FROM reports.sales_suppliers ORDER BY total_revenue DESC LIMIT 5;"
 ```
 - Средняя цена товаров от каждого поставщика.
 ```sql
docker exec -i bigdata_clickhouse clickhouse-client -q "SELECT supplier_name, total_revenue / total_quantity_sold as avg_price FROM reports.sales_suppliers ORDER BY avg_price DESC LIMIT 10;"
 ```
 - Распределение продаж по странам поставщиков.
```sql
docker exec -i bigdata_clickhouse clickhouse-client -q "SELECT supplier_country, COUNT(*) as suppliers, SUM(total_revenue) as total_revenue FROM reports.sales_suppliers GROUP BY supplier_country ORDER BY total_revenue DESC;"
```

6. Витрина качества продукции
Цель: Анализ отзывов и рейтингов товаров.
 - Продукты с наивысшим и наименьшим рейтингом.
 ```sql
docker exec -i bigdata_clickhouse clickhouse-client -q "SELECT product_name, avg_rating FROM reports.product_quality ORDER BY avg_rating DESC LIMIT 5;"

docker exec -i bigdata_clickhouse clickhouse-client -q "SELECT product_name, avg_rating FROM reports.product_quality ORDER BY avg_rating ASC LIMIT 5;"
 ```
 - Корреляция между рейтингом и объемом продаж.
 ```sql
docker exec -i bigdata_clickhouse clickhouse-client -q "SELECT avg_rating, total_quantity_sold, total_revenue FROM reports.product_quality ORDER BY avg_rating DESC;"
 ```
 - Продукты с наибольшим количеством отзывов.
 ```sql
docker exec -i bigdata_clickhouse clickhouse-client -q "SELECT product_name, total_reviews FROM reports.product_quality ORDER BY total_reviews DESC LIMIT 10;"
 ```
---------------

Все запросы есть в файле `./init/03_view.sql`, и их можно копировать оттуда в DBeaver.

---------------

В каких NoSQL БД должны быть эти отчеты:
1. **Clickhouse** **(обязательно)**

Алгоритм:

1. Клонируете к себе этот репозиторий.
2. Устанавливаете себе инструмент для работы с запросами SQL (рекомендую DBeaver).
3. Устанавливаете базу данных PostgreSQL (рекомендую установку через docker).
4. Устанавливаете Apache Spark (рекомендую установку через Docker. Для удобства написания кода на Python можно запустить вместе со JupyterNotebook. Для Java - подключить volume и собрать образ Docker, который будет запускать команду spark-submit с java jar-файлом при старте контейнера, сам jar файл собирается отдельно и кладется в подключенный volume)
5. Скачиваете файлы с исходными данными mock_data( * ).csv, где ( * ) номера файлов. Всего 10 файлов, каждый по 1000 строк.
6. Импортируете данные в БД PostgreSQL (например, через механизм импорта csv в DBeaver). Всего в таблице mock_data должно находиться 10000 строк из 10 файлов.
7. Анализируете исходные данные с помощью запросов.
8. Выявляете сущности фактов и измерений.
9. Реализуете приложение на Spark, которое по аналогии с первой лабораторной работой перекладывает исходные данные из PostgreSQL в модель снежинку/звезда в PostgreSQL. (Убедитесь в коннективности Spark и PostgreSQL, настройте сеть между Spark и PostgreSQL, если используете Docker).
10. Устанавливаете ClickHouse (рекомендую установку через Docker. Убедитесь в коннективности Spark и Clickhouse, настройте сеть между Spark и ClickHouse). **(обязательно)**
11. Реализуете приложение на Spark, которое создаёт все 6 перечисленных выше отчетов в виде 6 отдельных таблиц в ClickHouse. **(обязательно)**
12. Проверяете отчеты в каждой базе данных средствами языка самой БД (ClickHouse - SQL (DBeaver)).
13. Отправляете работу на проверку лаборантам.

Что должно быть результатом работы?

1. Репозиторий, в котором есть исходные данные mock_data().csv, где () номера файлов. Всего 10 файлов, каждый по 1000 строк.
2. Файл docker-compose.yml с установкой PostgreSQL, Spark, ClickHouse **(обязательно)** и заполненными данными в PostgreSQL из файлов mock_data(*).csv.
3. Инструкция, как запускать Spark-джобы для проверки лабораторной работы.
4. Код Apache Spark трансформации данных из исходной модели в снежинку/звезду в PostgreSQL.
5. Код Apache Spark трансформации данных из снежинки/звезды в отчеты в ClickHouse.