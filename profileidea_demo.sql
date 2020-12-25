select c.name,p2.description , u.first_name,u.last_name , p.city ,p.country from communities_users cu
join communities c  on cu.community_id  = c.id  
join users u on cu.user_id  = u.id 
join profiles p on p.id  = u.id 
join profiles p2  on p2.id = c.id ;
