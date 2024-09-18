/*
Netflix Movies and TV Shows Data Analysis using SQL

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions

*/

--Find the amount of content for each year of release

SELECT release_year, COUNT(*) AS content_count
FROM netflix
GROUP BY release_year
ORDER BY release_year;

--Find all TV shows starring actor 'Robert Downey Jr.'

SELECT * 
FROM netflix 
WHERE type = 'TV Show' 
  AND casts LIKE '%Robert Downey Jr.%';

--Find movies that are rated PG-13 and were released after 2015

SELECT * 
FROM netflix 
WHERE type = 'Movie' 
  AND rating = 'PG-13' 
  AND release_year > 2015;

--Find all movies and TV shows that contain the genre "Horror" and were added in the last 2 years

SELECT * 
FROM netflix 
WHERE listed_in LIKE '%Horror%' 
  AND release_year >= YEAR(CURDATE()) - 2;


--Find the Most Common Rating for Movies and TV Shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

--The list of all films lasts more than 120 minutes

SELECT * 
FROM netflix 
WHERE type = 'Movie' 
  AND CAST(SUBSTRING(duration, 1, INSTR(duration, ' ') - 1) AS UNSIGNED) > 120;

--Find the Top 5 Countries with the Most Content on Netflix

SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;

--Identify the Longest Movie

SELECT *
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;

--Find each year and the average numbers of content release in India on netflix

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

--Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in USA

SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'USA'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;
