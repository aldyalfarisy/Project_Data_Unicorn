SELECT * FROM unicorn_companies
SELECT * FROM unicorn_dates
SELECT * FROM unicorn_funding
SELECT * FROM unicorn_industries


-- BENUA YANG MEMILIKI UNICORN TERBANYAK 
SELECT continent,
		COUNT(DISTINCT company_id) AS total_company

FROM unicorn_companies
GROUP BY continent
ORDER BY 2 desc


-- NEGARA YANG MEMILIKI DIATAS 100 UNICORN
SELECT country,	
	COUNT(DISTINCT company_id) AS total_company
FROM unicorn_companies
GROUP by country
HAVING COUNT (DISTINCT company_id) > 100
ORDER by 2 desc



-- Industri apa yang paling besar di antara unicorn company berdasarkan total fundingnya? 
-- Berapa rata-rata valuasinya?

SELECT ui.industry,
		SUM(uf.funding) AS Total_funding,
		ROUND(AVG(uf.valuation),0) AS avg_valuation
FROM unicorn_industries ui
INNER JOIN unicorn_funding uf ON 
		ui.company_id = uf.company_id
GROUP BY 1
ORDER BY 2 DESC


--  berapakah jumlah company yang bergabung sebagai unicorn di tiap tahunnya di rentang tahun 2016-2022?

SELECT * FROM ( SELECT uc.company,
		EXTRACT (YEAR FROM ud.date_joined) AS year_joined,
		ui.industry
FROM unicorn_companies uc
INNER JOIN unicorn_dates ud
			ON uc.company_id = ud.company_id
INNER JOIN unicorn_industries ui
		ON uc.company_id = ui.company_id
		) x
WHERE year_joined 
			BETWEEN '2016' AND '2022'
AND industry = 'Fintech'


-- Tampilkan data detail company (nama company, kota asal, negara dan benua asal) 
-- beserta industri dan valuasinya. Dari negara mana company dengan valuasi terbesar berasal dan apa industrinya?
-- Bagaimana dengan Indonesia? Company apa yang memiliki valuasi paling besar di Indonesia?

SELECT * FROM unicorn_companies
SELECT * FROM unicorn_dates
SELECT * FROM unicorn_funding
SELECT * FROM unicorn_industries


SELECT * FROM ( SELECT uc.company,
		uc.city,
		uc.country,
		uc.continent,
		ui.industry,
		uf.valuation
FROM unicorn_companies uc
INNER JOIN unicorn_industries ui
				ON uc.company_id = ui.company_id
INNER JOIN unicorn_funding uf
				ON uc.company_id = uf.company_id
	
ORDER BY uf.valuation DESC
) x
WHERE country = 'Indonesia'


--Berapa umur company tertua ketika company tersebut bergabung menjadi unicorn company? 
-- Dari negara mana company tersebut berasal?

SELECT
	uc.*,
	ud.date_joined,
	ud.year_founded,
	EXTRACT(YEAR FROM ud.date_joined) - ud.year_founded AS company_age
FROM unicorn_companies uc 
INNER JOIN unicorn_dates ud 
	ON uc.company_id = ud.company_id 
ORDER BY company_age DESC

-- Untuk company yang didirikan tahun antara tahun 1960 dan 2000 (batas atas dan bawah masuk ke dalam rentang), 
-- berapa umur company tertua ketika company tersebut bergabung menjadi unicorn company (date_joined)?

SELECT
	uc.*,
	ud.date_joined,
	ud.year_founded,
	EXTRACT(YEAR FROM ud.date_joined) - ud.year_founded AS company_age
FROM unicorn_companies uc 
INNER JOIN unicorn_dates ud 
	ON uc.company_id = ud.company_id 
	AND ud.year_founded BETWEEN 1960 AND 2000
ORDER BY company_age DESC

-- Ada berapa company yang dibiayai oleh minimal satu investor yang mengandung nama ‘venture’

SELECT
	COUNT(DISTINCT company_id) AS total_company
FROM unicorn_funding uf
WHERE LOWER(select_investors) LIKE '%venture%'


