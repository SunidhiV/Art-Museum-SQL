SELECT * FROM artist;
SELECT * FROM canvas_size;
SELECT * FROM image_link;
SELECT * FROM museum;
SELECT * FROM museum_hours;
SELECT * FROM product_size;
SELECT * FROM subject;
SELECT * FROM work;

-- 1. Identifying Displayed Paintings
-- Question: Display all paintings that are currently not displayed in any museum.
SELECT * FROM work WHERE museum_id is NULL;

-- 2. Museum Inventory Analysis
-- Question: Calculate the number of museums that currently do not have any paintings displayed in their exhibits.
SELECT COUNT(*) FROM museum m
	WHERE not exists (SELECT 1 FROM work w
					 WHERE w.museum_id=m.museum_id);

-- 3. Exploring Artistic Popularity
-- Question: Provide a list of the top 10 most famous painting subjects based on their popularity.
SELECT TOP 10 s.subject, COUNT(*) AS paintingcount
FROM work w
JOIN subject s ON s.work_id = w.work_id
GROUP BY s.subject
ORDER BY paintingcount DESC;

-- 4. Museum Operation Efficiency
-- Question: Identify museums that are open on both Sunday and Monday. Display the museum name and city.

SELECT DISTINCT m.name AS museum_name
FROM museum_hours mh
JOIN museum m ON m.museum_id = mh.museum_id
WHERE mh.day = 'Sunday'
  AND m.museum_id IN (
    SELECT mh2.museum_id
    FROM museum_hours mh2
    WHERE mh2.day = 'Monday');

-- 5. Understanding Canva Size Preferences
-- Question: Display the three most popular canvas sizes within the museum's collection.

SELECT TOP 3
    cs.size_id,
    cs.label,
    COUNT(*) AS no_of_paintings
FROM
    work AS w
JOIN
    product_size AS ps ON ps.work_id = w.work_id
JOIN
    canvas_size AS cs ON cs.size_id = ps.size_id
GROUP BY
    cs.size_id, cs.label
ORDER BY COUNT(*) DESC;

-- 6. Museum Accessibility and Operational Excellence
-- Question: Determine the count of museums that operate every single day of the week.
SELECT COUNT(DISTINCT museum_id)
FROM museum_hours
WHERE museum_id IN (
    SELECT museum_id
    FROM museum_hours
    GROUP BY museum_id
    HAVING COUNT(DISTINCT day) = 7
);

-- 7.Question: Display the names of museums that operate every single day of the week.

SELECT name AS museum_name
FROM museum
WHERE museum_id IN (
    SELECT museum_id
    FROM museum_hours
    GROUP BY museum_id
    HAVING COUNT(DISTINCT day) = 7
);

-- 8. Art Valuation and Placement
-- Question: Identify the artist with the most and least expensive paintings. Display artist name, painting name and sale price.

SELECT DISTINCT a.full_name AS artist,
       w.name AS painting,
       ps.sale_price
FROM product_size ps
JOIN work w ON w.work_id = ps.work_id
JOIN artist a ON a.artist_id = w.artist_id
WHERE ps.sale_price = (SELECT MAX(sale_price) FROM product_size)
   OR ps.sale_price = (SELECT MIN(sale_price) FROM product_size);

-- 9. Global Artistic Impact
-- Question: Determine which artist has the highest number of portrait paintings exhibited outside the USA.

WITH ArtistPaintingCounts AS (
    SELECT
        a.full_name AS artist_name,
        COUNT(*) AS no_of_paintings,
        RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
    FROM
        work w
    JOIN artist a ON a.artist_id = w.artist_id
    JOIN subject s ON s.work_id = w.work_id
    JOIN museum m ON m.museum_id = w.museum_id
    WHERE
        s.subject = 'Portraits'
        AND m.country != 'USA'
    GROUP BY
        a.full_name,
        a.nationality
)
SELECT
    artist_name,
    no_of_paintings
FROM
    ArtistPaintingCounts
WHERE
    rnk = 1;


