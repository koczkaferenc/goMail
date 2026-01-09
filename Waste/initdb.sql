CREATE table users (
	id int primary key auto_increment,
	name varchar(255) not null
);
INSERT INTO users (id, name) VALUES (1, 'Koczka Ferenc');
INSERT INTO users (id, name) VALUES (2, 'nagy Ágnes');

CREATE table domains (
	id int primary key auto_increment,
	name varchar(255) not null,
	ownerid int not null,
	foreign key (ownerid) references users(id)
);
INSERT INTO domains (name, ownerid) VALUES ('uni-esztehazy.hu', 1);
INSERT INTO domains (name, ownerid) VALUES ('linux-szerver.hu', 1);
INSERT INTO domains (name, ownerid) VALUES ('agrialanc.hu', 2);
