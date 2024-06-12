-- QUESTION 1:Find the artist who has contributed with the maximum no of albums. Display the artist name and the no of albums.
SELECT 
   a.name, 
   COUNT(al.albumid) AS album_count
FROM 
   artist a
JOIN 
   album al USING(artistid)
GROUP BY 
   a.name
ORDER BY 
   album_count DESC
LIMIT 1;

-- Question 2
SELECT DISTINCT
    c.FirstName || ' ' || c.LastName AS ListenerName,
    c.Email,
    c.Country
FROM 
    Customer c
JOIN 
    Invoice i USING(customerid)
JOIN 
    InvoiceLine il USING(InvoiceId)
JOIN 
    Track t USING(TrackId) 
JOIN 
    Genre g USING(GenreId) 
WHERE 
    g.Name IN ('Jazz', 'Rock', 'Pop')
GROUP BY
    c.CustomerId, c.FirstName, c.LastName, c.Email, c.Country
HAVING 
    COUNT(DISTINCT g.Name) = 3;

-- QUESTION 3

SELECT 
    e.FirstName || ' ' || e.LastName AS EmployeeName,
    e.Title AS Designation,
    COUNT(DISTINCT c.CustomerId) AS CustomerCount
FROM 
    Employee e
JOIN 
    Customer c ON e.EmployeeId = c.SupportRepId
GROUP BY 
    e.EmployeeId, e.FirstName, e.LastName, e.Title
ORDER BY 
    CustomerCount DESC
LIMIT 1;
--USING CTE
WITH CustomerSupportCount AS (
    SELECT 
        e.EmployeeId,
        e.FirstName || ' ' || e.LastName AS EmployeeName,
        e.Title AS Designation,
        COUNT(DISTINCT c.CustomerId) AS CustomerCount
    FROM 
        Employee e
    JOIN 
        Customer c ON e.EmployeeId = c.SupportRepId
    GROUP BY 
        e.EmployeeId, e.FirstName, e.LastName, e.Title
),
RankedEmployees AS (
    SELECT
        EmployeeName,
        Designation,
        CustomerCount,
        RANK() OVER (ORDER BY CustomerCount DESC) AS Rank
    FROM 
        CustomerSupportCount
)
SELECT 
    EmployeeName,
    Designation
FROM 
    RankedEmployees
WHERE 
    Rank = 1;


--QUESTION 4
SELECT 
    c.City,
    SUM(i.Total) AS TotalSpent
FROM 
    Customer c
JOIN 
    Invoice i USING(CustomerId)
GROUP BY 
    c.City
ORDER BY 
    TotalSpent DESC
LIMIT 1;

--QUESTION 5
SELECT
    c.Country
FROM
    Customer c
JOIN
    Invoice i  USING(CustomerId)
GROUP BY
    c.Country
ORDER BY
    COUNT(i.InvoiceId) DESC
LIMIT 1;
--USING CTE
WITH InvoiceCountByCountry AS (
    SELECT
        c.Country,
        COUNT(i.InvoiceId) AS InvoiceCount
    FROM
        Customer c
    JOIN
        Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY
        c.Country
),
RankedCountries AS (
    SELECT
        Country,
        InvoiceCount,
        RANK() OVER (ORDER BY InvoiceCount DESC) AS Rank
    FROM
        InvoiceCountByCountry
)
SELECT
    Country
FROM
    RankedCountries
WHERE
    Rank = 1;
 
--QUESTION 6
SELECT
    c.FirstName || ' ' || c.LastName AS CustomerName,
    SUM(i.Total) AS TotalSpent
FROM
    Customer c
JOIN
    Invoice i ON c.CustomerId = i.CustomerId
GROUP BY
    c.CustomerId
ORDER BY
    TotalSpent DESC
LIMIT 1;

--QUESTION 7
SELECT
    c.City
FROM
    Customer c
WHERE
    c.CustomerId IN (
        SELECT
            i.CustomerId
        FROM
            Invoice i
        JOIN
            InvoiceLine il ON i.InvoiceId = il.InvoiceId
        JOIN
            Track t ON il.TrackId = t.TrackId
        JOIN
            Genre g ON t.GenreId = g.GenreId
        WHERE
            g.Name = 'Rock'
    )
GROUP BY
    c.City
ORDER BY
    COUNT(*) DESC
LIMIT 1;

--QUESTION 8
SELECT
    ab.Title AS AlbumName,
    at.Name AS ArtistName,
    COUNT(t.TrackId) AS TrackCount
FROM
    Album ab
JOIN
    Artist at  USING(ArtistId) 
JOIN
    Track t  USING(AlbumId)
GROUP BY
    ab.AlbumId, ab.Title, at.Name
HAVING
    COUNT(t.TrackId) < 5;

-- QUESTION 9
SELECT
    tr.Name AS TrackName,
    al.Title AS AlbumTitle,
    ar.Name AS ArtistName,
    g.Name AS GenreName
FROM
    Track tr
JOIN
    Album al USING(AlbumId) 
JOIN
    Artist ar USING(ArtistId) 
JOIN
    Genre g USING(GenreId) 
LEFT JOIN
    InvoiceLine il USING(TrackId) 
WHERE
    il.TrackId IS NULL;

-- QUESTION 10
SELECT 
    DISTINCT a.Name AS ArtistName,
    g.Name AS Genre
FROM 
    Artist a
JOIN 
    Album al ON a.ArtistId = al.ArtistId
