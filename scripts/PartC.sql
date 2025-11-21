CREATE OR REPLACE PACKAGE customer_manager IS
    FUNCTION get_total_purchase(p_customer_id IN NUMBER) RETURN NUMBER;
    PROCEDURE assign_gifts_to_all;
END customer_manager;
/
CREATE OR REPLACE PACKAGE BODY customer_manager IS
    FUNCTION get_total_purchase(p_customer_id IN NUMBER) RETURN NUMBER AS
        v_total_purchase NUMBER;
    BEGIN
        SELECT SUM(oi.unit_price * oi.quantity) 
            INTO v_total_purchase 
                FROM customers c
                LEFT JOIN orders o ON c.customer_id = o.customer_id
                LEFT JOIN order_items oi ON o.order_id = oi.order_id
                WHERE c.customer_id = p_customer_id;
        RETURN NVL(v_total_purchase, 0);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
    END get_total_purchase;

    FUNCTION choose_gift_package(p_total_purchase IN NUMBER) RETURN NUMBER AS
        v_gift_id NUMBER := NULL;
    BEGIN
        FOR gift_rec IN (SELECT gift_id, min_purchase FROM gift_catalog ORDER BY min_purchase ASC)
        LOOP
            CASE
                WHEN gift_rec.min_purchase <= p_total_purchase THEN
                    v_gift_id := gift_rec.gift_id;
                ELSE
                    EXIT;
            END CASE;
        END LOOP;
        
        RETURN v_gift_id;
    END choose_gift_package;

    PROCEDURE assign_gifts_to_all AS
        v_total_purchase NUMBER;
        v_gift_id NUMBER;
    BEGIN
        FOR cust_record IN (SELECT customer_id, email_address FROM customers)
        LOOP
            v_total_purchase := get_total_purchase(cust_record.customer_id);
            v_gift_id := choose_gift_package(v_total_purchase);
            INSERT INTO customer_rewards (customer_email, gift_id)
                VALUES (cust_record.email_address, v_gift_id);
        END LOOP;
    END assign_gifts_to_all;
END customer_manager;
/