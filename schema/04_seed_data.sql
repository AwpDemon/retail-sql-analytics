-- ============================================================================
-- RetailPulse Analytics Database — Sample Seed Data
-- MIST 4600 | University of Georgia | Spring 2025
-- ============================================================================
-- Inserts a representative sample dataset for development and testing.
-- For larger datasets, use scripts/generate_data.py.
-- ============================================================================

-- ============================================================================
-- CATEGORIES (12 rows: 4 parent + 8 subcategories)
-- ============================================================================
INSERT INTO categories (category_name, description, parent_category_id) VALUES
    ('Electronics', 'Consumer electronics and gadgets', NULL),
    ('Home & Kitchen', 'Household items, cookware, and furnishings', NULL),
    ('Apparel', 'Clothing, shoes, and accessories', NULL),
    ('Sports & Outdoors', 'Sporting goods and outdoor equipment', NULL);

INSERT INTO categories (category_name, description, parent_category_id) VALUES
    ('Laptops', 'Notebook computers and Chromebooks', 1),
    ('Smartphones', 'Mobile phones and accessories', 1),
    ('Audio', 'Headphones, speakers, and audio equipment', 1),
    ('Cookware', 'Pots, pans, and cooking utensils', 2),
    ('Small Appliances', 'Countertop appliances', 2),
    ('Mens Clothing', 'Mens shirts, pants, and outerwear', 3),
    ('Womens Clothing', 'Womens shirts, pants, and outerwear', 3),
    ('Fitness Equipment', 'Home gym and fitness accessories', 4);

-- ============================================================================
-- SUPPLIERS (25 rows)
-- ============================================================================
INSERT INTO suppliers (company_name, contact_name, contact_email, phone, address, city, state, country, lead_time_days, rating) VALUES
    ('TechSource Global', 'David Chen', 'dchen@techsource.com', '415-555-0101', '100 Innovation Blvd', 'San Jose', 'CA', 'US', 5, 4.50),
    ('HomeGoods Direct', 'Sarah Williams', 'swilliams@homegoodsd.com', '212-555-0202', '250 Commerce St', 'New York', 'NY', 'US', 7, 4.20),
    ('Apex Apparel Co', 'Maria Rodriguez', 'mrodriguez@apexapparel.com', '213-555-0303', '800 Fashion Ave', 'Los Angeles', 'CA', 'US', 10, 3.80),
    ('SportMax Industries', 'James Thompson', 'jthompson@sportmax.com', '503-555-0404', '420 Athletic Way', 'Portland', 'OR', 'US', 8, 4.10),
    ('Pacific Electronics', 'Lisa Tanaka', 'ltanaka@pacelec.com', '206-555-0505', '700 Tech Park Dr', 'Seattle', 'WA', 'US', 4, 4.70),
    ('Midwest Supply Chain', 'Robert Miller', 'rmiller@midwestsc.com', '312-555-0606', '150 Industrial Pkwy', 'Chicago', 'IL', 'US', 6, 3.90),
    ('Southern Textiles', 'Amanda Johnson', 'ajohnson@southtex.com', '404-555-0707', '320 Peachtree St', 'Atlanta', 'GA', 'US', 12, 3.50),
    ('Nordic Kitchen Supply', 'Erik Johansson', 'erikj@nordickitchen.com', '646-555-0808', '85 Scandinavian Way', 'Brooklyn', 'NY', 'US', 14, 4.60),
    ('Global Gadgets Ltd', 'Priya Patel', 'ppatel@globalgadgets.com', '408-555-0909', '920 Silicon Dr', 'Santa Clara', 'CA', 'US', 3, 4.40),
    ('EcoFit Sports', 'Kevin OBrien', 'kobrien@ecofitsports.com', '720-555-1010', '560 Mountain View Rd', 'Denver', 'CO', 'US', 9, 4.00),
    ('Zenith Audio Systems', 'Tom Park', 'tpark@zenithaudio.com', '415-555-1111', '200 Sound Blvd', 'San Francisco', 'CA', 'US', 5, 4.30),
    ('QuickShip Wholesale', 'Nancy Davis', 'ndavis@quickshipws.com', '972-555-1212', '400 Distribution Ln', 'Dallas', 'TX', 'US', 2, 4.80),
    ('Trident Manufacturing', 'Carlos Reyes', 'creyes@tridentmfg.com', '305-555-1313', '175 Factory Row', 'Miami', 'FL', 'US', 11, 3.60),
    ('Summit Outdoors', 'Anne Fletcher', 'afletcher@summitout.com', '801-555-1414', '890 Trail St', 'Salt Lake City', 'UT', 'US', 7, 4.10),
    ('Precision Parts Inc', 'Harold Wright', 'hwright@precisionparts.com', '614-555-1515', '330 Assembly Dr', 'Columbus', 'OH', 'US', 6, 3.70),
    ('Harbor Imports', 'Wei Zhang', 'wzhang@harborimports.com', '562-555-1616', '1200 Port Ave', 'Long Beach', 'CA', 'US', 15, 3.40),
    ('Atlas Home Furnishings', 'Barbara Collins', 'bcollins@atlashome.com', '919-555-1717', '77 Comfort Ln', 'Raleigh', 'NC', 'US', 8, 4.20),
    ('Velocity Tech', 'Chris Nguyen', 'cnguyen@velocitytech.com', '512-555-1818', '510 Circuit Rd', 'Austin', 'TX', 'US', 4, 4.50),
    ('Green Valley Goods', 'Diane Hartman', 'dhartman@greenvalley.com', '503-555-1919', '225 Organic Way', 'Eugene', 'OR', 'US', 10, 3.90),
    ('Titan Sports Gear', 'Frank Morales', 'fmorales@titansports.com', '602-555-2020', '680 Arena Blvd', 'Phoenix', 'AZ', 'US', 7, 4.00),
    ('Bright Home Electronics', 'Grace Lee', 'glee@brighthome.com', '425-555-2121', '350 Circuit Way', 'Bellevue', 'WA', 'US', 5, 4.60),
    ('Continental Apparel', 'Ivan Kozlov', 'ikozlov@continentalapp.com', '646-555-2222', '490 Garment District', 'New York', 'NY', 'US', 13, 3.30),
    ('Reliable Kitchen Co', 'Jackie Ford', 'jford@reliablekitchen.com', '615-555-2323', '120 Cook St', 'Nashville', 'TN', 'US', 9, 4.10),
    ('NextGen Devices', 'Kyle Austin', 'kaustin@nextgendev.com', '408-555-2424', '800 Chip Ln', 'San Jose', 'CA', 'US', 3, 4.70),
    ('Pine Creek Outfitters', 'Lauren Beck', 'lbeck@pinecreek.com', '406-555-2525', '55 Wilderness Rd', 'Bozeman', 'MT', 'US', 11, 3.80);

