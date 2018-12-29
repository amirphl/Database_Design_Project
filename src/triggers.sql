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

CREATE TRIGGER log_update_on_customers
AFTER UPDATE ON customers
FOR EACH ROW
  BEGIN
    INSERT INTO updatecustomerlog (username, dat) VALUES (NEW.username, current_timestamp);
  END;

CREATE TRIGGER log_update_on_transmitters
AFTER UPDATE ON transmitters
FOR EACH ROW
  BEGIN
    INSERT INTO updatetransmitterlog (transmitterId, dat, status) VALUES (NEW.id, current_timestamp, NEW.status);
  END;