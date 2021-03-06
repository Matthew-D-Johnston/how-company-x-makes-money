--
-- PostgreSQL database dump
--

-- Dumped from database version 12.3
-- Dumped by pg_dump version 12.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: companies; Type: TABLE; Schema: public; Owner: matthewjohnston
--

CREATE TABLE public.companies (
    id integer NOT NULL,
    name text NOT NULL,
    nickname text NOT NULL,
    ticker text NOT NULL,
    CONSTRAINT companies_ticker_check CHECK ((ticker = upper(ticker)))
);


ALTER TABLE public.companies OWNER TO matthewjohnston;

--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: matthewjohnston
--

CREATE SEQUENCE public.companies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.companies_id_seq OWNER TO matthewjohnston;

--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: matthewjohnston
--

ALTER SEQUENCE public.companies_id_seq OWNED BY public.companies.id;


--
-- Name: financial_data; Type: TABLE; Schema: public; Owner: matthewjohnston
--

CREATE TABLE public.financial_data (
    id integer NOT NULL,
    company_id integer NOT NULL,
    report_id integer NOT NULL,
    source_page text NOT NULL,
    currency text NOT NULL,
    segment text NOT NULL,
    metric text NOT NULL,
    unit text NOT NULL,
    data_current_period integer NOT NULL,
    data_year_ago_period integer NOT NULL,
    CONSTRAINT financial_data_unit_check CHECK ((unit = ANY (ARRAY['b'::text, 'm'::text, 't'::text, 'N/A'::text])))
);


ALTER TABLE public.financial_data OWNER TO matthewjohnston;

--
-- Name: financial_data_id_seq; Type: SEQUENCE; Schema: public; Owner: matthewjohnston
--

CREATE SEQUENCE public.financial_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.financial_data_id_seq OWNER TO matthewjohnston;

--
-- Name: financial_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: matthewjohnston
--

ALTER SEQUENCE public.financial_data_id_seq OWNED BY public.financial_data.id;


--
-- Name: financial_report; Type: TABLE; Schema: public; Owner: matthewjohnston
--

CREATE TABLE public.financial_report (
    id integer NOT NULL,
    company_id integer NOT NULL,
    quarter integer NOT NULL,
    year integer NOT NULL,
    period_end_date date NOT NULL,
    source text NOT NULL,
    source_url text NOT NULL,
    number_of_segments integer NOT NULL,
    special_form_date text,
    CONSTRAINT financial_report_quarter_check CHECK (((quarter >= 0) AND (quarter <= 4)))
);


ALTER TABLE public.financial_report OWNER TO matthewjohnston;

--
-- Name: financial_report_id_seq; Type: SEQUENCE; Schema: public; Owner: matthewjohnston
--

CREATE SEQUENCE public.financial_report_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.financial_report_id_seq OWNER TO matthewjohnston;

--
-- Name: financial_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: matthewjohnston
--

ALTER SEQUENCE public.financial_report_id_seq OWNED BY public.financial_report.id;


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: matthewjohnston
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);


--
-- Name: financial_data id; Type: DEFAULT; Schema: public; Owner: matthewjohnston
--

ALTER TABLE ONLY public.financial_data ALTER COLUMN id SET DEFAULT nextval('public.financial_data_id_seq'::regclass);


--
-- Name: financial_report id; Type: DEFAULT; Schema: public; Owner: matthewjohnston
--

ALTER TABLE ONLY public.financial_report ALTER COLUMN id SET DEFAULT nextval('public.financial_report_id_seq'::regclass);


--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: matthewjohnston
--

COPY public.companies (id, name, nickname, ticker) FROM stdin;
1	Twitter Inc	Twitter	TWTR
2	Lockheed Martin Corp	Lockheed Martin	LMT
3	BlackRock Inc	BlackRock	BLK
4	Uber Technologies Inc	Uber	UBER
5	Nike Inc	Nike	NKE
6	Netflix Inc	Netflix	NFLX
7	Spotify Technology SA	Spotify	SPOT
\.


--
-- Data for Name: financial_data; Type: TABLE DATA; Schema: public; Owner: matthewjohnston
--

