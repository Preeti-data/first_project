# Bookworms - Choosing Books for Monthly Subscription Boxes

**Group 4:** + Preeti Tewatia + Telma Guerreiro + Cem Kocyigit  
**Ironhack Data Analytics - First Project: SQL, From Data to Insight**

Bookworms is a fictional online book subscription company. Customers choose a collection and reading language, and receive a box of books selected by the company each month. The company also recommends and sells books.

We used Goodreads data to prepare collection shortlists and investigate ratings, author entries, book length and publication period.

Our rules return **1,253 distinct book records across four collections**. The more widely rated half of the rated dataset scored only **0.04 points higher on average** than the other half. That gave us little reason to choose on popularity alone.

The output is a set of candidates to review, not a sales forecast or a final purchasing list.

## 1. Business problem and scope

**Main question: Which books should Bookworms consider for its launch collections?**

A book with a score of 5.0 from two ratings is not automatically a stronger choice than one rated 4.5 by thousands of readers. Average rating and rating count answer different questions: how a record was rated, and how much rating activity it received.

We began with three collections and later added **Popular Classics**. The four collections in the final analysis are:

| Collection | What it is intended to offer |
| --- | --- |
| Popular Favourites | Well-rated books with substantial rating activity. |
| Recommended Short Reads | Well-rated shorter books with a minimum amount of feedback. |
| Hidden-Gem Candidates | High-scoring books with comparatively fewer ratings. |
| Popular Classics | Well-rated records with an older reported publication year, subject to further review of classic status. |

The analysis grew from three collections to four. "Recommended Short Reads" replaces the earlier label "Highly Rated Short Reads," and the rules below replace the trial thresholds.

All four filters use **English-language records**. This is an analysis scope decision, not evidence that customers prefer English.

### Who would use the results?

| Stakeholder | Decision supported |
| --- | --- |
| Business owner | Approve the collection offer and decide what to test before launch. |
| Content/recommendation team | Review candidate books and their suitability for each collection. |
| Purchasing team | Check exact editions, supplier availability and purchasing costs. |
| Marketing team | Explain the differences between the collections without making unsupported claims. |
| Customer experience team | Consider whether the choices suit subscribers and gather feedback. |

Genres and individual customer preferences are not in this dataset. We discussed adding genres, but they were not included in the final rules. This is a collection-selection project, not a personalized recommendation engine.

## 2. Questions and starting hypotheses

The business plan gave us four hypotheses to explore. They were starting ideas, not conclusions to prove.

| Hypothesis | Question | Approach used in the current analysis |
| --- | --- | --- |
| H1 - Ratings and popularity | Do records with more Goodreads ratings have higher average scores? | Split rated records at the median rating count and compare the two mean scores. |
| H2 - Author consistency | Do some author entries have several records that consistently score above the overall benchmark? | Group stored author labels and compare their median scores and consistency, using minimum record and rating-count requirements. |
| H3 - Book length | Do average scores differ between shorter and longer books? | Compare mean scores across three page ranges. |
| H4 - Publication period | Do ratings and rating activity differ across publication periods? | Compare mean scores and median rating counts by reported publication decade. |

For H1, the final analysis uses the two-group comparison rather than the correlation proposed initially. Written-review counts are retained, but we do not report a separate written-review finding.

These are **descriptive comparisons**, not proof of causation or statistical significance.

## 3. Dataset

The historical Goodreads dataset was selected from the course's Kaggle options. Its original description identifies the Goodreads API as the collection source. The exact download URL and dataset usage terms still need to be recorded; no data license is assumed here.

| Item | Current analysis data |
| --- | --- |
| Records | 11,123 |
| Distinct source `bookID` values | 11,123 |
| Fields in the cleaned CSV | 13: the original 12 plus `publication_year` |
| English-coded records | 10,537, or 94.7% |
| Missing page counts after cleaning | 76 |
| Missing average ratings after cleaning | 26 |
| Missing contributor fields after cleaning | 5 |

A row is a **book or edition record**, not necessarily a different work. Repeated titles were retained because they can represent different editions, translations or formats.

### Fields and their uses

| Fields | Use |
| --- | --- |
| `bookID`, `title` | Identify and describe the source record. |
| `authors` | Contributor text, including entries with several slash-separated names. |
| `average_rating`, `ratings_count` | Reader score and rating activity used in selection and analysis. |
| `text_reviews_count` | Number of written reviews; retained for reference and database storage. |
| `num_pages`, `language_code` | Collection suitability and reading-language filtering. |
| `publication_date`, `publication_year` | Source date text and extracted year used in period analysis. |
| `isbn`, `isbn13` | Edition identifiers, read as text to preserve leading zeros and letter characters. |
| `publisher` | Publisher information and additional context for checking formats. |

