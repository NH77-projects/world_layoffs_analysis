--
-- PostgreSQL database dump
--

\restrict D9gfQUyFZXzTp8gbrgeIrUkpCN0URioy9r4NlZjvn9lOM8nBjXy2GVuBJzAuqbD

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2026-06-25 15:03:29

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 240 (class 1255 OID 17796)
-- Name: company_at_least_half_lay_off_tree(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.company_at_least_half_lay_off_tree(start_date date, end_date date) RETURNS TABLE(company text, industry text, company_laid_off bigint, pct_laid_off numeric, country text)
    LANGUAGE sql
    AS $$
WITH base AS (
	SELECT *
	FROM layoffs_staging
		WHERE date >= start_date
		AND date < end_date
		AND percentage_laid_off >= 0.5
)
	SELECT company, industry, total_laid_off AS company_laid_off, percentage_laid_off AS pct_laid_off, country
	FROM base
	ORDER BY company_laid_off DESC
$$;


ALTER FUNCTION public.company_at_least_half_lay_off_tree(start_date date, end_date date) OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 17798)
-- Name: company_full_lay_off_tree(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.company_full_lay_off_tree(start_date date, end_date date) RETURNS TABLE(company text, industry text, country text, total_laid_off bigint)
    LANGUAGE sql
    AS $$
WITH base AS (
	SELECT *
	FROM layoffs_staging
		WHERE date >= start_date
		AND date < end_date
		AND percentage_laid_off = 1
)
	SELECT company, industry, country, SUM(total_laid_off) AS total_laid_off
	FROM base
	GROUP BY company, industry, country
	ORDER BY total_laid_off DESC
$$;


ALTER FUNCTION public.company_full_lay_off_tree(start_date date, end_date date) OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 17786)
-- Name: company_tree(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.company_tree(start_date date, end_date date) RETURNS TABLE(company text, company_laid_off bigint, pct_share_all numeric, company_laid_off_all bigint, num_events bigint)
    LANGUAGE sql
    AS $$
WITH base AS (
	SELECT *
	FROM layoffs_staging
		WHERE date >= start_date
		AND date < end_date
		AND total_laid_off IS NOT NULL
),
agg AS (
	SELECT 
		company,
		SUM(total_laid_off) AS company_laid_off,
		COUNT(*) AS num_events
	FROM base
	GROUP BY company
)
	SELECT 
		company,
		company_laid_off,
		ROUND(100.0 * company_laid_off / SUM(company_laid_off) OVER(), 2) AS pct_share_all,
		SUM(company_laid_off) OVER () AS company_laid_off_all,
		num_events
	FROM agg
	ORDER BY company_laid_off DESC
$$;


ALTER FUNCTION public.company_tree(start_date date, end_date date) OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 17768)
-- Name: country_tree(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.country_tree(start_date date, end_date date) RETURNS TABLE(country text, total_laid_off bigint, pct_laid_off numeric, total_laid_off_all bigint, num_events bigint, pct_events numeric, total_events bigint)
    LANGUAGE sql
    AS $$
WITH base AS(
	SELECT *
	FROM layoffs_staging
		WHERE date >= start_date
		AND date < end_date
		AND total_laid_off IS NOT NULL
),
agg AS(
	SELECT 
		country,
		SUM(total_laid_off) AS total_laid_off,
		COUNT(*) AS num_events
	FROM base
	GROUP BY country
)
	SELECT 
		country,
		total_laid_off,
		ROUND(100.0 * total_laid_off / SUM(total_laid_off) OVER(), 2) AS pct_laid_off,
		SUM(total_laid_off) OVER() AS total_laid_off_all,
		num_events,
		ROUND(100.0 * num_events / SUM(num_events) OVER(), 2) AS pct_events,
		SUM(num_events) OVER() AS total_events
	FROM agg
	ORDER BY total_laid_off DESC
$$;


ALTER FUNCTION public.country_tree(start_date date, end_date date) OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 17772)
-- Name: gl_us_ind_tree(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gl_us_ind_tree(start_date date, end_date date) RETURNS TABLE(global_industry text, global_laid_off bigint, global_pct_laid_off numeric, global_laid_off_all bigint, global_num_events bigint, global_pct_events numeric, global_total_events bigint, us_industry text, us_laid_off bigint, us_pct_laid_off numeric, us_laid_off_all bigint, us_num_events bigint, us_pct_events numeric, us_total_events bigint, ind_industry text, ind_laid_off bigint, ind_pct_laid_off numeric, ind_laid_off_all bigint, ind_num_events bigint, ind_pct_events numeric, ind_total_events bigint)
    LANGUAGE sql
    AS $$
WITH base AS(
	SELECT *
	FROM layoffs_staging
		WHERE date >= start_date
		AND date < end_date
		AND total_laid_off IS NOT NULL
),
global_cte AS(
	SELECT 
		industry,
		SUM(total_laid_off) AS global_laid_off,
		COUNT(*) AS global_num_events
	FROM base
	GROUP BY industry
),
us_cte AS(
	SELECT 
		industry,
		SUM(total_laid_off) AS us_laid_off,
		COUNT(*) AS us_num_events
	FROM base
	WHERE country = 'United States'
	GROUP BY industry
),
ind_cte AS(
	SELECT 
		industry,
		SUM(total_laid_off) AS ind_laid_off,
		COUNT(*) AS ind_num_events
	FROM base
	WHERE country = 'India'
	GROUP BY industry
),
joined_cte AS(
	SELECT 
		g.industry AS global_industry,
		global_laid_off,
		global_num_events,
		u.industry AS us_industry,
		us_laid_off,
		us_num_events,
		i.industry AS ind_industry,
		ind_laid_off,
		ind_num_events
	FROM global_cte AS g
		FULL OUTER JOIN us_cte AS u
			ON g.industry = u.industry
		FULL OUTER JOIN ind_cte AS i
			ON g.industry = i.industry
)
	SELECT 
		global_industry,
		global_laid_off,
		ROUND(100.0 * global_laid_off / SUM(global_laid_off) OVER(), 2) AS global_pct_laid_off,
		SUM(global_laid_off) OVER() AS global_laid_off_all,
		global_num_events,
		ROUND(100.0 * global_num_events / SUM(global_num_events) OVER(), 2) AS global_pct_events,
		SUM(global_num_events) OVER() AS global_total_events,
		us_industry,
		us_laid_off,
		ROUND(100.0 * us_laid_off / SUM(us_laid_off) OVER(), 2) AS us_pct_laid_off,
		SUM(us_laid_off) OVER() AS us_laid_off_all,
		us_num_events,
		ROUND(100.0 * us_num_events / SUM(us_num_events) OVER(), 2) AS us_pct_events,
		SUM(us_num_events) OVER() AS us_total_events,
		ind_industry,
		ind_laid_off,
		ROUND(100.0 * ind_laid_off / SUM(ind_laid_off) OVER(), 2) AS ind_pct_laid_off,
		SUM(ind_laid_off) OVER() AS ind_laid_off_all,
		ind_num_events,
		ROUND(100.0 * ind_num_events / SUM(ind_num_events) OVER(), 2) AS ind_pct_events,
		SUM(ind_num_events) OVER() AS ind_total_events
	FROM joined_cte
	ORDER BY global_laid_off DESC
$$;


ALTER FUNCTION public.gl_us_ind_tree(start_date date, end_date date) OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 17764)
-- Name: industry_tree(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.industry_tree(start_date date, end_date date) RETURNS TABLE(industry text, total_laid_off bigint, pct_laid_off numeric, total_laid_off_all bigint, num_events bigint, pct_num_events numeric, total_events bigint)
    LANGUAGE sql
    AS $$
WITH base AS(
	SELECT *
	FROM layoffs_staging
		WHERE date >= start_date
		AND date < end_date
		AND total_laid_off IS NOT NULL
),
agg AS(
	SELECT 
		industry,
		SUM(total_laid_off) AS total_laid_off,
		COUNT(*) AS num_events
	FROM base
	GROUP BY industry
)
SELECT 
	industry,
	total_laid_off,
	ROUND(100.0 * total_laid_off / SUM(total_laid_off) OVER(), 2) AS pct_laid_off,
	SUM(total_laid_off) OVER() AS total_laid_off_all,
	num_events,
	ROUND(100.0 * num_events / SUM(num_events) OVER(), 2) AS pct_num_events,
	SUM(num_events) OVER() AS total_events
FROM agg
ORDER BY total_laid_off DESC
$$;


ALTER FUNCTION public.industry_tree(start_date date, end_date date) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 221 (class 1259 OID 17709)
-- Name: comparative_metric_analysis_2020; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comparative_metric_analysis_2020 (
    global_industry text,
    industry_sum_total_laid_off_2020 bigint,
    percentage_industry_sum_total_laid_off_2020 numeric,
    industry_num_of_layoff_events_2020 bigint,
    us_industry text,
    us_industry_laid_off_2020 bigint,
    percentage_us_industry_laid_off_2020 numeric,
    us_industry_num_of_layoff_events_2020 bigint,
    india_industry text,
    in_industry_laid_off_2020 bigint,
    percentage_in_industry_laid_off_2020 numeric,
    in_industry_num_of_layoff_events_2020 bigint
);


ALTER TABLE public.comparative_metric_analysis_2020 OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 17719)
-- Name: comparative_metric_analysis_2021; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comparative_metric_analysis_2021 (
    global_industry text,
    global_industry_laid_off_2021 bigint,
    global_percentage_industry_total_laid_off_2021 numeric,
    global_total_laid_off_2021 numeric,
    global_num_of_events_2021 bigint,
    global_percentage_of_events_2021 numeric,
    global_total_num_of_events_2021 numeric,
    us_industry text,
    us_industry_laid_off_2021 bigint,
    us_percentage_industry_total_laid_off_2021 numeric,
    us_total_laid_off_2021 numeric,
    us_num_of_events_2021 bigint,
    us_percentage_of_events_2021 numeric,
    us_total_num_of_events_2021 numeric,
    ind_industry text,
    ind_industry_laid_off_2021 bigint,
    ind_percentage_industry_total_laid_off_2021 numeric,
    ind_total_laid_off_2021 numeric,
    ind_num_of_events_2021 bigint,
    ind_percentage_of_events_2021 numeric,
    ind_total_num_of_events_2021 numeric
);


