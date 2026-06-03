CREATE DATABASE ecommerce_analytics;
USE ecommerce_analytics;

CREATE TABLE customers_table (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_name VARCHAR(255),
    segment VARCHAR(100),
    customer_order_count INT
);

CREATE TABLE products_table (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    sub_category VARCHAR(100)
);

CREATE TABLE orders_table (
    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    customer_id VARCHAR(50),
    product_id VARCHAR(50),
    region VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    sales DECIMAL(12,2),
    profit DECIMAL(12,2),
    quantity INT,
    discount DECIMAL(5,2),
    profit_margin DECIMAL(10,4),
    delivery_days INT,
    high_discount_flag INT,
    loss_flag INT,
    order_year INT,
    order_month INT,
    FOREIGN KEY (customer_id) REFERENCES customers_table(customer_id),
    FOREIGN KEY (product_id) REFERENCES products_table(product_id)
);

CREATE TABLE rfm_table (
    customer_id VARCHAR(50) PRIMARY KEY,
    recency INT,
    frequency INT,
    monetary DECIMAL(12,2),
    r_score INT,
    f_score INT,
    m_score INT,
    rfm_score INT,
    segment VARCHAR(100),
    FOREIGN KEY (customer_id) REFERENCES customers_table(customer_id)
);

SELECT 
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers
FROM orders_table;

SELECT 
    order_year,
    order_month,
    ROUND(SUM(sales),2) AS monthly_sales,
    ROUND(SUM(profit),2) AS monthly_profit
FROM orders_table
GROUP BY order_year, order_month
ORDER BY order_year, order_month;

SELECT 
    region,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit
FROM orders_table
GROUP BY region
ORDER BY total_sales DESC;

SELECT 
    p.category,
    ROUND(SUM(o.sales),2) AS total_sales,
    ROUND(SUM(o.profit),2) AS total_profit
FROM orders_table o
JOIN products_table p
ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY total_sales DESC;

SELECT 
    p.product_name,
    ROUND(SUM(o.sales),2) AS total_sales
FROM orders_table o
JOIN products_table p
ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sales DESC
LIMIT 10;

SELECT 
    p.product_name,
    ROUND(SUM(o.profit),2) AS total_profit
FROM orders_table o
JOIN products_table p
ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_profit DESC
LIMIT 10;

SELECT 
    p.product_name,
    ROUND(SUM(o.profit),2) AS total_loss
FROM orders_table o
JOIN products_table p
ON o.product_id = p.product_id
GROUP BY p.product_name
HAVING total_loss < 0
ORDER BY total_loss ASC
LIMIT 10;

SELECT 
    discount,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit
FROM orders_table
GROUP BY discount
ORDER BY discount;

SELECT 
    high_discount_flag,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit,
    ROUND(AVG(profit_margin),4) AS avg_profit_margin
FROM orders_table
GROUP BY high_discount_flag;

SELECT 
    c.customer_name,
    ROUND(SUM(o.sales),2) AS total_sales
FROM orders_table o
JOIN customers_table c
ON o.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY total_sales DESC
LIMIT 10;

SELECT 
    c.customer_name,
    ROUND(SUM(o.profit),2) AS total_profit
FROM orders_table o
JOIN customers_table c
ON o.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY total_profit DESC
LIMIT 10;

SELECT 
    r.segment,
    COUNT(DISTINCT r.customer_id) AS total_customers,
    ROUND(SUM(r.monetary),2) AS total_revenue,
    ROUND(AVG(r.monetary),2) AS avg_revenue_per_customer,
    ROUND(AVG(r.recency),2) AS avg_recency,
    ROUND(AVG(r.frequency),2) AS avg_frequency
FROM rfm_table r
GROUP BY r.segment
ORDER BY total_revenue DESC;

SELECT 
    r.segment,
    ROUND(SUM(o.sales),2) AS revenue_from_orders,
    ROUND(SUM(o.profit),2) AS profit_from_orders
FROM orders_table o
JOIN rfm_table r
ON o.customer_id = r.customer_id
GROUP BY r.segment
ORDER BY revenue_from_orders DESC;

SELECT 
    r.segment,
    p.category,
    ROUND(SUM(o.sales),2) AS total_sales,
    ROUND(SUM(o.profit),2) AS total_profit
FROM orders_table o
JOIN rfm_table r
ON o.customer_id = r.customer_id
JOIN products_table p
ON o.product_id = p.product_id
GROUP BY r.segment, p.category
ORDER BY r.segment, total_sales DESC;

SELECT 
    c.customer_name,
    r.segment,
    r.recency,
    r.frequency,
    ROUND(r.monetary,2) AS monetary,
    r.rfm_score
FROM rfm_table r
JOIN customers_table c
ON r.customer_id = c.customer_id
ORDER BY r.rfm_score DESC, r.monetary DESC
LIMIT 20;

SELECT 
    CASE 
        WHEN profit < 0 THEN 'Loss Order'
        ELSE 'Profit Order'
    END AS order_type,
    COUNT(*) AS total_orders,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit
FROM orders_table
GROUP BY order_type;

SELECT 
    order_year,
    region,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit
FROM orders_table
GROUP BY order_year, region
ORDER BY order_year, total_sales DESC;

SELECT 
    p.category,
    p.sub_category,
    ROUND(SUM(o.sales),2) AS total_sales,
    ROUND(SUM(o.profit),2) AS total_profit,
    ROUND(AVG(o.discount),2) AS avg_discount
FROM orders_table o
JOIN products_table p
ON o.product_id = p.product_id
GROUP BY p.category, p.sub_category
ORDER BY total_sales DESC;

SELECT 
    customer_id,
    COUNT(DISTINCT order_id) AS order_count,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit
FROM orders_table
GROUP BY customer_id
HAVING order_count > 1
ORDER BY total_sales DESC;

SELECT 
    ROUND((SUM(profit) / SUM(sales)) * 100,2) AS overall_profit_margin_percentage
FROM orders_table;

CREATE VIEW sales_summary_view AS
SELECT 
    order_year,
    order_month,
    region,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders_table
GROUP BY order_year, order_month, region;

CREATE VIEW customer_rfm_summary_view AS
SELECT 
    c.customer_name,
    r.segment,
    r.recency,
    r.frequency,
    ROUND(r.monetary,2) AS monetary,
    r.rfm_score
FROM customers_table c
JOIN rfm_table r
ON c.customer_id = r.customer_id;

CREATE VIEW product_performance_view AS
SELECT 
    p.category,
    p.sub_category,
    p.product_name,
    ROUND(SUM(o.sales),2) AS total_sales,
    ROUND(SUM(o.profit),2) AS total_profit,
    SUM(o.quantity) AS total_quantity
FROM orders_table o
JOIN products_table p
ON o.product_id = p.product_id
GROUP BY p.category, p.sub_category, p.product_name;