-- ============================================================================
-- PRODUCTS (50 representative products across categories)
-- ============================================================================
INSERT INTO products (product_name, description, unit_price, cost_price, category_id, supplier_id, sku, weight_kg, is_active) VALUES
    -- Laptops (cat 5)
    ('ProBook 15 Laptop', '15.6" FHD, Intel i7, 16GB RAM, 512GB SSD', 899.99, 620.00, 5, 1, 'ELEC-LAP-001', 2.10, TRUE),
    ('UltraSlim 13 Notebook', '13.3" 2K, AMD Ryzen 5, 8GB RAM, 256GB SSD', 649.99, 430.00, 5, 5, 'ELEC-LAP-002', 1.30, TRUE),
    ('ChromeBook Lite', '14" HD, MediaTek, 4GB RAM, 64GB eMMC', 249.99, 155.00, 5, 18, 'ELEC-LAP-003', 1.50, TRUE),
    ('GameForce 17 Pro', '17.3" QHD 165Hz, RTX 4070, 32GB RAM', 1799.99, 1250.00, 5, 24, 'ELEC-LAP-004', 3.20, TRUE),
    -- Smartphones (cat 6)
    ('Galaxy S24 Ultra', '6.8" AMOLED, 256GB, 12GB RAM', 1199.99, 780.00, 6, 9, 'ELEC-PHN-001', 0.23, TRUE),
    ('iPhone 15 Pro', '6.1" Super Retina XDR, 256GB', 999.99, 700.00, 6, 1, 'ELEC-PHN-002', 0.19, TRUE),
    ('Pixel 8a', '6.1" OLED, 128GB, Google Tensor G3', 499.99, 310.00, 6, 9, 'ELEC-PHN-003', 0.19, TRUE),
    ('BudgetCall X1', '6.5" LCD, 64GB, Snapdragon 680', 149.99, 85.00, 6, 16, 'ELEC-PHN-004', 0.20, TRUE),
    -- Audio (cat 7)
    ('StudioMax Over-Ear Headphones', 'Active noise cancelling, 40hr battery', 349.99, 180.00, 7, 11, 'ELEC-AUD-001', 0.28, TRUE),
    ('BassWave Bluetooth Speaker', 'Portable, waterproof, 20W output', 79.99, 35.00, 7, 11, 'ELEC-AUD-002', 0.55, TRUE),
    ('EarPod Pro Wireless', 'True wireless ANC earbuds', 199.99, 95.00, 7, 5, 'ELEC-AUD-003', 0.06, TRUE),
    ('Vinyl Turntable Classic', 'Belt-drive turntable with built-in preamp', 229.99, 120.00, 7, 21, 'ELEC-AUD-004', 4.50, TRUE),
    -- Cookware (cat 8)
    ('Chef Pro 10-Piece Cookware Set', 'Stainless steel, induction-ready', 189.99, 85.00, 8, 8, 'HOME-CKW-001', 8.50, TRUE),
    ('Cast Iron Dutch Oven 6qt', 'Enameled cast iron, oven-safe', 69.99, 30.00, 8, 23, 'HOME-CKW-002', 5.80, TRUE),
    ('Non-Stick Frying Pan 12in', 'Ceramic coated, PFOA-free', 34.99, 14.00, 8, 2, 'HOME-CKW-003', 1.20, TRUE),
    ('Knife Block Set (8-piece)', 'High-carbon stainless steel', 129.99, 55.00, 8, 8, 'HOME-CKW-004', 3.40, TRUE),
    -- Small Appliances (cat 9)
    ('BrewMaster Coffee Maker', '12-cup programmable with thermal carafe', 89.99, 42.00, 9, 2, 'HOME-APP-001', 3.00, TRUE),
    ('AirFry Pro 5.5L', 'Digital air fryer, 8 presets', 119.99, 55.00, 9, 17, 'HOME-APP-002', 5.20, TRUE),
    ('BlendForce 1200W Blender', 'Professional-grade, 64oz pitcher', 74.99, 32.00, 9, 6, 'HOME-APP-003', 3.80, TRUE),
    ('Instant Pot Duo 8qt', '7-in-1 pressure cooker', 99.99, 48.00, 9, 12, 'HOME-APP-004', 6.10, TRUE),
    ('Toaster Oven Deluxe', 'Convection, fits 12" pizza', 64.99, 28.00, 9, 17, 'HOME-APP-005', 4.50, TRUE),
    -- Mens Clothing (cat 10)
    ('Classic Fit Oxford Shirt', '100% cotton button-down, multiple colors', 49.99, 15.00, 10, 3, 'APRL-MEN-001', 0.30, TRUE),
    ('Slim Chino Pants', 'Stretch cotton twill, flat front', 59.99, 20.00, 10, 7, 'APRL-MEN-002', 0.45, TRUE),
    ('Merino Wool Sweater', 'Crew neck, machine washable', 79.99, 28.00, 10, 22, 'APRL-MEN-003', 0.35, TRUE),
    ('Waterproof Shell Jacket', 'Seam-sealed, packable, 3-layer', 149.99, 55.00, 10, 4, 'APRL-MEN-004', 0.50, TRUE),
    ('Performance Running Shorts', 'Moisture-wicking, built-in liner', 34.99, 12.00, 10, 3, 'APRL-MEN-005', 0.15, TRUE),
    -- Womens Clothing (cat 11)
    ('Relaxed Fit Linen Blouse', 'Breathable linen, relaxed cut', 44.99, 14.00, 11, 7, 'APRL-WMN-001', 0.20, TRUE),
    ('High-Rise Yoga Leggings', '4-way stretch, squat-proof', 54.99, 16.00, 11, 3, 'APRL-WMN-002', 0.25, TRUE),
    ('Puffer Vest Insulated', '650-fill down, water-resistant', 89.99, 35.00, 11, 22, 'APRL-WMN-003', 0.40, TRUE),
    ('Casual Denim Jacket', 'Classic wash, button front', 69.99, 24.00, 11, 13, 'APRL-WMN-004', 0.70, TRUE),
    ('Trail Running Shoes', 'Vibram outsole, breathable mesh', 119.99, 48.00, 11, 4, 'APRL-WMN-005', 0.65, TRUE),
    -- Fitness Equipment (cat 12)
    ('Adjustable Dumbbell Set (5-52.5 lb)', 'Space-saving adjustable weight', 349.99, 180.00, 12, 10, 'SPRT-FIT-001', 24.00, TRUE),
    ('Yoga Mat Premium 6mm', 'Non-slip, eco-friendly TPE', 39.99, 12.00, 12, 19, 'SPRT-FIT-002', 1.20, TRUE),
    ('Resistance Band Set (5-pack)', 'Latex-free, 5 resistance levels', 24.99, 7.00, 12, 10, 'SPRT-FIT-003', 0.50, TRUE),
    ('Folding Treadmill 2.5HP', 'Compact, Bluetooth, heart rate monitor', 599.99, 320.00, 12, 20, 'SPRT-FIT-004', 35.00, TRUE),
    ('Exercise Ball 65cm', 'Anti-burst, includes pump', 19.99, 6.00, 12, 14, 'SPRT-FIT-005', 1.10, TRUE),
    ('Pull-Up Bar Doorframe', 'Multi-grip, no screws required', 29.99, 10.00, 12, 20, 'SPRT-FIT-006', 2.80, TRUE),
    -- Additional mixed products
    ('Wireless Charging Pad', 'Qi-compatible, 15W fast charge', 29.99, 10.00, 6, 9, 'ELEC-ACC-001', 0.10, TRUE),
    ('Smart Home Hub', 'Voice control, Zigbee/Z-Wave, Thread', 129.99, 65.00, 1, 21, 'ELEC-SMH-001', 0.35, TRUE),
    ('LED Desk Lamp', 'Adjustable color temp, USB charging port', 44.99, 18.00, 2, 17, 'HOME-LMP-001', 1.50, TRUE),
    ('Bamboo Cutting Board Set', '3-piece, juice groove', 29.99, 10.00, 8, 19, 'HOME-CKW-005', 2.00, TRUE),
    ('Stainless Steel Water Bottle', '32oz vacuum insulated', 24.99, 8.00, 12, 14, 'SPRT-ACC-001', 0.45, TRUE),
    ('Bluetooth Fitness Tracker', 'Heart rate, sleep, steps, 7-day battery', 59.99, 22.00, 12, 9, 'SPRT-FIT-007', 0.03, TRUE),
    ('USB-C Hub 7-in-1', 'HDMI, USB 3.0, SD, 100W PD passthrough', 49.99, 18.00, 5, 18, 'ELEC-ACC-002', 0.08, TRUE),
    ('Ergonomic Office Chair', 'Lumbar support, adjustable arms, mesh back', 299.99, 145.00, 2, 17, 'HOME-FRN-001', 15.00, TRUE),
    ('Portable Power Bank 20000mAh', 'USB-C PD 65W, fast charge', 59.99, 25.00, 6, 24, 'ELEC-ACC-003', 0.40, TRUE),
    ('French Press Coffee Maker', 'Borosilicate glass, 34oz', 24.99, 8.00, 8, 23, 'HOME-CKW-006', 0.60, TRUE),
    ('Insulated Cooler Backpack', '30-can capacity, leak-proof', 49.99, 20.00, 4, 25, 'SPRT-OUT-001', 0.90, TRUE),
    ('Camping Hammock', 'Nylon, holds 400lbs, includes straps', 34.99, 12.00, 4, 14, 'SPRT-OUT-002', 0.55, TRUE),
    ('Digital Kitchen Scale', 'Precision to 0.1g, tare function', 19.99, 7.00, 9, 12, 'HOME-APP-006', 0.40, TRUE);

-- ============================================================================
-- EMPLOYEES (30 rows)
-- ============================================================================

-- Top-level managers (no manager_id)
INSERT INTO employees (first_name, last_name, email, role, department, hire_date, salary, manager_id) VALUES
    ('Catherine', 'Brooks', 'cbrooks@retailpulse.com', 'VP of Sales', 'Sales', '2019-03-15', 125000.00, NULL),
    ('Michael', 'Torres', 'mtorres@retailpulse.com', 'VP of Operations', 'Operations', '2019-06-01', 120000.00, NULL),
    ('Susan', 'Park', 'spark@retailpulse.com', 'VP of Marketing', 'Marketing', '2020-01-10', 118000.00, NULL);

-- Mid-level managers
INSERT INTO employees (first_name, last_name, email, role, department, hire_date, salary, manager_id) VALUES
    ('Daniel', 'Kim', 'dkim@retailpulse.com', 'Sales Manager - East', 'Sales', '2020-04-20', 85000.00, 1),
    ('Angela', 'Foster', 'afoster@retailpulse.com', 'Sales Manager - West', 'Sales', '2020-07-14', 85000.00, 1),
    ('Brian', 'Wallace', 'bwallace@retailpulse.com', 'Operations Manager', 'Operations', '2020-09-01', 80000.00, 2),
    ('Rachel', 'Murphy', 'rmurphy@retailpulse.com', 'Marketing Manager', 'Marketing', '2021-02-15', 78000.00, 3);