The earlier Excel reference was reported as having **11,127 records**. The CSV notebook reports 11,119 parsed rows plus four repairs: **11,123**. That source-version difference remains unresolved, not an established intentional deletion. All results here use the 11,123-record CSV.

## 4. Data preparation

The final cleaning workflow is saved in **`bookworms_data_cleaning_final.ipynb`**. It starts from the original `books.csv`, rather than from an already-cleaned export. The saved run contains 49 executed code cells, reports 11,119 parsed records plus four repaired records, and ends with a successful export to **`bookworms_cleaned_data_final.csv`**.

The input and output are in the current working folder in this version. Its main cleaning decisions were:

| Issue or check | Treatment and reason |
| --- | --- |
| Four rows contained 13 fields instead of 12. | Inspect the rows, rejoin the split author text with `fix_author()`, and add the repaired records back rather than discard them. |
| Spaces in column headings and around titles. | Strip unnecessary outside spaces, including the spaces before `num_pages`. |
| Numeric values imported as text. | Convert IDs and counts to integers and average ratings to decimal values; retain ISBNs as text. |
| Duplicate records or IDs. | Check both; the notebook reports no fully duplicated rows or duplicate source book IDs. |
| Zero page counts. | Treat 76 values as missing or not applicable rather than as real zero-page books. |
| Zero average ratings. | Treat 26 scores as missing because those records also have zero recorded ratings. |
| Very large or small page counts. | Inspect rather than automatically delete: large values can describe sets or reference books, while some very small values appear to describe audio editions. |
| Different English-language codes. | Map `en-US`, `en-GB` and `en-CA` to `eng` for the broad language filter. |
| Publisher variants. | Apply `publisher_corrections` to the `publisher` column; these groups are an analytical choice, not a verified corporate-ownership classification. |
| `NOT A BOOK` in the contributor field. | Replace five placeholders with missing values without deleting the book records. |
| Publication information. | Extract `publication_year`, check for blank or missing years, and convert it to an integer. |

Two source strings contain impossible full dates, but their reported years can still be extracted. We retained the years for year-based analysis without guessing replacement days. Full SQL-date loading is a separate check.

### Contributor detail and author summaries

The final notebook uses two author-grouping dictionaries, but they do not both change the exported data:

| Step in the final notebook | What the code does | Effect on the cleaned export |
| --- | --- | --- |
| Cell 38: `author_corrections` | Replaces selected Douglas Adams and J.K. Rowling contributor lists directly in `df_clean["authors"]`. | These shortened labels remain in the exported `authors` column. |
| Cell 40: `more_author_corrections` | Creates `author_summary` and applies both dictionaries to that separate variable. | The additional grouping appears in the displayed summary, not in the exported `authors` column. |
| Cell 43: placeholder treatment | Replaces `NOT A BOOK` in `authors` with missing values. | Five placeholder fields are blank; the book records are retained. |

The separate summary in cell 40 is:

```python
author_summary = df_clean["authors"].replace(author_corrections)
author_summary = author_summary.replace(more_author_corrections)
author_summary.value_counts().head(20)
```

`head(20)` limits the displayed summary; it does not limit replacements to 20 book records. The saved summary shows Stephen King with 80 records, Sandra Brown with 46, and Agatha Christie with 45. These are counts of grouped labels, not counts of distinct works or a rating-based ranking.

**The first dictionary still overwrites contributor names.** The separate summary prevents the second dictionary from overwriting further names, but it cannot restore names already shortened in cell 38. Complete contributor preservation would require changing that first assignment as well and rerunning from the raw file; this README does not claim that step is already in the final notebook.

### Final export

The last cell saves `df_clean` with `index=False` and UTF-8 encoding as `bookworms_cleaned_data_file.csv` in the current working folder, and prints its location. The saved notebook output confirms that this export completed. It does not export `author_summary` or create an additional author-summary column.

The existing presentation's H2 result uses the earlier **fully grouped** `explore_clean_data.ipynb`. Reproducing that result from the final notebook's export requires applying both dictionaries separately in the analysis. Grouping the final export directly by `authors` is a different calculation. The author-label changes do not alter the ratings, counts, page lengths or publication years used by the collection filters and other comparisons.

## 5. Database design

We moved from one flat file to five related tables. Two linking tables handle the cases where a book has several contributors or qualifies for several collections.

