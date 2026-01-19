
CREATE DATABASE AIRLINE;

USE AIRLINE;

/*	Write a query to create a route_details table using suitable data types
 for the fields, such as route_id, flight_num, origin_airport, destination_airport, 
 aircraft_id, and distance_miles. Implement the check constraint for the flight number
 and unique constraint for the route_id fields.
 Also, make sure that the distance miles field is greater than 0. */
 
 CREATE TABLE ROUTE_DETAILS(
 ROUTE_ID INT UNIQUE,
 FLIGHT_NUM INT CHECK (FLIGHT_NUM BETWEEN 1000 AND 9999),
 ORIGIN_AIRPORT VARCHAR(5),
 DESTINATION_AIRPORT VARCHAR(5),
 AIRCRAFT_ID VARCHAR(10),
 DISTANCE_MILES INT CHECK (DISTANCE_MILES >0)
 );
 
/*Write a query to display all the passengers (customers) who have
 travelled in routes 01 to 25. Take data from the passengers_on_flights table.*/
 
 SELECT CUSTOMER_ID  FROM PASSENGERS_ON_FLIGHTS WHERE ROUTE_ID BETWEEN 1 AND 25;
 
/*Write a query to identify the number of passengers and total revenue 
 in business class from the ticket_details table.*/
 
 SELECT SUM(NO_OF_TICKETS) FROM TICKET_DETAILS;
 SELECT SUM(PRICE_PER_TICKET) FROM TICKET_DETAILS;
 SELECT (SUM(NO_OF_TICKETS)*SUM(PRICE_PER_TICKET)) AS TOTAL_REVENUE FROM TICKET_DETAILS;
 
/*Write a query to display the full name of the customer by extracting the 
 first name and last name from the customer table.*/
 
 SELECT 
 CONCAT (FIRST_NAME, ' ', LAST_NAME) AS CUSTOMER_NAME FROM CUSTOMER;
 
 /*Write a query to extract the customers who have registered and booked a ticket.
 Use data from the customer and ticket_details tables.*/
 
 SELECT 
 C.CUSTOMER_ID,
 C.FIRST_NAME,
 C.LAST_NAME FROM CUSTOMER C 
 INNER JOIN TICKET_DETAILS T
 ON C.CUSTOMER_ID = T.CUSTOMER_ID;
 
 /*Write a query to identify the customer’s first name and last name based on
 their customer ID and brand (Emirates) from the ticket_details table.*/
 
 SELECT 
 C.CUSTOMER_ID,
 C.FIRST_NAME,
 C.LAST_NAME,
 T.BRAND
 FROM CUSTOMER C 
 INNER JOIN TICKET_DETAILS T
 ON C.CUSTOMER_ID = T. CUSTOMER_ID;
 
/*Write a query to identify the customers who have travelled by Economy 
 Plus class using Group By and Having clause on the passengers_on_flights table. */
 
 SELECT
 C.CUSTOMER_ID,
 C.FIRST_NAME,
 C.LAST_NAME,
 P.CLASS_ID FROM CUSTOMER C 
 INNER JOIN PASSENGERS_ON_FLIGHTS P 
 ON C.CUSTOMER_ID = P.CUSTOMER_ID 
 GROUP BY
 C.CUSTOMER_ID,
 C.FIRST_NAME,
 C.LAST_NAME,
 P.CLASS_ID 
 HAVING CLASS_ID = "ECONOMY PLUS";
 
 
/*Write a query to identify whether the revenue has crossed 10000 using the 
 IF clause on the ticket_details table.*/
 
 SELECT 
 CASE
 WHEN
 (SUM(NO_OF_TICKETS) * SUM(PRICE_PER_TICKET)) >10000
 THEN "YES"
 ELSE "NO"
 END AS REVENUE
 FROM TICKET_DETAILS;
 
/*Write a query to create and grant access to a new user to perform 
 operations on a database.*/
 
 CREATE USER 'HELLO'@'localhost' IDENTIFIED BY '123456';
 GRANT ALL PRIVILEGES ON AIRLINE.* TO 'HELLO'@'localhost';
 FLUSH PRIVILEGES;
 
 /*Write a query to find the maximum ticket price for each class
 using window functions on the ticket_details table. */
 
 SELECT DISTINCT CLASS_ID,
 MAX(PRICE_PER_TICKET) OVER (PARTITION BY CLASS_ID)
 FROM TICKET_DETAILS;
 
 /*Write a query to extract the passengers whose route ID is 4 by improving 
 the speed and performance of the passengers_on_flights table.*/
 
 CREATE INDEX IDX_ROUTE_ID
 ON PASSENGERS_ON_FLIGHTS(ROUTE_ID);
 
 SELECT * FROM PASSENGERS_ON_FLIGHTS WHERE ROUTE_ID = 4;
 
