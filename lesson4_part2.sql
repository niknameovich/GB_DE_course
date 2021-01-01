-- пункт 1. 

select FLOOR(avg(timestampdiff(year,birthday_at,now()))) as 'users average age' from users;

-- пункт 2. 

select DAYNAME(
	STR_TO_DATE(
		CONCAT(YEAR(NOW()),'-', MONTH(birthday_at),'-', DAY(birthday_at)),
		'%Y-%m-%d')
	) as birthday,
	Group_concat(name) as names,
	count(*) as count  
from users 
group by birthday 
order by count;

-- пункт 3.

create temporary table tbl 
(
id serial,
value INT UNSIGNED
)
-- честно украденное из интернета решение 
SELECT EXP(SUM(LOG(value))) FROM tbl;

-- получилось сделать функцию перемножения также с помощью with recursive 
-- с оговоркой, если ID - AUTO INCREMENT и последовательный
with recursive multiple(mid,result) 
 as  
 ( 
select 1,1
union all  
select mid+1,
 result*(select value from tbl where id = mid) 
from multiple where mid<=10 
)
-- для вывода всех последовательных результатов
select * from multiple;
-- для вывода конечного результата
select MAX(result) from multiple;


