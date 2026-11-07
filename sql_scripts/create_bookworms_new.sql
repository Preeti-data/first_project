-- creating new sql database for bookworms with updated and cleaned data

CREATE DATABASE IF NOT EXISTS bookworms_new
    CHARACTER SET utf8mb4;

USE bookworms_new;

CREATE TABLE IF NOT EXISTS books (
    book_id INT PRIMARY KEY,
    title TEXT NOT NULL,
    average_rating DECIMAL(3,2) NULL,
    language_code VARCHAR(20) NOT NULL,
    num_pages INT NULL,
    ratings_count INT NOT NULL,
    text_reviews_count INT NOT NULL,
    publication_year INT NULL
);

CREATE TABLE IF NOT EXISTS authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    author_name VARCHAR(500) NOT NULL
);

CREATE TABLE IF NOT EXISTS collections (
    collection_id INT AUTO_INCREMENT PRIMARY KEY,
    collection_name VARCHAR(150) NOT NULL UNIQUE,
    selection_criteria TEXT NOT NULL,
    business_purpose TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_book_authors_book
        FOREIGN KEY (book_id) REFERENCES books (book_id) ON DELETE CASCADE,
    CONSTRAINT fk_book_authors_author
        FOREIGN KEY (author_id) REFERENCES authors (author_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS collection_of_books (
    collection_id INT NOT NULL,
    book_id INT NOT NULL,
    PRIMARY KEY (collection_id, book_id),
    CONSTRAINT fk_collection_of_books_collection
        FOREIGN KEY (collection_id) REFERENCES collections (collection_id) ON DELETE CASCADE,
    CONSTRAINT fk_collection_of_books_book
        FOREIGN KEY (book_id) REFERENCES books (book_id) ON DELETE CASCADE
);

SHOW TABLES;

