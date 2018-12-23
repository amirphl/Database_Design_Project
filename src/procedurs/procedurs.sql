DELIMITER //
CREATE PROCEDURE GetAllProducts()
  BEGIN
    SELECT *  FROM Product;
  END //
DELIMITER ;

CALL GetAllProducts();

# DECLARE total_count INT DEFAULT 0;
# SET total_count = 10;

# DECLARE total_products INT DEFAULT 0;
#
# SELECT
#   COUNT(*) INTO total_products
# FROM
#   products;

# @var_name
#variable scoping

