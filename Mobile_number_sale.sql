
--En cox nomre alan musteriler hansi nomreleri alib?
SELECT mobile_number, c.FIRST_NAME f FROM MOBILE_NUMBERS mn 
JOIN MOBILE_NUMBER_SALES mns  ON mns.MOBILE_NUMBER_ID =mn.MOBILE_NUMBER_ID 
JOIN CUSTOMER c  ON c.CUSTOMER_ID =mns.CUSTOMER_ID 
WHERE FIRST_NAME in (
SELECT c.FIRST_NAME FROM CUSTOMER c
JOIN MOBILE_NUMBER_SALES ps ON PS.CUSTOMER_ID = C.CUSTOMER_ID 
GROUP BY c.FIRST_NAME 
HAVING count(*)=
(
SELECT MAX(A) 
FROM (
SELECT count(*) AS A  FROM CUSTOMER c
JOIN MOBILE_NUMBER_SALES  ps ON PS.CUSTOMER_ID = C.CUSTOMER_ID 
GROUP BY c.FIRST_NAME
)
)
)


--1--Her bir operatorun butun prefixlerini tap.
SELECT o.OPERATOR_NAME, p.PREFIX  FROM OPERATORS o JOIN PREFIX p ON o.OPERATOR_ID =p.OPERATOR_ID 

--2--En cox hansi paket alinib ve bu paket hansi operatora aiddir?
SELECT ps.PAKET_ID,  np.PAKET_NAME,o.OPERATOR_NAME, COUNT(ps.PAKET_ID) AS sale_count
FROM PAKET_SALE ps
JOIN NUMBER_PAKET np ON ps.PAKET_ID = np.PAKET_ID
JOIN OPERATORS o ON o.OPERATOR_ID = np.OPERATOR_ID 
JOIN ALL_PAKETS_PRICES app ON app.PAKET_ID = np.PAKET_ID 
GROUP BY ps.PAKET_ID, np.PAKET_NAME,o.OPERATOR_name,app.PURCHASE_AMOUNT 
HAVING count(ps.PAKET_ID) in (SELECT max(sale_count) FROM (SELECT COUNT(ps.PAKET_ID) AS sale_count 
FROM PAKET_SALE ps
GROUP BY ps.PAKET_ID))


--3--En cox operatorun nomresi alinib?
SELECT mn.OPERATOR_ID  , o.OPERATOR_NAME , COUNT(mn.OPERATOR_ID)
FROM MOBILE_NUMBERS mn 
JOIN MOBILE_NUMBER_SALES mns ON mns.MOBILE_NUMBER_ID = mn.MOBILE_NUMBER_ID 
JOIN OPERATORS o ON o.OPERATOR_ID = mn.OPERATOR_ID 
GROUP BY mn.OPERATOR_ID , o.OPERATOR_NAME 
HAVING COUNT(mn.OPERATOR_ID) IN (SELECT max(a) FROM (SELECT COUNT(mn.OPERATOR_ID) AS a FROM MOBILE_NUMBERS mn
JOIN MOBILE_NUMBER_SALES mns ON mns.MOBILE_NUMBER_ID = mn.MOBILE_NUMBER_ID 
GROUP BY mn.OPERATOR_ID 
))

--4--Paket ve nomre alan musterileri cixart.
SELECT c.FIRST_name, mns.MOBILE_NUMBER_ID , PAKET_ID  FROM MOBILE_NUMBER_SALES mns 
JOIN  PAKET_SALE ps ON mns.CUSTOMER_ID = ps.CUSTOMER_ID 
JOIN CUSTOMER c ON c.CUSTOMER_ID =ps.CUSTOMER_ID 


--5-- Her bir musteri ne qeder odenis edib ay boyunca?(AZN la goster)(PAKET VE NOMRE)
SELECT first_name, sum(b) AS Odedi
FROM (
SELECT c.first_name, SUM(anp.purchase_amount) AS b FROM MOBILE_NUMBER_SALES mns 
JOIN CUSTOMER c ON c.CUSTOMER_ID = mns.CUSTOMER_ID 
JOIN ALL_NUMBERS_PRICES anp ON anp.MOBILE_NUMBER_ID = mns.MOBILE_NUMBER_ID 
GROUP BY c.first_name
UNION ALL
SELECT c.first_name, sum(app.purchase_amount) AS a  FROM PAKET_SALE ps 
JOIN CUSTOMER c  ON c.CUSTOMER_ID = ps.CUSTOMER_ID 
JOIN ALL_PAKETS_PRICES app  ON app.PAKET_ID = ps.PAKET_ID
GROUP BY c.first_name)
GROUP BY first_name

