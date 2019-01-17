USE store;

DELIMITER //
CREATE TRIGGER add_order_by_customer
BEFORE INSERT ON customerorders
FOR EACH ROW
  BEGIN

    DECLARE transmitter INT UNSIGNED;

    SELECT P.price
    INTO @price_of_product
    FROM product AS P
    WHERE P.shopId = NEW.shopId AND P.id = NEW.productId;

    SELECT P.offer
    INTO @offer_of_product
    FROM product AS P
    WHERE P.shopId = NEW.shopId AND P.id = NEW.productId;

    SELECT P.value
    INTO @supply_of_product
    FROM product AS P
    WHERE P.shopId = NEW.shopId AND P.id = NEW.productId;

    SELECT C.credit
    INTO @cu_cred
    FROM customers AS C
    WHERE C.username = NEW.customerUsername;

    SELECT S.start_time
    INTO @shop_start_time
    FROM shop AS S
    WHERE S.id = NEW.shopId;

    SELECT S.end_time
    INTO @shop_end_time
    FROM shop AS S
    WHERE S.id = NEW.shopId;

    IF @supply_of_product < NEW.value OR @cu_cred < ((1.0 - @offer_of_product) * @price_of_product * NEW.value) OR
       @shop_start_time > current_time OR
       current_time > @shop_end_time
    THEN
      SET NEW.status = 'rejected';
    ELSE

      UPDATE customers AS C
      SET C.credit = C.credit - (1.0 - @offer_of_product) * @price_of_product * NEW.value
      WHERE C.username = NEW.customerUsername AND NEW.payment_type = 'online';

      UPDATE product AS P
      SET P.value = P.value - NEW.value
      WHERE P.id = NEW.productId AND P.shopId = NEW.shopId;

      SELECT T.id
      INTO transmitter
      FROM transmitters AS T
      WHERE T.status = 'free' AND T.shopId = NEW.shopId
      LIMIT 1;

      IF transmitter
      THEN
        SET NEW.status = 'sending';
      END IF;

    END IF;
  END//

CREATE TRIGGER deliver_to_transmitter
AFTER INSERT ON customerorders
FOR EACH ROW
  BEGIN

    DECLARE transmitter INT UNSIGNED;

    IF NEW.status != 'rejected'
    THEN

      SELECT T.id
      INTO transmitter
      FROM transmitters AS T
      WHERE T.status = 'free' AND T.shopId = NEW.shopId
      LIMIT 1;

      IF transmitter
      THEN
        UPDATE transmitters AS T
        SET status = 'sending'
        WHERE T.id = transmitter;
        INSERT INTO shipment (transmitterId, purchase_time, customerUsername, shopId, productId)
        VALUES (transmitter, NEW.purchase_time, NEW.customerUsername, NEW.shopId, NEW.productId);

      END IF;
    END IF;
  END//

CREATE TRIGGER add_order_by_temporary_customer
BEFORE INSERT ON temporarycustomerorders
FOR EACH ROW
  BEGIN

    DECLARE transmitter INT UNSIGNED;

    SELECT P.value
    INTO @supply_of_product
    FROM product AS P
    WHERE P.shopId = NEW.shopId AND P.id = NEW.productId;

    SELECT S.start_time
    INTO @shop_start_time
    FROM shop AS S
    WHERE S.id = NEW.shopId;

    SELECT S.end_time
    INTO @shop_end_time
    FROM shop AS S
    WHERE S.id = NEW.shopId;

    IF @supply_of_product < NEW.value OR
       @shop_start_time > current_time OR
       current_time > @shop_end_time
    THEN
      SET NEW.status = 'rejected';
    ELSE

      UPDATE product AS P
      SET P.value = P.value - NEW.value
      WHERE P.id = NEW.productId AND P.shopId = NEW.shopId;

      SELECT T.id
      INTO transmitter
      FROM transmitters AS T
      WHERE T.status = 'free' AND T.shopId = NEW.shopId
      LIMIT 1;

      IF transmitter
      THEN
        SET NEW.status = 'sending';
      END IF;

    END IF;
  END//

CREATE TRIGGER deliver_temporary_customer_order_to_transmitter
AFTER INSERT ON temporarycustomerorders
FOR EACH ROW
  BEGIN

    DECLARE transmitter INT UNSIGNED;

    IF NEW.status != 'rejected'
    THEN

      SELECT T.id
      INTO transmitter
      FROM transmitters AS T
      WHERE T.status = 'free' AND T.shopId = NEW.shopId
      LIMIT 1;

      IF transmitter
      THEN
        UPDATE transmitters AS T
        SET status = 'sending'
        WHERE T.id = transmitter;
        INSERT INTO temporaryshipment (transmitterId, purchase_time, customerEmail, shopId, productId)
        VALUES (transmitter, NEW.purchase_time, NEW.customerEmail, NEW.shopId, NEW.productId);

      END IF;
    END IF;
  END//

DELIMITER ;

# CREATE TRIGGER log_update_on_customers
# AFTER UPDATE ON customers
# FOR EACH ROW
#   BEGIN
#     INSERT INTO updatecustomerlog (username, dat) VALUES (NEW.username, current_timestamp);
#   END;
#
# CREATE TRIGGER log_update_on_transmitters
# AFTER UPDATE ON transmitters
# FOR EACH ROW
#   BEGIN
#     INSERT INTO updatetransmitterlog (transmitterId, dat, status) VALUES (NEW.id, current_timestamp, NEW.status);
#   END;
#
# CREATE TRIGGER log_update_on_customer_orders
# AFTER UPDATE ON customerorders
# FOR EACH ROW
#   BEGIN
#     INSERT INTO updatecustomerorderlog (orderId, dat, status) VALUES (NEW.id, current_timestamp, NEW.status);
#   END;
#
# CREATE TRIGGER log_update_on_temporary_customer_orders
# AFTER UPDATE ON temporarycustomerorders
# FOR EACH ROW
#   BEGIN
#     INSERT INTO updatetemporarycustomerorderlog (orderId, dat, status) VALUES (NEW.id, current_timestamp, NEW.status);
#   END;
