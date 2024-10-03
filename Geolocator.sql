drop table if exists ip_address;


create table ip_details (
	ip_address varchar(15) primary key,
	city varchar(50),
	region varchar(30),
	country varchar(30),
	postal_code INTEGER(5),
	latitute varchar (10),
	longitude varchat (10)
);

creat table user_queries (
	query_id varchar (10) primary key
	ip_address varchar(15),
	query_time TIMESTAMP CURRENT_TIMESTAMP
	foreign key (ip_address) references ip_details(ip_address)
);