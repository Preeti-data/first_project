-- Bookworms catalogue analysis: MySQL schema for import into DrawDB.
-- Seven selected source fields:
-- bookID, title, authors, average_rating, ratings_count, num_pages, language_code.
-- Author IDs and collection definitions are created during preparation.
-- Collection membership is an output of the selection analysis.
-- This file defines the diagram only and does not contain book records.
CREATE DATABASE IF NOT EXISTS bookworms
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE bookworms;

-- Drop in reverse order (child tables first) so the script can be re-run
DROP TABLE IF EXISTS collection_of_books;
DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS collections;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS books;

CREATE TABLE books (
    book_id            INT NOT NULL AUTO_INCREMENT,
    title              TEXT NOT NULL,
    average_rating     DECIMAL(3,2) NOT NULL,
    language_code      VARCHAR(20) NOT NULL,
    num_pages          INT NOT NULL,
    ratings_count      INT NOT NULL,
    text_reviews_count INT NOT NULL,
    publication_date   DATE NULL,
    PRIMARY KEY (book_id)
);

CREATE TABLE authors (
    author_id   INT NOT NULL AUTO_INCREMENT,
    author_name VARCHAR(500) NOT NULL,
    PRIMARY KEY (author_id)
);

CREATE TABLE collections (
    collection_id      INT NOT NULL AUTO_INCREMENT,
    collection_name    VARCHAR(150) NOT NULL,
    selection_criteria TEXT NOT NULL,
    business_purpose   TEXT NOT NULL,
    PRIMARY KEY (collection_id)
);

CREATE TABLE book_authors (
    book_id   INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id)   REFERENCES books(book_id)     ON UPDATE NO ACTION ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON UPDATE NO ACTION ON DELETE CASCADE
);

CREATE TABLE collection_of_books (
    collection_id INT NOT NULL,
    book_id       INT NOT NULL,
    PRIMARY KEY (collection_id, book_id),
    FOREIGN KEY (collection_id) REFERENCES collections(collection_id) ON UPDATE NO ACTION ON DELETE CASCADE,
    FOREIGN KEY (book_id)       REFERENCES books(book_id)             ON UPDATE NO ACTION ON DELETE CASCADE
);