-- Sales representatives
INSERT INTO employees (first_name, last_name, email, role, department, hire_date, salary, manager_id) VALUES
    ('Ethan', 'Clark', 'eclark@retailpulse.com', 'Senior Sales Rep', 'Sales', '2021-01-10', 62000.00, 4),
    ('Olivia', 'Davis', 'odavis@retailpulse.com', 'Senior Sales Rep', 'Sales', '2021-03-22', 62000.00, 4),
    ('Noah', 'Martin', 'nmartin@retailpulse.com', 'Sales Rep', 'Sales', '2021-06-15', 52000.00, 4),
    ('Emma', 'Wilson', 'ewilson@retailpulse.com', 'Sales Rep', 'Sales', '2021-08-01', 52000.00, 5),
    ('Liam', 'Brown', 'lbrown@retailpulse.com', 'Sales Rep', 'Sales', '2021-10-10', 50000.00, 5),
    ('Sophia', 'Taylor', 'staylor@retailpulse.com', 'Sales Rep', 'Sales', '2022-01-05', 50000.00, 4),
    ('Mason', 'Anderson', 'manderson@retailpulse.com', 'Sales Rep', 'Sales', '2022-03-20', 48000.00, 5),
    ('Isabella', 'Thomas', 'ithomas@retailpulse.com', 'Sales Rep', 'Sales', '2022-05-15', 48000.00, 4),
    ('Lucas', 'Jackson', 'ljackson@retailpulse.com', 'Junior Sales Rep', 'Sales', '2022-09-01', 42000.00, 5),
    ('Mia', 'White', 'mwhite@retailpulse.com', 'Junior Sales Rep', 'Sales', '2023-01-15', 42000.00, 4),
    ('Alexander', 'Harris', 'aharris@retailpulse.com', 'Junior Sales Rep', 'Sales', '2023-04-10', 40000.00, 5);

-- Operations staff
INSERT INTO employees (first_name, last_name, email, role, department, hire_date, salary, manager_id) VALUES
    ('Charlotte', 'Lewis', 'clewis@retailpulse.com', 'Warehouse Lead', 'Operations', '2020-11-01', 55000.00, 6),
    ('Benjamin', 'Robinson', 'brobinson@retailpulse.com', 'Inventory Analyst', 'Operations', '2021-04-15', 52000.00, 6),
    ('Amelia', 'Walker', 'awalker@retailpulse.com', 'Shipping Coordinator', 'Operations', '2021-07-20', 48000.00, 6),
    ('Henry', 'Young', 'hyoung@retailpulse.com', 'QA Specialist', 'Operations', '2022-02-10', 50000.00, 6),
    ('Evelyn', 'King', 'eking@retailpulse.com', 'Warehouse Associate', 'Operations', '2022-08-01', 38000.00, 21);

-- Marketing staff
INSERT INTO employees (first_name, last_name, email, role, department, hire_date, salary, manager_id) VALUES
    ('Sebastian', 'Wright', 'swright@retailpulse.com', 'Digital Marketing Specialist', 'Marketing', '2021-05-10', 58000.00, 7),
    ('Harper', 'Lopez', 'hlopez@retailpulse.com', 'Content Strategist', 'Marketing', '2021-09-15', 55000.00, 7),
    ('Jack', 'Hill', 'jhill@retailpulse.com', 'SEO Analyst', 'Marketing', '2022-01-20', 52000.00, 7),
    ('Aria', 'Scott', 'ascott@retailpulse.com', 'Social Media Manager', 'Marketing', '2022-06-01', 50000.00, 7),
    ('Owen', 'Green', 'ogreen@retailpulse.com', 'Email Marketing Specialist', 'Marketing', '2023-02-15', 46000.00, 7),
    ('Ella', 'Adams', 'eadams@retailpulse.com', 'Marketing Coordinator', 'Marketing', '2023-06-01', 42000.00, 7);