ALTER TABLE public.comparative_metric_analysis_2021 OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 17811)
-- Name: industry_year_rank_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.industry_year_rank_view AS
 WITH yearly_industry AS (
         SELECT '2020'::text AS period,
            industry_tree.industry,
            industry_tree.pct_laid_off AS share,
            rank() OVER (ORDER BY industry_tree.pct_laid_off DESC) AS rank
           FROM public.industry_tree('2020-01-01'::date, '2021-01-01'::date) industry_tree(industry, total_laid_off, pct_laid_off, total_laid_off_all, num_events, pct_num_events, total_events)
        UNION ALL
         SELECT '2021'::text,
            industry_tree.industry,
            industry_tree.pct_laid_off,
            rank() OVER (ORDER BY industry_tree.pct_laid_off DESC) AS rank
           FROM public.industry_tree('2021-01-01'::date, '2022-01-01'::date) industry_tree(industry, total_laid_off, pct_laid_off, total_laid_off_all, num_events, pct_num_events, total_events)
        UNION ALL
         SELECT '2022'::text,
            industry_tree.industry,
            industry_tree.pct_laid_off,
            rank() OVER (ORDER BY industry_tree.pct_laid_off DESC) AS rank
           FROM public.industry_tree('2022-01-01'::date, '2023-01-01'::date) industry_tree(industry, total_laid_off, pct_laid_off, total_laid_off_all, num_events, pct_num_events, total_events)
        UNION ALL
         SELECT '2023'::text,
            industry_tree.industry,
            industry_tree.pct_laid_off,
            rank() OVER (ORDER BY industry_tree.pct_laid_off DESC) AS rank
           FROM public.industry_tree('2023-01-01'::date, '2024-01-01'::date) industry_tree(industry, total_laid_off, pct_laid_off, total_laid_off_all, num_events, pct_num_events, total_events)
        )
 SELECT period,
    industry,
    share,
    rank
   FROM yearly_industry
  ORDER BY industry, period;


