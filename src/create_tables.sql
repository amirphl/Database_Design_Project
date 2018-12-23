CREATE DATABASE OnlineStore;
USE OnlineStore;

CREATE TABLE Customers (
  username    VARCHAR(100) PRIMARY KEY,
  password    VARCHAR(30),
  email       VARCHAR(150) NOT NULL,
  first_name  VARCHAR(100),
  last_name   VARCHAR(100),
  postal_code CHAR(10)     NOT NULL,
  gender      ENUM ('man', 'woman'),
  credit      INT UNSIGNED NOT NULL DEFAULT 0
);

CREATE TABLE TemporaryCustomers (
  email        VARCHAR(150) PRIMARY KEY,
  first_name   VARCHAR(100),
  last_name    VARCHAR(100),
  postal_code  CHAR(10)                            NOT NULL,
  gender       ENUM ('man', 'woman') DEFAULT 'man' NOT NULL,
  address      VARCHAR(200)                        NOT NULL,
  phone_number VARCHAR(14)                         NOT NULL
);


CREATE TABLE CustomerAddresses (
  address          VARCHAR(200),
  CustomerUsername VARCHAR(100),
  PRIMARY KEY (address, CustomerUsername),
  FOREIGN KEY (CustomerUsername) REFERENCES Customers (username)
    ON DELETE CASCADE
);

CREATE TABLE CustomerPhoneNumbers (
  phone_number     VARCHAR(14),
  CustomerUsername VARCHAR(100),
  PRIMARY KEY (phone_number, CustomerUsername),
  FOREIGN KEY (CustomerUsername) REFERENCES Customers (username)
    ON DELETE CASCADE
);

CREATE TABLE Shop (
  id           CHAR(20) PRIMARY KEY,
  title        VARCHAR(100) NOT NULL,
  city         VARCHAR(100),
  address      VARCHAR(200) NOT NULL,
  phone_number VARCHAR(14)  NOT NULL,
  owner        VARCHAR(100),
  start_time   TIME         NOT NULL,
  end_time     TIME         NOT NULL
);

CREATE TABLE Product (
  id     CHAR(20),
  shopId CHAR(20),
  title  VARCHAR(100)               NOT NULL,
  price  INTEGER UNSIGNED           NOT NULL,
  value  INTEGER UNSIGNED DEFAULT 1 NOT NULL,
  offer  INTEGER UNSIGNED DEFAULT 0,
  PRIMARY KEY (id, shopId),
  FOREIGN KEY (shopId) REFERENCES Shop (id)
    ON DELETE CASCADE
);

CREATE TABLE CustomerOrders (
  id               CHAR(20),
  customerUsername VARCHAR(100),
  shopId           CHAR(20),
  productId        CHAR(20),
  value            INTEGER UNSIGNED DEFAULT 1                                                                 NOT NULL,
  status           ENUM ('accepted', 'rejected', 'sending', 'done') DEFAULT 'rejected'                        NOT NULL,
  payment_type     ENUM ('online', 'offline') DEFAULT 'online'                                                NOT NULL,
  dat              TIMESTAMP DEFAULT current_timestamp                                                        NOT NULL,
  address          VARCHAR(200)                                                                               NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (customerUsername) REFERENCES Customers (username),
  FOREIGN KEY (shopId) REFERENCES Shop (id),
  FOREIGN KEY (productId) REFERENCES Product (id)
);

CREATE TABLE TemporaryCustomerOrders (
  id            CHAR(20),
  customerEmail VARCHAR(150),
  shopId        CHAR(20),
  productId     CHAR(20),
  value         INTEGER UNSIGNED DEFAULT 1                                          NOT NULL,
  status        ENUM ('accepted', 'rejected', 'sending', 'done') DEFAULT 'rejected' NOT NULL,
  payment_type  ENUM ('offline') DEFAULT 'offline'                                  NOT NULL,
  dat           TIMESTAMP DEFAULT current_timestamp                                 NOT NULL,
  address       VARCHAR(200)                                                        NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (customerEmail) REFERENCES TemporaryCustomers (email),
  FOREIGN KEY (shopId) REFERENCES Shop (id),
  FOREIGN KEY (productId) REFERENCES Product (id)
);

CREATE TABLE Supporter (
  id           CHAR(20),
  shopId       CHAR(20),
  first_name   VARCHAR(100),
  last_name    VARCHAR(100),
  address      VARCHAR(200) NOT NULL,
  phone_number VARCHAR(14)  NOT NULL,
  PRIMARY KEY (id, shopId),
  FOREIGN KEY (shopId) REFERENCES Shop (id)
);

CREATE TABLE Operators (
  id         CHAR(20),
  shopId     CHAR(20),
  first_name VARCHAR(100),
  last_name  VARCHAR(100),
  PRIMARY KEY (id, shopId),
  FOREIGN KEY (shopId) REFERENCES Shop (id)
);

CREATE TABLE Transmitters (
  id           CHAR(20),
  shopId       CHAR(20),
  first_name   VARCHAR(100),
  last_name    VARCHAR(100),
  phone_number VARCHAR(14)                                NOT NULL,
  status       ENUM ('free', 'sending') DEFAULT 'sending' NOT NULL,
  credit       INTEGER UNSIGNED DEFAULT 0                 NOT NULL,
  PRIMARY KEY (id, shopId),
  FOREIGN KEY (shopId) REFERENCES Shop (id)
);