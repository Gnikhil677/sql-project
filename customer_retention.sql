WITH DATA AS (
	SELECT 	customerkey,
	full_name,
 	orderdate,
 	row_number() over(PARTITION BY customerkey ORDER BY orderdate desc) AS rn,
	FIRST_purchase_date,
	cohort_year 
FROM cohort_analysis
),
churned_customers AS (
	SELECT customerkey, 
			full_name,
			orderdate AS last_purchase_date,
			CASE 
				WHEN orderdate::date > (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months' THEN 'ACTIVE'
				ELSE 'CHURNED'
			END	AS customer_status,
			cohort_year
	FROM DATA  
	WHERE rn = 1 AND (first_purchase_date < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months')
)
SELECT 
		cohort_year,
		customer_status,
		count(customerkey) AS num_customers,
		sum(count(customerkey)) OVER(partition BY cohort_year)AS total_customers,
		100 * round(count(customerkey) / sum(count(customerkey)) OVER(partition BY cohort_year), 4) AS percent
FROM churned_customers 
GROUP BY 
	cohort_year,
	customer_status 