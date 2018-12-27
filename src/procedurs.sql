CREATE PROCEDURE add_customer(IN us VARCHAR(100), #username
                              IN pa VARCHAR(30), #password
                              IN em VARCHAR(150), #email
                              IN fi VARCHAR(100), #first_name
                              IN la VARCHAR(100), #last_name
                              IN po CHAR(10), #postal_code
                              IN ge ENUM ('man', 'woman'), #gender
                              IN cr INT UNSIGNED # credit
)
  BEGIN
    INSERT INTO customers (username, password, email, first_name, last_name, postal_code, gender, credit)
    VALUES (us, sha2(pa, 256), em, fi, la, po, ge, cr);
  END;

CREATE PROCEDURE update_customer(IN us VARCHAR(100), #username
                                 IN pa VARCHAR(30), #password
                                 IN em VARCHAR(150), #email
                                 IN fi VARCHAR(100), #first_name
                                 IN la VARCHAR(100), #last_name
                                 IN po CHAR(10), #postal_code
                                 IN ge ENUM ('man', 'woman')#gender
)
  BEGIN
    UPDATE customers
    SET password = pa, email = em, first_name = fi, last_name = la, postal_code = po, gender = ge
    WHERE username = us;
  END;

CREATE PROCEDURE add_order_by_customer(IN cu VARCHAR(100), #customerUsername
                                       IN sh CHAR(20), #shop id
                                       IN pr CHAR(20), # product id
                                       IN va INTEGER, # value
                                       IN pa ENUM ('online', 'offline'), # payment_type
                                       IN ad VARCHAR(200) # address
)
  BEGIN
    SELECT @pri := P.price
    FROM product AS P
    WHERE P.shopId = sh AND P.id = pr;

    UPDATE customers AS C
    SET credit = credit - pri
    WHERE C.username = cu AND pa = 'online';

    SELECT @shop_start_time := S.start_time
    FROM shop AS S
    WHERE S.id = sh;

    SELECT @shop_end_time := S.end_time
    FROM shop AS S
    WHERE S.id = sh;

    IF @shop_start_time <= current_time AND current_time <= @shop_end_time
    THEN
      INSERT INTO customerorders (customerUsername, shopId, productId, value, payment_type, address)
        VALUE (cu, sh, pr, va, pa, ad);
    ELSE
      INSERT INTO customerorders (customerUsername, shopId, productId, value, status, payment_type, address)
        VALUE (cu, sh, pr, va, 'rejected', pa, ad);
    END IF;
  END;

CREATE PROCEDURE add_order_by_temporary_customer(IN cu VARCHAR(150), #customerEmail
                                                 IN sh CHAR(20), #shop id
                                                 IN pr CHAR(20), # product id
                                                 IN va INTEGER, # value
                                                 IN ad VARCHAR(200) # address
)
  BEGIN

    SELECT @shop_start_time := S.start_time
    FROM shop AS S
    WHERE S.id = sh;

    SELECT @shop_end_time := S.end_time
    FROM shop AS S
    WHERE S.id = sh;

    IF @shop_start_time <= current_time AND current_time <= @shop_end_time
    THEN
      INSERT INTO temporarycustomerorders (customerEmail, shopId, productId, value, address)
        VALUE (cu, sh, pr, va, ad);
    ELSE
      INSERT INTO temporarycustomerorders (customerEmail, shopId, productId, value, status, address)
        VALUE (cu, sh, pr, va, 'rejected', ad);
    END IF;
  END;