/*For the route ID 4, write a query to view the execution plan of
 the passengers_on_flights table.*/
 
 EXPLAIN
 SELECT * FROM PASSENGERS_ON_FLIGHTS WHERE ROUTE_ID = 4;
 
/*Write a query to calculate the total price of all tickets booked by a customer 
across different aircraft IDs using rollup function. */

SELECT DISTINCT T.CUSTOMER_ID, C.FIRST_NAME, T.AIRCRAFT_ID,SUM(T.PRICE_PER_TICKET)
FROM TICKET_DETAILS T INNER JOIN CUSTOMER C
ON C.CUSTOMER_ID = T.CUSTOMER_ID GROUP BY CUSTOMER_ID, FIRST_NAME,AIRCRAFT_ID;
 
 -- OR 
 
 SELECT CUSTOMER_ID, AIRCRAFT_ID,
 SUM(NO_OF_TICKETS* PRICE_PER_TICKET) AS TOTAL_PRICE
 FROM TICKET_DETAILS
 GROUP BY CUSTOMER_ID, AIRCRAFT_ID WITH ROLLUP;
 
 /*Write a query to create a view with only business class customers along 
 with the brand of airlines. */
 
CREATE VIEW BUSINESS_CLASS_CUSTOMER AS
SELECT DISTINCT
C.FIRST_NAME,
C.LAST_NAME,
T.CLASS_ID,
T.BRAND FROM CUSTOMER C 
INNER JOIN TICKET_DETAILS T ON
C.CUSTOMER_ID = T.CUSTOMER_ID
WHERE CLASS_ID = 'BUSSINESS';

SELECT * FROM BUSINESS_CLASS_CUSTOMER;

     
/*Write a query to create a stored procedure that extracts all the details 
from the routes table where the travelled distance is more than 2000 miles.*/

delimiter //
CREATE PROCEDURE DETAILS2()
BEGIN
SELECT * FROM ROUTES WHERE DISTANCE_MILES >2000;
END;

CALL DETAILS2;

/*Write a query to create a stored procedure that groups the distance travelled 
by each flight into three categories. The categories are, short distance travel (SDT)
 for >=0 AND <= 2000 miles, intermediate distance travel (IDT) for >2000 AND <=6500, 
 and long-distance travel (LDT) for >6500.*/
 
 DELIMITER //
 CREATE PROCEDURE FLIGHT_DETAILS3()
 SELECT FLIGHT_NUM , DISTANCE_MILES,
 CASE
 WHEN 
    DISTANCE_MILES >=0 AND DISTANCE_MILES <=2000
    THEN "SDT"
WHEN 
    DISTANCE_MILES >2000 AND DISTANCE_MILES <=6500
    THEN "IDT"
WHEN
    DISTANCE_MILES >6500 
    THEN "LDT" 
   END AS CATEGORY FROM ROUTES
END;

CALL FLIGHT_DETAILS3

/*Write a query to extract ticket purchase date, customer ID, class ID and 
specify if the complimentary services are provided for the specific class using a 
stored function in stored procedure on the ticket_details table. 
Condition: 
●	If the class is Business and Economy Plus, then complimentary services are
 given as Yes, else it is No */
 
 
 DELIMITER //
 CREATE PROCEDURE COMPLIMENTARY_SERVICE()
 BEGIN
 SELECT P_DATE, CUSTOMER_ID, CLASS_ID,
 CASE
  WHEN
    CLASS_ID = 'BUSSINESS' OR  CLASS_ID = 'ECONOMY'
	THEN 'YES'
 ELSE 'NO'
 END AS COMPLIMENTARY_SERVICE
 FROM TICKET_DETAILS;
 END//
 
 DELIMITER ;
 
 
 CALL COMPLIMENTARY_SERVICE();
 
 
 
/*Write a query to extract the first record of the customer whose last name ends 
with Scott using a cursor from the customer table.*/

DELIMITER //

CREATE PROCEDURE CUSTOMER_SCOTT()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_id INT;
    DECLARE v_fname VARCHAR(100);
    DECLARE v_lname VARCHAR(100);

    -- Cursor
    DECLARE cursor_1 CURSOR FOR
        SELECT customer_id, first_name, last_name
        FROM customer
        WHERE last_name LIKE '%Scott';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cursor_1;

    read_loop: LOOP
        FETCH cursor_1 INTO v_id, v_fname, v_lname;

        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        -- Return first row only
        SELECT v_id, v_fname, v_lname;
        LEAVE read_loop;
    END LOOP;

    CLOSE cursor_1;
END//

DELIMITER ;
 
 
CALL CUSTOMER_SCOTT();


 

 
 
 

 
 
 

 
 
 
 