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
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET `_rollback` = 1;
    START TRANSACTION;
    INSERT INTO customers (username, password, email, first_name, last_name, postal_code, gender, credit)
    VALUES (us, sha2(pa, 256), em, fi, la, po, ge, cr);
    IF `_rollback`
    THEN
      ROLLBACK;
    ELSE
      COMMIT;
    END IF;
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
                                       IN sh CHAR(20), #shopId
                                       IN pr CHAR(20), # productId
                                       IN va INTEGER, # value
                                       IN pa ENUM ('online', 'offline'), # payment_type
                                       IN ad VARCHAR(200), # address
                                       IN ph VARCHAR(14) # phone_number
)
  BEGIN
    SELECT @pri := P.price
    FROM product AS P
    WHERE P.shopId = sh AND P.id = pr;

    SELECT @valu := P.value
    FROM product AS P
    WHERE P.shopId = sh AND P.id = pr;

    SELECT @cu_cred := C.credit
    FROM customers AS C
    WHERE C.username = cu;

    SELECT @shop_start_time := S.start_time
    FROM shop AS S
    WHERE S.id = sh;

    SELECT @shop_end_time := S.end_time
    FROM shop AS S
    WHERE S.id = sh;

    IF @valu < va OR @cu_cred < @pri * va OR @shop_start_time > current_time OR current_time > @shop_end_time
    THEN
      INSERT INTO customerorders (customerUsername, shopId, productId, value, status, payment_type, address, phone_number)
        VALUE (cu, sh, pr, va, 'rejected', pa, ad, ph);
    ELSE

      UPDATE customers AS C
      SET C.credit = C.credit - pri
      WHERE C.username = cu AND pa = 'online';

      UPDATE product AS P
      SET P.value = P.value - va
      WHERE P.id = pr AND P.shopId = sh;

      INSERT INTO customerorders (customerUsername, shopId, productId, value, payment_type, address, phone_number)
        VALUE (cu, sh, pr, va, pa, ad, ph);
    END IF;
  END;

CREATE PROCEDURE add_order_by_temporary_customer(IN cu VARCHAR(150), #customerEmail
                                                 IN sh CHAR(20), #shop id
                                                 IN pr CHAR(20), # product id
                                                 IN va INTEGER # value
)
  BEGIN

    SELECT @valu := P.value
    FROM product AS P
    WHERE P.shopId = sh AND P.id = pr;

    SELECT @shop_start_time := S.start_time
    FROM shop AS S
    WHERE S.id = sh;

    SELECT @shop_end_time := S.end_time
    FROM shop AS S
    WHERE S.id = sh;

    IF @shop_start_time <= current_time AND current_time <= @shop_end_time AND @valu >= va
    THEN
      INSERT INTO temporarycustomerorders (customerEmail, shopId, productId, value)
        VALUE (cu, sh, pr, va);
      UPDATE product AS P
      SET P.value = P.value - va
      WHERE P.id = pr AND P.shopId = sh;
    ELSE
      INSERT INTO temporarycustomerorders (customerEmail, shopId, productId, value, status)
        VALUE (cu, sh, pr, va, 'rejected');
    END IF;
  END;

CREATE PROCEDURE deliver_customer_order_to_transmitter(IN oid INT, # orderId
                                                       IN sh  CHAR(20) # shopId
)
  BEGIN
    SELECT @transmitter := T.id
    FROM transmitters AS T
    WHERE T.status = 'free' AND T.shopId = sh
    LIMIT 1;

    IF @transmitter IS NULL
    THEN
      UPDATE customerorders AS C
      SET status = 'rejected'
      WHERE C.id = oid;
    ELSE
      UPDATE transmitters AS T
      SET status = 'sending'
      WHERE T.id = @transmitter;

      UPDATE customerorders AS C
      SET status = 'sending'
      WHERE C.id = oid;

      INSERT INTO shipment (transmitterId, orderId) VALUES (@transmitter, oid);
    END IF;
  END;

CREATE PROCEDURE deliver_temporary_customer_order_to_transmitter(IN oid INT, # orderId
                                                                 IN sh  CHAR(20) # shopId
)
  BEGIN
    SELECT @transmitter := T.id
    FROM transmitters AS T
    WHERE T.status = 'free' AND T.shopId = sh
    LIMIT 1;

    IF @transmitter IS NULL
    THEN
      UPDATE temporarycustomerorders AS C
      SET status = 'rejected'
      WHERE C.id = oid;
    ELSE
      UPDATE transmitters AS T
      SET status = 'sending'
      WHERE T.id = @transmitter;

      UPDATE temporarycustomerorders AS C
      SET status = 'sending'
      WHERE C.id = oid;

      INSERT INTO temporaryshipment (transmitterId, orderId) VALUES (@transmitter, oid);
    END IF;
  END;


CREATE PROCEDURE deliver_to_customer(IN oid INT, # orderId
                                     IN tid CHAR(20) #transmitterId
)
  BEGIN
    UPDATE customerorders AS C
    SET C.status = 'done'
    WHERE C.id = oid;

    SELECT @pid := productId
    FROM customerorders AS C
    WHERE C.id = oid;

    UPDATE transmitters AS T
    SET T.status = 'free', T.credit = T.credit + 0.05 * (SELECT P.price
                                                         FROM product AS P
                                                         WHERE P.id = @pid)
    WHERE T.id = tid;
  END;

CREATE PROCEDURE charge_account(IN us VARCHAR(100), #username
                                IN cr INT UNSIGNED #credit
)
  BEGIN
    IF cr > 0
    THEN
      UPDATE customers
      SET credit = credit + cr
      WHERE username = us;
    END IF;
  END;










