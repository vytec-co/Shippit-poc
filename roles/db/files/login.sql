create database shop;
create user john@'%' identified by 'john_password';
grant all privileges on shop.* to john@'%';