JOIN 
    Track t ON al.AlbumId = t.AlbumId
JOIN 
    Genre g ON t.GenreId = g.GenreId
WHERE 
    a.ArtistId IN (
        SELECT 
            ag.ArtistId
        FROM 
            (
                SELECT 
                    al1.ArtistId,
                    COUNT(DISTINCT g1.GenreId) AS GenreCount
                FROM 
                    Album al1
                JOIN 
                    Track t1 ON al1.AlbumId = t1.AlbumId
                JOIN 
                    Genre g1 ON t1.GenreId = g1.GenreId
                GROUP BY 
                    al1.ArtistId
            ) AS ag
        WHERE 
            ag.GenreCount > 1
    )
ORDER BY 
    a.Name, g.Name;
	
--QUESTION 11
SELECT 
    g.Name AS GenreName,
    COUNT(il.InvoiceLineId) AS PurchaseCount
FROM 
    Genre g
JOIN 
    Track t ON g.GenreId = t.GenreId
JOIN 
    InvoiceLine il ON t.TrackId = il.TrackId
GROUP BY 
    g.GenreId, g.Name
ORDER BY 
    PurchaseCount DESC
LIMIT 1;

-- Query for least popular genre
SELECT 
    g.Name AS GenreName,
    COUNT(il.InvoiceLineId) AS PurchaseCount
FROM 
    Genre g
JOIN 
    Track t ON g.GenreId = t.GenreId
JOIN 
    InvoiceLine il ON t.TrackId = il.TrackId
GROUP BY 
    g.GenreId, g.Name
ORDER BY 
    PurchaseCount ASC
LIMIT 1;

--QUESTION 13
SELECT 
    t.Name AS TrackName,
    al.Title AS AlbumTitle,
    ar.Name AS ArtistName,
    t.UnitPrice
FROM 
    Track t
JOIN 
    Album al ON t.AlbumId = al.AlbumId
JOIN 
    Artist ar ON al.ArtistId = ar.ArtistId
WHERE 
    t.UnitPrice > (SELECT AVG(UnitPrice) FROM Track)
ORDER BY 
    t.UnitPrice DESC;
--QUESTION 14
-- Step 1: Identify the most popular genre
WITH MostPopularGenre AS (
    SELECT 
        g.GenreId,
        g.Name AS GenreName,
        COUNT(il.InvoiceLineId) AS PurchaseCount
    FROM 
        Genre g
    JOIN 
        Track t ON g.GenreId = t.GenreId
    JOIN 
        InvoiceLine il ON t.TrackId = il.TrackId
    GROUP BY 
        g.GenreId, g.Name
    ORDER BY 
        PurchaseCount DESC
    LIMIT 1
),

-- Step 2: Find the top 5 artists for the most popular genre
TopArtists AS (
    SELECT 
        ar.Name AS ArtistName,
        COUNT(t.TrackId) AS SongCount
    FROM 
        Artist ar
    JOIN 
        Album al ON ar.ArtistId = al.ArtistId
    JOIN 
        Track t ON al.AlbumId = t.AlbumId
    JOIN 
        MostPopularGenre mpg ON t.GenreId = mpg.GenreId
    GROUP BY 
        ar.ArtistId, ar.Name
    ORDER BY 
        SongCount DESC
    LIMIT 5
)

-- Final step: Select the results
SELECT 
    ta.ArtistName,
    ta.SongCount
FROM 
    TopArtists ta
ORDER BY 
    ta.SongCount DESC;

--QUESTION 14
SELECT 
    ar.Name AS ArtistName,
    COUNT(t.TrackId) AS NumberOfSongs
FROM 
    Artist ar
JOIN 
    Album al ON ar.ArtistId = al.ArtistId
JOIN 
    Track t ON al.AlbumId = t.AlbumId
GROUP BY 
    ar.Name
ORDER BY 
    NumberOfSongs DESC
LIMIT 1;

--QUESTION 15
SELECT 
    al.AlbumId,
    al.Title AS AlbumTitle,
    ar.Name AS ArtistName
FROM 
    Album al
JOIN 
    Artist ar ON al.ArtistId = ar.ArtistId
ORDER BY 
    al.AlbumId;

--QUESTION 16
SELECT 
    i.InvoiceId,
    i.CustomerId
FROM 
    Invoice i
LEFT JOIN 
    Customer c ON i.CustomerId = c.CustomerId
WHERE 
    c.CustomerId IS NULL;

SELECT 
    i.InvoiceId,
    i.CustomerId,
    c.FirstName,
    c.LastName
FROM 
    Invoice i
JOIN 
    Customer c ON i.CustomerId = c.CustomerId
ORDER BY 
    i.InvoiceId;
--QUESTION 17
SELECT 
    il.InvoiceLineId,
    il.InvoiceId,
    il.TrackId,
    il.UnitPrice,
    il.Quantity
FROM 
    InvoiceLine il
JOIN 
    Invoice i ON il.InvoiceId = i.InvoiceId
ORDER BY 
    il.InvoiceLineId;

--QUESTION 18
SELECT 
    *
FROM 
    Album
WHERE 
    Title IS NULL;
-- QUESTION 19
SELECT 
    pt.PlaylistId,
    pt.TrackId
FROM 
    PlaylistTrack pt
LEFT JOIN 
    Track t ON pt.TrackId = t.TrackId
WHERE 
    t.TrackId IS NULL;