--  Ada berapa company yang dibiayai oleh minimal satu investor yang mengandung nama:
-- Venture, Capital, Partner
SELECT
	COUNT(DISTINCT CASE WHEN LOWER(select_investors) LIKE '%venture%' THEN company_id END) AS investor_venture,
	COUNT(DISTINCT CASE WHEN LOWER(select_investors) LIKE '%capital%' THEN company_id END) AS investor_capital,
	COUNT(DISTINCT CASE WHEN LOWER(select_investors) LIKE '%partner%' THEN company_id END) AS investor_partner
FROM unicorn_funding uf 


--   Ada berapa startup logistik yang termasuk unicorn di Asia? 
-- Berapa banyak startup logistik yang termasuk unicorn di Indonesia

SELECT
	COUNT(DISTINCT CASE WHEN  uc.continent = 'Asia' THEN uc.company_id END) AS total_asia,
	COUNT(DISTINCT CASE WHEN uc.country = 'Indonesia' THEN uc.company_id END) AS total_indonesia
FROM unicorn_companies uc 
INNER JOIN unicorn_industries ui 
	ON uc.company_id = ui.company_id
WHERE ui.industry = '"Supply chain, logistics, & delivery"' AND uc.continent = 'Asia'


-- Di Asia terdapat tiga negara dengan jumlah unicorn terbanyak. 
-- Tampilkan data jumlah unicorn di tiap industri dan negara asal di Asia, terkecuali tiga negara tersebut. 
-- Urutkan berdasarkan industri, jumlah company (menurun), dan negara asal.

WITH top_3 as ( 
	SELECT uc.country,
		COUNT(DISTINCT uc.company_id) as total_company
		
FROM unicorn_companies uc
WHERE uc.continent = 'Asia'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3
)

SELECT 	uc.continent,
		ui.industry,
		COUNT(DISTINCT uc.company_id) AS total_company
FROM unicorn_companies uc
INNER JOIN unicorn_industries ui
ON uc.company_id = ui.company_id
WHERE uc.continent = 'Asia'
AND uc.country	NOT IN (
	SELECT
		DISTINCT country
	FROM top_3
)
GROUP BY 1,2
ORDER BY 3 DESC,2


-- Amerika Serikat, China, dan India adalah tiga negara dengan jumlah unicorn paling banyak. 
-- Apakah ada industri yang tidak memiliki unicorn yang berasal dari India? Apa saja?

SELECT
	DISTINCT ui.industry 
FROM unicorn_industries ui
WHERE ui.industry NOT IN (
	SELECT
		DISTINCT ui2.industry 
	FROM unicorn_companies uc
	INNER JOIN unicorn_industries ui2 
		ON uc.company_id = ui2.company_id 
	WHERE uc.country = 'India'
)


--Cari tiga industri yang memiliki paling banyak unicorn di tahun 2019-2021  
-- tampilkan jumlah unicorn serta rata-rata valuasinya (dalam milliar) di tiap tahun.

WITH top_3 AS (
SELECT ui.industry,
		COUNT(DISTINCT ui.company_id)
FROM unicorn_industries ui
INNER JOIN unicorn_dates ud
ON ud.company_id = ui.company_id
WHERE EXTRACT(YEAR FROM ud.date_joined) IN (2019,2020,2021)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3
) ,

yearly_rank as (
	SELECT
	ui.industry,
	EXTRACT(YEAR FROM ud.date_joined) AS year_joined,
	COUNT(DISTINCT ui.company_id) AS total_company,
	ROUND(AVG(uf.valuation)/1000000000,2) AS avg_valuation_billion
FROM unicorn_industries ui 
INNER JOIN unicorn_dates ud 
	ON ui.company_id = ud.company_id 
INNER JOIN unicorn_funding uf 
	ON ui.company_id = uf.company_id 
GROUP BY 1,2
) 

SELECT
	y.*
FROM yearly_rank y
INNER JOIN top_3 t
	ON y.industry = t.industry
WHERE y.year_joined IN (2019,2020,2021)
ORDER BY 1,2 DESC



--Negara mana yang memiliki unicorn paling banyak 
--dan berapa persen proporsinya?

WITH country_level AS (
	SELECT
	uc.country,
	COUNT(DISTINCT uc.company_id) AS total_per_country
FROM unicorn_companies uc
GROUP BY 1
ORDER BY 2 DESC
)

SELECT *,
		ROUND((total_per_country / SUM(total_per_country) OVER ()),3) * 100 AS proporsion_company
		FROM country_level
		ORDER BY 2 DESC





















