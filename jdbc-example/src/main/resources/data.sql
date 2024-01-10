Insert into users values('Y','Jay','Bogle','$2a$10$2OmczpmQkxcbH4hFXNxkQeAJ/xTz.KAoGB7regjB1eE8Xa99HjtxG','user');
Insert into users values('Y','Rojero','Loluna','$2a$10$qv8Br4NtJxUodxc60inKSOlZtkEsomHjojfAe9j6lvEP0pD94rE6a','admin');
Insert into authorities values(1, 'ADMIN');
Insert into authorities values(2, 'USER');
Insert into authorities values(3, 'SUPER_USER');
insert into USERS_AUTHORITIES values(2,'user');
insert into USERS_AUTHORITIES values(1,'admin');
insert into USERS_AUTHORITIES values(3,'admin');

