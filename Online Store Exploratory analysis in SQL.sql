 /* This is a dataset about an online store that shows 4 distinct actions customers take which include:
 a.view
 b.cart
 c.remove from cart
 d. purchase
 It also contains other features such as time, product type, userid.
 The aim of this analysis is to answer a few questions about the data and discover insights in the data.
 */
 
USE project_1;

/*** view what event_time column looks like ***/
SELECT 
  * 
FROM project_1.events  
LIMIT 5;

/**remove time and utc from event_time column ***/
CREATE  TEMPORARY TABLE temp1 AS
  SELECT 
    left(event_time, position(' ' in event_time)-1) eventdate
	, replace(right(event_time, position(' ' in event_time)+1),'UTC','') eventtime
	, e.* 
  FROM events e ;

/**** drop unused column event_time ***/
ALTER TABLE temp1
DROP column event_time;

/*** Answer questions about the data ****/

/***** 1. most purchased product ***/
SELECT 
  product_id
  , SUM(price) Sales 
FROM events
WHERE event_type ='purchase'
GROUP BY  product_id 
ORDER BY sales DESC
LIMIT 1;

/***** 2. Most viewed product ****/
SELECT 
  product_id
  , COUNT(event_type) noofviews 
FROM events 
WHERE event_type IN ('view')
GROUP BY product_id 
ORDER BY noofviews DESC 
LIMIT 1;

/*** 3.Most viewed and least viewed product for each brand ****/
WITH cte AS (
  SELECT 
	  brand
	  , product_id
	  , COUNT(event_type) noofviews
  FROM events
  WHERE event_type='view' 
	AND brand IS NOT NULL
  GROUP BY brand, product_id
)
,cte2 AS (
  SELECT 
	  *
	  ,DENSE_RANK() OVER(
      PARTITION BY brand 
      ORDER BY noofviews DESC
    ) rnk

	  ,FIRST_VALUE(product_id) OVER(
		  PARTITION BY brand 
		  ORDER BY noofviews DESC 
		  RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	  ) mostviewedproductid

    ,LAST_VALUE(product_id) OVER(
		  PARTITION BY brand 
		  ORDER BY noofviews DESC 
		  RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	  )leastviewedproductid

	 ,LAST_VALUE(noofviews) OVER(
		  PARTITION BY brand 
		  ORDER BY noofviews DESC 
		  RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	  )leastviewedcount
  FROM cte
)
SELECT 
  brand
  , product_id
  , mostviewedproductid
  , noofviews AS mostviewedcount
  , leastviewedproductid
  , leastviewedcount
  , rnk
FROM cte2 
WHERE rnk = 1 
ORDER BY noofviews DESC;

/***** 4. top 5 User with most views   ******/
SELECT 
  * 
FROM temp1 
LIMIT 5;

SELECT 
  user_id
  , COUNT(event_type) Noofviews
FROM temp1 
WHERE event_type ='view'
GROUP BY user_id
ORDER BY Noofviews DESC
LIMIT 5;

/*** Top 5 brands with most revenue and product types sold ***/
SELECT 
  brand
  , SUM(price) revenue
  , COUNT(DISTINCT product_id) noofproducts
FROM temp1
WHERE event_type ='purchase'
GROUP BY brand
ORDER BY revenue DESC
LIMIT 5;
