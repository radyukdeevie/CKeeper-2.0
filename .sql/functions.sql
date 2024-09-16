-- Функция для создания заказа

CREATE OR REPLACE FUNCTION create_order(t_i INTEGER, e_i INTEGER, p_i INTEGER[], p_q INTEGER[], p_d TEXT[])
RETURNS VOID AS $$
DECLARE
	i INTEGER;
	current_status INTEGER;
	new_order INTEGER;
BEGIN
	SELECT status_id INTO current_status FROM cafe_table WHERE table_id = t_i;

	IF current_status <> 1 THEN
		RAISE EXCEPTION 'Данный стол занят или зарезервирован: %', (SELECT table_description FROM cafe_table WHERE table_id = t_i);
	END IF;
	INSERT INTO active_order(
		table_id,
		employee_id
	)
	VALUES(
		t_i,
		e_i
	)
	RETURNING order_id INTO new_order;
	
	FOR i IN 1..array_length(p_i, 1)
	LOOP
		INSERT INTO list_order(
			order_id,
			product_id,
			product_quantity,
			product_desc
		)
		VALUES(
			new_order,
			p_i[i],
			p_q[i],
			p_d[i]
		);
	END LOOP;

	UPDATE cafe_table SET status_id = 2 WHERE table_id = t_i;
	
END;
$$ LANGUAGE plpgsql;

-- Функция для вывода информации о заказе

CREATE OR REPLACE FUNCTION get_list_order(o_i INTEGER)
RETURNS TABLE (
	"Название блюда" VARCHAR,
	"Количество" INTEGER,
	"Готовность" VARCHAR,
	"Дополнительно" TEXT
) AS $$
	SELECT product_name, l_o.product_quantity, product_status_name, l_o.product_desc
	FROM list_order l_o
	JOIN product p USING (product_id)
	JOIN product_status USING(product_status_id)
	WHERE order_id = o_i;
	
$$ LANGUAGE SQL;

-- Функция для удаления заказа
CREATE OR REPLACE FUNCTION delete_order(o_i INTEGER, e_i INTEGER)
RETURNS VOID AS $$
	INSERT INTO history_order(
		history_order_id,
		table_id,
		employee_id,
		cause
	)
	VALUES(
		o_i,
		(SELECT table_id FROM active_order WHERE order_id = o_i),
		(SELECT employee_id FROM active_order WHERE order_id = o_i),
		FORMAT('Удален: %s',
			(SELECT employee_last_name || ' ' || LEFT(employee_name, 1) || '.' || LEFT(employee_second_name, 1) || '.' FROM employee WHERE employee_id = e_i))
	);
	UPDATE cafe_table SET status_id = 1 WHERE table_id = (SELECT table_id FROM active_order WHERE order_id = o_i);
	DELETE FROM list_order WHERE order_id = o_i;
	DELETE FROM active_order WHERE order_id = o_i;
$$ LANGUAGE SQL;

-- Фунция для смены статуса блюда

CREATE OR REPLACE FUNCTION change_of_product_status(o_i INTEGER, p_i INTEGER, status INTEGER)
RETURNS VOID AS $$
	UPDATE list_order SET product_status_id = status WHERE order_id = o_i AND product_id = p_i
$$ LANGUAGE SQL;

-- Функция вывода чека
CREATE OR REPLACE FUNCTION get_check(o_i INTEGER)
RETURNS TABLE (
	"Наименование блюда" VARCHAR,
	"Количество" INTEGER,
	"Стоимость блюда" DECIMAL(10, 2)
) AS $$
	SELECT product_name, l_o.product_quantity, (l_o.product_quantity * product_price)
	FROM list_order l_o
	JOIN product USING(product_id)
	WHERE order_id = o_i
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION get_full_price(o_i INTEGER)
RETURNS TABLE (
	full_price DECIMAL
) AS $$
	SELECT SUM(l_o.product_quantity * product_price) FROM list_order l_o
	JOIN product USING (product_id)
	WHERE order_id = o_i
$$ LANGUAGE SQL;

--


-- Функция закрытия заказа

CREATE OR REPLACE FUNCTION close_order(o_i INTEGER, e_i INTEGER)
RETURNS VOID AS $$
	INSERT INTO history_order(history_order_id, table_id, employee_id, cause)
	VALUES
	(
		o_i,
		(SELECT table_id FROM active_order WHERE order_id = o_i),
		(SELECT employee_id FROM active_order WHERE order_id = o_i),
		FORMAT('Закрыт: %s',
			(SELECT employee_last_name || ' ' || LEFT(employee_name, 1) || '.' || LEFT(employee_last_name, 1) || '.' FROM active_order JOIN employee USING(employee_id) WHERE order_id = o_i))
	);

	INSERT INTO history_list_order(order_id, product_id, product_quantity, product_desc)
	SELECT order_id, product_id, product_quantity, product_desc
	FROM list_order
	WHERE order_id = o_i;

	DELETE FROM list_order WHERE order_id = o_i;
	DELETE FROM active_order WHERE order_id = o_i;

$$ LANGUAGE SQL;

SELECT close_order(2, 3);
SELECT delete_order(3, 6);