-- First, populate the customer_rewards table
BEGIN
    customer_manager.assign_gifts_to_all;
    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE display_customer_rewards AS
    v_gifts gift_type;
BEGIN
    FOR reward_record IN (
        SELECT cr.reward_id,
               cr.customer_email,
               cr.reward_date,
               cr.gift_id,
               gc.min_purchase,
               gc.gifts
        FROM customer_rewards cr
        JOIN gift_catalog gc ON cr.gift_id = gc.gift_id
        ORDER BY cr.reward_id
        FETCH FIRST 5 ROWS ONLY
    )
    LOOP
        v_gifts := reward_record.gifts;
        DBMS_OUTPUT.PUT('Reward ID: ' || reward_record.reward_id || 
                       ', Email: ' || reward_record.customer_email ||
                       ', Gifts: ');
        
        -- Display all gifts in the nested table
        FOR i IN 1..v_gifts.COUNT LOOP
            DBMS_OUTPUT.PUT(v_gifts(i));
            IF i < v_gifts.COUNT THEN
                DBMS_OUTPUT.PUT(', ');
            END IF;
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE(', Min Purchase: ' || reward_record.min_purchase ||
                           ', Date: ' || TO_CHAR(reward_record.reward_date, 'YYYY-MM-DD'));
    END LOOP;
END display_customer_rewards;
/

-- Execute the procedure
SET SERVEROUTPUT ON;
BEGIN
    display_customer_rewards;
END;
/
