-- Bookworms catalogue analysis: MySQL schema for import into DrawDB.
-- Seven selected source fields:
-- bookID, title, authors, average_rating, ratings_count, num_pages, language_code.
-- Author IDs and collection definitions are created during preparation.
-- Collection membership is an output of the selection analysis.
-- This file defines the diagram only and does not contain book records.

CREATE TABLE books (
    bookID INT NOT NULL,
    title TEXT NOT NULL,
    language_code VARCHAR(20) NOT NULL,
    num_pages INT,
    average_rating DECIMAL(3,2),
    ratings_count INT,
    PRIMARY KEY (bookID)
);

CREATE TABLE authors (
    author_id INT NOT NULL AUTO_INCREMENT,
    author_name VARCHAR(500) NOT NULL,
    PRIMARY KEY (author_id)
);

CREATE TABLE collections (
    collection_id INT NOT NULL AUTO_INCREMENT,
    collection_name VARCHAR(100) NOT NULL,
    description TEXT,
    PRIMARY KEY (collection_id),
    UNIQUE (collection_name)
);

CREATE TABLE book_authors (
    bookID INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (bookID, author_id),
    CONSTRAINT fk_book_authors_book
        FOREIGN KEY (bookID) REFERENCES books (bookID)
        ON DELETE CASCADE,
    CONSTRAINT fk_book_authors_author
        FOREIGN KEY (author_id) REFERENCES authors (author_id)
        ON DELETE CASCADE
);

CREATE TABLE book_collections (
    bookID INT NOT NULL,
    collection_id INT NOT NULL,
    selection_reason TEXT,
    PRIMARY KEY (bookID, collection_id),
    CONSTRAINT fk_book_collections_book
        FOREIGN KEY (bookID) REFERENCES books (bookID)
        ON DELETE CASCADE,
    CONSTRAINT fk_book_collections_collection
        FOREIGN KEY (collection_id) REFERENCES collections (collection_id)
        ON DELETE CASCADE
);
