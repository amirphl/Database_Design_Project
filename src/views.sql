CREATE VIEW S(shopId, productId, total) AS
  (SELECT
     C.shopId,
     C.productId,
     sum(C.value)
   FROM customerorders AS C
   GROUP BY C.shopId, C.productId
  )
  UNION ALL (
    SELECT
      T.shopId,
      T.productId,
      sum(T.value)
    FROM temporarycustomerorders AS T
    GROUP BY T.shopId, T.productId
  );

CREATE VIEW M0 (shopId, productId, total) AS (
  SELECT
    shopId,
    productId,
    sum(total)
  FROM S
  GROUP BY shopId, productId
);

CREATE VIEW H1 (shopId, productId, total) AS (
  SELECT *
  FROM M0
  WHERE M0.total >= (SELECT U.total
                     FROM M0 AS U
                     WHERE M0.shopId = U.shopId)
);

CREATE VIEW M1 (shopId, productId, total) AS (
  SELECT *
  FROM M0
  WHERE (M0.shopId, M0.productId, M0.total) NOT IN (SELECT *
                                                    FROM H1)
);

CREATE VIEW H2 (shopId, productId, total) AS (
  SELECT *
  FROM M1
  WHERE M1.total >= (SELECT U.total
                     FROM M1 AS U
                     WHERE M1.shopId = U.shopId)
);

CREATE VIEW M2 (shopId, productId, total) AS (
  SELECT *
  FROM M1
  WHERE (M1.shopId, M1.productId, M1.total) NOT IN (SELECT *
                                                    FROM H2)
);

CREATE VIEW H3 (shopId, productId, total) AS (
  SELECT *
  FROM M2
  WHERE M2.total >= (SELECT U.total
                     FROM M2 AS U
                     WHERE M2.shopId = U.shopId)
);

CREATE VIEW M3 (shopId, productId, total) AS (
  SELECT *
  FROM M2
  WHERE (M2.shopId, M2.productId, M2.total) NOT IN (SELECT *
                                                    FROM H3)
);

CREATE VIEW H4 (shopId, productId, total) AS (
  SELECT *
  FROM M3
  WHERE M3.total >= (SELECT U.total
                     FROM M3 AS U
                     WHERE M3.shopId = U.shopId)
);

CREATE VIEW M4 (shopId, productId, total) AS (
  SELECT *
  FROM M3
  WHERE (M3.shopId, M3.productId, M3.total) NOT IN (SELECT *
                                                    FROM H4)
);

CREATE VIEW H5 (shopId, productId, total) AS (
  SELECT *
  FROM M4
  WHERE M4.total >= (SELECT U.total
                     FROM M4 AS U
                     WHERE M4.shopId = U.shopId)
);

#--------------------------

