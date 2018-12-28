CREATE TRIGGER after_accept_customer_order
AFTER INSERT ON customerorders
FOR EACH ROW
  BEGIN
    CALL deliver_customer_order_to_transmitter(NEW.id, NEW.shopId);
  END;

CREATE TRIGGER after_accept_temporary_customer_order
AFTER INSERT ON temporarycustomerorders
FOR EACH ROW
  BEGIN
    CALL deliver_temporary_customer_order_to_transmitter(NEW.id, NEW.shopId);
  END;