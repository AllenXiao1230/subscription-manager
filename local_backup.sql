--
-- PostgreSQL database dump
--

\restrict rvL0oUJA3GcxyzpnUvyG8cKRo2Locs5772QXTqRhvmcMDNHfRtWSTkQB8eRcHRA

-- Dumped from database version 15.14
-- Dumped by pg_dump version 15.14

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

ALTER TABLE ONLY public.subscriptions DROP CONSTRAINT subscriptions_payment_owner_id_fkey;
ALTER TABLE ONLY public.subscription_members DROP CONSTRAINT subscription_members_subscription_id_fkey;
ALTER TABLE ONLY public.subscription_members DROP CONSTRAINT subscription_members_member_id_fkey;
ALTER TABLE ONLY public.payments DROP CONSTRAINT payments_subscription_id_fkey;
ALTER TABLE ONLY public.payments DROP CONSTRAINT payments_member_id_fkey;
ALTER TABLE ONLY public.subscriptions DROP CONSTRAINT subscriptions_pkey;
ALTER TABLE ONLY public.subscription_members DROP CONSTRAINT subscription_members_pkey;
ALTER TABLE ONLY public.payments DROP CONSTRAINT payments_subscription_id_member_id_billing_period_key;
ALTER TABLE ONLY public.payments DROP CONSTRAINT payments_pkey;
ALTER TABLE ONLY public.members DROP CONSTRAINT members_pkey;
ALTER TABLE ONLY public.members DROP CONSTRAINT members_email_key;
ALTER TABLE public.subscriptions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.payments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.members ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE public.subscriptions_id_seq;
DROP TABLE public.subscriptions;
DROP TABLE public.subscription_members;
DROP SEQUENCE public.payments_id_seq;
DROP TABLE public.payments;
DROP SEQUENCE public.members_id_seq;
DROP TABLE public.members;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: members; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.members (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(255)
);


ALTER TABLE public.members OWNER TO admin;

--
-- Name: members_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.members_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.members_id_seq OWNER TO admin;

--
-- Name: members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.members_id_seq OWNED BY public.members.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    subscription_id integer,
    member_id integer,
    amount_paid numeric(10,2) NOT NULL,
    payment_date date NOT NULL,
    billing_period character varying(7) NOT NULL
);


ALTER TABLE public.payments OWNER TO admin;

--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.payments_id_seq OWNER TO admin;

--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- Name: subscription_members; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.subscription_members (
    subscription_id integer NOT NULL,
    member_id integer NOT NULL,
    share_amount numeric(10,2)
);


ALTER TABLE public.subscription_members OWNER TO admin;

--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.subscriptions (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    total_price numeric(10,2) NOT NULL,
    billing_cycle character varying(50) DEFAULT 'monthly'::character varying,
    next_payment_date date,
    payment_owner_id integer
);


ALTER TABLE public.subscriptions OWNER TO admin;

--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.subscriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.subscriptions_id_seq OWNER TO admin;

--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.subscriptions_id_seq OWNED BY public.subscriptions.id;


