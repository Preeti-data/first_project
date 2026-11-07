-- Bookworms collection reports for MySQL 8+
-- These queries are read-only. The database can store books in any language.
-- Each query that selects or counts books applies books.language_code = 'eng'.
-- Collection memberships are read from collection_of_books.
-- Collection totals count book IDs, so a book can count in several collections.

USE bookworms_new;

-- 1. Show the stored collection rules and the additional reporting filter.
SELECT c.collection_id, c.collection_name, c.selection_criteria,
       'language_code = ''eng''' AS report_language_filter
FROM collections AS c
ORDER BY c.collection_id;

-- 2. How many English books are in each collection?
-- Put the filter in the LEFT JOIN so a collection with no English books shows 0.
SELECT c.collection_name,
       COUNT(b.book_id) AS english_book_count,
       ROUND(AVG(b.average_rating), 2) AS avg_book_rating
FROM collections AS c
LEFT JOIN collection_of_books AS cb ON cb.collection_id = c.collection_id
LEFT JOIN books AS b ON b.book_id = cb.book_id AND b.language_code = 'eng'
GROUP BY c.collection_id, c.collection_name
ORDER BY english_book_count DESC, c.collection_id;

-- 3. Which English books and authors are in Popular Favourites?
-- A book with several authors appears once per author.
SELECT b.book_id, b.title, a.author_name, b.average_rating, b.ratings_count
FROM collections AS c
JOIN collection_of_books AS cb ON cb.collection_id = c.collection_id
JOIN books AS b ON b.book_id = cb.book_id AND b.language_code = 'eng'
LEFT JOIN book_authors AS ba ON ba.book_id = b.book_id
LEFT JOIN authors AS a ON a.author_id = ba.author_id
WHERE c.collection_name = 'Popular Favourites'
ORDER BY b.ratings_count DESC, b.book_id, a.author_name;

-- 4. Which English books belong to two or more collections?
SELECT b.book_id, b.title, b.average_rating, b.ratings_count
FROM books AS b
WHERE b.language_code = 'eng'
  AND b.book_id IN (
      SELECT cb.book_id
      FROM collection_of_books AS cb
      GROUP BY cb.book_id
      HAVING COUNT(DISTINCT cb.collection_id) >= 2
  )
ORDER BY b.ratings_count DESC, b.book_id;

-- 5. What are the top three English books in each collection?
-- The language filter runs before the ranking.
WITH ranked_books AS (
    SELECT c.collection_id, c.collection_name, b.book_id, b.title,
           b.average_rating, b.ratings_count,
           ROW_NUMBER() OVER (
               PARTITION BY c.collection_id
               ORDER BY b.average_rating DESC, b.ratings_count DESC, b.book_id
           ) AS rank_in_collection
    FROM collection_of_books AS cb
    JOIN collections AS c ON c.collection_id = cb.collection_id
    JOIN books AS b ON b.book_id = cb.book_id AND b.language_code = 'eng'
)
SELECT collection_name, rank_in_collection, book_id, title,
       average_rating, ratings_count
FROM ranked_books
WHERE rank_in_collection <= 3
ORDER BY collection_id, rank_in_collection;

-- 6. How many English books are shared by every collection?
SELECT COUNT(*) AS english_books_in_all_collections
FROM (
    SELECT cb.book_id
    FROM collection_of_books AS cb
    JOIN books AS b ON b.book_id = cb.book_id AND b.language_code = 'eng'
    GROUP BY cb.book_id
    HAVING COUNT(DISTINCT cb.collection_id) = (SELECT COUNT(*) FROM collections)
) AS shared_books;

-- 7. Compare MySQL's English counts with the Python results for the supplied CSV.
-- A NULL collection ID means the name did not match a stored collection.
WITH python_counts AS (
    SELECT 'Popular Favourites' AS collection_name, 972 AS python_count
    UNION ALL SELECT 'Recommended Short Reads', 186
    UNION ALL SELECT 'Hidden-Gem Candidates', 45
    UNION ALL SELECT 'Popular Classics', 96
)
SELECT c.collection_id, p.collection_name, p.python_count,
       CASE WHEN c.collection_id IS NOT NULL THEN COUNT(b.book_id) END AS sql_english_count,
       CASE WHEN c.collection_id IS NOT NULL
            THEN CAST(COUNT(b.book_id) AS SIGNED) - p.python_count
       END AS difference
FROM python_counts AS p
LEFT JOIN collections AS c ON c.collection_name = p.collection_name
LEFT JOIN collection_of_books AS cb ON cb.collection_id = c.collection_id
LEFT JOIN books AS b ON b.book_id = cb.book_id AND b.language_code = 'eng'
GROUP BY c.collection_id, p.collection_name, p.python_count
ORDER BY c.collection_id, p.collection_name;

-- 8. List English books across all collections.
SELECT c.collection_name, b.book_id, b.title, b.average_rating, b.ratings_count,
       b.num_pages, b.publication_year
FROM collections AS c
JOIN collection_of_books AS cb ON cb.collection_id = c.collection_id
JOIN books AS b ON b.book_id = cb.book_id AND b.language_code = 'eng'
ORDER BY c.collection_id, b.average_rating DESC, b.ratings_count DESC, b.book_id;

-- 9. List English books in a selected collection.
-- Change the collection name in WHERE to view another list.
SELECT c.collection_name, b.book_id, b.title, b.average_rating, b.ratings_count,
       b.num_pages, b.publication_year
FROM collections AS c
JOIN collection_of_books AS cb ON cb.collection_id = c.collection_id
JOIN books AS b ON b.book_id = cb.book_id AND b.language_code = 'eng'
WHERE c.collection_name = 'Recommended Short Reads'
ORDER BY b.average_rating DESC, b.ratings_count DESC, b.book_id;