-- ============================================================================
-- CUSTOMERS (50 representative rows — use generate_data.py for full 500+)
-- ============================================================================
INSERT INTO customers (first_name, last_name, email, phone, address_line1, city, state, zip_code, country, date_of_birth, registered_at, customer_segment) VALUES
    ('John', 'Smith', 'john.smith@email.com', '770-555-1001', '123 Peachtree St', 'Atlanta', 'GA', '30301', 'US', '1985-06-15', '2023-01-10 09:30:00', 'VIP'),
    ('Emily', 'Johnson', 'emily.j@email.com', '212-555-1002', '456 Broadway', 'New York', 'NY', '10001', 'US', '1990-03-22', '2023-01-15 14:20:00', 'Premium'),
    ('Michael', 'Williams', 'mwilliams@email.com', '312-555-1003', '789 Michigan Ave', 'Chicago', 'IL', '60601', 'US', '1978-11-08', '2023-02-01 10:45:00', 'VIP'),
    ('Sarah', 'Brown', 'sarah.brown@email.com', '415-555-1004', '321 Market St', 'San Francisco', 'CA', '94102', 'US', '1992-07-30', '2023-02-14 16:30:00', 'Regular'),
    ('David', 'Jones', 'djones@email.com', '713-555-1005', '654 Main St', 'Houston', 'TX', '77001', 'US', '1988-01-25', '2023-02-28 11:00:00', 'Premium'),
    ('Jessica', 'Garcia', 'jgarcia@email.com', '602-555-1006', '987 Camelback Rd', 'Phoenix', 'AZ', '85001', 'US', '1995-09-12', '2023-03-10 08:15:00', 'Regular'),
    ('Robert', 'Martinez', 'rmartinez@email.com', '215-555-1007', '147 Walnut St', 'Philadelphia', 'PA', '19101', 'US', '1982-04-18', '2023-03-20 13:45:00', 'Regular'),
    ('Ashley', 'Davis', 'ashley.d@email.com', '469-555-1008', '258 Elm St', 'Dallas', 'TX', '75201', 'US', '1991-12-05', '2023-04-01 09:00:00', 'Premium'),
    ('Christopher', 'Rodriguez', 'crodriguez@email.com', '619-555-1009', '369 Harbor Dr', 'San Diego', 'CA', '92101', 'US', '1986-08-21', '2023-04-15 15:30:00', 'Regular'),
    ('Amanda', 'Wilson', 'awilson@email.com', '206-555-1010', '741 Pike St', 'Seattle', 'WA', '98101', 'US', '1993-05-14', '2023-05-01 10:20:00', 'VIP'),
    ('Daniel', 'Anderson', 'danderson@email.com', '303-555-1011', '852 Colfax Ave', 'Denver', 'CO', '80201', 'US', '1980-10-30', '2023-05-15 14:00:00', 'Regular'),
    ('Stephanie', 'Thomas', 'sthomas@email.com', '617-555-1012', '963 Boylston St', 'Boston', 'MA', '02101', 'US', '1989-02-17', '2023-06-01 11:30:00', 'Premium'),
    ('Matthew', 'Taylor', 'mtaylor@email.com', '404-555-1013', '174 Ponce de Leon', 'Atlanta', 'GA', '30308', 'US', '1994-07-08', '2023-06-15 09:45:00', 'Regular'),
    ('Lauren', 'Moore', 'lmoore@email.com', '305-555-1014', '285 Ocean Dr', 'Miami', 'FL', '33139', 'US', '1987-11-23', '2023-07-01 16:15:00', 'Regular'),
    ('Andrew', 'Jackson', 'ajackson@email.com', '503-555-1015', '396 Burnside St', 'Portland', 'OR', '97201', 'US', '1996-03-05', '2023-07-15 08:30:00', 'Regular'),
    ('Rachel', 'Martin', 'rmartin@email.com', '615-555-1016', '507 Broadway', 'Nashville', 'TN', '37201', 'US', '1983-09-19', '2023-08-01 13:00:00', 'Premium'),
    ('Joshua', 'Lee', 'jlee@email.com', '512-555-1017', '618 Congress Ave', 'Austin', 'TX', '78701', 'US', '1991-06-28', '2023-08-15 10:45:00', 'Regular'),
    ('Megan', 'Hernandez', 'mhernandez@email.com', '702-555-1018', '729 Fremont St', 'Las Vegas', 'NV', '89101', 'US', '1997-01-14', '2023-09-01 15:20:00', 'Regular'),
    ('Ryan', 'King', 'rking@email.com', '704-555-1019', '840 Tryon St', 'Charlotte', 'NC', '28201', 'US', '1984-08-07', '2023-09-15 09:00:00', 'VIP'),
    ('Nicole', 'Wright', 'nwright@email.com', '614-555-1020', '951 High St', 'Columbus', 'OH', '43201', 'US', '1990-04-26', '2023-10-01 14:30:00', 'Regular'),
    ('Brandon', 'Lopez', 'blopez@email.com', '210-555-1021', '162 Riverwalk', 'San Antonio', 'TX', '78201', 'US', '1986-12-11', '2023-10-15 11:15:00', 'Regular'),
    ('Kayla', 'Hill', 'khill@email.com', '317-555-1022', '273 Meridian St', 'Indianapolis', 'IN', '46201', 'US', '1993-07-03', '2023-11-01 08:45:00', 'Premium'),
    ('Justin', 'Scott', 'jscott@email.com', '901-555-1023', '384 Beale St', 'Memphis', 'TN', '38101', 'US', '1981-05-20', '2023-11-15 16:00:00', 'Regular'),
    ('Brittany', 'Green', 'bgreen@email.com', '502-555-1024', '495 Bardstown Rd', 'Louisville', 'KY', '40201', 'US', '1998-10-09', '2023-12-01 10:30:00', 'Regular'),
    ('Tyler', 'Adams', 'tadams@email.com', '414-555-1025', '606 Water St', 'Milwaukee', 'WI', '53201', 'US', '1987-03-16', '2023-12-15 13:45:00', 'Regular'),
    ('Samantha', 'Baker', 'sbaker@email.com', '919-555-1026', '717 Fayetteville St', 'Raleigh', 'NC', '27601', 'US', '1994-08-25', '2024-01-05 09:15:00', 'Premium'),
    ('Kevin', 'Nelson', 'knelson@email.com', '801-555-1027', '828 State St', 'Salt Lake City', 'UT', '84101', 'US', '1979-06-02', '2024-01-20 14:45:00', 'Regular'),
    ('Christina', 'Carter', 'ccarter@email.com', '804-555-1028', '939 Broad St', 'Richmond', 'VA', '23219', 'US', '1992-11-18', '2024-02-01 11:00:00', 'Regular'),
    ('Jason', 'Mitchell', 'jmitchell@email.com', '816-555-1029', '150 Grand Blvd', 'Kansas City', 'MO', '64101', 'US', '1985-04-30', '2024-02-15 15:30:00', 'VIP'),
    ('Heather', 'Perez', 'hperez@email.com', '504-555-1030', '261 Bourbon St', 'New Orleans', 'LA', '70112', 'US', '1996-01-22', '2024-03-01 08:00:00', 'Regular'),
    ('Patrick', 'Roberts', 'proberts@email.com', '407-555-1031', '372 Orange Ave', 'Orlando', 'FL', '32801', 'US', '1988-09-08', '2024-03-15 12:30:00', 'Regular'),
    ('Amber', 'Turner', 'aturner@email.com', '612-555-1032', '483 Hennepin Ave', 'Minneapolis', 'MN', '55401', 'US', '1991-07-14', '2024-04-01 09:45:00', 'Premium'),
    ('Derek', 'Phillips', 'dphillips@email.com', '513-555-1033', '594 Vine St', 'Cincinnati', 'OH', '45201', 'US', '1983-02-27', '2024-04-15 14:15:00', 'Regular'),
    ('Natalie', 'Campbell', 'ncampbell@email.com', '412-555-1034', '705 Liberty Ave', 'Pittsburgh', 'PA', '15201', 'US', '1995-12-06', '2024-05-01 10:00:00', 'Regular'),
    ('Sean', 'Parker', 'sparker@email.com', '860-555-1035', '816 Main St', 'Hartford', 'CT', '06101', 'US', '1980-05-19', '2024-05-15 16:45:00', 'Regular'),
    ('Kimberly', 'Evans', 'kevans@email.com', '803-555-1036', '927 Gervais St', 'Columbia', 'SC', '29201', 'US', '1989-10-31', '2024-06-01 11:30:00', 'Regular'),
    ('Aaron', 'Edwards', 'aedwards@email.com', '205-555-1037', '138 20th St N', 'Birmingham', 'AL', '35201', 'US', '1997-03-13', '2024-06-15 08:15:00', 'Premium'),
    ('Courtney', 'Collins', 'ccollins@email.com', '401-555-1038', '249 Westminster St', 'Providence', 'RI', '02901', 'US', '1986-08-24', '2024-07-01 13:00:00', 'Regular'),
    ('Eric', 'Stewart', 'estewart@email.com', '402-555-1039', '360 Dodge St', 'Omaha', 'NE', '68101', 'US', '1993-06-07', '2024-07-15 15:45:00', 'Regular'),
    ('Michelle', 'Sanchez', 'msanchez@email.com', '505-555-1040', '471 Central Ave', 'Albuquerque', 'NM', '87101', 'US', '1984-11-29', '2024-08-01 09:30:00', 'Regular'),
    ('Travis', 'Morris', 'tmorris@email.com', '520-555-1041', '582 Congress St', 'Tucson', 'AZ', '85701', 'US', '1990-04-16', '2024-08-15 14:00:00', 'Regular'),
    ('Vanessa', 'Rogers', 'vrogers@email.com', '559-555-1042', '693 Fulton St', 'Fresno', 'CA', '93701', 'US', '1998-09-21', '2024-09-01 10:15:00', 'Regular'),
    ('Marcus', 'Reed', 'mreed@email.com', '916-555-1043', '804 K St', 'Sacramento', 'CA', '95814', 'US', '1982-01-08', '2024-09-15 16:30:00', 'Premium'),
    ('Tiffany', 'Cook', 'tcook@email.com', '808-555-1044', '915 Kalakaua Ave', 'Honolulu', 'HI', '96813', 'US', '1995-05-25', '2024-10-01 08:45:00', 'Regular'),
    ('Gregory', 'Morgan', 'gmorgan@email.com', '907-555-1045', '126 4th Ave', 'Anchorage', 'AK', '99501', 'US', '1987-10-12', '2024-10-15 13:15:00', 'Regular'),
    ('Rebecca', 'Bell', 'rbell@email.com', '571-555-1046', '237 King St', 'Alexandria', 'VA', '22314', 'US', '1994-02-03', '2024-11-01 11:45:00', 'Regular'),
    ('Nathan', 'Murphy', 'nmurphy@email.com', '207-555-1047', '348 Congress St', 'Portland', 'ME', '04101', 'US', '1981-07-17', '2024-11-15 09:00:00', 'Premium'),
    ('Hannah', 'Rivera', 'hrivera@email.com', '775-555-1048', '459 Virginia St', 'Reno', 'NV', '89501', 'US', '1996-12-28', '2024-12-01 14:30:00', 'Regular'),
    ('Wesley', 'Cooper', 'wcooper@email.com', '225-555-1049', '570 Third St', 'Baton Rouge', 'LA', '70801', 'US', '1989-04-09', '2024-12-15 10:00:00', 'Regular'),
    ('Alexis', 'Richardson', 'arichardson@email.com', '501-555-1050', '681 Main St', 'Little Rock', 'AR', '72201', 'US', '1992-08-14', '2025-01-05 15:15:00', 'Regular');

-- ============================================================================
-- ORDERS (100 representative orders)
-- ============================================================================

