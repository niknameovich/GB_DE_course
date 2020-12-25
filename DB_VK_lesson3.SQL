-- Таблица профилей
CREATE TABLE IF NOT EXISTS profiles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Ссылка на пользователя", 
  description TEXT COMMENT "Say something interesting about you",
  email VARCHAR(100) NOT NULL UNIQUE COMMENT "Почта",
  phone VARCHAR(100) NOT NULL UNIQUE COMMENT "Телефон",
  city VARCHAR(130) COMMENT "Город проживания",
  country VARCHAR(130) COMMENT "Страна проживания",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Профили"; 

-- Создаём таблицу пользователей
CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки", 
  first_name VARCHAR(100) NOT NULL COMMENT "Имя пользователя",
  last_name VARCHAR(100) NOT NULL COMMENT "Фамилия пользователя",
  gender ENUM('M','F') NOT NULL COMMENT "Пол",
  birthday DATE COMMENT "Дата рождения",
  profile_id BIGINT UNSIGNED NOT NULL UNIQUE COMMENT "User profile",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки",
  Constraint profile_id_profiles FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE
) COMMENT "Пользователи";  



-- Таблица сообщений
CREATE TABLE IF NOT EXISTS messages (
  from_user_id BIGINT UNSIGNED NOT NULL COMMENT "Ссылка на отправителя сообщения",
  to_user_id BIGINT UNSIGNED NOT NULL COMMENT "Ссылка на получателя сообщения",
  body TEXT NOT NULL COMMENT "Текст сообщения",
  is_important BOOLEAN COMMENT "Признак важности",
  is_delivered BOOLEAN COMMENT "Признак доставки",
  created_at DATETIME DEFAULT NOW() not null COMMENT "Время создания строки",
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки",
  PRIMARY KEY(from_user_id,to_user_id,created_at),
  Constraint from_user_id_users FOREIGN KEY (from_user_id) REFERENCES users(id),
  Constraint to_user_id_users FOREIGN KEY (to_user_id) REFERENCES users(id) 
) COMMENT "Сообщения";

-- Таблица статусов отношений
CREATE TABLE IF NOT EXISTS statuses (
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
  name VARCHAR(150) NOT NULL UNIQUE COMMENT "Название статуса",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки" 
) COMMENT "Статусы дружбы";

-- Таблица отношений
CREATE TABLE IF NOT EXISTS relationships (
  user_id BIGINT UNSIGNED NOT NULL COMMENT "Ссылка на инициатора дружеских отношений",
  related_id BIGINT UNSIGNED COMMENT "Ссылка на получателя приглашения дружить",
  status_id TINYINT UNSIGNED COMMENT "Ссылка на статус (текущее состояние) отношений",
  requested_at DATETIME DEFAULT NOW() COMMENT "Время отправления приглашения дружить",
  confirmed_at DATETIME DEFAULT NOW() COMMENT "Время подтверждения приглашения",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки",  
  PRIMARY KEY (user_id, related_id) COMMENT "Составной первичный ключ",
  Constraint relationships_user_id_users FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  Constraint status_id_statuses FOREIGN KEY (status_id) REFERENCES statuses(id) ON DELETE SET NULL,
  Constraint related_id_users FOREIGN KEY (related_id) REFERENCES users(id) ON DELETE CASCADE
) COMMENT "Таблица дружбы";

-- Таблица групп
CREATE TABLE IF NOT EXISTS communities (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор сроки",
  user_id BIGINT UNSIGNED NOT NULL Comment "Admin Id",
  name VARCHAR(150) NOT NULL UNIQUE COMMENT "Название группы",
  profile_id BIGINT UNSIGNED NOT NULL UNIQUE COMMENT "Community Profile",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки",
  Constraint communities_profile_id_profiles FOREIGN KEY (profile_id) REFERENCES profiles(id) ,
  Constraint communities_user_id_users FOREIGN KEY (user_id) REFERENCES users(id) 
) COMMENT "Группы";

-- Таблица связи пользователей и групп
CREATE TABLE IF NOT EXISTS communities_users (
  community_id BIGINT UNSIGNED NOT NULL COMMENT "Ссылка на группу",
  user_id BIGINT UNSIGNED NOT NULL COMMENT "Ссылка на пользователя",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки", 
  PRIMARY KEY (community_id, user_id) COMMENT "Составной первичный ключ",
  Constraint community_id_communities FOREIGN KEY (community_id) REFERENCES communities(id) ON DELETE CASCADE,
  Constraint communities_users_user_id_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) COMMENT "Участники групп, связь между пользователями и группами";

