-- Create Database
CREATE DATABASE IF NOT EXISTS safaribloom;
USE safaribloom;

-- 1. Customers Table: Stores customer information for tracking sales
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone_number VARCHAR(20),
    address TEXT,
    registration_date DATE DEFAULT CURRENT_DATE
);

-- 2. Crops Table: Stores information on different crops being sold
CREATE TABLE crops (
    crop_id INT AUTO_INCREMENT PRIMARY KEY,
    crop_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),  -- e.g., 'Fruit', 'Vegetable', 'Herb'
    planting_season VARCHAR(50),
    harvest_duration INT,  -- Days until harvest
    price_per_unit DECIMAL(10, 2) NOT NULL,  -- Standard price per unit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Sales Table: Logs sales records for each transaction
CREATE TABLE sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    crop_id INT,
    sale_date DATE DEFAULT CURRENT_DATE,
    quantity INT NOT NULL,  -- Quantity sold
    unit_price DECIMAL(10, 2) NOT NULL,  -- Price per unit for this sale
    total_amount DECIMAL(10, 2) AS (quantity * unit_price) STORED,  -- Calculated total
    payment_method VARCHAR(50),  -- e.g., 'Cash', 'Card', 'Bank Transfer'
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (crop_id) REFERENCES crops(crop_id)
);

-- 4. Inventory Table: Manages current stock levels for each crop
CREATE TABLE inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    crop_id INT,
    initial_stock INT NOT NULL,
    current_stock INT NOT NULL,  -- Updates with each sale
    restock_level INT,  -- Alert level for restocking
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (crop_id) REFERENCES crops(crop_id)
);

-- 5. Expenses Table: Records expenses related to each crop
CREATE TABLE expenses (
    expense_id INT AUTO_INCREMENT PRIMARY KEY,
    crop_id INT,
    expense_date DATE DEFAULT CURRENT_DATE,
    description VARCHAR(255),
    amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (crop_id) REFERENCES crops(crop_id)
);

-- 6. Sales Performance View: A view for chart analysis of total sales, quantity sold, and average price
CREATE VIEW sales_performance AS
SELECT 
    crops.crop_name,
    crops.category,
    MONTH(sale_date) AS sale_month,
    YEAR(sale_date) AS sale_year,
    SUM(quantity) AS total_quantity_sold,
    SUM(total_amount) AS total_sales,
    AVG(unit_price) AS average_price_per_unit
FROM sales
JOIN crops ON sales.crop_id = crops.crop_id
GROUP BY crops.crop_id, sale_year, sale_month;

-- 7. Profit and Loss View: Aggregated profit and cost data for each crop by month and year
CREATE VIEW profit_and_loss AS
SELECT 
    crops.crop_name,
    MONTH(expense_date) AS expense_month,
    YEAR(expense_date) AS expense_year,
    SUM(expenses.amount) AS total_expenses,
    (SUM(sales.total_amount) - SUM(expenses.amount)) AS net_profit
FROM crops
LEFT JOIN sales ON crops.crop_id = sales.crop_id
LEFT JOIN expenses ON crops.crop_id = expenses.crop_id
GROUP BY crops.crop_id, expense_year, expense_month;

-- Indexes for Performance Optimization
CREATE INDEX idx_sales_date ON sales (sale_date);
CREATE INDEX idx_inventory_stock ON inventory (current_stock);
CREATE INDEX idx_expenses_date ON expenses (expense_date);
CREATE INDEX idx_crop_name ON crops (crop_name);

-- Sample Data for Testing

-- Insert sample customers
INSERT INTO customers (customer_name, email, phone_number, address) VALUES
('Alice Green', 'alice.green@example.com', '555-1111', '101 Oak Lane'),
('Bob Brown', 'bob.brown@example.com', '555-2222', '202 Pine St'),
('Cathy White', 'cathy.white@example.com', '555-3333', '303 Maple Ave');

-- Insert sample crops
INSERT INTO crops (crop_name, category, planting_season, harvest_duration, price_per_unit) VALUES
('Tomato', 'Vegetable', 'Spring', 90, 3.00),
('Basil', 'Herb', 'Summer', 45, 1.50),
('Lettuce', 'Vegetable', 'Fall', 60, 2.00),
('Strawberry', 'Fruit', 'Spring', 120, 4.00);

-- Insert sample inventory
INSERT INTO inventory (crop_id, initial_stock, current_stock, restock_level) VALUES
(1, 200, 200, 50),  -- Tomato
(2, 150, 150, 30),  -- Basil
(3, 300, 300, 75),  -- Lettuce
(4, 100, 100, 20);  -- Strawberry

-- Insert sample sales
INSERT INTO sales (customer_id, crop_id, sale_date, quantity, unit_price, payment_method) VALUES
(1, 1, '2024-11-01', 10, 3.00, 'Cash'),
(2, 2, '2024-11-02', 15, 1.50, 'Card'),
(3, 3, '2024-11-03', 20, 2.00, 'Bank Transfer'),
(1, 4, '2024-11-04', 5, 4.00, 'Cash');

-- Insert sample expenses
INSERT INTO expenses (crop_id, expense_date, description, amount) VALUES
(1, '2024-10-15', 'Fertilizer for tomatoes', 60.00),
(2, '2024-10-18', 'Organic pesticide', 45.00),
(3, '2024-10-20', 'Irrigation maintenance', 25.00),
(4, '2024-10-25', 'Packaging materials', 30.00);

-- End of SQL Dump