-- Generate orders across 2023-2025 with varied statuses, shipping, and payment
INSERT INTO orders (customer_id, employee_id, order_date, shipped_date, delivered_date, status, shipping_method, shipping_cost, payment_method, discount_amount) VALUES
    (1, 8, '2023-02-10 10:30:00', '2023-02-12 08:00:00', '2023-02-15 14:30:00', 'Delivered', 'Express', 12.99, 'Credit Card', 0.00),
    (2, 9, '2023-02-15 14:20:00', '2023-02-17 09:00:00', '2023-02-21 11:00:00', 'Delivered', 'Standard', 7.99, 'PayPal', 5.00),
    (3, 10, '2023-03-01 09:00:00', '2023-03-03 10:00:00', '2023-03-07 16:00:00', 'Delivered', 'Standard', 7.99, 'Credit Card', 10.00),
    (1, 8, '2023-03-20 11:45:00', '2023-03-22 08:30:00', '2023-03-25 13:00:00', 'Delivered', 'Express', 12.99, 'Credit Card', 0.00),
    (4, 11, '2023-04-05 16:30:00', '2023-04-07 09:00:00', '2023-04-11 15:30:00', 'Delivered', 'Standard', 7.99, 'Bank Transfer', 0.00),
    (5, 12, '2023-04-18 08:15:00', '2023-04-20 10:00:00', '2023-04-24 12:00:00', 'Delivered', 'Standard', 0.00, 'Credit Card', 15.00),
    (6, 13, '2023-05-02 13:00:00', '2023-05-04 08:00:00', '2023-05-08 17:00:00', 'Delivered', 'Free Shipping', 0.00, 'PayPal', 0.00),
    (7, 14, '2023-05-15 10:30:00', NULL, NULL, 'Cancelled', 'Standard', 7.99, 'Credit Card', 0.00),
    (3, 10, '2023-06-01 15:45:00', '2023-06-03 09:30:00', '2023-06-07 14:00:00', 'Delivered', 'Express', 12.99, 'Credit Card', 20.00),
    (8, 15, '2023-06-20 09:00:00', '2023-06-22 08:00:00', '2023-06-26 16:30:00', 'Delivered', 'Standard', 7.99, 'PayPal', 0.00),
    (10, 8, '2023-07-04 11:00:00', '2023-07-06 10:00:00', '2023-07-09 12:00:00', 'Delivered', 'Overnight', 24.99, 'Credit Card', 0.00),
    (9, 16, '2023-07-15 14:30:00', '2023-07-17 08:30:00', '2023-07-21 15:00:00', 'Delivered', 'Standard', 7.99, 'Bank Transfer', 5.00),
    (11, 17, '2023-08-01 08:45:00', '2023-08-03 09:00:00', '2023-08-07 13:00:00', 'Delivered', 'Standard', 7.99, 'Credit Card', 0.00),
    (12, 9, '2023-08-20 16:00:00', '2023-08-22 08:00:00', '2023-08-26 14:30:00', 'Delivered', 'Express', 12.99, 'Credit Card', 10.00),
    (1, 8, '2023-09-05 10:15:00', '2023-09-07 09:00:00', '2023-09-10 11:00:00', 'Delivered', 'Express', 12.99, 'Credit Card', 0.00),
    (13, 10, '2023-09-18 13:30:00', '2023-09-20 08:30:00', '2023-09-24 16:00:00', 'Delivered', 'Standard', 7.99, 'PayPal', 0.00),
    (14, 11, '2023-10-02 09:00:00', '2023-10-04 10:00:00', '2023-10-08 15:30:00', 'Delivered', 'Standard', 7.99, 'Credit Card', 5.00),
    (15, 12, '2023-10-15 15:45:00', NULL, NULL, 'Cancelled', 'Express', 12.99, 'PayPal', 0.00),
    (16, 13, '2023-10-28 11:30:00', '2023-10-30 08:00:00', '2023-11-02 14:00:00', 'Delivered', 'Standard', 0.00, 'Credit Card', 0.00),
    (5, 14, '2023-11-05 08:00:00', '2023-11-07 09:30:00', '2023-11-11 12:30:00', 'Delivered', 'Free Shipping', 0.00, 'Gift Card', 25.00),
    (17, 15, '2023-11-15 14:15:00', '2023-11-17 08:00:00', '2023-11-21 16:00:00', 'Delivered', 'Standard', 7.99, 'Credit Card', 0.00),
    (10, 8, '2023-11-24 06:00:00', '2023-11-25 09:00:00', '2023-11-28 11:00:00', 'Delivered', 'Overnight', 24.99, 'Credit Card', 50.00),
    (19, 16, '2023-12-01 10:30:00', '2023-12-03 08:00:00', '2023-12-06 14:00:00', 'Delivered', 'Express', 12.99, 'Credit Card', 0.00),
    (2, 9, '2023-12-10 13:45:00', '2023-12-12 09:00:00', '2023-12-16 15:30:00', 'Delivered', 'Standard', 7.99, 'PayPal', 10.00),
    (20, 17, '2023-12-18 16:00:00', '2023-12-20 10:00:00', '2023-12-23 12:00:00', 'Delivered', 'Express', 12.99, 'Credit Card', 0.00),
    (3, 10, '2023-12-22 09:15:00', '2023-12-23 08:00:00', '2023-12-27 14:30:00', 'Delivered', 'Overnight', 24.99, 'Credit Card', 30.00),
    (21, 11, '2024-01-05 11:00:00', '2024-01-07 09:00:00', '2024-01-11 16:00:00', 'Delivered', 'Standard', 7.99, 'Bank Transfer', 0.00),
    (22, 12, '2024-01-15 14:30:00', '2024-01-17 08:30:00', '2024-01-21 13:00:00', 'Delivered', 'Standard', 7.99, 'Credit Card', 5.00),
    (1, 8, '2024-01-28 08:45:00', '2024-01-30 09:00:00', '2024-02-02 15:00:00', 'Delivered', 'Express', 12.99, 'Credit Card', 0.00),
    (23, 13, '2024-02-05 10:00:00', NULL, NULL, 'Returned', 'Standard', 7.99, 'PayPal', 0.00),
    (24, 14, '2024-02-14 09:30:00', '2024-02-16 08:00:00', '2024-02-20 14:30:00', 'Delivered', 'Express', 12.99, 'Credit Card', 15.00),
    (10, 15, '2024-02-28 15:15:00', '2024-03-01 10:00:00', '2024-03-05 12:00:00', 'Delivered', 'Standard', 7.99, 'Credit Card', 0.00),
    (25, 16, '2024-03-10 11:30:00', '2024-03-12 08:00:00', '2024-03-16 16:30:00', 'Delivered', 'Standard', 0.00, 'Gift Card', 0.00),
    (26, 17, '2024-03-22 13:00:00', '2024-03-24 09:30:00', '2024-03-28 14:00:00', 'Delivered', 'Free Shipping', 0.00, 'Credit Card', 10.00),
    (5, 8, '2024-04-01 08:00:00', '2024-04-03 08:00:00', '2024-04-07 15:30:00', 'Delivered', 'Standard', 7.99, 'Credit Card', 0.00),
    (27, 9, '2024-04-15 16:45:00', '2024-04-17 09:00:00', '2024-04-21 11:00:00', 'Delivered', 'Standard', 7.99, 'PayPal', 0.00),
    (28, 10, '2024-04-28 10:30:00', '2024-04-30 10:00:00', '2024-05-04 13:00:00', 'Delivered', 'Standard', 7.99, 'Bank Transfer', 5.00),
    (29, 11, '2024-05-10 14:00:00', '2024-05-12 08:30:00', '2024-05-16 16:00:00', 'Delivered', 'Express', 12.99, 'Credit Card', 0.00),
    (19, 12, '2024-05-20 09:15:00', '2024-05-22 09:00:00', '2024-05-26 14:30:00', 'Delivered', 'Standard', 7.99, 'Credit Card', 20.00),
    (30, 13, '2024-06-01 11:45:00', '2024-06-03 08:00:00', '2024-06-07 12:00:00', 'Delivered', 'Standard', 0.00, 'PayPal', 0.00),
    (31, 14, '2024-06-15 15:30:00', '2024-06-17 10:00:00', '2024-06-21 15:30:00', 'Delivered', 'Free Shipping', 0.00, 'Credit Card', 0.00),
    (8, 15, '2024-06-28 08:30:00', '2024-06-30 08:30:00', '2024-07-03 11:00:00', 'Delivered', 'Standard', 7.99, 'Credit Card', 10.00),
    (32, 16, '2024-07-10 13:15:00', '2024-07-12 09:00:00', '2024-07-16 16:00:00', 'Delivered', 'Standard', 7.99, 'PayPal', 0.00),
    (33, 17, '2024-07-22 10:00:00', NULL, NULL, 'Cancelled', 'Express', 12.99, 'Credit Card', 0.00),
    (34, 8, '2024-08-01 16:30:00', '2024-08-03 08:00:00', '2024-08-07 14:30:00', 'Delivered', 'Standard', 7.99, 'Bank Transfer', 0.00),
    (1, 9, '2024-08-15 09:45:00', '2024-08-17 09:30:00', '2024-08-20 12:00:00', 'Delivered', 'Overnight', 24.99, 'Credit Card', 0.00),
    (35, 10, '2024-08-28 14:00:00', '2024-08-30 08:00:00', '2024-09-03 15:00:00', 'Delivered', 'Standard', 7.99, 'Credit Card', 5.00),
    (36, 11, '2024-09-05 11:30:00', '2024-09-07 10:00:00', '2024-09-11 13:30:00', 'Delivered', 'Standard', 7.99, 'PayPal', 0.00),
    (37, 12, '2024-09-18 08:15:00', '2024-09-20 08:00:00', '2024-09-24 16:00:00', 'Delivered', 'Express', 12.99, 'Credit Card', 15.00),
    (10, 13, '2024-10-01 15:00:00', '2024-10-03 09:30:00', '2024-10-07 14:00:00', 'Delivered', 'Standard', 7.99, 'Credit Card', 0.00),
    (38, 14, '2024-10-12 10:45:00', '2024-10-14 08:00:00', '2024-10-18 12:30:00', 'Delivered', 'Standard', 0.00, 'Gift Card', 0.00),
    (39, 15, '2024-10-25 13:30:00', '2024-10-27 09:00:00', '2024-10-31 15:00:00', 'Delivered', 'Free Shipping', 0.00, 'PayPal', 0.00),
    (40, 16, '2024-11-01 09:00:00', '2024-11-03 10:00:00', '2024-11-07 11:00:00', 'Delivered', 'Standard', 7.99, 'Credit Card', 0.00),
    (3, 17, '2024-11-10 16:15:00', '2024-11-12 08:00:00', '2024-11-15 14:30:00', 'Delivered', 'Express', 12.99, 'Credit Card', 25.00),
    (41, 8, '2024-11-20 11:00:00', '2024-11-22 09:30:00', '2024-11-26 16:00:00', 'Delivered', 'Standard', 7.99, 'Bank Transfer', 0.00),
    (42, 9, '2024-11-25 07:00:00', '2024-11-26 08:00:00', '2024-11-29 12:00:00', 'Delivered', 'Overnight', 24.99, 'Credit Card', 40.00),
    (12, 10, '2024-11-29 14:45:00', '2024-12-01 10:00:00', '2024-12-05 13:00:00', 'Delivered', 'Standard', 7.99, 'PayPal', 20.00),
    (43, 11, '2024-12-05 10:30:00', '2024-12-07 08:00:00', '2024-12-11 15:30:00', 'Delivered', 'Standard', 7.99, 'Credit Card', 0.00),
    (44, 12, '2024-12-10 13:00:00', '2024-12-12 09:00:00', '2024-12-16 14:00:00', 'Delivered', 'Express', 12.99, 'Credit Card', 10.00),
    (29, 13, '2024-12-15 08:45:00', '2024-12-17 10:00:00', '2024-12-20 11:00:00', 'Delivered', 'Express', 12.99, 'Credit Card', 0.00),
    (19, 14, '2024-12-18 15:30:00', '2024-12-20 08:30:00', '2024-12-23 16:30:00', 'Delivered', 'Standard', 7.99, 'PayPal', 15.00),
    (45, 15, '2024-12-22 09:00:00', '2024-12-23 08:00:00', '2024-12-27 14:00:00', 'Delivered', 'Overnight', 24.99, 'Credit Card', 0.00),
    (1, 8, '2025-01-05 11:15:00', '2025-01-07 09:00:00', '2025-01-10 13:00:00', 'Delivered', 'Express', 12.99, 'Credit Card', 0.00),
    (46, 16, '2025-01-12 14:30:00', '2025-01-14 08:00:00', '2025-01-18 15:30:00', 'Delivered', 'Standard', 7.99, 'Credit Card', 5.00),
    (47, 17, '2025-01-20 10:00:00', '2025-01-22 10:00:00', '2025-01-26 12:00:00', 'Delivered', 'Standard', 7.99, 'Bank Transfer', 0.00),
    (2, 9, '2025-01-28 16:45:00', '2025-01-30 08:30:00', '2025-02-03 14:00:00', 'Delivered', 'Standard', 0.00, 'PayPal', 0.00),
    (48, 10, '2025-02-05 08:30:00', '2025-02-07 09:00:00', '2025-02-11 16:30:00', 'Delivered', 'Free Shipping', 0.00, 'Credit Card', 0.00),
    (49, 11, '2025-02-12 13:15:00', '2025-02-14 08:00:00', '2025-02-18 13:00:00', 'Delivered', 'Standard', 7.99, 'PayPal', 10.00),
    (50, 12, '2025-02-20 11:00:00', '2025-02-22 10:00:00', '2025-02-26 15:00:00', 'Delivered', 'Standard', 7.99, 'Credit Card', 0.00),
    (10, 8, '2025-02-28 09:30:00', '2025-03-02 08:00:00', '2025-03-05 14:30:00', 'Delivered', 'Express', 12.99, 'Credit Card', 0.00),
    (5, 13, '2025-03-05 15:00:00', '2025-03-07 09:30:00', '2025-03-11 12:00:00', 'Delivered', 'Standard', 7.99, 'Credit Card', 20.00),
    (26, 14, '2025-03-12 10:45:00', '2025-03-14 08:00:00', NULL, 'Shipped', 'Standard', 7.99, 'Gift Card', 0.00),
    (8, 15, '2025-03-18 14:00:00', '2025-03-20 10:00:00', NULL, 'Shipped', 'Express', 12.99, 'Credit Card', 5.00),
    (16, 16, '2025-03-22 08:30:00', NULL, NULL, 'Processing', 'Standard', 7.99, 'PayPal', 0.00),
    (29, 17, '2025-03-25 16:15:00', NULL, NULL, 'Processing', 'Express', 12.99, 'Credit Card', 0.00),
    (37, 8, '2025-03-28 11:30:00', NULL, NULL, 'Pending', 'Standard', 7.99, 'Credit Card', 10.00),
    -- Additional holiday season orders (Q4 bulk)
    (1, 9, '2023-11-25 08:00:00', '2023-11-27 09:00:00', '2023-11-30 14:00:00', 'Delivered', 'Overnight', 24.99, 'Credit Card', 30.00),
    (3, 10, '2023-11-28 10:00:00', '2023-11-29 08:00:00', '2023-12-02 12:00:00', 'Delivered', 'Express', 12.99, 'Credit Card', 15.00),
    (10, 11, '2023-12-01 09:15:00', '2023-12-03 10:00:00', '2023-12-06 16:00:00', 'Delivered', 'Standard', 7.99, 'PayPal', 0.00),
    (5, 12, '2023-12-05 14:30:00', '2023-12-07 08:00:00', '2023-12-11 13:00:00', 'Delivered', 'Standard', 0.00, 'Credit Card', 20.00),
    (19, 13, '2023-12-08 11:00:00', '2023-12-10 09:30:00', '2023-12-14 15:30:00', 'Delivered', 'Free Shipping', 0.00, 'Gift Card', 0.00),
    (12, 14, '2023-12-12 16:45:00', '2023-12-14 08:00:00', '2023-12-18 14:00:00', 'Delivered', 'Express', 12.99, 'Credit Card', 25.00),
    (8, 15, '2023-12-15 08:30:00', '2023-12-16 10:00:00', '2023-12-19 11:30:00', 'Delivered', 'Overnight', 24.99, 'Credit Card', 0.00),
    (22, 16, '2024-11-22 07:30:00', '2024-11-23 08:00:00', '2024-11-26 14:00:00', 'Delivered', 'Overnight', 24.99, 'Credit Card', 35.00),
    (16, 17, '2024-11-25 10:00:00', '2024-11-27 09:00:00', '2024-12-01 16:00:00', 'Delivered', 'Standard', 7.99, 'PayPal', 10.00),
    (26, 8, '2024-11-28 13:15:00', '2024-11-29 08:30:00', '2024-12-02 12:00:00', 'Delivered', 'Express', 12.99, 'Credit Card', 0.00),
    (37, 9, '2024-12-01 09:00:00', '2024-12-03 10:00:00', '2024-12-07 15:00:00', 'Delivered', 'Standard', 7.99, 'Bank Transfer', 15.00),
    (43, 10, '2024-12-08 15:30:00', '2024-12-10 08:00:00', '2024-12-14 14:30:00', 'Delivered', 'Standard', 0.00, 'Credit Card', 0.00),
    (29, 11, '2024-12-12 11:45:00', '2024-12-14 09:00:00', '2024-12-18 13:00:00', 'Delivered', 'Free Shipping', 0.00, 'PayPal', 20.00),
    (47, 12, '2024-12-16 08:00:00', '2024-12-17 08:00:00', '2024-12-20 16:30:00', 'Delivered', 'Overnight', 24.99, 'Credit Card', 0.00),
    (50, 13, '2024-12-20 14:00:00', '2024-12-22 10:00:00', '2024-12-26 11:00:00', 'Delivered', 'Standard', 7.99, 'Credit Card', 5.00),
    -- Additional orders for volume
    (4, 14, '2023-07-10 10:00:00', '2023-07-12 08:00:00', '2023-07-16 14:00:00', 'Delivered', 'Standard', 7.99, 'Credit Card', 0.00),
    (6, 15, '2023-08-15 13:30:00', '2023-08-17 09:00:00', '2023-08-21 15:30:00', 'Delivered', 'Standard', 7.99, 'PayPal', 5.00),
    (9, 16, '2023-09-20 11:15:00', '2023-09-22 10:00:00', '2023-09-26 12:00:00', 'Delivered', 'Express', 12.99, 'Credit Card', 0.00),
    (11, 17, '2023-10-25 08:45:00', '2023-10-27 08:00:00', '2023-10-31 16:00:00', 'Delivered', 'Standard', 7.99, 'Bank Transfer', 10.00),
    (14, 8, '2024-01-10 14:00:00', '2024-01-12 09:30:00', '2024-01-16 13:30:00', 'Delivered', 'Standard', 0.00, 'Credit Card', 0.00),
    (16, 9, '2024-02-20 10:30:00', '2024-02-22 08:00:00', '2024-02-26 15:00:00', 'Delivered', 'Free Shipping', 0.00, 'PayPal', 0.00),
    (18, 10, '2024-03-15 15:45:00', '2024-03-17 10:00:00', '2024-03-21 14:00:00', 'Delivered', 'Standard', 7.99, 'Credit Card', 5.00),
    (20, 11, '2024-05-01 09:00:00', '2024-05-03 08:30:00', '2024-05-07 16:30:00', 'Delivered', 'Standard', 7.99, 'Credit Card', 0.00);

