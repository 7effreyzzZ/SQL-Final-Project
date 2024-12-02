-- Q1 What are the best-selling products?

SELECT 
    p.product_id, 
    p.product_name, 
    c.category_name, 
    SUM(td.quantity) AS total_sold
FROM 
    transaction_details td
JOIN 
    product p ON td.product_id = p.product_id
JOIN 
    category c ON p.category_id = c.category_id
GROUP BY 
    p.product_id, p.product_name, c.category_name
ORDER BY 
    total_sold DESC;

-- Q2 Which stores have the highest sales revenue?

SELECT 
    s.store_id, 
    s.store_name, 
    SUM(td.quantity * p.unit_price) AS total_revenue
FROM 
    transaction_details td
JOIN 
    product p ON td.product_id = p.product_id
JOIN 
    customer_transactions ct ON td.transaction_id = ct.transaction_id
JOIN 
    store s ON ct.store_id = s.store_id
GROUP BY 
    s.store_id, s.store_name
ORDER BY 
    total_revenue DESC;

-- Q3 What is the average customer rating for each store?

SELECT 
    s.store_id, 
    s.store_name, 
    AVG(cf.rating) AS average_rating
FROM 
    customer_feedback cf
JOIN 
    customer_transactions ct ON cf.transaction_id = ct.transaction_id
JOIN 
    store s ON ct.store_id = s.store_id
GROUP BY 
    s.store_id, s.store_name
ORDER BY 
    average_rating DESC;

-- Q4 Which customers spend the most?
SELECT 
    ct.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
    SUM(td.quantity * p.unit_price) AS total_spent
FROM 
    customer_transactions ct
JOIN 
    transaction_details td ON ct.transaction_id = td.transaction_id
JOIN 
    product p ON td.product_id = p.product_id
JOIN 
    customer c ON ct.customer_id = c.customer_id
GROUP BY 
    ct.customer_id, customer_name
ORDER BY 
    total_spent DESC;

-- Q5 What are the monthly sales trends?
SELECT 
    TO_CHAR(ct.transaction_date, 'YYYY-MM') AS month, 
    SUM(td.quantity * p.unit_price) AS total_revenue
FROM 
    transaction_details td
JOIN 
    customer_transactions ct ON td.transaction_id = ct.transaction_id
JOIN 
    product p ON td.product_id = p.product_id
GROUP BY 
    TO_CHAR(ct.transaction_date, 'YYYY-MM')
ORDER BY 
    month;

-- Q6. Which product categories contribute the most revenue?

SELECT
    c.category_name,
    SUM(td.quantity * p.unit_price) AS total_revenue
FROM
    transaction_details td
JOIN
    product p ON td.product_id = p.product_id
JOIN
    category c ON p.category_id = c.category_id
GROUP BY
    c.category_name
ORDER BY
    total_revenue DESC;


-- Q7. What are the three most profitable products in each store?

WITH RankedProducts AS (
    SELECT
        s.store_id,
        s.store_name,
        p.product_id,
        p.product_name,
        SUM(td.quantity * p.unit_price) AS total_profit, -- Profit is assumed as revenue since cost_price is not available
        ROW_NUMBER() OVER (PARTITION BY s.store_id ORDER BY SUM(td.quantity * p.unit_price) DESC) AS rank
    FROM
        transaction_details td
    JOIN
        product p ON td.product_id = p.product_id
    JOIN
        customer_transactions ct ON td.transaction_id = ct.transaction_id
    JOIN
        store s ON ct.store_id = s.store_id
    GROUP BY
        s.store_id, s.store_name, p.product_id, p.product_name
)
SELECT
    store_id,
    store_name,
    product_id,
    product_name,
    total_profit
FROM
    RankedProducts
WHERE
    rank <= 3
ORDER BY
    store_id, rank;

	
-- Q8. Which 10 vendors contribute most to the supply chain?

SELECT
    v.vendor_id,
    v.name AS vendor_name,
    pv.supply_frequency,
    COUNT(DISTINCT pv.product_id) AS total_products_supplied,
    SUM(ps.quantity) AS total_stock_quantity
FROM product_vendor pv
JOIN product_stock ps ON pv.product_id = ps.product_id
JOIN vendor v ON pv.vendor_id = v.vendor_id
GROUP BY v.vendor_id, v.name, pv.supply_frequency
ORDER BY total_stock_quantity DESC;


-- Q9. Who are the 10 most loyal customers?

SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    lp.membership_start_date,
    lp.total_points,
    lp.membership_tier,
    c.city
FROM 
    loyalty_program lp
JOIN 
    customer c ON lp.customer_id = c.customer_id
ORDER BY 
    lp.total_points DESC, 
    lp.membership_start_date ASC;


-- Q10. Store Expense Analysis

SELECT
    store_id,
    expense_category,
    SUM(amount) AS total_expense,
    (SUM(amount) * 100.0) /
	(SELECT SUM(amount) 
	FROM operating_costs WHERE store_id = o.store_id) AS percentage_share
FROM operating_costs o
GROUP BY store_id, expense_category
ORDER BY store_id, percentage_share DESC;