| Table | Purpose | Primary key |
| --- | --- | --- |
| `books` | Book details, reader scores, counts and publication date. | `book_id` |
| `authors` | Author/contributor records. | `author_id` |
| `book_authors` | Connect books to contributor records. | `book_id` + `author_id` |
| `collections` | Collection definitions. | `collection_id` |
| `collection_of_books` | Connect books to collections. | `collection_id` + `book_id` |

Each linking table has **one composite primary key** made from its two IDs. Both IDs are foreign keys. The combination must be unique, but each ID can appear in several links.

The four relationships are `books` **1:N** `book_authors`, `authors` **1:N** `book_authors`, `books` **1:N** `collection_of_books`, and `collections` **1:N** `collection_of_books`.

![Bookworms entity-relationship model](figures/ERM_bookworms.pdf)

### MySQL `books` table

| Column | Type | Allows NULL |
| --- | --- | --- |
| `book_id` | `INT`, primary key | No |
| `title` | `TEXT` | No |
| `average_rating` | `DECIMAL(3,2)` | Yes |
| `language_code` | `VARCHAR(20)` | No |
| `num_pages` | `INT` | Yes |
| `ratings_count` | `INT` | No |
| `text_reviews_count` | `INT` | No |
| `publication_year` | `INT` | Yes |

During data cleaning, we extracted the edition's publication year from the source date. MySQL stores this cleaned `publication_year` so SQL and Python can use the same field for year-based analysis, such as finding editions published before 1976.

The `book_id` preserves the original Goodreads ID from the CSV.

## 6. SQL implementation and checks

The MySQL database `bookworms_new` contains five tables. The schema is created with `create_bookworms_new.sql` and populated from the cleaned CSV using Python through SQLAlchemy and PyMySQL. The loading steps are documented in [`notebooks/database_population.ipynb`](notebooks/database_population.ipynb).

The `books` table keeps the original Goodreads book IDs and stores `publication_year`, which was extracted during data cleaning. This gives SQL and Python the same year field for the Popular Classics filter. Missing ratings, page counts and publication years are stored as `NULL`.

The MySQL screenshots document the table structure and relationships. The population notebook checks the number of books loaded against the CSV row count and displays the stored collection counts. The structure can also be checked directly in MySQL :

```sql
SHOW TABLES FROM bookworms_new;
SHOW COLUMNS FROM bookworms_new.books;
```

The collection figures reported here come from Python. A separate consistency check used SQl database bookworms_new stored under the name `bookworms_new_dump.sql`in sql_scripts. To reconcile the results against the live MySQL database, run `query_bookworms_new.sql`. It applies `language_code = 'eng'` when reporting collection counts, so they can be compared with the English-only Python results. 

## 7. Collection rules and results

All four filters require `language_code == "eng"`. Thresholds are inclusive where shown. They are the current project rules, not proven commercial optima or guarantees that a rating is reliable.

| Collection | Minimum average rating | Rating count | Other condition | Qualifying records |
| --- | ---: | --- | --- | ---: |
| Popular Favourites | 4.0 | At least 10,000 | None | 972 |
| Recommended Short Reads | 4.0 | At least 500 | More than 2 and no more than 100 pages | 186 |
| Hidden-Gem Candidates | 4.5 | 100-999 | None | 45 |
| Popular Classics | 4.0 | No minimum | Reported publication year before 1976 | 96 |

The Hidden-Gem calculation uses **4.5**, matching the executable filter, not the older comment that says 4.2. The Classics cutoff is **before 1976**, not "1976 or earlier."

![Records qualifying for each collection](figures/bookworms_collections.png)

The counts total **1,299 memberships across 1,253 distinct book IDs**. Overlaps are 39 Popular/Short, three Popular/Classics and four Short/Classics, with no triple overlaps. They explain the 46 extra memberships. Distinct IDs are still not necessarily distinct works.

### Examples of qualifying records

| Collection | Example | Source bookID | Score | Rating count | Relevant detail |
| --- | --- | ---: | ---: | ---: | --- |
| Popular Favourites | The Hobbit | 5907 | 4.27 | 2,530,894 | 366 pages |
| Recommended Short Reads | Calvin and Hobbes: Sunday Pages 1985-1995: An Exhibition Catalogue | 24820 | 4.71 | 3,613 | 96 pages |
| Hidden-Gem Candidates | Early Color | 6550 | 4.73 | 144 | 156 pages |
| Popular Classics | The Power Broker | 1111 | 4.51 | 11,208 | Reported year 1975 |

These are qualifying examples, not ranked recommendations or approved purchases. The Power Broker also qualifies for Popular Favourites. Each example refers to the specific source record.

## 8. Python analysis and findings

