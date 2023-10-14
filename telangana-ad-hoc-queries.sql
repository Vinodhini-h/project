-- adhoc questions--

-- Stamp Registration
-- 1. How does the revenue generated from document registration vary 
-- across districts in Telangana? List down the top 5 districts that showed
-- the highest document registration revenue growth between FY 2019
-- and 2022.

USE project1;
SELECT DISTINCT(dim_districts.district) AS District, SUM(fact_stamps.documents_registered_rev)
AS Total_revenue_for_document_registration_2019_to_2022
FROM fact_stamps
INNER JOIN dim_districts
ON fact_stamps.dist_code = dim_districts.dist_code
INNER JOIN dim_date
ON fact_stamps.month = dim_date.month
WHERE dim_date.fiscal_year IN ('2019', '2020','2021','2022')
GROUP BY dim_districts.district
ORDER BY Total_revenue_for_document_registration_2019_to_2022 DESC
LIMIT 5;

SELECT * FROM fact_stamps;

SELECT COUNT(estamps_challans_cnt)
FROM fact_stamps;

SELECT * FROM dim_date;

-- 2. How does the revenue generated from document registration compare
-- to the revenue generated from e-stamp challans across districts? List
-- down the top 5 districts where e-stamps revenue contributes
-- significantly more to the revenue than the documents in FY 2022?

WITH CTE_revenue AS
(SELECT dim_districts.district, SUM(fact_stamps.estamps_challans_rev) AS estamps_total_rev,
SUM(fact_stamps.documents_registered_rev) AS documents_total_rev
FROM fact_stamps
INNER JOIN dim_districts
ON fact_stamps.dist_code = dim_districts.dist_code
WHERE YEAR(month) = 2022
GROUP BY dim_districts.district
LIMIT 5)
SELECT * , estamps_total_rev-documents_total_rev AS Count_estamps_more_than_documents
FROM CTE_revenue
WHERE estamps_total_rev > documents_total_rev
ORDER BY Count_estamps_more_than_documents DESC ;

-- 3. Is there any alteration of e-Stamp challan count and document
-- registration count pattern since the implementation of e-Stamp
-- challan? If so, what suggestions would you propose to the government?

WITH CTE_estamps AS
(SELECT
  CASE
    WHEN MONTH(month) >= 4 THEN YEAR(month)
    ELSE YEAR(month) - 1
  END AS fiscal_year,
  AVG(documents_registered_cnt) AS avg_documents_registered,
  AVG(estamps_challans_cnt) AS avg_estamps_challans
FROM fact_stamps
GROUP BY fiscal_year
ORDER BY fiscal_year)
SELECT * , avg_documents_registered-avg_estamps_challans AS diff
FROM CTE_estamps;

-- 4. Categorize districts into three segments based on their stamp
-- registration revenue generation during the fiscal year 2021 to 2022.

SELECT dim_districts.district, SUM(fact_stamps.estamps_challans_rev) AS total_revenue,
    CASE 
        WHEN SUM(estamps_challans_rev) < 1000000000 THEN 'Low'
        WHEN SUM(estamps_challans_rev) > 1000000000 AND SUM(estamps_challans_rev) < 10000000000 THEN 'Medium'
        ELSE 'High'
    END as Revenue_category
FROM fact_stamps
INNER JOIN dim_districts
ON fact_stamps.dist_code = dim_districts.dist_code
WHERE YEAR(month) IN ('2021','2022')
GROUP BY dim_districts.district
ORDER BY total_revenue DESC;  

-- Transportation
-- 5. Investigate whether there is any correlation between vehicle sales and
-- specific months or seasons in different districts. Are there any months
-- or seasons that consistently show higher or lower sales rate, and if yes,
-- what could be the driving factors? (Consider Fuel-Type category only)


SELECT dim_districts.district, EXTRACT(MONTH FROM month) AS sales_month,
SUM(fuel_type_petrol+fuel_type_diesel+fuel_type_electric+fuel_type_others) AS total_sales
FROM fact_transport
INNER JOIN dim_districts
ON fact_transport.dist_code = dim_districts.dist_code
GROUP BY sales_month,dim_districts.district
ORDER BY sales_month,total_sales DESC;

-- 6. How does the distribution of vehicles vary by vehicle class
-- (MotorCycle, MotorCar, AutoRickshaw, Agriculture) across different
-- districts? Are there any districts with a predominant preference for a
-- specific vehicle class? Consider FY 2022 for analysis.

SELECT dim_districts.district, SUM(vehicleClass_MotorCycle) AS Total_MotorCycle_sales, 
SUM(vehicleClass_MotorCar) AS Total_MotorCar_sales, 
SUM(vehicleClass_AutoRickshaw) AS Total_AutoRickshaw_sales
FROM fact_transport
INNER JOIN dim_districts
ON fact_transport.dist_code = dim_districts.dist_code
WHERE YEAR(month) = 2022
GROUP BY dim_districts.district; 