--
-- Name: members id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.members ALTER COLUMN id SET DEFAULT nextval('public.members_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- Name: subscriptions id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);


--
-- Data for Name: members; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.members (id, name, email) FROM stdin;
1	您自己	your@email.com
2	陳小花	flower@email.com
3	張大明	david@email.com
4	小郭	\N
5	比	\N
6	aaa	\N
7	aaa	\N
8	古佳玄	\N
9	朱雅安	\N
10	李昕亭	\N
11	楊子頤	\N
12	小潘	\N
13	珮榛	\N
14	小天	\N
15	佳🪡	\N
16	侯明諭	\N
17	您自己	\N
18	武品堯	\N
19	張承恩	\N
20	陳諾亞	\N
21	王申隆	\N
22	蕭宇呈	\N
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.payments (id, subscription_id, member_id, amount_paid, payment_date, billing_period) FROM stdin;
2	1	2	130.00	2025-09-07	2025-09
3	1	3	130.00	2025-09-05	2025-09
5	1	3	130.00	2025-10-05	2025-10
16	1	11	92.00	2025-10-24	2025-08
17	1	10	92.00	2025-10-24	2025-08
18	1	9	92.00	2025-10-24	2025-08
19	1	8	92.00	2025-10-24	2025-08
20	1	1	92.00	2025-10-24	2025-08
21	1	11	92.00	2025-10-24	2025-09
22	1	10	92.00	2025-10-24	2025-09
23	1	9	92.00	2025-10-24	2025-09
24	1	8	92.00	2025-10-24	2025-09
25	1	1	92.00	2025-10-24	2025-09
26	2	1	49.67	2025-10-24	2024-12
27	2	12	49.67	2025-10-24	2024-12
28	2	1	49.67	2025-10-24	2025-01
29	2	1	49.67	2025-10-24	2025-02
30	2	1	49.67	2025-10-24	2025-03
31	2	1	49.67	2025-10-24	2025-04
32	2	1	49.67	2025-10-24	2025-05
33	2	1	49.67	2025-10-24	2025-06
34	2	1	49.67	2025-10-24	2025-07
35	2	1	49.67	2025-10-24	2025-08
36	2	12	49.67	2025-10-24	2025-08
37	2	12	49.67	2025-10-24	2025-07
38	2	12	49.67	2025-10-24	2025-06
39	2	12	49.67	2025-10-24	2025-05
40	2	12	49.67	2025-10-24	2025-04
41	2	12	49.67	2025-10-24	2025-03
42	2	12	49.67	2025-10-24	2025-02
43	2	12	49.67	2025-10-24	2025-01
44	2	13	49.67	2025-10-24	2024-12
45	2	13	49.67	2025-10-24	2025-01
46	2	13	49.67	2025-10-24	2025-02
47	2	13	49.67	2025-10-24	2025-03
48	2	13	49.67	2025-10-24	2025-04
49	2	14	49.67	2025-10-24	2025-05
50	2	13	49.67	2025-10-24	2025-05
51	2	13	49.67	2025-10-24	2025-06
52	2	13	49.67	2025-10-24	2025-07
54	2	14	49.67	2025-10-24	2025-08
55	2	14	49.67	2025-10-24	2025-07
57	2	14	49.67	2025-10-24	2025-04
58	2	14	49.67	2025-10-24	2025-03
59	2	14	49.67	2025-10-24	2025-02
60	2	14	49.67	2025-10-24	2025-01
61	2	14	49.67	2025-10-24	2024-12
62	2	15	49.67	2025-10-24	2024-12
63	2	15	49.67	2025-10-24	2025-01
64	2	15	49.67	2025-10-24	2025-02
65	2	15	49.67	2025-10-24	2025-03
66	2	15	49.67	2025-10-24	2025-04
67	2	15	49.67	2025-10-24	2025-05
68	2	14	49.67	2025-10-24	2025-06
69	2	15	49.67	2025-10-24	2025-06
70	2	15	49.67	2025-10-24	2025-07
71	2	15	49.67	2025-10-24	2025-08
72	2	16	49.67	2025-10-24	2025-08
73	2	16	49.67	2025-10-24	2025-07
74	2	16	49.67	2025-10-24	2025-06
75	2	16	49.67	2025-10-24	2025-05
76	2	16	49.67	2025-10-24	2025-04
77	2	16	49.67	2025-10-24	2025-03
78	2	16	49.67	2025-10-24	2025-02
79	2	16	49.67	2025-10-24	2025-01
80	2	16	49.67	2025-10-24	2024-12
81	2	12	49.67	2025-10-24	2025-09
82	2	12	49.67	2025-10-24	2025-10
83	2	12	49.67	2025-10-24	2025-11
84	3	18	79.83	2025-10-24	2024-12
85	3	18	79.83	2025-10-24	2025-01
86	3	17	79.83	2025-10-24	2024-12
87	3	17	79.83	2025-10-24	2025-01
88	3	17	79.83	2025-10-24	2025-02
89	3	17	79.83	2025-10-24	2025-03
90	3	17	79.83	2025-10-24	2025-04
91	3	17	79.83	2025-10-24	2025-05
92	3	17	79.83	2025-10-24	2025-06
93	3	17	79.83	2025-10-24	2025-07
94	3	17	79.83	2025-10-24	2025-08
95	3	17	79.83	2025-10-24	2025-09
96	2	1	49.67	2025-10-24	2025-09
97	3	22	79.83	2025-10-24	2024-12
98	3	22	79.83	2025-10-24	2025-01
99	3	22	79.83	2025-10-24	2025-02
100	3	22	79.83	2025-10-24	2025-03
101	3	22	79.83	2025-10-24	2025-04
102	3	22	79.83	2025-10-24	2025-05
103	2	15	49.67	2025-10-24	2025-09
104	3	22	79.83	2025-10-24	2025-06
105	3	22	79.83	2025-10-24	2025-07
106	3	22	79.83	2025-10-24	2025-08
107	3	22	79.83	2025-10-24	2025-09
108	3	22	79.83	2025-10-24	2025-10
109	3	22	79.83	2025-10-24	2025-11
110	3	18	79.83	2025-10-24	2025-02
111	3	18	79.83	2025-10-24	2025-03
112	3	18	79.83	2025-10-24	2025-04
113	3	18	79.83	2025-10-24	2025-05
114	3	18	79.83	2025-10-24	2025-06
115	3	18	79.83	2025-10-24	2025-07
116	3	18	79.83	2025-10-24	2025-08
117	3	18	79.83	2025-10-24	2025-09
118	3	18	79.83	2025-10-24	2025-10
120	3	21	79.83	2025-10-24	2025-09
\.


--
-- Data for Name: subscription_members; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.subscription_members (subscription_id, member_id, share_amount) FROM stdin;
3	17	79.83
3	18	79.83
3	19	79.83
3	20	79.83
3	21	79.83
3	22	79.83
1	1	92.00
1	8	92.00
1	9	92.00
1	10	92.00
1	11	92.00
2	1	49.67
2	12	49.67
2	13	49.67
2	14	49.67
2	15	49.67
2	16	49.67
\.


--
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.subscriptions (id, name, total_price, billing_cycle, next_payment_date, payment_owner_id) FROM stdin;
1	Netflix 家庭方案	460.00	monthly	2025-11-03	1
2	Spotify	298.00	monthly	2025-11-15	1
3	YT	479.00	monthly	2025-11-06	1
\.


--
-- Name: members_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.members_id_seq', 22, true);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.payments_id_seq', 120, true);


