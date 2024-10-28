INSERT INTO ip_id_table (ip_address) VALUES ('192.168.1.1'); -- Insert a sample IP
INSERT INTO table_id (log_id, ip_id) VALUES ('log123', LAST_INSERT_ID()); -- Use the last inserted ID
INSERT INTO log_query (log_id, ip_address, city, region, country, postal_code, latitude, longitude, query_time, request_type, request_resource, HTTP_response_code, object_size) 
VALUES ('log123', '192.168.1.1', 'Sample City', 'Sample Region', 'Sample Country', '12345', 25.123456, -80.123456, NOW(), 'GET', '/sample', 200, 123);
