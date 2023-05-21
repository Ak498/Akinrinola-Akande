 /* This is a dataset about an online store that shows 4 distinct actions customers take which include:
 a.view
 b.cart
 c.remove from cart
 d. purchase
 It also contains other features such as time, product type, userid.
 The aim of this analysis is to answer a few questions about the data and discover insights in the data.
 */
 
 use project_1;

/*** view what event_time column looks like ***/
select * from project_1.events  limit 5;

/**remove time and utc from event_time column ***/
create  temporary table temp1 as
select left(event_time, position(' ' in event_time)-1) eventdate, 
		replace(right(event_time, position(' ' in event_time)+1),'UTC','') eventtime, e.* 
from events e ;

/**** drop unused column event_time ***/
Alter table temp1
drop column event_time;

/*** Answer questions about the data ****/

/***** 1. most purchased product ***/
select product_id, sum(price) Sales 
from events
where event_type ='purchase'
group by product_id 
order by sales desc limit 1;

/***** 2. Most viewed product ****/
select product_id, count(event_type) noofviews 
from events 
where event_type in ('view')
group by product_id 
order by noofviews desc limit 1;

/*** 3.Most viewed and least viewed product for each brand ****/
with cte as 
	(select brand, product_id, count(event_type) noofviews
	from events
    where event_type='view' and brand is not null
	group by brand, product_id),
cte2 as 
	(select *, dense_rank() over(partition by brand order by noofviews desc)rnk,
	first_value(product_id) over(partition by brand order by noofviews desc range between unbounded preceding and unbounded following)mostviewedproductid,
    last_value(product_id) over(partition by brand order by noofviews desc range between unbounded preceding and unbounded following)leastviewedproductid,
	last_value(noofviews) over(partition by brand order by noofviews desc range between unbounded preceding and unbounded following)leastviewedcount
    from cte)
select brand, product_id, mostviewedproductid,noofviews as mostviewedcount, leastviewedproductid,leastviewedcount,rnk
from cte2 
where rnk =1 
order by noofviews desc;

/***** 4. top 5 User with most views   ******/
select * from temp1 limit 3;
select user_id, count(event_type) Noofviews
from temp1 where event_type ='view'
group by user_id
order by Noofviews desc
limit 5;

/*** Top 5 brands with most revenue and product types sold ***/
select brand, sum(price) revenue, count(distinct product_id) noofproducts
from temp1
where event_type ='purchase'
group by brand
order by revenue desc
limit 5;