--
-- Name: subscriptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.subscriptions_id_seq', 3, true);


--
-- Name: members members_email_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_email_key UNIQUE (email);


--
-- Name: members members_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: payments payments_subscription_id_member_id_billing_period_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_subscription_id_member_id_billing_period_key UNIQUE (subscription_id, member_id, billing_period);


--
-- Name: subscription_members subscription_members_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.subscription_members
    ADD CONSTRAINT subscription_members_pkey PRIMARY KEY (subscription_id, member_id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: payments payments_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(id) ON DELETE CASCADE;


--
-- Name: payments payments_subscription_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES public.subscriptions(id) ON DELETE CASCADE;


--
-- Name: subscription_members subscription_members_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.subscription_members
    ADD CONSTRAINT subscription_members_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(id) ON DELETE CASCADE;


--
-- Name: subscription_members subscription_members_subscription_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.subscription_members
    ADD CONSTRAINT subscription_members_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES public.subscriptions(id) ON DELETE CASCADE;


--
-- Name: subscriptions subscriptions_payment_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_payment_owner_id_fkey FOREIGN KEY (payment_owner_id) REFERENCES public.members(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict rvL0oUJA3GcxyzpnUvyG8cKRo2Locs5772QXTqRhvmcMDNHfRtWSTkQB8eRcHRA

