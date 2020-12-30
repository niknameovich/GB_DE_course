drop database if exists vk;
CREATE DATABASE vk;
use vk;

-- ������� ��������
CREATE TABLE IF NOT EXISTS profiles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "������ �� ������������", 
  description TEXT COMMENT "Say something interesting about you",
  email VARCHAR(100) NOT NULL UNIQUE COMMENT "�����",
  phone VARCHAR(100) NOT NULL UNIQUE COMMENT "�������",
  city VARCHAR(130) COMMENT "����� ����������",
  country VARCHAR(130) COMMENT "������ ����������",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "����� �������� ������",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "����� ���������� ������",
  deleted_at DATETIME DEFAULT NULL COMMENT "Deleted time"
) COMMENT "�������"; 

-- ������ ������� �������������
CREATE TABLE IF NOT EXISTS users (
  profile_id BIGINT UNSIGNED NOT NULL PRIMARY KEY COMMENT "User profile",  
  first_name VARCHAR(100) NOT NULL COMMENT "��� ������������",
  last_name VARCHAR(100) NOT NULL COMMENT "������� ������������",
  gender ENUM('M','F') NOT NULL COMMENT "���",
  birthday DATE COMMENT "���� ��������",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "����� �������� ������",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "����� ���������� ������",
  Constraint profile_id_profiles FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE
) COMMENT "������������";  



-- ������� ���������
CREATE TABLE IF NOT EXISTS messages (
  from_profile_id BIGINT UNSIGNED NOT NULL COMMENT "������ �� ����������� ���������",
  to_profile_id BIGINT UNSIGNED NOT NULL COMMENT "������ �� ���������� ���������",
  body TEXT NOT NULL COMMENT "����� ���������",
  is_important BOOLEAN COMMENT "������� ��������",
  is_delivered BOOLEAN COMMENT "������� ��������",
  is_received BOOLEAN COMMENT "Received",
  created_at DATETIME DEFAULT NOW() not null COMMENT "����� �������� ������",
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "����� ���������� ������",
  PRIMARY KEY(from_profile_id,to_profile_id,created_at),
  Constraint from_profile_id_users FOREIGN KEY (from_profile_id) REFERENCES profiles(id),
  Constraint to_profile_id_users FOREIGN KEY (to_profile_id) REFERENCES profiles(id) 
) COMMENT "���������";

-- ������� �������� ���������
CREATE TABLE IF NOT EXISTS statuses (
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "������������� ������",
  name VARCHAR(150) NOT NULL UNIQUE COMMENT "�������� �������",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "����� �������� ������",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "����� ���������� ������" 
) COMMENT "������� ������";

-- ������� ���������
CREATE TABLE IF NOT EXISTS relationships (
  from_profile_id BIGINT UNSIGNED NOT NULL COMMENT "������ �� ���������� ��������� ���������",
  to_profile_id BIGINT UNSIGNED COMMENT "������ �� ���������� ����������� �������",
  status_id TINYINT UNSIGNED COMMENT "������ �� ������ (������� ���������) ���������",
  requested_at DATETIME DEFAULT NOW() COMMENT "����� ����������� ����������� �������",
  confirmed_at DATETIME DEFAULT NOW() COMMENT "����� ������������� �����������",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "����� �������� ������",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "����� ���������� ������",  
  PRIMARY KEY (from_profile_id, to_profile_id) COMMENT "��������� ��������� ����",
  Constraint relationships_from_profile_id_users FOREIGN KEY (from_profile_id) REFERENCES users(profile_id) ON DELETE CASCADE,
  Constraint relationships_to_profile_id_users FOREIGN KEY (to_profile_id) REFERENCES users(profile_id) ON DELETE CASCADE,
  Constraint status_id_statuses FOREIGN KEY (status_id) REFERENCES statuses(id) ON DELETE SET NULL
) COMMENT "All users relations";

-- ������� �����
CREATE TABLE IF NOT EXISTS communities (
  user_profile_id BIGINT UNSIGNED NOT NULL Comment "Creator Id",
  name VARCHAR(150) NOT NULL UNIQUE COMMENT "�������� ������",
  profile_id BIGINT UNSIGNED NOT NULL UNIQUE COMMENT "Community Profile",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "����� �������� ������",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "����� ���������� ������",
  Constraint communities_profile_id_profiles FOREIGN KEY (profile_id) REFERENCES profiles(id) ,
  Constraint communities_user_profile_id_users FOREIGN KEY (user_profile_id) REFERENCES users(profile_id) 
) COMMENT "������";

-- ������� ����� ������������� � �����
CREATE TABLE IF NOT EXISTS communities_users (
  community_profile_id BIGINT UNSIGNED NOT NULL COMMENT "������ �� ������",
  user_profile_id BIGINT UNSIGNED NOT NULL COMMENT "������ �� ������������",
  status_id TINYINT UNSIGNED NOT NULL COMMENT "User status in community",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "����� �������� ������",
  PRIMARY KEY (community_profile_id, user_profile_id, status_id) COMMENT "��������� ��������� ����",
  Constraint community_id_communities FOREIGN KEY (community_profile_id) REFERENCES communities(profile_id) ON DELETE CASCADE,
  Constraint communities_users_user_id_user FOREIGN KEY (user_profile_id) REFERENCES users(profile_id) ON DELETE CASCADE,
  Constraint communities_users_status_id_statuses FOREIGN KEY (status_id) REFERENCES statuses(id) ON DELETE CASCADE
) COMMENT "��������� �����, ����� ����� �������������� � ��������";

