--------------------------------------------------------------------------------
-- Step 1: Create raw streams (directly mapped to the Kafka topics from DB2i CDC)
-- Topics follow the format: db2i.APP.TABLE
--------------------------------------------------------------------------------

CREATE STREAM customers_raw (
  schema STRUCT<type STRING, fields ARRAY<STRUCT<type STRING, field STRING>>, optional BOOLEAN, name STRING>,
  payload STRUCT<
    CUSTOMER_ID INT,
    NAME STRING,
    EMAIL STRING
  >
) WITH (
  KAFKA_TOPIC = 'db2i.APP.CUSTOMERS',
  VALUE_FORMAT = 'JSON'
);

CREATE STREAM orders_raw (
  schema STRUCT<type STRING, fields ARRAY<STRUCT<type STRING, field STRING>>, optional BOOLEAN, name STRING>,
  payload STRUCT<
    ORDER_ID INT,
    CUSTOMER_ID INT,
    ORDER_DATE STRING,
    STATUS STRING
  >
) WITH (
  KAFKA_TOPIC = 'db2i.APP.ORDERS',
  VALUE_FORMAT = 'JSON'
);

CREATE STREAM order_items_raw (
  schema STRUCT<type STRING, fields ARRAY<STRUCT<type STRING, field STRING>>, optional BOOLEAN, name STRING>,
  payload STRUCT<
    ITEM_ID INT,
    ORDER_ID INT,
    PRODUCT STRING,
    QUANTITY INT,
    PRICE DOUBLE
  >
) WITH (
  KAFKA_TOPIC = 'db2i.APP.ORDER_ITEMS',
  VALUE_FORMAT = 'JSON'
);

--------------------------------------------------------------------------------
-- Step 2: Flatten payload into clean streams
--------------------------------------------------------------------------------

CREATE STREAM customers_stream
  WITH (KAFKA_TOPIC = 'CUSTOMERS_STREAM', VALUE_FORMAT = 'JSON') AS
  SELECT
    payload->CUSTOMER_ID AS customer_id,
    payload->NAME AS name,
    payload->EMAIL AS email
  FROM customers_raw
  EMIT CHANGES;

CREATE STREAM orders_stream
  WITH (KAFKA_TOPIC = 'ORDERS_STREAM', VALUE_FORMAT = 'JSON') AS
  SELECT
    payload->ORDER_ID AS order_id,
    payload->CUSTOMER_ID AS customer_id,
    payload->ORDER_DATE AS order_date,
    payload->STATUS AS status
  FROM orders_raw
  EMIT CHANGES;

CREATE STREAM order_items_stream
  WITH (KAFKA_TOPIC = 'ORDER_ITEMS_STREAM', VALUE_FORMAT = 'JSON') AS
  SELECT
    payload->ITEM_ID AS item_id,
    payload->ORDER_ID AS order_id,
    payload->PRODUCT AS product,
    payload->QUANTITY AS quantity,
    payload->PRICE AS price
  FROM order_items_raw
  EMIT CHANGES;

--------------------------------------------------------------------------------
-- Step 3: Create Tables (materialized views) for deduplication and joining
--------------------------------------------------------------------------------

CREATE TABLE customers_table
  WITH (KAFKA_TOPIC = 'CUSTOMERS_TABLE', VALUE_FORMAT = 'JSON') AS
  SELECT
    customer_id,
    LATEST_BY_OFFSET(name) AS name,
    LATEST_BY_OFFSET(email) AS email
  FROM customers_stream
  GROUP BY customer_id
  EMIT CHANGES;

CREATE TABLE orders_table
  WITH (KAFKA_TOPIC = 'ORDERS_TABLE', VALUE_FORMAT = 'JSON') AS
  SELECT
    order_id,
    LATEST_BY_OFFSET(customer_id) AS customer_id,
    LATEST_BY_OFFSET(order_date) AS order_date,
    LATEST_BY_OFFSET(status) AS status
  FROM orders_stream
  GROUP BY order_id
  EMIT CHANGES;

CREATE TABLE order_items_table
  WITH (KAFKA_TOPIC = 'ORDER_ITEMS_TABLE', VALUE_FORMAT = 'JSON') AS
  SELECT
    item_id,
    LATEST_BY_OFFSET(order_id) AS order_id,
    LATEST_BY_OFFSET(product) AS product,
    LATEST_BY_OFFSET(quantity) AS quantity,
    LATEST_BY_OFFSET(price) AS price
  FROM order_items_stream
  GROUP BY item_id
  EMIT CHANGES;

--------------------------------------------------------------------------------
-- Step 4: Enriched Orders View (Orders + Customer + Items)
--------------------------------------------------------------------------------

CREATE TABLE orders_aggregated
  WITH (KAFKA_TOPIC = 'orders_aggregated', VALUE_FORMAT = 'JSON') AS
  SELECT
    o.order_id,
    o.customer_id,
    c.name AS customer_name,
    c.email AS customer_email,
    o.order_date,
    o.status,
    i.item_id,
    i.product,
    i.quantity,
    i.price
  FROM orders_table o
  LEFT JOIN customers_table c
    ON o.customer_id = c.customer_id
  LEFT JOIN order_items_table i
    ON i.order_id = o.order_id
  EMIT CHANGES;

--------------------------------------------------------------------------------
-- Done: The topic "ORDERS_ENRICHED" now contains enriched order events.
--------------------------------------------------------------------------------
