#In BigQuery, navigate to the article_data table in the BigQuery tab and click Query Table:
SELECT * FROM `news_classification_dataset.article_data`;

#First, see which categories were most common in the dataset.
SELECT
  category,
  COUNT(*) c
FROM
  `news_classification_dataset.article_data`
GROUP BY
  category
ORDER BY
  c DESC;

#If you wanted to find the article returned for a more obscure category like 
#/Arts & Entertainment/Music & Audio/Classical Music, you could run the following query:
SELECT * FROM `news_classification_dataset.article_data`
WHERE category = "/Arts & Entertainment/Music & Audio/Classical Music";

#To get only the articles where the Natural language API returned a confidence score 
#greater than 90%, run the following query:
SELECT
  article_text,
  category
FROM `news_classification_dataset.article_data`
WHERE cast(confidence as float64) > 0.9;