--6--Hansi Filialda daha cox satis olub?
SELECT branch_name , count(*) FROM STORE_BRANCH sb 
JOIN MOBILE_NUMBER_SALES mns ON mns.BRANCH_ID =sb.BRANCH_ID
JOIN PAKET_SALE ps ON ps.BRANCH_ID = sb.BRANCH_ID 
GROUP BY sb.BRANCH_NAME 
HAVING count()= (SELECT max(a) FROM (SELECT branch_name , count() AS a FROM STORE_BRANCH sb 
JOIN MOBILE_NUMBER_SALES mns ON mns.BRANCH_ID =sb.BRANCH_ID
JOIN PAKET_SALE ps ON ps.BRANCH_ID = sb.BRANCH_ID 
GROUP BY sb.BRANCH_NAME ))



--7-- Il erzinde hansi ayda daha cox nomre satis olub?
SELECT COUNT(*) , TO_CHAR(PURCHASE_DATE, 'MONTH')  FROM MOBILE_NUMBER_SALES mns 
GROUP BY TO_CHAR(PURCHASE_DATE, 'MONTH')
HAVING COUNT() = (SELECT max(a) FROM (SELECT COUNT() AS a, TO_CHAR(PURCHASE_DATE, 'MONTH')  FROM MOBILE_NUMBER_SALES mns 
GROUP BY TO_CHAR(PURCHASE_DATE, 'MONTH')))


--8-- Il erzinde hansi ayda daha cox paket satisi olub?
SELECT TO_CHAR(PURCHASE_DATE, 'MONTH'),  COUNT(*)   FROM PAKET_SALE ps
GROUP BY TO_CHAR(PURCHASE_DATE, 'MONTH')
HAVING COUNT() = (SELECT max(a) FROM (SELECT COUNT() AS a , TO_CHAR(PURCHASE_DATE, 'MONTH')  FROM PAKET_SALE ps
GROUP BY TO_CHAR(PURCHASE_DATE, 'MONTH')))

--9-- Il erzinde aylara gore umumi nece satis olub?
SELECT purchase_month, SUM(A) AS total_count
FROM (
    SELECT COUNT(*) AS A, TO_CHAR(PURCHASE_DATE, 'MONTH') AS purchase_month
    FROM MOBILE_NUMBER_SALES mns 
    GROUP BY TO_CHAR(PURCHASE_DATE, 'MONTH')

    UNION ALL 

    SELECT COUNT(*) AS A, TO_CHAR(PURCHASE_DATE, 'MONTH') AS purchase_month
    FROM PAKET_SALE ps  
    GROUP BY TO_CHAR(PURCHASE_DATE, 'MONTH')
)  combined_data
GROUP BY purchase_month;

--10-- Hansi musteri en cox nomre alib (Adini cixart) ?
SELECT c.first_name , COUNT(mns.MOBILE_NUMBER_ID) FROM CUSTOMER c 
JOIN MOBILE_NUMBER_SALES mns ON mns.CUSTOMER_ID = c.CUSTOMER_ID 
GROUP BY c.first_name
HAVING count(mns.MOBILE_NUMBER_ID) = (SELECT MAX(a) FROM (SELECT c.first_name, COUNT(mns.MOBILE_NUMBER_ID) AS a  FROM CUSTOMER c 
JOIN MOBILE_NUMBER_SALES mns ON mns.CUSTOMER_ID = c.CUSTOMER_ID 
GROUP BY c.first_name))

--11-- Hansi musteri en cox paket alib?
SELECT c.first_name , COUNT(ps.PAKET_ID) FROM CUSTOMER c 
JOIN PAKET_SALE ps  ON ps.CUSTOMER_ID = c.CUSTOMER_ID 
GROUP BY c.first_name
HAVING count(ps.PAKET_ID) = (SELECT MAX(a) FROM (SELECT c.first_name, COUNT(ps.PAKET_ID ) AS a  FROM CUSTOMER c 
JOIN PAKET_SALE ps  ON ps.CUSTOMER_ID = c.CUSTOMER_ID 
GROUP BY c.first_name))




SELECT np.paket_name, c.first_name
FROM NUMBER_PAKET np
JOIN PAKET_SALE ps ON np.PAKET_ID = ps.PAKET_ID 
JOIN CUSTOMER c ON c.CUSTOMER_ID = ps.CUSTOMER_ID 
WHERE c.first_name = (
    SELECT first_name
    FROM (
        SELECT c.first_name, COUNT(ps.PAKET_ID) AS paket_count
        FROM CUSTOMER c
        JOIN PAKET_SALE ps ON ps.CUSTOMER_ID = c.CUSTOMER_ID 
        GROUP BY c.first_name
        HAVING COUNT(ps.PAKET_ID) = (
            SELECT MAX(a)
            FROM (
                SELECT COUNT(ps.PAKET_ID) AS a
                FROM CUSTOMER c 
                JOIN PAKET_SALE ps ON ps.CUSTOMER_ID = c.CUSTOMER_ID 
                GROUP BY c.first_name
            )
        )
    )
);