-- 7. List down the top 3 and bottom 3 districts that have shown the highest
-- and lowest vehicle sales growth during FY 2022 compared to FY
-- 2021? (Consider and compare categories: Petrol, Diesel and Electric)

WITH CTE_total_sales AS
(SELECT dim_districts.district,
SUM(CASE WHEN YEAR(month) = 2021 
         THEN (fuel_type_petrol+ fuel_type_diesel+fuel_type_electric+fuel_type_others) ELSE 0 END) AS Total_sales_2021,
SUM(CASE WHEN YEAR(month) = 2022
	     THEN (fuel_type_petrol+ fuel_type_diesel+fuel_type_electric+fuel_type_others) ELSE 0 END) AS Total_sales_2022
FROM fact_transport
INNER JOIN dim_districts
ON fact_transport.dist_code = dim_districts.dist_code
GROUP BY dim_districts.district)
SELECT district, Total_sales_2021, Total_sales_2022, Total_sales_2022-Total_sales_2021 AS Sales_growth
FROM CTE_total_sales
ORDER BY Sales_growth DESC
LIMIT 3;


WITH CTE_total_sales AS
(SELECT dim_districts.district,
SUM(CASE WHEN YEAR(month) = 2021 
         THEN (fuel_type_petrol+ fuel_type_diesel+fuel_type_electric+fuel_type_others) ELSE 0 END) AS Total_sales_2021,
SUM(CASE WHEN YEAR(month) = 2022
	     THEN (fuel_type_petrol+ fuel_type_diesel+fuel_type_electric+fuel_type_others) ELSE 0 END) AS Total_sales_2022
FROM fact_transport
INNER JOIN dim_districts
ON fact_transport.dist_code = dim_districts.dist_code
GROUP BY dim_districts.district)
SELECT district, Total_sales_2021, Total_sales_2022, Total_sales_2022-Total_sales_2021 AS Sales_growth
FROM CTE_total_sales
ORDER BY Sales_growth
LIMIT 3;


-- Ts-Ipass (Telangana State Industrial Project Approval and Self Certification System)
-- 8. List down the top 5 sectors that have witnessed the most significant
-- investments in FY 2022.


SELECT sector, SUM(investment_in_cr) AS Total_investment
FROM fact_ts_ipass
WHERE month LIKE '%2022%'
GROUP BY sector
ORDER BY Total_investment DESC
LIMIT 5;

-- 9. List down the top 3 districts that have attracted the most significant
-- sector investments during FY 2019 to 2022? What factors could have
-- led to the substantial investments in these particular districts?

SELECT * FROM fact_ts_ipass;
SELECT dim_districts.district, sector, SUM(investment_in_cr) AS Total_investment
FROM fact_ts_ipass
INNER JOIN dim_districts
ON fact_ts_ipass.dist_code = dim_districts.dist_code
WHERE month LIKE '%2019%' OR '%2021%' OR '%2022%'
GROUP BY dim_districts.district, sector
ORDER BY Total_investment DESC
LIMIT 3;

-- 10. Is there any relationship between district investments, vehicles
-- sales and stamps revenue within the same district between FY 2021
-- and 2022?

WITH CTE_main AS
(SELECT dim_districts.district, AVG(investment_in_cr) AS Avg_direct_investment,
AVG(documents_registered_rev+estamps_challans_rev) AS Avg_stamps_revenue,
AVG(fuel_type_petrol+fuel_type_diesel+fuel_type_electric+fuel_type_others) AS Avg_vehicle
FROM dim_districts
INNER JOIN fact_ts_ipass
ON dim_districts.dist_code = fact_ts_ipass.dist_code
INNER JOIN fact_stamps
ON dim_districts.dist_code = fact_stamps.dist_code
INNER JOIN fact_transport
ON dim_districts.dist_code = fact_transport.dist_code
GROUP BY dim_districts.district)
SELECT dim_districts.district, ROUND(Avg_direct_investment,2) AS Avg_direct_investment_in_cr,
ROUND((Avg_stamps_revenue/10000000),2) AS Avg_stamps_revenue_in_cr, 
ROUND(Avg_vehicle, 0) AS Avg_vehicle_sales  
FROM CTE_main;

-- 11. Are there any particular sectors that have shown substantial
-- investment in multiple districts between FY 2021 and 2022?

SELECT * FROM fact_ts_ipass;


SELECT fact_ts_ipass.sector, SUM(fact_ts_ipass.investment_in_cr) AS Total_investment_in_cr, COUNT(dim_districts.district) AS Sector_Count
FROM fact_ts_ipass
INNER JOIN dim_districts
ON fact_ts_ipass.dist_code = dim_districts.dist_code
WHERE fact_ts_ipass.month LIKE '%2021%' OR fact_ts_ipass.month LIKE '%2022%'
GROUP BY fact_ts_ipass.sector
ORDER BY Total_investment_in_cr DESC;







