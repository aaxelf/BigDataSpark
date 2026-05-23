from pyspark.sql import SparkSession
from pyspark.sql.functions import col, dayofmonth, month, year, dense_rank, monotonically_increasing_id
from pyspark.sql.window import Window

spark = SparkSession.builder \
    .appName("ETL_to_DWH") \
    .config("spark.jars", "/opt/spark_jars/postgresql-42.7.3.jar") \
    .getOrCreate()

postgres_url = "jdbc:postgresql://bigdata_postgres:5432/bigdata_lab"
postgres_props = {
    "user": "postgres",
    "password": "postgres",
    "driver": "org.postgresql.Driver"
}

df = spark.read.jdbc(url=postgres_url, table="staging.mock_data", properties=postgres_props)

store_window = Window.orderBy(
    "store_name", "store_location", "store_city", "store_state", 
    "store_country", "store_phone", "store_email"
)

supplier_window = Window.orderBy(
    "supplier_name", "supplier_contact", "supplier_email", "supplier_phone",
    "supplier_address", "supplier_city", "supplier_country"
)

df = df.withColumn("store_id", dense_rank().over(store_window).cast("long"))
df = df.withColumn("supplier_id", dense_rank().over(supplier_window).cast("long"))
df = df.withColumn("date_id", col("sale_date").cast("timestamp").cast("long"))
df = df.withColumn("sale_id", monotonically_increasing_id())

dim_date = df.select("date_id", "sale_date").dropDuplicates(["date_id"]) \
    .withColumnRenamed("sale_date", "full_date") \
    .withColumn("day_num", dayofmonth(col("full_date"))) \
    .withColumn("month_num", month(col("full_date"))) \
    .withColumn("year_num", year(col("full_date"))) \
    .select("date_id", "full_date", "day_num", "month_num", "year_num")

dim_date.write.jdbc(postgres_url, "dwh.dim_date", mode="overwrite", properties=postgres_props)

dim_customers = df.select(
    col("sale_customer_id").alias("customer_id"),
    "customer_first_name",
    "customer_last_name",
    "customer_age",
    "customer_email",
    "customer_country",
    "customer_postal_code"
).dropDuplicates(["customer_id"])

dim_customers.write.jdbc(postgres_url, "dwh.dim_customers", mode="overwrite", properties=postgres_props)

dim_pets = df.select(
    col("sale_customer_id").alias("customer_id"),
    "customer_pet_type",
    "customer_pet_name",
    "customer_pet_breed",
    "pet_category"
).dropDuplicates(["customer_id"])

dim_pets.write.jdbc(postgres_url, "dwh.dim_pets", mode="overwrite", properties=postgres_props)

dim_sellers = df.select(
    col("sale_seller_id").alias("seller_id"),
    "seller_first_name",
    "seller_last_name",
    "seller_email",
    "seller_country",
    "seller_postal_code"
).dropDuplicates(["seller_id"])

dim_sellers.write.jdbc(postgres_url, "dwh.dim_sellers", mode="overwrite", properties=postgres_props)

dim_stores = df.select(
    "store_id",
    "store_name",
    "store_location",
    "store_city",
    "store_state",
    "store_country",
    "store_phone",
    "store_email"
).dropDuplicates(["store_id"])

dim_stores.write.jdbc(postgres_url, "dwh.dim_stores", mode="overwrite", properties=postgres_props)

dim_products = df.select(
    col("sale_product_id").alias("product_id"),
    "product_name",
    "product_category",
    "product_price",
    "product_brand",
    "product_rating",
    "product_reviews"
).dropDuplicates(["product_id"])

dim_products.write.jdbc(postgres_url, "dwh.dim_products", mode="overwrite", properties=postgres_props)

dim_suppliers = df.select(
    "supplier_id",
    "supplier_name",
    "supplier_contact",
    "supplier_email",
    "supplier_phone",
    "supplier_address",
    "supplier_city",
    "supplier_country"
).dropDuplicates(["supplier_id"])

dim_suppliers.write.jdbc(postgres_url, "dwh.dim_suppliers", mode="overwrite", properties=postgres_props)

fact_sales = df.select(
    "sale_id",
    "date_id",
    col("sale_customer_id").alias("customer_id"),
    col("sale_seller_id").alias("seller_id"),
    col("sale_product_id").alias("product_id"),
    "store_id",
    "supplier_id",
    "sale_quantity",
    "sale_total_price"
)

fact_sales.write.jdbc(postgres_url, "dwh.fact_sales", mode="overwrite", properties=postgres_props)

spark.stop()