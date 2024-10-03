drop table if exists ip_address;


create table log_query (
	ip_address varchar(15) primary key,
	city varchar(50),
	region varchar(30),
	country varchar(30),
	postal_code NUMERIC(5,0),
	latitute varchar (10),
	longitude varchar (10),
	query_time varchar(40),
	request_type varchar(4),
	request_resource varchar(40),
	HTTP_response_code NUMERIC(3,0),
	object_size NUMERIC(5,0)
);