COPY public.financial_data (id, company_id, report_id, source_page, currency, segment, metric, unit, data_current_period, data_year_ago_period) FROM stdin;
1	1	1	7	$	Total	Revenue	t	683438	841381
2	1	1	7	$	Total	Net income	t	-1378005	1119560
3	1	1	13	$	Advertising services	Revenue	t	561994	727123
4	1	1	13	$	Data licensing and other	Revenue	t	121444	114258
5	2	2	3	$	Total	Net sales	m	16220	14427
6	2	2	3	$	Total	Net earnings	m	1626	1420
7	2	2	11	$	Aeronautics	Net sales	m	6503	5550
8	2	2	11	$	Aeronautics	Operating profit	m	739	592
9	2	2	11	$	Missiles and Fire Control 	Net sales	m	2801	2411
10	2	2	11	$	Missiles and Fire Control 	Operating profit	m	370	327
11	2	2	11	$	Rotary and Mission Systems	Net sales	m	4039	3768
12	2	2	11	$	Rotary and Mission Systems	Operating profit	m	429	347
13	2	2	11	$	Space	Net sales	m	2877	2698
14	2	2	11	$	Space	Operating profit	m	252	288
15	3	3	2	$	Total	Revenue	m	3648	3524
16	3	3	2	$	Total	Net income	m	1402	1013
17	3	3	2	$	Investment advisory, administration fees and  securities lending	Revenue	m	2966	2903
18	3	3	2	$	Investment advisory performance fees	Revenue	m	112	64
19	3	3	2	$	Technology services	Revenue	m	278	237
20	3	3	2	$	Distribution fees	Revenue	m	253	267
21	3	3	2	$	Advisory and other	Revenue	m	39	53
22	4	4	5	$	Total	Revenue	m	2241	3166
23	4	4	5	$	Total	Net income	m	-1772	-5246
24	4	4	14	$	Mobility	Revenue	m	790	2376
25	4	4	35	$	Mobility	Adjusted EBITDA	m	50	506
26	4	4	14	$	Delivery	Revenue	m	1211	595
27	4	4	35	$	Delivery	Adjusted EBITDA	m	-232	-286
28	4	4	14	$	Freight	Revenue	m	211	167
29	4	4	35	$	Freight	Adjusted EBITDA	m	-49	-52
30	4	4	14	$	ATG and Other Technology Programs	Revenue	m	25	0
31	4	4	35	$	ATG and Other Technology Programs	Adjusted EBITDA	m	-91	-132
32	4	4	14	$	Other Bets	Revenue	m	4	28
33	4	4	35	$	Other Bets	Adjusted EBITDA	m	-23	-70
34	5	5	25	$	Total	Revenue	m	37403	39117
35	5	5	25	$	Total	Net income	m	2539	4029
36	5	5	35	$	North America	Revenue	m	14484	15902
37	5	5	35	$	North America	EBIT	m	2899	3925
38	5	5	35	$	Europe, Middle East & Africa	Revenue	m	9347	9812
39	5	5	35	$	Europe, Middle East & Africa	EBIT	m	1541	1995
40	5	5	35	$	Greater China	Revenue	m	6679	6208
41	5	5	35	$	Greater China	EBIT	m	2490	2376
42	5	5	35	$	Asia Pacific & Latin America	Revenue	m	5028	5254
43	5	5	35	$	Asia Pacific & Latin America	EBIT	m	1184	1323
44	5	5	35	$	Global Brand Divisions	Revenue	m	30	42
45	5	5	35	$	Global Brand Divisions	EBIT	m	-3468	-3262
46	6	6	3	$	Total	Revenue	t	6148286	4923116
47	6	6	3	$	Total	Net income	t	720196	270650
48	6	6	8	$	United States and Canada (UCAN)	Revenue	t	2839670	2501199
49	6	6	9	$	Europe, Middle East, and Africa (EMEA)	Revenue	t	1892537	1319087
50	6	6	9	$	Latin America (LATAM)	Revenue	t	785368	677136
51	6	6	9	$	Asia-Pacific (APAC)	Revenue	t	569140	349494
52	7	7	1	€	Total	Revenue	m	1889	1667
53	7	7	1	€	Total	Net income	m	-356	-76
54	7	7	30	€	Premium Service	Revenue	m	1758	1502
55	7	7	32	€	Premium Service	Gross profit	m	495	413
56	7	7	30	€	Ad-Supported Service	Revenue	m	131	165
57	7	7	32	€	Ad-Supported Service	Gross profit	m	-16	21
\.


