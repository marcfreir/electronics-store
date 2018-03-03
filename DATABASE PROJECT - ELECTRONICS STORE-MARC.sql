-- SUBJECTS: DATABASE PROJECT - ELECTRONICS STORE
-- STUDENT: MARC FREIR 

-- CREATING DATABASE
CREATE DATABASE db_electronicsstore;

-- USING THE DB
USE db_electronicsstore;

-- CREATING THE TABLES

-- CREATING USERS TABLE
CREATE TABLE tb_users
(
  userid INT NOT NULL AUTO_INCREMENT,
  username VARCHAR (80) NOT NULL,
  useremail VARCHAR (50) NOT NULL,
  usertype VARCHAR (10) NOT NULL,
  
  -- CREDENTIALS
  userlogin VARCHAR (45) NOT NULL UNIQUE,
  userpassword VARCHAR (20) NOT NULL,
  
  -- CREATING CONSTRAINT
  CONSTRAINT pk_userid PRIMARY KEY(userid)
) Engine = InnoDB DEFAULT CHARSET = UTF8;

-- CREATING CLIENTS TABLE
CREATE TABLE tb_clients
(
  clientid INT NOT NULL AUTO_INCREMENT,
  clientname VARCHAR (80) NOT NULL,
  clientaddress VARCHAR (100) NOT NULL,
  clientemail VARCHAR (50) NOT NULL,
  clienttype VARCHAR (10) NOT NULL,
  clientinvoices INT NOT NULL UNIQUE,
  
  -- CREATING CONSTRAINT
  CONSTRAINT pk_clientid PRIMARY KEY(clientid)
) Engine = InnoDB DEFAULT CHARSET = UTF8;

-- CREATING PRODUCTS TABLE
CREATE TABLE tb_products
(
  productid INT NOT NULL AUTO_INCREMENT,
  productname VARCHAR (80) NOT NULL,
  productdescription VARCHAR (100) NOT NULL,
  productdatein DATE,
  productdateout DATE,
  productprice DOUBLE (7, 2) NOT NULL,
  productpricediscount DOUBLE (7, 2),
  
  -- CREATING CONSTRAINT
  CONSTRAINT pk_productid PRIMARY KEY(productid)
) Engine = InnoDB DEFAULT CHARSET = UTF8;

-- CREATING INVOICE TABLE
CREATE TABLE tb_invoice
(
  invoiceid INT NOT NULL AUTO_INCREMENT,
  invoiceclientid INT NOT NULL,
  invoicedate DATE NOT NULL,
  productquantity INT,
  invoiceproductid INT NOT NULL,
  invoicetotal INT NOT NULL,
  
  -- CREATING CONSTRAINTS
  CONSTRAINT pk_invoiceid PRIMARY KEY(invoiceid),
  CONSTRAINT fk_invoiceclientid FOREIGN KEY(invoiceclientid)
  REFERENCES tb_clients(clientid),
  CONSTRAINT fk_invoiceproductid FOREIGN KEY(invoiceproductid)
  REFERENCES tb_products(productid)
) Engine = InnoDB DEFAULT CHARSET = UTF8;

-- 1a - SELECTING RECORDS IN 2 TABLES (WITH ALIASES)

SELECT clientname, invoiceid
FROM tb_clients AS C
INNER JOIN tb_invoice AS I
ON C.clientid = I.invoiceclientid;

-- 1b - SELECTING RECORDS IN 3 TABLES

SELECT clientid, clientname, invoiceid, productname
FROM tb_clients
INNER JOIN tb_invoice
INNER JOIN tb_products
ON tb_clients.clientid = tb_invoice.invoiceclientid;

-- 2a - CREATING A FUNCTION
DELIMITER //

CREATE FUNCTION f_calcinvoicetotal_plus (starting_value DOUBLE(7, 2), tax DOUBLE(7, 2))
RETURNS INT

BEGIN
       
   RETURN starting_value + (starting_value * tax / 100);
   
END; //

DELIMITER ;

-- CALLING THE FUNCTION
SELECT f_calcinvoicetotal_plus (10.00, 90.00) AS TotalwithInterest ;


-- OTHER ONE "JUST FOR FUN"

DELIMITER //

CREATE FUNCTION f_whatever (starting_value DOUBLE(7, 2))
RETURNS INT

BEGIN
   
   DECLARE a DOUBLE(7, 2);
   
   SET a = 0.00;
   
   label: WHILE a <= 300.00 DO
	 SET a = a + starting_value;
   END WHILE label;
   
   RETURN a;
   
END //

DELIMITER ;

-- CALLING THE FUNCTION
SELECT f_whatever (10.00);


-- 2b - CREATING A PROCEDURE
DELIMITER //
CREATE PROCEDURE of_Duty_p_showPrice (bug INT)

BEGIN

   SELECT CONCAT ('The price is: ', productprice) AS Price
   FROM tb_products
   WHERE productid = bug;
   
END //

DELIMITER ;

-- CALLING THE PROCEDURE
CALL of_Duty_p_showPrice (5.00);


-- 3a - CREATING STRUCTURE (REPETITION)
DELIMITER //

CREATE PROCEDURE p_products1parcel (x_limit DOUBLE(7, 2))

BEGIN

   DECLARE label VARCHAR (30);
    
   WHILE tb_products.productprice <= x_limit DO
      SET label = "Product price cannot be parceled!";
      -- SET cout = count + 1;
   END WHILE;
   
   
END //

DELIMITER ;

-- CALLING STRUCTURE
CALL p_products1parcel (30.00);


-- 4a - CREATING TRIGGER (INSERT)
DELIMITER //
CREATE TRIGGER tr_discount BEFORE INSERT
ON tb_products
FOR EACH ROW
SET NEW.productpricediscount = (NEW.productprice * 0.50);
//
DELIMITER ;

-- INSERTING PRODUCT WITH PRICE
INSERT INTO tb_products
(productname, productdescription, productdatein, productdateout, productprice)
VALUES
("Mouse", "Mouse Game - 12 buttons - green", '2005-01-01', '2005-02-02', 10.00);

INSERT INTO tb_products
(productname, productdescription, productdatein, productdateout, productprice, productpricediscount)
VALUES
("Mouse", "Mouse Game - 12 buttons - green", '2005-01-01', '2005-02-02', 10.00, 5.00);

-- SHOWING THE RESULT
SELECT * FROM tb_products;


-- 4b - CREATING TRIGGER (UPDATE)
DELIMITER //
CREATE TRIGGER tr_newdiscount BEFORE UPDATE
ON tb_products
FOR EACH ROW
SET NEW.productpricediscount = (NEW.productprice * 0.90);
//
DELIMITER ;

-- DROPPING TRIGGER
DROP TRIGGER tr_newdiscount;

-- UPDATING PRODUCT WITH PRICE
UPDATE tb_products
SET productdescription = "PRODUCT WITH DISCOUNT", productprice = productprice * 0.90
WHERE productdatein = '2005-01-01';

-- 4c - CREATING TRIGGER (DELETE)
DELIMITER //
CREATE TRIGGER tr_deletediscount AFTER DELETE
ON tb_products
FOR EACH ROW
BEGIN
   DELETE FROM tb_invoice
   WHERE tb_invoice.invoiceproductid = OLD.productid;
END //
DELIMITER ;