For H1-H4, a **rated record** has a nonmissing average score and a positive rating count. There are **11,042** such records. These comparisons use all languages, unlike the English-only collection filters.

### H1 - More ratings did not mean a much higher score

Splitting at the median rating count of **764.5** created two equal groups:

| Group | Records | Mean score |
| --- | ---: | ---: |
| 764 ratings or fewer | 5,521 | 3.923 |
| 765 ratings or more | 5,521 | 3.963 |

![Mean scores for lower- and higher-rating-count groups](figures/h1_ratings_and_popularity.png)

The **0.04-point gap** gives limited descriptive support for H1, not a strong difference. Each record contributes one average score; these means are not weighted by rating count.

### H2 - Some grouped author entries were consistently above the benchmark

The reported H2 analysis groups the stored `authors` labels in `bookworms_cleaned_data_file (1).csv`, where both grouping dictionaries had been applied, and compares them with the rated catalog median of **3.96**. An entry qualified with at least three rated records, at least 1,000 ratings in total, a median score above 3.96, and at least 75% of its records above 3.96.

That grouped-label version produces **212 qualifying entries**, as reported in the presentation:

| Example entry | Rated records | Median score | Records above 3.96 |
| --- | ---: | ---: | ---: |
| Bill Watterson | 7 | 4.71 | 100% |
| J.R.R. Tolkien | 25 | 4.44 | 96% |
| J.K. Rowling | 25 | 4.49 | 100% |

These examples are not the top three or a verified individual-author ranking. Contributor combinations are grouped as stored, and editions may repeat works. The earlier 213-entry result and Tolkien's 17-record grouping use different author labels. The final cleaning notebook displays a top-20 label count, not this H2 analysis, so its successful export should not be confused with a new execution of H2.

### H3 - Mean ratings were fairly close across page ranges

We excluded missing page counts and records with two pages or fewer, leaving **10,943 rated records**.

| Pages per record | Records | Mean score |
| --- | ---: | ---: |
| 3-100 | 921 | 3.968 |
| 101-400 | 7,034 | 3.907 |
| Over 400 | 2,988 | 4.021 |

The means differ but remain fairly close on the five-point scale. Length helps define a shorter-reading offer; it does not establish quality or cause a higher score.

### H4 - Feedback varied more than mean scores across decades

We used the reported publication year and displayed only decades with **at least 100 rated records**. This is a minimum group size, not a requirement that every book have 100 ratings.

| Publication decade | Rated records | Mean score | Median rating count |
| --- | ---: | ---: | ---: |
| 1970s | 203 | 3.960 | 226 |
| 1980s | 617 | 3.979 | 311 |
| 1990s | 2,449 | 3.954 | 641 |
| 2000s | 7,514 | 3.935 | 911 |
| 2010s | 137 | 3.981 | 775 |

Mean scores are similar. Median rating count peaks in the 2000s among the decades shown, but this is not evidence of current demand. Reported years may refer to editions, not first publication.

## 9. Key findings, recommendations and limitations

Our recommendation is to use the filters to narrow the choice, then review the actual books.

| Finding or limitation | Recommended action |
| --- | --- |
| The H1 mean-score difference is only about 0.04. | Consider average score and rating count together rather than treating popularity as a substitute for reader opinion. |
| Popular Favourites has the largest pool, with 972 candidates. | Use it as a practical starting point for editorial review, not a prediction that it will sell best. |
| Some low-page records are audio editions. | Verify format and edition before selecting physical books for the boxes. |
| Author labels may combine or simplify contributor credits. | Preserve the contributor links and review the grouped results before making individual-author recommendations. |
| Popular Classics has no rating-count minimum. | Review feedback and literary fit rather than treating an old reported year as proof of popularity or classic status. |
| No sales, subscriber, stock or cost data is available. | Check sourcing and costs, then test subscriber interest with a small pilot before committing to purchases. |

For example, source `bookID` 16 has six recorded pages and an audio publisher, yet passes the Short Reads numerical filter. In Classics, **22 of 96 candidates have fewer than 100 ratings, including one with zero**. These are reasons for a review step, not results we removed to make the lists look better.

The dataset is historical, not representative of every reader, and heavily English-coded. It contains no genres or subscriber preferences. We cannot use it to establish sales, profit, customer retention or personalized suitability. Repeated works and the treatment of contributor labels also affect record and author counts.

## 10. Tools and collaboration

We used Python and Pandas for preparation and analysis, Matplotlib for charts, Jupyter Notebook for the workflow, MySQL for the relational database, Miro for the initial model, DrawDB for database design, and Git/GitHub for sharing the work.