-- ============================================================================
-- ORDER_ITEMS (~300 line items across the 100 orders)
-- Average 3 items per order for realistic distribution
-- ============================================================================
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_percent) VALUES
    -- Order 1: John Smith - Electronics
    (1, 1, 1, 899.99, 0.00),   -- ProBook 15 Laptop
    (1, 44, 1, 49.99, 0.00),   -- USB-C Hub
    (1, 9, 1, 349.99, 5.00),   -- StudioMax Headphones
    -- Order 2: Emily Johnson
    (2, 17, 1, 89.99, 0.00),   -- BrewMaster Coffee Maker
    (2, 15, 2, 34.99, 0.00),   -- Non-Stick Frying Pan
    -- Order 3: Michael Williams
    (3, 5, 1, 1199.99, 0.00),  -- Galaxy S24 Ultra
    (3, 38, 1, 29.99, 0.00),   -- Wireless Charging Pad
    (3, 46, 1, 59.99, 10.00),  -- Portable Power Bank
    -- Order 4: John Smith again
    (4, 18, 1, 119.99, 0.00),  -- AirFry Pro
    (4, 41, 1, 29.99, 0.00),   -- Bamboo Cutting Board
    -- Order 5: Sarah Brown
    (5, 28, 2, 54.99, 0.00),   -- Yoga Leggings
    (5, 27, 1, 44.99, 0.00),   -- Linen Blouse
    (5, 31, 1, 119.99, 15.00), -- Trail Running Shoes
    -- Order 6: David Jones
    (6, 4, 1, 1799.99, 5.00),  -- GameForce 17 Pro
    (6, 44, 1, 49.99, 0.00),   -- USB-C Hub
    -- Order 7: Jessica Garcia
    (7, 33, 1, 39.99, 0.00),   -- Yoga Mat
    (7, 34, 1, 24.99, 0.00),   -- Resistance Bands
    (7, 42, 1, 24.99, 0.00),   -- Water Bottle
    -- Order 8: Robert Martinez (Cancelled)
    (8, 22, 2, 49.99, 0.00),   -- Oxford Shirt
    -- Order 9: Michael Williams
    (9, 2, 1, 649.99, 0.00),   -- UltraSlim 13
    (9, 11, 1, 199.99, 10.00), -- EarPod Pro
    -- Order 10: Ashley Davis
    (10, 13, 1, 189.99, 0.00), -- Cookware Set
    (10, 16, 1, 129.99, 0.00), -- Knife Block
    (10, 47, 1, 24.99, 0.00),  -- French Press
    -- Order 11: Amanda Wilson
    (11, 6, 1, 999.99, 0.00),  -- iPhone 15 Pro
    (11, 38, 1, 29.99, 0.00),  -- Wireless Charging Pad
    -- Order 12: Christopher Rodriguez
    (12, 23, 1, 59.99, 0.00),  -- Slim Chino Pants
    (12, 22, 1, 49.99, 0.00),  -- Oxford Shirt
    (12, 26, 1, 34.99, 0.00),  -- Running Shorts
    -- Order 13: Daniel Anderson
    (13, 19, 1, 74.99, 0.00),  -- BlendForce Blender
    (13, 50, 1, 19.99, 0.00),  -- Kitchen Scale
    -- Order 14: Stephanie Thomas
    (14, 29, 1, 89.99, 0.00),  -- Puffer Vest
    (14, 30, 1, 69.99, 5.00),  -- Denim Jacket
    -- Order 15: John Smith
    (15, 39, 1, 129.99, 0.00), -- Smart Home Hub
    (15, 40, 2, 44.99, 0.00),  -- LED Desk Lamp
    -- Order 16: Matthew Taylor
    (16, 10, 1, 79.99, 0.00),  -- BassWave Speaker
    (16, 34, 1, 24.99, 0.00),  -- Resistance Bands
    -- Order 17: Lauren Moore
    (17, 27, 2, 44.99, 0.00),  -- Linen Blouse x2
    (17, 28, 1, 54.99, 10.00), -- Yoga Leggings
    -- Order 18: Andrew Jackson (Cancelled)
    (18, 32, 1, 349.99, 0.00), -- Adjustable Dumbbells
    -- Order 19: Rachel Martin
    (19, 20, 1, 99.99, 0.00),  -- Instant Pot
    (19, 14, 1, 69.99, 0.00),  -- Dutch Oven
    (19, 47, 1, 24.99, 0.00),  -- French Press
    -- Order 20: David Jones
    (20, 7, 1, 499.99, 0.00),  -- Pixel 8a
    (20, 43, 1, 59.99, 15.00), -- Fitness Tracker
    -- Orders 21-30
    (21, 3, 1, 249.99, 0.00),  -- ChromeBook Lite
    (21, 44, 1, 49.99, 0.00),  -- USB-C Hub
    (22, 1, 1, 899.99, 10.00), -- ProBook Laptop (Black Friday)
    (22, 9, 1, 349.99, 15.00), -- StudioMax Headphones
    (22, 38, 2, 29.99, 0.00),  -- Wireless Charging Pad x2
    (23, 24, 1, 79.99, 0.00),  -- Merino Sweater
    (23, 25, 1, 149.99, 0.00), -- Shell Jacket
    (24, 13, 1, 189.99, 0.00), -- Cookware Set
    (24, 15, 1, 34.99, 0.00),  -- Frying Pan
    (25, 45, 1, 299.99, 0.00), -- Office Chair
    (25, 40, 1, 44.99, 0.00),  -- LED Desk Lamp
    (26, 4, 1, 1799.99, 8.00), -- GameForce (holiday discount)
    (26, 11, 2, 199.99, 5.00), -- EarPod Pro x2
    (26, 44, 1, 49.99, 0.00),  -- USB-C Hub
    -- Orders 27-40
    (27, 22, 3, 49.99, 0.00),  -- Oxford Shirt x3
    (28, 43, 1, 59.99, 0.00),  -- Fitness Tracker
    (28, 33, 1, 39.99, 0.00),  -- Yoga Mat
    (29, 6, 1, 999.99, 0.00),  -- iPhone 15 Pro
    (29, 11, 1, 199.99, 0.00), -- EarPod Pro
    (29, 46, 1, 59.99, 0.00),  -- Power Bank
    (30, 21, 1, 64.99, 0.00),  -- Toaster Oven (Returned)
    (31, 28, 1, 54.99, 0.00),  -- Yoga Leggings
    (31, 31, 1, 119.99, 0.00), -- Trail Running Shoes
    (32, 39, 1, 129.99, 0.00), -- Smart Home Hub
    (32, 10, 2, 79.99, 0.00),  -- BassWave Speaker x2
    (33, 48, 1, 49.99, 0.00),  -- Insulated Cooler
    (33, 49, 2, 34.99, 0.00),  -- Camping Hammock x2
    (34, 17, 1, 89.99, 0.00),  -- Coffee Maker
    (34, 50, 1, 19.99, 0.00),  -- Kitchen Scale
    (35, 7, 1, 499.99, 0.00),  -- Pixel 8a
    (35, 38, 1, 29.99, 0.00),  -- Wireless Charging Pad
    (36, 12, 1, 229.99, 0.00), -- Vinyl Turntable
    (37, 45, 1, 299.99, 0.00), -- Office Chair
    (37, 40, 1, 44.99, 0.00),  -- LED Desk Lamp
    (38, 2, 1, 649.99, 0.00),  -- UltraSlim 13
    (39, 20, 1, 99.99, 0.00),  -- Instant Pot
    (39, 18, 1, 119.99, 0.00), -- AirFry Pro
    (40, 35, 1, 599.99, 0.00), -- Folding Treadmill
    (40, 33, 1, 39.99, 0.00),  -- Yoga Mat
    -- Orders 41-60
    (41, 8, 2, 149.99, 0.00),  -- BudgetCall x2
    (42, 14, 1, 69.99, 0.00),  -- Dutch Oven
    (42, 41, 1, 29.99, 0.00),  -- Bamboo Cutting Board
    (42, 19, 1, 74.99, 0.00),  -- BlendForce Blender
    (43, 23, 2, 59.99, 0.00),  -- Slim Chinos x2 (Cancelled)
    (44, 36, 2, 19.99, 0.00),  -- Exercise Ball x2
    (44, 37, 1, 29.99, 0.00),  -- Pull-Up Bar
    (45, 25, 1, 149.99, 0.00), -- Shell Jacket
    (45, 24, 1, 79.99, 0.00),  -- Merino Sweater
    (46, 5, 1, 1199.99, 0.00), -- Galaxy S24 Ultra
    (46, 46, 1, 59.99, 0.00),  -- Power Bank
    (47, 16, 1, 129.99, 0.00), -- Knife Block
    (47, 15, 2, 34.99, 0.00),  -- Frying Pan x2
    (48, 30, 1, 69.99, 0.00),  -- Denim Jacket
    (48, 27, 1, 44.99, 0.00),  -- Linen Blouse
    (49, 9, 1, 349.99, 8.00),  -- StudioMax Headphones
    (49, 10, 1, 79.99, 0.00),  -- BassWave Speaker
    (50, 32, 1, 349.99, 0.00), -- Adjustable Dumbbells
    (50, 42, 2, 24.99, 0.00),  -- Water Bottle x2
    (51, 17, 1, 89.99, 0.00),  -- Coffee Maker
    (52, 3, 1, 249.99, 0.00),  -- ChromeBook Lite
    (53, 22, 1, 49.99, 0.00),  -- Oxford Shirt
    (53, 26, 2, 34.99, 0.00),  -- Running Shorts x2
    (54, 1, 1, 899.99, 5.00),  -- ProBook Laptop
    (54, 44, 2, 49.99, 0.00),  -- USB-C Hub x2
    (55, 34, 3, 24.99, 0.00),  -- Resistance Bands x3
    (55, 36, 1, 19.99, 0.00),  -- Exercise Ball
    (56, 6, 1, 999.99, 8.00),  -- iPhone 15 Pro (BF discount)
    (56, 11, 1, 199.99, 10.00),-- EarPod Pro
    (57, 13, 1, 189.99, 10.00),-- Cookware Set
    (57, 14, 1, 69.99, 0.00),  -- Dutch Oven
    (57, 47, 2, 24.99, 0.00),  -- French Press x2
    (58, 43, 2, 59.99, 0.00),  -- Fitness Tracker x2
    (59, 29, 1, 89.99, 0.00),  -- Puffer Vest
    (59, 31, 1, 119.99, 5.00), -- Trail Running Shoes
    (60, 35, 1, 599.99, 10.00),-- Folding Treadmill
    (60, 37, 2, 29.99, 0.00),  -- Pull-Up Bar x2
    -- Orders 61-76 (additional Q4 orders)
    (61, 39, 1, 129.99, 0.00), -- Smart Home Hub
    (61, 40, 1, 44.99, 0.00),  -- LED Desk Lamp
    (62, 21, 2, 64.99, 0.00),  -- Toaster Oven x2
    (63, 48, 1, 49.99, 0.00),  -- Insulated Cooler
    (63, 42, 3, 24.99, 0.00),  -- Water Bottle x3
    -- Orders 64-70 (holiday volume)
    (64, 18, 1, 119.99, 0.00), -- AirFry Pro
    (64, 50, 1, 19.99, 0.00),  -- Kitchen Scale
    (65, 12, 1, 229.99, 0.00), -- Vinyl Turntable
    (66, 45, 1, 299.99, 5.00), -- Office Chair (holiday sale)
    (66, 39, 1, 129.99, 0.00), -- Smart Home Hub
    (67, 9, 1, 349.99, 10.00), -- StudioMax Headphones
    (67, 11, 1, 199.99, 10.00),-- EarPod Pro
    (68, 15, 3, 34.99, 0.00),  -- Frying Pan x3
    (68, 16, 1, 129.99, 0.00), -- Knife Block Set
    (69, 4, 1, 1799.99, 10.00),-- GameForce 17 Pro (holiday)
    (69, 44, 2, 49.99, 0.00),  -- USB-C Hub x2
    (70, 7, 2, 499.99, 5.00),  -- Pixel 8a x2
    (70, 46, 2, 59.99, 0.00),  -- Power Bank x2
    -- Orders 71-76
    (71, 25, 1, 149.99, 0.00), -- Shell Jacket
    (71, 22, 2, 49.99, 0.00),  -- Oxford Shirt x2
    (72, 32, 1, 349.99, 0.00), -- Adjustable Dumbbells
    (72, 33, 1, 39.99, 0.00),  -- Yoga Mat
    (73, 28, 2, 54.99, 0.00),  -- Yoga Leggings x2
    (73, 31, 1, 119.99, 0.00), -- Trail Running Shoes
    (74, 20, 1, 99.99, 0.00),  -- Instant Pot
    (74, 17, 1, 89.99, 0.00),  -- Coffee Maker
    (75, 1, 1, 899.99, 0.00),  -- ProBook 15 Laptop
    (75, 9, 1, 349.99, 0.00),  -- StudioMax Headphones
    (76, 5, 1, 1199.99, 5.00), -- Galaxy S24 Ultra
    (76, 38, 1, 29.99, 0.00),  -- Wireless Charging Pad
    -- Orders 77-83
    (77, 23, 1, 59.99, 0.00),  -- Slim Chinos
    (77, 24, 1, 79.99, 0.00),  -- Merino Sweater
    (78, 8, 1, 149.99, 0.00),  -- BudgetCall X1
    (78, 46, 1, 59.99, 0.00),  -- Power Bank
    (79, 48, 2, 49.99, 0.00),  -- Insulated Cooler x2
    (79, 49, 1, 34.99, 0.00),  -- Camping Hammock
    (80, 19, 1, 74.99, 0.00),  -- BlendForce Blender
    (80, 50, 1, 19.99, 0.00),  -- Kitchen Scale
    (81, 30, 2, 69.99, 0.00),  -- Denim Jacket x2
    (82, 36, 3, 19.99, 0.00),  -- Exercise Ball x3
    (82, 37, 1, 29.99, 0.00),  -- Pull-Up Bar
    (83, 10, 1, 79.99, 0.00),  -- BassWave Speaker
    (83, 12, 1, 229.99, 5.00), -- Vinyl Turntable
    -- Orders 84-93
    (84, 6, 1, 999.99, 0.00),  -- iPhone 15 Pro
    (84, 11, 1, 199.99, 0.00), -- EarPod Pro
    (85, 14, 2, 69.99, 0.00),  -- Dutch Oven x2
    (85, 41, 1, 29.99, 0.00),  -- Bamboo Cutting Board
    (86, 2, 1, 649.99, 0.00),  -- UltraSlim 13
    (87, 29, 1, 89.99, 0.00),  -- Puffer Vest
    (87, 27, 2, 44.99, 0.00),  -- Linen Blouse x2
    (88, 35, 1, 599.99, 5.00), -- Folding Treadmill
    (88, 42, 1, 24.99, 0.00),  -- Water Bottle
    (89, 3, 2, 249.99, 0.00),  -- ChromeBook x2
    (90, 13, 1, 189.99, 0.00), -- Cookware Set
    (90, 47, 1, 24.99, 0.00),  -- French Press
    (91, 43, 1, 59.99, 0.00),  -- Fitness Tracker
    (91, 34, 2, 24.99, 0.00),  -- Resistance Bands x2
    (92, 45, 1, 299.99, 0.00), -- Office Chair
    (93, 1, 1, 899.99, 0.00),  -- ProBook 15 Laptop
    (93, 38, 1, 29.99, 0.00),  -- Wireless Charging Pad
    (93, 44, 1, 49.99, 0.00);  -- USB-C Hub

