\* Задание 2 *\
CREATE TABLE `users` (
  `id` SERIAL PRIMARY KEY,
  `name` text NOT NULL UNIQUE,
  `createddate` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
) 
CREATE TABLE `actions` (
  `id` SERIAL PRIMARY KEY,
  `user_id` bigint unsigned NOT NULL,
  `description` text NOT NULL,
  `lastupdated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
) 
ALTER TABLE actions add FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);


\* Задание 3,4 *\
mysqldump -uroot -p  lesson1 --tables users 
	--where="users.createddate<'2020-12-21'" > usersdump.sql;
mysqldump -uroot -p  lesson1 --tables actions 
	--where="actions.user_id=(select id from users where users.createddate<'2020-12-21')" -x > actions.sql;

create database testdump;
use testdump;
source usersdump.sql;
source actions.sql;

