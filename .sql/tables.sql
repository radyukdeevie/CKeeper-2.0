DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

DROP USER IF EXISTS administrator, waiter, kitchen_bar;

--CREATE USER administrator WITH PASSWORD 'admin123';
--CREATE USER waiter WITH PASSWORD 'waiter123';
--CREATE USER kitchen_bar WITH PASSWORD 'kitchen_bar123';
--GRANT CONNECT ON DATABASE CKeeper TO administrator;
--GRANT CONNECT ON DATABASE CKeeper TO waiter;
--GRANT CONNECT ON DATABASE CKeeper TO kitch en_bar;
--GRANT SELECT, UPDATE, INSERT ON TABLE employee, employee_code, employee_pass, job_employee, product,
--	product_status, type_product, photo_tables TO administrator;
--GRANT SELECT ON TABLE cafe_table, active_order, history_order, history_list_order, photo_tables, status TO administrator;
--GRANT EXECUTE ON FUNCTION create_order(INTEGER, INTEGER, INTEGER[], INTEGER[], VARCHAR[]) TO administrator, waiter;
--GRANT EXECUTE ON FUNCTION get_list_order(INTEGER) TO administrator, waiter;
--GRANT EXECUTE ON FUNCTION delete_order(INTEGER, INTEGER) TO administrator;
--GRANT EXECUTE ON FUNCTION change_of_product_status(INTEGER, INTEGER, INTEGER) TO administrator, kitchen_bar;
--GRANT EXECUTE ON FUNCTION get_check(INTEGER) TO administrator, waiter;
--GRANT EXECUTE ON FUNCTION get_full_price(INTEGER) TO administrator, waiter;
--GRANT EXECUTE ON FUNCTION close_order(INTEGERM INTEGER) TO administrator, waiter;


CREATE DOMAIN phone_number AS VARCHAR
CHECK (
    VALUE ~ '^\+375(25|29|33|44)\d{7}$'
);

CREATE DOMAIN email_address AS VARCHAR
CHECK (
    VALUE ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
);

CREATE TABLE job_employee(
	job_employee_id serial PRIMARY KEY NOT NULL,
	job_employee_name VARCHAR(256)
);
CREATE TABLE employee(
	employee_id serial PRIMARY KEY NOT NULL,
	employee_last_name VARCHAR(100),
	employee_name VARCHAR(100),
	employee_second_name VARCHAR(100),
	job_employee_id INTEGER,
	employee_phone phone_number,
	employee_email email_address,
	employee_photo VARCHAR(256) DEFAULT 'not_path_to_photo',

	FOREIGN KEY (job_employee_id) REFERENCES job_employee
);

CREATE TABLE employee_pass(
	employee_pass_id serial PRIMARY KEY NOT NULL,
	employee_pass_num VARCHAR(50),
	employee_pass_issued_by VARCHAR(256),
	employee_pass_issue_date DATE,
	employee_pass_expiry_date DATE,

	FOREIGN KEY (employee_pass_id) REFERENCES employee(employee_id),
	CONSTRAINT CHK_employee_pass_num CHECK (LEFT(employee_pass_num, 2) IN ('AB', 'AL', 'AH', 'Z', 'J'))
);

CREATE TABLE employee_code(
	employee_code_id serial PRIMARY KEY NOT NULL,
	employee_id INTEGER,
	employee_code VARCHAR(256) DEFAULT 'qwerty',

	CONSTRAINT CHK_employee_password CHECK (char_length(employee_code) <= 256),
	FOREIGN KEY (employee_id) REFERENCES employee
);

CREATE TABLE status(
	status_id serial PRIMARY KEY NOT NULL,
	status_name VARCHAR(256)
);

CREATE TABLE cafe_table(
	table_id serial PRIMARY KEY NOT NULL,
	table_seats INTEGER,
	status_id INTEGER DEFAULT 1,
	table_description TEXT DEFAULT '-',

	FOREIGN KEY (status_id) REFERENCES status
);

CREATE TABLE type_product(
	type_product_id serial PRIMARY KEY NOT NULL,
	type_product_name VARCHAR(256)
);

CREATE TABLE product(
	product_id serial PRIMARY KEY NOT NULL,
	product_name VARCHAR(256),
	type_product_id INTEGER,
	product_price DECIMAL(10, 2),
	product_stop BOOLEAN DEFAULT '0',

	FOREIGN KEY (type_product_id) REFERENCES type_product
);

CREATE TABLE product_status(
	product_status_id serial PRIMARY KEY NOT NULL,
	product_status_name VARCHAR(100)
);

CREATE TABLE active_order(
	order_id serial PRIMARY KEY NOT NULL,
	table_id INTEGER,
	employee_id INTEGER,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

	FOREIGN KEY (table_id) REFERENCES cafe_table,
	FOREIGN KEY (employee_id) REFERENCES employee
);

CREATE TABLE list_order(
	list_order_id serial PRIMARY KEY NOT NULL,
	order_id INTEGER,
	product_id INTEGER,
	product_quantity INTEGER,
	product_status_id INTEGER DEFAULT 1,
	product_desc TEXT DEFAULT '-',

	FOREIGN KEY (order_id) REFERENCES active_order,
	FOREIGN KEY (product_id) REFERENCES product,
	FOREIGN KEY (product_status_id) REFERENCES product_status
);

CREATE TABLE photo_tables(
	photo_tables_id serial PRIMARY KEY NOT NULL,
	photo_tables_path VARCHAR(256)
);

CREATE TABLE history_order(
	history_order_id serial PRIMARY KEY NOT NULL,
	table_id INTEGER,
	employee_id INTEGER,
	cause VARCHAR(100),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

	FOREIGN KEY (table_id) REFERENCES cafe_table,
	FOREIGN KEY (employee_id) REFERENCES employee
);

CREATE TABLE history_list_order(
	order_list_id serial PRIMARY KEY NOT NULL,
	order_id INTEGER,
	product_id INTEGER,
	product_quantity INTEGER,
	product_status_id INTEGER,
	product_desc TEXT DEFAULT '-',

	FOREIGN KEY (order_id) REFERENCES history_order,
	FOREIGN KEY (product_id) REFERENCES product,
	FOREIGN KEY (product_status_id) REFERENCES product_status
);