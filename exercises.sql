
-- Exercise 3 
select count(*),'Female' as gender 
	from likes 
	where profile_id 
		in 
			(select profile_id from users where users.gender = 'F')
union all 
select count(*), 'Male' as gender 
	from likes 
	where profile_id 
		in 
			(select profile_id from users where users.gender = 'M');

		
		
-- exercise 4. Calculated total number of received likes to the main photos
select 
	target_id userphoto_id,
	count(*) likes, 
	(select 
		CONCAT_WS(' ',users.first_name,users.last_name,';gender -',users.gender,';date of birth -', users.birthday) 
	from users 
	where users.profile_id  = 
		(select profile_id  from media_profiles where media_id = userphoto_id)
	) as info
	from likes 
	where likes.target_id 
		in (
			select media_id 
				from media_profiles 
			join /* in + limit subquery is not allowed in this mysql version*/
			(select profile_id 
				from users 
				order by birthday desc limit 10) young 
			on media_profiles.profile_id  = young.profile_id
			where ismainphoto = 1
			) 
		and likes.target_type_id = 
		(select id 
			from target_types 
			where name ='media') 
		group by userphoto_id with ROLLUP 
		order by likes;
	
	

-- exercise 5. 
/* Criterias were
 * The Profile_id had a least number of sent likes
 *  messages and posts
 *  as well as had a least medias loaded  
 * */
select 
	activity.profile_id as act_profile,
	(select CONCAT_WS(' ', users.first_name,users.last_name) from users where users.profile_id = activity.profile_id) as full_name,
	sum(activity.cp) as total_actions_count
	from 
		(
			select likes.profile_id,count(profile_id) as cp, 'sent likes' as act from likes 
				where profile_id in (SELECT profile_id from users) 
				group by profile_id
			union all
			select posts.profile_id, count(profile_id) as cp,'sent posts' as act from posts 
				where profile_id in (SELECT profile_id from users)
				group by profile_id
			union all
			select media.user_profile_id , count(user_profile_id) as cp, 'loaded medias' as act from media 
				where user_profile_id in (SELECT profile_id from users) 
				group by user_profile_id 
			union all
			select messages.from_profile_id , count(from_profile_id) as cp, 'sent a message' as act from messages
				where from_profile_id in (SELECT profile_id from users) 
				group by from_profile_id
		) activity 
	group by profile_id 
	order by total_actions_count 
	limit 10;



		