-- ============================================================================
-- INVENTORY (50 records, one per product)
-- ============================================================================
INSERT INTO inventory (product_id, quantity_on_hand, reorder_level, reorder_quantity, warehouse_location, last_restock_date) VALUES
    (1, 45, 15, 30, 'A-01-01', '2025-03-01'),
    (2, 62, 20, 40, 'A-01-02', '2025-02-15'),
    (3, 85, 25, 50, 'A-01-03', '2025-03-10'),
    (4, 18, 10, 20, 'A-01-04', '2025-02-20'),
    (5, 30, 15, 25, 'A-02-01', '2025-03-05'),
    (6, 25, 15, 25, 'A-02-02', '2025-03-08'),
    (7, 55, 20, 40, 'A-02-03', '2025-02-28'),
    (8, 120, 30, 60, 'A-02-04', '2025-03-12'),
    (9, 38, 15, 30, 'A-03-01', '2025-03-01'),
    (10, 95, 25, 50, 'A-03-02', '2025-02-25'),
    (11, 42, 20, 40, 'A-03-03', '2025-03-10'),
    (12, 22, 10, 20, 'A-03-04', '2025-02-18'),
    (13, 35, 10, 25, 'B-01-01', '2025-03-05'),
    (14, 70, 20, 40, 'B-01-02', '2025-02-22'),
    (15, 110, 30, 60, 'B-01-03', '2025-03-08'),
    (16, 28, 10, 20, 'B-01-04', '2025-03-01'),
    (17, 55, 15, 30, 'B-02-01', '2025-02-28'),
    (18, 40, 15, 30, 'B-02-02', '2025-03-12'),
    (19, 65, 20, 40, 'B-02-03', '2025-02-20'),
    (20, 48, 15, 30, 'B-02-04', '2025-03-05'),
    (21, 60, 20, 40, 'B-03-01', '2025-02-15'),
    (22, 90, 25, 50, 'C-01-01', '2025-03-10'),
    (23, 75, 20, 40, 'C-01-02', '2025-03-01'),
    (24, 45, 15, 30, 'C-01-03', '2025-02-25'),
    (25, 30, 10, 25, 'C-01-04', '2025-03-08'),
    (26, 100, 30, 60, 'C-02-01', '2025-02-28'),
    (27, 80, 25, 50, 'C-02-02', '2025-03-05'),
    (28, 68, 20, 40, 'C-02-03', '2025-03-12'),
    (29, 35, 10, 25, 'C-02-04', '2025-02-22'),
    (30, 50, 15, 30, 'C-03-01', '2025-03-01'),
    (31, 42, 15, 30, 'C-03-02', '2025-02-18'),
    (32, 15, 10, 20, 'D-01-01', '2025-03-08'),
    (33, 85, 25, 50, 'D-01-02', '2025-03-10'),
    (34, 130, 30, 60, 'D-01-03', '2025-02-28'),
    (35, 8, 5, 10, 'D-01-04', '2025-02-10'),
    (36, 95, 25, 50, 'D-02-01', '2025-03-05'),
    (37, 60, 20, 40, 'D-02-02', '2025-03-01'),
    (38, 72, 20, 40, 'A-04-01', '2025-03-12'),
    (39, 25, 10, 20, 'A-04-02', '2025-02-25'),
    (40, 55, 15, 30, 'B-04-01', '2025-03-08'),
    (41, 90, 25, 50, 'B-04-02', '2025-02-28'),
    (42, 105, 30, 60, 'D-03-01', '2025-03-10'),
    (43, 40, 15, 30, 'D-03-02', '2025-03-01'),
    (44, 58, 20, 40, 'A-04-03', '2025-02-22'),
    (45, 12, 10, 15, 'B-04-03', '2025-03-05'),
    (46, 65, 20, 40, 'A-04-04', '2025-03-12'),
    (47, 78, 20, 40, 'B-04-04', '2025-02-28'),
    (48, 45, 15, 30, 'D-04-01', '2025-03-01'),
    (49, 55, 15, 30, 'D-04-02', '2025-02-20'),
    (50, 88, 25, 50, 'B-04-05', '2025-03-10');

-- ============================================================================
-- Data load complete. Run verification:
-- ============================================================================
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'inventory', COUNT(*) FROM inventory
ORDER BY table_name;
