WITH customer_ltv AS (
	SELECT
		customerkey,
		full_name ,
		SUM(net_revenue) AS total_ltv
	FROM cohort_analysis 
	GROUP BY customerkey,
			full_name
), percentiles AS (
	SELECT 
		PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_ltv) AS percentile_25th,
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_ltv) AS percentile_75th
	FROM customer_ltv 
), segmented AS (
	SELECT c.*,
		CASE 
			WHEN c.total_ltv < p.percentile_25th THEN '1 - Low Value'
			WHEN c.total_ltv > p.percentile_75th THEN '3 - High Value'
			ELSE '2 - Mid Value'
		END AS customer_segment
	FROM customer_ltv c, percentiles p
)
SELECT customer_segment,
		sum(total_ltv) AS total_rev,
		count(customerkey) AS Num_customers,
		sum(total_ltv) / count(customerkey) AS avg_ltv
FROM segmented
GROUP BY customer_segment 
ORDER BY customer_segment 