-- Таблица типов медиафайлов
CREATE TABLE IF NOT EXISTS media_types (
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
  name VARCHAR(255) NOT NULL UNIQUE COMMENT "Название типа",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Типы медиафайлов";

-- Таблица медиафайлов
CREATE TABLE IF NOT EXISTS media (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
  user_id BIGINT UNSIGNED COMMENT "Ссылка на пользователя, который загрузил файл",
  filename VARCHAR(255) NOT NULL COMMENT "Путь к файлу",
  size INT NOT NULL COMMENT "Размер файла",
  metadata JSON COMMENT "Метаданные файла",
  media_type_id TINYINT UNSIGNED NOT NULL COMMENT "Ссылка на тип контента",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки",
  Constraint user_id_users FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  Constraint type_id_media_types FOREIGN KEY (media_type_id) REFERENCES media_types(id) ON DELETE CASCADE
) COMMENT "Медиафайлы";

CREATE TABLE IF NOT EXISTS media_profiles (
  media_id BIGINT UNSIGNED NOT NULL COMMENT "Ссылка на media",
  profile_id BIGINT UNSIGNED NOT NULL COMMENT "Ссылка на host profile",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки", 
  ismainphoto BOOL DEFAULT FALSE NOT NULL COMMENT "main profile photo",
  PRIMARY KEY (media_id, profile_id) COMMENT "Составной первичный ключ",
  Constraint media_id_media FOREIGN KEY (media_id) REFERENCES media(id) ON DELETE CASCADE,
  Constraint media_profiles_profile_id_profiles FOREIGN KEY (media_id) REFERENCES profiles(id) ON DELETE CASCADE
) COMMENT "User and Community files, relation between media and profile";


-- Таблица постов
CREATE TABLE IF NOT EXISTS posts (
  profile_id BIGINT UNSIGNED NOT NULL COMMENT "Ссылка на пользователя, который создал пост",
  description TEXT COMMENT "Бла-бла",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки",
  GUID VARCHAR(255) not null UNIQUE COMMENT "GUID to Identify post GENERATED ON CLIENT",
  PRIMARY KEY (profile_id,created_at) COMMENT "составной ключ с ограничением 1 пост одновременно с 1го профиля",
  Constraint profile_id_profiles FOREIGN KEY (profile_id) REFERENCES profiles(id) 
) COMMENT "пост";

CREATE TABLE IF NOT EXISTS posts_profiles (
  post_GUID VARCHAR(255) NOT NULL COMMENT "Ссылка на пост",
  profile_id BIGINT UNSIGNED NOT NULL COMMENT "Ссылка на профиль репостнувшего",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Когда был совершен репост", 
  PRIMARY KEY (post_GUID, profile_id) COMMENT "Составной первичный ключ",
  Constraint post_GUID_profiles FOREIGN KEY (post_GUID) REFERENCES posts(GUID) ON DELETE CASCADE,
  Constraint post_profile_id_profiles FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE
) COMMENT "REPOSTS";

CREATE TABLE IF NOT EXISTS posts_media (
  post_GUID VARCHAR(255) NOT NULL COMMENT "ссылка на пост",
  media_id BIGINT UNSIGNED NOT NULL COMMENT "ссылка на файл",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "дата создания", 
  PRIMARY KEY (post_GUID, media_id) COMMENT "Составной ключ",
  Constraint post_GUID FOREIGN KEY (post_GUID) REFERENCES posts(GUID) ON DELETE CASCADE,
  Constraint media_id FOREIGN KEY (media_id) REFERENCES media(id) ON DELETE CASCADE
) COMMENT "Файлы в постах";

CREATE TABLE IF NOT EXISTS  likes_media (
  user_id BIGINT UNSIGNED NOT NULL COMMENT "ссылка на user",
  media_id BIGINT UNSIGNED NOT NULL COMMENT "ссылка на файл",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "дата создания", 
  PRIMARY KEY (user_id, media_id) COMMENT "Составной ключ",
  Constraint user_id_likes FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  Constraint media_id_likes FOREIGN KEY (media_id) REFERENCES media(id) ON DELETE CASCADE
) COMMENT "likes to media";

CREATE TABLE  IF NOT EXISTS likes_posts (
  user_id BIGINT UNSIGNED NOT NULL COMMENT "user",
  post_GUID VARCHAR(255) NOT NULL COMMENT "post key",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "created", 
  PRIMARY KEY (user_id, post_GUID) COMMENT "PK",
  Constraint user_id_likesposts FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  Constraint post_GUID_likesposts FOREIGN KEY (post_GUID) REFERENCES posts(GUID) ON DELETE CASCADE
) COMMENT "likes to whole posts";