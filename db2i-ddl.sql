create SCHEMA APP;

-- Customers
CREATE TABLE APP.CUSTOMERS (
    CUSTOMER_ID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    NAME VARCHAR(100) NOT NULL,
    EMAIL VARCHAR(200) NOT NULL UNIQUE
);

-- Orders
CREATE TABLE APP.ORDERS (
    ORDER_ID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    CUSTOMER_ID INTEGER NOT NULL,
    STATUS VARCHAR(20) NOT NULL,
    TOTAL_AMOUNT DECIMAL(12,2) NOT NULL,
    CONSTRAINT APP.FK_ORDERS_CUSTOMER FOREIGN KEY (CUSTOMER_ID)
      REFERENCES APP.CUSTOMERS (CUSTOMER_ID)
);

-- Order items
CREATE TABLE APP.ORDER_ITEMS (
    ITEM_ID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ORDER_ID INTEGER NOT NULL,
    SKU VARCHAR(50) NOT NULL,
    QTY INTEGER NOT NULL,
    UNIT_PRICE DECIMAL(12,2) NOT NULL,
    CONSTRAINT APP.FK_ITEMS_ORDER FOREIGN KEY (ORDER_ID)
      REFERENCES APP.ORDERS (ORDER_ID)
);

-- Switch to APP library
SET SCHEMA APP;

-- Insert customers
INSERT INTO CUSTOMERS (NAME, EMAIL) VALUES
('Alice Johnson', 'alice.johnson@example.com'),
('Bob Smith', 'bob.smith@example.com'),
('Charlie Brown', 'charlie.brown@example.com'),
('Diana Prince', 'diana.prince@example.com'),
('Ethan Hunt', 'ethan.hunt@example.com'),
('Fiona Gallagher', 'fiona.gallagher@example.com'),
('George Michael', 'george.michael@example.com'),
('Hannah Wells', 'hannah.wells@example.com'),
('Ian Fleming', 'ian.fleming@example.com'),
('Julia Roberts', 'julia.roberts@example.com'),
('Kevin Bacon', 'kevin.bacon@example.com'),
('Laura Palmer', 'laura.palmer@example.com'),
('Michael Scott', 'michael.scott@example.com'),
('Nina Simone', 'nina.simone@example.com'),
('Oscar Wilde', 'oscar.wilde@example.com'),
('Pam Beesly', 'pam.beesly@example.com'),
('Quentin Blake', 'quentin.blake@example.com'),
('Rachel Green', 'rachel.green@example.com'),
('Steve Rogers', 'steve.rogers@example.com'),
('Tony Stark', 'tony.stark@example.com'),
('Uma Thurman', 'uma.thurman@example.com'),
('Victor Hugo', 'victor.hugo@example.com'),
('Wanda Maximoff', 'wanda.maximoff@example.com'),
('Xander Harris', 'xander.harris@example.com'),
('Yara Greyjoy', 'yara.greyjoy@example.com'),
('Zack Morris', 'zack.morris@example.com'),
('Ada Lovelace', 'ada.lovelace@example.com'),
('Bruce Wayne', 'bruce.wayne@example.com'),
('Clark Kent', 'clark.kent@example.com'),
('Dorothy Gale', 'dorothy.gale@example.com');

-- Insert orders (30 orders, distributed across customers)
INSERT INTO ORDERS (CUSTOMER_ID, STATUS, TOTAL_AMOUNT) VALUES
(1, 'CREATED', 120.50),
(2, 'SHIPPED', 89.99),
(3, 'DELIVERED', 250.00),
(4, 'CANCELLED', 49.99),
(5, 'CREATED', 340.75),
(6, 'CREATED', 180.20),
(7, 'DELIVERED', 560.00),
(8, 'SHIPPED', 220.10),
(9, 'CREATED', 75.50),
(10, 'DELIVERED', 430.00),
(11, 'CREATED', 99.90),
(12, 'CANCELLED', 130.45),
(13, 'DELIVERED', 85.00),
(14, 'SHIPPED', 200.20),
(15, 'CREATED', 67.45),
(16, 'DELIVERED', 145.75),
(17, 'CREATED', 305.00),
(18, 'SHIPPED', 210.15),
(19, 'DELIVERED', 590.00),
(20, 'CANCELLED', 75.75),
(21, 'CREATED', 430.00),
(22, 'SHIPPED', 88.40),
(23, 'DELIVERED', 154.30),
(24, 'CREATED', 249.99),
(25, 'SHIPPED', 400.00),
(26, 'DELIVERED', 510.20),
(27, 'CANCELLED', 34.95),
(28, 'DELIVERED', 220.00),
(29, 'CREATED', 145.10),
(30, 'SHIPPED', 330.60);

-- Insert order items (around 40 records, 1–3 per order)
INSERT INTO ORDER_ITEMS (ORDER_ID, SKU, QTY, UNIT_PRICE) VALUES
(1, 'SKU-1001', 2, 50.00),
(1, 'SKU-2001', 1, 20.50),
(2, 'SKU-1002', 1, 89.99),
(3, 'SKU-3001', 2, 100.00),
(3, 'SKU-4001', 1, 50.00),
(4, 'SKU-5001', 1, 49.99),
(5, 'SKU-1003', 5, 68.15),
(6, 'SKU-2002', 2, 90.10),
(7, 'SKU-3002', 4, 140.00),
(8, 'SKU-4002', 2, 110.05),
(9, 'SKU-1004', 1, 75.50),
(10, 'SKU-2003', 2, 215.00),
(11, 'SKU-5002', 3, 33.30),
(12, 'SKU-6001', 2, 65.20),
(13, 'SKU-1005', 1, 85.00),
(14, 'SKU-7001', 2, 100.10),
(15, 'SKU-8001', 1, 67.45),
(16, 'SKU-9001', 1, 145.75),
(17, 'SKU-1006', 2, 152.50),
(18, 'SKU-2004', 2, 105.08),
(19, 'SKU-3003', 5, 118.00),
(20, 'SKU-4003', 1, 75.75),
(21, 'SKU-5003', 3, 143.33),
(22, 'SKU-6002', 2, 44.20),
(23, 'SKU-1007', 1, 154.30),
(24, 'SKU-2005', 2, 124.99),
(25, 'SKU-3004', 2, 200.00),
(26, 'SKU-4004', 2, 255.10),
(27, 'SKU-1008', 1, 34.95),
(28, 'SKU-2006', 2, 110.00),
(29, 'SKU-3005', 1, 145.10),
(30, 'SKU-4005', 3, 110.20);
