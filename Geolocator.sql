DROP TABLE IF EXISTS log_query;
DROP TABLE IF EXISTS table_id;
DROP TABLE IF EXISTS ip_id_table;

CREATE TABLE ip_id_table (
    ip_id INT AUTO_INCREMENT PRIMARY KEY,
    ip_address VARCHAR(15) UNIQUE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE table_id (
    log_id VARCHAR(20) PRIMARY KEY,
    ip_id INT,
    FOREIGN KEY (ip_id) REFERENCES ip_id_table(ip_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE log_query (
    log_id VARCHAR(20) PRIMARY KEY,
    ip_address VARCHAR(15),
    city VARCHAR(50),
    region VARCHAR(30),
    country VARCHAR(30),
    postal_code VARCHAR(15),
    loc VARCHAR(40),
    query_date DATE,
    query_time TIME,
    request_type VARCHAR(10),
    request_resource VARCHAR(40),
    HTTP_response_code NUMERIC(3,0),
    object_size NUMERIC(5,0),
    user_agent VARCHAR(15),
    FOREIGN KEY (log_id) REFERENCES table_id(log_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
