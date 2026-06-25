-- =====================================================
-- 6. COUNTRY COMPARISON EDA
-- =====================================================


-- =====================================================
-- 6.1 Analysis of selected countries
-- =====================================================


SELECT *
FROM vw_industry;

SELECT *
FROM gl_us_ind_tree('2020-01-01', '2021-01-01');

SELECT *
FROM gl_us_ind_tree('2021-01-01', '2022-01-01');

SELECT *
FROM gl_us_ind_tree('2022-01-01', '2023-01-01');

SELECT *
FROM gl_us_ind_tree('2023-01-01', '2024-01-01');


SELECT us_industry, ROUND(100.0 * SUM(us_laid_off) / SUM(global_laid_off), 2)
FROM gl_us_ind_tree('2020-01-01', '2024-01-01')
GROUP BY us_industry
ORDER BY 2 DESC; -- Share of US in global industry layoffs 


SELECT ind_industry, ROUND(100.0 * SUM(ind_laid_off) / SUM(global_laid_off), 2)
FROM gl_us_ind_tree('2020-01-01', '2024-01-01')
GROUP BY ind_industry
ORDER BY 2 DESC; -- Share of India in global industry layoffs 


-- =====================================================
-- Key Finding
-- =====================================================


/* Throughout the whole observed period, Consumer(~15%) and Retail(~13%) industries dominate the magnitude of layoffs in the
United States, followed by Transportation(~8.2%), 'Other'(~7.6%), and Finance(~6.5%). This shows a similar pattern to the global
observation where both Consumer and Retail lead the list, followed by rest of mentioned industries with relatively close 
distribution of share, with an only exception of a switch in the ranking of Transportation(3rd) and 'Other'(4th) in the United
States. 

Findings also indicate that the industries with the highest share in global layoffs are driven by the United States, where
around 84% of global layoffs in Consumer and around 77% in Retail occurred in the United States. The rest of the top global
industries also follow the same pattern, with around 62% of global layoffs in Transportation, 54% in 'Other', and 59% in Finance
occurring in the United States. Notably, out of 30 observed global industries, the United States was responsible for more than
80% of layoffs in 14 industries. Consequently, this proves the geographic influence and concentration of layoffs occurring in
one country. 

As the second highest country in terms of the magnitude of global layoffs, the share of Industries in India is lead by the 
Education with around 28%, followed by Transportation(~13.2%), Food(~11.6%), Finance(~9.2%), and Retail(~8.3%). Unlike the global
and the United States, the share of layoffs is noticeably concentrated in Education, followed by close distribution in the rest
of the industries in India. Additionally, while Consumer and Retail respectively lead the magnitude of the global and the United
States layoffs, they are ranked as sixth(~7.9%) and fifth(~8.3%) based on their share in India. Both Education and Food 
industries, which do not dominate neither global nor the United States layoffs, have a strong presence in India, while 
Transportation, Finance, and Retail sharing the top 5 similar to all observations. Moreover, India is responsible for the around
76% of global layoffs in the Education industry.
*/


-- =====================================================
-- 6.2 YoY comparison of selected countries' industries
-- =====================================================

SELECT *
FROM vw_industry;

SELECT *
FROM gl_us_ind_tree('2020-01-01', '2021-01-01');

SELECT *
FROM gl_us_ind_tree('2021-01-01', '2022-01-01');

SELECT *
FROM gl_us_ind_tree('2022-01-01', '2023-01-01');

SELECT *
FROM gl_us_ind_tree('2023-01-01', '2024-01-01');


-- =====================================================
-- Key Finding
-- =====================================================


/* 
Transportation showed a cyclical pattern throughout the years across all observations, where a year with a dominant share was 
followed by decline in global, the United States, and India. An extreme drop off occurred in 2021 across all observations in
Transportation. Overall, the United States has been the major driver of Transportation, being responsible for around 62% of 
global layoffs. Despite its cyclical pattern, moderate to high level of layoffs throughout the year made Transportation one of
the major global industries which account for the share of layoffs throughout the observed periods.(cyclical trend, US dominant)

Travel industry has experienced an overall negative trend over the years. Despite being the second highest industry for the share
of layofss globlly in 2020, the trajectory of its dominance experienced a decline in following periods, with an extreme of 
recording no layoffs in 2021, and having very low share in last two observed periods across all observations.(declining trend)

Retail on the other hand, has experienced a consistent moderate to high level of dominance across the periods, which was mainly 
lead by the layofss in the United States. Consistent layoffs in the industry has managed to make Retail the second highest 
industry for its share in layoffs. Overall, the United States was responsible for the 77% of global layoffs in Retail. 
Similar pattern is also evident on YoY basis, where the United States consistently drove the layoffs in the industry by 
accounting around 80% - 90% of global layoffs in Retail in two periods.(consistent performer, US dominant)

Finance was another cyclical industry with a year of moderate level of dominance followed by a decline in its share the next 
year. Despite having moderate share of global layoffs, the frequency of the global layoff events mostly occurred in the Finance.
Similar to some other mentioned industries, the United States was also a major contributor of global layoffs in Finance, 
accounting for 59% of global layoffs in the industry. (cyclical trend, US dominant) 

Consumer is one of the most consistent industries in the data. Despite having a low share in 2020, the following years show a
consistent major dominance globally, making it the industry with the highest layoffs across whole observed period. Additionally,
around 84% of global layoffs in the industry occurred in the United States, thus making the country the global driver for layoffs
in the most dominant industry.(consistent, US dominant)

Despite having a moderte share globally, Food industry has had an outlier-driven pattern, where a consistent low - moderate 
share was interrupted by a significant spike in 2021. Overall share of the industry accounts for 6% which makes it a moderate 
industry responsible for the global layoffs. Similar pattern of the United States' dominance is also prevalent in Food industry,
where around 54% of global layoffs in the industry occurred in the United States.(outlier driven, moderate consistent, US dom) 

Education, which is another outlier, was predominantly prevelant in India, accounting for around 28% of layoffs in the country.
Despite industry showing consistent low share globally, 2021 saw a spike in layoffs where around 93% of layoffs was responsible
by the India. Similarly, throughout the whole period, 76% of global layoffs in the industry occurred in India. (outlier driven,
low consistent, India driven)

The distribution of the industries acorss the United States followed similar pattern to global obsevation, where it was either
dominant by one or a select few industries, while rest having close distribution. The United States being the global driver in
layoffs across multiple industries explains the similarity among the global and the United States metrics. India however, showed
more top heavy concentration of industries on YoY basis.
*/