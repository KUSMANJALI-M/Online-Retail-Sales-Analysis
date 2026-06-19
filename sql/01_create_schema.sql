CREATE TABLE transactions (
    transaction_id    SERIAL PRIMARY KEY,
    invoice           VARCHAR(20)    NOT NULL,
    stockcode         VARCHAR(20)    NOT NULL,
    quantity          INTEGER        NOT NULL,
    invoicedate       TIMESTAMP      NOT NULL,
    price             DECIMAL(10,2)  NOT NULL,
    customer_id       VARCHAR(20),
    country           VARCHAR(50),
    total_revenue     DECIMAL(10,2),
    invoice_year      INTEGER,
    invoice_month     INTEGER,
    year_month        VARCHAR(10),
    is_cancellation   BOOLEAN        DEFAULT FALSE
);

CREATE TABLE customers (
    customer_id       VARCHAR(20)    PRIMARY KEY,
    country           VARCHAR(50),
    first_purchase    DATE,
    last_purchase     DATE,
    total_orders      INTEGER,
    total_revenue     DECIMAL(12,2),
    rfm_segment       VARCHAR(20)
);

CREATE TABLE products (
    stockcode         VARCHAR(20)    PRIMARY KEY,
    description       VARCHAR(255),
    avg_price         DECIMAL(10,2),
    total_qty_sold    INTEGER,
    total_revenue     DECIMAL(12,2)
);