We worked across business planning, cleaning, database implementation, analysis and presentation. We agreed to use personal Git branches and review changes before merging into `main`.

Our integration discussions separated data preparation from analysis. Python transformations stay in notebooks; table creation, loading and analytical SQL need their own saved scripts. A changed database alone is not a record of how it was built.

The main lesson was to keep contributor and edition detail and record both the selection rules and data version. An author label can change a summary without changing any book's score.

## 11. Files and how to run the work

### Main files

| File | Role |
| --- | --- |
| `bookworms_data_cleaning_final.ipynb` | Final shared cleaning notebook, including the separate second-stage author summary and the revised local save path. |
| `books.csv` | Original raw input expected by the final cleaning notebook. |
| `bookworms_cleaned_data_final.csv` | Cleaned output written by the final notebook; its saved run confirms the export succeeded. |
| `explore_clean_data.ipynb` | Shared collection-selection and H1,H2,H3,H4 analysis notebook. |
| `figures/` | Current ERM,ERD and charts used in this README. |
| `slides/`Bookworms_g4_presentation.pptx | Final Bookworms presentation. |
| `sql_scripts/` | Current database creation script, database dump and analytical queries. |

The final cleaning notebook reads **`books.csv` from the current working folder** and writes **`bookworms_cleaned_data_final.csv` to that folder**. It uses `../data/raw/` for reading boos.csv and `../data/clean/` for saving the cleaned file.

A simple local arrangement for running it unchanged is:

```text
working-folder/
    bookworms_data_cleaning_final.ipynb
    books.csv
    bookworms_cleaned_data_corrected.csv   # created by the export cell
```

For the repository, raw data, cleaned data and notebooks can be kept in separate folders, but the paths in the code must then be updated together. Do not rename a cleaned export to `books.csv`: the repair and cleaning steps expect the original raw input.

The shared exploration notebook contains the collection filters and H1/H2 code. The later H3/H4 charts and presentation provide the other reported comparisons. The older saved H2 output in the exploration notebook belongs to its earlier input version, not automatically to every later export.

### Running order

1. **Prepare the environment.** Use a Python environment with Pandas, Matplotlib and Jupyter, plus MySQL and Workbench for the database stage. Keep the original raw CSV unchanged.
2. **Run the final cleaning notebook.** Put `books.csv` in the working folder used by `bookworms_data_cleaning_final.ipynb`. Restart the notebook session and run its cells from the beginning so the data and both dictionaries are created in order.
3. **Check the export location.** The final cell writes `bookworms_cleaned_data_corrected.csv` and prints the full path. It saves `df_clean`, not `author_summary`. Retain the previous export until the team has checked which version the analysis reads.
4. **Point the analysis to the chosen export.** The exploration notebook must explicitly load that file; it does not inherit variables from the cleaning notebook. To reproduce the published H2 grouping, apply both author dictionaries separately before the H2 aggregation, rather than assuming the final exported `authors` field already contains both. Keep the collection thresholds unchanged.
5. **Prepare and load the database tables.** Use the current database creation and loading workflow, not an older DrawDB-only draft. Before building contributor links, resolve the first author replacement described in section 4. Preserve the source-to-database ID mapping and record how missing values and dates are loaded. Do not rerun table-creation commands over a working database just to change its documentation.
6. **Refresh the analysis and documentation together.** Rerun the collection filters and hypothesis calculations from the agreed data version, then update the charts, presentation and README together if any results change. Run and reconcile the live MySQL queries separately. Check that the ERM and SQL definitions describe the same tables and that the images linked here are present.

Creating `author_summary` inside the cleaning notebook does not save that variable in the CSV or make it available in another notebook. The analysis needs its own explicit grouping step or a saved, documented summary input.

### Remaining reproducibility checks

The final cleaning notebook is now part of the documented workflow, and it contains a saved successful export. The remaining checks concern the full repository and its analytical outputs:

- Record the original dataset download URL and usage terms, and reconcile the earlier Excel/CSV record-count difference.
- Resolve cell 38's remaining contributor replacement before claiming complete contributor preservation, and use consistent author grouping when reproducing H2.
- Save the current SQL definitions, loading procedure and analytical outputs; confirm the full `authors`/`collections` definitions, ID mapping, loaded row counts, missing-value treatment and stored dates.
- Keep the final notebook and its matching export with the project, confirm environment dependencies, and include the notebooks or scripts behind the later H3/H4 charts. A cleaning notebook does not replace the separate analysis code.

These checks do not require deleting publication data or rebuilding working tables to match an old diagram.
