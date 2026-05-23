from pyspark.sql import SparkSession
from pyspark.sql.functions import sum as _sum, avg, count

spark = SparkSession.builder \
    .appName("ETL_to_ClickHouse") \
    .config("spark.jars", "/opt/spark_jars/postgresql-42.7.3.jar,/opt/spark_jars/clickhouse-jdbc-0.6.0-patch3-all.jar") \
    .getOrCreate()

postgres_url = "jdbc:postgresql://postgres:5432/bigdata_lab"
postgres_props = {
    "user": "postgres",
    "password": "postgres",
    "driver": "org.postgresql.Driver"
}

clickhouse_url = "jdbc:clickhouse://clickhouse:8123/reports"
clickhouse_props = {
    "user": "default",
    "password": "",
    "driver": "com.clickhouse.jdbc.ClickHouseDriver"
}

fact = spark.read.jdbc(postgres_url, "dwh.fact_sales", properties=postgres_props)
dim_date = spark.read.jdbc(postgres_url, "dwh.dim_date", properties=postgres_props)
dim_customer = spark.read.jdbc(postgres_url, "dwh.dim_customers", properties=postgres_props)
dim_product = spark.read.jdbc(postgres_url, "dwh.dim_products", properties=postgres_props)
dim_store = spark.read.jdbc(postgres_url, "dwh.dim_stores", properties=postgres_props)
dim_supplier = spark.read.jdbc(postgres_url, "dwh.dim_suppliers", properties=postgres_props)

sales_products = fact.join(dim_product, "product_id") \
    .groupBy("product_id", "product_name", "product_category") \
    .agg(
        _sum("sale_total_price").alias("total_revenue"),
        _sum("sale_quantity").alias("total_quantity"),
        avg("product_rating").alias("avg_rating"),
        avg("product_reviews").alias("total_reviews")
    )

sales_customers = fact.join(dim_customer, "customer_id") \
    .groupBy("customer_id", "customer_first_name", "customer_last_name", "customer_country") \
    .agg(
        _sum("sale_total_price").alias("total_spent"),
        avg("sale_total_price").alias("avg_check")
    )

sales_time = fact.join(dim_date, "date_id") \
    .groupBy("year_num", "month_num") \
    .agg(
        _sum("sale_total_price").alias("total_revenue"),
        count("sale_id").alias("total_orders"),
        avg("sale_total_price").alias("avg_order_value")
    )

sales_stores = fact.join(dim_store, "store_id") \
    .groupBy("store_id", "store_name", "store_city", "store_country") \
    .agg(
        _sum("sale_total_price").alias("total_revenue"),
        avg("sale_total_price").alias("avg_check")
    )

sales_suppliers = fact.join(dim_supplier, "supplier_id") \
    .groupBy("supplier_id", "supplier_name", "supplier_country") \
    .agg(
        _sum("sale_total_price").alias("total_revenue"),
        _sum("sale_quantity").alias("total_quantity_sold")
    )

product_quality = fact.join(dim_product, "product_id") \
    .groupBy("product_id", "product_name") \
    .agg(
        avg("product_rating").alias("avg_rating"),
        avg("product_reviews").alias("total_reviews"),
        _sum("sale_quantity").alias("total_quantity_sold"),
        _sum("sale_total_price").alias("total_revenue")
    )

sales_products.write.jdbc(clickhouse_url, "sales_products", mode="append", properties=clickhouse_props)
sales_customers.write.jdbc(clickhouse_url, "sales_customers", mode="append", properties=clickhouse_props)
sales_time.write.jdbc(clickhouse_url, "sales_time", mode="append", properties=clickhouse_props)
sales_stores.write.jdbc(clickhouse_url, "sales_stores", mode="append", properties=clickhouse_props)
sales_suppliers.write.jdbc(clickhouse_url, "sales_suppliers", mode="append", properties=clickhouse_props)
product_quality.write.jdbc(clickhouse_url, "product_quality", mode="append", properties=clickhouse_props)

spark.stop()