-- ������� ����� �����������
CREATE TABLE IF NOT EXISTS media_types (
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "������������� ������",
  name VARCHAR(255) NOT NULL UNIQUE COMMENT "�������� ����",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "����� �������� ������",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "����� ���������� ������"
) COMMENT "���� �����������";

-- ������� �����������
CREATE TABLE IF NOT EXISTS media (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "������������� ������",
  user_profile_id BIGINT UNSIGNED COMMENT "������ �� ������������, ������� �������� ����",
  filename VARCHAR(255) NOT NULL COMMENT "���� � �����",
  filesize INT NOT NULL COMMENT "������ �����",
  metadata JSON COMMENT "���������� �����",
  media_type_id TINYINT UNSIGNED NOT NULL COMMENT "������ �� ��� ��������",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "����� �������� ������",
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "����� ���������� ������",
  Constraint user_id_users FOREIGN KEY (user_profile_id) REFERENCES users(profile_id) ON DELETE SET NULL,
  Constraint type_id_media_types FOREIGN KEY (media_type_id) REFERENCES media_types(id) ON DELETE CASCADE
) COMMENT "����������";

CREATE TABLE IF NOT EXISTS media_profiles (
  media_id BIGINT UNSIGNED NOT NULL COMMENT "������ �� media",
  profile_id BIGINT UNSIGNED NOT NULL COMMENT "������ �� host profile",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "����� �������� ������", 
  ismainphoto BOOL DEFAULT FALSE NOT NULL COMMENT "main profile photo",
  PRIMARY KEY (media_id, profile_id) COMMENT "��������� ��������� ����",
  Constraint media_id_media FOREIGN KEY (media_id) REFERENCES media(id) ON DELETE CASCADE,
  Constraint media_profiles_profile_id_profiles FOREIGN KEY (media_id) REFERENCES profiles(id) ON DELETE CASCADE
) COMMENT "User and Community files, relation between media and profile";


-- ������� ������
CREATE TABLE IF NOT EXISTS posts (
  profile_id BIGINT UNSIGNED NOT NULL COMMENT "������ �� ������������, ������� ������ ����",
  description TEXT COMMENT "���-���",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "����� �������� ������",
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "����� ���������� ������",
  GUID VARCHAR(255) not null UNIQUE COMMENT "GUID to Identify post GENERATED ON CLIENT",
  PRIMARY KEY (profile_id,created_at) COMMENT "��������� ���� � ������������ 1 ���� ������������ � 1�� �������",
  Constraint posts_profile_id_profiles FOREIGN KEY (profile_id) REFERENCES profiles(id) 
) COMMENT "����";

CREATE TABLE IF NOT EXISTS posts_profiles (
  post_GUID VARCHAR(255) NOT NULL COMMENT "������ �� ����",
  profile_id BIGINT UNSIGNED NOT NULL COMMENT "������ �� ������� �������������",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "����� ��� �������� ������", 
  PRIMARY KEY (post_GUID, profile_id) COMMENT "��������� ��������� ����",
  Constraint post_GUID_profiles FOREIGN KEY (post_GUID) REFERENCES posts(GUID) ON DELETE CASCADE,
  Constraint post_profile_id_profiles FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE
) COMMENT "REPOSTS";

CREATE TABLE IF NOT EXISTS posts_media (
  post_GUID VARCHAR(255) NOT NULL COMMENT "������ �� ����",
  media_id BIGINT UNSIGNED NOT NULL COMMENT "������ �� ����",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "���� ��������", 
  PRIMARY KEY (post_GUID, media_id) COMMENT "��������� ����",
  Constraint post_GUID FOREIGN KEY (post_GUID) REFERENCES posts(GUID) ON DELETE CASCADE,
  Constraint media_id FOREIGN KEY (media_id) REFERENCES media(id) ON DELETE CASCADE
) COMMENT "����� � ������";

CREATE TABLE IF NOT EXISTS  likes_media (
  profile_id BIGINT UNSIGNED NOT NULL COMMENT "������ �� user",
  media_id BIGINT UNSIGNED NOT NULL COMMENT "������ �� ����",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "���� ��������", 
  PRIMARY KEY (profile_id, media_id) COMMENT "��������� ����",
  Constraint profile_id_likes FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE,
  Constraint media_id_likes FOREIGN KEY (media_id) REFERENCES media(id) ON DELETE CASCADE
) COMMENT "likes to media";

CREATE TABLE  IF NOT EXISTS likes_posts (
  profile_id BIGINT UNSIGNED NOT NULL COMMENT "Profile",
  post_GUID VARCHAR(255) NOT NULL COMMENT "post key",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "created", 
  PRIMARY KEY (profile_id, post_GUID) COMMENT "PK",
  Constraint profile_id_likesposts FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE,
  Constraint post_GUID_likesposts FOREIGN KEY (post_GUID) REFERENCES posts(GUID) ON DELETE CASCADE
) COMMENT "likes to whole posts";