-- netflix project

CREATE DATABASE IF NOT EXISTS netflix;
USE netflix;

-- create netflix table
CREATE TABLE IF NOT EXISTS netflix (
    show_id VARCHAR(10),
    type VARCHAR(10),
    title VARCHAR(125),
    director VARCHAR(225),
    cast VARCHAR(800),
    country VARCHAR(150),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(20),
    listed_in VARCHAR(100),
    description VARCHAR(300)
);

-- view all content
SELECT * FROM netflix;

-- count total content
SELECT COUNT(*) AS total_content FROM netflix;

-- distinct content types (movie vs tv show)
SELECT DISTINCT type FROM netflix;

-- count movies vs tv shows
SELECT 
    type,
    COUNT(*) AS total_content 
FROM netflix
GROUP BY type;

-- find the most common rating for movies and tv shows
SELECT 
    type,
    rating
FROM (
    SELECT 
        type,
        rating,
        COUNT(*) AS count_records,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    GROUP BY type, rating
) AS t1
WHERE ranking = 1;

-- list all movies released in a specific year (example: 2020)
SELECT * FROM netflix
WHERE 
    type = 'Movie'
    AND release_year = 2020;

-- find the top 5 countries with the most content on netflix
SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', n), ',', -1)) AS new_country,
    COUNT(show_id) AS total_content
FROM netflix
JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
) numbers
ON CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', '')) >= n - 1
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5;

-- identify the longest movie
SELECT * FROM netflix
WHERE 
    type = 'Movie'
    AND duration = (SELECT MAX(duration) FROM netflix);

-- find content added in the last 5 years
SELECT 
    EXTRACT(YEAR FROM STR_TO_DATE(date_added, '%M %d %Y')) AS year,
    COUNT(*) AS yearly_content
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d %Y') >= DATE_SUB(CURRENT_DATE, INTERVAL 5 YEAR)
AND date_added IS NOT NULL
GROUP BY year
ORDER BY yearly_content DESC;

-- find all movies/tv shows by director 'Rajiv Chilaka'
SELECT * FROM netflix  
WHERE director LIKE '%Rajiv Chilaka%';

-- list all tv shows with more than 5 seasons
SELECT * 
FROM netflix
WHERE type = 'TV Show' 
AND duration > 5;

-- count the number of content items in each genre
SELECT listed_in, COUNT(show_id) AS content_count
FROM netflix
GROUP BY listed_in;

-- find each year the average number of content releases by india on netflix (top 5 years)
SELECT 
    EXTRACT(YEAR FROM STR_TO_DATE(date_added, '%M %d %Y')) AS year,
    COUNT(*) AS yearly_content,
    ROUND(
        (COUNT(*) / (SELECT COUNT(*) FROM netflix WHERE country = 'India')) * 100,
        2 
    ) AS avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY year
ORDER BY yearly_content DESC
LIMIT 5;

-- list all movies that are documentaries
SELECT * FROM netflix  
WHERE listed_in LIKE '%Documentaries%';

-- find all content without a director
SELECT * FROM netflix  
WHERE director = '';

-- how many movies has 'Salman Khan' appeared in the last 10 years
SELECT *  
FROM netflix  
WHERE cast LIKE '%Salman Khan%'  
AND release_year >= YEAR(CURRENT_DATE) - 10;

-- find the top 10 actors who appeared in the highest number of movies produced in india
SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ',', n), ',', -1)) AS actor,
    COUNT(*) AS total_content
FROM netflix,
    (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) AS numbers
WHERE country LIKE '%India%'
GROUP BY actor
ORDER BY total_content DESC
LIMIT 10;

-- categorize content based on the presence of keywords 'kill' and 'violence' in the description
WITH new_table AS (
    SELECT 
        *,
        CASE 
            WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%'  
            THEN 'Bad_Content'
            ELSE 'Good_Content'
        END AS category
    FROM netflix
)
SELECT 
    category,
    COUNT(*) AS total_content
FROM new_table
GROUP BY category;