--
-- Data for Name: financial_report; Type: TABLE DATA; Schema: public; Owner: matthewjohnston
--

COPY public.financial_report (id, company_id, quarter, year, period_end_date, source, source_url, number_of_segments, special_form_date) FROM stdin;
1	1	2	2020	2020-06-30	10-Q	https://d18rn0p25nwr6d.cloudfront.net/CIK-0001418091/51caa042-6314-4604-92ee-98dfb080ac5b.pdf	2	N/A
2	2	2	2020	2020-06-28	10-Q	https://investors.lockheedmartin.com/static-files/2fdcca51-9038-4a84-8a59-7d8d4348330c	4	N/A
3	3	2	2020	2020-06-30	10-Q	http://d18rn0p25nwr6d.cloudfront.net/CIK-0001364742/ac685253-accc-48fb-bacc-4a81d52c6f40.pdf	5	N/A
4	4	2	2020	2020-06-30	10-Q	https://d18rn0p25nwr6d.cloudfront.net/CIK-0001543151/6be7ca8c-d5b0-44b5-96ea-7322b601fa82.pdf	5	N/A
5	5	0	2020	2020-05-31	10-K	http://d18rn0p25nwr6d.cloudfront.net/CIK-0000320187/72b61935-3ee0-4f79-a564-0d5134713574.pdf	5	N/A
6	6	2	2020	2020-06-30	10-Q	http://d18rn0p25nwr6d.cloudfront.net/CIK-0001065280/bcff7d52-7a7d-4e0c-8265-4b6860929fb1.pdf	4	N/A
7	7	2	2020	2020-06-30	6-K	http://d18rn0p25nwr6d.cloudfront.net/CIK-0001639920/818bc571-7eb0-4959-bc59-bff08fe6a2a0.pdf	2	July, 2020
\.


--
-- Name: companies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: matthewjohnston
--

SELECT pg_catalog.setval('public.companies_id_seq', 7, true);


--
-- Name: financial_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: matthewjohnston
--

SELECT pg_catalog.setval('public.financial_data_id_seq', 57, true);


--
-- Name: financial_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: matthewjohnston
--

SELECT pg_catalog.setval('public.financial_report_id_seq', 7, true);


--
-- Name: companies companies_name_key; Type: CONSTRAINT; Schema: public; Owner: matthewjohnston
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_name_key UNIQUE (name);


--
-- Name: companies companies_nickname_key; Type: CONSTRAINT; Schema: public; Owner: matthewjohnston
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_nickname_key UNIQUE (nickname);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: matthewjohnston
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: companies companies_ticker_key; Type: CONSTRAINT; Schema: public; Owner: matthewjohnston
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_ticker_key UNIQUE (ticker);


--
-- Name: financial_data financial_data_pkey; Type: CONSTRAINT; Schema: public; Owner: matthewjohnston
--

ALTER TABLE ONLY public.financial_data
    ADD CONSTRAINT financial_data_pkey PRIMARY KEY (id);


--
-- Name: financial_report financial_report_company_id_quarter_period_end_date_source_key; Type: CONSTRAINT; Schema: public; Owner: matthewjohnston
--

ALTER TABLE ONLY public.financial_report
    ADD CONSTRAINT financial_report_company_id_quarter_period_end_date_source_key UNIQUE (company_id, quarter, period_end_date, source);


--
-- Name: financial_report financial_report_pkey; Type: CONSTRAINT; Schema: public; Owner: matthewjohnston
--

ALTER TABLE ONLY public.financial_report
    ADD CONSTRAINT financial_report_pkey PRIMARY KEY (id);


--
-- Name: financial_data financial_data_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: matthewjohnston
--

ALTER TABLE ONLY public.financial_data
    ADD CONSTRAINT financial_data_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: financial_data financial_data_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: matthewjohnston
--

ALTER TABLE ONLY public.financial_data
    ADD CONSTRAINT financial_data_report_id_fkey FOREIGN KEY (report_id) REFERENCES public.financial_report(id);


--
-- Name: financial_report financial_report_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: matthewjohnston
--

ALTER TABLE ONLY public.financial_report
    ADD CONSTRAINT financial_report_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- PostgreSQL database dump complete
--

