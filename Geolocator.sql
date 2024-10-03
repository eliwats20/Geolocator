drop table log_query if exists;
drop table table_id if exists;
drop table ip_id if exists;






create table ip_id_table (
	ip_id varchar(20) primary key,
	ip_address varchar(15)
);

create table table_id (
	ip_id varchar(20), 
	log_id varchar(20),
	primary key(ip_id, log_id),
	foreign key (ip_id) references ip_id_table(ip_id)
);

create table log_query (
	log_id varchar(20) primary key
	ip_address varchar(15),
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
	foreign key (log_id) references table_id(log_id)
);

