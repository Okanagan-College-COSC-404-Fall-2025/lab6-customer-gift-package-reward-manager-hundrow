CREATE OR REPLACE TYPE gift_type IS TABLE OF VARCHAR2(100);
/
CREATE TABLE gift_catalog (
    gift_id NUMBER PRIMARY KEY,
    min_purchase NUMBER,
    gifts gift_type
) NESTED TABLE gifts STORE AS gifts_nt;
/
INSERT INTO gift_catalog (gift_id, min_purchase, gifts) VALUES (1, 100, gift_type('Stickers', 'Pen Set'));
INSERT INTO gift_catalog (gift_id, min_purchase, gifts) VALUES (2, 1000, gift_type('Teddy Bear', 'Perfume Sample'));
INSERT INTO gift_catalog (gift_id, min_purchase, gifts) VALUES (3, 10000, gift_type('Backpack', 'Thermos Bottle', 'Chocolate Collection'));
COMMIT;