
-- replacing all VARCHAR ID from DB for simplify test VK scheme 

alter table posts change GUID ID Serial;
alter table posts_media change post_GUID ID BIGINT UNSIGNED NOT NULL;
alter table posts_profiles change post_GUID ID BIGINT UNSIGNED NOT NULL;

select * from target_types;
alter table messages add column ID BIGINT UNSIGNED;


-- vk.posts definition
Drop Table IF EXISTS posts;
CREATE TABLE `posts` (
  `profile_id` bigint unsigned NOT NULL COMMENT 'Ссылка на пользователя, который создал пост',
  `description` text COMMENT 'Бла-бла',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания строки',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Время обновления строки',
  `ID` bigint unsigned NOT NULL AUTO_INCREMENT,
  `parent_post_id` bigint unsigned DEFAULT NULL,
  `community_id` bigint unsigned DEFAULT NULL,
  `header` varchar(255) DEFAULT NULL,
  `is_public` tinyint(1) DEFAULT '1',
  `is_archived` tinyint(1) DEFAULT '0',
  UNIQUE KEY `ID` (`ID`)
);

drop table if exists likes;
CREATE TABLE likes (
id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  profile_id BIGINT UNSIGNED NOT NULL,
  target_id BIGINT UNSIGNED NOT NULL,
  target_type_id TINYINT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE INDEX(profile_id,target_id,target_type_id)
);

INSERT INTO likes (profile_id ,target_id,target_type_id,created_at)
  SELECT 
    FLOOR(1 + (RAND() * 200)), 
    FLOOR(1 + (RAND() * 500)),
    (select id from target_types where name ='media'),
    CURRENT_TIMESTAMP 
  FROM media limit 200;
  
insert into posts_media (ID,media_id) 
select 
(select id from posts order by rand() limit 1),
(select id from media order by rand() limit 1)
from media limit 100;

insert into posts_profiles (ID,profile_id) 
select 
(select id from posts order by rand() limit 1),
(select ID from profiles order by rand() limit 1)
from profiles limit 100;

update posts set parent_post_id = null where parent_post_id  = 0;

alter table posts add FOREIGN KEY posts_profile_id_profiles_id(profile_id) references profiles(id) on delete restrict;
alter table posts_media add FOREIGN KEY posts_media_id_posts_id(ID) references posts(id) on delete cascade;

-- TODO: think about how to change scheme to realise reposts functionality
alter table posts_profiles add FOREIGN KEY posts_profiles_id_posts_id(ID) references posts(id) on delete cascade;

alter table posts add FOREIGN KEY posts_parent_post_id_posts_id(parent_post_id) references posts(id) on delete cascade; -- delete all comments to post


alter table profiles add FOREIGN KEY profiles_city_id_cities_id(city_id) references cities(id) on delete set null;
alter table likes add FOREIGN KEY likes_profile_id_profiles_id(profile_id) references profiles(id) on delete restrict;

update likes set target_type_id  = (select id from target_types order by rand() LIMIT 1) where likes.target_type_id  = 4;
alter table likes add FOREIGN KEY likes_target_type_id_target_types_id(target_type_id) references target_types(id) on delete restrict;


alter table media_profiles add foreign key media_profiles_ID_profiles_id (profile_id) references profiles(id) on delete cascade;


