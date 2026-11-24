
#List all of the bike lanes that have an average safety rating of 4.0 or higher
#Show average safety ratings for  each bike lane & label "Safe Lane"
/*Getting an overview of the data*/

select * from CityBikeLanes;


/*List all of the bike lanes that have an average safety rating of 4.0 or higher
--Show average safety ratings for  each bike lane & label "Safe Lane" */
with safety_average_cte as (
select street, avg(safety_rating) as 'rating'
from citybikelanes
group by street)

select street, rating, 'Safe Lane' as 'Label'
from safety_average_cte
where rating >=4;

/* Giving the bike lane a safety rating and average safety rating using the window funct */
select street, safety_rating, avg(safety_rating) over (partition by street) as 'average_safety_rating'
from CityBikeLanes;

select street, safety_rating,
avg(safety_rating) over (partition by street) as 'average_safety_rating'
from CityBikeLanes
where street='2nd';

/* list of all the bike lanes, both safety ratings for each lane, the average safety rating for each lane, 
--and a label with the recommendation as "Remove", "Leave As-Is", or "Improvements Needed" */

with lane_average as(
	select 
		street,
        safety_rating,
        avg(safety_rating) over(partition by street) as average_safety_rating,
        count(safety_rating) over(partition by street) as rating_count
	from CityBikeLanes
)
select
	street,
    safety_rating,
    round(average_safety_rating, 2) as average_safety_rating,
    case
		when average_safety_rating >= 4.0 then 'Leave As-Is'
        when average_safety_rating < 2.5 then 'Remove'
		else 'Improvements Needed'
	end as recommendation
from lane_average;

/*street level metrics & executive sumamry*/
with street_summary as (
select
    street,
    count(safety_rating) as rating_count,
    round(avg(safety_rating),2) as average_safety_rating,
    min(safety_rating) as min_rating,
    max(safety_rating) as max_rating,
    case
		when avg(safety_rating) >= 4.0 then 'Leave As-Is'
        when avg(safety_rating) < 2.5 then 'Remove'
        else 'Improvements Needed'
	end as recommendation
from CityBikeLanes
group by street
)
select
	recommendation,
    count(*) as street_count,
    round(100.0 * count(*) / sum(count(*)) over (),2) as pct_of_streets,
    sum(rating_count) as total_ratings
from street_summary
group by recommendation
order by street_count desc;

