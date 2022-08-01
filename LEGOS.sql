--1
--Creating A VIEW To Simplify Querries

CREATE VIEW Analytics_main AS

	SELECT s.set_num, s.name AS set_name,s.year, s.theme_id, 
	CAST(s.num_parts AS numeric) num_parts, t.name AS theme_name, t.parent_id, 
	p.name AS parent_theme_name
FROM sets s
LEFT JOIN themes t
 ON s.theme_id = t.id
 LEFT JOIN themes p
 ON t.parent_id = p.id

 SELECT * FROM Analytics_main

 --What is the total number of parts per theme?

  SELECT * FROM Analytics_main;

  SELECT theme_name, SUM (num_parts) AS Total_Num_Parts
  FROM Analytics_main
  --WHERE parent_theme_name IS NOT NULL
  GROUP BY theme_name
  ORDER BY 2 DESC

   --What is the total number of parts per year?

   SELECT YEAR, SUM (num_parts) AS Total_Num_Parts
  FROM Analytics_main
  --WHERE parent_theme_name IS NOT NULL
  GROUP BY year
  ORDER BY 2 DESC

  --How many sets were created in each century in the dataset?

   SELECT Century, COUNT (set_num) AS Total_set_num
  FROM Analytics_main
  --WHERE parent_theme_name IS NOT NULL
  GROUP BY Century
  --ORDER BY 2 DESC

  --Percentage of sets created in the 21st Century with the Train theme

  WITH cte AS
  (
  SELECT Century, theme_name, COUNT (set_num) total_sets_created
  FROM Analytics_main
  WHERE Century = '21st Century'
  GROUP BY Century, theme_name
  --ORDER BY 3 DESC
  )
  SELECT Century, theme_name, total_sets_created, SUM (total_sets_created) OVER () AS Total, 
 ((total_sets_created/SUM (total_sets_created) * 100 AS Percentage
  FROM cte
  GROUP BY Century, theme_name

  --Most popular theme by year for the 21st Century

SELECT year, theme_name, total_set_num
FROM (
	   SELECT YEAR, theme_name, COUNT (set_num) AS Total_set_num, 
	   ROW_NUMBER () OVER (Partition by year ORDER BY COUNT (set_num) DESC) final
	  FROM Analytics_main
	  WHERE Century = '21st Century' 
	  AND parent_theme_name IS NOT NULL
	  GROUP BY year, theme_name
	  --ORDER BY year DESC
  )m
  WHERE final =1
  ORDER BY year DESC


  --Most produced LEGO color in quantity of parts

SELECT color_name, SUM (quantity) AS Quantity_of_parts
FROM 
(
	SELECT 
	inv.color_id, inv.inventory_id, inv.part_num, CAST (inv.quantity AS NUMERIC) Quantity, inv.is_spare, 
	c.name AS color_name, c.rgb, p.name AS part_name, p.part_material, pc.name AS category_name
	FROM inventory_parts inv
	INNER JOIN colors c
	ON inv.color_id = c.id
	INNER JOIN parts p
	ON inv.part_num = p.part_num
	INNER JOIN part_categories pc
	ON part_cat_id = pc.id
) main
GROUP BY color_name
ORDER BY 2 DESC