ALTER VIEW public.industry_year_rank_view OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 17641)
-- Name: layoffs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.layoffs (
    company text,
    location text,
    industry text,
    total_laid_off integer,
    percentage_laid_off numeric(3,2),
    date date,
    stage text,
    country text,
    funds_raised_millions numeric(15,2)
);


ALTER TABLE public.layoffs OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 17691)
-- Name: layoffs_staging; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.layoffs_staging (
    company text,
    location text,
    industry text,
    total_laid_off integer,
    percentage_laid_off numeric(3,2),
    date date,
    stage text,
    country text,
    funds_raised_millions numeric(15,2)
);


ALTER TABLE public.layoffs_staging OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 17816)
-- Name: vw_industry; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_industry AS
 SELECT industry,
    total_laid_off,
    pct_laid_off,
    total_laid_off_all,
    num_events,
    pct_num_events,
    total_events
   FROM public.industry_tree('2020-01-01'::date, '2024-01-01'::date) industry_tree(industry, total_laid_off, pct_laid_off, total_laid_off_all, num_events, pct_num_events, total_events);


ALTER VIEW public.vw_industry OWNER TO postgres;

-- Completed on 2026-06-25 15:03:34

--
-- PostgreSQL database dump complete
--

\unrestrict D9gfQUyFZXzTp8gbrgeIrUkpCN0URioy9r4NlZjvn9lOM8nBjXy2GVuBJzAuqbD

