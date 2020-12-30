CREATE TABLE countries (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки", 
  name VARCHAR(100) NOT NULL COMMENT "Название страны",
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Справочник стран";  

CREATE TABLE cities (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки", 
  name VARCHAR(100) NOT NULL COMMENT "City Name",
  country_id INT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Cities";  

alter table countries add column code VARCHAR(5) Comment "Phone country code";
alter table cities add FOREIGN KEY cities_country_id_countries (country_id) REFERENCES countries(id);

update profiles set country  = null;
alter table profiles change country country_id INT UNSIGNED NULL;
alter table profiles change city city_id INT UNSIGNED NULL;
alter table profiles drop column country_id; /*information already exists between tables cities & countries */
alter table profiles drop column deleteddate;


alter table media add column digest varchar(256) not null comment "SHA256 дайжест файла";	
alter table media add column issecureforreload bool not null default false comment "file is locked by loaded user";
alter table media add column issecureforcopy bool not null default false comment "file is locked by loaded user";


alter table relationships drop column requested_at; /*similar to created_at*/


INSERT INTO statuses (name) VALUES ('single'),('married'),('friendship'),('blocked'),('admin'),('member');
INSERT INTO media_types (name) VALUES ('photo'),('video'),('audio'),('book');

UPDATE profiles SET country_id = FLOOR(1 + RAND() * 100);
select * from users where profile_id > 100;
select * from communities where profile_id < 100 and user_profile_id >100;

alter table relationships drop Foreign Key relationships_from_profile_id_users;
alter table relationships drop Foreign Key relationships_to_profile_id_users;
alter table relationships drop PRIMARY KEY;
ALTER TABLE relationships MODIFY COLUMN to_profile_id bigint unsigned NULL COMMENT 'Ссылка на получателя приглашения дружить';
alter table relationships add UNIQUE INDEX from_to_status (from_profile_id,to_profile_id,status_id);
alter table relationships add CONSTRAINT relationships_from_profile_id_users FOREIGN KEY (from_profile_id) REFERENCES users(profile_id) ON DELETE CASCADE;
alter table relationships add CONSTRAINT relationships_to_profile_id_users FOREIGN KEY (to_profile_id) REFERENCES users(profile_id) ON DELETE CASCADE;

select * from relationships r where r.status_id  = 1;
update relationships r set r.to_profile_id = null, confirmed_at = created_at where r.status_id =1;

select r.from_profile_id 
from relationships r 
join relationships r2 
on r.from_profile_id = r2.from_profile_id  
where r.status_id =2 and r2.status_id =1; 

delete from relationships 
where status_id =1 
and from_profile_id in 
(select r1.from_profile_id 
from (select * from relationships) as r1 
join (select * from relationships) as r2
on r1.from_profile_id = r2.from_profile_id  
where r1.status_id =2 and r2.status_id =1);


-- Создаём временную таблицу форматов медиафайлов
CREATE TEMPORARY TABLE extensions (name VARCHAR(10));

-- Заполняем значениями
INSERT INTO extensions VALUES ('jpeg'), ('avi'), ('mpeg'), ('png');

-- Проверяем
SELECT * FROM extensions;

-- Обновляем ссылку на файл
UPDATE media SET filename = CONCAT(
  'http://dropbox.net/vk/',
  filename,'_',
  (SELECT last_name FROM users ORDER BY RAND() LIMIT 1),
  '.',
  (SELECT name FROM extensions ORDER BY RAND() LIMIT 1)
);
-- update filetypes
update media set media_type_id =
case 
when filename like '%jpeg' or filename  like '%png' then 1
when filename like '%avi' then 2
when filename like '%mpeg' then 3
end;

-- Заполняем метаданные
UPDATE media SET metadata = CONCAT('{"owner":"', 
  (SELECT CONCAT(first_name, ' ', last_name) FROM users WHERE profile_id = media.user_profile_id),
  '"}');  
 
 -- Заполняем hash summ
 UPDATE media SET media.digest = SHA2(metadata,256);

alter table media_profiles  drop foreign key media_profiles_profile_id_profiles;

alter table media_profiles 
add constraint media_profiles_profile_id_profiles 
FOREIGN KEY (media_id) 
REFERENCES media(id) 
ON DELETE CASCADE;

-- set main photo to some profiles
update media_profiles set ismainphoto = 1 
where profile_id %2 = 0 
and media_id in 
(select id from media where media.media_type_id = 1);
-- TODO: think about to create file extentions table


select * from messages m where m.created_at > m.updated_at ;
update messages m set updated_at = NOW() where m.created_at > m.updated_at ;

-- its strange but VK allows you to send a message to yourself 
select * from messages m where m.from_profile_id = m.to_profile_id;

-- check confuse if message was received but not delivered
select * from messages m where m.is_delivered = 0 and m.is_received =1;
update messages set is_delivered =1 where is_received  =1;


alter table posts CHANGE GUID GUID VARCHAR(255) null COMMENT "GUID to Identify post GENERATED ON CLIENT";
alter table posts_media drop primary key;
alter table posts_profiles drop primary key;
alter table likes_posts drop primary key;
alter table posts_media CHANGE post_GUID post_GUID VARCHAR(255) null COMMENT "GUID to Identify post GENERATED ON CLIENT";
alter table posts_profiles CHANGE post_GUID post_GUID VARCHAR(255) null COMMENT "GUID to Identify post GENERATED ON CLIENT";
alter table likes_posts CHANGE post_GUID post_GUID VARCHAR(255) null COMMENT "GUID to Identify post GENERATED ON CLIENT";


update posts set posts .GUID = UUID();
alter table posts CHANGE GUID GUID VARCHAR(255) not null UNIQUE COMMENT "GUID to Identify post GENERATED ON CLIENT";

update posts_media set post_GUID = (SELECT GUID FROM posts ORDER BY RAND() LIMIT 1);
update posts_profiles set post_GUID = (SELECT GUID FROM posts ORDER BY RAND() LIMIT 1);
update likes_posts set post_GUID = (SELECT GUID FROM posts ORDER BY RAND() LIMIT 1);

alter table posts_media add PRIMARY KEY (post_GUID, media_id) COMMENT "Составной ключ";
alter table posts_profiles add PRIMARY KEY (post_GUID, profile_id) COMMENT "Составной ключ";

-- check on error
select lp.post_GUID,lp.profile_id,count(*) from likes_posts lp 
group by lp.post_GUID,lp.profile_id 
having count(CONCAT(lp.post_GUID,lp.profile_id)) >1 ; 

delete from likes_posts where post_GUID = ':x';
alter table likes_posts add PRIMARY KEY (post_GUID, profile_id) COMMENT "Составной ключ";

alter table likes_posts add Constraint post_GUID FOREIGN KEY (post_GUID) REFERENCES posts(GUID) ON DELETE CASCADE;
alter table posts_media add Constraint media_post_GUID FOREIGN KEY (post_GUID) REFERENCES posts(GUID) ON DELETE CASCADE;
alter table posts_profiles add Constraint profiles_post_GUID FOREIGN KEY (post_GUID) REFERENCES posts(GUID) ON DELETE CASCADE;


