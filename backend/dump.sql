--
-- PostgreSQL database dump
--

\restrict 8KOnsQ8c9IeGGqPi2GKrL8OIDGXWaGRkWMtyT2jKgeDolhDgOLUjtTJdeUscMDh

-- Dumped from database version 16.13
-- Dumped by pg_dump version 16.13

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
-- Name: admission_mcq_options; Type: TABLE; Schema: public; Owner: exambank
--

CREATE TABLE public.admission_mcq_options (
    id uuid NOT NULL,
    question_id uuid NOT NULL,
    label character varying(16) NOT NULL,
    text text NOT NULL,
    display_order integer NOT NULL,
    image_filename text
);


ALTER TABLE public.admission_mcq_options OWNER TO exambank;

--
-- Name: admission_mcq_questions; Type: TABLE; Schema: public; Owner: exambank
--

CREATE TABLE public.admission_mcq_questions (
    id uuid NOT NULL,
    paper_id uuid NOT NULL,
    question_number character varying(32) NOT NULL,
    question_text text NOT NULL,
    subject character varying(64),
    chapter character varying(128),
    correct_answer character varying(16),
    solution text,
    solution_status character varying(16) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    university_name text,
    exam_session text,
    exam_unit text,
    images jsonb,
    has_image boolean GENERATED ALWAYS AS ((question_text ~~ '%[IMAGE%'::text)) STORED NOT NULL,
    gemini_solution text,
    gemini_correct_answer character varying(16)
);


ALTER TABLE public.admission_mcq_questions OWNER TO exambank;

--
-- Name: admission_written_questions; Type: TABLE; Schema: public; Owner: exambank
--

CREATE TABLE public.admission_written_questions (
    id uuid NOT NULL,
    paper_id uuid NOT NULL,
    question_number character varying(32) NOT NULL,
    question_text text NOT NULL,
    university_name text,
    exam_session text,
    exam_unit text,
    subject character varying(64),
    chapter character varying(128),
    solution text,
    solution_status character varying(16) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    images jsonb,
    has_image boolean GENERATED ALWAYS AS ((question_text ~~ '%[IMAGE%'::text)) STORED NOT NULL
);


ALTER TABLE public.admission_written_questions OWNER TO exambank;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: exambank
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO exambank;

--
-- Name: attempt_answers; Type: TABLE; Schema: public; Owner: exambank
--

CREATE TABLE public.attempt_answers (
    id uuid NOT NULL,
    attempt_id uuid NOT NULL,
    question_id uuid NOT NULL,
    selected_label character varying(16) NOT NULL,
    is_correct boolean NOT NULL,
    answered_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.attempt_answers OWNER TO exambank;

--
-- Name: attempts; Type: TABLE; Schema: public; Owner: exambank
--

CREATE TABLE public.attempts (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    kind character varying(16) NOT NULL,
    mode character varying(16) NOT NULL,
    paper_id uuid,
    drill_subject character varying(64),
    drill_chapter character varying(128),
    duration_sec integer,
    question_ids uuid[] NOT NULL,
    status character varying(16) DEFAULT 'in_progress'::character varying NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    submitted_at timestamp with time zone,
    score_correct integer,
    score_total integer,
    elapsed_sec integer,
    exam_type character varying(32),
    CONSTRAINT ck_attempts_kind CHECK (((kind)::text = ANY ((ARRAY['exam'::character varying, 'drill'::character varying, 'subject_quiz'::character varying])::text[]))),
    CONSTRAINT ck_attempts_kind_shape CHECK (((((kind)::text = 'exam'::text) AND (paper_id IS NOT NULL)) OR (((kind)::text = 'drill'::text) AND (drill_subject IS NOT NULL) AND (drill_chapter IS NOT NULL)) OR (((kind)::text = 'subject_quiz'::text) AND (drill_subject IS NOT NULL)))),
    CONSTRAINT ck_attempts_mode CHECK (((mode)::text = ANY ((ARRAY['timed'::character varying, 'untimed'::character varying])::text[]))),
    CONSTRAINT ck_attempts_status CHECK (((status)::text = ANY ((ARRAY['in_progress'::character varying, 'submitted'::character varying, 'abandoned'::character varying])::text[])))
);


ALTER TABLE public.attempts OWNER TO exambank;

--
-- Name: bookmarks; Type: TABLE; Schema: public; Owner: exambank
--

CREATE TABLE public.bookmarks (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    question_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.bookmarks OWNER TO exambank;

--
-- Name: exam_papers; Type: TABLE; Schema: public; Owner: exambank
--

CREATE TABLE public.exam_papers (
    id uuid NOT NULL,
    source_filename text NOT NULL,
    university_name text,
    exam_session text,
    exam_unit text,
    page_count integer NOT NULL,
    output_json_path text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    exam_type character varying(32) DEFAULT 'admission_test'::character varying NOT NULL,
    question_type character varying(16) DEFAULT 'mcq'::character varying NOT NULL,
    board_name text,
    exam_year character varying(8),
    subject character varying(64),
    subject_paper character varying(2),
    source_pdf_path text
);


ALTER TABLE public.exam_papers OWNER TO exambank;

--
-- Name: hsc_mcq_options; Type: TABLE; Schema: public; Owner: exambank
--

CREATE TABLE public.hsc_mcq_options (
    id uuid NOT NULL,
    question_id uuid NOT NULL,
    label character varying(16) NOT NULL,
    text text NOT NULL,
    display_order integer NOT NULL,
    image_filename text
);


ALTER TABLE public.hsc_mcq_options OWNER TO exambank;

--
-- Name: hsc_mcq_questions; Type: TABLE; Schema: public; Owner: exambank
--

CREATE TABLE public.hsc_mcq_questions (
    id uuid NOT NULL,
    paper_id uuid NOT NULL,
    question_number character varying(32) NOT NULL,
    question_text text NOT NULL,
    board_name text,
    exam_year character varying(8),
    subject character varying(64),
    subject_paper character varying(2),
    chapter character varying(128),
    correct_answer character varying(16),
    solution text,
    solution_status character varying(16) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    images jsonb,
    has_image boolean GENERATED ALWAYS AS ((question_text ~~ '%[IMAGE%'::text)) STORED NOT NULL,
    gemini_solution text,
    gemini_correct_answer character varying(16)
);


ALTER TABLE public.hsc_mcq_questions OWNER TO exambank;

--
-- Name: hsc_written_questions; Type: TABLE; Schema: public; Owner: exambank
--

CREATE TABLE public.hsc_written_questions (
    id uuid NOT NULL,
    paper_id uuid NOT NULL,
    question_number character varying(32) NOT NULL,
    board_name text,
    exam_year character varying(8),
    subject character varying(64),
    subject_paper character varying(2),
    uddipak_text text NOT NULL,
    uddipak_has_image boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    images jsonb
);


ALTER TABLE public.hsc_written_questions OWNER TO exambank;

--
-- Name: hsc_written_subparts; Type: TABLE; Schema: public; Owner: exambank
--

CREATE TABLE public.hsc_written_subparts (
    id uuid NOT NULL,
    question_id uuid NOT NULL,
    label character varying(1) NOT NULL,
    marks integer NOT NULL,
    text text NOT NULL,
    display_order integer NOT NULL,
    solution text,
    solution_status character varying(16) DEFAULT 'pending'::character varying NOT NULL,
    has_image boolean GENERATED ALWAYS AS ((text ~~ '%[IMAGE%'::text)) STORED NOT NULL
);


ALTER TABLE public.hsc_written_subparts OWNER TO exambank;

--
-- Name: quiz_status; Type: TABLE; Schema: public; Owner: exambank
--

CREATE TABLE public.quiz_status (
    subject character varying(64) NOT NULL,
    exam_type character varying(32) NOT NULL,
    status character varying(16) DEFAULT 'draft'::character varying NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_id uuid,
    CONSTRAINT ck_quiz_status_status CHECK (((status)::text = ANY ((ARRAY['draft'::character varying, 'published'::character varying, 'archived'::character varying])::text[])))
);


ALTER TABLE public.quiz_status OWNER TO exambank;

--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: exambank
--

CREATE TABLE public.refresh_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_hash text NOT NULL,
    issued_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone,
    replaced_by_id uuid,
    user_agent text,
    ip text
);


ALTER TABLE public.refresh_tokens OWNER TO exambank;

--
-- Name: users; Type: TABLE; Schema: public; Owner: exambank
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    display_name text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    is_admin boolean DEFAULT false NOT NULL
);


ALTER TABLE public.users OWNER TO exambank;

--
-- Data for Name: admission_mcq_options; Type: TABLE DATA; Schema: public; Owner: exambank
--

COPY public.admission_mcq_options (id, question_id, label, text, display_order, image_filename) FROM stdin;
d6b3b016-341f-4850-85a6-9f54dbd5856a	49ac5214-08aa-4093-9790-8e3402278800	A	শূন্যতম সূত্র	0	\N
648d56bc-af9d-4ea1-b44a-e2daf175d85d	49ac5214-08aa-4093-9790-8e3402278800	B	প্রথম সূত্র	1	\N
df8b2b03-9d6d-4dc5-b9c5-42d858b2bda3	49ac5214-08aa-4093-9790-8e3402278800	C	দ্বিতীয় সূত্র	2	\N
1f4d2431-ef89-4ef5-9243-1d8844543908	49ac5214-08aa-4093-9790-8e3402278800	D	তৃতীয় সূত্র	3	\N
c8453b71-1d07-4edb-97fb-02e88f043a45	dfa449d1-1841-483a-9d3c-fae10a197a8e	A	$5/4\\,\\text{A}$	0	\N
b366c0bf-3a6d-415e-95bf-4225f1b0cc62	dfa449d1-1841-483a-9d3c-fae10a197a8e	B	$5/8\\,\\text{A}$	1	\N
665f4c6b-c2ee-4251-b20f-b3cdd521d659	dfa449d1-1841-483a-9d3c-fae10a197a8e	C	$1\\,\\text{A}$	2	\N
e58b310d-5463-47bf-8c51-7e02f4026fee	dfa449d1-1841-483a-9d3c-fae10a197a8e	D	$4/5\\,\\text{A}$	3	\N
a53a7a4f-35e7-47c2-9d37-f3f5bccd5a57	2b101e61-141d-4d7f-b4c2-196138cf5fb2	A	অন্তস্থ শক্তির কোনো পরিবর্তন হয় না	0	\N
707dc551-f1fc-4a36-9a31-e35e4a0880f6	2b101e61-141d-4d7f-b4c2-196138cf5fb2	B	তাপমাত্রা হ্রাস পায়	1	\N
fbc3307b-d16d-4919-be61-6814a3d42448	2b101e61-141d-4d7f-b4c2-196138cf5fb2	C	চাপের কোনো পরিবর্তন হয় না	2	\N
b7a5b4c4-355f-47f9-9f8b-9fb4f6dbb994	2b101e61-141d-4d7f-b4c2-196138cf5fb2	D	দশার পরিবর্তন হয়।	3	\N
f7baf277-5433-46e9-8d27-559ac6612a4e	0e7b1d5f-a655-4b21-a3e9-37c113cfc52e	A	প্রতিসরণ	0	\N
7df2ab7c-53e4-4be9-94bd-940768a66f4e	0e7b1d5f-a655-4b21-a3e9-37c113cfc52e	B	অপবর্তন	1	\N
050b5b06-fa08-44f8-8baa-73aee41c2a0d	0e7b1d5f-a655-4b21-a3e9-37c113cfc52e	C	প্রতিফলন	2	\N
83530010-e691-4365-a086-cee8580d5037	0e7b1d5f-a655-4b21-a3e9-37c113cfc52e	D	ডপলার ক্রিয়া	3	\N
46419d7a-c777-485c-8219-42b43e9f5cc7	1cba308b-e030-438f-bf35-8632f38605e8	A	$3.3\\,\\text{kg}$	0	\N
6856301d-e772-44fd-9704-89e3d56416c3	1cba308b-e030-438f-bf35-8632f38605e8	B	$4.8\\,\\text{kg}$	1	\N
bf157011-7a72-48aa-9ac0-db0cb9aa5ce7	1cba308b-e030-438f-bf35-8632f38605e8	C	$21\\,\\text{kg}$	2	\N
3a763bcb-ba5f-41e4-93c5-06fd0f856ced	1cba308b-e030-438f-bf35-8632f38605e8	D	$30\\,\\text{kg}$	3	\N
a1b1e090-9218-4708-8e5a-61faa94e1170	aed35f2e-37e1-442a-b518-86d99c84bcea	A	$0.414\\,m_0c^2$	0	\N
d1c5d865-3fd1-4824-84a9-0fa75c630180	aed35f2e-37e1-442a-b518-86d99c84bcea	B	$0.25\\,m_0c^2$	1	\N
11adf197-9dfa-4b49-b175-238688d0360f	aed35f2e-37e1-442a-b518-86d99c84bcea	C	$1.414\\,m_0c^2$	2	\N
c5170b4b-caa0-4974-a31d-b6af789ca44c	aed35f2e-37e1-442a-b518-86d99c84bcea	D	$2.0\\,m_0c^2$	3	\N
ec05145c-1d02-4f93-b858-769d36a2cd95	603aab63-8553-47a4-a088-d2d1ce0ccd17	A	$0.05\\,\\text{ms}^{-1}$	0	\N
2eeae2cc-6943-4086-bafb-db65e0a3c907	603aab63-8553-47a4-a088-d2d1ce0ccd17	B	$0.125\\,\\text{ms}^{-1}$	1	\N
2e66e106-b43e-4e33-b43c-30e2df23bb45	603aab63-8553-47a4-a088-d2d1ce0ccd17	C	$0.157\\,\\text{ms}^{-1}$	2	\N
2a3db257-0d11-4189-b074-e0399307da7d	603aab63-8553-47a4-a088-d2d1ce0ccd17	D	$0.314\\,\\text{ms}^{-1}$	3	\N
c68b0f88-3205-468a-9055-a4e6a1000794	dc146fec-8cb1-4a88-9c45-440587c8f124	A	$1.8\\,\\text{ms}^{-2}$	0	\N
e04315b2-a4c9-49a3-a2f9-2751930bf070	dc146fec-8cb1-4a88-9c45-440587c8f124	B	$2.0\\,\\text{ms}^{-2}$	1	\N
bdc260d8-2f0e-4fd4-8852-ee160a769166	dc146fec-8cb1-4a88-9c45-440587c8f124	C	$6.0\\,\\text{ms}^{-2}$	2	\N
38fa579b-298e-40f4-8a27-01f235ccf42e	dc146fec-8cb1-4a88-9c45-440587c8f124	D	$8.0\\,\\text{ms}^{-2}$	3	\N
342c04c8-0045-4a4a-9914-0beb3f894f2c	d3ccca49-10b5-4f46-ac64-eb70abeb097a	A	$\\text{kg m}^2\\text{s}^{-1}$	0	\N
02e0493a-9988-4dae-946a-1c40cd4017c5	d3ccca49-10b5-4f46-ac64-eb70abeb097a	B	$\\text{kg m s}^{-2}$	1	\N
fba63105-d26f-46f1-9cd9-14dca700e989	d3ccca49-10b5-4f46-ac64-eb70abeb097a	C	$\\text{kg m s}^{-1}$	2	\N
862ce61c-dd4d-47cf-9599-5936855d005c	d3ccca49-10b5-4f46-ac64-eb70abeb097a	D	$\\text{kg m}^2\\text{s}^{-2}$	3	\N
7145cfe7-f317-4216-9a14-340eca00d30a	3ecc6897-3b48-4930-b659-d597c69c83bc	A	$(10110010)_2$	0	\N
f770ba73-9b22-4177-ab56-0f753a7f11b0	3ecc6897-3b48-4930-b659-d597c69c83bc	B	$(10100010)_2$	1	\N
2e2802a7-16b0-483b-9c1a-3283aaab8bfd	3ecc6897-3b48-4930-b659-d597c69c83bc	C	$(10100101)_2$	2	\N
67599cb8-ab97-4b09-a79f-d4206170b443	3ecc6897-3b48-4930-b659-d597c69c83bc	D	$(10100011)_2$	3	\N
8f808fa3-7d9f-46b3-b09d-7f268ca2f002	f6992e14-6260-4199-8666-6e9366738d82	A	(বেগ)$^2$	0	\N
ee2b0e4e-3359-4fb3-8787-536ad5b9ac58	f6992e14-6260-4199-8666-6e9366738d82	B	(রোধ)$^2$	1	\N
9898d836-35f5-4ab6-806c-ba78f34079fd	f6992e14-6260-4199-8666-6e9366738d82	C	চৌম্বক ক্ষেত্র	2	\N
829a26ec-0bf6-4020-a9cf-d64d9e38e3cc	f6992e14-6260-4199-8666-6e9366738d82	D	বৈদ্যুতিক বিভব	3	\N
542ce161-aaa2-4762-a0f5-cb044e6f31c2	8348307d-6f89-4ee2-bcee-97ba4e2a32f8	A	$12$	0	\N
aeb102f8-5858-492d-9c86-b83e263cbd0b	8348307d-6f89-4ee2-bcee-97ba4e2a32f8	B	$60$	1	\N
d95f4350-80f1-41c8-8eda-33d8913f2c14	8348307d-6f89-4ee2-bcee-97ba4e2a32f8	C	$25$	2	\N
2bfac51d-bb01-4612-a30d-f00bdbfcf841	8348307d-6f89-4ee2-bcee-97ba4e2a32f8	D	$15$	3	\N
93de0f49-6082-4de4-b97b-31cbdf172a73	fa4ff435-2391-4047-b44c-f685d53e9f55	A	$0^\\circ$	0	\N
f980f57d-5c86-4163-af48-7f563398945c	fa4ff435-2391-4047-b44c-f685d53e9f55	B	$90^\\circ$	1	\N
90e4555d-0738-4b3e-8fcd-d85cbffcdea7	fa4ff435-2391-4047-b44c-f685d53e9f55	C	$120^\\circ$	2	\N
dd118ea2-2bca-42f7-9a93-92f37f3fa722	fa4ff435-2391-4047-b44c-f685d53e9f55	D	$180^\\circ$	3	\N
914a6760-c4c6-4f42-9c24-d1c1e06e2aba	1f2aa538-6e73-48e9-92b0-91ab71dd76aa	A	অ্যালুমিনিয়াম বাইরের দিকে বর্ধিত হয় ও ছিদ্র একই আকারের থাকে।	0	\N
1f1f8f81-167a-4da6-a9ab-e737afdf6dce	1f2aa538-6e73-48e9-92b0-91ab71dd76aa	B	ছিদ্রের ব্যাস কমে যায়।	1	\N
5fb8497f-8c8f-443a-81f9-7491eb67379c	1f2aa538-6e73-48e9-92b0-91ab71dd76aa	C	ছিদ্রের ক্ষেত্রফল অ্যালুমিনিয়ামের যে কোনো অংশের ক্ষেত্রফলের সমান অনুপাতে বৃদ্ধি পায়।	2	\N
6ad05022-77d9-4b39-8207-16958d1ad5ea	1f2aa538-6e73-48e9-92b0-91ab71dd76aa	D	ছিদ্রের ক্ষেত্রফল অ্যালুমিনিয়ামের যে কোনো অংশের ক্ষেত্রফলের চেয়ে বেশি অনুপাতে বৃদ্ধি পায়।	3	\N
8a374745-a1a4-4a11-9698-0806adb7d2fe	1e77e791-b572-49c5-96d7-14115d517329	A	শূন্য (zero)	0	\N
10fd5d91-979b-4722-b1bd-e9699639c8d1	1e77e791-b572-49c5-96d7-14115d517329	B	$2\\pi m + \\pi/4$	1	\N
dbb961fd-2c17-4067-9498-518300497e09	1e77e791-b572-49c5-96d7-14115d517329	C	$2\\pi m + \\pi/2$	2	\N
4d1a4e48-d1ee-462f-9a91-c5532a7ad07d	1e77e791-b572-49c5-96d7-14115d517329	D	$2\\pi m + \\pi$	3	\N
6be7e39e-7e90-40be-850f-b172e0395953	a772c84b-1fe5-43b3-8631-af02fd8450a1	A	তরঙ্গের কৌণিক কম্পাঙ্ক, $\\omega$	0	\N
f84a35c4-1c51-4100-a873-1b3edd0d2687	a772c84b-1fe5-43b3-8631-af02fd8450a1	B	শূন্য মাধ্যমে তরঙ্গদৈর্ঘ্য, $\\lambda$	1	\N
f6f6f553-9b7a-4eea-9fc5-40da4ca9d176	a772c84b-1fe5-43b3-8631-af02fd8450a1	C	শূন্য মাধ্যমে আলোর বেগ, $c_0$	2	\N
3e638cea-4e83-499b-a769-d09b84d9e617	a772c84b-1fe5-43b3-8631-af02fd8450a1	D	প্লাঙ্কের ধ্রুবক, $h$	3	\N
31b25f51-3d47-429c-91a8-4b6d94f42000	c7cb926c-cb05-4342-86c3-3c23a8749ebf	A	[IMAGE_1]	0	\N
7d2fc479-a8ec-4317-8615-0cea2504d6bf	c7cb926c-cb05-4342-86c3-3c23a8749ebf	B	[IMAGE_2]	1	\N
203a97e8-e3a5-414e-994a-e7da99d4cfc1	c7cb926c-cb05-4342-86c3-3c23a8749ebf	C	[IMAGE_3]	2	\N
52e68675-9e2b-4100-8b95-04cc482969ec	c7cb926c-cb05-4342-86c3-3c23a8749ebf	D	[IMAGE_4]	3	\N
151b3e50-6868-43ec-8a35-3cbff30d7e3b	78416331-8465-4bc7-8067-af60abc59577	A	$v_3 > v_1 > v_2$	0	\N
14fe2632-d6a7-43f7-bd8e-5cb3c8411690	78416331-8465-4bc7-8067-af60abc59577	B	$v_3 > v_2 > v_1$	1	\N
97c605fa-518f-494a-a4fe-146e60269829	78416331-8465-4bc7-8067-af60abc59577	C	$v_1 > v_2 > v_3$	2	\N
41c045a7-9fdb-4ddd-944c-4d0033a42d26	78416331-8465-4bc7-8067-af60abc59577	D	$v_1 > v_3 > v_2$	3	\N
cc64db5b-c7dd-4f55-8bda-7420311867bb	b1f34359-813c-454a-87d2-8be081eec7d0	A	$2Mf^2/L$	0	\N
e8d5e8b3-7588-4806-a0b6-4a1dad08d392	b1f34359-813c-454a-87d2-8be081eec7d0	B	$4MLf^2$	1	\N
4c6be658-f22b-4619-8afc-9f81fbadd6c1	b1f34359-813c-454a-87d2-8be081eec7d0	C	$4f^2L^3/M$	2	\N
b3d749cb-996e-4299-93bf-eb31fd1373f7	b1f34359-813c-454a-87d2-8be081eec7d0	D	$4fm/L$	3	\N
6bb2d75c-75ee-4b0a-b1c3-cd2001107012	59bfd3d6-e1bf-4233-8def-1f648b4c045e	A	$6, 3$	0	\N
b199d2c3-f757-4f6b-9434-a014fd0a02d6	59bfd3d6-e1bf-4233-8def-1f648b4c045e	B	$7, 2$	1	\N
251fbcdd-2c9f-4ba3-a0fc-a8182dbc8872	59bfd3d6-e1bf-4233-8def-1f648b4c045e	C	$7, 3$	2	\N
3ae0a4a5-4a21-4a63-8f3e-5043cc3b0250	59bfd3d6-e1bf-4233-8def-1f648b4c045e	D	$8, 4$	3	\N
eea14b32-5bda-4056-b39a-8d6ad90a2128	3bba5900-28d6-4761-ad6f-cfa430e73ebe	A	$70.7\\,\\text{A}$	0	\N
2cf003ba-0bfe-440f-87d2-b74e8cf65263	3bba5900-28d6-4761-ad6f-cfa430e73ebe	B	$100\\,\\text{A}$	1	\N
6cc6d8cb-0a64-46e3-bd12-e7234804e4d9	3bba5900-28d6-4761-ad6f-cfa430e73ebe	C	$50\\,\\text{A}$	2	\N
954a4987-4d68-4247-8a80-6bc741c2c09b	3bba5900-28d6-4761-ad6f-cfa430e73ebe	D	$200\\,\\text{A}$	3	\N
3cdd7469-f966-4da7-b4ae-bfc1e20e6234	e1d1e7b0-bd77-4a21-95bc-ed3972271996	A	$v_s/2$	0	\N
31d1ebc3-7a10-405a-9a1b-5132edd6b5e9	e1d1e7b0-bd77-4a21-95bc-ed3972271996	B	$\\sqrt{3}v_s/2$	1	\N
76925773-aaac-4cdf-ad16-1dbae9446700	e1d1e7b0-bd77-4a21-95bc-ed3972271996	C	$2v_s$	2	\N
f30c5987-3670-4b42-839e-c6348027bcf1	e1d1e7b0-bd77-4a21-95bc-ed3972271996	D	$3v_s/4$	3	\N
8e63d554-624b-49df-ac38-48a75f8b0d94	ca52fa50-abaa-4fd0-bb0d-ae75039e1cbb	A	$\\mu_0 ev/(4\\pi r^2)$	0	\N
d225cb90-8301-483d-ae96-b5e79ef8f1d8	ca52fa50-abaa-4fd0-bb0d-ae75039e1cbb	B	$\\mu_0 ev/(2\\pi r)$	1	\N
e34fcd0e-e6ec-4890-81d2-fd00c8c50e4a	ca52fa50-abaa-4fd0-bb0d-ae75039e1cbb	C	$\\mu_0 ev/(\\pi r^2)$	2	\N
2b305b36-afa8-4fca-bc01-2d128eb01ce2	ca52fa50-abaa-4fd0-bb0d-ae75039e1cbb	D	$\\mu_0 e/(4\\pi vr)$	3	\N
b979d1bc-7cb6-445d-a592-c0fc0d9d614e	eab51de4-7348-4b0e-9609-064e88015dea	A	$1.8\\text{ km}, 0.15\\text{ km}$	0	\N
b23f8674-e178-44fe-a59f-0d226134e396	eab51de4-7348-4b0e-9609-064e88015dea	B	$2.2\\text{ km}, 0.20\\text{ km}$	1	\N
ebd781d6-f909-4681-bc5a-7b3c65057fbe	eab51de4-7348-4b0e-9609-064e88015dea	C	$2.8\\text{ km}, 0.25\\text{ km}$	2	\N
877e1a3f-f049-4c1d-af44-98c887212d1d	eab51de4-7348-4b0e-9609-064e88015dea	D	$3.3\\text{ km}, 0.30\\text{ km}$	3	\N
6c09e560-591e-4cba-b1d0-1c7949b11000	ae44507d-e359-4e47-b783-a5b9ca68f0eb	A	$-2cx$	0	\N
a6d9f882-1d16-41c1-9e4b-d41659d59fc8	ae44507d-e359-4e47-b783-a5b9ca68f0eb	B	$2cx$	1	\N
9e9060dd-f4ab-4ed4-863c-b984a6078505	ae44507d-e359-4e47-b783-a5b9ca68f0eb	C	$-cx^3/3$	2	\N
ae1682c3-2ae6-4276-9716-2156ea00ce7d	ae44507d-e359-4e47-b783-a5b9ca68f0eb	D	$cx^3/3$	3	\N
657324b0-77aa-467c-b1d6-497653e3e4c6	854a05d3-849b-4dd9-a522-4b7c9d192a45	A	[IMAGE_1]	0	p03_q26_01.png
17a175ea-3718-4ec6-bd82-65ec78a17387	854a05d3-849b-4dd9-a522-4b7c9d192a45	B	[IMAGE_2]	1	p03_q26_02.png
c6c381ee-3fb5-4646-abbf-0709e26dcae9	854a05d3-849b-4dd9-a522-4b7c9d192a45	C	[IMAGE_3]	2	p03_q26_03.png
b6089c1e-7579-4cb1-930c-97e05b3c63ca	854a05d3-849b-4dd9-a522-4b7c9d192a45	D	[IMAGE_4]	3	p03_q26_04.png
7b3a535e-0f72-44db-b519-14d71d0c9d97	f69b2d12-2038-41a9-b416-d3c480736f5b	A	$-1.5\\text{ eV}$	0	\N
3a44a215-1a43-4e65-925b-79e8a5b4f01d	f69b2d12-2038-41a9-b416-d3c480736f5b	B	$-3.4\\text{ eV}$	1	\N
cc216549-6109-4cee-9345-697a4bf3342f	f69b2d12-2038-41a9-b416-d3c480736f5b	C	$-4.5\\text{ eV}$	2	\N
0714b62e-0ce3-4ca7-8867-f95d99494f13	f69b2d12-2038-41a9-b416-d3c480736f5b	D	$-40.8\\text{ eV}$	3	\N
ad3d8898-f388-46e2-8bff-50d95a127373	28c07dfe-cb42-44d4-9f2f-dda64ffb6882	A	বেগ-সময় লেখচিত্রের ঢাল থেকে।	0	\N
5dffdbef-3cd0-49a6-b491-a27eb42453a5	28c07dfe-cb42-44d4-9f2f-dda64ffb6882	B	ত্বরণ-সময় লেখচিত্রের ঢাল থেকে।	1	\N
8a5b29b8-59c9-41bb-a016-5fffdef98bbc	28c07dfe-cb42-44d4-9f2f-dda64ffb6882	C	বেগ-সময় লেখচিত্রের নিচের ক্ষেত্রফল থেকে।	2	\N
6773abb8-6980-4665-ada4-f85284236be2	28c07dfe-cb42-44d4-9f2f-dda64ffb6882	D	ত্বরণ-সময় লেখচিত্রের নিচের ক্ষেত্রফল থেকে।	3	\N
72cb359c-2a60-49e8-9c48-dc3014df6936	cc8ba2b6-5eb6-4c30-a00d-d2a89b0ce831	A	$2F/3$	0	\N
671994ad-908d-4036-bdf6-5565428d919c	cc8ba2b6-5eb6-4c30-a00d-d2a89b0ce831	B	$4F/3$	1	\N
5b2b9c94-9d57-47c9-a4e4-6bcf8e06487f	cc8ba2b6-5eb6-4c30-a00d-d2a89b0ce831	C	$2F/9$	2	\N
cabcc322-22ad-42c8-ae24-db78f4f5005f	cc8ba2b6-5eb6-4c30-a00d-d2a89b0ce831	D	$4F/9$	3	\N
98111222-0617-475b-b88a-35e131198242	9eb2d84f-c683-46fd-b93a-def8d294ca2b	A	শক্তির সংরক্ষণ নীতি	0	\N
7775f957-026d-442e-8b4e-ef68854aff93	9eb2d84f-c683-46fd-b93a-def8d294ca2b	B	ভরবেগের সংরক্ষণ নীতি	1	\N
f66b22df-5cfb-4719-ab84-fec9f0eedb53	9eb2d84f-c683-46fd-b93a-def8d294ca2b	C	কৌণিক-ভরবেগের সংরক্ষণ নীতি	2	\N
9ff13df3-64c1-45cc-ae89-5b9f80c73842	9eb2d84f-c683-46fd-b93a-def8d294ca2b	D	ভরের সংরক্ষণ নীতি	3	\N
e69fbabf-548e-4479-b3b1-c6fa9a7f4ec0	895509f8-b03b-428b-9204-b769960ab6bb	A	$-830\\text{ kJ mol}^{-1}$	0	\N
3b7d00a1-d8b9-45fe-9625-f1a932764acc	895509f8-b03b-428b-9204-b769960ab6bb	B	$-720\\text{ kJ mol}^{-1}$	1	\N
15f6b5d8-f9fe-4a8f-895f-36de92785fee	895509f8-b03b-428b-9204-b769960ab6bb	C	$+720\\text{ kJ mol}^{-1}$	2	\N
8b51d48d-3817-44a8-85b7-e8e4a4bb193c	895509f8-b03b-428b-9204-b769960ab6bb	D	$+830\\text{ kJ mol}^{-1}$	3	\N
11c57597-31d2-43f8-97e8-20eedfada7d1	70d67fa4-ff2f-4dce-8d8d-a05722edbb25	A	$2s^2$	0	\N
101e1272-2f66-44a5-89a0-bcf4fa5b896e	70d67fa4-ff2f-4dce-8d8d-a05722edbb25	B	$2s^2 2p^1$	1	\N
74b30aa1-e0d2-4f69-9ad6-0b533cf694a8	70d67fa4-ff2f-4dce-8d8d-a05722edbb25	C	$2s^2 2p^4$	2	\N
cf4d1d23-0481-469c-a4b7-676ad41ead57	70d67fa4-ff2f-4dce-8d8d-a05722edbb25	D	$2s^2 2p^6$	3	\N
ccfa7171-0821-41f4-8b51-dc0969112f78	ce2fc38e-54aa-47ce-937d-57af1aed1ee7	A	increase in $\\ce{[Zn^{2+}]}$	0	\N
20d76bda-5144-4be6-8634-015fcfa091c7	ce2fc38e-54aa-47ce-937d-57af1aed1ee7	B	increase in $\\ce{[Cu^{2+}]}$	1	\N
bb6410e3-24a0-4cd4-adab-7579dbd2d85e	ce2fc38e-54aa-47ce-937d-57af1aed1ee7	C	increase in $\\ce{[Zn^{2+}]}$ and $\\ce{[Cu^{2+}]}$ equally	2	\N
c905fe11-400a-4721-ae6b-4ebfd273f7e4	ce2fc38e-54aa-47ce-937d-57af1aed1ee7	D	increase in $\\ce{[Zn^{2+}]}$ and decrease in $\\ce{[Cu^{2+}]}$	3	\N
4e8f914c-7eb2-42c8-9615-1fdfbf5ffb2c	929116a7-ddf4-40a5-a2bd-420368fee05c	A	$\\ce{CO(g) + 1/2 O2(g) -> CO2(g)}$	0	\N
162cbc64-6a8c-41ff-a0bc-03ebd29a971b	929116a7-ddf4-40a5-a2bd-420368fee05c	B	$\\ce{H2(g) + 1/2 O2(g) -> H2O(g)}$	1	\N
f6392403-ca8f-455c-861b-4b23e2227ea9	929116a7-ddf4-40a5-a2bd-420368fee05c	C	$\\ce{NO(g) + 1/2 O2(g) -> NO2(g)}$	2	\N
8bfb1609-2661-4340-acd1-b0488af80e6b	929116a7-ddf4-40a5-a2bd-420368fee05c	D	$\\ce{K(s) + Mn(s) + 2O2(g) -> KMnO4(s)}$	3	\N
5449eb15-6a6d-49e4-be6b-fe04584244da	625f1e10-b3af-4e25-9a59-3d91c728f490	A	$\\ce{^{9}_{4}Be}$	0	\N
30a7b06e-feb7-456d-81d7-94ab6adc6113	625f1e10-b3af-4e25-9a59-3d91c728f490	B	$\\ce{^{19}_{9}F}$	1	\N
622de9d1-07b1-4ec3-bdec-1c3ff3c87d6e	625f1e10-b3af-4e25-9a59-3d91c728f490	C	$\\ce{^{23}_{11}Na^{+}}$	2	\N
4c431765-b931-4563-a330-5594300f19e5	625f1e10-b3af-4e25-9a59-3d91c728f490	D	$\\ce{^{18}_{8}O^{2-}}$	3	\N
d1eb12df-7260-442b-acea-8ab078116c57	82853947-6870-412d-ac9b-8df48e33c00d	A	NaF	0	\N
1f95157e-43b3-4fc1-8097-a702f1862215	82853947-6870-412d-ac9b-8df48e33c00d	B	NaCl	1	\N
0f3a41cc-df84-41b3-89a5-18d8b98bcc0a	82853947-6870-412d-ac9b-8df48e33c00d	C	NaBr	2	\N
d3fa0f0a-8313-4146-a2bb-f35cb0ba2d09	82853947-6870-412d-ac9b-8df48e33c00d	D	NaI	3	\N
84df20da-31a8-4f79-9861-da55dcbd3821	53856c05-7c1d-490d-9842-1cbd1379dac8	A	nitrogen and oxygen	0	\N
0b152e37-d356-4488-aa5b-ab40b9633bc4	53856c05-7c1d-490d-9842-1cbd1379dac8	B	oxygen and nitrogen	1	\N
f8ae03e0-ab4d-4e90-81f6-4871de8c695f	53856c05-7c1d-490d-9842-1cbd1379dac8	C	potassium and oxygen	2	\N
a2371371-1216-4d61-8123-6f1634dd82d0	53856c05-7c1d-490d-9842-1cbd1379dac8	D	nitrogen and potassium	3	\N
1b62f14a-2668-42f8-8ae9-ced57105e9be	b0ec239f-dc9a-4f83-aba6-53e6f14d01d2	A	6, 2	0	\N
d0c3b812-6b75-47a4-b204-f060991b60ee	b0ec239f-dc9a-4f83-aba6-53e6f14d01d2	B	6, 1	1	\N
86d7b8e7-baad-470b-9fda-2bde79aea623	b0ec239f-dc9a-4f83-aba6-53e6f14d01d2	C	8, 0	2	\N
81ac9055-5152-4f17-a85e-5611d99173bc	b0ec239f-dc9a-4f83-aba6-53e6f14d01d2	D	7, 0	3	\N
6269c302-76c6-4d84-bb68-7639363c0886	84546171-00b6-447b-b7dc-488380953491	A	$\\ce{Cr^{3+}}$	0	\N
62e909b9-ca0e-4e26-a581-45e68e016385	84546171-00b6-447b-b7dc-488380953491	B	$\\ce{Mn^{3+}}$	1	\N
8f3110d9-7c87-4c29-aea9-64c5c0efd9c4	84546171-00b6-447b-b7dc-488380953491	C	$\\ce{Fe^{3+}}$	2	\N
49762bf1-daf7-4686-a72d-2c2315aa43c9	84546171-00b6-447b-b7dc-488380953491	D	$\\ce{Sc^{3+}}$	3	\N
8eb1bd04-a017-4d1a-a993-35ba7e031089	6fb6f30d-7d6c-4c7e-a2d5-5cc6e78aeb86	A	$\\ce{Mg^{2+} < Na^{+} < Ne}$	0	\N
3c890b5c-72aa-44b7-87f3-56243673c153	6fb6f30d-7d6c-4c7e-a2d5-5cc6e78aeb86	B	$\\ce{Mg^{2+} < Ne < Na}$	1	\N
30b587aa-a721-481d-beb5-b0698a5e2a97	6fb6f30d-7d6c-4c7e-a2d5-5cc6e78aeb86	C	$\\ce{Na^{+} < Mg^{2+} < Ne}$	2	\N
ddbdbbcc-4dbd-4a87-9b7e-3a0b439e8550	6fb6f30d-7d6c-4c7e-a2d5-5cc6e78aeb86	D	$\\ce{Mg^{2+} > Na^{+} > Ne}$	3	\N
367794dc-e40f-449d-bf43-8b8b1432b723	db1f1d93-1124-496f-95b9-39b58ac51593	A	অম্লীয় $\\ce{K2Cr2O7}$ দ্রবণ	0	\N
3e49bdba-55d2-4729-ad57-469c70342673	db1f1d93-1124-496f-95b9-39b58ac51593	B	লঘু $\\ce{H2SO4}$	1	\N
b5cfa9fb-5354-4e1e-a568-f3f99e12ba49	db1f1d93-1124-496f-95b9-39b58ac51593	C	২, ৪- ডাইনাইট্রোফিনাইলহাইড্রাজিন	2	\N
e7eeb8a2-d44e-4ea1-9755-2d534fbbb690	db1f1d93-1124-496f-95b9-39b58ac51593	D	ফেহলিং এর দ্রবণ	3	\N
8fac07a9-8837-4d03-a7e3-8e2ae8eb50a4	a5a5df8b-0438-4c5e-84ee-97e93fe94eee	A	$\\ce{N2}$	0	\N
4d4598a8-0654-46c5-95de-48e8c7d60234	a5a5df8b-0438-4c5e-84ee-97e93fe94eee	B	$\\ce{H2}$	1	\N
9f4a0cfc-814a-4125-80c6-fd67b097e490	a5a5df8b-0438-4c5e-84ee-97e93fe94eee	C	$\\ce{O2}$	2	\N
e8cc4b78-dc48-4a5b-a9fa-c6b9ea74e473	a5a5df8b-0438-4c5e-84ee-97e93fe94eee	D	Ar	3	\N
23ee0c6d-28f7-4500-9c4b-3db85db68ce5	729c646b-8532-4fd3-9772-6e99cc0c94ec	A	$\\ce{C2H4}$	0	\N
e8b2d4e0-e53b-4c9d-9ee6-6c79d7b0f66f	729c646b-8532-4fd3-9772-6e99cc0c94ec	B	$\\ce{C2H5Br}$	1	\N
131c7ab8-5f20-4bc9-9a72-ff98e0db63b3	729c646b-8532-4fd3-9772-6e99cc0c94ec	C	$\\ce{CH3CHO}$	2	\N
6002d3f3-e57b-4746-b77b-4993ebe1e612	729c646b-8532-4fd3-9772-6e99cc0c94ec	D	$\\ce{C2H6}$	3	\N
d9da6f30-ee80-42ea-9ad6-7e4266071b09	ee2d55e5-ce12-45d5-94cc-60fa5b0d86c8	A	$\\ce{C2H5OH}$	0	\N
7a0ebc87-f8de-42ca-954e-2a118f6fbf17	ee2d55e5-ce12-45d5-94cc-60fa5b0d86c8	B	$\\ce{C6H5OH}$	1	\N
f735bce1-1d60-493c-bcce-f2250d334580	ee2d55e5-ce12-45d5-94cc-60fa5b0d86c8	C	$\\ce{C6H5COOH}$	2	\N
1186c049-20b3-41d3-ae5b-e0e865fc89ae	ee2d55e5-ce12-45d5-94cc-60fa5b0d86c8	D	$\\ce{C2H5COOH}$	3	\N
e37b5dd3-8dd1-4ab2-b277-2bef80268d20	0736b02b-9661-4de6-b0c0-548a25e0bbff	A	1.0	0	\N
73c78eda-5e83-40fc-a144-5869eabd79ab	0736b02b-9661-4de6-b0c0-548a25e0bbff	B	2.0	1	\N
bdd3c800-da40-4bcc-a453-1f48294c15e3	0736b02b-9661-4de6-b0c0-548a25e0bbff	C	13.0	2	\N
8798adec-0071-44bb-83d2-bf6ce45a9d01	0736b02b-9661-4de6-b0c0-548a25e0bbff	D	12.0	3	\N
7e23a67a-92a4-4939-a745-8ff8abccda1c	c0b04562-271b-4a8e-9233-492b18ab18fe	A	$0.05$	0	\N
2c225fb8-cf70-4e24-8136-efc7bb7584a9	c0b04562-271b-4a8e-9233-492b18ab18fe	B	$0.15$	1	\N
f8fcf679-0fae-4ac5-a457-f72a38a5bd53	c0b04562-271b-4a8e-9233-492b18ab18fe	C	$0.25$	2	\N
89de74e5-c554-4ef3-979a-38a3af2df64a	c0b04562-271b-4a8e-9233-492b18ab18fe	D	$0.50$	3	\N
7a91e340-cf72-4e6d-996b-98603b0f5c26	14e4de09-de4d-4164-97c0-6bab31ffc5eb	A	তাপমাত্রা	0	\N
ef74ab53-3bb1-458f-b3fa-ae6c322fd4ae	14e4de09-de4d-4164-97c0-6bab31ffc5eb	B	বিক্রিয়ার অর্ধায়ু	1	\N
b0deb8e1-dfb4-4ead-9cda-b18015280dba	14e4de09-de4d-4164-97c0-6bab31ffc5eb	C	প্রভাবক	2	\N
5e1b9372-fb64-4df7-8f82-dab2a77c0c79	14e4de09-de4d-4164-97c0-6bab31ffc5eb	D	বিক্রিয়কের ঘনমাত্রা	3	\N
69326cdb-7e49-4e9a-bdb7-a6bea66bb5fe	d8fcce4d-8374-4016-9f7d-0191b5610c9e	A	$\\ce{CH3CH2COOH}$	0	\N
b213a3c7-17e3-4a10-a9f4-7a87d142e810	d8fcce4d-8374-4016-9f7d-0191b5610c9e	B	$\\ce{ClCH2CH2COOH}$	1	\N
239a92c4-4c0c-4304-824c-138d763e619c	d8fcce4d-8374-4016-9f7d-0191b5610c9e	C	$\\ce{Cl2CHCOOH}$	2	\N
5fc0a355-b7cb-4c6e-8875-06d56ce37300	d8fcce4d-8374-4016-9f7d-0191b5610c9e	D	$\\ce{CH3COOH}$	3	\N
7eaa5d78-5934-4867-bc3b-bdc8f4a16842	3128d748-503d-4d0a-9ac6-df5f7a81e93f	A	$100\\,\\text{mL}$	0	\N
a8b70c68-a13a-4ffc-bd5a-6c3634757ac4	3128d748-503d-4d0a-9ac6-df5f7a81e93f	B	$150\\,\\text{mL}$	1	\N
ff5acd19-f866-4bc9-b097-4c540bf5ffb2	3128d748-503d-4d0a-9ac6-df5f7a81e93f	C	$125\\,\\text{mL}$	2	\N
9d05b6cf-8102-45fe-87e2-91068e71712f	3128d748-503d-4d0a-9ac6-df5f7a81e93f	D	$75\\,\\text{mL}$	3	\N
59091716-5ff7-49c7-b942-282e99673e5a	1a2812c3-4af9-4e94-bf3e-6b81307d291a	A	$\\ce{HNO3, H2SO4}$	0	\N
13a13784-4915-437e-a6af-b7579abf6eef	1a2812c3-4af9-4e94-bf3e-6b81307d291a	B	$\\ce{H2SO4}, 30^{\\circ}-100^{\\circ}\\text{C}$	1	\N
43d03587-bf15-4094-9f0b-a7911856b890	1a2812c3-4af9-4e94-bf3e-6b81307d291a	C	Dilute $\\ce{HNO3}$	2	\N
349c80d1-5318-4beb-806c-bad6cde2d917	1a2812c3-4af9-4e94-bf3e-6b81307d291a	D	Concentrated $\\ce{HNO3}$	3	\N
a23755b4-2bec-404e-b00a-6632261b93a1	3e425357-2da0-435c-a491-0c029de6471a	A	$1.10\\,\\text{g}$ of hydrogen atoms	0	\N
be079afb-3fe7-4957-b506-cab3369a5141	3e425357-2da0-435c-a491-0c029de6471a	B	$14.7\\,\\text{g}$ of chromium atoms	1	\N
b4785f68-365d-44ce-84a8-563963e330a2	3e425357-2da0-435c-a491-0c029de6471a	C	$2.0\\,\\text{g}$ of helium atoms	2	\N
27b3ebfe-040c-4fc9-b225-4f9e8cd54f39	3e425357-2da0-435c-a491-0c029de6471a	D	$7.0\\,\\text{g}$ of nitrogen atoms	3	\N
94ea5453-2eb2-4067-a45f-3e9dc7ad864b	6992614e-d77c-4d24-8695-f4699ab8a47f	A	$\\ce{CO}$	0	\N
dbd6eff5-9d4d-4ef0-ac08-5f81a29c1a80	6992614e-d77c-4d24-8695-f4699ab8a47f	B	$\\ce{NO_x}$	1	\N
21607fa4-08b0-4b62-b97e-475ed5aeca3e	6992614e-d77c-4d24-8695-f4699ab8a47f	C	$\\ce{CH4}$	2	\N
8f99280c-db89-497d-a32e-fa9cc0991210	6992614e-d77c-4d24-8695-f4699ab8a47f	D	$\\ce{CO2}$	3	\N
2f23a898-c29b-4018-a1d7-62086449dd7d	55805a43-a27d-4c26-8439-de828ba47cb0	A	$\\ce{CH4}$	0	\N
ce5901e4-d429-4f05-9afe-cb4f0211f45a	55805a43-a27d-4c26-8439-de828ba47cb0	B	$\\ce{NH3}$	1	\N
0fd23a4a-7701-488e-b216-c601f7e20a5f	55805a43-a27d-4c26-8439-de828ba47cb0	C	$\\ce{PH3}$	2	\N
917b42a4-a628-4e18-89a9-d01faf085f68	55805a43-a27d-4c26-8439-de828ba47cb0	D	$\\ce{H2S}$	3	\N
150bdc8d-7db8-4cf0-90ce-b197c2964fb7	f3f44de8-3551-49a1-9366-ec0bedf8c9b5	A	$0.0987\\,\\text{g}$	0	\N
6a545cc9-895f-4dc7-a532-84337587a18b	f3f44de8-3551-49a1-9366-ec0bedf8c9b5	B	$0.0897\\,\\text{g}$	1	\N
93c5b4f7-7719-49b3-93be-06dcd04fcc2e	f3f44de8-3551-49a1-9366-ec0bedf8c9b5	C	$0.0798\\,\\text{g}$	2	\N
2a1dd282-8360-43fc-9cfb-b0de72cb9aa0	f3f44de8-3551-49a1-9366-ec0bedf8c9b5	D	$0.0789\\,\\text{g}$	3	\N
7ea5294a-3d1d-404e-83e2-c80fa396dd8f	34ad18c2-3e65-4c20-8121-c67cf5764f6f	A	2	0	\N
dd6e2730-4b12-41a5-84d0-264e97b3e9ad	34ad18c2-3e65-4c20-8121-c67cf5764f6f	B	3	1	\N
1017e31e-c21f-4030-922e-c20f12fb3063	34ad18c2-3e65-4c20-8121-c67cf5764f6f	C	4	2	\N
61bd84f9-1a4c-4677-b1c8-639e7d7c0d30	34ad18c2-3e65-4c20-8121-c67cf5764f6f	D	5	3	\N
eeeb9f92-6e6a-4449-b35a-821efa8f72a8	9db9d914-e93f-4de3-b6bf-30b1158f5173	A	$\\ce{K2SO4, Fe2(SO4)3, H2O}$	0	\N
a5c4af14-d9ef-422d-8e9a-a76909bb9159	9db9d914-e93f-4de3-b6bf-30b1158f5173	B	$\\ce{K2SO4, Cr2(SO4)3, H2O}$	1	\N
804423e8-b852-4a75-b163-20b4b0c3afbc	9db9d914-e93f-4de3-b6bf-30b1158f5173	C	$\\ce{Cr2(SO4)3, Fe2(SO4)3, H2O}$	2	\N
ee9ccd5e-520f-47b6-a6af-f28ce1194286	9db9d914-e93f-4de3-b6bf-30b1158f5173	D	$\\ce{K2SO4, Cr2(SO4)3, Fe2(SO4)3, H2O}$	3	\N
5b9d6c34-ba67-4db6-b129-1b48441a0480	ca252eac-40d5-4fe9-aad5-cef587161e6c	A	$\\ce{CH3(CH2)2CH=CH CO2H}$	0	\N
3f57d02a-b3d0-4d67-8f7e-aad375504229	ca252eac-40d5-4fe9-aad5-cef587161e6c	B	$\\ce{CH3(CH2)4CH2COCH2CH3}$	1	\N
a948ca54-8fc7-402d-a9f5-569e7f07412f	ca252eac-40d5-4fe9-aad5-cef587161e6c	C	$\\ce{CH3(CH2)4CO2CH2CH3}$	2	\N
19c68861-12d5-452c-9e7f-4196fad0e4bb	ca252eac-40d5-4fe9-aad5-cef587161e6c	D	$\\ce{CH3CH2CO2(CH2)4CH3}$	3	\N
2d2ad7ae-e021-4061-9faa-4502ccda16b3	333ebc97-aa2c-4c66-ae65-d81c97d2bfc8	A	$X=\\ce{NH3}, Y=\\ce{HCl(aq)}$	0	\N
98673bcc-d647-4309-ba31-570953de64bb	333ebc97-aa2c-4c66-ae65-d81c97d2bfc8	B	$X=\\ce{KCN}$ in $\\ce{C2H5OH}, Y=\\ce{NaOH(aq)}$	1	\N
89281722-7c9a-4ed6-ae65-cc70151816cb	333ebc97-aa2c-4c66-ae65-d81c97d2bfc8	C	$X=\\ce{KCN}$ in $\\ce{C2H5OH}, Y=\\ce{HCl(aq)}$	2	\N
26c2770e-b386-4312-9d9e-e2c6c881c287	333ebc97-aa2c-4c66-ae65-d81c97d2bfc8	D	$X=\\ce{HCN}, Y=\\ce{NaOH(aq)}$	3	\N
3ac6c148-8f9b-4d96-b7d6-9b0987898623	42981bc8-705a-4165-8fac-a289a0673583	A	$\\ce{Ca(OH)2}$	0	\N
6d2749bb-a72a-4f2a-bb81-d038d409e50b	42981bc8-705a-4165-8fac-a289a0673583	B	$\\ce{Cr2(SO4)3}$	1	\N
89f2351a-4df3-4694-bb11-1eea28d4cb16	42981bc8-705a-4165-8fac-a289a0673583	C	$\\ce{Al2(SO4)3}$	2	\N
fc38088a-34ed-4fe3-bd95-cc5d97903aef	42981bc8-705a-4165-8fac-a289a0673583	D	$\\ce{Fe2(SO4)3}$	3	\N
6e6425b7-2e83-4cdc-aeb6-568d626d0859	2c6aa640-77b4-4d21-a7db-6d7425228348	A	$\\ce{H2SO4}$	0	\N
d05cb7b2-c1c9-4d81-a2d5-522c3127c158	2c6aa640-77b4-4d21-a7db-6d7425228348	B	$\\ce{HNO3}$	1	\N
2496dcca-fbc7-4258-8507-3268f997d28f	2c6aa640-77b4-4d21-a7db-6d7425228348	C	$\\ce{HCl}$	2	\N
1332efb0-72e0-43e5-a410-fa860689f3bc	2c6aa640-77b4-4d21-a7db-6d7425228348	D	$\\ce{HF}$	3	\N
a46766b9-4f18-47bd-aff5-a318212c6ba5	dedf970c-bc28-42e4-97a9-e40fc3b52910	A	0	0	\N
5c0e52b8-c13c-448a-bd4a-9c03860ff687	dedf970c-bc28-42e4-97a9-e40fc3b52910	B	1	1	\N
2109a46d-d979-4d0e-828f-a3f082aa7ed8	dedf970c-bc28-42e4-97a9-e40fc3b52910	C	2	2	\N
04ff3c77-e325-4557-9e20-583120f488de	dedf970c-bc28-42e4-97a9-e40fc3b52910	D	3	3	\N
71bfeb2c-c32c-4b31-a315-0689ab19a51f	9756187f-492e-469e-8a23-5440b02e118d	A	$\\frac{2}{(x-1)^2}$	0	\N
e6936dac-3938-4a36-ac78-3c918e6284ac	9756187f-492e-469e-8a23-5440b02e118d	B	$\\frac{2}{(1-x^2)}$	1	\N
508db32c-fda5-49a3-a924-0be7df4eedad	9756187f-492e-469e-8a23-5440b02e118d	C	$\\frac{2}{(1-x)^2}$	2	\N
bc8e1a78-ed16-4b0b-b43c-41b11f6ebf00	9756187f-492e-469e-8a23-5440b02e118d	D	$\\frac{2x}{(1-x)^2}$	3	\N
b3570cae-46c1-426d-b8a7-9aea180136f2	80f911b3-a969-481c-bb8d-6920cf9cb4c3	A	$2P$	0	\N
ea960384-f67d-48ff-9488-9ee2b6761e8e	80f911b3-a969-481c-bb8d-6920cf9cb4c3	B	0	1	\N
3811b3a4-9e3b-4b25-83ba-f40ef0b309cd	80f911b3-a969-481c-bb8d-6920cf9cb4c3	C	$P$	2	\N
e360037b-c7fe-40f1-bda3-8476efaaaf6c	80f911b3-a969-481c-bb8d-6920cf9cb4c3	D	$\\frac{P}{2}$	3	\N
d66312a7-c36c-4ffc-a957-fc6276e5cc88	dc71a03f-b7c0-4e24-b019-2104aeda7e06	A	1	0	\N
06fd8c19-6bc9-43c7-9aec-6b89396cd52e	dc71a03f-b7c0-4e24-b019-2104aeda7e06	B	$2\\sqrt{2}$	1	\N
e8bf63dd-9814-4991-a7b9-d881c2f1fafc	dc71a03f-b7c0-4e24-b019-2104aeda7e06	C	3	2	\N
e00f362a-0edc-4efd-a8e6-0e183a4af4a0	dc71a03f-b7c0-4e24-b019-2104aeda7e06	D	4	3	\N
ca8e3b5a-5db4-4a0f-9c6e-abb4c4772c25	e67dc779-dc77-43b4-b0ce-c4894489103e	A	2 sq. units	0	\N
11a095c1-ee29-41b8-9612-6ba3bd44971e	e67dc779-dc77-43b4-b0ce-c4894489103e	B	4 sq. units	1	\N
c6889722-897f-4aeb-9eb4-7c897f8ee532	e67dc779-dc77-43b4-b0ce-c4894489103e	C	6 sq. units	2	\N
7a39f14e-d17b-4be3-aad6-f31d117e72a8	e67dc779-dc77-43b4-b0ce-c4894489103e	D	8 sq. units	3	\N
15100982-11f8-4102-8c83-aa8b413ff16f	69a58ffa-5f06-43ad-9351-93fcac89a144	A	$\\frac{2}{3}(e^x)^{3/2} + c$	0	\N
5d59fd7c-16a3-4716-b9d0-abeb7214dedc	69a58ffa-5f06-43ad-9351-93fcac89a144	B	$\\frac{1}{2}\\sqrt{e^x} + c$	1	\N
93513aa8-0ebc-4261-8d77-53d578e7f852	69a58ffa-5f06-43ad-9351-93fcac89a144	C	$2e^{x/2} + c$	2	\N
fffd3345-0631-45fc-ad82-50263f100ddf	69a58ffa-5f06-43ad-9351-93fcac89a144	D	$e^{x/2} + c$	3	\N
659f62fa-26eb-4e0c-919e-0301e9b76765	4c0d955d-1d07-4287-bf21-188b604a0255	A	$\\tan^{-1} \\frac{5}{9}$	0	\N
6c770218-4dcb-4438-a437-eab0b3be22c8	4c0d955d-1d07-4287-bf21-188b604a0255	B	$\\tan^{-1} \\frac{13}{7}$	1	\N
6cf90051-b0c1-479e-839e-46d06167ce78	4c0d955d-1d07-4287-bf21-188b604a0255	C	$\\frac{\\pi}{2}$	2	\N
2d1ad4db-8580-4b3c-90ca-adb45cf82b4e	4c0d955d-1d07-4287-bf21-188b604a0255	D	$\\frac{\\pi}{4}$	3	\N
cf6c6b47-3c09-4ed3-b30b-799bffbdf0f5	235b4eb3-fa4e-4e55-a04b-7eb052aecf74	A	$\\sec^2(\\sin^{-1} x) + c$	0	\N
5d658f34-c10c-489e-a4cd-905decfe79ca	235b4eb3-fa4e-4e55-a04b-7eb052aecf74	B	$\\sec(\\sin^{-1} x) + c$	1	\N
3924f7ad-943b-436f-8dd4-898aca331024	235b4eb3-fa4e-4e55-a04b-7eb052aecf74	C	$\\ln |\\sec(\\sin^{-1} x)| + c$	2	\N
430f33b1-49b9-4386-b494-9f0d686d50f1	235b4eb3-fa4e-4e55-a04b-7eb052aecf74	D	$\\ln |\\tan(\\sin^{-1} x)| + c$	3	\N
cb19532b-ab8b-4096-8a88-e762bd83a295	94d6936a-6e54-46fc-88a2-0f7b1a95d577	A	$30^\\circ$	0	\N
bfed2c95-0e24-4014-998e-6f06d7fe6c17	94d6936a-6e54-46fc-88a2-0f7b1a95d577	B	$45^\\circ$	1	\N
e6b69691-964e-4d22-a089-d8ba9e1921cf	94d6936a-6e54-46fc-88a2-0f7b1a95d577	C	$60^\\circ$	2	\N
88595180-57eb-41fc-8295-c61708eddb6d	94d6936a-6e54-46fc-88a2-0f7b1a95d577	D	$90^\\circ$	3	\N
e4f0d745-61f2-44a3-9a93-b71185aba742	6ab638f1-de68-40dc-8cbf-9d70d18aed9e	A	$(2n + 1) \\frac{\\pi}{4}$	0	\N
44ad7af2-2eb5-45a3-99ff-892b5f8514cd	6ab638f1-de68-40dc-8cbf-9d70d18aed9e	B	$(2n + 1) \\frac{\\pi}{8}$	1	\N
725191b2-83bd-4895-9ee8-f796f1b6d6f8	6ab638f1-de68-40dc-8cbf-9d70d18aed9e	C	$n \\frac{\\pi}{4}$	2	\N
9ab75f4e-cc6f-4b54-b0bd-14cae819a7b9	6ab638f1-de68-40dc-8cbf-9d70d18aed9e	D	$(2n - 1) \\frac{\\pi}{2}$	3	\N
a0c59e71-e6a3-4986-ae17-d20952331220	0d5eb94e-46e9-4e0a-9b5c-9795b00a3a2b	A	$y^2 = 1 + 2x$	0	\N
86ae344b-ab6d-475a-850d-5ad1604bf449	0d5eb94e-46e9-4e0a-9b5c-9795b00a3a2b	B	$y^2 = 4(1 - x)$	1	\N
55de4e4f-6a15-4a22-a1f1-277f65f16781	0d5eb94e-46e9-4e0a-9b5c-9795b00a3a2b	C	$y^2 = 4(1 + x)$	2	\N
d4ea7568-25e0-4886-a494-36f8575c6f2f	0d5eb94e-46e9-4e0a-9b5c-9795b00a3a2b	D	$x^2 = 4(1 + y)$	3	\N
1aef858a-965b-4462-ae26-7e491124a175	8ca720b4-8d46-40a9-85b9-71a1f611773c	A	$4$ একক	0	\N
76932eb1-07d9-4b42-af23-c1bd5c3f4e03	8ca720b4-8d46-40a9-85b9-71a1f611773c	B	$2\\sqrt{2}$ একক	1	\N
a1e7b5f8-cabb-445f-859e-ef8300ab4da5	8ca720b4-8d46-40a9-85b9-71a1f611773c	C	$2$ একক	2	\N
dbd22353-a62a-434c-aa4d-0ffd47873659	8ca720b4-8d46-40a9-85b9-71a1f611773c	D	$4\\sqrt{2}$ একক	3	\N
3a2f2478-a3e1-4f64-a01a-d7e4b4f28d39	4bf22e12-a335-4efa-9b66-8dd4cf2db6d7	A	বৃত্ত	0	\N
0ab6fca6-e3db-4d26-84a1-29d48aab6aba	4bf22e12-a335-4efa-9b66-8dd4cf2db6d7	B	উপবৃত্ত	1	\N
1dede344-fc8c-4d25-8996-1168bc5e484a	4bf22e12-a335-4efa-9b66-8dd4cf2db6d7	C	পরাবৃত্ত	2	\N
50a7fe90-26d6-4bf9-838e-aef6237afe2c	4bf22e12-a335-4efa-9b66-8dd4cf2db6d7	D	অধিবৃত্ত	3	\N
4c85d885-268d-4aaf-a28c-b9e42ca08671	e9e5918b-87d8-40d3-821b-8026e321680f	A	$\\frac{3}{2\\sqrt{2}}$	0	\N
393728d9-1eb9-4a44-8c24-1b42ea60e4b4	e9e5918b-87d8-40d3-821b-8026e321680f	B	$\\frac{3}{2}$	1	\N
b7347f4a-cd94-470c-9413-d1ae2eb337b0	e9e5918b-87d8-40d3-821b-8026e321680f	C	$\\frac{\\sqrt{5}}{2}$	2	\N
c0d48ab2-7df3-4ca6-bdb5-1fc28183025e	e9e5918b-87d8-40d3-821b-8026e321680f	D	$\\sqrt{\\frac{5}{2}}$	3	\N
44deeb6c-2ea0-442d-8923-0e303a42e0e2	ce6762bd-9ad2-4110-bd59-4b014abe8a95	A	$0$	0	\N
6a58a084-42eb-45ef-94c7-b77839855af4	ce6762bd-9ad2-4110-bd59-4b014abe8a95	B	$\\frac{1}{3}$	1	\N
3ffadc98-df50-42b3-b344-28be2621f55b	ce6762bd-9ad2-4110-bd59-4b014abe8a95	C	$1$	2	\N
80767a51-0aaf-4700-9f3a-fdeb9c7bef7d	ce6762bd-9ad2-4110-bd59-4b014abe8a95	D	$3$	3	\N
acadd648-3988-424f-9971-60f79f694dea	6a905554-2dd1-4a7c-a500-bd9e825e1c4f	A	$x^2 - 4x + 6 = 0$	0	\N
9cfe4322-8ada-4892-9689-deb818acf179	6a905554-2dd1-4a7c-a500-bd9e825e1c4f	B	$x^2 - 3x - 8 = 0$	1	\N
0cec70c4-851f-4205-a664-bf1044895a38	6a905554-2dd1-4a7c-a500-bd9e825e1c4f	C	$x^2 - 11x + 8 = 0$	2	\N
45bcd56c-4579-423c-852d-105ab8405eab	6a905554-2dd1-4a7c-a500-bd9e825e1c4f	D	$x^2 - 3x + 8 = 0$	3	\N
cb7e6e8c-be5c-4050-b867-ac14a25c425c	c04c6ea0-7ee3-4e5a-85dc-b72c7f6f3020	A	$3$	0	\N
89f1ee9b-7c45-4bee-8276-1d7827d2c801	c04c6ea0-7ee3-4e5a-85dc-b72c7f6f3020	B	$4$	1	\N
db7c194a-7df7-4cee-96e8-f0b0fdd06fc2	c04c6ea0-7ee3-4e5a-85dc-b72c7f6f3020	C	$-4$	2	\N
680bbf3a-e854-4f12-8f40-d7dd00962f60	c04c6ea0-7ee3-4e5a-85dc-b72c7f6f3020	D	$-3$	3	\N
233ccc57-b12e-46ce-826a-3046013b198c	723ea36f-88d0-4670-befb-326b583f045b	A	$2^n + 1$	0	\N
3d7449d5-5bb0-48f2-89be-2a554f382a3f	723ea36f-88d0-4670-befb-326b583f045b	B	$2^n$	1	\N
a33fbc54-9022-49f9-b778-32df9b23d840	723ea36f-88d0-4670-befb-326b583f045b	C	$2^{n-1}$	2	\N
77066fc6-e526-4a15-a6f2-9e9d85586636	723ea36f-88d0-4670-befb-326b583f045b	D	$2^n - 1$	3	\N
7f7d1065-8117-486e-bef0-7ab5667f1a46	b7a602a2-e595-4a46-8aca-637cb75a3eee	A	$1000\\,\\text{m/sec}$	0	\N
fb61c8a4-5d8a-469d-afd6-cfff9a8b9b72	b7a602a2-e595-4a46-8aca-637cb75a3eee	B	$800\\,\\text{m/sec}$	1	\N
f212a220-ca42-49f4-bc74-6d37510bedb8	b7a602a2-e595-4a46-8aca-637cb75a3eee	C	$700\\,\\text{m/sec}$	2	\N
ab1a8553-484c-4ed5-a252-ec92454c759e	b7a602a2-e595-4a46-8aca-637cb75a3eee	D	$500\\,\\text{m/sec}$	3	\N
a87758d4-4a83-4ca0-9235-d740a0e66c5f	19108d8a-6555-46b1-9f75-d93b8fd0e4c6	A	$(\\frac{1}{2}, \\frac{2}{3})$	0	\N
5c6b834f-c12b-499b-9f7a-c0474fb70869	19108d8a-6555-46b1-9f75-d93b8fd0e4c6	B	$(\\frac{5}{6}, 1)$	1	\N
b4f219a2-03d2-4a1d-8b7f-a852474a420b	19108d8a-6555-46b1-9f75-d93b8fd0e4c6	C	$(\\frac{5}{3}, 1)$	2	\N
9e886eb2-003c-4141-9283-8042debac3b5	19108d8a-6555-46b1-9f75-d93b8fd0e4c6	D	$(\\frac{2}{3}, -1)$	3	\N
9fec5ba0-2d26-41c8-8b9b-1e5236fca39e	5b085180-8d95-4faa-b246-1baa9dc2dc92	A	$360$	0	\N
f8c6d8ea-f1aa-4cfd-ae79-cb5a5f9f41ae	5b085180-8d95-4faa-b246-1baa9dc2dc92	B	$460$	1	\N
d428b9c0-04a7-4953-96b4-d484d55905b6	5b085180-8d95-4faa-b246-1baa9dc2dc92	C	$459$	2	\N
cdd665a6-c234-4931-99d7-fd6ca5f36507	5b085180-8d95-4faa-b246-1baa9dc2dc92	D	$359$	3	\N
0f4b6842-d450-4b8a-9fe8-ec2be7cec44b	5816d1c2-fe10-419f-97a9-c4b2995fe001	A	$10$	0	\N
555f8bca-cc29-4678-9434-680c56e96556	5816d1c2-fe10-419f-97a9-c4b2995fe001	B	$20$	1	\N
c1ce0848-c546-4751-b8b9-3445697f9cd7	5816d1c2-fe10-419f-97a9-c4b2995fe001	C	$30$	2	\N
bea1fac6-5f97-40cc-b327-3d6346d15edd	5816d1c2-fe10-419f-97a9-c4b2995fe001	D	$45$	3	\N
ec48607f-e3bb-4e8c-bf5d-d0835c8104ca	37460786-8f6a-4562-a11d-a167c6305daf	A	$\\frac{2}{7} < x < \\frac{2}{5}$	0	\N
bf54c464-abd6-453f-b765-801709a40b52	37460786-8f6a-4562-a11d-a167c6305daf	B	$-\\frac{4}{7} < x < -\\frac{2}{5}$	1	\N
64e35028-2d72-40e0-96aa-4b7e3d200ab7	37460786-8f6a-4562-a11d-a167c6305daf	C	$\\frac{1}{8} < x < \\frac{1}{7}$	2	\N
0700844d-2501-4c95-9f96-ea9a7c47f90b	37460786-8f6a-4562-a11d-a167c6305daf	D	$\\frac{1}{5} > x > \\frac{1}{7}$	3	\N
37d66b64-02b1-4dea-a88b-d41f2c84831a	9b7cbbe1-1c92-4bd9-b792-34480ccd831c	A	$204$	0	\N
151f2e74-2028-435a-b98d-9d28497e6490	9b7cbbe1-1c92-4bd9-b792-34480ccd831c	B	$240$	1	\N
67d9b16d-dc4e-4761-b1a8-f4593bc5d0dd	9b7cbbe1-1c92-4bd9-b792-34480ccd831c	C	$402$	2	\N
5d5184a8-081c-44c9-bf7b-1a5f7e58bb6a	9b7cbbe1-1c92-4bd9-b792-34480ccd831c	D	$420$	3	\N
14f4c1a2-1dbe-489e-8eb1-07c42acee431	0b060917-e53b-4c70-8db2-389b2eaf1ecf	A	$\\frac{6}{7}$	0	\N
26779a64-75b6-4df7-94c1-93add22258f0	0b060917-e53b-4c70-8db2-389b2eaf1ecf	B	$\\frac{5}{12}$	1	\N
cb3f4c0c-dc5f-4ba5-a4bb-7fdf96d29ea3	0b060917-e53b-4c70-8db2-389b2eaf1ecf	C	$\\frac{2}{3}$	2	\N
757f2513-1dfc-40e6-bd81-71b7e4e67fdb	0b060917-e53b-4c70-8db2-389b2eaf1ecf	D	$\\frac{7}{12}$	3	\N
b35f59a3-fb41-4830-bf0a-e0deeecec6d5	d9196d07-6259-4a68-9f98-a502a20080f1	A	$\\mathbb{R} - \\{1\\}$	0	\N
c3ef96b8-7591-416c-b554-df619e3929cf	d9196d07-6259-4a68-9f98-a502a20080f1	B	$\\mathbb{R} - \\{0\\}$	1	\N
3766bacf-2d8f-4b4a-aeff-f597c38416c3	d9196d07-6259-4a68-9f98-a502a20080f1	C	$\\mathbb{R} - \\{0, 1\\}$	2	\N
5d55a639-7967-48c1-bfe5-02999bd8a6a9	d9196d07-6259-4a68-9f98-a502a20080f1	D	$(-\\infty, 0)$	3	\N
fe57e3f3-8ced-47af-8fca-729942f7b67b	d8efe0db-6cfa-4e4c-b111-c7fe8248c4bc	A	$\\cos^{-1} \\frac{1}{\\sqrt{3}}$	0	\N
6b78c71d-511c-43b2-9d69-9b814e6406f7	d8efe0db-6cfa-4e4c-b111-c7fe8248c4bc	B	$\\cos^{-1} \\frac{1}{3}$	1	\N
03c36ef6-44c5-43cd-99ad-7fa82165b68b	d8efe0db-6cfa-4e4c-b111-c7fe8248c4bc	C	$\\cos^{-1} \\frac{1}{2}$	2	\N
7e2e7429-5ee4-44f7-93a2-9ac2b4f19958	d8efe0db-6cfa-4e4c-b111-c7fe8248c4bc	D	$\\cos^{-1} \\frac{1}{\\sqrt{2}}$	3	\N
b2904e1e-afcf-4f7b-aa9e-ad4ebaa81459	244f8058-cb97-45c0-b78e-4b2393795704	A	$x = 0$	0	\N
eb4c9eae-2426-44b8-9bf0-5fb11b673fd5	244f8058-cb97-45c0-b78e-4b2393795704	B	$x = 2$	1	\N
5aff76b9-e78a-4d94-b395-08303b02d537	244f8058-cb97-45c0-b78e-4b2393795704	C	$y = 2$	2	\N
dd04a2c1-fa62-462f-a307-8d025997c17f	244f8058-cb97-45c0-b78e-4b2393795704	D	$y = 4$	3	\N
165622f6-8f6a-40ab-b78c-cafb08745a04	47a2db81-bbd5-4f67-bd3d-1e0423644fb0	A	$1 - \\frac{1}{2} \\cos 2A$	0	\N
677461d2-2005-4e8b-a535-c26d82c2cb2f	47a2db81-bbd5-4f67-bd3d-1e0423644fb0	B	$1 + \\sin 2A$	1	\N
7e16182f-735e-4b0f-bbcc-a178cd641e04	47a2db81-bbd5-4f67-bd3d-1e0423644fb0	C	$1 + 3 \\cos 2A$	2	\N
239e14ab-dd35-424b-90d1-a8b68b9caa6d	47a2db81-bbd5-4f67-bd3d-1e0423644fb0	D	$1 + \\frac{1}{2} \\cos 2A$	3	\N
c398c633-6e6a-469b-8c8c-969cbad24a95	f1de21b5-a199-45b1-8c93-94c0a1fab0e2	A	0	0	\N
b9594e6e-29f9-4a09-8f29-ca821d2b019d	f1de21b5-a199-45b1-8c93-94c0a1fab0e2	B	2	1	\N
faf977a3-31f2-4616-856e-e912f1787c86	f1de21b5-a199-45b1-8c93-94c0a1fab0e2	C	$1 + \\sqrt{3}$	2	\N
a933ca63-c47d-4500-855e-6dacdbc25260	f1de21b5-a199-45b1-8c93-94c0a1fab0e2	D	1	3	\N
5538b0f6-a3df-4e7e-99e0-1f0bff1fd868	0ff94e30-07be-49f1-b626-ab10a70868e0	A	Oryza sativa	0	\N
0dbc661f-0b01-4a2a-bdf0-3370de2def5b	0ff94e30-07be-49f1-b626-ab10a70868e0	B	Nelumbo nucifera	1	\N
010f243d-cf90-4d75-8767-bc95352a2130	0ff94e30-07be-49f1-b626-ab10a70868e0	C	Helianthus annuus	2	\N
76a782ac-a898-4d4f-8725-7a3dbcf5f976	0ff94e30-07be-49f1-b626-ab10a70868e0	D	Portulaca oleracea	3	\N
19a670dd-a94c-4cc3-97cc-e00d853d3fee	ac4ed30f-eb94-4a9f-9732-474d064d0a28	A	Ctenophora	0	\N
4b336845-9fd2-42f1-a75f-23bc68bb55c1	ac4ed30f-eb94-4a9f-9732-474d064d0a28	B	Gastropoda	1	\N
0fca0756-1c77-46a8-867c-c7e12260955a	ac4ed30f-eb94-4a9f-9732-474d064d0a28	C	Porifera	2	\N
7c8351b3-90b0-4583-8dcd-c4f8aaec9010	ac4ed30f-eb94-4a9f-9732-474d064d0a28	D	Cnidaria	3	\N
6d992530-9e57-4072-b723-8b27aed96039	7b964edd-5141-4241-8361-6607fdc97545	A	লাল-সবুজ বর্ণান্ধতা	0	\N
797f0a0c-fc2b-4e8e-b1f6-7ab2b38c10e4	7b964edd-5141-4241-8361-6607fdc97545	B	থ্যালাসেমিয়া	1	\N
394f6d93-2139-4a36-9cc6-e12f276e7b48	7b964edd-5141-4241-8361-6607fdc97545	C	হিমোফিলিয়া	2	\N
f2b59dc6-f609-4b99-8697-c7c12cd0aae1	7b964edd-5141-4241-8361-6607fdc97545	D	মাস্কুলার ডিস্ট্রফি	3	\N
98cfac19-e7fa-4fbb-9ae4-db58806ea2c0	befc229d-d0b2-42f9-9ff5-885b2df37ab8	A	যকৃৎ	0	\N
83d41c9e-2cc4-4cfb-ba2c-f3dcd3662225	befc229d-d0b2-42f9-9ff5-885b2df37ab8	B	অগ্ন্যাশয়	1	\N
56ec913d-40d8-4065-8acf-a628f99ec9b5	befc229d-d0b2-42f9-9ff5-885b2df37ab8	C	লালা গ্রন্থি	2	\N
b094e84f-0bdb-4489-a9b2-1dc201cd4529	befc229d-d0b2-42f9-9ff5-885b2df37ab8	D	গ্যাস্ট্রিক গ্রন্থি	3	\N
5bfdc6f6-646e-4b57-a872-bc6e3575b71d	e8034aa9-cb42-4061-a490-075e61ccb4ef	A	লেপ্টোটিন	0	\N
f86454d2-0618-47e1-81e9-ae6e77fa5a4e	e8034aa9-cb42-4061-a490-075e61ccb4ef	B	জাইগোটিন	1	\N
b001e1b1-2729-406b-a3d2-91d062a2a97a	e8034aa9-cb42-4061-a490-075e61ccb4ef	C	প্যাকাইটিন	2	\N
1fbefd2c-5868-4f6b-a206-f46c6209b61a	e8034aa9-cb42-4061-a490-075e61ccb4ef	D	ডায়াকাইনেসিস	3	\N
8a998c11-62e3-46ad-9357-b83e4dcb727b	dfa30cb6-c26d-4978-9e28-8a6a63583eea	A	20	0	\N
5c7cd597-8236-419f-9ac6-6af90cd6c317	dfa30cb6-c26d-4978-9e28-8a6a63583eea	B	24	1	\N
92b344c1-66be-485b-ada1-80db3df57895	dfa30cb6-c26d-4978-9e28-8a6a63583eea	C	26	2	\N
3d4cf6b3-7b67-4826-a1de-3dbcdfc06357	dfa30cb6-c26d-4978-9e28-8a6a63583eea	D	30	3	\N
73cb921b-4a2a-49d1-b2cd-aed52416e71a	639e19bd-dedd-4d8f-b4a9-e301c01c61bd	A	Cassia sophera	0	\N
1aaa2277-2902-490e-a370-5882c166c4c9	639e19bd-dedd-4d8f-b4a9-e301c01c61bd	B	Brassica napus	1	\N
b6b6b2bd-9103-40ce-b4ec-edc48017a6b8	639e19bd-dedd-4d8f-b4a9-e301c01c61bd	C	Lablab purpureus	2	\N
aa5fb07a-178e-4126-b46a-61f9afd6e984	639e19bd-dedd-4d8f-b4a9-e301c01c61bd	D	Pisum sativum	3	\N
871c9a17-0cbf-4e19-9c08-ff724f991046	252b88c0-d3fd-4d5d-85a5-b770a56ddc48	A	$45\\%$	0	\N
369455f7-c8b6-49e8-84d2-ee36056b3588	252b88c0-d3fd-4d5d-85a5-b770a56ddc48	B	$55\\%$	1	\N
b42531c1-50cd-4adb-a131-e0c16814b0bf	252b88c0-d3fd-4d5d-85a5-b770a56ddc48	C	$65\\%$	2	\N
63399219-67a6-4377-93d0-c7f8b065e395	252b88c0-d3fd-4d5d-85a5-b770a56ddc48	D	$75\\%$	3	\N
2b1ae9e6-e6a0-48a6-9b87-10bbe02fd242	611563ab-2616-4db5-a6fd-edf5d4601122	A	হেপারিন	0	\N
c77b7364-5cc3-48c4-8e7c-5d3feb040366	611563ab-2616-4db5-a6fd-edf5d4601122	B	থ্রম্বিন	1	\N
9c4deefc-7cf5-410a-a498-67d6004a402b	611563ab-2616-4db5-a6fd-edf5d4601122	C	ফাইব্রিন	2	\N
14e2b1b5-03ab-41c7-b33c-e03b2e2b3036	611563ab-2616-4db5-a6fd-edf5d4601122	D	থ্রম্বোপ্লাস্টিন	3	\N
e290b61a-053f-4cba-84c2-887d09f076d2	c8dd689f-0b80-43bc-81da-9f1e01122104	A	Anura	0	\N
63ac36c7-590b-46a3-9a51-584dc67cfe84	c8dd689f-0b80-43bc-81da-9f1e01122104	B	Crocodilia	1	\N
9c9d3988-d7e7-4b8f-a7fa-da70e727f6d4	c8dd689f-0b80-43bc-81da-9f1e01122104	C	Gymnophiona	2	\N
0ac13dc4-19b2-4b85-8182-a5d7b799d608	c8dd689f-0b80-43bc-81da-9f1e01122104	D	Caudata	3	\N
bebb52bb-9671-4d93-8506-0c0493b48700	7d80b0ca-0599-4eb7-9955-862b2ff6c816	A	ইঁদুর	0	\N
e45f7ba6-39cc-49f2-9d3d-ec69a8107b23	7d80b0ca-0599-4eb7-9955-862b2ff6c816	B	বনরুই	1	\N
5b300e24-37a4-42bf-b43f-1b9bab09ed5b	7d80b0ca-0599-4eb7-9955-862b2ff6c816	C	হংসচঞ্চু	2	\N
e3650378-9aca-4ef2-b679-c7b71d57d213	7d80b0ca-0599-4eb7-9955-862b2ff6c816	D	কাঠবিড়াল	3	\N
136251d7-f93f-4d3e-ae86-199e6fef77fc	e29f7dc7-dab8-4560-89ac-02ebea288803	A	হার্পেটোলজি	0	\N
fa9c9450-59af-4ecb-bab9-3427f514a5ea	e29f7dc7-dab8-4560-89ac-02ebea288803	B	অরনিথোলজি	1	\N
adfe51e2-b59b-4ce2-9242-698f718b533a	e29f7dc7-dab8-4560-89ac-02ebea288803	C	ম্যামালজি	2	\N
63935f35-05de-4a4c-970a-3ab6e7631895	e29f7dc7-dab8-4560-89ac-02ebea288803	D	ম্যালাকলজি	3	\N
d9a029a0-f551-4252-a9d8-2aa6b6d1d5b3	bab9447a-4fc7-419a-97a0-cb423d80687d	A	$15:1$	0	\N
2041bd76-3c26-4aa7-b891-b7f7ef4775a2	bab9447a-4fc7-419a-97a0-cb423d80687d	B	$13:3$	1	\N
a8b3e9b1-873a-4beb-9f00-097f1727884d	bab9447a-4fc7-419a-97a0-cb423d80687d	C	$9:7$	2	\N
5c9e29d9-d89b-4dcb-89d5-929337427294	bab9447a-4fc7-419a-97a0-cb423d80687d	D	$9:3:3:1$	3	\N
8b00eb46-6109-4b72-bae3-cda36589008a	acdd52eb-444b-4a96-a782-26ebde296637	A	Carolus Linnaeus	0	\N
c9828757-095f-40ca-ba58-b4b49d06ce0c	acdd52eb-444b-4a96-a782-26ebde296637	B	Charles Darwin	1	\N
0ecd7c23-3eb6-4eb5-99db-332eec53f4f9	acdd52eb-444b-4a96-a782-26ebde296637	C	Gregor Johann Mendel	2	\N
59cdc796-ab63-4862-97f2-9f429144b651	acdd52eb-444b-4a96-a782-26ebde296637	D	Theophrastus	3	\N
7884d47e-ae76-480f-80f4-02b17bd12105	b0dd1f29-90ac-4c47-9952-2fd84fadebd6	A	Porifera	0	\N
87df95bd-821a-4854-8519-4c91b1fd272f	b0dd1f29-90ac-4c47-9952-2fd84fadebd6	B	Platyhelminthes	1	\N
48fb4fd5-21f8-4196-9bee-e6927fdaf8b0	b0dd1f29-90ac-4c47-9952-2fd84fadebd6	C	Mollusca	2	\N
74e721e5-0806-42c6-8151-74aed2d58668	b0dd1f29-90ac-4c47-9952-2fd84fadebd6	D	Nematoda	3	\N
11341985-bab4-4c4e-977a-5f55b0e25889	dfc6a5de-674e-46ad-9c2b-77a46abe8c5d	A	সংবেদী কোষ	0	\N
280bfe6e-9235-427b-9ee3-6e7966a2602c	dfc6a5de-674e-46ad-9c2b-77a46abe8c5d	B	গ্রন্থি কোষ	1	\N
ecf01eeb-14bf-4be1-a331-41a4879c58b0	dfc6a5de-674e-46ad-9c2b-77a46abe8c5d	C	নিডোসাইট	2	\N
0f82635d-5f1a-443f-96a5-1a6a98719e53	dfc6a5de-674e-46ad-9c2b-77a46abe8c5d	D	ক্ষণপদীয় কোষ	3	\N
92972575-e103-4044-acc9-a38f41e4d28b	090e1d6a-890d-4fb7-92f8-ad252286e587	A	হাইওয়েড অস্থি	0	\N
d0c4061d-870f-4f14-885c-0f311c45d395	090e1d6a-890d-4fb7-92f8-ad252286e587	B	ম্যান্ডিবল	1	\N
b2ca5b2c-25d9-4a3c-81b4-638a218799e9	090e1d6a-890d-4fb7-92f8-ad252286e587	C	রামাস	2	\N
e34e6f31-35d9-48ea-96f4-9626d8fca42d	090e1d6a-890d-4fb7-92f8-ad252286e587	D	ম্যাক্সিলা	3	\N
44f22735-a319-4cfb-b0f3-7e0d3da00090	1043b4ba-f62b-45b2-99b5-0c1b5636ed45	A	অস্থি বৃদ্ধি	0	\N
df3b822a-4693-4752-af63-bc2b70e012d8	1043b4ba-f62b-45b2-99b5-0c1b5636ed45	B	খাদ্যের বিপাক	1	\N
66c3b1f9-a23d-4acc-85e7-d8c60970ab36	1043b4ba-f62b-45b2-99b5-0c1b5636ed45	C	রক্তচাপ	2	\N
a2b0acd6-0f85-4ced-8f57-6598fb12eba0	1043b4ba-f62b-45b2-99b5-0c1b5636ed45	D	যৌন হরমোনের কাজ	3	\N
661a25d9-053c-456b-821e-4e7b0a6ef990	17ca7102-b756-4c15-a0cd-82bd42af56fe	A	Penicillium	0	\N
343b140a-ca49-4b29-9fe5-889137b66fd5	17ca7102-b756-4c15-a0cd-82bd42af56fe	B	Phytophthora	1	\N
b77e7513-b56d-4946-ab4e-70c8cd32f8bd	17ca7102-b756-4c15-a0cd-82bd42af56fe	C	Alternaria	2	\N
2bc38d9a-c2d7-4f42-a678-c40ad9ebc695	17ca7102-b756-4c15-a0cd-82bd42af56fe	D	Cephaleuros	3	\N
e5b08961-d28e-4158-ba7c-aa1e9af0c3cb	1a22353f-b8d9-44d2-bd07-3872a6e4ae09	A	Riccia	0	\N
20156f6f-fea3-4f30-8d77-f7fe79a4a246	1a22353f-b8d9-44d2-bd07-3872a6e4ae09	B	Anthoceros	1	\N
ec2551a6-f51a-4bd1-a7bd-dab02d8fc0bc	1a22353f-b8d9-44d2-bd07-3872a6e4ae09	C	Pteris	2	\N
58dd2f2d-371f-4bb2-a90e-cc4c185e6972	1a22353f-b8d9-44d2-bd07-3872a6e4ae09	D	Hibiscus	3	\N
eab26f85-66b3-407c-8d94-5ff7d5f39450	aa8b6797-a138-460b-8ed0-1ea04b90668d	A	Bacillus	0	\N
2d15a2aa-06ed-447d-bab4-e4eccb42d24f	aa8b6797-a138-460b-8ed0-1ea04b90668d	B	Acetobacter	1	\N
f394d412-d19b-4c08-a87f-257b40b56df9	aa8b6797-a138-460b-8ed0-1ea04b90668d	C	Pseudomonas	2	\N
3ccb91f6-8765-4b54-b1d3-a61c7ef95139	aa8b6797-a138-460b-8ed0-1ea04b90668d	D	Nitrobacter	3	\N
ebe289cf-c97a-480e-ac6f-7aa4f43030f4	748e1a23-53a8-4c1b-b48b-2d4e03e00118	A	উৎপাদক	0	\N
c1aad0d7-6817-46f3-91c0-f45730cb81f1	748e1a23-53a8-4c1b-b48b-2d4e03e00118	B	প্রাইমারি খাদক	1	\N
8b467622-79d7-4710-8cf9-72ee690e8eb8	748e1a23-53a8-4c1b-b48b-2d4e03e00118	C	সেকেন্ডারি খাদক	2	\N
970bceed-6bfe-4453-964b-c881723174db	748e1a23-53a8-4c1b-b48b-2d4e03e00118	D	টারশিয়ারি খাদক	3	\N
3f957b5e-a5a4-4843-a186-70e536c5b13f	8a2500b7-832b-4c7a-9124-bf9a97170121	A	৮	0	\N
cd0a8af8-4578-4f46-81df-97f85b68a454	8a2500b7-832b-4c7a-9124-bf9a97170121	B	৪	1	\N
84eef631-5d54-4902-81af-28a0cb8402ab	8a2500b7-832b-4c7a-9124-bf9a97170121	C	৩	2	\N
7b1a3476-06a5-49d1-882a-74014c622e25	8a2500b7-832b-4c7a-9124-bf9a97170121	D	৬	3	\N
5619491f-ac0b-4fa0-a8bf-6b74f77d328b	1b6b68e8-23cc-47db-8064-0171f9fa6776	A	মোম	0	\N
dc4baa21-da6f-4106-b19c-086b99ac7448	1b6b68e8-23cc-47db-8064-0171f9fa6776	B	রাবার	1	\N
a2c4f276-c9d8-4e5d-8771-628c3109d8ec	1b6b68e8-23cc-47db-8064-0171f9fa6776	C	সিটোস্টেরল	2	\N
68fe90de-772a-4939-9142-b718cade9fc6	1b6b68e8-23cc-47db-8064-0171f9fa6776	D	সেফালিন	3	\N
2ba2e4f2-e34b-4d65-854c-0016eba5f399	47119bcf-aec2-4d82-9fca-51f0a1187435	A	AUG	0	\N
8fcd12e2-5fc6-496a-9ea3-48f5845769ea	47119bcf-aec2-4d82-9fca-51f0a1187435	B	UGG	1	\N
f147c382-183c-4d96-887f-e35b47cb5dd3	47119bcf-aec2-4d82-9fca-51f0a1187435	C	UGA	2	\N
8eb081da-b3ef-4fef-b88c-1660ad23c4e7	47119bcf-aec2-4d82-9fca-51f0a1187435	D	AGU	3	\N
b6b5bb89-a100-4651-bbfa-fe58264bd106	57eb8fb5-6663-483d-b5de-e6259ebff3d0	A	Micelle	0	\N
1681b439-f86e-42ec-aa0d-6ca237d465fb	57eb8fb5-6663-483d-b5de-e6259ebff3d0	B	Microfibril	1	\N
24fa4728-b489-44a4-b282-55731ccea67e	57eb8fb5-6663-483d-b5de-e6259ebff3d0	C	Fibril	2	\N
acac315a-6ed3-4467-9fac-f06e71ea81ca	57eb8fb5-6663-483d-b5de-e6259ebff3d0	D	Fibre	3	\N
20eca164-8225-4aa1-b508-a7f42b34f38f	42ed5662-52b7-42ef-b9db-62d793d7586d	A	Bryophyta	0	\N
fd8f8273-6055-48a2-863e-495814ddf36d	42ed5662-52b7-42ef-b9db-62d793d7586d	B	Pteridophyta	1	\N
e6cab203-9a8a-4e8c-9aed-d7b47df3d59e	42ed5662-52b7-42ef-b9db-62d793d7586d	C	Gymnosperm	2	\N
e7c14d5b-fe01-4680-9b8d-83490388a77a	42ed5662-52b7-42ef-b9db-62d793d7586d	D	Angiosperm	3	\N
484c10ae-d23e-41d1-9b18-bd719f113f70	3b791f22-9541-4e07-9e63-a9053b682564	A	Sargassum	0	\N
07080893-1c76-49f7-ab82-d31bad5719be	3b791f22-9541-4e07-9e63-a9053b682564	B	Ocillatoria	1	\N
9b402c1e-6369-48c2-81ae-2a62dc357300	3b791f22-9541-4e07-9e63-a9053b682564	C	Volvox	2	\N
08efd21a-9008-4b83-ac30-95508afd4831	3b791f22-9541-4e07-9e63-a9053b682564	D	Zygnema	3	\N
30d12c3f-9ced-4577-bc85-d75424994985	2d074995-ec0c-4e8c-b0b0-4ba70e47708a	A	Aspideretes hurum	0	\N
c74204b1-9177-423f-911a-bd915edb7a2a	2d074995-ec0c-4e8c-b0b0-4ba70e47708a	B	Aspideretes nigricans	1	\N
422a87b0-f5ff-4e32-869b-39942328dbbb	2d074995-ec0c-4e8c-b0b0-4ba70e47708a	C	Chelonia mydas	2	\N
5414fa78-092b-44b5-adb0-7eb4ea95dba5	2d074995-ec0c-4e8c-b0b0-4ba70e47708a	D	Pangshura tecta	3	\N
275953aa-e7f7-4cc7-a45a-f2750baa8ba3	35282711-e0a6-4f6e-ae17-3568df55c9ea	A	Cellulase	0	\N
29f1b7e0-533a-4a90-886b-53b655146469	35282711-e0a6-4f6e-ae17-3568df55c9ea	B	Cellubiase	1	\N
fc5e63c6-93fb-421e-81cd-687339af2237	35282711-e0a6-4f6e-ae17-3568df55c9ea	C	Zymase	2	\N
94a7b71e-4c90-4b93-997f-d1e03f8d7de3	35282711-e0a6-4f6e-ae17-3568df55c9ea	D	Catalase	3	\N
12c5384d-c9e7-4e55-89ac-bc22a53faba6	1b7caef1-59fd-4b4a-aa70-42c2f635fe44	A	$3\\,\\text{A}$	0	\N
3f214214-2691-4970-940b-5a5c18a15fe2	1b7caef1-59fd-4b4a-aa70-42c2f635fe44	B	$2\\,\\text{A}$	1	\N
5c320a0e-8291-4e17-b07e-efe6c301f5c3	1b7caef1-59fd-4b4a-aa70-42c2f635fe44	C	$1\\,\\text{A}$	2	\N
31316e20-4f79-4fcd-9f82-5f57e0c38b88	1b7caef1-59fd-4b4a-aa70-42c2f635fe44	D	$0.5\\,\\text{A}$	3	\N
5896b551-262b-4aff-9132-ba4a2c9d0218	d465803b-1304-4d77-8002-5b7aedd3c83c	A	$3.6 \\times 10^4\\,\\text{C}$	0	\N
9641a933-9ad6-4925-84ab-5c02cc015142	d465803b-1304-4d77-8002-5b7aedd3c83c	B	$5.4 \\times 10^4\\,\\text{C}$	1	\N
7605ca74-4bed-43f2-bf2e-e7e85e244a2b	d465803b-1304-4d77-8002-5b7aedd3c83c	C	$1.4 \\times 10^3\\,\\text{C}$	2	\N
de8c0f77-ef5b-4505-ad60-e87167f9d877	d465803b-1304-4d77-8002-5b7aedd3c83c	D	$3.6 \\times 10^6\\,\\text{C}$	3	\N
dd1b41b8-731f-4578-b51a-c6249cbd746a	af038b7c-e600-4d33-8155-21719ce50014	A	$0\\,\\text{J}$	0	\N
1c591199-ec81-4a0a-8d9d-cac9815bea91	af038b7c-e600-4d33-8155-21719ce50014	B	$1\\,\\text{J}$	1	\N
5759d895-50da-4ad1-a0bc-bf4d9fbdb0ed	af038b7c-e600-4d33-8155-21719ce50014	C	$2\\,\\text{J}$	2	\N
fcb461fd-de2c-4fb0-aea9-f69dafcb70d7	af038b7c-e600-4d33-8155-21719ce50014	D	$4\\,\\text{J}$	3	\N
5dce8b07-0d92-46e6-bb6f-5c9f0736736b	46017748-34b0-4df2-ba25-ae8a35202fd9	A	$2\\sqrt{2}$	0	\N
5fd1b15a-84fb-424e-bef5-821b9f412de9	46017748-34b0-4df2-ba25-ae8a35202fd9	B	$2$	1	\N
94b38065-9b97-4f39-8f12-48b01f3152c3	46017748-34b0-4df2-ba25-ae8a35202fd9	C	$1$	2	\N
a4e4edf7-970e-450f-8042-6474bf2d6e20	46017748-34b0-4df2-ba25-ae8a35202fd9	D	$\\sqrt{2}$	3	\N
68699356-6252-4cfb-bb98-2ee4d3c9210f	38286d3b-99a2-4122-b821-87eb0a236eca	A	$4 \\times 10^5\\,\\text{N}$	0	\N
7cd4e5a1-847f-4af9-9ab2-6598e80e33b6	38286d3b-99a2-4122-b821-87eb0a236eca	B	$4 \\times 10^{-5}\\,\\text{N}$	1	\N
bc7d964e-df65-4bfb-8560-bfa224761e18	38286d3b-99a2-4122-b821-87eb0a236eca	C	$4 \\times 10^4\\,\\text{N}$	2	\N
4d991538-4f88-4080-857a-f6aab606d197	38286d3b-99a2-4122-b821-87eb0a236eca	D	$2 \\times 10^6\\,\\text{N}$	3	\N
8099fc5f-cf13-412d-b44a-7c410c6ed988	631925ee-0015-485f-b444-04e213626498	A	$3\\,\\text{rad/s}$	0	\N
58e46925-7e22-4b14-9ece-4b1d5784286a	631925ee-0015-485f-b444-04e213626498	B	$\\sqrt{3}\\,\\text{rad/s}$	1	\N
f8bcee2d-4502-447e-a29c-b1b8a509017a	631925ee-0015-485f-b444-04e213626498	C	$\\sqrt{27}\\,\\text{rad/s}$	2	\N
c209da9b-1eca-49db-9604-7c2a5a523389	631925ee-0015-485f-b444-04e213626498	D	$9\\,\\text{rad/s}$	3	\N
510ba871-ad05-4b17-93b6-36ffe06515a4	bb8e0d8a-95dc-4430-a5de-bbedcd1d8fda	A	$\\lambda = h/cE$	0	\N
ccf16575-d5d5-4c5f-8f75-4f9ea0425e56	bb8e0d8a-95dc-4430-a5de-bbedcd1d8fda	B	$\\lambda = ch/E$	1	\N
ba052d6d-8e41-43a7-baa3-6c222a464cb6	bb8e0d8a-95dc-4430-a5de-bbedcd1d8fda	C	$\\lambda = c/Eh$	2	\N
427ed078-fb03-4cff-a967-b677a346c650	bb8e0d8a-95dc-4430-a5de-bbedcd1d8fda	D	$\\lambda = E/hc^2$	3	\N
d958d69d-59ec-4a57-a24e-6bce29b927b2	993ab2ec-b5b1-45ce-8e69-172067cd19a5	A	$0\\,\\text{m}$	0	\N
8a3991ff-3ccc-490f-b959-9f93d1e12c7b	993ab2ec-b5b1-45ce-8e69-172067cd19a5	B	$0.098\\,\\text{m}$	1	\N
c9807246-4068-43fd-9a02-8000b9fa2dc2	993ab2ec-b5b1-45ce-8e69-172067cd19a5	C	$0.31\\,\\text{m}$	2	\N
08f5f44a-75a8-40c2-a1ac-31172ce80117	993ab2ec-b5b1-45ce-8e69-172067cd19a5	D	$1.0\\,\\text{m}$	3	\N
512af829-3c9d-401b-99d2-4ad5a1b64e56	346f920b-88ea-4002-9f8c-54db78719db2	A	$\\frac{60}{\\pi}\\,\\text{rad/s}$	0	\N
9c34a64c-e540-436e-95e8-35d8c9960740	346f920b-88ea-4002-9f8c-54db78719db2	B	$\\frac{1800}{\\pi}\\,\\text{rad/s}$	1	\N
d6a7e47e-dd4f-404e-a081-27388463d4d8	346f920b-88ea-4002-9f8c-54db78719db2	C	$\\frac{\\pi}{rad}\\,\\text{/s}$	2	\N
ade5552f-5691-4234-93a3-7df2ec4a169b	346f920b-88ea-4002-9f8c-54db78719db2	D	$\\frac{\\pi}{1800}\\,\\text{rad/s}$	3	\N
e6614b88-5f77-4d73-9168-a7614b0e4686	3f5b9d22-6edf-4b2b-a7e7-2b634e259061	A	$C_v = (x - 1)R$	0	\N
95218cf3-8ab6-4646-ad5f-b6b2cfa1560b	3f5b9d22-6edf-4b2b-a7e7-2b634e259061	B	$C_v = R/(x - 1)$	1	\N
2b294460-d341-499d-b94a-070cc5e41a72	3f5b9d22-6edf-4b2b-a7e7-2b634e259061	C	$C_v = R/(1 - x)$	2	\N
b65719a4-ae74-4a1d-b97e-f54d19897d55	3f5b9d22-6edf-4b2b-a7e7-2b634e259061	D	$C_v = R/(1 + R)$	3	\N
eb249c2a-3e5b-4e98-b621-6aea87550a4f	b5a6e81f-c016-4964-8cc9-cd77e4ec8fa3	A	$KT/2$	0	\N
a5afda07-ec91-43df-bbcd-0bb559f87316	b5a6e81f-c016-4964-8cc9-cd77e4ec8fa3	B	$KT$	1	\N
6ed36459-aca8-4f79-97bd-cf7a18cfadd1	b5a6e81f-c016-4964-8cc9-cd77e4ec8fa3	C	$3KT/2$	2	\N
da283e36-b70f-4213-87d1-4d4e51a78c69	b5a6e81f-c016-4964-8cc9-cd77e4ec8fa3	D	$5KT/2$	3	\N
58f522e8-5185-40ed-a86f-f2e3b6dc3923	234ce33d-2f3e-44da-bb27-cb3c7539c50f	A	বৃদ্ধি পায়	0	\N
d29cf91b-0cf5-46d7-a629-d85cdb879094	234ce33d-2f3e-44da-bb27-cb3c7539c50f	B	অপরিবর্তিত থাকে	1	\N
0e8b30a2-c9da-4f54-9507-ca39b95d39ac	234ce33d-2f3e-44da-bb27-cb3c7539c50f	C	কমতে থাকবে	2	\N
3bac7caf-44e8-4f51-8c9e-dbab6427a8ea	234ce33d-2f3e-44da-bb27-cb3c7539c50f	D	বলা সম্ভব নয়	3	\N
76a22bc7-b4e3-49a9-96e2-ab8c58488c1d	41a0acaa-dbdc-4719-9b7f-f796e1a8db5f	A	$4$	0	\N
20102fb2-bdb8-4cd0-9700-97a561d62a09	41a0acaa-dbdc-4719-9b7f-f796e1a8db5f	B	$2$	1	\N
88657e37-ef79-4c5b-a0b3-8fb01b5fed53	41a0acaa-dbdc-4719-9b7f-f796e1a8db5f	C	$1.41$	2	\N
839d0e67-b354-40f6-8edc-e76209533ebb	41a0acaa-dbdc-4719-9b7f-f796e1a8db5f	D	$0.5$	3	\N
f9081427-df22-4a95-b4f4-5d7b5b5d836c	816a0061-1e82-44b0-8914-79a1931908fd	A	X-ray	0	\N
5970380f-2b7a-4c3c-805a-f848961dd4eb	816a0061-1e82-44b0-8914-79a1931908fd	B	Radio Wave	1	\N
f0fe1e94-6ebb-452a-8cd8-cb6136dc93d1	816a0061-1e82-44b0-8914-79a1931908fd	C	Sound Wave	2	\N
38b1f89e-7d9a-4f48-a61a-f4aa4478d379	816a0061-1e82-44b0-8914-79a1931908fd	D	Ultra-Violet	3	\N
dde5664d-5cd6-41ff-92ee-0911c27648dd	39913432-08d3-4da1-8101-76555b68789f	A	$T$	0	\N
14b291d9-1fd5-4403-8568-da1b210f4295	39913432-08d3-4da1-8101-76555b68789f	B	$2T$	1	\N
b9c93d07-e21e-46fb-90c5-586f02e4b534	39913432-08d3-4da1-8101-76555b68789f	C	$T/2$	2	\N
55e60563-f09c-4906-be92-ae3928a03ab7	39913432-08d3-4da1-8101-76555b68789f	D	$4T$	3	\N
23bcda30-a22d-47cd-8c04-9ca5f2e098d1	cf30506d-2b21-48ac-ab56-f21bdea377c6	A	$\\lambda/8$	0	\N
7b0301e1-0d7e-4d58-83ad-6052e258c1de	cf30506d-2b21-48ac-ab56-f21bdea377c6	B	$3\\lambda/4$	1	\N
226ac3dc-df06-44f0-bf35-e74289be6c37	cf30506d-2b21-48ac-ab56-f21bdea377c6	C	$\\lambda/4$	2	\N
04e7f30f-c431-46a0-8a85-44b1a6217fea	cf30506d-2b21-48ac-ab56-f21bdea377c6	D	$\\lambda/2$	3	\N
2003d76c-bf8f-4bf8-9457-1dcfd8ffe9d1	7452052d-1c3d-4aa8-8fcd-e58556513248	A	$(1100000)_2$	0	\N
7a3604f1-c090-47ed-a8a5-710596d772e2	7452052d-1c3d-4aa8-8fcd-e58556513248	B	$(1010101)_2$	1	\N
9e8d3871-0061-4631-93f9-1357aaa957e1	7452052d-1c3d-4aa8-8fcd-e58556513248	C	$(1000010)_2$	2	\N
3507024c-4ce0-4171-88a7-febae06e681d	7452052d-1c3d-4aa8-8fcd-e58556513248	D	$(1111111)_2$	3	\N
758899fa-77e5-498b-817f-d3936eac0bb5	6b90fb4c-402a-49a3-95a2-75d1eb435bea	A	শূন্য মাধ্যমে ফোটন আলোর বেগে চলে	0	\N
e5574b0d-e601-48fa-bbcc-1f1dcb7b478f	6b90fb4c-402a-49a3-95a2-75d1eb435bea	B	ফোটনের ভরবেগ ও শক্তি নেই	1	\N
82181054-f217-485a-a5c6-7e87c27d30f9	6b90fb4c-402a-49a3-95a2-75d1eb435bea	C	ফোটন কণা এবং তরঙ্গ উভয় ধর্ম প্রদর্শন করতে পারে	2	\N
2f430be0-8438-42b0-984c-8e7bee0b22ff	6b90fb4c-402a-49a3-95a2-75d1eb435bea	D	ফোটনের ভর শূন্য	3	\N
88094cf4-9655-40c4-8d07-ee62e5348c88	18cb2450-e0d6-41d9-87b7-d55e28876177	A	$100\\,\\text{Hz}$ & $14.14\\,\\text{A}$	0	\N
80a0598a-70f1-4fad-a10a-897a49d99581	18cb2450-e0d6-41d9-87b7-d55e28876177	B	$200\\,\\text{Hz}$ & $15\\,\\text{A}$	1	\N
efd45295-0c75-43ef-8cf2-7d0a830498bd	18cb2450-e0d6-41d9-87b7-d55e28876177	C	$100\\,\\text{Hz}$ and $20\\,\\text{A}$	2	\N
85a9aa2f-f273-4284-ad1d-f56a6ea9a990	18cb2450-e0d6-41d9-87b7-d55e28876177	D	$50\\,\\text{Hz}$ and $14.14\\,\\text{A}$	3	\N
ddd1fb90-2cb7-4bdb-affe-8c8b57634362	ab80055d-216e-4731-926d-e2edebe712a0	A	$2 \\times 10^{-5}\\,\\text{T}$	0	\N
55b78222-2077-42db-a5de-eaa59e04f4ce	ab80055d-216e-4731-926d-e2edebe712a0	B	$4 \\times 10^{-6}\\,\\text{T}$	1	\N
b32429ec-6fd0-47b6-89f4-7cd51c47b416	ab80055d-216e-4731-926d-e2edebe712a0	C	$10^{-8}\\,\\text{T}$	2	\N
c5d3ba65-4f05-493f-a0f4-7d701ac8a508	ab80055d-216e-4731-926d-e2edebe712a0	D	$7 \\times 10^{-6}\\,\\text{T}$	3	\N
4201cd06-93fe-4888-a8c0-8c42d216fff4	7e95694e-7ce3-4768-b194-baf73df330b4	A	$E$	0	\N
31d91151-7068-4d18-88e2-346836ee1160	7e95694e-7ce3-4768-b194-baf73df330b4	B	$2E$	1	\N
3c8e7169-a427-4f1a-8a29-737cdabfe178	7e95694e-7ce3-4768-b194-baf73df330b4	C	$4E$	2	\N
ffbef0a3-6b31-4a10-9db1-60bf0fb50efc	7e95694e-7ce3-4768-b194-baf73df330b4	D	$E/2$	3	\N
0d6c2d99-fc08-4e19-840f-4cd0fa1d753a	1f71e2ec-348b-4269-9503-e39e1cc6db2c	A	$4\\,\\text{N}$	0	\N
d6f1aca3-06ed-4179-8126-e7d77f0ebdac	1f71e2ec-348b-4269-9503-e39e1cc6db2c	B	$0.04\\,\\text{N}$	1	\N
0600d821-ec3f-405b-9181-090f393d5170	1f71e2ec-348b-4269-9503-e39e1cc6db2c	C	$25\\,\\text{N}$	2	\N
7c02edb6-d8bd-41e5-ba7e-ec48a9ee6c15	1f71e2ec-348b-4269-9503-e39e1cc6db2c	D	$40\\,\\text{N}$	3	\N
4105ed9a-03ec-4a8d-a4ac-5f4531bfbcc2	568b2bc9-9a19-44c0-8b8b-8d0045475282	A	পূর্বের সমান থাকবে	0	\N
19cdc2d5-37b3-457a-8250-f69917180c61	568b2bc9-9a19-44c0-8b8b-8d0045475282	B	পূর্বের তিনগুণ হবে	1	\N
023d876c-1872-48fe-82ff-87984bd1fe40	568b2bc9-9a19-44c0-8b8b-8d0045475282	C	পূর্বের দ্বিগুণ হবে	2	\N
bdbc52cd-5da6-4892-b99a-c72721fe41a9	568b2bc9-9a19-44c0-8b8b-8d0045475282	D	পূর্বের দেড়গুণ হবে	3	\N
c12f27a2-305f-4048-8ae5-cb39f66a2730	87e60be5-0a87-45da-ad2f-f8266e80c18c	A	$^{214}\\text{Po}(Z=84)$	0	\N
e5e12f71-a960-49c9-a0e4-5a871d3d9ba3	87e60be5-0a87-45da-ad2f-f8266e80c18c	B	$^{210}\\text{Pb}(Z=82)$	1	\N
962c7282-848f-4799-a7a5-a8768ee00e7e	87e60be5-0a87-45da-ad2f-f8266e80c18c	C	$^{214}\\text{At}(Z=85)$	2	\N
5270dceb-984d-4fc8-b51d-eec1e4501b29	87e60be5-0a87-45da-ad2f-f8266e80c18c	D	$^{210}\\text{Bi}(Z=83)$	3	\N
8c29ed2d-dac2-43b7-b40d-f5de74309af8	08a035f1-feef-4d5b-8017-ef1773ce0f4d	A	[IMAGE_1]	0	p02_q25_01.png
fd73a9f3-7349-4753-a79f-a1f13819dcf6	08a035f1-feef-4d5b-8017-ef1773ce0f4d	B	[IMAGE_2]	1	p02_q25_02.png
40987f4e-2549-4cca-85c7-0bd184534ce5	08a035f1-feef-4d5b-8017-ef1773ce0f4d	C	[IMAGE_3]	2	p02_q25_03.png
e6168bcf-de03-4323-94dd-b3aef5218fe6	08a035f1-feef-4d5b-8017-ef1773ce0f4d	D	[IMAGE_4]	3	p02_q25_04.png
246ae583-8c89-41ad-b618-58cc829ccf4c	a360f901-de88-4d26-8f31-c16713d3b6da	A	$\\sqrt{(2gR)}$	0	\N
5a54e858-5626-4bd5-a6d8-83afb1f15c7c	a360f901-de88-4d26-8f31-c16713d3b6da	B	$\\sqrt{(2)gR}$	1	\N
6577a861-b51f-4054-a6ca-a36f669bcafd	a360f901-de88-4d26-8f31-c16713d3b6da	C	$gR$	2	\N
027ab055-d5b4-4875-93a6-805286ce1768	a360f901-de88-4d26-8f31-c16713d3b6da	D	$2\\sqrt{(gR)}$	3	\N
028daefb-8908-450b-878d-4f63469c73b3	c20cf417-98d4-41eb-8914-7e4e3f45fa83	A	$1.2 \\times 10^2\\,\\text{m/s}$	0	\N
b7957ada-2fb8-4645-8c15-4cd1b8167922	c20cf417-98d4-41eb-8914-7e4e3f45fa83	B	$1.2 \\times 10^3\\,\\text{m/s}$	1	\N
344cf64b-8034-49ea-9a62-fd4252cbcf31	c20cf417-98d4-41eb-8914-7e4e3f45fa83	C	$2.4 \\times 10^2\\,\\text{m/s}$	2	\N
b95170d0-8b14-4b6a-a0c7-c0777561b4d3	c20cf417-98d4-41eb-8914-7e4e3f45fa83	D	$1.9 \\times 10^2\\,\\text{m/s}$	3	\N
5a8a63a7-3803-4350-84ad-e1e3102bf020	b51e5ec8-ad46-46b5-b689-d5e8a977463e	A	$35^\\circ$	0	\N
0cb16cc1-8df4-4eb7-8944-813801c8aead	b51e5ec8-ad46-46b5-b689-d5e8a977463e	B	$40^\\circ$	1	\N
cad78b20-a9ce-43bd-a0b7-e188e937bed5	b51e5ec8-ad46-46b5-b689-d5e8a977463e	C	$30^\\circ$	2	\N
94727a3e-cd45-4f77-b4ca-104903e594c2	b51e5ec8-ad46-46b5-b689-d5e8a977463e	D	$45^\\circ$	3	\N
76cb523d-e81d-447a-8c3e-8694a661e0df	d254c27e-6371-48b8-96a2-4f5407502a92	A	$-6.8\\,\\text{eV}$	0	\N
e135bc43-60b4-49f8-afa0-d5e098b4862c	d254c27e-6371-48b8-96a2-4f5407502a92	B	$-3.4\\,\\text{eV}$	1	\N
3e40d9b6-cb80-4222-ad73-63d7a943dedb	d254c27e-6371-48b8-96a2-4f5407502a92	C	$-27.2\\,\\text{eV}$	2	\N
93e3c78b-7de7-4433-8808-8aa0ee0973dc	d254c27e-6371-48b8-96a2-4f5407502a92	D	$-4.7\\,\\text{eV}$	3	\N
33e0bb22-06e7-413a-bce2-e0c5cea9ef1f	004f4b76-a500-47d3-a015-235e0717205b	A	$14\\,\\text{MPC}$	0	\N
9ed591f2-2017-4cd6-a139-60f6fb002bdd	004f4b76-a500-47d3-a015-235e0717205b	B	$77\\,\\text{MPC}$	1	\N
e0fda347-f3ab-434b-9ae0-bb76e4693818	004f4b76-a500-47d3-a015-235e0717205b	C	$55\\,\\text{MPC}$	2	\N
cc5f6488-c499-4db2-aaad-56a8d0271b01	004f4b76-a500-47d3-a015-235e0717205b	D	$28\\,\\text{MPC}$	3	\N
c48110e9-fafe-46d7-aa30-4c92320e5530	88a8f4c9-ea06-4842-9c1d-97e855a3d71f	A	$K_p = K_c(RT)^{-1}$	0	\N
703271ce-1189-4485-952a-711615138ef6	88a8f4c9-ea06-4842-9c1d-97e855a3d71f	B	$K_p = K_c(RT)^{-2}$	1	\N
5bf9bbb9-0002-41b8-a40b-15447887e42a	88a8f4c9-ea06-4842-9c1d-97e855a3d71f	C	$K_p = K_c$	2	\N
a0d24a17-908b-4c94-9c96-5fa4defdb29e	88a8f4c9-ea06-4842-9c1d-97e855a3d71f	D	$K_p = K_c(RT)^2$	3	\N
3ac45117-8ca7-4274-a6ed-45477d09c1f1	efe882a1-b0e9-451d-9053-921f352fa936	A	$\\ce{CH3X > RCH2X > R2CHX > R3CX}$	0	\N
efc78b0c-4e00-4400-9121-899f5b8cb10e	efe882a1-b0e9-451d-9053-921f352fa936	B	$\\ce{RCH2X > CH3X > R2CHX > R3CX}$	1	\N
691b4801-0e78-4528-80ad-0ba0bdff6cc4	efe882a1-b0e9-451d-9053-921f352fa936	C	$\\ce{CH3X > RCH2X > R3CX > R2CHX}$	2	\N
b71e09f2-d209-4646-9e1f-08cae0291701	efe882a1-b0e9-451d-9053-921f352fa936	D	$\\ce{R3CX > R2CHX > RCH2X > CH3X}$	3	\N
1619cfdd-21d0-41ac-9296-fb3394172e1b	1278d559-feee-4b48-aa97-24292f1da1ee	A	$\\ce{-CH3}$	0	\N
fd43b332-6cee-4ab7-ad9f-2ab05712579c	1278d559-feee-4b48-aa97-24292f1da1ee	B	$\\ce{-COOH}$	1	\N
69b8a3b6-4fd2-40bf-b6e0-77ed0aa86ac9	1278d559-feee-4b48-aa97-24292f1da1ee	C	$\\ce{-CHO}$	2	\N
c7c1714d-fc43-48db-85ad-1423b6c80585	1278d559-feee-4b48-aa97-24292f1da1ee	D	$\\ce{-Cl}$	3	\N
e5063882-1567-4ca1-83d0-da79d85d93be	91988d5e-0978-4f79-83f7-3a2de7a2733e	A	$\\ce{NaOH(aq) + HCl(aq)}$	0	\N
a7af939d-144e-46ef-b800-b71acd013b64	91988d5e-0978-4f79-83f7-3a2de7a2733e	B	$\\ce{Na^+(aq) + Cl^-(aq)}$	1	\N
3c749c97-3b91-4e8b-b226-45fac09b8d46	91988d5e-0978-4f79-83f7-3a2de7a2733e	C	$\\ce{NaOH(aq) + Cl2(g)}$	2	\N
9e797ac5-5c20-4ee3-a537-104b41a571a0	91988d5e-0978-4f79-83f7-3a2de7a2733e	D	$\\ce{OH^+(aq) + Cl^-(aq)}$	3	\N
26e4fdef-2c66-45da-bca4-ae581c446aa7	8f713ee6-5884-42e5-8d02-4107e2eefdc5	A	$-173.0\\,\\text{kJ mol}^{-1}$	0	\N
9fdb8541-7160-41d7-b147-7b0d4989ae6e	8f713ee6-5884-42e5-8d02-4107e2eefdc5	B	$-394.0\\,\\text{kJ mol}^{-1}$	1	\N
de09e9d4-7550-4dba-abc7-b60334e44d76	8f713ee6-5884-42e5-8d02-4107e2eefdc5	C	$373.0\\,\\text{kJ mol}^{-1}$	2	\N
771f26de-e606-4e21-9198-96dada701941	8f713ee6-5884-42e5-8d02-4107e2eefdc5	D	$394.0\\,\\text{kJ mol}^{-1}$	3	\N
7d23044f-1ca0-4f9b-a747-80092bf6c33e	b3b4ac18-4ccf-4541-8660-a40bd7ffc907	A	An enzyme	0	\N
bbac97e6-2e15-4b86-b11a-76929dd9a37e	b3b4ac18-4ccf-4541-8660-a40bd7ffc907	B	A non-caloric sweetener	1	\N
265430c5-ab03-455c-b4df-d528dfd694bf	b3b4ac18-4ccf-4541-8660-a40bd7ffc907	C	An amino acid	2	\N
080e4c1c-e820-4b66-8c60-bd6bcd0c1e42	b3b4ac18-4ccf-4541-8660-a40bd7ffc907	D	An anti-oxidant	3	\N
18752f4f-04d1-4a57-bca6-2fa8357cbccb	2eadfc9d-ff57-4f49-b710-3bbdcabc99ee	A	35.5	0	\N
866ae1db-e2ac-4697-afde-9e11fd02e63d	2eadfc9d-ff57-4f49-b710-3bbdcabc99ee	B	1.0	1	\N
8794eee4-5b2a-4706-8e43-3e9fb3c72e3b	2eadfc9d-ff57-4f49-b710-3bbdcabc99ee	C	55.5	2	\N
3d220a7e-dbb3-43d2-8adb-0e99c530de2b	2eadfc9d-ff57-4f49-b710-3bbdcabc99ee	D	18.0	3	\N
8c8fb8d4-52d8-475e-9e6c-8ec1ff1532d4	b071fb5e-2247-45f5-940a-d6c959acaa5a	A	$\\ce{HClO4 > HNO3 > H2SO3 > H2SO4}$	0	\N
9b157268-4f38-4795-9582-ffa765efb5d5	b071fb5e-2247-45f5-940a-d6c959acaa5a	B	$\\ce{HNO3 > H2SO3 > H2SO4 > HClO4}$	1	\N
66c390c5-6e1f-4407-93fb-d60a9cf173a0	b071fb5e-2247-45f5-940a-d6c959acaa5a	C	$\\ce{H2SO3 > H2SO4 > HClO4 > HNO3}$	2	\N
6f7107d8-3f2c-445c-a157-d439fa08c260	b071fb5e-2247-45f5-940a-d6c959acaa5a	D	$\\ce{HClO4 > H2SO4 > HNO3 > H2SO3}$	3	\N
cea03ddb-7139-4220-a0ba-556c5e07dbcf	f2d50c47-9e08-413b-90c8-863ea371ef25	A	$\\ce{H3C^+}$	0	\N
e83df460-2399-486f-bcab-00f97c48ee06	f2d50c47-9e08-413b-90c8-863ea371ef25	B	$\\ce{(CH3)2HC^+}$	1	\N
1733b9ae-4d1c-41e4-a0dd-15a3eeb990a9	f2d50c47-9e08-413b-90c8-863ea371ef25	C	$\\ce{H3C-H2C^+}$	2	\N
e1779918-46c6-4c37-917e-06ba563e00d3	f2d50c47-9e08-413b-90c8-863ea371ef25	D	$\\ce{(CH3)3C^+}$	3	\N
a3bdd8cd-6add-40c0-939f-65951017022b	99bd16c8-681e-4cd7-95ea-a6d206a4561f	A	Na	0	\N
684ccb88-76ec-4657-a903-418e96758300	99bd16c8-681e-4cd7-95ea-a6d206a4561f	B	K	1	\N
1e66b27a-a5a4-45cc-9d65-50ef20896a14	99bd16c8-681e-4cd7-95ea-a6d206a4561f	C	Rb	2	\N
c10d3485-69d2-49d6-bae4-5a4b465a1b2a	99bd16c8-681e-4cd7-95ea-a6d206a4561f	D	Cs	3	\N
2d3281df-e058-40fa-b617-fa1701c46d91	66b92bce-847f-4ec9-a9d5-e5622d0e8600	A	UV-radiation	0	\N
574d5292-2dff-42b7-856e-e172682beece	66b92bce-847f-4ec9-a9d5-e5622d0e8600	B	CFC-12	1	\N
1f6d6561-db10-42af-947b-3963f253fadb	66b92bce-847f-4ec9-a9d5-e5622d0e8600	C	$\\ce{\\cdot Cl}$	2	\N
82ae44ca-0be2-4478-bd12-f767ea851571	66b92bce-847f-4ec9-a9d5-e5622d0e8600	D	CO	3	\N
67268ec7-cb6d-4978-a31f-091a0949b36c	a997c0bd-b964-4ebf-87ba-b0539efb4f82	A	$3/4\\,R_H$	0	\N
b35f1113-209d-499f-b8a9-aace54f92e47	a997c0bd-b964-4ebf-87ba-b0539efb4f82	B	$5/36\\,R_H$	1	\N
e58026e8-76de-4ce6-8a28-9069ffd99769	a997c0bd-b964-4ebf-87ba-b0539efb4f82	C	$8/9\\,R_H$	2	\N
d3bcf51b-27d2-41e7-94e2-31a33fb89e8c	a997c0bd-b964-4ebf-87ba-b0539efb4f82	D	$9/144\\,R_H$	3	\N
7a7a3ed5-e4c2-4807-9f80-686da96ea9dc	4e250e2d-3679-451d-92f3-b8a35ff1aabe	A	Super-Saturated	0	\N
8a319176-d19f-4e4f-a0f2-94c036f028b7	4e250e2d-3679-451d-92f3-b8a35ff1aabe	B	Unsaturated	1	\N
bc8b023b-c798-4ee0-89a0-2986f9bf8f55	4e250e2d-3679-451d-92f3-b8a35ff1aabe	C	Saturated	2	\N
59844b55-1809-45aa-b057-29dceff3f8fe	4e250e2d-3679-451d-92f3-b8a35ff1aabe	D	All of them	3	\N
23c2014f-1d96-4c45-bfd6-a6f7311c7e1e	9338ff51-8319-4d75-9b12-115fa40ad7d5	A	9,2	0	\N
972ea1f1-cf6b-4f4f-9193-c70315d9f7e6	9338ff51-8319-4d75-9b12-115fa40ad7d5	B	8,4	1	\N
de34fb41-ec70-4b3e-8c7b-570ba4afc62c	9338ff51-8319-4d75-9b12-115fa40ad7d5	C	10,1	2	\N
a17c3a14-09e8-4003-9b2c-938bab78c6a4	9338ff51-8319-4d75-9b12-115fa40ad7d5	D	10,2	3	\N
71f4b87f-8c24-4aad-a79b-9535bdbf9ea8	e14decef-c912-4c67-9a74-6e228482bdf0	A	Catalyst only	0	\N
e15e3179-81e7-4422-92a0-fb2f38e8c503	e14decef-c912-4c67-9a74-6e228482bdf0	B	Temperature only	1	\N
3215146c-9a5d-4239-846d-77fbca5c89de	e14decef-c912-4c67-9a74-6e228482bdf0	C	Pressure only	2	\N
bc381a28-f5c3-44c4-93e5-55484306dbf6	e14decef-c912-4c67-9a74-6e228482bdf0	D	Temperature, pressure and catalyst	3	\N
1e14176c-969c-4b53-ad2c-d04bd0221b46	effc303c-be0b-4ab5-b77b-8c5782cbca48	A	Butan-1-ol	0	\N
44a96af7-41ef-47ca-b589-58192c9e9ab4	effc303c-be0b-4ab5-b77b-8c5782cbca48	B	Butan-2-ol	1	\N
47d5f22d-a142-4369-beb7-fe971ac0f811	effc303c-be0b-4ab5-b77b-8c5782cbca48	C	2-methylpropan-1-ol	2	\N
3212df0c-0c8f-48b4-b9ac-2b509f2ff928	effc303c-be0b-4ab5-b77b-8c5782cbca48	D	2-methylpropan-2-ol	3	\N
f3f82e45-bfe4-47d9-80f8-e304320138f0	188e8474-d1f9-4b24-bc07-8c165de8c238	A	Benzene diazonium chloride	0	\N
4176f100-af2a-4f37-8833-1941a99c5f1c	188e8474-d1f9-4b24-bc07-8c165de8c238	B	Chlorobenzene	1	\N
78a6d16f-9557-4293-9085-0a1452ac4b3e	188e8474-d1f9-4b24-bc07-8c165de8c238	C	Nitrobenzene	2	\N
f2272a3a-35fe-4bfc-b18d-40146111745d	188e8474-d1f9-4b24-bc07-8c165de8c238	D	Phenol	3	\N
80053c1e-24ef-4f03-a262-ebb4d1a81177	79a79fe2-b88e-4109-a379-20fbd6f9bee8	A	$\\ce{KNO3}$	0	\N
87b0a56f-352a-4c9f-b971-880bcd929f0e	79a79fe2-b88e-4109-a379-20fbd6f9bee8	B	$\\ce{KI}$	1	\N
4a200bc2-5ac0-4e99-99f2-d135aaddbf98	79a79fe2-b88e-4109-a379-20fbd6f9bee8	C	$\\ce{KBr}$	2	\N
451bf041-7ae1-4ca9-9e90-e21b99eaa05a	79a79fe2-b88e-4109-a379-20fbd6f9bee8	D	$\\ce{KCl}$	3	\N
464554fa-e2b6-4828-a668-01db23e5ea81	54359da1-92d6-4bbc-a95c-006986f8aa6a	A	$\\ce{CO2}$	0	\N
7ec6b843-5a41-4b4f-95ab-79e37ead1048	54359da1-92d6-4bbc-a95c-006986f8aa6a	B	$\\ce{SO2}$	1	\N
e782b8b9-8404-468c-b8af-1523ce5d3963	54359da1-92d6-4bbc-a95c-006986f8aa6a	C	$\\ce{H2O}$	2	\N
426c293b-bd81-4510-9f98-1686ec45af5a	54359da1-92d6-4bbc-a95c-006986f8aa6a	D	$\\ce{CH2O}$	3	\N
447b88be-e2b9-45fb-b871-516f8330178c	160d3d55-632b-4eae-9f49-b71e561af0ef	A	5.5	0	\N
311db14b-7768-42f0-8221-093a45da36e3	160d3d55-632b-4eae-9f49-b71e561af0ef	B	7.0	1	\N
e909208d-12c3-4f79-a906-3d7b5da69b97	160d3d55-632b-4eae-9f49-b71e561af0ef	C	8.5	2	\N
5512d4fc-dfba-4aaa-abf0-3c066a533a7c	160d3d55-632b-4eae-9f49-b71e561af0ef	D	3.0	3	\N
b31ef641-c8ef-4d8d-b366-71dff62653c9	34a58ff5-146c-4b24-ab31-b496aa336d65	A	1,2-methyl-4-butyl benzene	0	\N
6c6c6ac1-ef2a-4668-bdf6-1dff9038fc6f	34a58ff5-146c-4b24-ab31-b496aa336d65	B	1-butyl-3,4-dimethyl benzene	1	\N
91e2cf83-ca08-441c-a448-365a0f561140	34a58ff5-146c-4b24-ab31-b496aa336d65	C	1,2,4-dimethyl butyl benzene	2	\N
683cb428-375d-4962-a55e-de06449fd8a9	34a58ff5-146c-4b24-ab31-b496aa336d65	D	methyl butyl benzene	3	\N
88a04a2f-ad65-431a-82a2-a8bfc041a75e	4ad10a1c-f759-44fc-b122-a342e5345a2d	A	Methane	0	\N
1bc6b630-4b09-45d2-8905-e4e1544e93d5	4ad10a1c-f759-44fc-b122-a342e5345a2d	B	Ethane	1	\N
064779d9-8664-4881-a33f-dab9b407e990	4ad10a1c-f759-44fc-b122-a342e5345a2d	C	Butane	2	\N
6da1beb3-2a9b-475f-a867-39f4b2287041	4ad10a1c-f759-44fc-b122-a342e5345a2d	D	Pentane	3	\N
d1c2becf-5862-4908-b4bc-b0136a9adcad	b608c211-3a82-452f-a440-f03381ff6cdb	A	Ethanol	0	\N
95d54589-072b-416d-bb5c-6228f533e534	b608c211-3a82-452f-a440-f03381ff6cdb	B	Ethanoic acid	1	\N
2d7d47ee-45e4-482f-b2b6-b0472b8baeb5	b608c211-3a82-452f-a440-f03381ff6cdb	C	Water	2	\N
a50278a8-3074-474b-a519-32da3ed6830a	b608c211-3a82-452f-a440-f03381ff6cdb	D	Ammonia	3	\N
68508b31-551c-4ea4-92a6-cb59c63109dd	8d2ee9f7-696c-415b-a8aa-3d97e0bd4a8f	A	Copper	0	\N
8ffca3f8-504c-4495-8062-6d0cdb97c75a	8d2ee9f7-696c-415b-a8aa-3d97e0bd4a8f	B	Chromium	1	\N
b48b3ce9-1d17-48f7-922b-68af0e3f1c34	8d2ee9f7-696c-415b-a8aa-3d97e0bd4a8f	C	Sodium	2	\N
142a820f-d26a-42ef-b579-60d80e23850a	8d2ee9f7-696c-415b-a8aa-3d97e0bd4a8f	D	Calcium	3	\N
3b2a40d3-a04f-49da-bc06-744b213d2882	65ea1367-817f-45f1-925c-f07d4ff78c1c	A	Sn is oxidized	0	\N
61d09f45-a870-4e29-a042-1b227d852da7	65ea1367-817f-45f1-925c-f07d4ff78c1c	B	Cl is oxidized	1	\N
5db3de5b-3ed5-40fe-98be-46477180a169	65ea1367-817f-45f1-925c-f07d4ff78c1c	C	Fe is oxidized	2	\N
b47e75ab-fc7d-41e1-a78d-93af4aae0a4e	65ea1367-817f-45f1-925c-f07d4ff78c1c	D	Cl is reduced	3	\N
42ce917f-3b9e-48ce-b1c1-f3999c62bcff	d4c961fd-e7c3-41c4-bfe0-b0947b6b1791	A	$\\ce{H2 < N2 < CO2 < NH3}$	0	\N
55ab05b7-6ca7-488d-8094-881e317b0a1f	d4c961fd-e7c3-41c4-bfe0-b0947b6b1791	B	$\\ce{H2 < NH3 < N2 < CO2}$	1	\N
3a4c12a7-7e43-455e-af3e-c822fdcaea7b	d4c961fd-e7c3-41c4-bfe0-b0947b6b1791	C	$\\ce{CO2 > NH3 > H2 > N2}$	2	\N
eb3f1bd1-6c09-4424-a236-8ae27774a177	d4c961fd-e7c3-41c4-bfe0-b0947b6b1791	D	$\\ce{N2 > H2 > CO2 > NH3}$	3	\N
a29bae5f-c0b1-4d2c-83ab-31824199b289	28e2553a-c7f2-4662-813d-c9e9226da0f1	A	Na	0	\N
13acc1db-7eda-4419-bbe6-a280b62802ad	28e2553a-c7f2-4662-813d-c9e9226da0f1	B	$\\ce{Cl2}$	1	\N
55a3ab94-6392-45e8-a4b8-2166747e6086	28e2553a-c7f2-4662-813d-c9e9226da0f1	C	$\\ce{H2}$	2	\N
f3f71dbe-28e0-4108-b59e-305ee82bfe17	28e2553a-c7f2-4662-813d-c9e9226da0f1	D	NaOH	3	\N
09f7bc1b-36c1-4f43-8c16-7e8009bae712	2777ffa1-e79a-4e69-8144-3e4b14159177	A	Pipette and beaker	0	\N
7a7ab0d7-15b9-444b-b178-26e2add978dc	2777ffa1-e79a-4e69-8144-3e4b14159177	B	Burette and reagent bottle	1	\N
01f54e10-14c1-4612-ac05-e5e111d375e3	2777ffa1-e79a-4e69-8144-3e4b14159177	C	Pipette and burette	2	\N
93c787c3-e4b3-4f05-8971-6734d5a5503c	2777ffa1-e79a-4e69-8144-3e4b14159177	D	Graduated pipette and conical flask	3	\N
e5219f69-18d4-4c17-bba4-8a64bfadd398	837b9a9e-058a-4d0c-ab74-739f69655f67	A	Nitrogen	0	\N
e358415f-fab4-45b6-9715-2e7a389cf450	837b9a9e-058a-4d0c-ab74-739f69655f67	B	phosphorus	1	\N
33050ca4-8e4e-4c27-9baa-1ee6395310bb	837b9a9e-058a-4d0c-ab74-739f69655f67	C	sulphur	2	\N
32cdd96b-94d9-47e9-8b91-1ce74e8651e7	837b9a9e-058a-4d0c-ab74-739f69655f67	D	Oxygen	3	\N
f50b4dd1-c7c3-41ee-9938-203f87a5406d	2e739d1c-0a19-4655-acd6-3c0afdac88f7	A	$\\ce{Al2O3.2SiO2.2H2O}$	0	\N
0cd426d2-4a9a-41f5-bca6-372cd9d8b44a	2e739d1c-0a19-4655-acd6-3c0afdac88f7	B	$\\ce{Al2O3.3SiO2.H2O}$	1	\N
a1a1ecba-b944-4245-9884-b769c6132570	2e739d1c-0a19-4655-acd6-3c0afdac88f7	C	$\\ce{Al2O3.2SiO2.3H2O}$	2	\N
ca5f7286-c761-4bbc-9dc7-73c4e73b8290	2e739d1c-0a19-4655-acd6-3c0afdac88f7	D	$\\ce{K2O.Al2O3.6SiO2}$	3	\N
2b049a6c-fa55-4322-ad84-5d4227439035	90f4458e-db6a-42a5-974f-e7838ff95383	A	$\\frac{\\pi}{6}, \\frac{\\pi}{3}$	0	\N
dad7a52a-f3dd-4b6c-a6e1-5fcfc5b9dc9b	90f4458e-db6a-42a5-974f-e7838ff95383	B	$\\frac{\\pi}{4}, \\frac{\\pi}{3}$	1	\N
f5d1b0d3-d623-4cd6-8f36-39908850faec	90f4458e-db6a-42a5-974f-e7838ff95383	C	$\\frac{\\pi}{3}, \\frac{\\pi}{5}$	2	\N
d1efc37d-05c4-4ad5-b99f-3eac8c5ecbf6	90f4458e-db6a-42a5-974f-e7838ff95383	D	$\\frac{\\pi}{6}, \\frac{\\pi}{4}$	3	\N
b0358197-3282-4d1a-8890-9a59f624e1c3	00a8153e-8901-4f13-8ded-a2f2e4e13ffe	A	$(\\frac{3\\sqrt{3}}{2}, \\frac{3}{2})$	0	\N
87e33b4a-88f0-433b-8637-598eceb60276	00a8153e-8901-4f13-8ded-a2f2e4e13ffe	B	$(\\frac{3\\sqrt{3}}{2}, -\\frac{3}{2})$	1	\N
5832a1bd-f9ef-4920-b9a8-b3ebdf064157	00a8153e-8901-4f13-8ded-a2f2e4e13ffe	C	$(-\\frac{3\\sqrt{3}}{2}, \\frac{3}{2})$	2	\N
254d3442-6b91-4933-91f0-997f2737115a	00a8153e-8901-4f13-8ded-a2f2e4e13ffe	D	$(-\\frac{3\\sqrt{3}}{2}, -\\frac{3}{2})$	3	\N
264549b4-a902-4400-bf9a-e17648bd034b	64013a8d-e3f5-4db2-94af-1521227c85f1	A	1	0	\N
fb16224a-21e8-43bd-a373-7f30d36bd521	64013a8d-e3f5-4db2-94af-1521227c85f1	B	$2\\sqrt{2}$	1	\N
1219c144-e211-49b8-8109-3002df2a5dec	64013a8d-e3f5-4db2-94af-1521227c85f1	C	3	2	\N
921190f3-8645-4b61-9d02-b1e8c09c42f4	64013a8d-e3f5-4db2-94af-1521227c85f1	D	4	3	\N
74bd1b57-c91a-4bd9-a1b3-94e9c49bb0b2	280db66c-4465-492b-be96-2df7528ac624	A	$\\frac{85}{36}$	0	\N
ca3a0e2a-dd54-43f1-a04d-3f5b7ceed1d1	280db66c-4465-492b-be96-2df7528ac624	B	$\\frac{36}{85}$	1	\N
39501abd-8a18-401d-822b-dc0b8e5aa536	280db66c-4465-492b-be96-2df7528ac624	C	$\\frac{10}{9}$	2	\N
6da44d96-8d82-44e4-a71b-07dca3ae7bdf	280db66c-4465-492b-be96-2df7528ac624	D	$\\frac{9}{10}$	3	\N
fc9dc845-5411-483e-904f-d027067da996	3ff2320b-449f-4642-a3b2-44b42845af9f	A	$2\\sin 2x$	0	\N
dd815f98-4af0-476e-88d7-ce797869d824	3ff2320b-449f-4642-a3b2-44b42845af9f	B	0	1	\N
bc2ffe20-10c2-4cba-9b5d-3fff3b1dc33f	3ff2320b-449f-4642-a3b2-44b42845af9f	C	1	2	\N
751fa8a6-6b18-42ff-8477-520ea9f79168	3ff2320b-449f-4642-a3b2-44b42845af9f	D	$\\cos 2x$	3	\N
aeef1067-12a7-4df3-b9fa-baadea39a0c8	684ae4f8-35a7-4cae-9b36-d6a5e6b5ecad	A	$\\frac{25}{2}$	0	\N
24f3bd0a-0778-4bd1-bf11-6b05e8d99874	684ae4f8-35a7-4cae-9b36-d6a5e6b5ecad	B	25	1	\N
06bf3039-e9cc-4e16-aba9-e20735b690ec	684ae4f8-35a7-4cae-9b36-d6a5e6b5ecad	C	50	2	\N
e92b2f21-d1df-4f25-849c-6d7b81060761	684ae4f8-35a7-4cae-9b36-d6a5e6b5ecad	D	5	3	\N
c1fc2771-9072-46a7-921c-3cab707f5002	88055b7b-1d2a-4214-8b2f-764bf18631fd	A	$\\sin(xe^x)$	0	\N
77d480c0-de02-4420-8845-9fe84f3c1a4d	88055b7b-1d2a-4214-8b2f-764bf18631fd	B	$\\tan(xe^x)$	1	\N
d72078ba-e455-4561-9a2e-1d0d069bfd4f	88055b7b-1d2a-4214-8b2f-764bf18631fd	C	$\\cot(xe^x)$	2	\N
a6e5f6d4-8b79-40a1-ab26-5e49cccc391f	88055b7b-1d2a-4214-8b2f-764bf18631fd	D	$\\sec(xe^x)$	3	\N
8ee54620-220b-41fc-90f7-5dd491419cca	d6a54fcb-9063-4b1e-9ea6-d7af276a9e3d	A	$\\frac{1}{2}f^2(x)$	0	\N
ca8f617b-c0cb-4704-83a9-c31871e525bf	d6a54fcb-9063-4b1e-9ea6-d7af276a9e3d	B	$\\frac{1}{2}x^2$	1	\N
42842836-de10-488f-90f6-3651bb6ca0dd	d6a54fcb-9063-4b1e-9ea6-d7af276a9e3d	C	$\\frac{1}{2}[\\{f(x)\\}^2 - \\{f(0)\\}^2]$	2	\N
3f9e84c4-b126-46e9-965b-dac3ae2ac1df	d6a54fcb-9063-4b1e-9ea6-d7af276a9e3d	D	$f(x) - f(0)$	3	\N
eba8a351-eff9-4104-915c-906120c46fb9	dfe2f375-038e-404b-84c8-d180703d4066	A	$\\frac{7}{6}$	0	\N
041af6e2-5cce-41e7-8e9e-0024dbb3dc5c	dfe2f375-038e-404b-84c8-d180703d4066	B	$\\frac{7}{6}$	1	\N
4b569124-4fe4-45d9-8b00-a3c588a53fe3	dfe2f375-038e-404b-84c8-d180703d4066	C	$1$	2	\N
2ddd3fcc-914b-429c-ab90-373a823458a4	dfe2f375-038e-404b-84c8-d180703d4066	D	$-1$	3	\N
973a9679-f9bb-4730-93e6-8767d76e0ee0	fa5859ec-2974-4fb0-a78e-381edc86ba1b	A	$60^\\circ$	0	\N
3489c399-a96d-4dc4-bf28-e2c8a045cd57	fa5859ec-2974-4fb0-a78e-381edc86ba1b	B	$30^\\circ$	1	\N
b1f4acc0-2f7a-4718-86a0-378cf9ca01ab	fa5859ec-2974-4fb0-a78e-381edc86ba1b	C	$90^\\circ$	2	\N
58555277-3487-45f2-9e1e-f3254e1ea8b7	fa5859ec-2974-4fb0-a78e-381edc86ba1b	D	$120^\\circ$	3	\N
4814d287-aff1-411a-89d9-4b5c60dd9c91	d6a74f81-a1f0-4490-8734-6a72f92fc963	A	$6:5$	0	\N
10540b6a-bdc6-486b-8bac-27bd3bf4b28a	d6a74f81-a1f0-4490-8734-6a72f92fc963	B	$5:6$	1	\N
ae11f01e-eb4b-44c3-ba18-ccd8714675b2	d6a74f81-a1f0-4490-8734-6a72f92fc963	C	$11:1$	2	\N
afe5d0c7-8b73-42fa-b065-0185ee63c825	d6a74f81-a1f0-4490-8734-6a72f92fc963	D	$1:6$	3	\N
264254a1-1b79-47db-b534-2198c764d0a6	729b8f97-7237-4a56-b3c1-32b088e0d05e	A	$\\sqrt{3}$	0	\N
0de22e02-0227-490d-a97f-0724f0eaa0e4	729b8f97-7237-4a56-b3c1-32b088e0d05e	B	$\\frac{1}{\\sqrt{3}}$	1	\N
dff3cc73-2d3c-45ef-8d15-4acce08ad558	729b8f97-7237-4a56-b3c1-32b088e0d05e	C	$\\frac{\\sqrt{3}}{2}$	2	\N
232e8893-9f88-46e6-b7a3-4395c142c2bc	729b8f97-7237-4a56-b3c1-32b088e0d05e	D	$1$	3	\N
f2922f6d-5ff2-4dd2-9dbf-f8646d01751e	059f3416-8a2a-4f39-b02d-8c91930a3182	A	$\\frac{2}{3} \\text{ unit}^2$	0	\N
1c025982-de77-48bf-be5b-de488bb99366	059f3416-8a2a-4f39-b02d-8c91930a3182	B	$\\frac{2}{3} \\text{ unit}^2$	1	\N
970e01d4-8d49-4256-8215-65e3d279470f	059f3416-8a2a-4f39-b02d-8c91930a3182	C	$\\frac{3}{2} \\text{ unit}^2$	2	\N
1e16250d-0527-46da-a42c-03052fa07a60	059f3416-8a2a-4f39-b02d-8c91930a3182	D	$\\frac{1}{3} \\text{ unit}^2$	3	\N
9985ccdb-4ffe-4943-83f8-eb167aeee849	6ebea734-46a1-4bc7-9949-cfd2128f81e9	A	$\\sqrt{73}N$	0	\N
3617a9fe-cbac-4786-ae67-e501d0b5c51b	6ebea734-46a1-4bc7-9949-cfd2128f81e9	B	$\\sqrt{97}N$	1	\N
ca3cba99-7297-457c-a64f-d279dc38731b	6ebea734-46a1-4bc7-9949-cfd2128f81e9	C	$\\sqrt{55}N$	2	\N
f3ce0399-e61b-4b76-af17-2f9969fa2450	6ebea734-46a1-4bc7-9949-cfd2128f81e9	D	$11N$	3	\N
89bccea5-904d-481a-bcbb-685cff5d73f0	2bff07da-b0ce-4a86-8516-089b41c61b98	A	$\\pi$	0	\N
6b8f9e5c-edcb-449e-94ce-1d9a8b431c01	2bff07da-b0ce-4a86-8516-089b41c61b98	B	$2\\pi$	1	\N
fe775492-2f34-4b96-8866-eeff5d17d963	2bff07da-b0ce-4a86-8516-089b41c61b98	C	$\\frac{\\pi}{2}$	2	\N
e2dbc519-1760-4282-a839-33ab32f007a9	2bff07da-b0ce-4a86-8516-089b41c61b98	D	$\\frac{\\pi}{4}$	3	\N
482d8ad1-accd-49d6-8e66-101a59e5f339	f7308d4e-842c-48a5-ab56-13e3c775a9bf	A	$3 < x < 4$	0	\N
2ae2ba18-a7f0-44db-96a1-07f3204b734e	f7308d4e-842c-48a5-ab56-13e3c775a9bf	B	$\\frac{1}{9} > x > \\frac{1}{10}$	1	\N
daf8b7dc-f33f-40a5-9edf-ec2e0e5c732f	f7308d4e-842c-48a5-ab56-13e3c775a9bf	C	$\\frac{1}{9} < x < \\frac{1}{6}$	2	\N
6ceab2e5-1a05-4bf3-8177-bed24d247a0b	f7308d4e-842c-48a5-ab56-13e3c775a9bf	D	$\\frac{1}{3} < x < \\frac{1}{2}$	3	\N
c717e11f-7f8f-4277-988f-6cd734041751	b107e72d-5b35-48a9-844e-8debf4367482	A	$4$	0	\N
4c21ef46-bd3d-47fa-8458-16f52ddd6d2e	b107e72d-5b35-48a9-844e-8debf4367482	B	$3$	1	\N
f5b0536e-6855-4287-b698-53a756c3aeea	b107e72d-5b35-48a9-844e-8debf4367482	C	$2$	2	\N
43222389-a202-4b09-ba99-02a2e47cc951	b107e72d-5b35-48a9-844e-8debf4367482	D	$0$	3	\N
ad626648-0f96-47ab-a479-b89c88468007	ca7ca25e-f07d-423d-9b1e-5fa91a2bf578	A	$0$	0	\N
a5f4a49c-584d-442e-a280-5dcdceb9d80d	ca7ca25e-f07d-423d-9b1e-5fa91a2bf578	B	$10$	1	\N
27a352c4-89f1-45c1-9ccf-a3b6f2d5d0bf	ca7ca25e-f07d-423d-9b1e-5fa91a2bf578	C	$11$	2	\N
324dda4e-6d7f-46e0-ab5a-260c35cd3119	ca7ca25e-f07d-423d-9b1e-5fa91a2bf578	D	$100$	3	\N
04cdd270-47f7-4cc7-bc27-fa34aca4c0dc	be3b4e34-7d71-43a8-9a9a-12a60e7bdbd9	A	$495$	0	\N
fcf8e310-df5f-4551-a7c8-c3f938368596	be3b4e34-7d71-43a8-9a9a-12a60e7bdbd9	B	$4223$	1	\N
e4e94172-d64b-4c78-86c2-ea276313c89c	be3b4e34-7d71-43a8-9a9a-12a60e7bdbd9	C	$-1760$	2	\N
75dd0f0a-1db8-4018-8e92-1f37e7acce59	be3b4e34-7d71-43a8-9a9a-12a60e7bdbd9	D	$1760$	3	\N
c36fada4-8f55-42cc-9c4f-7142fbc9bab5	e3496790-8253-4d55-ac02-c62789a3aa79	A	1	0	\N
2ddc0e71-1d79-434e-9563-b4a32df099b4	e3496790-8253-4d55-ac02-c62789a3aa79	B	-1	1	\N
492fd4be-d9b1-412e-85db-4ecd202c4fdd	e3496790-8253-4d55-ac02-c62789a3aa79	C	-4	2	\N
ecd0dd25-9378-433c-9be7-02cb5d8c475f	e3496790-8253-4d55-ac02-c62789a3aa79	D	-5	3	\N
42b24d35-77b4-406b-9908-b0e87f2256bf	eb443241-a0e6-419c-9b43-9c2b638a0d79	A	$\\vec{a} \\cdot \\vec{b} = 0$	0	\N
4866abd9-8dd7-4aed-a4bd-e2f6766d07e7	eb443241-a0e6-419c-9b43-9c2b638a0d79	B	$\\vec{a} \\wedge \\vec{b} = 0$	1	\N
d2deb711-68c8-4eec-88f9-6a019fe84d37	eb443241-a0e6-419c-9b43-9c2b638a0d79	C	(\\vec{a} + \\vec{b}) \\cdot (\\vec{a} - \\vec{b}) = 0	2	\N
fa6ef914-497a-4211-a767-11d78779a0a0	eb443241-a0e6-419c-9b43-9c2b638a0d79	D	(\\vec{a} + \\vec{b}) \\wedge (\\vec{a} - \\vec{b})	3	\N
87d8d95f-0ece-4178-8590-4b760ea31cce	f3fd98df-40b0-4dc2-a6b7-423b3130671c	A	$x^2 + y^2 + 8x - 2y + 51 = 0$	0	\N
9d421f40-1be0-4551-8037-2e4430538cde	f3fd98df-40b0-4dc2-a6b7-423b3130671c	B	$x^2 + y^2 - 8x - 2y + 51 = 0$	1	\N
eff7044c-5a89-44c5-bdec-6cb9a719c219	f3fd98df-40b0-4dc2-a6b7-423b3130671c	C	$x^2 + y^2 + 8x + 2y - 51 = 0$	2	\N
b6dd0d48-2ecc-487f-9a70-dd91da57c424	f3fd98df-40b0-4dc2-a6b7-423b3130671c	D	$x^2 + y^2 - 8x - 2y - 51 = 0$	3	\N
d40f83d0-2ad6-443f-a49e-d0affb0ac9ee	ef9f39c1-8a27-4472-a265-1705ec549c3a	A	10	0	\N
4cefabbd-5692-4855-9271-baaaa2b57997	ef9f39c1-8a27-4472-a265-1705ec549c3a	B	20	1	\N
2aca5557-4802-4f43-88be-9398a96c12c2	ef9f39c1-8a27-4472-a265-1705ec549c3a	C	50	2	\N
65287d5f-faa7-4152-9fa3-be9b7a401333	ef9f39c1-8a27-4472-a265-1705ec549c3a	D	200	3	\N
4395baa1-0e9e-4883-8f41-3cce814e3144	d8b127a1-4e4c-4125-a55f-2b39cec54c6f	A	18	0	\N
e9fe2d65-d67d-4c8c-8d14-eb6606af8989	d8b127a1-4e4c-4125-a55f-2b39cec54c6f	B	6	1	\N
d35c78bb-55ac-4e27-84e7-82e396df2fd0	d8b127a1-4e4c-4125-a55f-2b39cec54c6f	C	9	2	\N
65d75de6-5054-4c6f-8068-45c15175636b	d8b127a1-4e4c-4125-a55f-2b39cec54c6f	D	9	3	\N
91734464-3426-4f07-bbd7-865c5ddcfa64	06d590b9-a4b4-435d-80d2-e00892d57ee2	A	$-\\infty < x \\leq 4; 0 \\leq y < \\infty$	0	\N
1a41ec87-4e8b-4013-a0cb-78d2cbb74a8a	06d590b9-a4b4-435d-80d2-e00892d57ee2	B	$-\\infty < x < 4; 0 < y < \\infty$	1	\N
b4d92493-8d12-46d9-8550-48fdb3fc1261	06d590b9-a4b4-435d-80d2-e00892d57ee2	C	$-\\infty < x < 4; 0 \\leq y < \\infty$	2	\N
2aa0a0ce-f8ec-492c-ab67-7d7534a59176	06d590b9-a4b4-435d-80d2-e00892d57ee2	D	$-\\infty < x \\leq 4; 0 < y < \\infty$	3	\N
fbf07e66-536e-4e49-9630-08f7b4ea2e9b	7d7ecf56-2a4c-4c75-821e-a8442b60bd53	A	$(2, 3)$	0	\N
9dced5ea-6e96-4486-bce2-1c13bcb423c5	7d7ecf56-2a4c-4c75-821e-a8442b60bd53	B	$(16, 9)$	1	\N
2fb63344-8e45-4c61-bb2a-d1e7e3acfe44	7d7ecf56-2a4c-4c75-821e-a8442b60bd53	C	$(2, 10)$	2	\N
a54200ab-1615-4810-abe3-4dd6496f1bcc	7d7ecf56-2a4c-4c75-821e-a8442b60bd53	D	$(2, 7)$	3	\N
67a27a5b-0c4b-467f-8387-1e3a97301994	8c9b0948-331e-4bf9-b380-79f3b91f4035	A	$1, 0$	0	\N
d68f4624-b02c-4658-9a06-89c6be122c71	8c9b0948-331e-4bf9-b380-79f3b91f4035	B	$1, \\frac{\\pi}{2}$	1	\N
453325b8-06b1-48c3-9132-2f10ec43e20e	8c9b0948-331e-4bf9-b380-79f3b91f4035	C	$1, \\pi$	2	\N
a0e58d5d-7903-4889-85a6-cb092273af75	8c9b0948-331e-4bf9-b380-79f3b91f4035	D	$1, \\frac{3\\pi}{2}$	3	\N
d4904c49-72b3-4b94-83f1-6c8027d0bcf4	3b282d93-6894-4dd4-be9a-097db02400fa	A	$|x + 3| < 4$	0	\N
edba5b53-c697-40fa-94a3-00e5209730b0	3b282d93-6894-4dd4-be9a-097db02400fa	B	$|x + 1| < 3$	1	\N
1d35619a-a775-4a45-81dc-1e30db7ce9b9	3b282d93-6894-4dd4-be9a-097db02400fa	C	$|x + 4| < 3$	2	\N
3156d335-acb0-4a8e-9e94-dc20fe2acbc5	3b282d93-6894-4dd4-be9a-097db02400fa	D	$|x - 4| < 1$	3	\N
6c6df27a-9a5c-4d72-97a5-b20756a678d7	a87b01e9-3ec3-41cf-92da-517b413d3aa6	A	$\\frac{1}{2}$	0	\N
60cd09a4-190f-4c77-b023-5deebd7a1cf5	a87b01e9-3ec3-41cf-92da-517b413d3aa6	B	1	1	\N
f6a9e578-e6f8-4e26-8bb1-9bb64042b50e	a87b01e9-3ec3-41cf-92da-517b413d3aa6	C	0	2	\N
8f839c74-d9d2-4851-b607-b1250e939757	a87b01e9-3ec3-41cf-92da-517b413d3aa6	D	-1	3	\N
2d64ba35-3913-4bd7-9454-7958bbda62b2	2577e578-d372-4932-b1f1-a963c8261dd1	A	$\\frac{1}{6} n(n + 1)(2n + 1)$	0	\N
f7c730a5-fc9f-4471-949b-83a4e8c933c5	2577e578-d372-4932-b1f1-a963c8261dd1	B	$\\frac{1}{2} n(n + 1)(n + 2)$	1	\N
e404ae42-d74e-4b85-a78d-96d454a98016	2577e578-d372-4932-b1f1-a963c8261dd1	C	$\\frac{1}{6} n(n + 1)(n + 2)$	2	\N
1ecace8a-73f1-4a9b-ab35-61d1525249e1	2577e578-d372-4932-b1f1-a963c8261dd1	D	$\\frac{1}{6} n(n + 1)(n + 2)(n + 3)$	3	\N
9e81ff37-be73-41fb-ae73-541396ebcc06	36e5af15-9705-415b-85bf-31b806740b80	A	স্পাইকলেট	0	\N
5b9c414c-707f-4ec7-8adf-019dc7c3ffee	36e5af15-9705-415b-85bf-31b806740b80	B	পরাগধানী	1	\N
9c2a5d4e-27ec-44dc-9dfc-ef7861c92c73	36e5af15-9705-415b-85bf-31b806740b80	C	পাতা	2	\N
a23ac24d-94f0-4b2d-b84f-83b25c2abd07	36e5af15-9705-415b-85bf-31b806740b80	D	ডিম্বক	3	\N
6a782414-5272-4c6b-8fcf-fa0c8854fd57	1ec0f453-a44c-44b3-89cd-6bdaea5ce980	A	প্যাকাইটিন	0	\N
87dbc0cf-c7bd-4362-94c8-ab43136be0c5	1ec0f453-a44c-44b3-89cd-6bdaea5ce980	B	জাইগোটিন	1	\N
2b39713c-052a-4068-ac5c-1ad65f2ed7bd	1ec0f453-a44c-44b3-89cd-6bdaea5ce980	C	লেপ্টোটিন	2	\N
a8a6b170-f00e-440b-972a-bd9ba4416982	1ec0f453-a44c-44b3-89cd-6bdaea5ce980	D	ডায়াকাইনেসিস	3	\N
6efe5187-0ca2-4ffe-b1c5-6e88ed953ec0	3dbf509d-5a9a-42d9-96c3-65b09b7f4f65	A	কাঁকড়া	0	\N
77cf02df-047b-4293-b07f-b52d01053ace	3dbf509d-5a9a-42d9-96c3-65b09b7f4f65	B	চিংড়ি	1	\N
aef6c200-ea16-43f1-9846-74e42b2dc1e2	3dbf509d-5a9a-42d9-96c3-65b09b7f4f65	C	মাকড়সা	2	\N
dca49f44-fc9b-4ee2-8622-ba9ab7147c3c	3dbf509d-5a9a-42d9-96c3-65b09b7f4f65	D	প্রজাপতি	3	\N
dd3ef713-d0e2-46ae-bfc8-af53e260831f	98fa0cdb-db98-4516-b6a9-5b0a4cd7fe31	A	হামাগুড়ি	0	\N
a039d72c-5b05-4339-9f5d-7bd738c04607	98fa0cdb-db98-4516-b6a9-5b0a4cd7fe31	B	ডিগবাজী	1	\N
c5026e1f-f434-4c06-8e76-837aa8e867a4	98fa0cdb-db98-4516-b6a9-5b0a4cd7fe31	C	অ্যামিবয়েড	2	\N
db395377-7ec7-4475-b497-68a0d222cf6e	98fa0cdb-db98-4516-b6a9-5b0a4cd7fe31	D	ভাসা	3	\N
c617fd32-becb-4534-b666-e70b75301d9f	a8176b61-70e6-4a44-8927-2e0e940205cd	A	পেরিঅস্টিয়াম	0	\N
c9c102af-4a2f-49e2-a6ac-e4f29700e345	a8176b61-70e6-4a44-8927-2e0e940205cd	B	পেরিকার্ডিয়াম	1	\N
72fd0696-a83f-4721-9894-90ccf5da43e0	a8176b61-70e6-4a44-8927-2e0e940205cd	C	পেরিটোনিয়াম	2	\N
68cf10fb-3d0a-472b-bb44-3b8001fec9e8	a8176b61-70e6-4a44-8927-2e0e940205cd	D	পেরিকন্ড্রিয়াম	3	\N
24de0a84-360f-40fe-ba45-00c876ecc4bb	f7217c62-ca80-447d-9def-5918cec789b8	A	A-অ্যান্টিজেন উপস্থিত	0	\N
34067c3d-516c-4a6f-b331-cb55fa61745e	f7217c62-ca80-447d-9def-5918cec789b8	B	B-অ্যান্টিজেন উপস্থিত	1	\N
a0212391-35fd-4906-9d95-1b092a8912e6	f7217c62-ca80-447d-9def-5918cec789b8	C	A এবং B-অ্যান্টিজেন উপস্থিত	2	\N
f487b947-372a-4a3a-a4ac-8724bbeb69d7	f7217c62-ca80-447d-9def-5918cec789b8	D	A এবং B-অ্যান্টিজেন অনুপস্থিত	3	\N
efa2fda7-16d2-4b23-964b-72047646012c	498ae4f4-1af9-4c0a-858c-42b6f4776e99	A	$৩:১$	0	\N
8061b050-faed-4f3d-9337-969204281b15	498ae4f4-1af9-4c0a-858c-42b6f4776e99	B	$২:১$	1	\N
2dc66c15-b21c-49ae-a6d2-39a5c7836d57	498ae4f4-1af9-4c0a-858c-42b6f4776e99	C	$১৩:৩$	2	\N
e0aa757b-f838-4cd5-9ead-0be0a81cb5b7	498ae4f4-1af9-4c0a-858c-42b6f4776e99	D	$৯:৭$	3	\N
df18fd29-c03b-4b9f-aad0-e51535040f63	edeec63f-3598-40e4-a76b-20026bd38e6f	A	১৮৬৫	0	\N
92e5f0f7-3510-43c6-ae6b-f5dd8eb8e88d	edeec63f-3598-40e4-a76b-20026bd38e6f	B	১৮৫৯	1	\N
9046160c-e884-4475-be89-9c2fc7d67891	edeec63f-3598-40e4-a76b-20026bd38e6f	C	১৯৫৯	2	\N
ea4bf638-fa91-4b82-bc62-6fb06371c98c	edeec63f-3598-40e4-a76b-20026bd38e6f	D	১৮৩৬	3	\N
36ae722d-d111-4cc1-ba04-2b853fb4aaa7	9f25db43-7419-4324-9f10-10513c923a31	A	ঘাসফড়িং	0	\N
336b7940-c57a-4172-bf63-4d37cf12b5ce	9f25db43-7419-4324-9f10-10513c923a31	B	টিকটিকি	1	\N
db099f1c-55d2-4486-94d2-4646d0de51c4	9f25db43-7419-4324-9f10-10513c923a31	C	পাখি	2	\N
38bb5cfc-2261-4de4-ac1e-8e0e6a7b79ba	9f25db43-7419-4324-9f10-10513c923a31	D	মানুষ	3	\N
714d59be-2789-4770-a3d7-d7892633ecc3	63aaf4d9-ee45-4153-8dde-3b0af400b968	A	ভিটামিন	0	\N
bb20841f-45fb-431d-8c81-55c241086fcb	63aaf4d9-ee45-4153-8dde-3b0af400b968	B	শর্করা	1	\N
8808b9ea-aa09-45dc-9ef2-655dbfb3c72f	63aaf4d9-ee45-4153-8dde-3b0af400b968	C	আমিষ	2	\N
1f0c42a8-e382-49a0-8648-c61fadd65e8b	63aaf4d9-ee45-4153-8dde-3b0af400b968	D	ফ্যাটি অ্যাসিড	3	\N
05df32c9-6469-4e3c-9e3f-cc98e27831a1	c517231f-41c8-4e37-9389-fbbec3adad17	A	ত্বক	0	\N
64bfe891-f068-4216-a61f-04b005da2708	c517231f-41c8-4e37-9389-fbbec3adad17	B	অধঃত্বক	1	\N
4924437e-a7d4-464d-9146-b67f60b69816	c517231f-41c8-4e37-9389-fbbec3adad17	C	অন্তঃত্বক	2	\N
49c67b08-5c33-4419-83ff-b405e0c38bf5	c517231f-41c8-4e37-9389-fbbec3adad17	D	পরিচক্র	3	\N
2449ef4d-b944-4844-92a4-34401ba8abcc	ea03d5f3-88ce-4d02-9bcf-3737e9b9be25	A	একটি	0	\N
2674a80d-75d0-4a05-882b-ed7c8bc4a1ac	ea03d5f3-88ce-4d02-9bcf-3737e9b9be25	B	দুইটি	1	\N
bdf1fa4e-a549-40df-9d3f-cbb10fbc62f4	ea03d5f3-88ce-4d02-9bcf-3737e9b9be25	C	তিনটি	2	\N
b62dac33-d3b7-4b8f-b1a2-70aac0d1debd	ea03d5f3-88ce-4d02-9bcf-3737e9b9be25	D	আটটি	3	\N
0d8840ca-16a3-4663-8e0b-654dac49aaca	ca1083be-b2b5-473c-b3dc-7325603180bb	A	পর-পরাগায়ণ	0	\N
5914c3fd-afc4-4ccb-92e9-7cf3447f4237	ca1083be-b2b5-473c-b3dc-7325603180bb	B	উন্মুক্ত পরাগায়ণ	1	\N
19e769b1-339c-436d-a7db-0ba4dfcec01e	ca1083be-b2b5-473c-b3dc-7325603180bb	C	স্ব-পরাগায়ণ	2	\N
8638597d-9c33-4145-b27a-298913879e0e	ca1083be-b2b5-473c-b3dc-7325603180bb	D	স্ব এবং পর-পরাগায়ণ	3	\N
b67af19c-fd42-4d7f-8431-718e1ba0cc54	3169f68f-ec7b-4989-8244-d96ed5b3c99c	A	ফসফরাস	0	\N
811c8c00-1704-4594-81f3-ce48739644d8	3169f68f-ec7b-4989-8244-d96ed5b3c99c	B	ম্যাগনেসিয়াম	1	\N
4159ca54-f6fd-4dbb-b055-b7e661eb5d18	3169f68f-ec7b-4989-8244-d96ed5b3c99c	C	লৌহ	2	\N
065fab18-9d92-4d35-9ce0-cfce96f01bd6	3169f68f-ec7b-4989-8244-d96ed5b3c99c	D	পটাশিয়াম	3	\N
dd40e4d7-85b6-47cd-ab5a-803089f1c46a	57d1b1a7-ab09-42b4-812f-bd9ba0173801	A	১০টি	0	\N
96798313-aa9e-42f0-b18f-b27dcf89e5a4	57d1b1a7-ab09-42b4-812f-bd9ba0173801	B	১২টি	1	\N
e43b1ce6-9369-4845-841b-86edb25a92ae	57d1b1a7-ab09-42b4-812f-bd9ba0173801	C	২০টি	2	\N
d7872f8a-c5ff-4d93-a8c3-f67275515bad	57d1b1a7-ab09-42b4-812f-bd9ba0173801	D	২৪টি	3	\N
e8c8de7f-3511-45f0-9f2d-161f53e2b385	79fc02c9-79b0-47dd-8ee9-71365ef709cb	A	Chlamydomonas	0	\N
0095aa71-10fd-423f-933c-9e0280652e78	79fc02c9-79b0-47dd-8ee9-71365ef709cb	B	Ulothrix	1	\N
853860cb-1194-45c8-8258-0025f6e1400c	79fc02c9-79b0-47dd-8ee9-71365ef709cb	C	Pyrobotrys	2	\N
e30f67a4-f353-49b2-993b-2d9f1be9842d	79fc02c9-79b0-47dd-8ee9-71365ef709cb	D	Volvox	3	\N
6b01b753-da43-4b94-9938-c540a7720440	7bacb6f5-4157-4154-8fd2-6d7261e40013	A	দেহ থ্যালয়েড	0	\N
3bd1d8a8-b0a0-4a68-a8c6-3e2463b27c8d	7bacb6f5-4157-4154-8fd2-6d7261e40013	B	দেহ ভাস্কুলার	1	\N
95c99993-f1ae-40db-9014-d3c61cd5436a	7bacb6f5-4157-4154-8fd2-6d7261e40013	C	দেহ গ্যামিটোফাইট	2	\N
21efc0f4-f4a7-4271-b977-5f9a78891cbd	7bacb6f5-4157-4154-8fd2-6d7261e40013	D	অপুস্পক	3	\N
a4f63fb6-e19e-4e7c-b348-d4230ee3467e	4e0281ab-153b-477c-b6da-d2e84b39c456	A	Agrobacterium tumefaciens	0	\N
9d290a25-df63-4770-805b-c04f8338d562	4e0281ab-153b-477c-b6da-d2e84b39c456	B	Bacillus thuringiensis	1	\N
315d3412-0d1d-4753-8174-ff5ec785e2a7	4e0281ab-153b-477c-b6da-d2e84b39c456	C	Agrobacterium tritici	2	\N
0d1c2e23-9589-49f7-9b04-061f7e91c071	4e0281ab-153b-477c-b6da-d2e84b39c456	D	Bacillus denitrificans	3	\N
26debb24-ae6f-4a83-a41d-d5bccddfeb55	421ea082-a221-472e-80ea-f7dd9eac7001	A	Opuntia dillenii	0	\N
5450c1c8-b3e5-44e8-a60b-0cc7c6506583	421ea082-a221-472e-80ea-f7dd9eac7001	B	Nipa fruticans	1	\N
74480c6a-73fc-4c79-9190-94cbbe743364	421ea082-a221-472e-80ea-f7dd9eac7001	C	Ottelia alismoides	2	\N
5ecac590-7692-42ab-b7cb-c58487fa95f8	421ea082-a221-472e-80ea-f7dd9eac7001	D	Lemna minor	3	\N
ecc55d70-f420-4baf-817f-f858c009e8c5	46c6faa7-10cd-4eb0-ad3a-bc90abe4ce6a	A	Robert Hooke	0	\N
59ea917d-bfec-435b-8cd6-b1ddc9778ee3	46c6faa7-10cd-4eb0-ad3a-bc90abe4ce6a	B	Robert Brown	1	\N
495a116c-bcf6-4683-9a44-d62a10be0ed9	46c6faa7-10cd-4eb0-ad3a-bc90abe4ce6a	C	K. R. Porter	2	\N
0d4636f0-2b1c-49ed-aed2-76f624c559d1	46c6faa7-10cd-4eb0-ad3a-bc90abe4ce6a	D	Antony Von Leeuwenhoek	3	\N
ddc3a895-6aa6-425e-ba50-c34fcc5ee8bc	4aa70cdc-5e9c-4837-86bc-b14a9fedc56f	A	রাইবোসোম	0	\N
3b41e97c-09ba-469c-a6d5-954ddcb75c17	4aa70cdc-5e9c-4837-86bc-b14a9fedc56f	B	লাইসোসোম	1	\N
04823c84-9136-4962-b211-e81206acbbcf	4aa70cdc-5e9c-4837-86bc-b14a9fedc56f	C	ক্লোরোপ্লাস্ট	2	\N
486b03ab-105e-417f-b7cd-a602f137e819	4aa70cdc-5e9c-4837-86bc-b14a9fedc56f	D	মাইটোকন্ড্রিয়া	3	\N
5c971a95-f78a-42e4-821f-37e60bb7cab6	d3611d76-989c-4d17-ae58-6d2259a20e9b	A	DNA	0	\N
d569c09c-1e1e-4454-bf3d-84a542783d70	d3611d76-989c-4d17-ae58-6d2259a20e9b	B	mRNA	1	\N
13336646-890f-4161-90f5-6d96506ae848	d3611d76-989c-4d17-ae58-6d2259a20e9b	C	tRNA	2	\N
113854d0-2bf4-4b2e-8344-d24b8a798f6f	d3611d76-989c-4d17-ae58-6d2259a20e9b	D	rRNA	3	\N
d9c090a9-3a78-4725-a480-69059da83a18	ae7cab33-73af-4c6e-82e0-b9b1d817e6c3	A	$\\beta$-গ্লুকোজ	0	\N
fd8122f8-677f-40bc-b72c-2853d2de0bf6	ae7cab33-73af-4c6e-82e0-b9b1d817e6c3	B	ফ্রুক্টোজ	1	\N
c6884d60-ce57-411d-a7f7-cb0099b42281	ae7cab33-73af-4c6e-82e0-b9b1d817e6c3	C	মল্টোজ	2	\N
3d57385a-782a-4aa2-b51d-75caeb138f59	ae7cab33-73af-4c6e-82e0-b9b1d817e6c3	D	র‍্যাফিনোজ	3	\N
dfb1bd4c-6a6e-4e93-bee1-cb96e12eb25d	294554a8-a348-4257-9e51-c30b30876435	A	Corypha taliera	0	\N
3159d8b6-d367-4b40-bee2-9a19c52cd382	294554a8-a348-4257-9e51-c30b30876435	B	Albizia procera	1	\N
b37321d0-1e9a-4af2-95bb-a7742eee98af	294554a8-a348-4257-9e51-c30b30876435	C	Dillenia pentagyna	2	\N
81cb070b-6150-41af-b8bb-479b037e4200	294554a8-a348-4257-9e51-c30b30876435	D	Streblus asper	3	\N
9860ddb9-49db-493d-ba1e-3dbe950ffd5a	73cba5b2-f4e0-4498-8fa2-6fa6de8c3caa	A	যকৃৎ	0	\N
3d052342-7d42-4488-8f2a-d3197dc30630	73cba5b2-f4e0-4498-8fa2-6fa6de8c3caa	B	অগ্ন্যাশয়	1	\N
856d4a4e-5601-4a6c-b0c4-baa88dc2f72e	73cba5b2-f4e0-4498-8fa2-6fa6de8c3caa	C	বৃক্ক	2	\N
98550421-71c4-47cc-8f61-7b1d216e1414	73cba5b2-f4e0-4498-8fa2-6fa6de8c3caa	D	ফুসফুস	3	\N
aa3a38b9-e862-4f23-927e-ca681589ed8e	0c1935b9-a0b7-4203-8df2-d82f06aa21ea	A	ওয়াটসন এন্ড ক্রিক	0	\N
1bf193be-897d-4ca3-a0f3-e70be27a4b29	0c1935b9-a0b7-4203-8df2-d82f06aa21ea	B	এডওয়ার্ড জেনার	1	\N
56d3e393-7e8e-49b2-bd9a-3baf026e2dfe	0c1935b9-a0b7-4203-8df2-d82f06aa21ea	C	আলেকজান্ডার ফ্লেমিং	2	\N
8cc972bd-e57b-41d3-9792-cbc597fc89df	0c1935b9-a0b7-4203-8df2-d82f06aa21ea	D	ল্যামার্ক	3	\N
9c612ad9-9249-4e32-99c8-03338d76f29e	d8c1eb85-f71b-49aa-9e63-c7ea75d06097	A	স্ক্যাপুলা	0	\N
96e25598-6688-4bdc-b2ce-40f4c651fdad	d8c1eb85-f71b-49aa-9e63-c7ea75d06097	B	হিউমেরাস	1	\N
05c02d40-1ea0-4df5-a44b-b4457206e507	d8c1eb85-f71b-49aa-9e63-c7ea75d06097	C	রেডিও-আলনা	2	\N
862c128c-0007-4589-bb0b-60fb3c24e19c	d8c1eb85-f71b-49aa-9e63-c7ea75d06097	D	পেলভিক গার্ডেল	3	\N
bbd424cb-edce-4383-8633-cb2c1455d358	1a19b128-3a4e-4b9f-a10e-fb4d1997d584	A	মেমব্রেনাস ল্যাবিরিন্থ	0	\N
84b40bf8-b697-4dec-a71a-ce70dcc486f1	1a19b128-3a4e-4b9f-a10e-fb4d1997d584	B	অর্গান অব কর্টি	1	\N
413196db-8436-427c-8d70-bf713a0deece	1a19b128-3a4e-4b9f-a10e-fb4d1997d584	C	টিমপেনিক পর্দা	2	\N
fd129155-1aca-47b4-bedf-9f12ad1e251f	1a19b128-3a4e-4b9f-a10e-fb4d1997d584	D	ম্যালিয়াস	3	\N
46c2ee66-927a-4a7c-a9ad-9ed87927bfd3	8ce61a29-e36b-494f-b4f3-a38b28373425	A	প্রোল্যাকটিন	0	\N
3cd3e00e-7949-4d4b-94d8-9f26f73e907a	8ce61a29-e36b-494f-b4f3-a38b28373425	B	প্রোজেস্টেরন	1	\N
51334944-54a3-48dc-a949-c36b433868a7	8ce61a29-e36b-494f-b4f3-a38b28373425	C	অক্সিটসিন	2	\N
728de69c-2c05-47fe-a820-28855a755620	8ce61a29-e36b-494f-b4f3-a38b28373425	D	গোনাডোট্রপিন	3	\N
f37fded7-912c-4183-b39c-2267d309eccf	1a7e5863-9b1b-432c-9ea2-5eb346823307	A	ঘড়িয়াল	0	\N
abf7062f-a65c-47e3-9e23-1a55ddd9d1be	1a7e5863-9b1b-432c-9ea2-5eb346823307	B	গন্ডার	1	\N
740bbe80-e504-4298-b434-aaff86812a10	1a7e5863-9b1b-432c-9ea2-5eb346823307	C	টুয়াটারা	2	\N
b540e3e8-c095-4781-a070-c2257aaa3c34	1a7e5863-9b1b-432c-9ea2-5eb346823307	D	হংস চঞ্চু প্লাটিপাস	3	\N
6c3afca1-67a2-490c-8795-b0d2ef465a0a	8af36a16-997a-4f49-8622-77c5f80334df	A	Coulomb	0	\N
f9697fa1-a7b0-488a-b346-d6f461552da5	8af36a16-997a-4f49-8622-77c5f80334df	B	Ampere	1	\N
2632db6f-e8d8-4208-955a-c437fd5f79de	8af36a16-997a-4f49-8622-77c5f80334df	C	Volt	2	\N
a043221f-682e-418e-8851-140e06cac9d4	8af36a16-997a-4f49-8622-77c5f80334df	D	Ohm	3	\N
647c6ae8-f257-40b2-8bec-f96c148f1223	901eaa80-8900-46c4-820f-6f002be4a75d	A	$660\\,\\text{J}$	0	\N
ac05a510-d3c8-4b14-969e-7d8dd2036b8c	901eaa80-8900-46c4-820f-6f002be4a75d	B	$680\\,\\text{J}$	1	\N
53a570ce-ce96-45b0-a311-3f79a7b81953	901eaa80-8900-46c4-820f-6f002be4a75d	C	$700\\,\\text{J}$	2	\N
3529b712-b106-4480-9c1b-ec76265c6c8a	901eaa80-8900-46c4-820f-6f002be4a75d	D	$720\\,\\text{J}$	3	\N
78a1c4bc-2b9b-40b3-9c9c-f84528074a30	6b8b0d2e-4b91-4511-9acf-a2f4c0fce4e9	A	$10\\,\\text{m}$	0	\N
608c3300-587a-410a-b878-67c0d010d851	6b8b0d2e-4b91-4511-9acf-a2f4c0fce4e9	B	$15\\,\\text{m}$	1	\N
6e3a53ff-78cf-4e16-9d84-37955ba4b04c	6b8b0d2e-4b91-4511-9acf-a2f4c0fce4e9	C	$25\\,\\text{m}$	2	\N
7e813bf5-a9d7-4937-a2c7-23019d801ed6	6b8b0d2e-4b91-4511-9acf-a2f4c0fce4e9	D	$28\\,\\text{m}$	3	\N
8d28c027-63d9-4ed7-a087-1057dbc55023	f0807419-d303-4100-8168-7fa61676df98	A	$1.6 \\times 10^{15}\\,\\text{s}^{-1}$	0	\N
4481f014-69a7-4948-acb3-b8e13db076be	f0807419-d303-4100-8168-7fa61676df98	B	$6.63 \\times 10^{34}\\,\\text{s}^{-1}$	1	\N
378e755d-f808-4e11-8ee0-610027727cef	f0807419-d303-4100-8168-7fa61676df98	C	$4.14 \\times 10^{15}\\,\\text{s}^{-1}$	2	\N
a2a801a4-35d8-43d7-81eb-6e73ab418e93	f0807419-d303-4100-8168-7fa61676df98	D	$4.14 \\times 10^{34}\\,\\text{s}^{-1}$	3	\N
c0084a34-5e93-4072-933c-65b6c4fb8141	44dabe5a-baf4-4f09-abf0-5fdc2d32a0e2	A	$2\\pi$	0	\N
564eb44f-182b-47ce-8e84-71210237ce89	44dabe5a-baf4-4f09-abf0-5fdc2d32a0e2	B	$\\pi$	1	\N
66ccb53a-606a-4eaa-a674-dd5dbb8ca6d0	44dabe5a-baf4-4f09-abf0-5fdc2d32a0e2	C	$\\frac{\\pi}{2}$	2	\N
cb64c6d7-60c8-4d80-a057-83f5a4c49650	44dabe5a-baf4-4f09-abf0-5fdc2d32a0e2	D	$\\frac{\\pi}{4}$	3	\N
8d26bf49-517f-498e-a959-35d7117b844a	e8c100e6-f5c4-4839-97d9-0e7d7089985b	A	$3 \\times 10^{-3}\\,\\text{cm}$	0	\N
b64b96ea-202f-4263-9186-ea668e9b5fa8	e8c100e6-f5c4-4839-97d9-0e7d7089985b	B	$3 \\times 10^{-4}\\,\\text{cm}$	1	\N
0b6d7a74-1f37-47db-9839-396ffecbb6b2	e8c100e6-f5c4-4839-97d9-0e7d7089985b	C	$3 \\times 10^{-5}\\,\\text{cm}$	2	\N
bd7594ba-c01f-47f8-adfb-41ba7d03fd0a	e8c100e6-f5c4-4839-97d9-0e7d7089985b	D	$6 \\times 10^{-6}\\,\\text{cm}$	3	\N
cc2d2943-02be-444c-beca-6fc1cc9cb4c7	236c5edc-9fb2-4134-b848-7df9910ee107	A	$917.28 \\times 10^5\\,\\text{J/K}$	0	\N
4b512809-79f0-4f7f-b43e-a1c802bccb4f	236c5edc-9fb2-4134-b848-7df9910ee107	B	$3.36 \\times 10^5\\,\\text{J/K}$	1	\N
1df19978-bec2-435b-8ba6-f09d38e5cbeb	236c5edc-9fb2-4134-b848-7df9910ee107	C	$273 \\times 10^5\\,\\text{J/K}$	2	\N
d8aae5e5-095c-4b39-9607-08fa8f1fab15	236c5edc-9fb2-4134-b848-7df9910ee107	D	$0\\,\\text{J/K}$	3	\N
1f5f5ac3-1c30-44c6-bb4a-0f81f7f5cd1b	4b3fd082-8394-4ecc-afda-a36b07d05658	A	$15\\%$	0	\N
832de3b8-6dc2-46d9-83fd-d81591d2d6cd	4b3fd082-8394-4ecc-afda-a36b07d05658	B	$25\\%$	1	\N
683b1d8e-158f-4c6f-97e9-143df35f760f	4b3fd082-8394-4ecc-afda-a36b07d05658	C	$35\\%$	2	\N
463b1110-0a9b-4a30-84f8-419f89bce030	4b3fd082-8394-4ecc-afda-a36b07d05658	D	$50\\%$	3	\N
adf1dab6-c2a1-40f9-94f5-fda346435600	ba844b10-8d58-4186-9c14-2cdced4aaeae	A	$2\\,\\text{N}$	0	\N
9cd71b52-0d61-4dec-8ce3-7f699a9d137b	ba844b10-8d58-4186-9c14-2cdced4aaeae	B	$2.5\\,\\text{N}$	1	\N
d24caee2-415c-4986-8823-0a8a956bc0a6	ba844b10-8d58-4186-9c14-2cdced4aaeae	C	$300\\,\\text{N}$	2	\N
5306c9bb-4823-4e7f-836f-61ab93221179	ba844b10-8d58-4186-9c14-2cdced4aaeae	D	$5\\,\\text{N}$	3	\N
01275e6e-d68e-487d-ab22-af49d0f299a6	4290a514-cf7b-4347-b9af-e669fda9388f	A	আপেক্ষিক রোধ অর্ধেক হবে	0	\N
c8f04a89-b664-4947-bf92-13133e7d6272	4290a514-cf7b-4347-b9af-e669fda9388f	B	আপেক্ষিক রোধ একই থাকবে	1	\N
34550d93-45bd-4cc7-bdf5-7d8e62517a53	4290a514-cf7b-4347-b9af-e669fda9388f	C	আপেক্ষিক রোধ দ্বিগুণ হবে	2	\N
5eabb078-d72c-4260-a6df-096b3df35eeb	4290a514-cf7b-4347-b9af-e669fda9388f	D	আপেক্ষিক রোধ চারগুণ হবে	3	\N
0206e763-37f1-4860-a873-f64ffa5f6666	461e205a-bb8a-4bdd-81fb-f8a21d854215	A	গামা রশ্মি	0	\N
dc94a345-868e-4893-bda5-c77d8ea30c79	461e205a-bb8a-4bdd-81fb-f8a21d854215	B	অবলোহিত রশ্মি	1	\N
32919031-02e3-4bce-897f-a3f4032a66d1	461e205a-bb8a-4bdd-81fb-f8a21d854215	C	অতিবেগুনি রশ্মি	2	\N
ac64eae3-fd68-43c3-8181-8cc90869575f	461e205a-bb8a-4bdd-81fb-f8a21d854215	D	এক্স-রে রশ্মি	3	\N
31d85a28-21b4-42e5-a689-89dcba93e0fd	b1c543d3-0318-4e2d-bc4b-6212bc78941b	A	$2.9 \\times 10^{-4}\\,\\text{m}$	0	\N
f23f5e09-67ee-42ca-86f4-8698064a1dc2	b1c543d3-0318-4e2d-bc4b-6212bc78941b	B	$2.4 \\times 10^{-8}\\,\\text{m}$	1	\N
18aa6929-8dc2-430d-add8-9edaf5639e99	b1c543d3-0318-4e2d-bc4b-6212bc78941b	C	$2.9 \\times 10^{-10}\\,\\text{m}$	2	\N
a86c70cf-02c5-4b61-8ef4-2d9b57c26303	b1c543d3-0318-4e2d-bc4b-6212bc78941b	D	$2.4 \\times 10^{-39}\\,\\text{m}$	3	\N
d035a955-fb43-4854-b068-e2fdc6a09391	224cfaf5-cd27-416f-a643-c1e7c7aa4d36	A	$15\\,\\Omega$	0	\N
ccf9ebd9-a645-48ee-b951-c9dcdd1129bd	224cfaf5-cd27-416f-a643-c1e7c7aa4d36	B	$20\\,\\Omega$	1	\N
b2817d8c-0fee-4e78-8e6b-cf2419c266c2	224cfaf5-cd27-416f-a643-c1e7c7aa4d36	C	$25\\,\\Omega$	2	\N
62c26396-61ff-4889-8af8-125cbbe28bd3	224cfaf5-cd27-416f-a643-c1e7c7aa4d36	D	$30\\,\\Omega$	3	\N
e7091e30-ffb8-487d-9dc9-85db9ceac013	6dc0f00b-5ebd-4b0e-b639-2168d0bea3ce	A	কমবে	0	\N
6329fa85-dc12-4a36-9be6-54a9da9d3d48	6dc0f00b-5ebd-4b0e-b639-2168d0bea3ce	B	বৃদ্ধি পাবে	1	\N
5b3a3a93-1794-40f4-83a3-dee05a08a3bb	6dc0f00b-5ebd-4b0e-b639-2168d0bea3ce	C	পরিবর্তন হবে না	2	\N
e55a68d3-432c-4e7d-b7ed-2c3e73e2e0fe	6dc0f00b-5ebd-4b0e-b639-2168d0bea3ce	D	শূন্য হবে	3	\N
5bf750ce-404d-44a9-a63e-597bc93e1316	87a00d9d-0b71-46a9-a5b5-dab32ffe2472	A	$1.67\\,\\text{H.P.}$	0	\N
fb8786e9-5d01-4f2f-9497-d81ece6e892f	87a00d9d-0b71-46a9-a5b5-dab32ffe2472	B	$3.34\\,\\text{H.P.}$	1	\N
3e01849d-9172-43d0-a023-e26187020dcd	87a00d9d-0b71-46a9-a5b5-dab32ffe2472	C	$6.68\\,\\text{H.P.}$	2	\N
23877923-425d-444c-a541-81fc8fac133d	87a00d9d-0b71-46a9-a5b5-dab32ffe2472	D	$26.72\\,\\text{H.P.}$	3	\N
c2b0ac0d-1ae1-463c-a04b-a628ae0c1248	42ed3074-0269-4669-9f60-ed38853ba85a	A	$(101110000)_2$	0	\N
db7bbaa8-c49d-4d84-9866-b0cac9f1a6eb	42ed3074-0269-4669-9f60-ed38853ba85a	B	$(110110000)_2$	1	\N
35f602ec-9ade-4143-b1c9-31e655076a54	42ed3074-0269-4669-9f60-ed38853ba85a	C	$(111010000)_2$	2	\N
b3b0ac30-56e6-4942-bd82-ac4fcd89ab57	42ed3074-0269-4669-9f60-ed38853ba85a	D	$(111100000)_2$	3	\N
d49de2f0-4039-457e-a49a-19e22b31b798	70b8f220-c374-4587-bcb2-12f7e2fa0bf7	A	$1.331\\,\\text{m/s}^2$	0	\N
9b3af192-60cb-41e1-a7de-038ddbd3c484	70b8f220-c374-4587-bcb2-12f7e2fa0bf7	B	$2.663\\,\\text{m/s}^2$	1	\N
e7c3efd0-7e87-42b1-ad2c-644122f6c832	70b8f220-c374-4587-bcb2-12f7e2fa0bf7	C	$5.325\\,\\text{m/s}^2$	2	\N
ad7d3e2e-ee96-4bc6-972d-17ab2ee7cc46	70b8f220-c374-4587-bcb2-12f7e2fa0bf7	D	$10.650\\,\\text{m/s}^2$	3	\N
b25e7ab2-8ad0-42e7-bba2-c2b793f2d9bf	e7e5c15d-593a-41f6-a631-17cee6c3d6e2	A	$-4$	0	\N
c156e27d-1bfa-48e6-80e8-106ed4b7bd07	e7e5c15d-593a-41f6-a631-17cee6c3d6e2	B	$-6$	1	\N
b97575a8-d83d-4f39-bc3f-729410ea033e	e7e5c15d-593a-41f6-a631-17cee6c3d6e2	C	$6$	2	\N
52f40d3c-f6bc-4e44-8b8e-a0f975acbaef	e7e5c15d-593a-41f6-a631-17cee6c3d6e2	D	$-2$	3	\N
64b1dd1b-19bd-4d3d-8213-0da88015ae29	bd780c4e-1e12-4891-a7a0-e6a61eed1456	A	$[ML^3T^{-3}]$	0	\N
db737c11-d581-49a9-94b4-368ab19cda46	bd780c4e-1e12-4891-a7a0-e6a61eed1456	B	$[M^{-1}L^3T^{-2}]$	1	\N
ee670c2e-1efb-49b1-aaf9-50529b778e61	bd780c4e-1e12-4891-a7a0-e6a61eed1456	C	$[M^{-2}L^3T^{-1}]$	2	\N
ec0ac846-9542-4219-99d7-4715efe5287e	bd780c4e-1e12-4891-a7a0-e6a61eed1456	D	$[M^{-3}L^3T]$	3	\N
19b7515b-d194-4cab-8f51-d7128d8d4807	b1948a83-dec1-4d5c-92ca-3909de974a5e	A	$20\\,\\text{cm}$	0	\N
7efc3c1a-bfd4-41ae-96c4-40119f370575	b1948a83-dec1-4d5c-92ca-3909de974a5e	B	$10\\,\\text{cm}$	1	\N
6236783f-24c8-4ab6-a36d-8c4b83cbe443	b1948a83-dec1-4d5c-92ca-3909de974a5e	C	$40\\,\\text{cm}$	2	\N
ead49fc0-9da5-48e6-ba64-0a6f7d7c4537	b1948a83-dec1-4d5c-92ca-3909de974a5e	D	$80\\,\\text{cm}$	3	\N
1df26f44-0627-4a46-a679-3455a699276c	73c1c74d-b66f-4759-8fe1-c9a414e37872	A	$4.9\\,\\text{s}$	0	\N
7eb71cb6-5072-4cc1-b78f-9dc35ba97441	73c1c74d-b66f-4759-8fe1-c9a414e37872	B	$9.8\\,\\text{s}$	1	\N
827e12c0-ae80-4f33-95de-47cda588b0b7	73c1c74d-b66f-4759-8fe1-c9a414e37872	C	$1\\,\\text{s}$	2	\N
20b402fb-335c-4042-98da-cd5fc3b3a440	73c1c74d-b66f-4759-8fe1-c9a414e37872	D	$2\\,\\text{s}$	3	\N
7f6c5bf7-be49-4e15-bd55-ea9b09f28727	6f0a35c2-8908-4c2d-9620-26945cada15f	A	Newton-meter$^2$/Coulomb	0	\N
bf90de44-ad3f-4295-b396-a345c324e488	6f0a35c2-8908-4c2d-9620-26945cada15f	B	Newton-meter/Coulomb	1	\N
0185a401-51e6-483a-9920-5ae67c52a6de	6f0a35c2-8908-4c2d-9620-26945cada15f	C	Newton/Coulomb	2	\N
c707c25b-8557-4459-bef6-b7d1946cf2bc	6f0a35c2-8908-4c2d-9620-26945cada15f	D	Newton/meter$^2$	3	\N
1c487526-1337-49d1-8448-e6212ccc2afc	e1f38048-f857-424d-bbec-4cfa15494f9c	A	$4.2 \\times 10^{62}$	0	\N
68d626ed-b883-4359-8c95-17fabaeb858f	e1f38048-f857-424d-bbec-4cfa15494f9c	B	$4.2 \\times 10^{52}$	1	\N
76f0602d-14b4-418b-8880-496153866ed2	e1f38048-f857-424d-bbec-4cfa15494f9c	C	$4.2 \\times 10^{42}$	2	\N
c15d56b4-6687-46d0-a899-87fed389f91b	e1f38048-f857-424d-bbec-4cfa15494f9c	D	$4.2 \\times 10^{32}$	3	\N
92113d9c-d658-4291-b560-25b0191e05d6	a01b5c95-1c9e-4319-b48f-90743f87f68c	A	$0.693\\,\\text{s}$	0	\N
dd9b99de-fe1d-4b99-9c17-29124a7fde19	a01b5c95-1c9e-4319-b48f-90743f87f68c	B	$6.93\\,\\text{s}$	1	\N
fe5df891-d593-41ef-b4a0-9f9998c37b91	a01b5c95-1c9e-4319-b48f-90743f87f68c	C	$69.3\\,\\text{s}$	2	\N
4148d70a-7951-417f-82c1-e0f03ef4335e	a01b5c95-1c9e-4319-b48f-90743f87f68c	D	$693\\,\\text{s}$	3	\N
c4689ec3-790f-4cfa-a32c-39283acd4c73	75a24797-7a12-4fab-a527-e72c1d201203	A	$\\frac{3}{2}\\,\\text{m/s}$	0	\N
7adc5645-4a5d-4db8-bac8-a2e86beefbc5	75a24797-7a12-4fab-a527-e72c1d201203	B	$\\frac{\\sqrt{3}}{2}\\,\\text{m/s}$	1	\N
3e32353d-7aa2-4ba5-890c-c832ebc96108	75a24797-7a12-4fab-a527-e72c1d201203	C	$3\\,\\text{m/s}$	2	\N
fe285f3b-e81d-4c19-8f52-4e40b0066e85	75a24797-7a12-4fab-a527-e72c1d201203	D	$0\\,\\text{m/s}$	3	\N
e367ad1d-5412-4d47-a008-3906e9dbb931	0ecbb69a-5327-4480-ab5b-8a34b5179a3a	A	$1.5 \\times 10^8\\,\\text{m/s}$	0	\N
19f17bea-5a76-496d-b90f-48bfc54bf14e	0ecbb69a-5327-4480-ab5b-8a34b5179a3a	B	$2.0 \\times 10^8\\,\\text{m/s}$	1	\N
cfeb65db-f534-47e3-8777-f1b80d96e42f	0ecbb69a-5327-4480-ab5b-8a34b5179a3a	C	$3.0 \\times 10^8\\,\\text{m/s}$	2	\N
593fc14c-2120-4382-8c2e-95e325ad3d56	0ecbb69a-5327-4480-ab5b-8a34b5179a3a	D	$4.5 \\times 10^8\\,\\text{m/s}$	3	\N
a4af6e32-0e17-41fc-a505-8b5968914cd1	d3b41295-7f1b-48e9-a96a-52043440d70b	A	$100\\,\\text{D}$	0	\N
b35b0ff0-5a3b-46b1-a2c5-890f5d582b78	d3b41295-7f1b-48e9-a96a-52043440d70b	B	$1/100\\,\\text{D}$	1	\N
9ee4e897-4805-46e9-84ab-0d164c4518e5	d3b41295-7f1b-48e9-a96a-52043440d70b	C	$1/10\\,\\text{D}$	2	\N
7c038623-117d-49f1-a915-bbeed0310815	d3b41295-7f1b-48e9-a96a-52043440d70b	D	$1\\,\\text{D}$	3	\N
f86bd78f-f139-4088-acb2-c2e8c619062b	838997fc-c95f-428f-8c5c-30357c80a62a	A	$141$	0	\N
266884a0-a3c3-4400-88c8-4650f882a1d2	838997fc-c95f-428f-8c5c-30357c80a62a	B	$142$	1	\N
626c4c79-8832-4719-9209-02d06ff26c00	838997fc-c95f-428f-8c5c-30357c80a62a	C	$143$	2	\N
1628dbc7-a75d-4a9b-ae34-151697a658c2	838997fc-c95f-428f-8c5c-30357c80a62a	D	$144$	3	\N
be854851-5623-424c-80bb-f17b8516c8fe	9c09af5e-a1c7-4691-9711-b9cd745d9753	A	সরণ-সময় লেখচিত্রের নিচের ক্ষেত্রফল	0	\N
0411eb67-7dda-47a7-9447-c00c87d73734	9c09af5e-a1c7-4691-9711-b9cd745d9753	B	বল-সময় লেখচিত্রের নিচের ক্ষেত্রফল	1	\N
20faa255-cafe-4acf-bf2e-577175e144c6	9c09af5e-a1c7-4691-9711-b9cd745d9753	C	সরণ-সময় লেখচিত্রের ঢাল	2	\N
0f22f8ea-a2ae-458f-a84a-31f7fdf17d28	9c09af5e-a1c7-4691-9711-b9cd745d9753	D	ত্বরণ-সময় লেখচিত্রের ঢাল	3	\N
74be835b-a022-42d1-b90d-cef0811fba15	338d8dcd-bd80-427d-8c4b-7cefaa73721f	A	বিচ্ছুরণ	0	\N
1fe2327f-d3cf-48c4-847b-18d7224094c0	338d8dcd-bd80-427d-8c4b-7cefaa73721f	B	অপবর্তন	1	\N
704bfdcd-3ba1-4071-be10-9842ac82c26d	338d8dcd-bd80-427d-8c4b-7cefaa73721f	C	পূর্ণ-অভ্যন্তরীণ প্রতিফলন	2	\N
94b59696-7dd8-4f47-a33b-83da87914d0e	338d8dcd-bd80-427d-8c4b-7cefaa73721f	D	ব্যতিচার	3	\N
699b112e-f2d3-47c0-9004-aeabbfba2b4f	bd60af41-e47f-4b2f-b7a4-98ef83b9084d	A	$\\ce{Ni^{2+}}$	0	\N
5da94700-21ce-4974-b2a6-a0c39be1ebd6	bd60af41-e47f-4b2f-b7a4-98ef83b9084d	B	$\\ce{Fe^{2+}}$	1	\N
3a919ac8-e1d1-4bdf-91ce-4be2fea2d607	bd60af41-e47f-4b2f-b7a4-98ef83b9084d	C	$\\ce{Cu^{2+}}$	2	\N
da3f9858-56ec-4cf4-b7c7-8ce3cd75a8b3	bd60af41-e47f-4b2f-b7a4-98ef83b9084d	D	$\\ce{Zn^{2+}}$	3	\N
b519d49d-d40b-44fa-a7c6-c5a84004d9d9	816bbb35-34a6-4bae-baec-e4e2c5eeb8a6	A	$\\ce{F2ClC-CClF2}$	0	\N
5258f522-0704-404c-b520-b81a83f73538	816bbb35-34a6-4bae-baec-e4e2c5eeb8a6	B	$\\ce{C6H5-CN}$	1	\N
5d8a40b4-f8cc-456e-b676-f7f6d100249f	816bbb35-34a6-4bae-baec-e4e2c5eeb8a6	C	$\\ce{CCl3-NO2}$	2	\N
b0a63471-d7dd-4ea6-ac4c-9c284e118132	816bbb35-34a6-4bae-baec-e4e2c5eeb8a6	D	$\\ce{(CH3)3C-OH}$	3	\N
a75208ac-9515-4de7-9e3b-1ec095f00e8d	c4cc621e-d237-415f-9ea9-f8bb51f40fe8	A	Produced by the homolytic scission of $\\sigma$-bond	0	\N
c22f8b7b-4bef-45ea-8e45-406dc10b1d2b	c4cc621e-d237-415f-9ea9-f8bb51f40fe8	B	Produced by the heterolytic scission of $\\sigma$-bond	1	\N
6736aeea-f816-4b79-8d20-bff93b784751	c4cc621e-d237-415f-9ea9-f8bb51f40fe8	C	It is very unstable	2	\N
3670ac90-3621-4ab8-bd5a-e139e1a75451	c4cc621e-d237-415f-9ea9-f8bb51f40fe8	D	Number of protons and electrons are equal in it	3	\N
ed7eac79-1c6b-49b6-8534-caaa656ead1f	07e159ce-c75d-4515-aa66-29e1c860d3f4	A	$12$	0	\N
4f1f9c51-bc5a-41d1-819d-2e7eeee5b974	07e159ce-c75d-4515-aa66-29e1c860d3f4	B	$18$	1	\N
2efdbe2c-8701-4a9e-9e02-ad035c3cdbc1	07e159ce-c75d-4515-aa66-29e1c860d3f4	C	$14$	2	\N
50274c4e-637f-428a-b19d-63310c25d943	07e159ce-c75d-4515-aa66-29e1c860d3f4	D	$16$	3	\N
150db96e-b379-4eba-b5e0-b3e0dee55bcf	2c305db3-16c3-4530-a455-8f9db42746ed	A	$-d[A]/dt = k[A][B]$	0	\N
0fc94756-f095-4c35-87dd-99e0f4a180d0	2c305db3-16c3-4530-a455-8f9db42746ed	B	$-d[B]/dt = k[A][B]^2$	1	\N
fcde7642-b1b3-46bb-a6b9-1871fe82a95a	2c305db3-16c3-4530-a455-8f9db42746ed	C	$d[P]/dt = k[P]^\\alpha$	2	\N
24ee1943-5385-4598-8fb1-e8002a9057d6	2c305db3-16c3-4530-a455-8f9db42746ed	D	$d[P]/dt = k[A]^̑[B]^̑$	3	\N
2dc2cdc2-0d52-4135-8c34-064f9f50c8cc	9257ad0d-f357-442a-8e42-1580316a87fa	A	Iodoform test	0	\N
11eb2cd2-4fb2-4bfa-8a15-12423a9a87d9	9257ad0d-f357-442a-8e42-1580316a87fa	B	Carbylamine test	1	\N
7d227d59-180b-443b-b263-e68c7662e3cf	9257ad0d-f357-442a-8e42-1580316a87fa	C	Ninhydrin test	2	\N
a47734db-883f-46e3-9106-f846b57fd822	9257ad0d-f357-442a-8e42-1580316a87fa	D	Tollen's reagent	3	\N
f791e978-386e-45cd-9869-e5a753dab023	4f25ecab-439f-4260-a0f2-64396678d17d	A	Cyclohexane	0	\N
570f0006-7c22-4a30-99ef-531436c74605	4f25ecab-439f-4260-a0f2-64396678d17d	B	Benzene	1	\N
0276ca33-8b73-48ec-9e8b-3b31bfe1b908	4f25ecab-439f-4260-a0f2-64396678d17d	C	Toluene	2	\N
31c0eee1-0ed4-4c8b-a18f-1eae0bbf2307	4f25ecab-439f-4260-a0f2-64396678d17d	D	n-butane	3	\N
e78ea449-8595-480f-bd31-c04b4a16dadb	664bc991-eece-45c1-8784-3f14656648a8	A	Aniline	0	\N
2bd7eefe-a7bd-4d61-b348-0b252607e472	664bc991-eece-45c1-8784-3f14656648a8	B	Nitrobenzene	1	\N
5286ffb4-158c-4f30-a27b-d12b29392f5d	664bc991-eece-45c1-8784-3f14656648a8	C	Nitroanilide	2	\N
798d6288-efbd-417d-9d45-07ffc69d5cc8	664bc991-eece-45c1-8784-3f14656648a8	D	Diphenyl amide	3	\N
e00b9224-c77a-436b-a8ed-67d045caf393	e08fd6ff-3066-48f6-b9ce-d3bd8c01f09d	A	Atomic radius	0	\N
e5254ed0-95f3-4bf8-a044-3b717adbc109	e08fd6ff-3066-48f6-b9ce-d3bd8c01f09d	B	Electronegativity	1	\N
65d050f2-2222-410b-9bcf-87ad49933286	e08fd6ff-3066-48f6-b9ce-d3bd8c01f09d	C	Electron affinity	2	\N
43539070-a012-495f-b3c6-5fd6607c133f	e08fd6ff-3066-48f6-b9ce-d3bd8c01f09d	D	Melting temperature	3	\N
ccd1f77a-deb4-485f-bfd6-f349e00b7e0e	89dfebc4-65e9-4c03-bba7-d48a9dc5a24f	A	Equilibrium constant increases	0	\N
2af57718-6a6f-4cc7-ad4e-78acf9a1160c	89dfebc4-65e9-4c03-bba7-d48a9dc5a24f	B	Equilibrium shifts to left	1	\N
143758ac-8401-451c-a69d-2550ca21c772	89dfebc4-65e9-4c03-bba7-d48a9dc5a24f	C	Equilibrium is unaltered	2	\N
af8142fb-d733-4557-a0c9-424328f0219c	89dfebc4-65e9-4c03-bba7-d48a9dc5a24f	D	Equilibrium shifts to right	3	\N
c8c9a1cc-76f3-46e7-8312-7c52f79cdfad	72a404da-1b6a-4d45-9af7-fdcdf2bcaa68	A	Ethyne	0	\N
147f8f4b-f92d-4b13-b85a-9cf6a13b259e	72a404da-1b6a-4d45-9af7-fdcdf2bcaa68	B	Ethene	1	\N
631caef2-1089-44eb-ab02-44c55169d242	72a404da-1b6a-4d45-9af7-fdcdf2bcaa68	C	Ethanol	2	\N
016a4603-715e-49b4-a5fa-8011e715ba82	72a404da-1b6a-4d45-9af7-fdcdf2bcaa68	D	Ethane	3	\N
e1dd615e-be2b-42e8-a60b-03302f258d10	83765096-e851-4699-a569-2839fc554f77	A	$\\ce{CH#CH}$	0	\N
4f05c1b7-d671-4c42-b86d-b874fd20746f	83765096-e851-4699-a569-2839fc554f77	B	$\\ce{CH2=CHCl}$	1	\N
fd15ae67-fc7f-4c87-8c08-b2a0d8fba8d5	83765096-e851-4699-a569-2839fc554f77	C	$\\ce{ClCH=CHCl}$	2	\N
f13b32ad-a053-45d9-ba2f-4d5bd09c99fc	83765096-e851-4699-a569-2839fc554f77	D	$\\ce{CH2=CHCH2Cl}$	3	\N
87b49b6f-3bff-4431-a139-40c9e9b27e42	c6f32376-7456-450a-a70d-c767370577b4	A	Distillation	0	\N
941f81c5-3da6-40fe-a6d7-48531403d946	c6f32376-7456-450a-a70d-c767370577b4	B	Steam distillation	1	\N
b271e153-8ab7-42a9-8e6a-8a1554bbcbcf	c6f32376-7456-450a-a70d-c767370577b4	C	Sublimation	2	\N
338bb43c-afe7-416e-9276-16b403e5d49d	c6f32376-7456-450a-a70d-c767370577b4	D	Fractional distillation	3	\N
d8c1345d-7a3b-4581-8ccd-e8c4f24bacfa	f2267763-fb03-42a3-894c-b9854e737e1f	A	$\\ce{OH-, Cl-, Na+}$	0	\N
c2d1a851-1f84-468e-8138-9311ccc36138	f2267763-fb03-42a3-894c-b9854e737e1f	B	$\\ce{OH-, Cl-, H+}$	1	\N
89dca635-f94a-4883-8148-e0a436d455a9	f2267763-fb03-42a3-894c-b9854e737e1f	C	$\\ce{H+, Cl-, Na+}$	2	\N
624f3d68-c826-499e-99ad-a379be54b4e9	f2267763-fb03-42a3-894c-b9854e737e1f	D	$\\ce{H+, Cl-, Na+, OH-}$	3	\N
15a369bd-cd82-476e-8208-79bd0517777d	413d4cdd-6355-419d-8748-b74dc8d6e47a	A	$\\ce{K4[Fe(CN)6]}$	0	\N
55d3b4a4-19db-4fae-8ef3-17d943b220d9	413d4cdd-6355-419d-8748-b74dc8d6e47a	B	$\\ce{[Co(NH3)6]Cl3}$	1	\N
cdaa48e5-0fcc-41ac-91d8-75d9a3f4df79	413d4cdd-6355-419d-8748-b74dc8d6e47a	C	$\\ce{[Fe(H2O)6]Cl3}$	2	\N
7d9133be-7311-4087-8b8d-d0f09ab0dff2	413d4cdd-6355-419d-8748-b74dc8d6e47a	D	$\\ce{[Cu(NH3)4]Cl2}$	3	\N
adb0d8d4-d838-4cc4-87ff-7fe28f6b1a02	a1f16c35-2a65-4030-962a-ecaf97d66c2f	A	Potassium nitrate	0	\N
7cc6aee1-e713-4670-ac68-ccffc61304e3	a1f16c35-2a65-4030-962a-ecaf97d66c2f	B	TSP	1	\N
0598ea82-dfdb-4c8f-89aa-bfd09ee0438f	a1f16c35-2a65-4030-962a-ecaf97d66c2f	C	Dolomite	2	\N
cd1ce4f7-1afb-4bc3-b909-053742ec5204	a1f16c35-2a65-4030-962a-ecaf97d66c2f	D	Silica	3	\N
a72e2b66-c2a3-43e6-8c4c-35223817203a	51763612-673d-4149-9e59-850e3835a7e0	A	Primary amine	0	\N
403f1dc5-f42a-4341-a151-1e76de02f7f9	51763612-673d-4149-9e59-850e3835a7e0	B	Aldehyde	1	\N
4975c7ab-987c-4b3b-bc9e-95c0934d76f7	51763612-673d-4149-9e59-850e3835a7e0	C	Amide	2	\N
d0edf337-842d-448e-82dd-75f3ad7eab7f	51763612-673d-4149-9e59-850e3835a7e0	D	Primary alcohol	3	\N
e1f3943d-8e08-4939-b39d-e7e666385716	0ee5ddf0-213f-422f-8bef-a7da9d44352f	A	Low temperature and high pressure	0	\N
3e090212-dd37-4c95-98c6-9bdef804b6ad	0ee5ddf0-213f-422f-8bef-a7da9d44352f	B	High temperature and low pressure	1	\N
cf4b7156-9b57-493c-94b5-654fc1473e5b	0ee5ddf0-213f-422f-8bef-a7da9d44352f	C	Absolute zero temperature	2	\N
2451ee2b-3a40-4e03-b043-8fde6aed7099	0ee5ddf0-213f-422f-8bef-a7da9d44352f	D	High pressure	3	\N
0208df91-dad6-4d18-beb3-b9d3756cd619	d721f23e-f8af-405e-8f83-34378a70d728	A	$3400, 1700\\,\\text{cm}^{-1}$	0	\N
cd32bb1a-239c-4556-af9b-0c542ff466ef	d721f23e-f8af-405e-8f83-34378a70d728	B	$2800, 1700\\,\\text{cm}^{-1}$	1	\N
8aabaff6-eba9-47ea-b91f-7161fccc99a3	d721f23e-f8af-405e-8f83-34378a70d728	C	$3400, 1400\\,\\text{cm}^{-1}$	2	\N
a1655ce0-2d91-463b-b931-05b2374462da	d721f23e-f8af-405e-8f83-34378a70d728	D	$2500, 1000\\,\\text{cm}^{-1}$	3	\N
d66a2a92-935b-4979-99ef-aa9eeab6ad12	49bfe20a-d222-4189-b848-04925f7086a7	A	Sublimation	0	\N
89fc2746-7f22-4b02-bbc2-b0f49d7c3960	49bfe20a-d222-4189-b848-04925f7086a7	B	Evaporation	1	\N
39951bfd-4a26-4a33-bfd3-899125bbc55e	49bfe20a-d222-4189-b848-04925f7086a7	C	Freezing	2	\N
a4dd6ad8-0e59-42f6-a166-17bbbd814f07	49bfe20a-d222-4189-b848-04925f7086a7	D	Boiling	3	\N
49024f64-d191-4e3c-b22a-9d2b20f703c4	9bfa121a-95a9-4f33-a552-48f13675a94b	A	3	0	\N
428c62d3-fdd1-4f43-a4bf-a6688bd5dd6f	9bfa121a-95a9-4f33-a552-48f13675a94b	B	4	1	\N
0a84dd7c-e991-47b6-89ec-b401975a6c64	9bfa121a-95a9-4f33-a552-48f13675a94b	C	5	2	\N
0049f812-4734-4838-80dd-0fed7679ca34	9bfa121a-95a9-4f33-a552-48f13675a94b	D	6	3	\N
29fb1a8e-bb5d-4fc8-866e-5ae5e8722de5	26dfe77c-efc3-4080-963d-cf32abdb13b6	A	First order	0	\N
c0747357-99fe-4b8d-9909-ec51687d64b5	26dfe77c-efc3-4080-963d-cf32abdb13b6	B	Zero order	1	\N
726a76cb-23ce-4bc9-912e-70cdb3e36fd5	26dfe77c-efc3-4080-963d-cf32abdb13b6	C	Second order	2	\N
ab60e497-58af-4262-8877-57301fce3d44	26dfe77c-efc3-4080-963d-cf32abdb13b6	D	Fractional order	3	\N
16e1a49b-274f-4a38-8e8e-cbdebd3f85d4	07ac1fdd-07d6-48fe-a989-0981f110d6f3	A	13, 1	0	\N
a9269efd-eec2-48e8-aa9d-0cd4a8fe0602	07ac1fdd-07d6-48fe-a989-0981f110d6f3	B	14, 0	1	\N
5b9d2985-2996-4e45-8d53-fb35dd164b27	07ac1fdd-07d6-48fe-a989-0981f110d6f3	C	12, 2	2	\N
87f21cf4-027a-449a-b227-de0c138fb991	07ac1fdd-07d6-48fe-a989-0981f110d6f3	D	1, 13	3	\N
3b32cc12-c0b2-470c-8c59-f190a800018d	1751398b-f5bb-46c5-b484-2513d8290a3d	A	$\\ce{BaCO3 < SrCO3 < CaCO3 < MgCO3 < BeCO3}$	0	\N
d4f0d6a0-0b87-4cd8-bdfe-0c3ebd29e24c	1751398b-f5bb-46c5-b484-2513d8290a3d	B	$\\ce{BeCO3 > MgCO3 > CaCO3 > SrCO3 > BaCO3}$	1	\N
61d67fb9-f2c3-457b-ad3b-651b568772ed	1751398b-f5bb-46c5-b484-2513d8290a3d	C	$\\ce{BaCO3 > SrCO3 > CaCO3 > MgCO3 > BeCO3}$	2	\N
eecb05b5-3e3c-4b97-8003-658081baab5d	1751398b-f5bb-46c5-b484-2513d8290a3d	D	$\\ce{MgCO3 > CaCO3 > SrCO3 > BeCO3 > BaCO3}$	3	\N
1cc1b02e-4d48-4d12-8d42-012cd70a1bb8	94483e8c-3caa-435f-b8a6-427ab98d5223	A	$\\ce{H2SO4}$	0	\N
bf23d07f-f9ee-4abb-a6a3-52f9e8782042	94483e8c-3caa-435f-b8a6-427ab98d5223	B	$\\ce{HBrO4}$	1	\N
19338ff0-9a37-42de-aa98-01068d8a513f	94483e8c-3caa-435f-b8a6-427ab98d5223	C	$\\ce{HNO3}$	2	\N
7ab97bef-73dd-4105-a205-d1f49e7a762f	94483e8c-3caa-435f-b8a6-427ab98d5223	D	$\\ce{HClO4}$	3	\N
f566fc4a-d3c5-48fe-a1e0-578f8d1629ce	d3bb3752-0477-4cb2-9469-31c3bfeb8775	A	Arrhenius equation	0	\N
3765034a-cd19-48a7-8f8a-9cba197d0f25	d3bb3752-0477-4cb2-9469-31c3bfeb8775	B	Perfect gas equation	1	\N
d9ae7234-34b5-4331-8554-f359c45367f5	d3bb3752-0477-4cb2-9469-31c3bfeb8775	C	Einstein equation	2	\N
2630f2b8-53d3-4762-a778-d96db1089e77	d3bb3752-0477-4cb2-9469-31c3bfeb8775	D	Faraday equation	3	\N
c6e3b249-e38e-42a7-b6cd-dee58b5b3e17	75971f6b-4db1-4a85-bb4c-348f436bd47a	A	$\\ce{CH3COOC2H5}$	0	\N
4223cb85-2261-4941-8b4d-6dfab1c85cea	75971f6b-4db1-4a85-bb4c-348f436bd47a	B	$\\ce{C2H4}$	1	\N
0cbbee58-fa55-41c1-9147-775fbfd0584f	75971f6b-4db1-4a85-bb4c-348f436bd47a	C	$\\ce{C2H2}$	2	\N
16a68bcc-ff99-45c3-bce6-f53482243426	75971f6b-4db1-4a85-bb4c-348f436bd47a	D	$\\ce{C2H6}$	3	\N
cbf802c3-53e3-4d23-83e3-c081ce108bf5	28e0109a-abc4-410f-98df-7b0ab3e06b62	A	$106\\,\\text{g}$	0	\N
0c1dcaa6-6e4d-4dd6-8d8f-3cfd8f2910d8	28e0109a-abc4-410f-98df-7b0ab3e06b62	B	$53\\,\\text{g}$	1	\N
60cef9d8-fc73-4221-975c-fafa50e56c6d	28e0109a-abc4-410f-98df-7b0ab3e06b62	C	$10.6\\,\\text{g}$	2	\N
5fd3bc53-e61c-494e-8fd4-45693599ea80	28e0109a-abc4-410f-98df-7b0ab3e06b62	D	$5.3\\,\\text{g}$	3	\N
0cb28cf4-4ab1-441c-abfb-7a29fd778956	a1216396-dd21-4d46-b6d9-5f9baa33c0ad	A	$\\ce{H2NCONH2}$	0	\N
495d1412-1844-4061-a4ae-1b29ecd12eb6	a1216396-dd21-4d46-b6d9-5f9baa33c0ad	B	$\\ce{NH4OH}$	1	\N
d0d81a46-4ff2-40a5-922d-80150a5df45c	a1216396-dd21-4d46-b6d9-5f9baa33c0ad	C	$\\ce{NO3^-}$ salt	2	\N
e93342d4-3a11-4937-aa27-d18913186fe4	a1216396-dd21-4d46-b6d9-5f9baa33c0ad	D	$\\ce{NO2^-}$ salt	3	\N
31c24121-42bc-4a15-9c64-0e6c63deeeca	73025035-d12c-4dd3-a548-a066ef26a300	A	$7x - 5y - 29 = 0$	0	\N
8058796e-b324-4f84-81fb-ea8cfb836b8d	73025035-d12c-4dd3-a548-a066ef26a300	B	$5x - 7y - 31 = 0$	1	\N
47189dca-fe5b-4180-934f-84d346cb9af5	73025035-d12c-4dd3-a548-a066ef26a300	C	$5x + 7y + 11 = 0$	2	\N
ce2a05c2-612e-4e01-8688-01ae015491bc	73025035-d12c-4dd3-a548-a066ef26a300	D	$7x + 5y + 1 = 0$	3	\N
05ef08bf-3995-4c87-b4cb-ac6bda71ce14	14495dd6-f4c8-48c2-9cea-e1f1c93b92a8	A	$\\frac{1}{\\sqrt{13}}$	0	\N
61cfdb12-4343-477f-8ca7-2e7f5d8a12d0	14495dd6-f4c8-48c2-9cea-e1f1c93b92a8	B	$\\frac{2}{\\sqrt{13}}$	1	\N
cf7123b9-4a20-4fe7-8501-b6b38eb6782c	14495dd6-f4c8-48c2-9cea-e1f1c93b92a8	C	$\\frac{3}{\\sqrt{13}}$	2	\N
f44866ef-5798-4152-a0f3-af35d1ff9568	14495dd6-f4c8-48c2-9cea-e1f1c93b92a8	D	$\\frac{4}{\\sqrt{13}}$	3	\N
052f1658-13a5-4e1b-8470-d6289cb1afa6	76343b23-ae51-4c07-9734-a17b5fb17fa4	A	$30^\\circ$	0	\N
a43f23e2-be06-4e3c-9639-1e648cb06aa3	76343b23-ae51-4c07-9734-a17b5fb17fa4	B	$45^\\circ$	1	\N
6ac1d9f4-3680-4d39-993a-390d665d5823	76343b23-ae51-4c07-9734-a17b5fb17fa4	C	$60^\\circ$	2	\N
78fc4779-c391-4f61-8f56-a357e6d8b259	76343b23-ae51-4c07-9734-a17b5fb17fa4	D	$75^\\circ$	3	\N
68995083-d55e-40ab-bcab-460886947eae	91f2907b-13de-4f68-89c3-26664aff072b	A	$\\frac{\\pi}{6}, \\frac{5\\pi}{6}$	0	\N
056f4663-1fae-4d56-b5ee-823226bc5e13	91f2907b-13de-4f68-89c3-26664aff072b	B	$-\\frac{\\pi}{6}, \\frac{5\\pi}{6}$	1	\N
3e29c25d-5c03-46d5-853e-e92f2b213ca1	91f2907b-13de-4f68-89c3-26664aff072b	C	$\\frac{\\pi}{6}, -\\frac{5\\pi}{6}$	2	\N
dc8fc77d-d2ec-4838-b042-7a1742f2cb39	91f2907b-13de-4f68-89c3-26664aff072b	D	$\\frac{\\pi}{6}, \\frac{5\\pi}{6}$	3	\N
f8e39395-1b6b-4a13-b466-4b85a0a70832	fcbfeb79-7f9b-4168-a154-8268ad3ffaaf	A	$4$ and $2$	0	\N
1746f1a8-a00b-43ea-aab0-273214c77bde	fcbfeb79-7f9b-4168-a154-8268ad3ffaaf	B	$2$ and $4$	1	\N
55e39801-87ef-4699-9a1b-7015526ed32a	fcbfeb79-7f9b-4168-a154-8268ad3ffaaf	C	$\\sqrt{2}$ and $2\\sqrt{2}$	2	\N
ab54c3ec-d43e-41b1-a7ce-ad679917231b	fcbfeb79-7f9b-4168-a154-8268ad3ffaaf	D	$2\\sqrt{2}$ and $\\sqrt{2}$	3	\N
228400d2-9c62-40b2-88b8-5e63ac36bf47	1fbc98e0-4c41-4d0b-bcf3-b78ba3170441	A	$e$	0	\N
0ce1ab07-eda4-4bc5-9328-b94fac6640d6	1fbc98e0-4c41-4d0b-bcf3-b78ba3170441	B	$1$	1	\N
17ec44d2-96fc-479a-8b3f-0000aad7ddae	1fbc98e0-4c41-4d0b-bcf3-b78ba3170441	C	$\\frac{1}{e}$	2	\N
ac7b3168-f2dd-4812-888e-5a6d4913a8d4	1fbc98e0-4c41-4d0b-bcf3-b78ba3170441	D	$0$	3	\N
11033a1c-88ca-45f2-87a6-2fe19bd0d867	278a11e6-e51a-4147-ab85-5b33145c4b4f	A	$\\frac{5}{4}$	0	\N
a29ce6f0-f68e-40b3-80c8-6d4cd8390e98	278a11e6-e51a-4147-ab85-5b33145c4b4f	B	$\\frac{4}{3}$	1	\N
660d2704-61b6-4a51-972f-4099bf4123e9	278a11e6-e51a-4147-ab85-5b33145c4b4f	C	$\\frac{5}{3}$	2	\N
679f8331-6518-44f8-9a22-8f8a66dc7903	278a11e6-e51a-4147-ab85-5b33145c4b4f	D	$5$	3	\N
2efc3e7e-0c25-4eb7-84a6-b63fca15cfc9	e73a39b5-852e-4ff6-941c-17bf84b210d2	A	$2\\pi$ sq.units	0	\N
8ac6f6bc-884d-43c5-8427-cc38b28fc485	e73a39b5-852e-4ff6-941c-17bf84b210d2	B	$3\\pi$ sq.units	1	\N
88138e45-7f13-4240-aaa9-1ac2fbd48b9e	e73a39b5-852e-4ff6-941c-17bf84b210d2	C	$4\\pi$ sq.units	2	\N
43dcb69a-e263-4bb0-baca-50000bd3d305	e73a39b5-852e-4ff6-941c-17bf84b210d2	D	$5\\pi$ sq.units	3	\N
4f8ea33e-a25f-4a1c-bb95-fa2a3984965a	6fb6e116-0fd3-471d-ba3c-ba45510a024b	A	$x = \\pm 2$	0	\N
a3fff275-4c97-4489-a4aa-550ae0f8aa93	6fb6e116-0fd3-471d-ba3c-ba45510a024b	B	$1$	1	\N
634597c0-11e9-4db1-8357-9f8484e8594d	6fb6e116-0fd3-471d-ba3c-ba45510a024b	C	$\\pm 1$	2	\N
6887c3b9-cfd4-435f-aeb0-5016291be373	6fb6e116-0fd3-471d-ba3c-ba45510a024b	D	$\\pm \\frac{3}{2}$	3	\N
dc1a88c3-f8e9-41b7-8688-5a012445c5d3	4592e698-0afb-4d68-9d5b-4ff5996e72c0	A	$(\\frac{9}{4}, -1)$	0	\N
29aa99d9-315d-4885-8170-83a58d013616	4592e698-0afb-4d68-9d5b-4ff5996e72c0	B	$(-\\frac{9}{4}, -1)$	1	\N
ce9133d0-f55d-480b-b3c3-10f6f2584fc3	4592e698-0afb-4d68-9d5b-4ff5996e72c0	C	$(0, 2)$	2	\N
98fd6670-f19a-4266-aca6-916170aa50ae	4592e698-0afb-4d68-9d5b-4ff5996e72c0	D	$(2, 0)$	3	\N
b553188f-772e-4358-b3f6-5cc58adc5887	b719be80-d9d9-4ab9-ac30-4f9ffb9e75f4	A	$\\sin x$	0	\N
13f99532-bc96-4c3b-bc2a-7b8f880ffcd6	b719be80-d9d9-4ab9-ac30-4f9ffb9e75f4	B	$\\cos x$	1	\N
273c9b82-25ca-442a-a201-de8f9171d904	b719be80-d9d9-4ab9-ac30-4f9ffb9e75f4	C	$x$	2	\N
c9e74a26-db13-4b24-8880-a371b7e9518b	b719be80-d9d9-4ab9-ac30-4f9ffb9e75f4	D	$1$	3	\N
d2cefc5c-aed6-4182-8a4f-e7e273a0e5b9	c58cb579-ea91-40a0-9671-5caff7d789c3	A	$-1$	0	\N
69d564ab-37f9-41e5-ada4-c7f6f8c025f0	c58cb579-ea91-40a0-9671-5caff7d789c3	B	$0$	1	\N
e787a9b1-9d4a-4ee7-8084-42dd33936800	c58cb579-ea91-40a0-9671-5caff7d789c3	C	$\\frac{1}{3}$	2	\N
68a8a661-e484-4d49-8e54-6bb5a7d58b3b	c58cb579-ea91-40a0-9671-5caff7d789c3	D	$1$	3	\N
55107c2d-45ca-4d24-873f-9962e3142407	3c8324f4-f243-40a5-9cf7-c8f0400442c9	A	$(-2, -2)$	0	\N
b7e90bf6-070a-4dc2-ad0e-8e4f5d5086e6	3c8324f4-f243-40a5-9cf7-c8f0400442c9	B	$(-2, 2)$	1	\N
29675fe4-3d46-46a1-a57d-99cdd1200a6b	3c8324f4-f243-40a5-9cf7-c8f0400442c9	C	$(2, -2)$	2	\N
0965fa45-1993-43be-8f51-aa24babb1947	3c8324f4-f243-40a5-9cf7-c8f0400442c9	D	$(2, 2)$	3	\N
0dea4dfc-ff14-46ed-be58-246f462a8abb	5a5757fc-54ec-42c9-8c7d-9e79e2b779ec	A	$x^2 + y^2 + 12x - 8y + 16 = 0$	0	\N
2ca25b01-b4c2-4c02-b93f-e852ab6c42ae	5a5757fc-54ec-42c9-8c7d-9e79e2b779ec	B	$x^2 + y^2 - 8x - 6y + 8 = 0$	1	\N
83ca9045-fdb6-4473-99ee-6f3bd6181992	5a5757fc-54ec-42c9-8c7d-9e79e2b779ec	C	$x^2 + y^2 - 12x - 8y + 16 = 0$	2	\N
6cbfabfb-2ff7-4133-85d2-41d37a171829	5a5757fc-54ec-42c9-8c7d-9e79e2b779ec	D	$x^2 + y^2 + 8x + 6y - 40 = 0$	3	\N
363fb7c5-4917-4b37-a5ff-04112abd245b	822237e1-862f-4d85-aa99-278dca464bcc	A	$-\\frac{5}{6}$	0	\N
711faa16-5bf5-40f9-afb1-2f1c332592e3	822237e1-862f-4d85-aa99-278dca464bcc	B	$-\\frac{1}{3}$	1	\N
2ddf37a0-e33b-41c6-9ec1-e069fddb8c99	822237e1-862f-4d85-aa99-278dca464bcc	C	$\\frac{1}{3}$	2	\N
4d6f8192-2b5f-416f-9b48-40f49acb25f7	822237e1-862f-4d85-aa99-278dca464bcc	D	$\\frac{2}{3}$	3	\N
64b83f00-64a3-42a4-9f8a-0d5a7c86e732	3a8afe71-35fc-4592-a122-8d83a713e9e2	A	$4\\sqrt{3}$ একক	0	\N
607896ed-92a6-4000-841a-488ae38b5ccb	3a8afe71-35fc-4592-a122-8d83a713e9e2	B	$7\\sqrt{3}$ একক	1	\N
da6c8f7f-4a7f-4ee2-8ef8-09d42ed43375	3a8afe71-35fc-4592-a122-8d83a713e9e2	C	$10\\sqrt{3}$ একক	2	\N
8adce56d-98b5-4c2f-a1bf-ec7bf70050bb	3a8afe71-35fc-4592-a122-8d83a713e9e2	D	$15\\sqrt{3}$ একক	3	\N
9c3c52d5-4663-499b-98ce-9547a3a262b1	3c7cac49-945e-475a-bcec-dd9baa98e4b4	A	$-3 < x < 3$	0	\N
25a2d724-fd14-4318-ab78-b5ad45bcf765	3c7cac49-945e-475a-bcec-dd9baa98e4b4	B	$-3 \\leq x < 3$	1	\N
4c6a63ac-aab0-426e-80d3-1c8f0edee466	3c7cac49-945e-475a-bcec-dd9baa98e4b4	C	$-3 < x \\leq 3$	2	\N
29947d3e-11bf-4f8a-8997-b3bfa7b54bbe	3c7cac49-945e-475a-bcec-dd9baa98e4b4	D	$-3 \\leq x \\leq 3$	3	\N
f958b6c9-39e3-482c-a939-9d11759f6906	53a06aa2-abf8-40e7-a48a-fe5ed88a006f	A	$-\\frac{1}{2}\\cos A$	0	\N
d6cd027b-f8ca-4dde-91ce-78a879687f8f	53a06aa2-abf8-40e7-a48a-fe5ed88a006f	B	$0$	1	\N
85818aeb-25f4-473b-be14-0e19531bf132	53a06aa2-abf8-40e7-a48a-fe5ed88a006f	C	$\\cos A$	2	\N
bccd7409-aad2-4b20-a842-f16096bca3c3	53a06aa2-abf8-40e7-a48a-fe5ed88a006f	D	$\\sin A$	3	\N
afb089ba-6621-4128-a903-277cb789b990	5b4a15e7-8b68-40a7-a5c1-9100079ec87e	A	$\\frac{1}{\\sqrt{2}}$	0	\N
5698b0f4-46d4-447d-94d7-d55329b720e0	5b4a15e7-8b68-40a7-a5c1-9100079ec87e	B	$\\frac{1}{2}$	1	\N
d6501d62-1360-484e-9234-aad2400ca1b1	5b4a15e7-8b68-40a7-a5c1-9100079ec87e	C	$\\frac{\\sqrt{3}}{2}$	2	\N
eb020ed5-c5ac-420c-8afc-c74f66870dd0	5b4a15e7-8b68-40a7-a5c1-9100079ec87e	D	$\\sqrt{2}$	3	\N
271b6cfd-b926-4bfc-b9b9-f02d6048922e	14bc131c-3a3c-496c-947c-029d7c7f9c86	A	$\\frac{5}{\\sqrt{38}}$	0	\N
2e410d17-6d3d-47eb-8c85-27e444271a1b	14bc131c-3a3c-496c-947c-029d7c7f9c86	B	$\\frac{3}{\\sqrt{38}}$	1	\N
ee647df3-a3d5-4b7f-b577-ae4d7695977f	14bc131c-3a3c-496c-947c-029d7c7f9c86	C	$\\frac{2}{\\sqrt{38}}$	2	\N
7d6e21bd-a7bc-4ebc-bd5f-c3a6617f7d9e	14bc131c-3a3c-496c-947c-029d7c7f9c86	D	$\\frac{1}{\\sqrt{38}}$	3	\N
d42d9301-7959-4b9c-b87e-24f4bfba88ce	494e26be-ddc6-46e8-8f85-02017a97a9a8	A	$0.5\\,\\text{s}$	0	\N
e4b787a3-2cbf-4f74-9fe6-ea9fdd683974	494e26be-ddc6-46e8-8f85-02017a97a9a8	B	$1\\,\\text{s}$	1	\N
d9ce0866-5953-4f75-aee9-4418e915c3ba	494e26be-ddc6-46e8-8f85-02017a97a9a8	C	$1.5\\,\\text{s}$	2	\N
3a385b14-fdb9-4cd4-862c-2c01d6cd0f45	494e26be-ddc6-46e8-8f85-02017a97a9a8	D	$2\\,\\text{s}$	3	\N
f4e72247-2aa4-4b8f-b056-689b2efb4457	9ad62dcb-36f2-4724-a79f-8a405e26a116	A	Circle	0	\N
c72b48ce-e0e4-4a13-9b01-fdec22da806e	9ad62dcb-36f2-4724-a79f-8a405e26a116	B	Parabola	1	\N
99dd56e0-9531-414b-8f14-b9b38bd58792	9ad62dcb-36f2-4724-a79f-8a405e26a116	C	Hyperbola	2	\N
37caa3f2-7aa8-40af-9b57-c8c08c237202	9ad62dcb-36f2-4724-a79f-8a405e26a116	D	Ellipse	3	\N
8be16fd5-10cd-4994-94b8-ff0ca9686be0	35a4c577-4532-465c-9034-2e13b7aab087	A	$1$	0	\N
63ac016a-d714-42b5-9cfc-10605fc8d98c	35a4c577-4532-465c-9034-2e13b7aab087	B	$\\frac{1}{2}$	1	\N
24f6ae7c-600f-4e9c-9e5f-dfed36fbe562	35a4c577-4532-465c-9034-2e13b7aab087	C	$-1$	2	\N
a60c8885-5bb3-4c1b-953b-9aa246d6a6e0	35a4c577-4532-465c-9034-2e13b7aab087	D	$-\\frac{1}{2}$	3	\N
2a403889-20bd-4f3d-8f5c-b863551c2319	96b1335d-6f4e-4999-897e-e9b5497af568	A	540	0	\N
80555869-834a-4a3a-92a6-4abe4cf191e5	96b1335d-6f4e-4999-897e-e9b5497af568	B	640	1	\N
78e9afc1-6b91-407e-b514-07dedbc1f691	96b1335d-6f4e-4999-897e-e9b5497af568	C	740	2	\N
f740af7e-af07-4bb0-a2c5-3ea6e6776a4c	96b1335d-6f4e-4999-897e-e9b5497af568	D	840	3	\N
0eaab085-35ff-48f7-83c6-c68463b6dd46	a9253795-0981-4530-836a-7708a2ae0b45	A	6	0	\N
cfc186e4-2440-4844-ba24-2732d450fd95	a9253795-0981-4530-836a-7708a2ae0b45	B	18	1	\N
b13f7423-f0cf-4ba0-8a93-57da51dc26b3	a9253795-0981-4530-836a-7708a2ae0b45	C	4	2	\N
10ecb1bf-c5ce-40a0-8201-54a53a033a0a	a9253795-0981-4530-836a-7708a2ae0b45	D	12	3	\N
815d0ea9-d755-458c-8e53-5df656711030	1434f64d-6b43-45c0-ab47-b89cad8465cc	A	10080	0	\N
5f421dd2-798c-4527-a336-8fa72cb48649	1434f64d-6b43-45c0-ab47-b89cad8465cc	B	9680	1	\N
c75219c0-7725-4e84-90fc-60d572c8dec8	1434f64d-6b43-45c0-ab47-b89cad8465cc	C	50720	2	\N
05bfeec0-8dcd-4484-9954-bf8dcf813ecd	1434f64d-6b43-45c0-ab47-b89cad8465cc	D	90720	3	\N
01d67501-45bd-474d-a1e4-856465452f9d	0bcd7650-c0f9-49fd-a011-7833c7b7bbd7	A	$\\{3, 5\\}$	0	\N
4f595e60-9262-4962-b86c-968f6fa04b88	0bcd7650-c0f9-49fd-a011-7833c7b7bbd7	B	$\\{1, 2, 9\\}$	1	\N
c5fb60b5-29ee-4242-b1cf-3c290603a515	0bcd7650-c0f9-49fd-a011-7833c7b7bbd7	C	$\\{3, 5, 10\\}$	2	\N
39878a1f-b669-48eb-8f80-de49d30f0636	0bcd7650-c0f9-49fd-a011-7833c7b7bbd7	D	$\\{1, 2, 3, 5, 9, 10\\}$	3	\N
2f0eb8d7-c991-4a4a-816b-96cb3c59c3fc	69ccb9cd-13f7-4e9a-acf2-88c246e38c07	A	$x - \\frac{x^3}{3!} + \\frac{x^5}{5!} - \\dots$	0	\N
9c963b7b-a270-45a5-a965-52c9179b0e3e	69ccb9cd-13f7-4e9a-acf2-88c246e38c07	B	$x + \\frac{x^3}{3!} + \\frac{x^5}{5!} + \\dots$	1	\N
2ed46c1a-eafa-4ee7-b105-be02a7014a62	69ccb9cd-13f7-4e9a-acf2-88c246e38c07	C	$1 + x + \\frac{x^3}{3!} + \\frac{x^5}{5!} + \\dots$	2	\N
759cccae-9423-4e3b-8eed-4c31d5090750	69ccb9cd-13f7-4e9a-acf2-88c246e38c07	D	$-x - \\frac{x^3}{3!} - \\frac{x^5}{5!} - \\dots$	3	\N
731fc79b-7435-4739-9a87-ffe6884cad5b	a5484c83-9534-4ac5-b60c-eb8ce222ccf6	A	$\\frac{15}{56}$	0	\N
35ff1d29-fc0d-438b-b506-674ee6afaf47	a5484c83-9534-4ac5-b60c-eb8ce222ccf6	B	$\\frac{3}{7}$	1	\N
112d7d05-d286-458d-96f7-ac6b5f0ab5b0	a5484c83-9534-4ac5-b60c-eb8ce222ccf6	C	$\\frac{28}{65}$	2	\N
49555038-6c37-48d9-81c1-b02e5f441867	a5484c83-9534-4ac5-b60c-eb8ce222ccf6	D	$\\frac{13}{22}$	3	\N
ea56a256-aa78-4d48-814e-7a688ba832e6	c34aa487-10b3-401a-9571-d771f69d09d8	A	$\\frac{1}{9}$	0	\N
d1bb1a92-27e3-49de-8aee-e7f9df03a9cd	c34aa487-10b3-401a-9571-d771f69d09d8	B	$\\frac{1}{8}$	1	\N
a573426b-7e24-4785-9e09-32177b7c81f8	c34aa487-10b3-401a-9571-d771f69d09d8	C	$8$	2	\N
b36fb2f3-d7c0-4158-9370-c99eade87949	c34aa487-10b3-401a-9571-d771f69d09d8	D	$9$	3	\N
cd766ceb-8947-4aa5-8bc3-34388241a08b	2d6c847e-a7b4-44c0-8392-a046d64740be	A	Prophase	0	\N
05d8fdf9-1240-4dcc-b64b-19ebe5264d91	2d6c847e-a7b4-44c0-8392-a046d64740be	B	Metaphase	1	\N
5b92516b-94e0-4ad1-89cd-cf49c8d68d3e	2d6c847e-a7b4-44c0-8392-a046d64740be	C	Anaphase	2	\N
50e275fd-a144-414a-a595-f29651ea25f9	2d6c847e-a7b4-44c0-8392-a046d64740be	D	Telophase	3	\N
a5b0b8c5-951f-4bf6-9b3c-1659b10ea551	fbb20a08-77e8-4cf1-8639-713fba6275e2	A	Malic acid	0	\N
af3bbb73-fe75-40d4-bace-5e0eda72cf16	fbb20a08-77e8-4cf1-8639-713fba6275e2	B	Oxaloacetic acid	1	\N
ce03335e-375f-40fb-b489-32e01b231785	fbb20a08-77e8-4cf1-8639-713fba6275e2	C	Pyruvic acid	2	\N
2125b9a2-0075-4928-9d45-2cb849735130	fbb20a08-77e8-4cf1-8639-713fba6275e2	D	Phosphoglyceric acid	3	\N
76ec4f2f-a47d-4bdf-a3cd-3ca3d6b03f5b	15c9bfc4-c6e6-474a-84b7-9ea57e556064	A	বেসাল	0	\N
b9edf1eb-e50e-476b-90a6-51d5df526458	15c9bfc4-c6e6-474a-84b7-9ea57e556064	B	শীর্ষক	1	\N
1315c10a-01e9-4585-9ffc-ef6abcf86352	15c9bfc4-c6e6-474a-84b7-9ea57e556064	C	এক প্রান্তীয়	2	\N
2e112193-4524-492d-bbf3-c57241eb6197	15c9bfc4-c6e6-474a-84b7-9ea57e556064	D	প্যারাইটাল	3	\N
630fc8f7-039c-4d2c-836b-0225c6a080a4	92005291-f426-4e0f-818c-48beef76042b	A	শীর্ষস্থ ভাজক টিস্যু	0	\N
583073e1-002c-4bb5-9a2d-a1cacec2c433	92005291-f426-4e0f-818c-48beef76042b	B	প্রাইমারি জাইলেম টিস্যু	1	\N
5a82f4b1-f095-481a-9268-f8c48089d0ed	92005291-f426-4e0f-818c-48beef76042b	C	সেকেন্ডারি জাইলেম টিস্যু	2	\N
8e9222fd-6985-4ccc-a0ac-a2c34e0fc5db	92005291-f426-4e0f-818c-48beef76042b	D	সেকেন্ডারি ফ্লোয়েম টিস্যু	3	\N
68fbe0f7-3dff-4b22-a774-9f6bbe17d65e	e62596bd-c9e8-4dfd-8dd2-1e5cabb12725	A	*Solanum nigrum*	0	\N
4bd659ca-490f-40cf-b717-65a6a85d478d	e62596bd-c9e8-4dfd-8dd2-1e5cabb12725	B	*Solanum melongena*	1	\N
dbae4d3d-224c-420d-9784-36f20c1cd640	e62596bd-c9e8-4dfd-8dd2-1e5cabb12725	C	*Parthenium argentatum*	2	\N
e12e54e5-95ed-47f8-975d-dd4275d179db	e62596bd-c9e8-4dfd-8dd2-1e5cabb12725	D	*Taraxacum albidum*	3	\N
34b9c3af-04f4-4138-a920-46372c79a881	0b1c1d43-442e-46a7-81e3-a76cc54f365a	A	ক্রেবস চক্র	0	\N
3316a078-82ec-4c33-9932-0eebca0d03ef	0b1c1d43-442e-46a7-81e3-a76cc54f365a	B	হ্যাচ ও স্ল্যাক চক্র	1	\N
bb75f0ef-205f-4b59-8334-15415fbf2ffe	0b1c1d43-442e-46a7-81e3-a76cc54f365a	C	ক্যালভিন চক্র	2	\N
873cae33-ac0b-4bb2-8227-4a55e81593b1	0b1c1d43-442e-46a7-81e3-a76cc54f365a	D	চক্রীয় ফটোফসফোরাইলেশন	3	\N
dd34c971-7c73-4ca7-a6e1-1d54272267d9	bfe7b666-a851-4156-a5aa-dd164029ebf7	A	মেসোগ্লিয়া	0	\N
31e93588-45c8-4990-8316-09cbf55ed462	bfe7b666-a851-4156-a5aa-dd164029ebf7	B	সিলেন্টেরন	1	\N
7cfc1fbb-c510-4209-b310-2a27b0d19094	bfe7b666-a851-4156-a5aa-dd164029ebf7	C	মেসোডার্ম	2	\N
2d861d79-e59e-407e-8489-edd1e574b232	bfe7b666-a851-4156-a5aa-dd164029ebf7	D	নিডোসাইট	3	\N
0503841f-ffdf-4cac-934d-fa57660ce46b	89ac0c06-7b1c-4c99-a632-595114dbf986	A	Cypriniformes	0	\N
6793d9ae-0bad-4e84-8a6b-50d85f274fa1	89ac0c06-7b1c-4c99-a632-595114dbf986	B	Clupeiformes	1	\N
9547756c-ba20-493b-a187-7e5e09556233	89ac0c06-7b1c-4c99-a632-595114dbf986	C	Siluriformes	2	\N
87718a91-4236-444f-983b-8548329845f2	89ac0c06-7b1c-4c99-a632-595114dbf986	D	Channiformes	3	\N
881e5214-6296-4bdc-937c-825ff478673b	6b3de2ef-eac7-49cf-b36a-382a09a64f19	A	অ্যাড্রিনালিন	0	\N
62765a62-8988-44bb-8d98-e557a841903a	6b3de2ef-eac7-49cf-b36a-382a09a64f19	B	ইনসুলিন	1	\N
85590074-acea-4d64-9c7f-73a55c65a4a4	6b3de2ef-eac7-49cf-b36a-382a09a64f19	C	প্যারাথরমন	2	\N
b59d93cf-4194-4fdd-9027-6e8e0e88d929	6b3de2ef-eac7-49cf-b36a-382a09a64f19	D	সোমাটোট্রপিন	3	\N
1f5ee164-d635-4c20-af1a-9b6c4ea1c977	75138e12-93c2-4a7b-b86c-5c95a065bf15	A	কার্প	0	\N
39e0c521-c955-4093-9598-9cafe0059d12	75138e12-93c2-4a7b-b86c-5c95a065bf15	B	বোয়াল	1	\N
807f183e-8521-465d-a5d8-4017b9648f85	75138e12-93c2-4a7b-b86c-5c95a065bf15	C	সিলভার ফিশ	2	\N
6c6d450c-c6a5-4571-a8a6-e9cbf005e18e	75138e12-93c2-4a7b-b86c-5c95a065bf15	D	ক্যাটফিস	3	\N
6bda1b49-c50a-428a-91bb-6543393c2178	f430ea32-c5dc-4851-9992-938cb2c77a2a	A	পেরিকার্ডিয়াম	0	\N
4b579c16-a632-404e-ae99-02cc4bb004a4	f430ea32-c5dc-4851-9992-938cb2c77a2a	B	পেরিঅস্টিয়াম	1	\N
9721f5ba-df4b-429e-89ff-b1f89c6e6881	f430ea32-c5dc-4851-9992-938cb2c77a2a	C	প্লুরা	2	\N
b8c5077a-ba55-4b89-b27c-d77a1ecd7643	f430ea32-c5dc-4851-9992-938cb2c77a2a	D	পেরিকন্ড্রিয়াম	3	\N
9a4ac4fd-aedd-450b-8761-16eff02ec419	485e6fce-a058-4ec1-a1fc-2bf1a110798f	A	অণুচক্রিকা	0	\N
e16b7983-b460-4c13-b6b6-e91cba360041	485e6fce-a058-4ec1-a1fc-2bf1a110798f	B	ফাইব্রিনোজেন	1	\N
60b38c19-936f-41dc-94ed-f8aa512e8bf4	485e6fce-a058-4ec1-a1fc-2bf1a110798f	C	ইনসুলিন	2	\N
72e22c62-58ee-4a1f-890a-afc9d512ca34	485e6fce-a058-4ec1-a1fc-2bf1a110798f	D	প্রোথ্রম্বিন	3	\N
2d5d5a7b-fa78-4496-b5bc-16f6c3042c8e	8ccb80ce-de3b-47d8-8cc4-8e376cdfcd0c	A	বর্ণান্ধতা	0	\N
b89c0397-17d9-4962-9186-cf1c3f58d7f6	8ccb80ce-de3b-47d8-8cc4-8e376cdfcd0c	B	গাত্রবর্ণ	1	\N
074bd3f9-892e-4064-88a5-a2d209356a59	8ccb80ce-de3b-47d8-8cc4-8e376cdfcd0c	C	চোখের রঙ	2	\N
34bc49cb-95de-4e47-b8d6-31bacb23251e	8ccb80ce-de3b-47d8-8cc4-8e376cdfcd0c	D	সিস্টিক ফাইব্রোসিস	3	\N
fd9a8513-f4c1-4cd4-a4c3-34a794afa31b	2ab9f2b5-9176-4e69-b582-e78328a8e2ff	A	পরিফেরা	0	\N
1f20312e-ccdc-4fc8-a2b8-a4f9f4c3dda3	2ab9f2b5-9176-4e69-b582-e78328a8e2ff	B	নিডেরিয়া	1	\N
194f26b9-5d94-4d27-b9a5-989a44844663	2ab9f2b5-9176-4e69-b582-e78328a8e2ff	C	অ্যানিলিডা	2	\N
613d3382-780a-443a-b33f-5f030c33e845	2ab9f2b5-9176-4e69-b582-e78328a8e2ff	D	কর্ডাটা	3	\N
6af54110-ad55-46dc-8ae8-6b3d430af3cf	bbae0831-2f32-4d55-8561-e7ff7aa814e0	A	সাইক্লয়েড	0	\N
597b91e4-379f-4720-9e6b-4ac12708462d	bbae0831-2f32-4d55-8561-e7ff7aa814e0	B	গ্যানয়েড	1	\N
665347c3-6c17-4c71-9f64-109e812b7a50	bbae0831-2f32-4d55-8561-e7ff7aa814e0	C	টিনয়েড	2	\N
ab4ddbaa-a324-426a-a0da-23cd4678feb2	bbae0831-2f32-4d55-8561-e7ff7aa814e0	D	প্ল্যাকয়েড	3	\N
964ccf41-441a-4f3b-b714-ccb0f25912b4	db27080c-93bb-4bfe-a03a-b3613c0a0a36	A	লোহিত রক্তকণিকা	0	\N
c878e694-553a-40f5-bea7-eed8d085f1bf	db27080c-93bb-4bfe-a03a-b3613c0a0a36	B	শ্বেত রক্তকণিকা	1	\N
11144210-df9a-499b-af26-dea1d75603f3	db27080c-93bb-4bfe-a03a-b3613c0a0a36	C	অণুচক্রিকা	2	\N
cc1e6c28-6810-46be-8b05-703622b048fb	db27080c-93bb-4bfe-a03a-b3613c0a0a36	D	গ্লোবিন	3	\N
aa1d8db9-cd6f-4c5f-9bcf-d6cf85992ddd	66a8c37b-6490-45ab-9535-a35fb5cb3f53	A	স্ত্রী গ্যামিটোফাইটের পরিস্ফুটন	0	\N
6b8560fe-61d5-49d7-ab73-e2c9dad2ce20	66a8c37b-6490-45ab-9535-a35fb5cb3f53	B	নিষেকক্রিয়া	1	\N
39baa105-1b9c-416f-9d82-9b1fdf10d564	66a8c37b-6490-45ab-9535-a35fb5cb3f53	C	পরাগায়ণ	2	\N
0b9b62a8-74f7-4ecd-8d0e-017985923697	66a8c37b-6490-45ab-9535-a35fb5cb3f53	D	পুংগ্যামিটের পরিস্ফুটন	3	\N
287e881a-6ad8-479a-8016-690bcbfdcc61	605c3e67-1a2a-4601-97bd-e68935ea571b	A	Nerium odoratum	0	\N
a9a4b75d-7a1a-42f6-8488-10aa368ca7e1	605c3e67-1a2a-4601-97bd-e68935ea571b	B	Nymphaea nouchali	1	\N
63273ad2-3364-40d7-bbe4-4d65e9372322	605c3e67-1a2a-4601-97bd-e68935ea571b	C	Calotropis procera	2	\N
0372880e-f922-4ba8-bce9-16697121e0a3	605c3e67-1a2a-4601-97bd-e68935ea571b	D	Rhizophora conjugata	3	\N
4b0c73df-1b6a-41bb-bbab-eb29e6425427	6de7115c-baac-48d1-aa68-abffed612b0e	A	মূল	0	\N
1b145280-9dcc-4e25-83e5-a46894fe6b94	6de7115c-baac-48d1-aa68-abffed612b0e	B	কাণ্ড	1	\N
68874044-576f-4048-81e4-fa78ed62573b	6de7115c-baac-48d1-aa68-abffed612b0e	C	পাতা	2	\N
2c36ed2a-2814-4e72-8ba8-51107d441f28	6de7115c-baac-48d1-aa68-abffed612b0e	D	রাইজয়েড	3	\N
3247e6e2-813b-4282-99fd-9ccd90d425e1	f2c2eda6-7843-4e42-800a-9a11c06f8de1	A	Penicillium notatum	0	\N
25d6f956-26e7-4cb7-a647-f3b4ceec5e1e	f2c2eda6-7843-4e42-800a-9a11c06f8de1	B	Penicillium chrysogenum	1	\N
ca2afc24-2481-4c96-b5c9-6f595d30c69a	f2c2eda6-7843-4e42-800a-9a11c06f8de1	C	Penicillium roqueforti	2	\N
527befb8-d36b-4102-9ae7-f17a6eb27da0	f2c2eda6-7843-4e42-800a-9a11c06f8de1	D	Penicillium camemberti	3	\N
7f3785b2-5c87-4c94-921f-d507ff306614	c88b3891-ffae-4ade-975e-1fb05affc027	A	Amyloplast	0	\N
a5d90b3a-45e7-470d-b3ac-3f6b7e066100	c88b3891-ffae-4ade-975e-1fb05affc027	B	Elaioplast	1	\N
932c3054-5fdb-4cee-aeb2-44e4d87cb7d9	c88b3891-ffae-4ade-975e-1fb05affc027	C	Aleuroplast	2	\N
70a33a1f-93f5-4816-92d1-aae973d99464	c88b3891-ffae-4ade-975e-1fb05affc027	D	Protoplast	3	\N
b335651c-e735-4e9d-80e6-d7c891528c56	a62032a1-d1cc-4736-8425-0f2e921f4fd7	A	Spirogyra	0	\N
d677576c-7fff-4fa4-9819-c1badd9410d1	a62032a1-d1cc-4736-8425-0f2e921f4fd7	B	Nostoc	1	\N
923c8d68-ee7b-406a-864a-a7f81a0ae1dd	a62032a1-d1cc-4736-8425-0f2e921f4fd7	C	Oedogonium	2	\N
95574a92-31c8-40c7-aefe-2dc1252aaf29	a62032a1-d1cc-4736-8425-0f2e921f4fd7	D	Ulothrix	3	\N
3706f964-b223-4fc1-8e2e-085d4961a1cb	5daf662b-be0e-4354-b921-4a52bd745a0e	A	Xanthomonas citri	0	\N
dadcc7e6-c67c-42c5-bdc7-1e43fb40d7f2	5daf662b-be0e-4354-b921-4a52bd745a0e	B	Streptomyces scabies	1	\N
d46d7aba-2200-4f61-833d-6eb015cfd10a	5daf662b-be0e-4354-b921-4a52bd745a0e	C	Agrobacterium tritici	2	\N
39368ab0-a7b3-474a-ac4d-4ee4d9e9d207	5daf662b-be0e-4354-b921-4a52bd745a0e	D	Clostridium botulinum	3	\N
e96430d7-89d7-41ee-82d0-96745ec555f6	f85f5472-7255-41ae-9f88-65f974586019	A	Agrobacterium tumefaciens	0	\N
a015be3f-3cf2-43ac-8d1f-901610234731	f85f5472-7255-41ae-9f88-65f974586019	B	Bacillus subtilis	1	\N
4559bc47-8987-4f66-98df-8247a1a632ba	f85f5472-7255-41ae-9f88-65f974586019	C	Bacillus thuringiensis	2	\N
e6d927f9-ef4e-4160-bbc0-09c6f19b99dc	f85f5472-7255-41ae-9f88-65f974586019	D	Bacillus amyloliquefaciens	3	\N
1176272b-bf65-4dfb-883f-e9165c063faa	f58574cb-2588-4cc8-90eb-356220619c91	A	মেরিস্টেম কালচার	0	\N
93cca514-1078-4af4-826e-0b1b182df3f3	f58574cb-2588-4cc8-90eb-356220619c91	B	ভ্রূণ কালচার	1	\N
4bca1d85-105e-4229-b606-5831a1306f7a	f58574cb-2588-4cc8-90eb-356220619c91	C	কক্ষমুকুল কালচার	2	\N
696b872c-c209-462a-9e98-8939a5c8626d	f58574cb-2588-4cc8-90eb-356220619c91	D	ক্যালাস কালচার	3	\N
269caa22-60aa-4abe-8e23-ee7154ab1121	910ac715-d034-40c2-91de-40725ffa374c	A	স্পার্মাটোগোনিয়া	0	\N
590a7db5-3943-4e52-8ec4-4bd71ae984a7	910ac715-d034-40c2-91de-40725ffa374c	B	স্ক্রোটাম	1	\N
290e0f97-e134-478d-b12b-56a3a2285564	910ac715-d034-40c2-91de-40725ffa374c	C	এপিডিডাইমিস	2	\N
55a3866b-4eeb-4b0f-9df8-aad4ec92acbd	910ac715-d034-40c2-91de-40725ffa374c	D	প্রোস্টেট গ্রন্থি	3	\N
2fd5d924-7b4d-486c-8b32-5145c3b70598	0f113169-736b-4c61-b902-5a2ef43f7b5e	A	মধ্যকর্ণ	0	\N
65cccc87-ca95-4ecf-8f25-6acdfa589f23	0f113169-736b-4c61-b902-5a2ef43f7b5e	B	ককলিয়া	1	\N
668cd23d-ac87-4227-83e4-eb04b842d557	0f113169-736b-4c61-b902-5a2ef43f7b5e	C	অর্ধবৃত্তাকার নালি	2	\N
634cca88-19ef-4ef7-83cf-b70265847ebe	0f113169-736b-4c61-b902-5a2ef43f7b5e	D	ইউট্রিকুলাস	3	\N
53ec8f3e-7cf4-4e63-8780-71447ff21427	89f71357-2e12-4d2a-927e-a1ef6b168558	A	Entamoeba histolytica	0	\N
bc7120ea-486f-4f91-97fa-9f796e4e86f0	89f71357-2e12-4d2a-927e-a1ef6b168558	B	Wuchereria bancrofti	1	\N
2d15cd25-9c8a-4b0e-a85a-b623ec04deae	89f71357-2e12-4d2a-927e-a1ef6b168558	C	Aedes fatigans	2	\N
8c72496d-4c02-4f37-9536-9ebbd36f4182	89f71357-2e12-4d2a-927e-a1ef6b168558	D	Culex quinquefasciatus	3	\N
3a7dd6ae-cec1-496e-a186-fea3c308c8e2	50abb947-d3a0-451e-8221-e6a2398017ce	A	অন্ত্রে	0	\N
849e044b-7995-4e7a-b779-5e328204aa0c	50abb947-d3a0-451e-8221-e6a2398017ce	B	পাকস্থলিতে	1	\N
fa2aeee9-fe5e-4ed9-b24b-4b4d86bca127	50abb947-d3a0-451e-8221-e6a2398017ce	C	অ্যাড্রিনাল গ্রন্থিতে	2	\N
d9aeb542-bc22-4c01-8da9-eb643235ce84	50abb947-d3a0-451e-8221-e6a2398017ce	D	বৃক্কে	3	\N
a0274a21-14b6-4a8c-bbcf-c29c88e2da82	a01533cf-6c59-45ee-83fa-f7418d8cc33b	A	ফেনেরোজোয়েট	0	\N
95831028-65ea-4ab4-899a-2c34a95ca985	a01533cf-6c59-45ee-83fa-f7418d8cc33b	B	সাইজন্ট	1	\N
77def352-89ab-4b04-9d3d-f408a43380b1	a01533cf-6c59-45ee-83fa-f7418d8cc33b	C	মেরোজোয়েট	2	\N
727f400c-07c7-4ae2-a9a6-19bfbec5117f	a01533cf-6c59-45ee-83fa-f7418d8cc33b	D	ট্রফোজোয়েট	3	\N
1781e462-cdd3-4c8e-ad7e-8d27b0d80ebb	b6da5681-215c-4b93-b5f0-6e8f785b731b	A	$50\\,\\text{A}$	0	\N
77943339-29c8-4548-a26d-46584614470d	b6da5681-215c-4b93-b5f0-6e8f785b731b	B	$70\\,\\text{A}$	1	\N
58440da6-4d3b-41e2-b085-cf5b7a884cb9	b6da5681-215c-4b93-b5f0-6e8f785b731b	C	$120\\,\\text{A}$	2	\N
7d009400-69a0-4033-b9e5-f9241c5f1f58	b6da5681-215c-4b93-b5f0-6e8f785b731b	D	$190\\,\\text{A}$	3	\N
e414bf11-e005-4947-b37c-06d26e0c6e5e	25ec7bf5-1589-4329-b1f7-516f0f8d37a0	A	$0.16\\,\\text{A}$	0	\N
e9bdbab7-291e-48d6-86e4-dc229c9a2e85	25ec7bf5-1589-4329-b1f7-516f0f8d37a0	B	$0.26\\,\\text{A}$	1	\N
dbbd08bf-3295-4a02-9d3a-be5fd4876677	25ec7bf5-1589-4329-b1f7-516f0f8d37a0	C	$0.36\\,\\text{A}$	2	\N
e5c7f22f-aab8-43e8-9060-7d7043340767	25ec7bf5-1589-4329-b1f7-516f0f8d37a0	D	$0.46\\,\\text{A}$	3	\N
92fc7668-eb72-4d07-a8ae-22b78cf25d5b	19e6c77e-9cfc-4eec-99c4-afdb0ba05ca5	A	$2.26 \\times 10^6\\,\\text{J/K}$	0	\N
703446fe-1d8b-4ee2-82bd-12a156f308c3	19e6c77e-9cfc-4eec-99c4-afdb0ba05ca5	B	$842.98 \\times 10^6\\,\\text{J/K}$	1	\N
c305524d-c64b-4746-a783-3e4e62c87b56	19e6c77e-9cfc-4eec-99c4-afdb0ba05ca5	C	$165.04 \\times 10^6\\,\\text{J/K}$	2	\N
62730f15-4abc-4f53-afe1-c3afe560ef59	19e6c77e-9cfc-4eec-99c4-afdb0ba05ca5	D	$847.01 \\times 10^6\\,\\text{J/K}$	3	\N
0826cb5d-e05a-446f-a460-2889e56ffcc1	d00bf7f0-ff55-42bd-8b08-def20bb03915	A	$-40^\\circ\\text{C}$	0	\N
03f76e29-9654-41ca-9094-3f159969fd3d	d00bf7f0-ff55-42bd-8b08-def20bb03915	B	$40^\\circ\\text{C}$	1	\N
572e51c6-7e5f-4bf0-8d40-6fce874d5ddc	d00bf7f0-ff55-42bd-8b08-def20bb03915	C	$0^\\circ\\text{C}$	2	\N
601cd941-ecb9-4c13-99c1-21f303a0eb47	d00bf7f0-ff55-42bd-8b08-def20bb03915	D	$100^\\circ\\text{C}$	3	\N
99c382e8-fe5d-4fbc-8829-f507361c09af	52ec6e64-8b1a-461b-a878-0c0c035dbbd4	A	$16 \\times 10^{14}\\,\\text{Hz}$	0	\N
037c46a9-e3cc-4172-8cd8-ebc4c01f94a5	52ec6e64-8b1a-461b-a878-0c0c035dbbd4	B	$16 \\times 10^{-14}\\,\\text{Hz}$	1	\N
cd57a67f-9e65-4df5-bbbe-c8dfdd056443	52ec6e64-8b1a-461b-a878-0c0c035dbbd4	C	$1.6 \\times 10^{-19}\\,\\text{Hz}$	2	\N
5aaaeabd-0687-4747-b655-e47236dbdac0	52ec6e64-8b1a-461b-a878-0c0c035dbbd4	D	$1.6 \\times 10^{19}\\,\\text{Hz}$	3	\N
7d64c065-a272-45fc-bcc1-d32a1ad6e74c	66e563db-29f8-4f21-8537-c0127e5e63cc	A	$2/3, 1/3$	0	\N
9ceb430a-3171-4385-8ac7-3b53ef8615d6	66e563db-29f8-4f21-8537-c0127e5e63cc	B	$2, 3$	1	\N
c09bf5b3-b14a-4e6d-9ee0-f6e32438e99d	66e563db-29f8-4f21-8537-c0127e5e63cc	C	$4/5, -1/5$	2	\N
a3c4b91b-ff8d-4da7-951b-13c90ea4ae4a	66e563db-29f8-4f21-8537-c0127e5e63cc	D	$1/5, 3/5$	3	\N
221cfb92-234d-4844-83fb-77cb71b80df6	050c9a2a-afc8-4cf8-84d4-2c22be81abd0	A	Radio Wave	0	\N
ad145e40-a478-4cd6-a168-cd0ea1413b8f	050c9a2a-afc8-4cf8-84d4-2c22be81abd0	B	Micro Wave	1	\N
1a95a505-4269-4f4e-a7a5-bd681ab09c06	050c9a2a-afc8-4cf8-84d4-2c22be81abd0	C	X-ray	2	\N
3c8fd2e4-63a6-4884-8772-454a3a99b6e2	050c9a2a-afc8-4cf8-84d4-2c22be81abd0	D	Ultrasound	3	\N
4bbb7fbb-1e83-4ad6-bc40-db9fc25199f4	454c4c4e-a9c0-4349-9861-1d2394b1c495	A	শুধুমাত্র হোল	0	\N
01441f23-fc4c-42d8-8398-f2550da22eda	454c4c4e-a9c0-4349-9861-1d2394b1c495	B	শুধুমাত্র ইলেকট্রন	1	\N
08b06fd3-33aa-41a5-b6e3-40b47eba1122	454c4c4e-a9c0-4349-9861-1d2394b1c495	C	ধনাত্মক আয়ন	2	\N
9acdac33-7c5a-477c-ab9b-b6c4f9724f9f	454c4c4e-a9c0-4349-9861-1d2394b1c495	D	হোল এবং ইলেকট্রন	3	\N
0c2abee8-d423-4a12-aff5-f93b5cb0d8bb	0d3a863f-1bdc-4700-9fde-50a6789967a6	A	দ্রুতির	0	\N
8fa7c6bd-417c-4d5d-9ef2-6d12b0977032	0d3a863f-1bdc-4700-9fde-50a6789967a6	B	দূরত্বের	1	\N
3559d8bd-3bb1-4dbc-9ba2-78fbd9a4c357	0d3a863f-1bdc-4700-9fde-50a6789967a6	C	সময়ের	2	\N
c4ceb461-ba0c-4f4b-a778-8f71a3c29974	0d3a863f-1bdc-4700-9fde-50a6789967a6	D	কম্পাঙ্কের	3	\N
5b977fd2-3619-461c-8d02-d776e07f5b53	98043387-e7c4-4277-99f0-6815949e7288	A	$[MLT^{-2}]$	0	\N
efde45cc-375f-4206-aa98-c5f0e25482c0	98043387-e7c4-4277-99f0-6815949e7288	B	$[ML^2 T^{-1}]$	1	\N
58302f19-ca2a-4498-be61-5a95eb7e793c	98043387-e7c4-4277-99f0-6815949e7288	C	$[M^2 LT^{-2}]$	2	\N
4217de9c-89ab-413d-8225-ba5a7bde9847	98043387-e7c4-4277-99f0-6815949e7288	D	$[ML^2 T^{-2}]$	3	\N
82f6387e-5a1b-47f5-8aff-95110dc1bb4f	011f55e3-6770-4d47-9e46-3b8cd0e83955	A	$150\\,\\text{m}$	0	\N
c3cc6281-bef2-4aa3-9752-6b60bdffaabc	011f55e3-6770-4d47-9e46-3b8cd0e83955	B	$300\\,\\text{m}$	1	\N
6ffc8561-ab65-4490-a142-d71a46455d3f	011f55e3-6770-4d47-9e46-3b8cd0e83955	C	$400\\,\\text{m}$	2	\N
3ed67190-3f3f-4a42-b2b8-8d97ae6b5536	011f55e3-6770-4d47-9e46-3b8cd0e83955	D	$200\\,\\text{m}$	3	\N
ef1b3c9d-34dd-43c3-a41b-e4b864d6c457	0bd7afbd-dcc0-410b-bde1-5355b8cb277f	A	তাপমাত্রা	0	\N
7c2fa4e6-1bd9-4f85-b8fe-bd211c06c5b9	0bd7afbd-dcc0-410b-bde1-5355b8cb277f	B	চাপ	1	\N
2449890b-0854-42ef-a12a-4a7f1238e759	0bd7afbd-dcc0-410b-bde1-5355b8cb277f	C	এনট্রপি	2	\N
1fd13f0c-8501-43e5-8a4d-267c5fa0eddc	0bd7afbd-dcc0-410b-bde1-5355b8cb277f	D	অভ্যন্তরীণ শক্তি	3	\N
950c2cb4-0811-4d96-be10-f45fde5c181a	14e7bcbb-c2f7-48bc-aa90-74c03999d9e7	A	$\\frac{\\pi}{2}$	0	\N
ed1aaeb9-bd69-4135-a234-3d065928757c	14e7bcbb-c2f7-48bc-aa90-74c03999d9e7	B	$\\frac{\\pi}{3}$	1	\N
7ace54c7-e2f0-4abb-9fb8-a03d635a94ff	14e7bcbb-c2f7-48bc-aa90-74c03999d9e7	C	$\\frac{\\pi}{4}$	2	\N
f2e0abce-dd12-4810-b5dd-0d61ef249f3c	14e7bcbb-c2f7-48bc-aa90-74c03999d9e7	D	$\\frac{\\pi}{6}$	3	\N
7b68d3e1-5092-4193-86a5-777e3a82979d	0c357720-5066-4fd6-a7d7-64dde5fcb0c2	A	OR gate	0	\N
44e06813-aa3e-46cb-8c67-3b449fd3cb71	0c357720-5066-4fd6-a7d7-64dde5fcb0c2	B	NOR gate	1	\N
f2174b8b-07a5-48dc-b346-fa5528cbc35b	0c357720-5066-4fd6-a7d7-64dde5fcb0c2	C	NOT gate	2	\N
05f2854f-a899-45eb-91eb-48688f773baa	0c357720-5066-4fd6-a7d7-64dde5fcb0c2	D	AND gate	3	\N
ff957768-177b-4226-9973-004f9e19dd74	0b5f0817-9307-4039-a24b-2cad9cc12a35	A	দ্বিগুণ হবে	0	\N
06da0a4a-f5b5-415d-b21b-2f58ddc5c7a8	0b5f0817-9307-4039-a24b-2cad9cc12a35	B	অর্ধেক হবে	1	\N
a363e31e-5561-4e8f-a8da-7e49597f2ed5	0b5f0817-9307-4039-a24b-2cad9cc12a35	C	চারগুণ হবে	2	\N
5c3423b4-ec2a-4b3f-8a15-fd30e31713b4	0b5f0817-9307-4039-a24b-2cad9cc12a35	D	অপরিবর্তিত থাকবে	3	\N
73297350-c4f4-47c2-8d9e-56fd116010ea	057d9d16-3096-49a9-9332-91786e8f7fde	A	$20\\text{ J}$	0	\N
91397895-7e22-48c3-b273-dfcf0cc9a1fb	057d9d16-3096-49a9-9332-91786e8f7fde	B	$30\\text{ J}$	1	\N
4bff07d6-ff6c-4a60-a177-9407c5523255	057d9d16-3096-49a9-9332-91786e8f7fde	C	$10\\text{ J}$	2	\N
24f8056f-e1f0-4d17-a553-76b07a4f6cc7	057d9d16-3096-49a9-9332-91786e8f7fde	D	$40\\text{ J}$	3	\N
bbe908f2-2d0c-4b04-b048-f3b7f4dad21d	a573f0bf-6d03-49fe-bb60-accbb25272cb	A	$\\frac{M_1}{M_2}$	0	\N
3d468e5a-d5d5-4854-9ddd-2b8d29acdbc2	a573f0bf-6d03-49fe-bb60-accbb25272cb	B	$\\frac{M_2}{M_1}$	1	\N
c5fb8867-bd0a-480d-9a6b-4f0640cb5d58	a573f0bf-6d03-49fe-bb60-accbb25272cb	C	$\\sqrt{\\frac{M_1}{M_2}}$	2	\N
972b24d3-c534-4c42-9d70-8b3b795a89ff	a573f0bf-6d03-49fe-bb60-accbb25272cb	D	$\\sqrt{\\frac{M_2}{M_1}}$	3	\N
f82fc9c3-f302-41bf-95b8-2ad9db4dcf47	3e4ea525-2149-4cf7-ac09-9c3085be3a07	A	$16$	0	\N
3744aea8-372f-44b5-90a5-78a729786426	3e4ea525-2149-4cf7-ac09-9c3085be3a07	B	$4$	1	\N
8cc46626-b954-4918-917a-bc051803e162	3e4ea525-2149-4cf7-ac09-9c3085be3a07	C	$3$	2	\N
50f0eb1a-5b77-4a3d-9146-5c0387b7df46	3e4ea525-2149-4cf7-ac09-9c3085be3a07	D	$2$	3	\N
559d20ef-efdc-41e8-8222-71e21569b861	93d31d40-3d8a-4907-89b2-12486ee52608	A	$\\frac{7}{8}\\text{ min}$	0	\N
8c1ec7d0-ea46-49d7-8be8-9a0547fdd53e	93d31d40-3d8a-4907-89b2-12486ee52608	B	$\\frac{8}{7}\\text{ min}$	1	\N
ddeb6f86-daf9-4d4c-933c-3aca331c63f0	93d31d40-3d8a-4907-89b2-12486ee52608	C	$\\frac{7}{2}\\text{ min}$	2	\N
1fdbe5a0-71ae-486b-8b86-f60120e72d96	93d31d40-3d8a-4907-89b2-12486ee52608	D	$\\frac{14}{3}\\text{ min}$	3	\N
0e4efb16-3215-46fd-b2d0-b10c0428b24c	8dc11970-9511-4442-a739-3d999548678b	A	$1:3:5$	0	\N
b94911d9-a8ea-4a8c-9cfd-b9f3d271ddae	8dc11970-9511-4442-a739-3d999548678b	B	$3:5:15$	1	\N
f64308d0-986f-4be6-b599-860359c88783	8dc11970-9511-4442-a739-3d999548678b	C	$15:5:3$	2	\N
9520621e-a8f2-4d86-9e74-e222585d5617	8dc11970-9511-4442-a739-3d999548678b	D	$5:3:1$	3	\N
8925bb06-f3ea-4cf4-9b0f-482af8cd4e19	a75f1685-75c9-46d3-a53d-c51b3c16eaef	A	সমান এবং একই দিকে	0	\N
e026525d-24ab-4e29-b1f1-b50c8fa1073f	a75f1685-75c9-46d3-a53d-c51b3c16eaef	B	সমান এবং বিপরীত দিকে	1	\N
ac4a6f4e-a4a6-4c2c-876f-357a0f3a7beb	a75f1685-75c9-46d3-a53d-c51b3c16eaef	C	সমান এবং পারস্পরিক লম্বভাবে	2	\N
37ed5e97-ff7b-434e-ba25-b55a0de256f0	a75f1685-75c9-46d3-a53d-c51b3c16eaef	D	ভিন্ন এবং বিপরীত দিকে	3	\N
3567b853-b78b-4d3b-ac29-2a00c74b8e90	8867a36b-758a-4c7e-ab60-1596edc4c28e	A	$\\frac{1}{\\sqrt{2}}$	0	\N
979562ad-7453-4740-a572-a4d889445df7	8867a36b-758a-4c7e-ab60-1596edc4c28e	B	$\\sqrt{2}$	1	\N
8676b1db-a70f-468c-9ee2-0aeab1313dd8	8867a36b-758a-4c7e-ab60-1596edc4c28e	C	$\\frac{\\sqrt{3}}{2}$	2	\N
25aac657-22de-481f-a4e5-5358b71f4513	8867a36b-758a-4c7e-ab60-1596edc4c28e	D	$\\frac{2}{\\sqrt{3}}$	3	\N
c0e6dce4-8437-416b-a200-93cf35b85286	6dff14d7-14d7-4232-9a97-e4b24b18a43c	A	অর্ধেক হবে	0	\N
cd1952ae-7db4-45e6-84b2-dc815eaec191	6dff14d7-14d7-4232-9a97-e4b24b18a43c	B	দ্বিগুণ হবে	1	\N
33068449-83d7-48d0-aa9b-f16978c21465	6dff14d7-14d7-4232-9a97-e4b24b18a43c	C	অপরিবর্তিত থাকবে	2	\N
b497f618-8f1b-44a4-8b17-6f324608f393	6dff14d7-14d7-4232-9a97-e4b24b18a43c	D	চারগুণ হবে	3	\N
1ad7c51a-5976-403e-8aa1-a62b433fc7a1	fad720c6-cf79-47e3-a7dc-997ce0a4ca1c	A	$1\\text{ A}$	0	\N
664dad62-06be-4aa1-93f1-cbfe94f8842b	fad720c6-cf79-47e3-a7dc-997ce0a4ca1c	B	$10\\text{ A}$	1	\N
2b0ffe51-7966-43f0-bf8b-3e87a346f6b4	fad720c6-cf79-47e3-a7dc-997ce0a4ca1c	C	$12\\text{ A}$	2	\N
32565905-ad3d-4e4e-b3f6-cb9ff43c135e	fad720c6-cf79-47e3-a7dc-997ce0a4ca1c	D	$100\\text{ A}$	3	\N
ae1a7674-8faf-41a0-a6d8-587549c16647	a776c176-a748-4ce2-81b0-d2817998a72c	A	$7.5 \\times 10^{11}\\text{ N/m}^2$	0	\N
f2c7904e-5cff-4d21-bedd-059211faf8ab	a776c176-a748-4ce2-81b0-d2817998a72c	B	$3 \\times 10^{10}\\text{ N/m}^2$	1	\N
ca7c5399-fdd4-489d-96b8-55d969fc8c7b	a776c176-a748-4ce2-81b0-d2817998a72c	C	$5.33 \\times 10^{10}\\text{ N/m}^2$	2	\N
9d4159a1-91d3-430e-bfbd-e3f876ddd604	a776c176-a748-4ce2-81b0-d2817998a72c	D	$4 \\times 10^{10}\\text{ N/m}^2$	3	\N
935099ce-cbdc-4752-8161-4d1b844629c0	79fac420-1fdd-40d0-b324-11d7fdf6767b	A	$220$	0	\N
74982ac9-68ab-40cd-9afc-2236feaab9f2	79fac420-1fdd-40d0-b324-11d7fdf6767b	B	$210$	1	\N
23249042-741f-445f-b49f-49c8766a1dc9	79fac420-1fdd-40d0-b324-11d7fdf6767b	C	$430$	2	\N
63b1b059-8501-473d-abf1-e73da29d7d18	79fac420-1fdd-40d0-b324-11d7fdf6767b	D	$10$	3	\N
d53dfe13-5c1e-434a-be51-c7af01c58e91	907c9c8d-a368-4884-bbbd-04bfd8d150b8	A	$\\frac{9.8}{1.6}\\text{ h}$	0	\N
0b2ecab3-bb24-4b2c-8923-0714180eb223	907c9c8d-a368-4884-bbbd-04bfd8d150b8	B	$\\sqrt{\\frac{1.6}{9.8}}\\text{ h}$	1	\N
e217fb24-f0b2-4e0b-9ef7-1fc97a4c277c	907c9c8d-a368-4884-bbbd-04bfd8d150b8	C	$\\sqrt{\\frac{9.8}{1.6}}\\text{ h}$	2	\N
e48f82cd-1ba2-4cb9-ae8e-0e70a2a1eddb	907c9c8d-a368-4884-bbbd-04bfd8d150b8	D	$\\frac{1.6}{9.8}\\text{ h}$	3	\N
3df115a3-a194-4bc2-b857-c2d611e7d674	001777f1-ddfd-4c1d-9f39-0f7ea9489952	A	[IMAGE_1]	0	p02_q28_01.png
25fe764a-df3c-493a-b2fc-2c24ede805ff	001777f1-ddfd-4c1d-9f39-0f7ea9489952	B	[IMAGE_2]	1	p02_q28_02.png
706e93ed-1e9c-475e-b281-bae0b8d1808b	001777f1-ddfd-4c1d-9f39-0f7ea9489952	C	[IMAGE_3]	2	p02_q28_03.png
05275d93-5f93-40ae-a361-c95b8061dbdc	001777f1-ddfd-4c1d-9f39-0f7ea9489952	D	[IMAGE_4]	3	p02_q28_04.png
defce1ed-c248-4c8b-9d01-329337b6f636	ff1a1634-1cba-4dfd-a821-3c681b5fd44e	(A)	[IMAGE_1]	0	p03_qq_01.png
d43cc62b-8b0d-4df8-9a3a-ab677f82250a	ff1a1634-1cba-4dfd-a821-3c681b5fd44e	(B)	[IMAGE_2]	1	p03_qq_02.png
e853c40f-d7c2-43d9-8e8a-022b9fac2175	ff1a1634-1cba-4dfd-a821-3c681b5fd44e	(C)	[IMAGE_3]	2	p03_qq_03.png
3f4931b0-87ca-4268-880d-4022d92dfb28	ff1a1634-1cba-4dfd-a821-3c681b5fd44e	(D)	[IMAGE_4]	3	p03_qq_04.png
a830e44d-f641-4ec2-95c1-b27d3b6eaea7	80d9a4aa-49ca-4e56-9af1-fa6d6157e28f	A	$4f$	0	\N
9cfa8344-5d4f-4be6-a9d9-703aec5dcc24	80d9a4aa-49ca-4e56-9af1-fa6d6157e28f	B	$2f$	1	\N
59e9ca41-0524-4029-8ebc-1794f95b57a6	80d9a4aa-49ca-4e56-9af1-fa6d6157e28f	C	$f/2$	2	\N
1430e03e-59f7-4ea8-b364-d0daf84d736a	80d9a4aa-49ca-4e56-9af1-fa6d6157e28f	D	$f$	3	\N
938c3dac-0111-4c06-b8f0-7a044e45a3d2	ae15f6c7-0d25-43b1-8e14-d37e484872ce	A	$0.1\\text{ M } \\ce{NH3}$	0	\N
bbe80177-8388-4058-9a5c-6910857c683c	ae15f6c7-0d25-43b1-8e14-d37e484872ce	B	$0.1\\text{ M } \\ce{NaOH}$	1	\N
7df50c1f-6c0d-4cbf-8366-6a8c09e9034a	ae15f6c7-0d25-43b1-8e14-d37e484872ce	C	$0.1\\text{ M } \\ce{NH4Cl}$	2	\N
fa45d52e-3647-47d5-b614-ae41958299a9	ae15f6c7-0d25-43b1-8e14-d37e484872ce	D	$0.1\\text{ M } \\ce{CH3COONa}$	3	\N
048f1dcc-b89e-4213-a276-ed245793895a	51d69466-c78a-4b91-8219-f4af4a02a717	A	$-28.5\\text{ kJ}$	0	\N
6f0895d5-2f11-4fef-aeaf-12030493ea9a	51d69466-c78a-4b91-8219-f4af4a02a717	B	$-57.0\\text{ kJ}$	1	\N
54b3fac1-8947-47dc-9e98-e1806b5541b5	51d69466-c78a-4b91-8219-f4af4a02a717	C	$+57.0\\text{ kJ}$	2	\N
0f39595c-0eba-452b-a282-520934b40e7a	51d69466-c78a-4b91-8219-f4af4a02a717	D	$-114\\text{ kJ}$	3	\N
8e998678-ff00-4d58-bb3b-644bb6e68035	edf6c621-dc98-4e38-b0e7-28fb0705ef7d	A	$\\ce{PH3}$	0	\N
b15e59d6-0fdc-4cb7-b17d-2ac861c7e914	edf6c621-dc98-4e38-b0e7-28fb0705ef7d	B	$\\ce{H2O}$	1	\N
579ac5f8-5c26-417e-ae5b-3077add5ada2	edf6c621-dc98-4e38-b0e7-28fb0705ef7d	C	$\\ce{BF3}$	2	\N
770a96d1-73dd-4de4-a80e-6e2d967f4d44	edf6c621-dc98-4e38-b0e7-28fb0705ef7d	D	$\\ce{NH3}$	3	\N
01780fc8-1b71-4f0e-afa4-99513216b826	d618e137-7897-4e44-845d-19efabbed372	A	$\\ce{CCl4}$	0	\N
17840436-f2cc-46dc-ab9b-1fce00a0e559	d618e137-7897-4e44-845d-19efabbed372	B	$\\ce{NH4^+}$	1	\N
4c29e8e0-4703-4a46-8b84-7b18e926d595	d618e137-7897-4e44-845d-19efabbed372	C	$\\ce{CH4}$	2	\N
47bfcf67-7a8f-4f97-82b7-25b8811ebb6d	d618e137-7897-4e44-845d-19efabbed372	D	$\\ce{SF4}$	3	\N
b3f4e6d6-c6c1-47cc-bb66-51941e52f4a1	bdc03323-6d57-4d58-9401-066566deb512	A	$7+$	0	\N
b56a8cdd-d188-4e01-a9fd-aac4a33f8cbd	bdc03323-6d57-4d58-9401-066566deb512	B	$4+$	1	\N
7ceed24b-9994-4e12-a472-5292e15ea1a1	bdc03323-6d57-4d58-9401-066566deb512	C	$2+$	2	\N
303850ab-a2b0-4f5a-9741-11db10854498	bdc03323-6d57-4d58-9401-066566deb512	D	$3+$	3	\N
a1949d7e-095f-48e6-92db-5c3efa25f2d7	71c25a35-73e3-41f6-a8bf-c3a473786382	A	$4d^7 5s^2$ and $4d^7 5s^0$	0	\N
9379d632-9a58-4487-acf2-1c8790d41968	71c25a35-73e3-41f6-a8bf-c3a473786382	B	$3d^7 4s^1$ and $3d^7 4s^0$	1	\N
a49b13ba-0eb1-465b-97d8-206517ffeef4	71c25a35-73e3-41f6-a8bf-c3a473786382	C	$3d^7 3s^2$ and $3d^7 3s^0$	2	\N
3a5df6db-c373-43c1-bd2b-519bdfdb4f5b	71c25a35-73e3-41f6-a8bf-c3a473786382	D	$3d^7 4s^2$ and $3d^7 4s^0$	3	\N
0fd48b3a-8f74-42d7-864e-7668f98ca33f	ef9feb31-e7cf-4efd-ba13-605ce79e5251	A	2, 4-Dimethylhexanol-4	0	\N
ec4fa8c0-6363-450e-81b2-546079e4f66b	ef9feb31-e7cf-4efd-ba13-605ce79e5251	B	3, 5-Dimethylthexanol-3	1	\N
5d9d07a5-6fe2-4d3d-884b-fd454a56ec35	ef9feb31-e7cf-4efd-ba13-605ce79e5251	C	1-Ethyl-1, 3-Dimethylhexanol-1	2	\N
b4d97f41-48aa-45ef-93f8-45a1d8c5b80e	ef9feb31-e7cf-4efd-ba13-605ce79e5251	D	1, 3-Dimethyl-1-ethylbutanol-1	3	\N
718c8c8b-4763-4285-bd56-942968fa51d9	99529fb9-4e7c-4921-88bf-afd6530c176e	A	$\\ce{2Na + Cl2 -> 2NaCl}$	0	\N
258af892-427a-4914-9847-968f18106940	99529fb9-4e7c-4921-88bf-afd6530c176e	B	$\\ce{SnCl2 + FeCl3 -> SnCl4 + FeCl2}$	1	\N
9134a185-8108-4e08-9df0-0b209d8038e1	99529fb9-4e7c-4921-88bf-afd6530c176e	C	$\\ce{Cu + HNO3 -> Cu(NO3)2 + NO + H2O}$	2	\N
daf7005d-56ab-4cbc-bd51-4f50b4f343ee	99529fb9-4e7c-4921-88bf-afd6530c176e	D	$\\ce{NaCl + AgNO3 -> NaNO3 + AgCl}$	3	\N
fd77f47d-dff4-4034-a887-378879a6f99f	4d51c540-42e6-4445-b690-ad8f1c9841d5	A	$4.6 \\times 10^4$	0	\N
79512058-53eb-43a7-a102-32ec07d9076c	4d51c540-42e6-4445-b690-ad8f1c9841d5	B	$5.9 \\times 10^3$	1	\N
c844d7b2-1d1a-4cb8-a510-e2241331f2cc	4d51c540-42e6-4445-b690-ad8f1c9841d5	C	$10.2 \\times 10^3$	2	\N
1d30bf30-1f6f-4d18-aeec-fcbfd70fe793	4d51c540-42e6-4445-b690-ad8f1c9841d5	D	$3.2 \\times 10^{-3}$	3	\N
f7158815-58e5-427d-9483-da4f7f5a7537	818b5172-787d-44d7-afd0-7a96d94b69ed	A	Alkane and Alkyne	0	\N
c0446667-45ce-4ffe-a2b5-7f0e38eaab90	818b5172-787d-44d7-afd0-7a96d94b69ed	B	Methanol and Ethanol	1	\N
698f269c-bb4d-4db9-9053-10bf797da967	818b5172-787d-44d7-afd0-7a96d94b69ed	C	Aldehyde and Ketone	2	\N
b607ae45-223f-4284-91eb-d3819515ca43	818b5172-787d-44d7-afd0-7a96d94b69ed	D	$1^{\\circ}$ and $2^{\\circ}$ Alcohol	3	\N
6ce18f25-5b29-4bed-8def-59057cfed941	36bf17f5-128a-45ef-b983-71a2e8d6b2d5	A	$\\ce{Zn^{2+}(aq) | Zn(s) || Cu(s) | Cu^{2+}(aq)}$	0	\N
f07d1218-c455-4b01-96c6-5a462504de03	36bf17f5-128a-45ef-b983-71a2e8d6b2d5	B	$\\ce{Zn(s) | Zn^{2+}(aq) || Cu^{2+}(aq) | Cu(s)}$	1	\N
92ac6fec-8724-4580-ab12-f79220a75a54	36bf17f5-128a-45ef-b983-71a2e8d6b2d5	C	$\\ce{Zn^{2+}(aq) | Zn(s) || Cu^{2+}(aq) | Cu(s)}$	2	\N
af34b2be-9394-4c43-940f-1bc04c15d9fd	36bf17f5-128a-45ef-b983-71a2e8d6b2d5	D	$\\ce{Zn^{2+}(aq) | Zn(s) || Cu^{2+}(aq) | Cu^{2+}(aq)}$	3	\N
42fefb45-555c-4865-94e2-60303df3a81c	32373f1f-9075-41bc-bb81-2bfa7fafbd32	A	$\\ce{H2}$	0	\N
14004347-fb8e-4f2f-b87d-7e338312f0fe	32373f1f-9075-41bc-bb81-2bfa7fafbd32	B	$\\ce{O2}$	1	\N
daff80fb-f9e1-4b15-9d1c-bea92adc5200	32373f1f-9075-41bc-bb81-2bfa7fafbd32	C	$\\ce{CH4}$	2	\N
d0a97943-bae9-4eed-bfe5-fc4c3135fbc5	32373f1f-9075-41bc-bb81-2bfa7fafbd32	D	$\\ce{C}$	3	\N
07a3bab9-0fd4-4da0-91f9-4f49cfe0056b	ea27a43b-778c-46f7-96d8-f698a257513e	A	[IMAGE_1]	0	\N
11a587ad-6d81-4b87-b15f-dbb48594c3ba	ea27a43b-778c-46f7-96d8-f698a257513e	B	[IMAGE_2]	1	\N
eebd08cb-6c03-4627-ad8e-48f8cd7e15bc	ea27a43b-778c-46f7-96d8-f698a257513e	C	[IMAGE_3]	2	\N
a675f37c-daad-4b62-af48-5c5b9839a11b	ea27a43b-778c-46f7-96d8-f698a257513e	D	[IMAGE_4]	3	\N
c732e23f-3c18-43ca-a005-76969d098e06	a8a901a9-da07-4be3-a4db-ff8d81cb71db	A	$2.689 \\times 10^{23}$	0	\N
d43356c8-df3e-4e07-b61d-b5782d3df6f8	a8a901a9-da07-4be3-a4db-ff8d81cb71db	B	$26.89 \\times 10^{23}$	1	\N
27d56794-f03d-491b-9884-5b49ef3dd2c0	a8a901a9-da07-4be3-a4db-ff8d81cb71db	C	$0.2689 \\times 10^{23}$	2	\N
b7e4ed44-ba3b-4dc5-9645-aab2851d680b	a8a901a9-da07-4be3-a4db-ff8d81cb71db	D	$26.89 \\times 10^{25}$	3	\N
db99aee9-0793-432d-a595-26f3d46fc61e	081618ed-512b-4c10-a895-edf6823b6664	A	$\\ce{O2N}-\\text{[IMAGE_1]}-\\ce{CO2H}$	0	\N
3ac6fc99-a8cc-4142-b962-c1277446c9df	081618ed-512b-4c10-a895-edf6823b6664	B	$\\ce{H2N}-\\text{[IMAGE_2]}-\\ce{CO2H}$	1	\N
ca53ff41-6559-4283-9618-a9a11e373b75	081618ed-512b-4c10-a895-edf6823b6664	C	$\\ce{Cl}-\\text{[IMAGE_3]}-\\ce{CO2H}$	2	\N
a6de6a9f-fdd0-493f-833c-8946ff0badc2	081618ed-512b-4c10-a895-edf6823b6664	D	$\\ce{H2N}-\\text{[IMAGE_4]}-\\ce{Cl}$	3	\N
49428dd0-8629-4813-979c-f09e786aee32	a7474a47-2e26-491d-a7b9-b04b8138e571	A	Gamma ray	0	\N
96230c1b-7d49-45fc-8e1f-5027692de35f	a7474a47-2e26-491d-a7b9-b04b8138e571	B	Microwave	1	\N
728863f8-afe4-4eff-babe-7d1778ef3d7e	a7474a47-2e26-491d-a7b9-b04b8138e571	C	Visible ray	2	\N
8b462417-8588-40ac-83bf-f011d8838db7	a7474a47-2e26-491d-a7b9-b04b8138e571	D	X-ray	3	\N
c7ed4e70-440e-4eb8-8e6f-4c647014620a	1e33bbb3-91c6-46a7-ad67-806b1d18161a	A	$\\ce{CH2(NH2)COOH}$	0	\N
26a7e7c7-d64f-4bce-8b3c-8ea3b37c8e09	1e33bbb3-91c6-46a7-ad67-806b1d18161a	B	$\\ce{CH3CH(NH2)COOH}$	1	\N
9c203690-0e9b-4d53-a55e-95bcd051edd0	1e33bbb3-91c6-46a7-ad67-806b1d18161a	C	$\\ce{(CH3)2C=CHCl}$	2	\N
2ae6f45a-365d-4da9-a27f-500353366d5a	1e33bbb3-91c6-46a7-ad67-806b1d18161a	D	$\\ce{CH3CH2COOH}$	3	\N
48d64ac9-6eab-4b70-abae-797e6003266a	79cc36ab-9263-417d-81e5-15ead1475094	A	$\\alpha$-emission	0	\N
9dd556e5-4031-41ae-b96f-b312285e4076	79cc36ab-9263-417d-81e5-15ead1475094	B	$\\beta$-emission	1	\N
9024bab9-0886-46ac-a7d3-ae3d1c1be4b3	79cc36ab-9263-417d-81e5-15ead1475094	C	$\\gamma$-emission	2	\N
f1a977a9-daa6-4203-854e-ac6c62986f4d	79cc36ab-9263-417d-81e5-15ead1475094	D	neutron-emission	3	\N
76c3d7bc-12e9-497d-8f76-3b827e488d8c	b1bc1143-f068-4b94-93f6-17b65baec896	A	$\\ce{HNO3}$	0	\N
58ca5849-3291-4247-83e7-d4e193760a48	b1bc1143-f068-4b94-93f6-17b65baec896	B	$\\ce{H2SO4}$	1	\N
beeeb299-a20d-44b8-863c-f9cec2ab6997	b1bc1143-f068-4b94-93f6-17b65baec896	C	$\\ce{AlCl3}$	2	\N
3b93951f-4b6f-4717-9569-1dca650fe920	b1bc1143-f068-4b94-93f6-17b65baec896	D	$\\ce{NH3}$	3	\N
a8129899-88ba-4556-ad52-86ebb01160ba	f4d09186-46ba-4f88-a5c9-04b0433f7835	A	[IMAGE_1]	0	\N
7614ed4f-edd7-4201-9f7b-922c0ec9398c	f4d09186-46ba-4f88-a5c9-04b0433f7835	B	[IMAGE_2]	1	\N
413a3ca3-b3c0-4598-b48b-11a996526cf1	f4d09186-46ba-4f88-a5c9-04b0433f7835	C	[IMAGE_3]	2	\N
1d02e69b-8af4-4de7-b8ce-15c132dc796e	f4d09186-46ba-4f88-a5c9-04b0433f7835	D	[IMAGE_4]	3	\N
b2eae796-7fd9-4fed-8be9-c6d5b057428f	fdbc5078-665d-4f74-a850-e00ed1345627	A	বিক্রিয়াহার কমে	0	\N
7f58b436-4981-42ea-a3da-069f28f9e04b	fdbc5078-665d-4f74-a850-e00ed1345627	B	সাম্যাবস্থা বামে যায়	1	\N
ec3ef24a-85a6-4686-adf9-70667fa6ef64	fdbc5078-665d-4f74-a850-e00ed1345627	C	বিক্রিয়াহার বাড়ে	2	\N
3dc0202c-dcca-459d-b803-54c407eeafde	fdbc5078-665d-4f74-a850-e00ed1345627	D	সক্রিয়ন শক্তি ধ্রুব থাকে	3	\N
dfa441b1-4f30-4954-bd83-a442ef89c3c4	f6255bbd-d781-4edb-b2d1-9aad47b7132b	A	ইলেক্ট্রননেগেটিভিটি	0	\N
7b4cecd1-e3fa-4c96-8a37-cfaf557eaf65	f6255bbd-d781-4edb-b2d1-9aad47b7132b	B	২য় ইলেকট্রনের আসক্তি	1	\N
4db5f863-5f51-4d30-84da-c3c99b0d2260	f6255bbd-d781-4edb-b2d1-9aad47b7132b	C	১ম ইলেকট্রন আসক্তি	2	\N
366ed010-87cb-4aa1-b1a6-01f796e56cda	f6255bbd-d781-4edb-b2d1-9aad47b7132b	D	১ম আয়নীকরণ শক্তি	3	\N
589131c0-556f-40ac-bd7f-6240a463f253	f00b57c6-0a5c-4809-a880-7401078f3b13	A	The pH of a $10^{-2}\\,\\text{M}$ HCl solution is 2	0	\N
33edd158-924b-44eb-a8ca-839d4c98db9a	f00b57c6-0a5c-4809-a880-7401078f3b13	B	The pH of $0.01\\,\\text{M}$ $\\ce{Na2CO3}$ solution is higher than 7	1	\N
5769e29e-c4b5-4a53-a760-4cf3589b3a46	f00b57c6-0a5c-4809-a880-7401078f3b13	C	The pH of a $0.01\\,\\text{M}$ NaOH is 12	2	\N
d9af682e-8462-4916-b22c-b4cf4188a85e	f00b57c6-0a5c-4809-a880-7401078f3b13	D	The pH of a $10^{-9}\\,\\text{M}$ HCl solution is 9	3	\N
a56edd37-4759-488b-b09a-76e5b08d21fd	136398ca-8194-4ed3-a2ea-f931285eabd0	A	$\\ce{CH3OH + CH4}$	0	\N
d9ebddc7-5e4d-49e0-8f85-460de075f0be	136398ca-8194-4ed3-a2ea-f931285eabd0	B	$\\ce{CH4}$	1	\N
aa04d72d-c9a9-4210-8d8c-8dbfc95c2771	136398ca-8194-4ed3-a2ea-f931285eabd0	C	$\\ce{CH3OH + HCOOH}$	2	\N
6eb57c25-96de-45ad-a60a-cd102ffb35bb	136398ca-8194-4ed3-a2ea-f931285eabd0	D	$\\ce{HCOOH}$	3	\N
2e6869e3-4f45-4d99-817d-8acc21ef2133	30f37909-3dbb-4a80-b190-e39259217d2a	A	3	0	\N
94ecc5d6-eb9e-4492-8722-861968753547	30f37909-3dbb-4a80-b190-e39259217d2a	B	4	1	\N
e630c033-c091-4961-9d4b-2a1043951dd6	30f37909-3dbb-4a80-b190-e39259217d2a	C	6	2	\N
72c7a2e4-9551-437a-b74d-9eb4b2b36a9c	30f37909-3dbb-4a80-b190-e39259217d2a	D	2	3	\N
b189bf6c-ed64-4c34-861f-f169bc9123bc	5734fe7c-2150-4d15-9c09-fe80dd6493a2	A	2.3 g	0	\N
300eeddc-a272-488d-8d45-6e466befd015	5734fe7c-2150-4d15-9c09-fe80dd6493a2	B	23.0 g	1	\N
364d6955-0eb3-4d53-bb9f-ff8f329df227	5734fe7c-2150-4d15-9c09-fe80dd6493a2	C	46.0 g	2	\N
30446c7b-5a17-4a22-bd5e-dd73860bfc11	5734fe7c-2150-4d15-9c09-fe80dd6493a2	D	11.5 g	3	\N
7cd649cb-4c36-444f-9379-1005edb911e0	1ff83c52-dd81-4e69-904a-3f1555c693a6	A	$sp, sp^2$	0	\N
65e3db84-1459-4739-acaf-9a7a301a1aa2	1ff83c52-dd81-4e69-904a-3f1555c693a6	B	$sp, sp^3$	1	\N
110ed81e-6e5f-4cf7-95eb-f5b1dbb8ae7c	1ff83c52-dd81-4e69-904a-3f1555c693a6	C	$sp^2, sp^3$	2	\N
9fa9ff43-89ae-4902-bb59-705428540a9d	1ff83c52-dd81-4e69-904a-3f1555c693a6	D	$sp, sp^2, sp^3$	3	\N
c8c3e6dd-88f1-4d67-bca1-b87915c227cf	06c9561c-1eb8-41ac-9b33-b0b757817c2c	A	i + ii	0	\N
e92336fa-92a9-4bf5-9d1e-e441a65c703d	06c9561c-1eb8-41ac-9b33-b0b757817c2c	B	ii + iii	1	\N
1a6cd326-dada-4db1-9778-5d7ea1af9ab2	06c9561c-1eb8-41ac-9b33-b0b757817c2c	C	i + iii	2	\N
58d93d80-d740-48a1-a652-72587bfa7ef4	06c9561c-1eb8-41ac-9b33-b0b757817c2c	D	i + ii + iii	3	\N
a7c3779b-a7af-4260-a933-45288bb80a60	ab6542ff-6b20-49cd-b58a-cfd06c2b7235	A	Calcium silicate	0	\N
c7e6dc52-2f40-4cb6-acbf-364b8ef15408	ab6542ff-6b20-49cd-b58a-cfd06c2b7235	B	Calcium aluminate	1	\N
da7a085e-0a5b-404a-a862-831aeaa3f39b	ab6542ff-6b20-49cd-b58a-cfd06c2b7235	C	Magnesium oxide	2	\N
a5e396aa-0a18-4ba4-95fb-d0b2cac45942	ab6542ff-6b20-49cd-b58a-cfd06c2b7235	D	Sodium oxide	3	\N
d3aca281-e349-46af-8e85-a9a8f8e7f1e4	f7453ae7-25bb-450e-808c-7ef9876f705f	A	Pipette and beaker	0	\N
2768a63b-5e2e-472e-a5ad-3cda97b12617	f7453ae7-25bb-450e-808c-7ef9876f705f	B	Pipette and volumetric flask	1	\N
d0cf53c2-b728-43cf-9b5f-011671f86972	f7453ae7-25bb-450e-808c-7ef9876f705f	C	Measuring cylinder and volumetric flask	2	\N
c8232e97-a735-4153-9bbc-3f80fbcebdb2	f7453ae7-25bb-450e-808c-7ef9876f705f	D	Burette and beaker	3	\N
fecefac9-62e5-4120-a841-a2151b2ae404	16e61ff3-b78f-4f50-bfba-1ffb10761b16	A	$(12, 9)$	0	\N
0cf211b1-f7ec-4539-96b3-8c6570d90fd7	16e61ff3-b78f-4f50-bfba-1ffb10761b16	B	$(\\frac{7}{2}, 7)$	1	\N
8d8b0d4c-7084-4fa5-b692-c33d5575626f	16e61ff3-b78f-4f50-bfba-1ffb10761b16	C	$(4, \\frac{13}{2})$	2	\N
8158e91f-a2ae-4396-8fac-aeb9d6c3f339	16e61ff3-b78f-4f50-bfba-1ffb10761b16	D	$(9, 12)$	3	\N
f11d054f-0f80-44f8-b590-c07893f322e3	e6e0e1ce-ab24-457e-b0be-f8e99c2b867a	A	$13x - 23 = 0$	0	\N
907b1f38-eb50-46bb-8326-db053d0341ee	e6e0e1ce-ab24-457e-b0be-f8e99c2b867a	B	$3x - 7 = 0$	1	\N
16ccb2e5-4e98-4789-90d3-32a9a15db53d	e6e0e1ce-ab24-457e-b0be-f8e99c2b867a	C	$7x - 3 = 0$	2	\N
fc655f8f-50e0-4ae0-95d8-09869b9b9d42	e6e0e1ce-ab24-457e-b0be-f8e99c2b867a	D	$23x - 13 = 0$	3	\N
7f0c3687-1351-4246-8457-d7f747cbf5cc	9e4a4db0-6a84-4fe2-85eb-8d61c4eadd4d	A	4	0	\N
03a4ca9f-508d-4e32-918d-b29987f988fe	9e4a4db0-6a84-4fe2-85eb-8d61c4eadd4d	B	5	1	\N
1364aa6c-0f78-4408-837e-18076bc38062	9e4a4db0-6a84-4fe2-85eb-8d61c4eadd4d	C	6	2	\N
ac87ea1e-cd64-443f-88ab-53472cb7d149	9e4a4db0-6a84-4fe2-85eb-8d61c4eadd4d	D	8	3	\N
7b3f4480-dbfa-4cfe-8958-f101e11af13d	dca56350-0ec7-480f-841f-3d0b0d098135	A	2	0	\N
a2c379d2-2f8d-470d-8881-a63a44348611	dca56350-0ec7-480f-841f-3d0b0d098135	B	-1	1	\N
14fa6c59-e047-4d1d-98b3-171746916d7c	dca56350-0ec7-480f-841f-3d0b0d098135	C	1	2	\N
88c7df95-0077-46a4-9d0b-5115903f06b7	dca56350-0ec7-480f-841f-3d0b0d098135	D	0	3	\N
f1746153-46f8-41a2-a2e0-86b2cde52982	360baecf-34a7-437c-8c7f-c5b3d1d8b27d	A	$0^\\circ, 45^\\circ$	0	\N
5cc9f279-9628-4a5e-ba0e-55db2e00c8fb	360baecf-34a7-437c-8c7f-c5b3d1d8b27d	B	$0^\\circ, 22.5^\\circ$	1	\N
fc50165f-736e-4873-896b-4d51305933ba	360baecf-34a7-437c-8c7f-c5b3d1d8b27d	C	$45^\\circ, 45^\\circ$	2	\N
f0cea061-a81c-44da-9947-2fee1c5ca46c	360baecf-34a7-437c-8c7f-c5b3d1d8b27d	D	$22.5^\\circ, 45^\\circ$	3	\N
2efed6b6-9c7b-41ef-8a50-70b92b92ae94	02f9760b-6ba8-4014-95b2-2fd38671158c	A	$-2, -5, 3$	0	\N
32de1363-e943-4646-9555-907cc07f774c	02f9760b-6ba8-4014-95b2-2fd38671158c	B	$0, 0, 0$	1	\N
b9ced3bd-d826-4c1a-8557-e636a2c8a41b	02f9760b-6ba8-4014-95b2-2fd38671158c	C	$1, 1, 1$	2	\N
ad1ca4e8-aa52-4cb2-bb8b-5d18dc28f140	02f9760b-6ba8-4014-95b2-2fd38671158c	D	$2, 5, 3$	3	\N
849f5409-e449-45bb-819f-8b2db4dd1432	c77902b3-6550-4c6d-a2cd-3aa4f40423f9	A	$\\sin x$	0	\N
e5cce20a-87af-4793-b050-b6a150441ed7	c77902b3-6550-4c6d-a2cd-3aa4f40423f9	B	$\\sin^{-1} x$	1	\N
9c2da5fe-d925-49a1-b88b-f93fc29be071	c77902b3-6550-4c6d-a2cd-3aa4f40423f9	C	$\\cos x$	2	\N
e3d2dbd3-66fd-4294-aa58-e67116232e0c	c77902b3-6550-4c6d-a2cd-3aa4f40423f9	D	$\\sec^{-1} x$	3	\N
82b8bda0-41fb-4fc8-936c-1b89e5ebba4f	cf3e3677-791a-4595-acca-dbdb0f4d2908	A	$7\\text{ N}$	0	\N
e13c2677-d9f3-4233-96e5-317612861a87	cf3e3677-791a-4595-acca-dbdb0f4d2908	B	$3\\text{ N}$	1	\N
2ad5acad-b51b-42c4-8e7f-be334f24a326	cf3e3677-791a-4595-acca-dbdb0f4d2908	C	$\\sqrt{29}\\text{ N}$	2	\N
a2744d7d-774e-4c6c-a704-9569bb8aea2d	cf3e3677-791a-4595-acca-dbdb0f4d2908	D	$5\\text{ N}$	3	\N
e0930321-f0a5-47ca-a134-dfc341734b6b	12134285-1e26-45a8-b59f-6cda2798a7fc	A	$0$	0	\N
c5ce1d1e-20df-43f7-90c4-63bf3ab4f8a3	12134285-1e26-45a8-b59f-6cda2798a7fc	B	$6$	1	\N
71d19d01-fa26-4141-adc6-43ebfb91a0dd	12134285-1e26-45a8-b59f-6cda2798a7fc	C	$10$	2	\N
e65ae752-3a90-4115-9ea5-64befa0cedb2	12134285-1e26-45a8-b59f-6cda2798a7fc	D	$4$	3	\N
a6b1b775-85bb-48e1-b011-50b98707b230	858d0097-93f9-4bac-87dd-2d101bbd68bf	A	$\\frac{26}{3} \\text{ sq units}$	0	\N
fe0afcef-4a8d-4d77-8c62-0c0727924abf	858d0097-93f9-4bac-87dd-2d101bbd68bf	B	$\\frac{80}{3} \\text{ sq units}$	1	\N
f7777147-0c3d-440d-9834-224274ba10a5	858d0097-93f9-4bac-87dd-2d101bbd68bf	C	$\\frac{8}{3} \\text{ sq units}$	2	\N
1447eaee-c814-42cf-8e7b-d9924797412b	858d0097-93f9-4bac-87dd-2d101bbd68bf	D	$\\frac{35}{3} \\text{ sq units}$	3	\N
b78213e0-8547-471e-97fc-dd61b3ab568e	40b17b5e-c209-4c7b-9fe0-acb9ed1a0c48	A	$x^2 + y^2 = 1$	0	\N
88f8ff18-7c36-4192-9434-7eecba4f10bb	40b17b5e-c209-4c7b-9fe0-acb9ed1a0c48	B	$x^2 - y^2 = 1$	1	\N
f769535b-4924-4c01-b3b8-041a7eed03e9	40b17b5e-c209-4c7b-9fe0-acb9ed1a0c48	C	$x + y = 1$	2	\N
e347207b-5067-4c26-83e2-4a260276566e	40b17b5e-c209-4c7b-9fe0-acb9ed1a0c48	D	$x - y = 1$	3	\N
204c8039-1a3a-4d09-8a9e-f12262a58eb4	850faec6-68af-49ef-83ad-e98c2046befd	A	$k = 1$	0	\N
10faaf6c-c475-4ec2-8b1e-cd3350d590dc	850faec6-68af-49ef-83ad-e98c2046befd	B	$k = -1$	1	\N
503d7ac0-092d-4960-afcc-6b791b806e34	850faec6-68af-49ef-83ad-e98c2046befd	C	$k = 3$	2	\N
5760cd25-0727-4a1f-87b7-352c4196f159	850faec6-68af-49ef-83ad-e98c2046befd	D	$k = 0$	3	\N
024dd447-07a1-422d-9725-b3440a73cc61	72f0d0eb-9f06-46e9-b116-dc9b59c32680	A	$\\frac{3}{5}$	0	\N
c810932a-e010-4fb9-b903-295c9256ab03	72f0d0eb-9f06-46e9-b116-dc9b59c32680	B	$\\frac{3}{4}$	1	\N
73c75011-2f2b-41b3-be09-ac48675372a2	72f0d0eb-9f06-46e9-b116-dc9b59c32680	C	$\\frac{4}{5}$	2	\N
ab4a4399-e899-4c12-b9cb-916ce9487d64	72f0d0eb-9f06-46e9-b116-dc9b59c32680	D	$\\frac{2}{3}$	3	\N
0b1e7740-25bf-4ec7-92e7-aa3b4e0c31b0	bb5e6ca7-1c67-4954-8b43-e6664aca219b	A	$\\frac{3}{5}$	0	\N
7f969f58-83bd-40a8-b344-20b5f309d1fb	bb5e6ca7-1c67-4954-8b43-e6664aca219b	B	$\\frac{5}{6}$	1	\N
0c169c31-dbc7-46ca-bd59-a1c6570cce68	bb5e6ca7-1c67-4954-8b43-e6664aca219b	C	$\\frac{2}{3}$	2	\N
ad6f3bbf-bf63-4472-a69a-dacb12f8f869	bb5e6ca7-1c67-4954-8b43-e6664aca219b	D	$-\\frac{2}{3}$	3	\N
7d28d70b-2c1e-4e70-857d-d6fcfdeb3255	03afcf27-cabb-4a4b-80d8-abfd1ee920ca	A	$-1$	0	\N
48b2b6d6-72ec-4230-af1b-236ecaae5c2c	03afcf27-cabb-4a4b-80d8-abfd1ee920ca	B	$1$	1	\N
a13494de-7bb1-416a-89e3-eda37736a8b8	03afcf27-cabb-4a4b-80d8-abfd1ee920ca	C	$\\frac{3}{4}$	2	\N
7858fabb-e253-4db2-a234-bd69bc689c0d	03afcf27-cabb-4a4b-80d8-abfd1ee920ca	D	$\\frac{4}{3}$	3	\N
28505cac-3e8c-44b7-bba5-412927082787	2a8fa087-27d8-453d-93bc-340a8fd2942e	A	$x^2 - x + 1 = 0$	0	\N
0a0c9c18-5632-4bc3-8f55-34e8bc97ed7e	2a8fa087-27d8-453d-93bc-340a8fd2942e	B	$2x^2 - 2x + 1 = 0$	1	\N
2c3c42e0-68f8-46ad-a981-a7c2aae0d2f9	2a8fa087-27d8-453d-93bc-340a8fd2942e	C	$x^2 + x + 1 = 0$	2	\N
9b6cd9bc-5948-498f-86ad-f75e0501c0fb	2a8fa087-27d8-453d-93bc-340a8fd2942e	D	$2x^2 + 2x + 1 = 0$	3	\N
c646497c-6c53-4e91-ba09-2b4c37548dff	2455d12f-d4c4-4f3b-9ccf-7896d751003c	A	$\\frac{1}{9}$	0	\N
da1e8a56-ce3c-4d14-a3fc-57d197fff1fb	2455d12f-d4c4-4f3b-9ccf-7896d751003c	B	$\\frac{2}{9}$	1	\N
e66db9c5-2b85-4d5d-ba6b-dfcda24877b8	2455d12f-d4c4-4f3b-9ccf-7896d751003c	C	$\\frac{1}{11}$	2	\N
b36dd2fd-4a1d-4ce5-b5dd-feaf161c600a	2455d12f-d4c4-4f3b-9ccf-7896d751003c	D	$\\frac{2}{11}$	3	\N
f43e755e-7531-4d0a-8c2c-3b626b653341	50eca9d6-a660-49f4-886e-21ef757b589b	A	14	0	\N
5564b56f-badc-4c73-b23e-bde8861f63a2	50eca9d6-a660-49f4-886e-21ef757b589b	B	15	1	\N
86d591ed-f319-47bc-907e-ce1bb6a64cb0	50eca9d6-a660-49f4-886e-21ef757b589b	C	16	2	\N
d12e4d03-1ee4-4746-9dc8-a7ff382a763d	50eca9d6-a660-49f4-886e-21ef757b589b	D	18	3	\N
3f2813fe-bb84-43e5-babd-d9faac8cda9b	06d698e8-232a-49ee-8128-f63ac88d04d2	A	$[0, +\\infty)$	0	\N
e70db9ee-3951-4ebd-85b1-c6125c1d35fd	06d698e8-232a-49ee-8128-f63ac88d04d2	B	$(0, +\\infty)$	1	\N
535b608e-4bbe-4941-ae75-a4eedff4526b	06d698e8-232a-49ee-8128-f63ac88d04d2	C	$(-\\infty, +\\infty)$	2	\N
346cf0e8-98a4-48b9-8a54-edd1ca1784ae	06d698e8-232a-49ee-8128-f63ac88d04d2	D	$(-\\infty, 0) \\cup (0, +\\infty)$	3	\N
d98158da-4beb-4a08-bc15-e7feaf5c03c6	398cf02a-8e91-487f-99c4-9986f19e2b39	A	$\\frac{g}{2}$	0	\N
d4727400-0272-4a2a-bcfb-632787307b03	398cf02a-8e91-487f-99c4-9986f19e2b39	B	$\\frac{g}{8}$	1	\N
3ec1e203-5a25-4d39-8557-c409123535f9	398cf02a-8e91-487f-99c4-9986f19e2b39	C	$g$	2	\N
e556e0a6-eccb-43f8-be15-882d41e1ae99	398cf02a-8e91-487f-99c4-9986f19e2b39	D	$\\frac{1}{g}$	3	\N
7210601b-70b2-41f3-9b6f-80db15ae642f	b89d5282-f81b-43c3-8741-614a877c86ad	A	$-1$	0	\N
915caf72-3605-4f47-b93b-1bf8a87ecb44	b89d5282-f81b-43c3-8741-614a877c86ad	B	$3$	1	\N
289f9c5c-edd4-4fe6-bc75-adae36c451cf	b89d5282-f81b-43c3-8741-614a877c86ad	C	$1$	2	\N
deb668f6-4d76-4765-a0dd-de88062e3842	b89d5282-f81b-43c3-8741-614a877c86ad	D	$5$	3	\N
2d851925-a90f-4223-9d57-7b6c36acd7f4	6cfffde6-51cf-41b4-a4d4-c71e22c23870	A	2	0	\N
d6c12ff1-2367-48ef-b4bd-de18222a5466	6cfffde6-51cf-41b4-a4d4-c71e22c23870	B	3	1	\N
d1f1411e-60d5-44cd-89c9-b3d448e72a67	6cfffde6-51cf-41b4-a4d4-c71e22c23870	C	4	2	\N
6d83335b-60eb-4206-ba19-d19ebaad52c8	6cfffde6-51cf-41b4-a4d4-c71e22c23870	D	5	3	\N
4ab6d892-2df2-499f-8f78-e0d0b56c2cf8	a939077d-db2a-4f99-82ed-b8fa8d7f9e5d	A	12780	0	\N
27b46a26-0aef-486c-ac0c-0b08f071e81c	a939077d-db2a-4f99-82ed-b8fa8d7f9e5d	B	12708	1	\N
817f7aad-3143-4e97-9d0d-cafb0b9693d3	a939077d-db2a-4f99-82ed-b8fa8d7f9e5d	C	12870	2	\N
e094af63-06e8-4afa-9493-787804d1286a	a939077d-db2a-4f99-82ed-b8fa8d7f9e5d	D	12807	3	\N
332d5062-7fbf-4c7b-aa86-2cbf00d427ab	d422abd4-872c-408d-ac31-d32d55b374ea	A	$[\\frac{1}{2}, \\frac{9}{2}]$	0	\N
41a70d7f-5658-423e-baf0-8db6f6dea4a3	d422abd4-872c-408d-ac31-d32d55b374ea	B	$(-\\infty, \\frac{1}{2}] \\cup [\\frac{9}{2}, \\infty)$	1	\N
0c9cefe2-c071-4489-8c44-ba5a1052bb46	d422abd4-872c-408d-ac31-d32d55b374ea	C	$[-\\infty, \\frac{1}{2}]$	2	\N
dade79d6-8151-4f78-90b7-892e032feb77	d422abd4-872c-408d-ac31-d32d55b374ea	D	$[\\frac{1}{2}, \\frac{9}{2}] \\cup [\\frac{27}{2}, \\infty)$	3	\N
c2999c83-04f0-4ec8-abda-06002230aae3	642ceec3-d1b1-44da-9724-05d0c03df45b	A	$\\frac{5\\pi}{12}$	0	\N
7360af79-c17f-4a03-b46e-ab84886bd584	642ceec3-d1b1-44da-9724-05d0c03df45b	B	$\\frac{\\pi}{6}$	1	\N
46d2a04c-cf03-4dd6-9eee-3567a74ed6e7	642ceec3-d1b1-44da-9724-05d0c03df45b	C	$-\\frac{\\pi}{4}$	2	\N
3ede7a51-3429-42f8-aac1-b85d76ab219e	642ceec3-d1b1-44da-9724-05d0c03df45b	D	$\\frac{5\\pi}{12}$	3	\N
f7584251-5f33-4c32-a666-5380c1bf4d41	c2c3a64e-b2cb-4256-b8dc-fb6b1f66ed03	A	$x^2 + y^2 - 4x - 2y = 0$	0	\N
892a4daf-1b58-43e8-a959-d5bf0b70418a	c2c3a64e-b2cb-4256-b8dc-fb6b1f66ed03	B	$x^2 + y^2 + 4x + 2y = 0$	1	\N
6d52c14f-3305-4f25-90e3-737eb9f96681	c2c3a64e-b2cb-4256-b8dc-fb6b1f66ed03	C	$x^2 + y^2 + 2x + 4y = 0$	2	\N
c5e10d02-db07-40c5-9b1f-07f8dec7d7a4	c2c3a64e-b2cb-4256-b8dc-fb6b1f66ed03	D	$x^2 + y^2 - 2x - 4y = 0$	3	\N
51dd2871-5435-4038-8482-964ac00bf6c2	cc1a8a38-da4b-4ffb-bead-d9293e2a321a	A	$60^\\circ$	0	\N
0703ea94-40f0-4f72-9f5a-b5528ed87ce0	cc1a8a38-da4b-4ffb-bead-d9293e2a321a	B	$45^\\circ$	1	\N
b905c91f-63ff-4761-bba1-f40f066011bd	cc1a8a38-da4b-4ffb-bead-d9293e2a321a	C	$30^\\circ$	2	\N
0c57cb44-9075-4d82-955f-e880b5fcdf62	cc1a8a38-da4b-4ffb-bead-d9293e2a321a	D	$120^\\circ$	3	\N
6408eb7c-834f-4a00-a3a7-45e2165d3939	ae85c7fb-3043-4f6c-93bb-593346503a90	A	$3\\sqrt{3}$ sq units	0	\N
9db156c1-9f42-438d-baf4-7b7d2ffb2abb	ae85c7fb-3043-4f6c-93bb-593346503a90	B	$6\\sqrt{3}$ sq units	1	\N
c1882dba-42b6-48be-9bb8-4b13c68c8687	ae85c7fb-3043-4f6c-93bb-593346503a90	C	$6\\sqrt{6}$ sq units	2	\N
6066282e-1d14-45ba-831a-f25a07366595	ae85c7fb-3043-4f6c-93bb-593346503a90	D	$3\\sqrt{6}$ sq units	3	\N
d3683c40-ce5a-4cd3-a131-caf5e0722d88	462f083c-d6dc-4988-9632-c59710763f0a	A	$\\sin(A - B)$	0	\N
185cd1e8-0c21-4177-962a-856b6657e908	462f083c-d6dc-4988-9632-c59710763f0a	B	$\\sin(B - A)$	1	\N
1b3d472a-d993-44a2-a78c-199b44a19c1a	462f083c-d6dc-4988-9632-c59710763f0a	C	$\\cos(B - A)$	2	\N
df7e0300-b537-4eed-a145-b4dbdf02a27e	462f083c-d6dc-4988-9632-c59710763f0a	D	$\\cos(A - B)$	3	\N
756e0c71-fde8-4f35-aa58-316ec800cdae	481d86de-d333-486b-af5a-9a1bd481a2f7	A	$\\frac{2}{3}$	0	\N
3931c25d-fb92-4de0-a88d-d2b9390178d8	481d86de-d333-486b-af5a-9a1bd481a2f7	B	$\\frac{3}{2}$	1	\N
b8e70e59-1c34-4292-ad59-25338ede6c6c	481d86de-d333-486b-af5a-9a1bd481a2f7	C	$\\frac{1}{3}$	2	\N
c034a6b8-2ae1-400b-906a-01b4d1584b56	481d86de-d333-486b-af5a-9a1bd481a2f7	D	$\\frac{1}{2}$	3	\N
193f1a11-c0f8-436e-a3cc-7ced4c7d7c8c	ab6987fc-cd5d-47b8-b253-3bded6040ef5	A	Pteris	0	\N
fab94465-cdba-48f6-924a-00925fcc96ac	ab6987fc-cd5d-47b8-b253-3bded6040ef5	B	Dracaena	1	\N
89012d65-d09f-4e7f-91f7-60b9d5705ead	ab6987fc-cd5d-47b8-b253-3bded6040ef5	C	Nymphaea	2	\N
b6424296-177f-4aaa-8a65-07176fa1aeb1	ab6987fc-cd5d-47b8-b253-3bded6040ef5	D	Cynodon	3	\N
1c534115-8f02-4339-b526-49982d21e476	2821f398-5302-478c-b499-259c7dc29937	A	Gnetum	0	\N
d73e452c-2bd9-401a-a3a0-7971450a8ddd	2821f398-5302-478c-b499-259c7dc29937	B	Ginkgo	1	\N
dfbfdb8e-be3c-41a2-989c-3c4355288dd8	2821f398-5302-478c-b499-259c7dc29937	C	Pinus	2	\N
a63fce99-7f84-45cc-9a6a-49c5d8338a01	2821f398-5302-478c-b499-259c7dc29937	D	Cycas	3	\N
7caec11f-6eac-4d41-b88e-239dcff38c0b	aae62c26-f151-420a-8872-735d520ca8d0	A	Malvaceae	0	\N
1e5611b9-1395-4773-b44e-1cab06dd1b46	aae62c26-f151-420a-8872-735d520ca8d0	B	Poaceae	1	\N
363f1b2f-46bb-4f56-ad7e-ec20eb063e95	aae62c26-f151-420a-8872-735d520ca8d0	C	Liliaceae	2	\N
03b81608-731d-4489-b9da-7f82b9abe16b	aae62c26-f151-420a-8872-735d520ca8d0	D	Tilliaceae	3	\N
2a68110a-c9e6-45fa-8d51-c5c119748e11	2d83b941-c6e6-4c00-b25a-bbf7d96ff482	A	Allium odorum	0	\N
3c6520ff-599b-4765-9f85-09e7e852816b	2d83b941-c6e6-4c00-b25a-bbf7d96ff482	B	Solanum nigrum	1	\N
d142c9f0-680b-4a02-893f-da83b77be6f7	2d83b941-c6e6-4c00-b25a-bbf7d96ff482	C	Parthanium argentatum	2	\N
97b383d6-5f8e-4501-9b7f-8a06a88969d3	2d83b941-c6e6-4c00-b25a-bbf7d96ff482	D	Hieracium excellens	3	\N
92a19279-669a-403f-bd92-292bfe99c753	0551c75e-5559-4163-8f4a-8884bcfae7b0	A	অ্যানিলিডা	0	\N
533b1e66-b3b9-485e-9b88-885b9949dc74	0551c75e-5559-4163-8f4a-8884bcfae7b0	B	মলাস্কা	1	\N
64e8d8cf-84cd-4af7-bff9-e812832e5eb6	0551c75e-5559-4163-8f4a-8884bcfae7b0	C	নেমাটোডা	2	\N
dda2ffd6-5f30-4311-9880-771437012eb5	0551c75e-5559-4163-8f4a-8884bcfae7b0	D	একাইনোডার্মাটা	3	\N
5acbbc0c-3cc7-4613-af8b-3855f57a9478	f69ffa1a-a6d1-41fb-a035-01b81a1827d9	A	পরিফেরা	0	\N
57d80562-3cbe-44fa-bba8-ea5d3fb9955c	f69ffa1a-a6d1-41fb-a035-01b81a1827d9	B	নিডারিয়া	1	\N
112e57fa-52b0-4812-b335-3a388f16ce1e	f69ffa1a-a6d1-41fb-a035-01b81a1827d9	C	নেমাটোডা	2	\N
a1f8a21a-fb70-46a1-aaeb-37c08990ddb6	f69ffa1a-a6d1-41fb-a035-01b81a1827d9	D	মলাস্কা	3	\N
3fd4221b-d83a-4856-af1f-051fc679ecdc	8ef8154e-4927-4902-b420-1de5d6080cf0	A	ল্যাব্রাম	0	\N
f1806ea2-9708-4b4d-97b7-83eecae47e59	8ef8154e-4927-4902-b420-1de5d6080cf0	B	ম্যান্ডিবল	1	\N
4c28919f-972f-4378-bdc8-938381293ab4	8ef8154e-4927-4902-b420-1de5d6080cf0	C	ম্যাক্সিলা	2	\N
d287dddc-03ce-49c3-8973-148484ebc7d1	8ef8154e-4927-4902-b420-1de5d6080cf0	D	হাইপোফ্যারিংস	3	\N
337110df-9ade-4c9a-938a-b4816fc2560e	a075b5c2-6407-482f-8c2a-f36f20237262	A	এক জোড়া	0	\N
67507eff-088b-45b4-9f4f-a33350950662	a075b5c2-6407-482f-8c2a-f36f20237262	B	দুই থেকে তিন জোড়া	1	\N
3cb9841a-70e5-416b-8df7-c31d3f25ee94	a075b5c2-6407-482f-8c2a-f36f20237262	C	চার জোড়া	2	\N
f2cfe422-008e-4f38-be86-ec76bb4bb7a6	a075b5c2-6407-482f-8c2a-f36f20237262	D	পাঁচ থেকে সাত জোড়া	3	\N
ca409792-8146-4b02-96c1-d10863de1167	757833d3-baca-4e74-b8c2-b8bb3667c3b0	A	কন্ড্রিকথিস	0	\N
7a8aa437-fc3a-4127-9179-944e92a395c0	757833d3-baca-4e74-b8c2-b8bb3667c3b0	B	অস্টিকথিস	1	\N
ccb5aedb-471d-4edb-a61a-6b30d0768a93	757833d3-baca-4e74-b8c2-b8bb3667c3b0	C	রেপটিলিয়া	2	\N
87323a64-4dd7-4e3f-aea1-62ebf6d0149a	757833d3-baca-4e74-b8c2-b8bb3667c3b0	D	মিক্সিনি	3	\N
9584478f-6372-42db-9f76-613a37e2d18b	8fda6522-142a-4ec3-95a8-c373ca83437a	A	নন-কার্বোহাইড্রেট উৎস থেকে গ্লুকোজ সংশ্লেষণ	0	\N
9a9e45f0-c061-4c8d-bc92-6e78a1bb2740	8fda6522-142a-4ec3-95a8-c373ca83437a	B	নন-কার্বোহাইড্রেট উৎস থেকে গ্লাইকোজেন সংশ্লেষণ	1	\N
d91b88c3-0ca9-48e5-b44c-ad1908888f27	8fda6522-142a-4ec3-95a8-c373ca83437a	C	কার্বোহাইড্রেট উৎস থেকে গ্লাইকোজেন সংশ্লেষণ	2	\N
3aedc25a-c099-4933-a367-8a6a7268c919	8fda6522-142a-4ec3-95a8-c373ca83437a	D	কার্বোহাইড্রেট উৎস থেকে গ্লুকোজ সংশ্লেষণ	3	\N
feb03aa5-48f1-4af4-b585-44bf0fbd37ff	b1c73711-447f-4b00-aa6a-88f81edb82f0	A	মিউকাস	0	\N
8c7172c3-3216-4d7b-9387-1fa5c9c3cb1e	b1c73711-447f-4b00-aa6a-88f81edb82f0	B	পেপটিক	1	\N
bdb1b4a8-c670-4790-823e-d4928388e2ec	b1c73711-447f-4b00-aa6a-88f81edb82f0	C	প্যারাইটাল	2	\N
cf882b83-fd43-4b83-92fa-374d18e4fcd8	b1c73711-447f-4b00-aa6a-88f81edb82f0	D	কার্ডিয়াক	3	\N
3efe51bb-b22d-4340-82b1-6a3ee903d631	9f53e265-4917-4208-ab93-995ea0bcbfff	A	উভয়ই দেহপ্রাচীর ও পরিপাক নালির মধ্যবর্তী ফাঁকা স্থান	0	\N
69c6354c-9d7c-4c1f-ab17-d4efec2a8056	9f53e265-4917-4208-ab93-995ea0bcbfff	B	উভয়ই সকল উপাঙ্গ পর্যন্ত বিস্তৃত	1	\N
4177f479-7ed3-45c8-b1db-d82bc1a5720b	9f53e265-4917-4208-ab93-995ea0bcbfff	C	উভয়ই রক্ত সংবহনতন্ত্রের অংশ	2	\N
7dc4b739-36f5-4792-b68a-c26484535669	9f53e265-4917-4208-ab93-995ea0bcbfff	D	উভয়ই স্নায়ুতন্ত্রের অংশ	3	\N
e34a5091-291a-43ae-ae09-278326ae5c46	ba3792ee-1e18-4743-835c-92deb1e266b2	A	ডান অলিন্দে	0	\N
45d72f95-b877-4df1-8961-a053a9f7a5fe	ba3792ee-1e18-4743-835c-92deb1e266b2	B	বাম অলিন্দে	1	\N
f18b6488-68b1-4442-94a6-06795d83a114	ba3792ee-1e18-4743-835c-92deb1e266b2	C	ডান নিলয়ে	2	\N
73eaf354-3611-475c-9d87-5917f6660102	ba3792ee-1e18-4743-835c-92deb1e266b2	D	বাম নিলয়ে	3	\N
51109591-3191-4f01-a7b2-05ce9e194f4b	7e62838f-d484-4dca-9617-595d9bfd0bd2	A	Riccia	0	\N
0146f99c-d952-48b1-a26f-0264fd71972c	7e62838f-d484-4dca-9617-595d9bfd0bd2	B	Marchantia	1	\N
f1a83a65-d784-4a64-bb31-a2f97c21d3cc	7e62838f-d484-4dca-9617-595d9bfd0bd2	C	Pteris	2	\N
efa26a0d-da69-4417-ba10-f78d54f2f5f3	7e62838f-d484-4dca-9617-595d9bfd0bd2	D	Drynaria	3	\N
97678704-1c5c-4497-a95b-05d26cd4bce0	1639acbb-7206-4b85-983c-add68fe6a74c	A	Ulothrix	0	\N
2bc85ea0-da6b-45fd-bb82-953f93ec5f31	1639acbb-7206-4b85-983c-add68fe6a74c	B	Botrydium	1	\N
e4133d9b-ffaa-4dc9-a6f6-4fffb49fcc6a	1639acbb-7206-4b85-983c-add68fe6a74c	C	Nostoc	2	\N
404bfc2f-bffc-4ac9-af54-2157d01b1b01	1639acbb-7206-4b85-983c-add68fe6a74c	D	Polysiphonia	3	\N
dd6a8fb7-9542-4d2e-9ab3-878e6291b4c7	93d5cd06-b557-45d1-bd29-20690a4f3df3	A	ড্যানিয়েলি এবং ডেভসন	0	\N
1d23e16d-1209-45b6-b959-958c3b160821	93d5cd06-b557-45d1-bd29-20690a4f3df3	B	লিনার্ড এবং সিঙ্গার	1	\N
1ea8ecf0-eb55-41fc-bf42-2fa6a9042c0d	93d5cd06-b557-45d1-bd29-20690a4f3df3	C	সিঙ্গার এবং নিকলসন	2	\N
7248ff4e-667f-4e58-a489-9fd4730cf06f	93d5cd06-b557-45d1-bd29-20690a4f3df3	D	বেনসন	3	\N
523325f9-0e9a-4f23-a355-6dd063acbab0	f12d0cda-d5a6-4c13-ae7f-6861ad9c4141	A	90-95%	0	\N
4355e8c9-0b20-4f33-ac32-3a16ff50de22	f12d0cda-d5a6-4c13-ae7f-6861ad9c4141	B	5-10%	1	\N
6c98dda7-06e2-40be-894e-68a4cc7a5c87	f12d0cda-d5a6-4c13-ae7f-6861ad9c4141	C	50-60%	2	\N
6235609a-a169-4a3a-993e-357561aa2e70	f12d0cda-d5a6-4c13-ae7f-6861ad9c4141	D	65-85%	3	\N
dc63d073-88b7-40ef-954f-6c0c6ffe13c6	220000a0-d1ed-4354-8a39-e7ac1d00f389	A	লিউসিন	0	\N
810ce777-9ec7-4729-bb06-5c3ebd5a092a	220000a0-d1ed-4354-8a39-e7ac1d00f389	B	লাইসিন	1	\N
bc2fb9a1-a1a2-4f44-a19e-2cf0be1ace24	220000a0-d1ed-4354-8a39-e7ac1d00f389	C	অরনিথিন	2	\N
f236e039-a12c-4891-a65d-f45f55b3ccfe	220000a0-d1ed-4354-8a39-e7ac1d00f389	D	ভ্যালিন	3	\N
eda11e90-484f-4861-b39d-632d5db32ea2	116df7ab-762b-44ba-8af4-5d866d28aedd	A	Endocarpon miniatum	0	\N
a71f313d-d93a-42d7-94df-75df40644a42	116df7ab-762b-44ba-8af4-5d866d28aedd	B	Cladonia rangiferina	1	\N
8382950d-6410-4951-aeb1-c3a1be94d7a1	116df7ab-762b-44ba-8af4-5d866d28aedd	C	Xanthoria sp.	2	\N
0a237f2f-ea7d-4263-a28f-55251d160ce1	116df7ab-762b-44ba-8af4-5d866d28aedd	D	Peltigera sp.	3	\N
c205efb3-b7d8-4b79-8c91-61457a4123a4	35c7efb2-0fd3-4be9-bac4-e918263e9033	A	$3.4\\,\\text{nm}$	0	\N
5521597a-1e6f-4bba-a5a7-0a867ddab7d3	35c7efb2-0fd3-4be9-bac4-e918263e9033	B	$2\\,\\text{nm}$	1	\N
787022cf-fce4-484e-bf9a-7b09fd73388c	35c7efb2-0fd3-4be9-bac4-e918263e9033	C	$0.34\\,\\text{nm}$	2	\N
d442aa37-7ae5-486f-a5c9-70a9c96da7a2	35c7efb2-0fd3-4be9-bac4-e918263e9033	D	$34\\,\\text{nm}$	3	\N
92a484dd-fa8d-43fc-b941-8a87e6f4abd4	574bd461-a733-4802-b218-73d8044103fc	A	উদ্ভিদ উদ্যান	0	\N
92bce2b4-8081-4dab-9040-8149114ba8bd	574bd461-a733-4802-b218-73d8044103fc	B	বন্যজীব অভয়ারণ্য	1	\N
4de676cc-9666-45f8-b2e5-04a6e27ba3b7	574bd461-a733-4802-b218-73d8044103fc	C	বীজ ব্যাংক	2	\N
5740882e-8ac7-414e-b50c-56eb8a31f4e3	574bd461-a733-4802-b218-73d8044103fc	D	চিড়িয়াখানা	3	\N
5d16b801-63e9-4218-995c-3f707393746b	cfaad6fd-92a1-435a-8475-5ecd234da16e	A	Bacillus	0	\N
9a938db7-834d-47fe-aecf-d93d7a5bb7c9	cfaad6fd-92a1-435a-8475-5ecd234da16e	B	Lactobacillus	1	\N
a16902b7-8095-45df-933d-9a1b9d47ef12	cfaad6fd-92a1-435a-8475-5ecd234da16e	C	E. coli	2	\N
5325c7aa-8e04-445e-86a6-8a42b7080750	cfaad6fd-92a1-435a-8475-5ecd234da16e	D	Agrobacterium	3	\N
49203fab-f5da-442f-afbc-5288e536d94c	3aab1dfa-d407-4897-9e36-bc30e8f15a82	A	TIV	0	\N
f9e01df5-ef28-4be5-8828-574d418a70f3	3aab1dfa-d407-4897-9e36-bc30e8f15a82	B	$\\text{T}_2\\text{virus}$	1	\N
4022e70c-7483-4ac9-8355-7afb189f72a2	3aab1dfa-d407-4897-9e36-bc30e8f15a82	C	Vaccinia	2	\N
8d55d380-34a2-4268-b266-3253cdd524d4	3aab1dfa-d407-4897-9e36-bc30e8f15a82	D	HIV	3	\N
14a8ba0b-261c-42a0-b6c7-e5d5d4b21beb	d10b6e36-5b5b-477e-9140-70866e9e367b	A	Phytophthora	0	\N
197e73d3-bf53-424c-b171-9617408bb52c	d10b6e36-5b5b-477e-9140-70866e9e367b	B	Alternaria	1	\N
2b611cda-7a74-476d-a16e-081a5a79ea9a	d10b6e36-5b5b-477e-9140-70866e9e367b	C	Rhizopus	2	\N
737b3a85-47ad-4c68-aa16-5d5bcebb9723	d10b6e36-5b5b-477e-9140-70866e9e367b	D	Trichophyton	3	\N
3902c60b-f95d-47d7-98e9-37b175f4a1b3	65f31937-aedf-4548-8ed2-0580d0e78973	A	পেরিকন্ড্রিয়াম	0	\N
84186b32-cbcc-41e2-abc1-ae2376f226e5	65f31937-aedf-4548-8ed2-0580d0e78973	B	কিউটিকল	1	\N
36a6515b-e6d6-411d-8ed6-87124cf01f16	65f31937-aedf-4548-8ed2-0580d0e78973	C	পেরিট্রফিক মেমব্রেন	2	\N
61b159b6-1448-4d44-a054-55abe596ee15	65f31937-aedf-4548-8ed2-0580d0e78973	D	পেরিঅস্টিয়াম	3	\N
24a3f99f-ce16-4d6b-bba6-6ff8ca3aa3fc	ad97fc36-394b-4e9c-8716-9bf149aeccc8	A	ম্যাক্সিলারি	0	\N
51aea461-27fb-45e5-9087-50b24948b34e	ad97fc36-394b-4e9c-8716-9bf149aeccc8	B	ম্যান্ডিবুলার	1	\N
ca017e55-45ce-4872-af82-d0fa147e546c	ad97fc36-394b-4e9c-8716-9bf149aeccc8	C	ভেগাস	2	\N
4fb284b0-e47e-410a-b845-d116603630b8	ad97fc36-394b-4e9c-8716-9bf149aeccc8	D	হাইপোগ্লোসাল	3	\N
608b3bfc-05b6-485e-a6de-d7f33d77bd2a	72cd0a9b-c680-466a-adb2-5fb00c5e9d83	A	অভ্যাসগত	0	\N
921a7acf-fdca-425f-ad2d-c584811b9b0b	72cd0a9b-c680-466a-adb2-5fb00c5e9d83	B	সহজাত	1	\N
6127a3af-29a9-4726-b9a1-248771625af0	72cd0a9b-c680-466a-adb2-5fb00c5e9d83	C	শিক্ষণ	2	\N
12fdc7fa-d4f5-4474-87fa-8e46e13cb09b	72cd0a9b-c680-466a-adb2-5fb00c5e9d83	D	অনুকরণ	3	\N
0155fbd6-51f9-4db4-98da-571a4b3946d1	268dfbaf-ace5-47d8-8099-60a6b502cb28	A	প্রোটিন	0	\N
6a75aefc-4a92-4326-8044-ec01a9aed308	268dfbaf-ace5-47d8-8099-60a6b502cb28	B	লিপিড	1	\N
33cfc50c-7fa0-45c9-8b71-9e31a16e8708	268dfbaf-ace5-47d8-8099-60a6b502cb28	C	এনজাইম	2	\N
b6b2bf31-1710-4617-ae1e-f7957c224890	268dfbaf-ace5-47d8-8099-60a6b502cb28	D	কোএনজাইম	3	\N
cc8d14f8-7ea0-4094-b79c-f2f9097583bc	ab4d7ade-8a5b-449f-b31f-494aedf2e19e	A	$22\\ \\text{\\AA}$	0	\N
2b400f5d-223d-4721-9e95-26d155d47c06	ab4d7ade-8a5b-449f-b31f-494aedf2e19e	B	$2.2\\ \\text{\\AA}$	1	\N
b73df6f6-3d7b-4db3-8576-1d80b6a9eb73	ab4d7ade-8a5b-449f-b31f-494aedf2e19e	C	$3.4\\ \\text{\\AA}$	2	\N
07a5b952-e134-4130-916b-fa549d06dc20	ab4d7ade-8a5b-449f-b31f-494aedf2e19e	D	$34\\ \\text{\\AA}$	3	\N
e837b10e-fab9-4494-9e1e-a1f5a94ad844	b8a9a920-ed6d-4703-bf9f-ecb99715dc11	A	ওয়ালেসিয়া	0	\N
ff616a2f-adb6-4f97-aa8b-866a21e1a449	b8a9a920-ed6d-4703-bf9f-ecb99715dc11	B	ওয়েবারিয়া	1	\N
f8b3d778-4c05-4026-aea2-145ca53e4255	b8a9a920-ed6d-4703-bf9f-ecb99715dc11	C	ইন্দোচীন	2	\N
ad3bfb8e-1a74-49d6-b432-a5ce41ec0cff	b8a9a920-ed6d-4703-bf9f-ecb99715dc11	D	ওয়ালেস-ওয়েবারিয়া	3	\N
793d1db5-0cb5-4c02-8a72-3261dcd145a7	e92084ad-292d-4840-abe3-026cbdede660	A	$60^\\circ$	0	\N
eddb1204-fc2e-4af3-8f0f-5f9519a37ca0	e92084ad-292d-4840-abe3-026cbdede660	B	$30^\\circ$	1	\N
f65bbc93-c2fa-48ff-a5c0-502e8a2abbd3	e92084ad-292d-4840-abe3-026cbdede660	C	$45^\\circ$	2	\N
11a15a95-ef62-461d-9ac6-297f1b510ff2	e92084ad-292d-4840-abe3-026cbdede660	D	$90^\\circ$	3	\N
dc0fb9fc-5082-4116-a610-2b4113efd6d6	1b88a88c-cb2d-4184-a5e0-de08129088a2	A	$\\frac{m_1}{m_2}$	0	\N
0258bb38-01c3-4527-989e-a77b5180696b	1b88a88c-cb2d-4184-a5e0-de08129088a2	B	$-\\frac{m_1}{m_2}$	1	\N
b1a06322-a566-400a-b33f-c429b609cde6	1b88a88c-cb2d-4184-a5e0-de08129088a2	C	$\\frac{m_2}{m_1}$	2	\N
24e32ad4-556a-4a44-9373-27abe2211fe6	1b88a88c-cb2d-4184-a5e0-de08129088a2	D	$\\sqrt{\\frac{m_2}{m_1}}$	3	\N
6abce20f-9de0-4bbd-98b6-e4f9c271a44e	01cdbfcd-5a74-450f-b9fa-69200db938c3	A	amu	0	\N
657ff351-a96f-4c57-be48-a9f0dbde6216	01cdbfcd-5a74-450f-b9fa-69200db938c3	B	$\\text{Nm}^{-1}\\text{s}^2$	1	\N
dad99d34-393b-49cb-9671-b803134c7e81	01cdbfcd-5a74-450f-b9fa-69200db938c3	C	MeV	2	\N
8ffeac96-846b-465f-8640-df56d7af7cd5	01cdbfcd-5a74-450f-b9fa-69200db938c3	D	$\\frac{\\text{MeV}}{c^2}$	3	\N
8cac95d7-b502-402c-a848-62a9ce9523e9	cbc7a85d-71ac-44c7-baa8-1aa8f8287b9a	A	$2\\pi$	0	\N
c41dd1e6-5da3-4034-9e44-f1c424e333e4	cbc7a85d-71ac-44c7-baa8-1aa8f8287b9a	B	$\\pi$	1	\N
c553edb6-de0d-4860-b77d-9338903ccf9f	cbc7a85d-71ac-44c7-baa8-1aa8f8287b9a	C	$\\frac{\\pi}{2}$	2	\N
65ad7c6b-735c-408a-9d2e-c3cdc1a76288	cbc7a85d-71ac-44c7-baa8-1aa8f8287b9a	D	$\\frac{\\pi}{4}$	3	\N
8f48c9a6-2d38-4283-9cd9-10fb67066f45	3685e2c6-f04d-478e-87ed-12d8cc72939c	A	$a \\sin \\theta = (2n + 1) \\frac{\\lambda}{2}$	0	\N
be2784e0-657a-4c28-a176-0c19fcab9a69	3685e2c6-f04d-478e-87ed-12d8cc72939c	B	$a \\sin \\theta = n\\lambda$	1	\N
4e47577d-17a5-4bed-b250-c5e33d70cd25	3685e2c6-f04d-478e-87ed-12d8cc72939c	C	$a \\sin \\theta = n \\frac{\\lambda}{2}$	2	\N
1f8c9336-73e4-40f2-b722-e0487c7a749d	3685e2c6-f04d-478e-87ed-12d8cc72939c	D	$a \\sin \\theta = (2n + 1) \\lambda$	3	\N
0c995304-8477-4af0-9a8d-bb28481c6b0a	f43d91bf-4188-4d97-8011-e759b608a2e2	A	$500\\,\\text{kcal}$	0	\N
0902fc16-503b-41f0-aa8a-a8594996020f	f43d91bf-4188-4d97-8011-e759b608a2e2	B	$1000\\,\\text{cal}$	1	\N
867a8ca3-286b-42b1-b704-34fa2da543b5	f43d91bf-4188-4d97-8011-e759b608a2e2	C	$500\\,\\text{cal}$	2	\N
6d785cb1-3a5d-4aff-b9e3-600b9d0a41ab	f43d91bf-4188-4d97-8011-e759b608a2e2	D	$10\\,\\text{kcal}$	3	\N
d105debe-8e63-471b-b5c6-6b726701ada5	19ccfdd4-936b-41cd-b943-379ebb3eb295	A	$0.2\\,\\text{A}$	0	\N
4ccb4980-8ac1-4d60-8085-ab79731a6083	19ccfdd4-936b-41cd-b943-379ebb3eb295	B	$0.4\\,\\text{A}$	1	\N
c6414034-5c9f-4d22-93e9-4044080f3bab	19ccfdd4-936b-41cd-b943-379ebb3eb295	C	$0.6\\,\\text{A}$	2	\N
c6a4cfb1-4eb9-4eac-8a04-cec6b9496af3	19ccfdd4-936b-41cd-b943-379ebb3eb295	D	$1.2\\,\\text{A}$	3	\N
ed69b2bd-af95-404e-aa38-d6a9d95ea17f	73b59855-deaa-4f41-9913-5a53a9111826	A	$2/\\pi^2\\,\\text{s}$	0	\N
2fb2cd95-7170-4414-adfd-3b90246eaec6	73b59855-deaa-4f41-9913-5a53a9111826	B	$\\pi^2/2\\,\\text{s}$	1	\N
fd3fe588-6a3b-4ac8-82aa-2b426f037d96	73b59855-deaa-4f41-9913-5a53a9111826	C	$\\pi/2\\,\\text{s}$	2	\N
6ccbab14-ad33-40c1-9752-8854979b1acd	73b59855-deaa-4f41-9913-5a53a9111826	D	$\\pi^2/4\\,\\text{s}$	3	\N
942d1d03-3024-4943-942c-57c9bcf20ed4	cb3208dc-39aa-44b3-8625-60ee6507cbf3	A	[IMAGE_1]	0	p01_q09_01.png
5f36f024-c5d5-4406-b3b8-790da36d7db1	cb3208dc-39aa-44b3-8625-60ee6507cbf3	B	[IMAGE_2]	1	p01_q09_02.png
ad94590f-cd80-409a-8fe9-a1fefc34b480	cb3208dc-39aa-44b3-8625-60ee6507cbf3	C	[IMAGE_3]	2	p01_q09_03.png
96daff0f-903f-4f36-b3d9-bdfbb6586f88	cb3208dc-39aa-44b3-8625-60ee6507cbf3	D	[IMAGE_4]	3	p01_q09_04.png
35dc9f38-7664-4ce2-b9f0-8e92fb705615	f4dded80-a2f9-4297-8907-775b0136b46a	A	$q(\\vec{E} + \\vec{v} \\times \\vec{B})$	0	\N
5d9f0faf-6d38-4899-9982-aa20a65991ee	f4dded80-a2f9-4297-8907-775b0136b46a	B	$q(\\vec{E} + \\vec{v} \\cdot \\vec{B})$	1	\N
7a8f70a8-b06d-4507-bdfb-267c22169d7d	f4dded80-a2f9-4297-8907-775b0136b46a	C	$q\\vec{E}$	2	\N
a2faba11-7293-4d42-9efd-bd6f0dd17bcb	f4dded80-a2f9-4297-8907-775b0136b46a	D	$q(\\vec{E} + \\vec{B})$	3	\N
49c05425-f882-4e47-99a6-4a3bbd5c4b17	738590ae-23a1-4699-bc44-edbe819148d2	A	$4\\,\\text{cm}$	0	\N
26491d68-dbae-401b-8a6f-4a41e7c5284a	738590ae-23a1-4699-bc44-edbe819148d2	B	$6\\,\\text{cm}$	1	\N
fd21e74e-7799-4409-b441-6bad241b6a92	738590ae-23a1-4699-bc44-edbe819148d2	C	$9\\,\\text{cm}$	2	\N
9378c5f4-d23f-4ce1-a524-5bb0ac07a34b	738590ae-23a1-4699-bc44-edbe819148d2	D	$12\\,\\text{cm}$	3	\N
fdc314eb-da72-4e50-9d1f-04e3f448eccb	2a7dc3da-9520-4108-929c-a14782e25c36	A	$\\frac{10 + \\sqrt{198}}{9.8}\\,\\text{s}$	0	\N
8709b3dc-7e92-461e-97e0-45d2c24868bb	2a7dc3da-9520-4108-929c-a14782e25c36	B	$\\frac{10 \\sqrt{198}}{9.8}\\,\\text{s}$	1	\N
4b78375b-e791-4a68-89b8-c3e9d17e57ee	2a7dc3da-9520-4108-929c-a14782e25c36	C	$\\frac{10 \\pm \\sqrt{198}}{9.8}\\,\\text{s}$	2	\N
8f912df4-7a1b-4135-b543-9eb66c17b6b9	2a7dc3da-9520-4108-929c-a14782e25c36	D	$\\frac{10 \\pm \\sqrt{2}}{9.8}\\,\\text{s}$	3	\N
6f51fe65-78b4-4e94-93b5-9c6ef555dc2e	ed6ec807-2624-4a5a-9f90-6aea86d4fa8b	A	$1:8$	0	\N
5efe174b-2c76-4c94-9ec4-ed23d3954c23	ed6ec807-2624-4a5a-9f90-6aea86d4fa8b	B	$1:6$	1	\N
b0dd4254-abfd-45d3-9214-a6224270c105	ed6ec807-2624-4a5a-9f90-6aea86d4fa8b	C	$1:4$	2	\N
cff76c91-08d1-45b3-b498-8d0f4de57385	ed6ec807-2624-4a5a-9f90-6aea86d4fa8b	D	$1:2$	3	\N
9780a0fb-cc8d-4b39-b1a5-9c2077e65821	4ce9e2ef-41c9-44d4-9476-d83c495c093d	A	$25\\,\\text{cm}$	0	\N
566840ed-8ed9-460d-8978-b6f244484dbe	4ce9e2ef-41c9-44d4-9476-d83c495c093d	B	$50\\,\\text{cm}$	1	\N
7cf29ea8-0f42-454b-97ff-620f0f38bb25	4ce9e2ef-41c9-44d4-9476-d83c495c093d	C	$100\\,\\text{cm}$	2	\N
a8eecfe4-e5d3-4870-b6dd-d728e8becf3c	4ce9e2ef-41c9-44d4-9476-d83c495c093d	D	$200\\,\\text{cm}$	3	\N
81b2a9c6-aedf-4bf8-92b6-38aac3b08d04	2ed4d1d4-dbdf-4ccc-8fd9-0194c445f242	A	an $\\alpha$ particle	0	\N
eecfce44-1dee-4a1a-b958-47903a34aa98	2ed4d1d4-dbdf-4ccc-8fd9-0194c445f242	B	an electron	1	\N
0da47810-dd2d-49f2-ad42-bc4884447ee0	2ed4d1d4-dbdf-4ccc-8fd9-0194c445f242	C	a positron	2	\N
c19524d4-69d5-4ab3-8ffe-fc394b05edae	2ed4d1d4-dbdf-4ccc-8fd9-0194c445f242	D	a proton	3	\N
af15acb4-5c38-4e3f-b520-62e902e76a19	f94170d0-cff7-45cc-961c-a4730e275392	A	Glycosidic bond	0	\N
5efd7eca-bb39-44ab-8075-1eba8fe787c4	f94170d0-cff7-45cc-961c-a4730e275392	B	Peptide bond	1	\N
0562bb29-f46c-44bc-b0ce-9b6e0dd5eba7	f94170d0-cff7-45cc-961c-a4730e275392	C	Hydrogen bond	2	\N
f81eb822-a13e-4532-ad57-469ee49d0230	f94170d0-cff7-45cc-961c-a4730e275392	D	Metallic bond	3	\N
8817a922-8902-4cc1-a7e5-38a43b35eabf	96d6c2e1-271c-4e56-9c4e-af357a936773	A	$\\ce{Fe + Br2 -> Fe^{2+} + 2Br^{-}}$	0	\N
7f9fbe45-ab16-4c84-a161-7f043f24e5e2	96d6c2e1-271c-4e56-9c4e-af357a936773	B	$\\ce{Fe + 2Br^{-} -> Fe^{2+} + Br2}$	1	\N
782969fb-9f54-4139-96f5-76b36b1650b6	96d6c2e1-271c-4e56-9c4e-af357a936773	C	$\\ce{Fe^{2+} + Br2 -> Fe + 2Br^{-}}$	2	\N
c7830473-d6b7-403e-9291-71e8823b83f1	96d6c2e1-271c-4e56-9c4e-af357a936773	D	$\\ce{Fe -> Fe^{3+} + 2Br^{-}}$	3	\N
57ee10bc-d781-4470-b993-e89f966c0585	b6378ecd-e623-4031-ad9d-b1ee9069b25e	A	গ্যাস ক্রোমাটোগ্রাফি	0	\N
7489beff-5989-4f47-a8dc-eb6452a50a90	b6378ecd-e623-4031-ad9d-b1ee9069b25e	B	কাগজ ক্রোমাটোগ্রাফি	1	\N
7241c216-9ae1-42ff-a12c-e9111b2dc598	b6378ecd-e623-4031-ad9d-b1ee9069b25e	C	কলাম ক্রোমাটোগ্রাফি	2	\N
36a2a5b9-fb15-4d45-9f9b-22f1b9973f5e	b6378ecd-e623-4031-ad9d-b1ee9069b25e	D	পাতলা স্তর ক্রোমাটোগ্রাফি	3	\N
1d141fb5-dcb1-4a25-9b8f-e6450456acbf	8867992c-ed13-405c-99b3-a754695250aa	A	$\\ce{(CH3)3N}$	0	\N
5d574bb5-4cb3-4610-85fa-4e7aa3efacbf	8867992c-ed13-405c-99b3-a754695250aa	B	$\\ce{CH3CH=CH2}$	1	\N
db47411d-1b23-4351-8347-b3a5c6620b51	8867992c-ed13-405c-99b3-a754695250aa	C	$\\ce{(CH3)2NH}$	2	\N
6c3357d1-ff44-4277-956e-28fcb605c878	8867992c-ed13-405c-99b3-a754695250aa	D	$\\ce{CH3CH=CHCH3}$	3	\N
3a972b77-b786-46f2-9a29-a86890895598	92a4ce58-aad4-4b26-99af-b0b87c0eba6c	A	Ethanal	0	\N
93af43f0-428b-4f26-9993-fdbc394cfc7c	92a4ce58-aad4-4b26-99af-b0b87c0eba6c	B	Ethane	1	\N
98c50a4b-921c-465e-83c7-6a2e3e1df4af	92a4ce58-aad4-4b26-99af-b0b87c0eba6c	C	Ethyne	2	\N
796f21ad-e862-42aa-9414-406f8e7e56b6	92a4ce58-aad4-4b26-99af-b0b87c0eba6c	D	Ethene	3	\N
1797ff21-a3dd-40c1-bfa1-d90710b233bb	ad041f98-b102-428f-af61-3fcb3932ab0c	A	s orbital	0	\N
f9a3b60b-732f-4cdd-8afd-91dbd2eecd43	ad041f98-b102-428f-af61-3fcb3932ab0c	B	p orbital	1	\N
f5e80781-5d75-43f3-a377-341332ac5813	ad041f98-b102-428f-af61-3fcb3932ab0c	C	$dz^2$ orbital	2	\N
414a2830-8d20-466b-a117-72f767aefb64	ad041f98-b102-428f-af61-3fcb3932ab0c	D	$d_{x^2-y^2}$ orbital	3	\N
2e6cbb76-452a-4f20-b932-27af3bea4233	9aaa9699-b55d-4ec4-a388-055c432e742c	A	২-ক্লোরো-৩-ব্রোমো-৫-ইথাইলহেক্সেন	0	\N
7b88cb7e-4df9-4547-ad20-38b480b26724	9aaa9699-b55d-4ec4-a388-055c432e742c	B	২-ক্লোরো-৩-ব্রোমো-৫-মিথাইলহেপটেন	1	\N
36ab46e9-fd71-457d-a623-0600f9aee748	9aaa9699-b55d-4ec4-a388-055c432e742c	C	৩-ব্রোমো-২-ক্লোরো-৫-ইথাইলহেক্সেন	2	\N
4ebef743-1dff-4130-8498-f7b6e459ff69	9aaa9699-b55d-4ec4-a388-055c432e742c	D	৩-ব্রোমো-২-ক্লোরো-৫-মিথাইলহেপটেন	3	\N
d2e14ea8-b835-4f13-9545-4705ff943946	8c3a0a97-ed9f-4c12-acaf-bdcbbad422fa	A	উভয়েই কার্বন মৌল দ্বারা গঠিত।	0	\N
03aab680-aff0-4163-bd8f-ed735ebaf12a	8c3a0a97-ed9f-4c12-acaf-bdcbbad422fa	B	হীরা ও গ্রাফাইটে কার্বন পরমাণুর সংকরায়ন হলো যথাক্রমে $sp^3$ ও $sp^2$।	1	\N
272e3bc3-b701-437d-9dab-7d40ac1ee2c3	8c3a0a97-ed9f-4c12-acaf-bdcbbad422fa	C	উভয়ের বিদ্যুৎ পরিবাহিতা ভিন্ন।	2	\N
55cb782d-c80c-4ebb-b9af-b9b29f305992	8c3a0a97-ed9f-4c12-acaf-bdcbbad422fa	D	উভয়ের দহন তাপ একই।	3	\N
c0edff64-fc0e-48a6-96e0-5e5b5d4ac50c	8217d294-a502-4f6a-b208-c62dcfffe02c	A	Neon	0	\N
0b0d5b9c-0bb6-41e5-8d46-6cc346b749b7	8217d294-a502-4f6a-b208-c62dcfffe02c	B	Oxygen	1	\N
9aa6838f-1131-4d61-a8d4-1e28b8c1a10f	8217d294-a502-4f6a-b208-c62dcfffe02c	C	Hydrogen	2	\N
3cb216fa-0638-44ca-9a7f-8fa9579341f3	8217d294-a502-4f6a-b208-c62dcfffe02c	D	Silicon	3	\N
72ad013b-baa6-41de-a7f2-ba3db4aac494	5b753a9c-bc52-44d3-b843-a3689a895b35	A	19	0	\N
2d41adee-7aa0-446c-90f6-e6bc3d15085d	5b753a9c-bc52-44d3-b843-a3689a895b35	B	31	1	\N
aedd7fb1-df0f-4a15-8eac-fed9c671f595	5b753a9c-bc52-44d3-b843-a3689a895b35	C	23	2	\N
80958298-315f-44d5-8120-1f5c1fbe1d12	5b753a9c-bc52-44d3-b843-a3689a895b35	D	32	3	\N
1960b986-93d0-4cec-b422-1734c0c130b8	ba63839e-0aa0-4751-9038-76320811eb23	A	পিপেট	0	\N
a49fc5b0-8c4d-4f23-801d-4500f234ffb2	ba63839e-0aa0-4751-9038-76320811eb23	B	মাপন সিলিন্ডার	1	\N
80b36c67-a9bf-43cd-b544-149510d5ce67	ba63839e-0aa0-4751-9038-76320811eb23	C	ব্যুরেট	2	\N
b4a7b58d-ad10-4ffe-bbcf-0154419e1d24	ba63839e-0aa0-4751-9038-76320811eb23	D	আয়তনিক ফ্লাক্স	3	\N
38be9f5f-99ab-4632-a657-12703e72ec08	7e2a200d-36b5-406b-bf8d-eb9986458db5	A	$0.1\\,\\text{M}$	0	\N
0ceda326-a16a-4f8e-ac5e-69d39573f22d	7e2a200d-36b5-406b-bf8d-eb9986458db5	B	$0.1\\,\\text{m}$	1	\N
cd825470-d033-4668-a1d3-4f08d9a087ba	7e2a200d-36b5-406b-bf8d-eb9986458db5	C	$0.01\\,\\text{M}$	2	\N
fbeffdfd-11d4-4fe7-a12f-6f7695675fee	7e2a200d-36b5-406b-bf8d-eb9986458db5	D	$0.01\\,\\text{m}$	3	\N
f8035e59-881d-4d90-b446-d1edf7ceadb4	fa2b9b58-980f-49d5-ae3f-e60173b6fb40	A	$+2, +2$	0	\N
277ac257-9152-4fcb-a715-097843d3dd81	fa2b9b58-980f-49d5-ae3f-e60173b6fb40	B	$+5, +2$	1	\N
417fcd49-eec5-46df-8cbb-df28c74304f8	fa2b9b58-980f-49d5-ae3f-e60173b6fb40	C	$+4, +3$	2	\N
ad5a028e-5ab2-4c42-aa34-0a249b52bb1c	fa2b9b58-980f-49d5-ae3f-e60173b6fb40	D	$+5, +3$	3	\N
8dc746ad-2a42-4f58-a689-888e690c6ff7	c6168bd7-37a5-4afc-8d9b-ee157d9eba01	A	$\\ce{Na2O}$	0	\N
3b7154ae-a7f0-4e23-b018-328bb4c900d1	c6168bd7-37a5-4afc-8d9b-ee157d9eba01	B	$\\ce{ZnO}$	1	\N
6a921440-c682-48dc-9233-62752316f577	c6168bd7-37a5-4afc-8d9b-ee157d9eba01	C	$\\ce{Al2O3}$	2	\N
b577f36d-279f-4ec8-8b7c-64589f6c263a	c6168bd7-37a5-4afc-8d9b-ee157d9eba01	D	$\\ce{CO2}$	3	\N
1268d41f-3cf3-44e4-9bd0-42169c9fda43	98cea303-757a-4474-8e7e-0b8afa2b0288	A	সার্বজনীন নির্দেশক দিয়ে পরীক্ষা	0	\N
c0cb6358-6c9a-4702-a1bc-486a0394281f	98cea303-757a-4474-8e7e-0b8afa2b0288	B	সোডিয়াম কার্বনেট গুঁড়া যোগে	1	\N
902e5c9a-b9e7-4dd8-987e-08adb883ab55	98cea303-757a-4474-8e7e-0b8afa2b0288	C	ম্যাগনেশিয়াম ফিতা যোগে	2	\N
94caef44-ff51-4d1d-9282-43cd841f9ad8	98cea303-757a-4474-8e7e-0b8afa2b0288	D	বেরিয়াম নাইট্রেট দ্রবণ যোগে	3	\N
9d4c8c84-d99c-426b-b22f-0874e99cebce	80c5c9d7-d501-420c-a2a1-c1922ab19807	A	$\\frac{1}{4}$	0	\N
064aca3c-ef6e-4659-a2f7-f18dd4fca64c	80c5c9d7-d501-420c-a2a1-c1922ab19807	B	$-4$	1	\N
a9f4bd05-0d32-4f4b-baa6-a87b37cb05a4	80c5c9d7-d501-420c-a2a1-c1922ab19807	C	$4$	2	\N
eef8eb83-fb7a-4664-ac51-0f9fb86a0098	80c5c9d7-d501-420c-a2a1-c1922ab19807	D	$-\\frac{1}{4}$	3	\N
7b99f8f2-c4c1-4a1f-8854-098ff73dbe1f	23ba8888-8e6d-4dd8-8c37-f448819ee2ca	A	$1$	0	\N
9b63b89e-2f5e-45fe-8812-046352beedad	23ba8888-8e6d-4dd8-8c37-f448819ee2ca	B	$\\infty$	1	\N
6f6e6d64-206f-4dfd-9f14-570a0c6b2035	23ba8888-8e6d-4dd8-8c37-f448819ee2ca	C	$-\\infty$	2	\N
d0c9b6bd-452f-4fa4-afee-0898dbca84cb	23ba8888-8e6d-4dd8-8c37-f448819ee2ca	D	$-1$	3	\N
cc0a6fbc-1625-419c-b536-e957c2e64082	da1e1550-a9a6-43e8-94e1-8581937d1d94	A	$\\frac{2}{3}$	0	\N
c49143bd-e41b-4ba3-a33c-755cef86d494	da1e1550-a9a6-43e8-94e1-8581937d1d94	B	$\\frac{4}{5}$	1	\N
1ac2736b-be79-4e07-82a5-7b5326e36fc8	da1e1550-a9a6-43e8-94e1-8581937d1d94	C	$\\frac{3}{4}$	2	\N
ec474a61-8c8d-416f-888f-88d451fa5717	da1e1550-a9a6-43e8-94e1-8581937d1d94	D	$\\frac{3}{5}$	3	\N
2b3a6bbf-5969-4566-9f01-417d3009c339	6a27ed3e-e0af-40ab-b3d8-a064753c7ebe	A	$\\frac{1}{2(e^{2x} + 1)} + c$	0	\N
1a5f9e12-2af5-4982-a0ae-2e8b4b9df524	6a27ed3e-e0af-40ab-b3d8-a064753c7ebe	B	$\\frac{-1}{2(e^{2x} + 1)} + c$	1	\N
5cef102f-644c-4b16-ac79-a7d8f2bf5560	6a27ed3e-e0af-40ab-b3d8-a064753c7ebe	C	$\\frac{1}{2e^{2x}} + c$	2	\N
93eaa843-4d79-4eb9-9184-889a58c51be9	6a27ed3e-e0af-40ab-b3d8-a064753c7ebe	D	$\\frac{-1}{2e^{2x}} + c$	3	\N
a216efc0-0cd0-4b02-8015-810500f20c05	41cd39b1-ca7d-4575-b95c-fc839dc20cdf	A	$\\frac{1}{\\sqrt{3}}$	0	\N
81ecedb4-f21d-4d69-8d1b-96aac9e9a163	41cd39b1-ca7d-4575-b95c-fc839dc20cdf	B	$\\frac{\\sqrt{3}}{2}$	1	\N
d34df7dd-5a0c-4138-a3fd-95852d9097dc	41cd39b1-ca7d-4575-b95c-fc839dc20cdf	C	$\\sqrt{3}$	2	\N
80de134d-f593-48de-ab78-7ecfa6a1301a	41cd39b1-ca7d-4575-b95c-fc839dc20cdf	D	$\\frac{2}{\\sqrt{3}}$	3	\N
c7649d55-cf82-4d72-a6fc-c1ea8574c3a1	ecde36b4-4d95-4b69-b86b-952c1723f834	A	$\\int_0^2 (x - 1) dx$	0	\N
8589df91-5063-4d50-bce4-440d09b4e32c	ecde36b4-4d95-4b69-b86b-952c1723f834	B	$\\int_0^2 |x - 1| dx$	1	\N
07ff77b0-9073-4435-a5f8-694fc1f01d55	ecde36b4-4d95-4b69-b86b-952c1723f834	C	$2 \\int_0^2 (1 - x) dx$	2	\N
a50ec9d3-0735-4362-86e8-44b3d0a7393e	ecde36b4-4d95-4b69-b86b-952c1723f834	D	$2 \\int_0^1 (x - 1) dx$	3	\N
318262f8-32b9-4335-8b07-73f07f72a0cd	62b45fa3-5a84-4c32-84a5-c2bd8fbf7309	A	$30^\\circ$	0	\N
c96f95ac-900f-4771-b6bf-228f25869d2e	62b45fa3-5a84-4c32-84a5-c2bd8fbf7309	B	$90^\\circ$	1	\N
f0b9d1ad-7c3b-472f-947b-0ed6a1c077e6	62b45fa3-5a84-4c32-84a5-c2bd8fbf7309	C	$60^\\circ$	2	\N
e8cf7546-222f-4eb0-a2d2-1b0267bc0cbc	62b45fa3-5a84-4c32-84a5-c2bd8fbf7309	D	$180^\\circ$	3	\N
d502f32d-966f-43e4-9cc9-29435b1513ac	bc22adfe-a7ce-4ce7-b7b1-4b77be764eda	A	0	0	\N
6f714142-bcb0-49fa-9868-c659b7d0c43c	bc22adfe-a7ce-4ce7-b7b1-4b77be764eda	B	1	1	\N
0da9ae93-a2d1-4c6e-ac02-216d0db7ed11	bc22adfe-a7ce-4ce7-b7b1-4b77be764eda	C	-1	2	\N
c8c7512e-cf1f-4ac7-a99d-ad5c25ca21d2	bc22adfe-a7ce-4ce7-b7b1-4b77be764eda	D	5	3	\N
90456058-549d-4892-8a9e-630396fcfaae	e089d5d2-bb03-4471-86c2-2c3407530f61	A	0	0	\N
14934689-3774-49ff-90b7-55b471700c5c	e089d5d2-bb03-4471-86c2-2c3407530f61	B	1	1	\N
ff188575-bc0d-4f96-a47f-93a924160893	e089d5d2-bb03-4471-86c2-2c3407530f61	C	\\sqrt{2}	2	\N
3b271695-1d07-4268-8d68-447c095059a3	e089d5d2-bb03-4471-86c2-2c3407530f61	D	i	3	\N
8561e974-51c5-441d-af54-c13913cba08d	6ca4ca64-aa11-49a8-b740-f4aa541d150e	A	$x^2 + y^2 + 8x - 6y + 24 = 0$	0	\N
3d54b4ff-fd33-4538-8d16-a49be49840a5	6ca4ca64-aa11-49a8-b740-f4aa541d150e	B	$x^2 + y^2 - 8x - 6y + 24 = 0$	1	\N
3b93cf8a-1e88-4dcd-a9e3-95cfe4a1c855	6ca4ca64-aa11-49a8-b740-f4aa541d150e	C	$x^2 + y^2 + 8x + 6y + 24 = 0$	2	\N
5019c1a6-d829-474a-b687-865829ff4338	6ca4ca64-aa11-49a8-b740-f4aa541d150e	D	$x^2 + y^2 - 8x - 6y - 24 = 0$	3	\N
698ac02c-05e2-44db-acd4-3be910eda405	91207fa5-34c4-4ff7-b892-2b63c864520d	A	$\\frac{8}{121}\\vec{b}$	0	\N
21841387-1b0d-4fe6-a7bc-00761cc8fbcd	91207fa5-34c4-4ff7-b892-2b63c864520d	B	$\\frac{-8}{121}\\vec{b}$	1	\N
d2a6462d-f044-400b-b2a6-100c12646a2a	91207fa5-34c4-4ff7-b892-2b63c864520d	C	$\\frac{8}{121}\\vec{a}$	2	\N
c873a9a3-9e18-423e-9ac7-38f1e28fc750	91207fa5-34c4-4ff7-b892-2b63c864520d	D	$\\frac{-8}{121}\\vec{a}$	3	\N
a944f754-b007-44c6-a1aa-80cd4bc08117	da7a4805-ff0e-4d85-8208-2a919d682dc1	A	$\\frac{70}{81}$	0	\N
81f2b70d-f6c5-49ca-923c-c825c5ea39fa	da7a4805-ff0e-4d85-8208-2a919d682dc1	B	520	1	\N
a7602cf3-7ad4-49c4-aae0-c97ad3c72caf	da7a4805-ff0e-4d85-8208-2a919d682dc1	C	$\\frac{35}{128}$	2	\N
066bc001-44f5-4a17-af6f-c2156851bc53	da7a4805-ff0e-4d85-8208-2a919d682dc1	D	$\\frac{7}{512}$	3	\N
c08bf48f-0fd7-4e76-9ed3-2dc4cfcda486	e4a4312d-9b7e-4862-a29f-2de94713cc60	A	360	0	\N
b7fa8e02-41be-4ed2-a1b6-1929c131f7b4	e4a4312d-9b7e-4862-a29f-2de94713cc60	B	20160	1	\N
c2011aaa-cb92-4f2c-a829-57f8360df427	e4a4312d-9b7e-4862-a29f-2de94713cc60	C	720	2	\N
6ab1c9b1-8510-46cd-880b-03b5beeed1d3	e4a4312d-9b7e-4862-a29f-2de94713cc60	D	30	3	\N
1d970880-1aa3-4e47-b335-99dd5f7ea402	085a79c7-14c3-4218-962f-e64b04e1c576	A	$(-\\infty, \\frac{1}{3}) \\cup (1, \\infty)$	0	\N
835abcd5-b137-44e8-94e2-8c7c6d1b5ed8	085a79c7-14c3-4218-962f-e64b04e1c576	B	$x > \\frac{1}{3}$	1	\N
a37dff71-a91c-4971-b27b-a03fe7b92e6e	085a79c7-14c3-4218-962f-e64b04e1c576	C	$0 < x < \\frac{2}{3}$	2	\N
b0c0bae2-0c4e-4472-b6ef-4a455e2c7f1f	085a79c7-14c3-4218-962f-e64b04e1c576	D	$(0, \\frac{1}{3}) \\cup (\\frac{1}{3}, \\frac{2}{3})$	3	\N
ddcb10c7-6736-44d3-8e82-77abc20390aa	5ffa9e49-ab9b-4f56-8ae1-82f03898b371	A	$(-\\infty, 2)$	0	\N
205035d9-da22-4e2f-8ae5-cf78c1f148b6	5ffa9e49-ab9b-4f56-8ae1-82f03898b371	B	$(-\\infty, \\infty)$	1	\N
5bd271b9-d5f6-46e5-b560-8df3ec37e9d9	5ffa9e49-ab9b-4f56-8ae1-82f03898b371	C	$(-2, \\infty)$	2	\N
b55b21bc-15d8-484a-b0ea-1a09872796c7	5ffa9e49-ab9b-4f56-8ae1-82f03898b371	D	$[-2, 2]$	3	\N
9954c80a-3142-4233-af10-11ab10f6df1b	2008a1b5-2c4c-4190-aa4e-f4c56f50c794	A	আর্থ্রোপোডা	0	\N
ab83ab23-d4c0-4f23-b637-8163d44d979c	2008a1b5-2c4c-4190-aa4e-f4c56f50c794	B	অ্যানিলিডা	1	\N
d7fd3f6e-a94e-472c-8b0a-f20ba21397af	2008a1b5-2c4c-4190-aa4e-f4c56f50c794	C	মলাস্কা	2	\N
21c5df32-c3c8-4ad0-ad6b-06ebe20806d0	2008a1b5-2c4c-4190-aa4e-f4c56f50c794	D	প্লাটিহেলমিনথিস	3	\N
03a38208-45d6-481a-a7b3-27c3d69a8c68	e4c4feed-a17c-498d-9247-c5a43ea89ad9	A	বেরি	0	\N
0b8aaab2-e7e4-470f-9a99-c6570e836ccc	e4c4feed-a17c-498d-9247-c5a43ea89ad9	B	ক্যারিওপসিস	1	\N
71f4a78d-ccd5-4c2d-a429-252b27f79c8b	e4c4feed-a17c-498d-9247-c5a43ea89ad9	C	পড	2	\N
76244ab3-c961-4619-917f-4ce2454e1807	e4c4feed-a17c-498d-9247-c5a43ea89ad9	D	ক্যাপসুল	3	\N
7fe214d3-cff5-4a24-9722-1984f0aa1961	aa8691c4-4ca8-4d64-be2c-fc2b10494982	A	হাঙর	0	\N
05399bad-bb4b-4dba-b530-97b31c2746b1	aa8691c4-4ca8-4d64-be2c-fc2b10494982	B	তারামাছ	1	\N
6da60401-ab30-4762-8574-897d4c2772c8	aa8691c4-4ca8-4d64-be2c-fc2b10494982	C	কইমাছ	2	\N
1ce05f51-689e-4abf-bdd5-ee81d0faba15	aa8691c4-4ca8-4d64-be2c-fc2b10494982	D	কাতল মাছ	3	\N
d6ea3075-3fcc-4b43-b2e2-7e0cbd8feb6c	860d75a9-b6b6-4674-95d6-85d0f8ba8233	A	সমন্বয়ক	0	\N
a9ba73b4-7dc7-4781-beac-ebc41f35f5e0	860d75a9-b6b6-4674-95d6-85d0f8ba8233	B	প্রকট	1	\N
9b3522e9-c84f-4d3c-b6d6-650697d7d655	860d75a9-b6b6-4674-95d6-85d0f8ba8233	C	প্রচ্ছন্ন	2	\N
45cba9e0-0dd7-46b4-af4b-13c0140f31b9	860d75a9-b6b6-4674-95d6-85d0f8ba8233	D	পুঞ্জীভূত	3	\N
51bbf3d3-f02d-4cbb-9270-0d81f580c675	d41b3a01-c52b-4729-955d-8848a8d533e9	A	পেপেইন	0	\N
b4c26353-f898-4a99-9bb0-0c638fa4bcf7	d41b3a01-c52b-4729-955d-8848a8d533e9	B	রেনিন	1	\N
1e17e411-030d-48ec-8f0c-3a26030338ff	d41b3a01-c52b-4729-955d-8848a8d533e9	C	ক্যাটালেজ	2	\N
97ee0d5f-8ec6-4162-834a-ee84a27e2940	d41b3a01-c52b-4729-955d-8848a8d533e9	D	পেকটিন	3	\N
b016b7fb-a818-42eb-bd04-f9c30057ce4c	f497e262-dfbe-44d7-9638-0c14d9b4a43e	A	75%	0	\N
28d21c4a-2fa2-4bd0-9a99-4edbb7d3aab7	f497e262-dfbe-44d7-9638-0c14d9b4a43e	B	15%	1	\N
e9308da7-64c4-4998-96e5-8f81c0a3fc32	f497e262-dfbe-44d7-9638-0c14d9b4a43e	C	10%	2	\N
fda55226-7a25-494b-94d0-bfbc47f5f44d	f497e262-dfbe-44d7-9638-0c14d9b4a43e	D	5%	3	\N
68790902-30ca-4a2d-a736-bd40e31042fb	6da1c88a-d204-4ade-97f4-9cae350814a5	A	Pongamia pinnata	0	\N
04cd5c33-d8db-4977-bb24-c0b2649084a9	6da1c88a-d204-4ade-97f4-9cae350814a5	B	Heritiera fomes	1	\N
e8f6dcf0-66ca-4085-859a-17bff5fc6283	6da1c88a-d204-4ade-97f4-9cae350814a5	C	Shorea robusta	2	\N
e7c292ac-b0ad-4bf5-b40b-952ea0ce25f4	6da1c88a-d204-4ade-97f4-9cae350814a5	D	Ceriops decandra	3	\N
2cd99b88-6937-4906-ab67-e802451fb896	92929cc0-1722-42b5-b8c5-b1277a6f82b6	A	ভ্যাসোপ্রেসিন	0	\N
fb3fa66f-87ec-48f6-b05a-12b4b97e1eb8	92929cc0-1722-42b5-b8c5-b1277a6f82b6	B	প্রোজেস্টেরন	1	\N
dd08d351-5bc2-4ff8-bd23-661cf7d23028	92929cc0-1722-42b5-b8c5-b1277a6f82b6	C	ল্যাকটিন	2	\N
cc8cad42-56f9-40fe-9c1e-001b1dacf7f3	92929cc0-1722-42b5-b8c5-b1277a6f82b6	D	অক্সিটাসিন	3	\N
037ae01a-42ef-40ca-a9c3-019efc12fcee	9785367b-9c02-4c3a-abc8-67f09aa409c7	A	লিউসিন	0	\N
2527760f-9195-460b-a1b4-4f4c6b69f356	9785367b-9c02-4c3a-abc8-67f09aa409c7	B	আরজিনিন	1	\N
02706c93-4088-43f1-9cc3-ed6e5d5ae451	9785367b-9c02-4c3a-abc8-67f09aa409c7	C	ভ্যালিন	2	\N
d53b45ed-d938-478c-9436-67b483674d96	9785367b-9c02-4c3a-abc8-67f09aa409c7	D	ট্রিপটোফ্যান	3	\N
2b47a11f-9157-4e3c-970f-e990576118d7	e13dfe24-27fd-489f-8b0a-06fbf736f560	A	৩ মিলিয়ন	0	\N
4071ec06-3727-4b9e-977c-721ab57c6d95	e13dfe24-27fd-489f-8b0a-06fbf736f560	B	৩০ মিলিয়ন	1	\N
984b02e9-695f-4223-a43c-36fd1992d4cf	e13dfe24-27fd-489f-8b0a-06fbf736f560	C	৩০০ মিলিয়ন	2	\N
9b3c580e-b11d-4d2b-940d-2d0b54e321c4	e13dfe24-27fd-489f-8b0a-06fbf736f560	D	৩০০০ মিলিয়ন	3	\N
0f677104-9c61-477b-9739-0a5aa70a3069	765add34-d5b1-4807-886c-3f7fed343151	A	মাইটোকন্ড্রিয়া	0	\N
2c2b4144-7652-444f-85b1-5656a899824a	765add34-d5b1-4807-886c-3f7fed343151	B	নিউক্লিয়াস	1	\N
bd3c647e-d567-41a6-9376-6ed9c0c3a05b	765add34-d5b1-4807-886c-3f7fed343151	C	রাইবোসোম	2	\N
3dd2f9de-e24b-4f39-9b2b-3d316f7c668c	765add34-d5b1-4807-886c-3f7fed343151	D	লাইসোসোম	3	\N
cba56f3b-a58e-4080-bbe2-6899bf779680	4e63f36b-a4da-45a9-8d7f-4b5759d54f7d	A	মেনিনজেস	0	\N
f2269a03-4f1a-4378-9829-099e7d42c0eb	4e63f36b-a4da-45a9-8d7f-4b5759d54f7d	B	পেরিটোনিয়াম	1	\N
19818a4c-ca38-4bd2-95dc-211e0bdfb711	4e63f36b-a4da-45a9-8d7f-4b5759d54f7d	C	পেরিকার্ডিয়াম	2	\N
44fac6cf-6f86-435b-b8a1-f24795c6eecc	4e63f36b-a4da-45a9-8d7f-4b5759d54f7d	D	নিউরোকার্ডিয়াম	3	\N
a113eb3f-3e94-431e-93be-c3e46ebfd6e4	f1f2e16b-2474-4dd0-835b-43f3e3bf8c26	A	গ্লুকোকর্টিকয়েড	0	\N
34c864a6-4cb9-447c-8efb-56a09780e7c6	f1f2e16b-2474-4dd0-835b-43f3e3bf8c26	B	গোনাডোট্রপিন	1	\N
9ae1e100-2b34-414b-ab66-5f89de1e7388	f1f2e16b-2474-4dd0-835b-43f3e3bf8c26	C	প্যারাথরমোন	2	\N
7113b171-8291-4df5-8da9-7b513c305c49	f1f2e16b-2474-4dd0-835b-43f3e3bf8c26	D	ক্যালসিটোনিন	3	\N
8befb67d-3ee4-467f-923d-d1986a3d9bda	6f88beac-bf8d-4706-b7a0-84a680424689	A	Pteris vittata	0	\N
0b51248f-826d-4542-a53f-c85612c1d0b3	6f88beac-bf8d-4706-b7a0-84a680424689	B	Podocarpus neriifolius	1	\N
84dfaf8a-7c5f-4089-844c-e15d48c22cb8	6f88beac-bf8d-4706-b7a0-84a680424689	C	Cycas revoluta	2	\N
e8770f66-30e9-46f1-855c-67c075bef88c	6f88beac-bf8d-4706-b7a0-84a680424689	D	Nerium indicum	3	\N
60c5ecd9-8e6a-4cdd-bb65-223e3f4510cd	9c0f0b25-fcc0-49df-a3ef-6df03929744a	A	থ্যালাফাইটা	0	\N
9e8edc42-357b-40b1-ad1b-f1b3016f8cd8	9c0f0b25-fcc0-49df-a3ef-6df03929744a	B	ব্রায়োফাইটা	1	\N
d01ec2ce-4716-498e-9072-8166d56bf251	9c0f0b25-fcc0-49df-a3ef-6df03929744a	C	টেরিডোফাইটা	2	\N
cf7a4742-508e-4869-8a85-4346f62d33ae	9c0f0b25-fcc0-49df-a3ef-6df03929744a	D	স্পার্মাটোফাইটা	3	\N
54dcdcd8-7f59-4eff-900d-fc1168d15313	134c31cf-066e-4317-af88-173a7711068d	A	$25\\%$	0	\N
199468a3-f4dd-452c-8296-c606f48443fd	134c31cf-066e-4317-af88-173a7711068d	B	$100\\%$	1	\N
7e7b3559-bbad-49ad-9052-f82068e98cec	134c31cf-066e-4317-af88-173a7711068d	C	$125\\%$	2	\N
b5b0d20f-d791-4fda-800e-e7fce706b1b2	134c31cf-066e-4317-af88-173a7711068d	D	$67\\%$	3	\N
4e671ebb-1ffc-4caa-9057-3a2094dd9a6f	4706a514-8c18-4c10-911a-ca041142edc2	A	$4$	0	\N
5e2696b5-5bac-4d8f-8ac5-9fde6c1a7eeb	4706a514-8c18-4c10-911a-ca041142edc2	B	$\\frac{1}{2}$	1	\N
c4e9e844-3be0-4747-b87e-8b3f31c79372	4706a514-8c18-4c10-911a-ca041142edc2	C	$2$	2	\N
3c07f092-50ca-4aa6-ae22-1c73a7574777	4706a514-8c18-4c10-911a-ca041142edc2	D	$1$	3	\N
0ca9f695-648b-44d7-addf-e25eae0080ae	982593d5-f7ce-4d9e-813b-41e6df2b0bef	A	$\\omega q$	0	\N
30ea751e-b260-4263-8b35-0e6918216630	982593d5-f7ce-4d9e-813b-41e6df2b0bef	B	$2\\pi\\omega q$	1	\N
411abddd-fb5f-4e7a-a962-67bb9925ec2f	982593d5-f7ce-4d9e-813b-41e6df2b0bef	C	$\\frac{q}{\\omega}$	2	\N
ff0d42cb-67cc-4bb1-9171-fb05bebc3b5d	982593d5-f7ce-4d9e-813b-41e6df2b0bef	D	$\\frac{q\\omega}{2\\pi}$	3	\N
979eb4d9-00a6-46a6-99ec-a602a3e3f67a	314c5e8f-d335-43b8-9d15-98ddd83054ac	A	$\\frac{1}{2}c$	0	\N
8d6067ab-3a9e-43d0-a351-5e39f8be478a	314c5e8f-d335-43b8-9d15-98ddd83054ac	B	$\\frac{\\sqrt{3}}{2}c$	1	\N
89201ccd-4e9d-48fb-9538-32062acec03a	314c5e8f-d335-43b8-9d15-98ddd83054ac	C	$\\frac{3}{\\sqrt{2}}c$	2	\N
e1ff05b4-6be8-489b-b411-4cc53078de22	314c5e8f-d335-43b8-9d15-98ddd83054ac	D	$\\frac{3}{4}c$	3	\N
513cc3b1-4b49-4eb2-b739-ab8142d30ef9	61ea3a53-6193-49d9-a68a-80213ce57a55	A	$\\sqrt{\\frac{m}{k}}v$	0	\N
fbb206bd-1961-4256-b8a1-91d76bc6d208	61ea3a53-6193-49d9-a68a-80213ce57a55	B	$\\sqrt{\\frac{k}{m}}v$	1	\N
b9085277-8057-41d3-9d46-96e8f6cc116b	61ea3a53-6193-49d9-a68a-80213ce57a55	C	$\\sqrt{kv}$	2	\N
9bab4e24-6068-4218-93d8-da029fa4c139	61ea3a53-6193-49d9-a68a-80213ce57a55	D	$\\sqrt{mv}$	3	\N
6f48a9bb-d953-4aac-80b1-b014826ad08b	461daa81-404c-4000-b336-e406acefa007	A	$\\frac{D}{d\\lambda}$	0	\N
bc034d84-6de2-4ae7-a7d4-6f9564c1583c	461daa81-404c-4000-b336-e406acefa007	B	$\\frac{d}{D\\lambda}$	1	\N
ddcb1d2e-aee8-49c7-adc9-f3ef6316152e	461daa81-404c-4000-b336-e406acefa007	C	$\\frac{\\lambda}{Dd}$	2	\N
efca475b-af6c-4da2-a739-ec976c9d07cd	461daa81-404c-4000-b336-e406acefa007	D	$\\frac{d^2}{\\lambda D^3}$	3	\N
c2da9fde-ea64-4f1e-b111-8b3f1059f335	d0ff282d-2b31-4f6d-a72b-f0e522b93a60	A	$-1$	0	\N
b6e09a53-bf12-4340-979a-73b36fc82e44	d0ff282d-2b31-4f6d-a72b-f0e522b93a60	B	$\\frac{7}{4}$	1	\N
d1599167-ff82-4944-9d7a-feef73424ca0	d0ff282d-2b31-4f6d-a72b-f0e522b93a60	C	$0$	2	\N
75f6d505-d1f9-4e41-a397-a6c7b3ad4fc9	d0ff282d-2b31-4f6d-a72b-f0e522b93a60	D	$2$	3	\N
14a762ef-5c02-4c18-8629-fc47bc1ab1bd	e7f5bd3b-c6c0-40f2-8303-1977170cdd93	A	$\\frac{U_0}{2}$	0	\N
0bad23ed-644f-4aee-931d-25cabc486134	e7f5bd3b-c6c0-40f2-8303-1977170cdd93	B	$\\frac{U_0}{4}$	1	\N
28a0220c-a908-46fe-8317-6e53092e7e32	e7f5bd3b-c6c0-40f2-8303-1977170cdd93	C	$2U_0$	2	\N
af81c526-777b-4e2d-b112-857309bd0bca	e7f5bd3b-c6c0-40f2-8303-1977170cdd93	D	$4U_0$	3	\N
63a269d8-6bca-4d11-a85b-6d847dc358ec	91b366bd-9fda-470d-99fa-9daae2309649	A	$[MLT^{-1}]$	0	\N
9697f2bd-87ef-4acb-a27d-224a336dc74d	91b366bd-9fda-470d-99fa-9daae2309649	B	$[ML^{-1}T^{-2}]$	1	\N
65b520ef-9ab7-4396-91c2-65ea11c43ac8	91b366bd-9fda-470d-99fa-9daae2309649	C	$[MLT^{-2}]$	2	\N
6ab36eb9-ca40-480b-b5fe-c88c89a15737	91b366bd-9fda-470d-99fa-9daae2309649	D	$[ML^2T^{-2}]$	3	\N
90480f88-b63c-480b-8c67-93068a49addc	a1ae8350-1cd7-42bd-8999-4a5c1a275990	A	ক্ষীণ দৃষ্টি	0	\N
868efd67-23fb-4c4b-9772-f72a675656a3	a1ae8350-1cd7-42bd-8999-4a5c1a275990	B	দূর দৃষ্টি	1	\N
4e9b0d6e-3539-4eff-944c-035ea3b65faa	a1ae8350-1cd7-42bd-8999-4a5c1a275990	C	চালশে	2	\N
4f2c8e0c-29ea-4f4b-b29e-758e13362233	a1ae8350-1cd7-42bd-8999-4a5c1a275990	D	বিষম দৃষ্টি	3	\N
f593227f-c22c-42bc-b695-fa382fb44141	cdfddac8-993b-4063-a369-7e44a7d24b69	A	আলফা কণা	0	\N
30994d8f-8c15-4915-b53d-c5c72b37cfaa	cdfddac8-993b-4063-a369-7e44a7d24b69	B	ইলেকট্রন	1	\N
3a8080a9-3684-4c92-9a70-665ea0297dd5	cdfddac8-993b-4063-a369-7e44a7d24b69	C	প্রোটন	2	\N
4b9f6bc9-08f8-4d72-aef3-5bbaaf3ebbd6	cdfddac8-993b-4063-a369-7e44a7d24b69	D	নিউট্রন	3	\N
76fc6b53-34d7-4793-ab49-9f39a4e8c32b	27cfb107-5cd9-4f06-9464-e31b0758e1a3	A	$\\frac{7}{8}$ min	0	\N
50ddf7bb-d8c6-43c0-a3a5-4197560077d3	27cfb107-5cd9-4f06-9464-e31b0758e1a3	B	$\\frac{7}{4}$ min	1	\N
6a091c8e-5d31-472c-9914-eed650030819	27cfb107-5cd9-4f06-9464-e31b0758e1a3	C	$\\frac{7}{2}$ min	2	\N
cfd3aac1-c11e-4a7c-b7bb-cb92979def06	27cfb107-5cd9-4f06-9464-e31b0758e1a3	D	$\\frac{14}{3}$ min	3	\N
25ddd502-448d-47cf-8e72-5300d40fbd5a	c740ba7e-7386-4f2f-a462-c1d4778554e9	A	$10.00$ volt	0	\N
0ad0980e-e2ba-4c16-964b-b77d354dec3e	c740ba7e-7386-4f2f-a462-c1d4778554e9	B	$14.14$ volt	1	\N
2a138ffc-080f-47d2-a4a6-6ad72a5aff2b	c740ba7e-7386-4f2f-a462-c1d4778554e9	C	$5.00$ volt	2	\N
f5909c04-01dd-4b3a-be9f-6e3d8c43dec5	c740ba7e-7386-4f2f-a462-c1d4778554e9	D	$1.41$ volt	3	\N
04545dc9-8ebf-41cf-840b-fb6147843ffb	4599acb3-9d78-4bf9-8c9b-47bc3b7756d6	A	$2\\,\\text{m/s}^2$	0	\N
7779a3df-ce59-484a-907d-a51bf42423cf	4599acb3-9d78-4bf9-8c9b-47bc3b7756d6	B	$3\\,\\text{m/s}^2$	1	\N
52c5ef10-b99a-43bd-874c-916b987f2fe9	4599acb3-9d78-4bf9-8c9b-47bc3b7756d6	C	$4\\,\\text{m/s}^2$	2	\N
35a83daa-ed74-42b1-be7f-d7d1c1390cf8	4599acb3-9d78-4bf9-8c9b-47bc3b7756d6	D	$5\\,\\text{m/s}^2$	3	\N
71de0302-5754-4f5a-9be1-eb382bba3750	f1859d7a-e0a7-4fd0-b9c8-a04f01ee9d2a	A	[IMAGE_1]	0	p02_q15_01.png
06780f6b-b08c-4263-8337-1dccb2c0705a	f1859d7a-e0a7-4fd0-b9c8-a04f01ee9d2a	B	[IMAGE_2]	1	p02_q15_02.png
8cb4bbee-bcc3-4460-a20a-b55ffa59b694	f1859d7a-e0a7-4fd0-b9c8-a04f01ee9d2a	C	[IMAGE_3]	2	p02_q15_03.png
7539fb73-10b6-4c60-8b7f-bedb1469de37	f1859d7a-e0a7-4fd0-b9c8-a04f01ee9d2a	D	[IMAGE_4]	3	p02_q15_04.png
da197aab-63f2-41c3-b95e-7b7596a00df4	8fd95e13-4647-45f0-9000-6db05b6026e8	A	আয়নিক ও সমযোজী বন্ধন	0	\N
8c03f8be-6ef0-4bb1-ad67-c96829116d67	8fd95e13-4647-45f0-9000-6db05b6026e8	B	আয়নিক ও সন্নিবেশ বন্ধন	1	\N
3b6c5fa5-7e08-4bdc-86d0-caee7c64c157	8fd95e13-4647-45f0-9000-6db05b6026e8	C	সমযোজী ও সন্নিবেশ বন্ধন	2	\N
c60de6f2-1440-4a5a-b4bc-f96b5778ae4a	8fd95e13-4647-45f0-9000-6db05b6026e8	D	আয়নিক ও হাইড্রোজেন বন্ধন	3	\N
e5930c23-eb18-4c16-a28f-432ca64ed840	21061bb7-2fad-4900-a39c-a8b7c7d4de4d	A	বিজারণ	0	\N
86de56da-abfb-4ad3-a204-34a4f3de9d45	21061bb7-2fad-4900-a39c-a8b7c7d4de4d	B	প্রতিস্থাপন	1	\N
133dfb05-f33e-403f-9b58-e13181c511b6	21061bb7-2fad-4900-a39c-a8b7c7d4de4d	C	প্রশমন	2	\N
7155cb5b-8da8-4351-934a-71fc14aebb40	21061bb7-2fad-4900-a39c-a8b7c7d4de4d	D	জারণ	3	\N
b806a65d-b6e4-482b-8cac-b4ea17e75bb1	7d461d8e-72d3-43c3-b1d0-12d0b4e3d772	A	7	0	\N
0a6795d8-6750-4694-a661-a2891c5223a9	7d461d8e-72d3-43c3-b1d0-12d0b4e3d772	B	$10^{-7}$	1	\N
0953dc08-ef81-44d9-a16f-8ecf66adab2c	7d461d8e-72d3-43c3-b1d0-12d0b4e3d772	C	0	2	\N
c578f4d4-1df8-464e-9c27-9e04cda79a28	7d461d8e-72d3-43c3-b1d0-12d0b4e3d772	D	1	3	\N
f97ed5cd-cb8f-402c-96ec-c82f50a1f876	4231fa1b-a194-4a21-9db1-38f8030b9a6e	A	$\\ce{BeCl2}$	0	\N
106da2af-359c-41e7-8541-cfb0b1c7a56a	4231fa1b-a194-4a21-9db1-38f8030b9a6e	B	$\\ce{PCl5}$	1	\N
12a33645-71ef-4b0c-8ce7-b43c491f21ff	4231fa1b-a194-4a21-9db1-38f8030b9a6e	C	$\\ce{BCl3}$	2	\N
79b24350-4314-4758-aeac-2ed75a7509e5	4231fa1b-a194-4a21-9db1-38f8030b9a6e	D	$\\ce{Cl2}$	3	\N
a9934002-1d12-4c6e-9eaa-d2fa173d97f0	163a9454-4b90-4405-af92-d6bfd760718a	A	$\\ce{H+(aq)/H2(g), Pt}$	0	\N
51dfcd4a-8b61-429f-adf3-81435c6f969f	163a9454-4b90-4405-af92-d6bfd760718a	B	$\\ce{Cu^{2+}(aq)/Cu(s)}$	1	\N
1dd25425-ac40-4ff3-a6ad-54f7a9fc5eae	163a9454-4b90-4405-af92-d6bfd760718a	C	$\\ce{Na+(aq)/Na(s)}$	2	\N
a7e8d4ae-05b4-409c-baf5-e9e25395c7f6	163a9454-4b90-4405-af92-d6bfd760718a	D	$\\ce{Pt(s)/F(g)/F^{-}(aq)}$	3	\N
7056aa91-f3a2-499b-a2a8-b76333b914e6	fd7ced10-1180-4fde-90ed-9381a96b789e	A	$\\frac{d[A]}{dt}$	0	\N
187c14a6-926b-4e08-9613-ac84c3f2fca9	fd7ced10-1180-4fde-90ed-9381a96b789e	B	$-\\frac{1}{a} \\frac{d[A]}{dt}$	1	\N
2e09c39a-3220-49eb-98d2-a63831ff2758	fd7ced10-1180-4fde-90ed-9381a96b789e	C	$-\\frac{d[B]}{dt}$	2	\N
856d76b0-8c24-4d96-93f3-2417baf2494a	fd7ced10-1180-4fde-90ed-9381a96b789e	D	$\\frac{1}{b} \\frac{d[A]}{dt}$	3	\N
9fabc6f3-f815-4a24-bb98-bc50cc7d2def	a7d85557-9917-4bab-af32-d9673fe57186	A	ক্যারোটিন	0	\N
d6455e6f-89bd-4468-9165-357e254b3426	a7d85557-9917-4bab-af32-d9673fe57186	B	লিপিড	1	\N
db7a4e2d-7b97-4721-8443-f2d5d0c56e58	a7d85557-9917-4bab-af32-d9673fe57186	C	ক্যাসিন	2	\N
0fcf5ff2-2538-403d-8370-32997cedb2e0	a7d85557-9917-4bab-af32-d9673fe57186	D	ল্যাক্টঅ্যালবুমিন	3	\N
11e21ff7-7f3d-44e1-a020-3d76025abb53	7e61a652-0e81-456b-9c02-97f81dd7a84b	A	প্রোপানোন	0	\N
b4b327ad-21d7-45e8-9fde-cc941e3ff50b	7e61a652-0e81-456b-9c02-97f81dd7a84b	B	প্রোপিন	1	\N
37935f3e-817a-4c60-9583-64d14677ffd8	7e61a652-0e81-456b-9c02-97f81dd7a84b	C	প্রোপানল	2	\N
81236cd7-5eac-437e-b21e-edce83388108	7e61a652-0e81-456b-9c02-97f81dd7a84b	D	প্রোপান্যাল	3	\N
059333e7-4e58-45a9-bc8f-fe04b4ce52ad	0c0333a8-db06-4c7b-bea0-578be51a63df	A	$\\ce{-CHO}$	0	\N
8ff3d86f-d120-4f4a-bcf4-7ca4d5bf65ea	0c0333a8-db06-4c7b-bea0-578be51a63df	B	$\\ce{-NO2}$	1	\N
3c1b363d-70fe-47d1-91a7-f16550612531	0c0333a8-db06-4c7b-bea0-578be51a63df	C	$\\ce{-NH2}$	2	\N
b7c73d10-855b-463c-9ec0-7863474c8672	0c0333a8-db06-4c7b-bea0-578be51a63df	D	$\\ce{-SO3H}$	3	\N
38388bd3-6ccc-489b-864c-b962a1eaac1a	caf34160-873b-451e-ba8e-aefcf0a5e2d9	A	$\\ce{Na+(aq) + Cl^{-}(aq)}$	0	\N
40942029-2cfe-4d29-8208-1790f976b423	caf34160-873b-451e-ba8e-aefcf0a5e2d9	B	$\\ce{NaOH(aq) + HCl(aq)}$	1	\N
a0326cd9-afe6-43a1-8600-9a4228159536	caf34160-873b-451e-ba8e-aefcf0a5e2d9	C	$\\ce{OH^{-}(aq) + Cl^{-}(aq)}$	2	\N
3d130702-5a9a-4607-94a1-5ba48807983a	caf34160-873b-451e-ba8e-aefcf0a5e2d9	D	$\\ce{Na+ + Cl^{-}}$	3	\N
bccedc5c-2889-4e8c-87a7-b3b8bf4f6efa	f59f0363-3312-4d2b-b7f0-4a67e92a6d43	A	$\\frac{3}{4} R_H$	0	\N
76ca2773-222f-4380-883a-56ff492baf7a	f59f0363-3312-4d2b-b7f0-4a67e92a6d43	B	$\\frac{5}{36} R_H$	1	\N
28dbb453-75b0-4c2d-afcf-1a74afb893e7	f59f0363-3312-4d2b-b7f0-4a67e92a6d43	C	$\\frac{3}{16} R_H$	2	\N
b82ca8bb-f9fd-426f-9820-3a1745912160	f59f0363-3312-4d2b-b7f0-4a67e92a6d43	D	$\\frac{9}{144} R_H$	3	\N
901abe97-3c2e-4207-8098-f2e424cb3bcc	9758b3e8-e5f5-4bad-a925-609b556c384d	A	$173\\,\\text{kJ/mol}$	0	\N
d7555c20-748d-42fa-af85-b87bb1d29892	9758b3e8-e5f5-4bad-a925-609b556c384d	B	$-394\\,\\text{kJ/mol}$	1	\N
89c0042d-5825-484c-b9d2-4f1f20e2ea50	9758b3e8-e5f5-4bad-a925-609b556c384d	C	$373\\,\\text{kJ/mol}$	2	\N
b7db49cb-2e6d-41c9-9bde-424667a187b7	9758b3e8-e5f5-4bad-a925-609b556c384d	D	$394\\,\\text{kJ/mol}$	3	\N
72a8773f-a00d-4e8b-9668-5db3b7b4f224	f5711a00-a72f-4b09-ac83-19de367a4db1	A	3	0	\N
64dbf83e-c5e5-4170-9c6a-64763577f12d	f5711a00-a72f-4b09-ac83-19de367a4db1	B	4	1	\N
6688012a-8745-41a3-bcaf-722a624e411b	f5711a00-a72f-4b09-ac83-19de367a4db1	C	5	2	\N
fa603510-9e1b-45f2-9c0d-d3971252149a	f5711a00-a72f-4b09-ac83-19de367a4db1	D	6	3	\N
c0b94ba5-8266-44c4-97ec-28746634128b	a51d7c27-ebce-4cc4-9b5b-441d5ff104c8	A	ক্ষার	0	\N
457deb14-2379-4e12-9f47-466caa6f9024	a51d7c27-ebce-4cc4-9b5b-441d5ff104c8	B	দ্রাবক	1	\N
d4be9b23-28df-4155-b94e-868826bd8685	a51d7c27-ebce-4cc4-9b5b-441d5ff104c8	C	অনুঘটক	2	\N
34e7b34e-106f-4f08-b46e-86c02501b05c	a51d7c27-ebce-4cc4-9b5b-441d5ff104c8	D	নিউক্লিওফাইল	3	\N
8c3de5dd-4e56-4c87-bb7f-2732aecbe003	fec8cafa-9a31-4118-997a-2dc4ff1452d9	A	$K_w = 1 \\times 10^{-14}$	0	\N
fe1dad54-857c-40cf-8ca0-eb39a95234c6	fec8cafa-9a31-4118-997a-2dc4ff1452d9	B	$pK_w = 14$	1	\N
cb20056e-e11d-4fb5-bb24-88b234af615f	fec8cafa-9a31-4118-997a-2dc4ff1452d9	C	$[\\ce{H3O^+}][\\ce{OH^-}] = K_w$	2	\N
96eafa40-12b7-482e-9e05-1a2ac8529cb2	fec8cafa-9a31-4118-997a-2dc4ff1452d9	D	$K_w = 1 \\times 10^{-14} \\text{ M}$	3	\N
e6246e3d-5bec-4af0-b93c-c531c3608696	e22a26cf-e7ce-464b-b19c-7fe1766f7c72	A	2	0	\N
b16b3d61-4cfa-4eee-860a-abe429e08669	e22a26cf-e7ce-464b-b19c-7fe1766f7c72	B	3	1	\N
b121a89f-f192-46d8-8c35-4bfdfd40d1e1	e22a26cf-e7ce-464b-b19c-7fe1766f7c72	C	-2	2	\N
f698603b-6a1e-4a27-9909-00f9334ed1d6	e22a26cf-e7ce-464b-b19c-7fe1766f7c72	D	-3	3	\N
655250cc-555c-42e1-a818-654be3984ef8	5e0e6008-65cb-4a3f-9135-33ca1bbef1ee	A	$(3, -4)$	0	\N
3ea3a099-3ac1-4178-9edc-25156821d03a	5e0e6008-65cb-4a3f-9135-33ca1bbef1ee	B	$(-3, 4)$	1	\N
79e3083f-a445-4f16-a8e0-598d08d1db5c	5e0e6008-65cb-4a3f-9135-33ca1bbef1ee	C	$(-3, -4)$	2	\N
7094bb31-953a-41f0-9ce0-a5f5b3a06c96	5e0e6008-65cb-4a3f-9135-33ca1bbef1ee	D	$(3, 4)$	3	\N
2c41c9a9-a5e6-46ad-b32d-676e9bb0671f	d731f844-7267-4331-8e61-e9b3d4f84248	A	$\\frac{1}{4}$	0	\N
63241bf0-f535-4f61-a3a4-e8a90b2bd218	d731f844-7267-4331-8e61-e9b3d4f84248	B	$\\frac{1}{8}$	1	\N
9798cde9-031e-4d27-95a0-06a709c4e005	d731f844-7267-4331-8e61-e9b3d4f84248	C	$\\frac{1}{2}$	2	\N
fae09335-bbce-40fd-9ba3-66fb616666a9	d731f844-7267-4331-8e61-e9b3d4f84248	D	1	3	\N
d73267a3-843a-48a0-8ae3-26a382f8be71	36cf314e-7f2e-4dbb-9f51-3b44b39668a9	A	0	0	\N
7e933cc5-93a8-4f7c-b087-6a5978134556	36cf314e-7f2e-4dbb-9f51-3b44b39668a9	B	1	1	\N
f0186adf-b3c8-453d-9765-36f1edd4ca6b	36cf314e-7f2e-4dbb-9f51-3b44b39668a9	C	2	2	\N
8a673d1a-e176-4935-8f11-75933a6e9c77	36cf314e-7f2e-4dbb-9f51-3b44b39668a9	D	$\\frac{1}{2}$	3	\N
927e24ad-67d1-4479-a828-1a2552c7d163	cb064a5d-b595-47d2-82f0-62cae4d01f6e	A	$\\frac{\\sin(2\\ln x)}{2}$	0	\N
aadf54bc-b86a-45ae-9f15-1cc2c4c90212	cb064a5d-b595-47d2-82f0-62cae4d01f6e	B	$\\frac{2\\cos(\\ln x)}{x}$	1	\N
76732871-39c9-4ed6-85d9-8b5bd7baacec	cb064a5d-b595-47d2-82f0-62cae4d01f6e	C	$\\frac{\\sin(2\\ln x)}{x}$	2	\N
6c746e39-c069-4ca3-a761-9c9c5ade32ea	cb064a5d-b595-47d2-82f0-62cae4d01f6e	D	$-2x \\cos(\\ln x) \\sin(\\ln x)$	3	\N
58b3a7cc-97dc-403c-be28-94c4bc7f712b	0e6f388d-33a0-4f0a-88e4-3e5b6f56072e	A	$4 \\times 2$	0	\N
e29f5d97-b2f1-4d4a-a805-34eb925a9c2a	0e6f388d-33a0-4f0a-88e4-3e5b6f56072e	B	$5 \\times 4$	1	\N
c3645a2e-fad7-4689-ac35-447885c95b9f	0e6f388d-33a0-4f0a-88e4-3e5b6f56072e	C	$5 \\times 2$	2	\N
0617f71f-43f9-46d5-a673-5a8d484e41fe	0e6f388d-33a0-4f0a-88e4-3e5b6f56072e	D	$2 \\times 5$	3	\N
5a1e59f6-b17c-437f-bb88-20f91cfdf112	4d48eb67-9224-4cda-ada6-72237c81dc55	A	$\\frac{\\pi}{2}$	0	\N
a7623ea1-9811-4fd1-a47e-74201e3dd7af	4d48eb67-9224-4cda-ada6-72237c81dc55	B	$\\frac{\\pi}{3}$	1	\N
a37587bd-f020-468d-ab80-f8ff5a8cf1cb	4d48eb67-9224-4cda-ada6-72237c81dc55	C	$\\frac{\\pi}{4}$	2	\N
0994ab44-2c3b-4eac-9143-30328aa7a140	4d48eb67-9224-4cda-ada6-72237c81dc55	D	$\\frac{\\pi}{6}$	3	\N
710e7179-526d-4eec-b396-59a3a668b2c0	e8bdfe3d-0799-4385-84a2-99e588b584f7	A	$30^\\circ$	0	\N
688307c1-725c-4cbc-b4b2-a017d1ded1c3	e8bdfe3d-0799-4385-84a2-99e588b584f7	B	$45^\\circ$	1	\N
1f73c4b6-4a9c-47bd-bd77-25e21971c019	e8bdfe3d-0799-4385-84a2-99e588b584f7	C	$65^\\circ$	2	\N
a3b3a589-9e5b-4205-9224-b427dd9b4f2e	e8bdfe3d-0799-4385-84a2-99e588b584f7	D	$120^\\circ$	3	\N
9b1394e5-a99e-422b-bd40-06d3ca6e1900	f03efe1d-a96d-45db-ad85-9a0ef8dad3e7	A	15	0	\N
f0477ccf-7851-47b7-88dd-508c5d6e09eb	f03efe1d-a96d-45db-ad85-9a0ef8dad3e7	B	25	1	\N
1784632a-8881-47b4-ab61-33c23a35b74f	f03efe1d-a96d-45db-ad85-9a0ef8dad3e7	C	30	2	\N
f6cf4953-1d56-4a76-ba3c-9195e826eb99	f03efe1d-a96d-45db-ad85-9a0ef8dad3e7	D	35	3	\N
df5fbe1c-5d44-47df-94ce-86f9611ac0c4	2518e0e8-9206-4450-b11a-13117a8ad1e1	A	$\\sqrt{3}$	0	\N
f9e6e45f-1a3e-47b0-b234-102d94bcb993	2518e0e8-9206-4450-b11a-13117a8ad1e1	B	$\\frac{1}{3}$	1	\N
ac70554e-6295-49a4-8706-8bda07c448db	2518e0e8-9206-4450-b11a-13117a8ad1e1	C	$\\frac{1}{\\sqrt{3}}$	2	\N
22cf3ed9-b57e-4cda-9153-41959eda8c43	2518e0e8-9206-4450-b11a-13117a8ad1e1	D	$\\frac{1}{2}$	3	\N
5fdff081-4972-45cb-b6a7-56bda964f154	25d93e66-2e35-4311-a08a-e1daf77f5cd5	A	Ellipse	0	\N
2b9c1941-a1c4-4503-95c3-18be3bc877ca	25d93e66-2e35-4311-a08a-e1daf77f5cd5	B	Parabola	1	\N
d413c4d4-6e6c-40c3-8b78-4f4b84956c8b	25d93e66-2e35-4311-a08a-e1daf77f5cd5	C	Circle	2	\N
834eb97a-b3f9-4db4-a25f-f843638f3a59	25d93e66-2e35-4311-a08a-e1daf77f5cd5	D	Hyperbola	3	\N
e4c75f05-d5c2-4559-8b36-54c7e6c48f23	1d109fae-1ac2-4f89-8067-e9ba7c36622d	A	$\\frac{1}{18}$	0	\N
ba59f338-a5f9-4b21-a215-67272ea6b564	1d109fae-1ac2-4f89-8067-e9ba7c36622d	B	$\\frac{1}{6}$	1	\N
aedf159f-9630-4a4d-ba91-6b6091b17ea0	1d109fae-1ac2-4f89-8067-e9ba7c36622d	C	$\\frac{1}{216}$	2	\N
f52f9519-77d7-4a30-83af-b02cfe136bad	1d109fae-1ac2-4f89-8067-e9ba7c36622d	D	$\\frac{1}{36}$	3	\N
7ff774e9-a5ef-4658-a598-839ae1d5544d	87e9fd93-2808-42fd-b422-83f211bb7322	A	$x \\leq 3$	0	\N
133ab4b5-98fe-447b-9316-f8c22d45079a	87e9fd93-2808-42fd-b422-83f211bb7322	B	$x \\geq 2$	1	\N
bf99b88a-64ff-4625-8d2f-d2ef0da6ee8a	87e9fd93-2808-42fd-b422-83f211bb7322	C	$2 \\leq x \\leq 11$	2	\N
6df8b637-3fb5-49bb-bc21-9b95ba6f01c2	87e9fd93-2808-42fd-b422-83f211bb7322	D	$2 \\leq x \\leq 3$	3	\N
f698122e-3b70-4013-9cba-952f6ca6853e	cfc4d4f2-7399-4d28-a66d-32cad02fe053	A	2	0	\N
d8ef0a33-ca61-4327-bb26-f46273fdf381	cfc4d4f2-7399-4d28-a66d-32cad02fe053	B	3	1	\N
b2b5fc56-f227-48c3-bd8a-d98e46d67615	cfc4d4f2-7399-4d28-a66d-32cad02fe053	C	4	2	\N
c0920919-a9cc-4539-b87d-d7c386f99a9e	cfc4d4f2-7399-4d28-a66d-32cad02fe053	D	6	3	\N
ad8309bf-4caa-46e1-9a7b-0b3244ab435a	c92c73b1-0152-4405-a2fa-756266d65d68	A	$\\frac{u^2}{2g}$	0	\N
c82983fa-6f32-4476-aaab-37e06ee399f8	c92c73b1-0152-4405-a2fa-756266d65d68	B	$\\frac{2u^2}{g}$	1	\N
7505bcc4-6730-4943-b576-2b8ee947d49f	c92c73b1-0152-4405-a2fa-756266d65d68	C	$\\frac{u^2}{2g} \\sin\\alpha$	2	\N
add0a6e5-d5af-4139-9541-e169b287ec64	c92c73b1-0152-4405-a2fa-756266d65d68	D	$\\frac{u^2}{2g} \\cos\\alpha$	3	\N
0dfbe5a9-e343-4744-a201-0d5ce4b51ce8	00b03986-74f2-40b4-9af6-ce3925b007dc	A	Cycas	0	\N
ced360ac-6db4-401e-9b33-2489ade9219a	00b03986-74f2-40b4-9af6-ce3925b007dc	B	Pinus	1	\N
39fb4d19-507d-42da-a807-b9618900c5c5	00b03986-74f2-40b4-9af6-ce3925b007dc	C	Hibiscus	2	\N
e73572c0-d6b3-471c-8742-3c97d55f1209	00b03986-74f2-40b4-9af6-ce3925b007dc	D	Ficus	3	\N
ddaf9f21-4043-40c7-b7b2-b77f6b8e6a11	e8ee2da2-bf87-4c75-8c8f-2e9c0d8f6ffa	A	3 : 1	0	\N
eede91a7-f956-4a31-9caa-a928ddf0bc44	e8ee2da2-bf87-4c75-8c8f-2e9c0d8f6ffa	B	2 : 1	1	\N
2000298b-5967-43dd-982f-d8fee4364baf	e8ee2da2-bf87-4c75-8c8f-2e9c0d8f6ffa	C	9 : 7	2	\N
bdaf1275-4943-4a11-abb9-59bc92ffc2f7	e8ee2da2-bf87-4c75-8c8f-2e9c0d8f6ffa	D	13 : 3	3	\N
1cce715e-2c58-493d-9f9b-ab3b70622242	5f20e571-1124-47e8-b85d-e3e560f8f78c	A	Loa loa	0	\N
e8acbf84-e4f1-4115-acaf-0b04b7116f66	5f20e571-1124-47e8-b85d-e3e560f8f78c	B	Fasciola hepatica	1	\N
1da5babb-2c59-4d14-80f9-0674b6c74fd0	5f20e571-1124-47e8-b85d-e3e560f8f78c	C	Ascaris lumbricoides	2	\N
f946adf1-837b-4d47-8beb-b5bb6775a635	5f20e571-1124-47e8-b85d-e3e560f8f78c	D	None of them	3	\N
8fea49b4-7cd9-4d42-af7c-f6e52a0e1905	e49544ab-0be3-452c-8c27-063d7ccdfd9a	A	Arthropoda	0	\N
e63cc1b0-024e-4a74-bd14-e774d2a4043a	e49544ab-0be3-452c-8c27-063d7ccdfd9a	B	Mollusca	1	\N
676bff79-62bb-4451-a0d3-52e51c193eca	e49544ab-0be3-452c-8c27-063d7ccdfd9a	C	Annelida	2	\N
53eac913-643b-4719-95e3-be590f74f059	e49544ab-0be3-452c-8c27-063d7ccdfd9a	D	Echinodermata	3	\N
8f0888c7-1075-47e0-8f49-17ab16dc98fc	b9d4bc25-127c-4c39-bb6a-f74fab2daa5b	A	ত্বক	0	\N
0a9b9972-f292-44f1-b7ca-c4cd011cf99d	b9d4bc25-127c-4c39-bb6a-f74fab2daa5b	B	অধঃত্বক	1	\N
60d808ed-43f7-471a-b372-d46a2ed94e6b	b9d4bc25-127c-4c39-bb6a-f74fab2daa5b	C	কর্টেক্স	2	\N
ae486a5d-9bbd-4c7a-ad7c-c73dbe3659dd	b9d4bc25-127c-4c39-bb6a-f74fab2daa5b	D	অন্তস্ত্বক	3	\N
27a4fbc8-9722-4d6f-9f7e-354c0be2738b	3e67f4a4-ca8a-4bd9-9ee2-e16bd6c81433	A	লেপ্টোটিন	0	\N
e63068b0-a459-49c1-bebe-84301751b902	3e67f4a4-ca8a-4bd9-9ee2-e16bd6c81433	B	জাইগোটিন	1	\N
5a2d905d-bc10-460c-8723-b99b2a6cecd4	3e67f4a4-ca8a-4bd9-9ee2-e16bd6c81433	C	প্যাকাইটিন	2	\N
033e8ccf-fb91-4625-87d9-396e6dbbec89	3e67f4a4-ca8a-4bd9-9ee2-e16bd6c81433	D	ডিপ্লোটিন	3	\N
8c885a24-1f19-4d85-a01e-fbc8ecd104c4	a3aaef78-8e59-433f-ac68-4519f4760806	A	7.0	0	\N
b5162568-6e99-4543-8e9d-694fe3f1d64b	a3aaef78-8e59-433f-ac68-4519f4760806	B	7.4	1	\N
072b489b-20fd-4ecf-86fd-be42477ea6df	a3aaef78-8e59-433f-ac68-4519f4760806	C	7.6	2	\N
35171f13-aee9-446c-8bea-68d98287c3d4	a3aaef78-8e59-433f-ac68-4519f4760806	D	7.8	3	\N
bde03d3a-029d-43c2-97f9-45c5203758b1	ac9c2eda-3782-4ada-810c-06a385ce0a78	A	অগ্ন্যাশয়ে	0	\N
c99b13b2-e8c4-4a8e-a87a-70b714fd37c6	ac9c2eda-3782-4ada-810c-06a385ce0a78	B	যকৃতে	1	\N
679b521b-b5ac-4dc0-a2d2-35b69391fcd8	ac9c2eda-3782-4ada-810c-06a385ce0a78	C	অস্থিমজ্জায়	2	\N
935bded4-a7a0-4827-a5e3-dc61396d618b	ac9c2eda-3782-4ada-810c-06a385ce0a78	D	হৃৎপিণ্ডে	3	\N
aef7b4b6-0f71-4d72-9428-3cc4dd29a39b	d08735b1-aae3-42f7-8532-2c5c6bc6c925	A	ডিম-নিম্ফ-পূর্ণাঙ্গ পতঙ্গ	0	\N
5bafd957-1346-46c5-b3fd-4560c4a64b9f	d08735b1-aae3-42f7-8532-2c5c6bc6c925	B	ডিম-লার্ভা-পূর্ণাঙ্গ পতঙ্গ	1	\N
bfedf32a-3739-4c03-bfbc-7284bb2b8f44	d08735b1-aae3-42f7-8532-2c5c6bc6c925	C	ডিম-পিউপা-লার্ভা-পূর্ণাঙ্গ পতঙ্গ	2	\N
df9cb785-b4d3-4bb5-974d-e694bcf5eb9b	d08735b1-aae3-42f7-8532-2c5c6bc6c925	D	ডিম-লার্ভা-পিউপা-পূর্ণাঙ্গ পতঙ্গ	3	\N
6ed4481f-2c46-4f1f-8ce9-67900f63fb2d	b97ea374-8a87-4ee2-a8b4-90834d50371a	A	Tectona grandis	0	\N
ccf7a4b0-8788-4c40-a63b-86df008d6716	b97ea374-8a87-4ee2-a8b4-90834d50371a	B	Barringtonia acutangula	1	\N
3b1e8a1e-6658-4c08-83c3-3b4b9120c75b	b97ea374-8a87-4ee2-a8b4-90834d50371a	C	Shorea robusta	2	\N
f5e9e4e0-0566-4751-b7e7-20554e8fbf82	b97ea374-8a87-4ee2-a8b4-90834d50371a	D	Cassia fistula	3	\N
ae1f819d-ad5b-4bad-ab5e-07d61e1ee29a	f518c5a0-69dd-4fb3-8e38-173f7491c10d	A	Spirillum minus	0	\N
70ac0139-c278-4ced-bb48-111fce6f061e	f518c5a0-69dd-4fb3-8e38-173f7491c10d	B	Vibrio cholerae	1	\N
5f627947-3571-4946-b874-c84860f2f0f3	f518c5a0-69dd-4fb3-8e38-173f7491c10d	C	Pseudomonas fluorescens	2	\N
c2eb10e8-66aa-4a68-a04e-f53066f53074	f518c5a0-69dd-4fb3-8e38-173f7491c10d	D	Bacillus subtilis	3	\N
04bc80a2-1a9c-419e-8e4c-8e367e7d2639	f3ccae87-8df4-45b5-a2f8-f092d524eaa9	A	Escherichia	0	\N
333d485f-696e-4569-a5f4-25e4d036927a	f3ccae87-8df4-45b5-a2f8-f092d524eaa9	B	Nostoc	1	\N
2aefbad0-b210-44e0-94d9-f36e7bcfb87c	f3ccae87-8df4-45b5-a2f8-f092d524eaa9	C	Zygnema	2	\N
9e03c4f3-b26b-4d34-84e1-685c2cc5e60e	f3ccae87-8df4-45b5-a2f8-f092d524eaa9	D	Chlorella	3	\N
3dafd2d1-cb0a-4598-ade2-79f66a01f901	39dd46a2-325a-4193-8e31-6dfdfc974b3a	A	CCU	0	\N
428904f6-dae6-40a0-a308-7a642a0dfb59	39dd46a2-325a-4193-8e31-6dfdfc974b3a	B	ACU	1	\N
13513358-5b86-441a-b9ed-f63237b6c98d	39dd46a2-325a-4193-8e31-6dfdfc974b3a	C	UGA	2	\N
3f526562-8631-45a1-87b0-cba719136b21	39dd46a2-325a-4193-8e31-6dfdfc974b3a	D	AAG	3	\N
6b6a1452-692e-4484-aacb-68af0030e7d2	aac47faa-1e1c-444f-8beb-d6e87baf4e7e	A	IgG	0	\N
2e614e06-dbca-444c-be91-ed3605c8da80	aac47faa-1e1c-444f-8beb-d6e87baf4e7e	B	IgA	1	\N
2a5fa6a2-4a66-4684-8bc3-4e590a7cb049	aac47faa-1e1c-444f-8beb-d6e87baf4e7e	C	IgM	2	\N
45000f77-0175-4f8c-9990-0a53e591be57	aac47faa-1e1c-444f-8beb-d6e87baf4e7e	D	IgE	3	\N
0ced40ac-051d-4e7c-a428-d6c8edce728b	a07a61b1-3cd7-476b-89f6-8a8c7efa8e60	A	৪টি	0	\N
4e8ed74a-e62d-4df7-a43c-db65c38bf25e	a07a61b1-3cd7-476b-89f6-8a8c7efa8e60	B	৫টি	1	\N
17305724-845f-4ebc-8d0e-de90c9e3b31b	a07a61b1-3cd7-476b-89f6-8a8c7efa8e60	C	৭টি	2	\N
c5927a40-b941-4d5c-abc8-2550e20dea81	a07a61b1-3cd7-476b-89f6-8a8c7efa8e60	D	১২টি	3	\N
2f5631e7-4b67-4098-8d42-b11b3281cbac	9f75d35f-1455-4153-8056-423445f16fce	A	সবসময়	0	\N
e25986c6-7186-4da1-be43-18dac655e55c	9f75d35f-1455-4153-8056-423445f16fce	B	কখনোই না	1	\N
e6ae3fbb-e997-4764-9909-a98cd7c759a6	9f75d35f-1455-4153-8056-423445f16fce	C	শুধুমাত্র যখন $i = 0$	2	\N
efe9b573-f8d5-418f-b31a-6cfed0348703	26a90ee1-1a28-4f25-99c1-62d64f2b39df	C	4f	2	\N
b46f795c-90e0-4028-bf26-c43a4f0c4d15	9f75d35f-1455-4153-8056-423445f16fce	D	শুধুমাত্র যখন $i = \\text{ধ্রুবক}$	3	\N
691493c7-ce07-4fb8-8a79-b8b3962e40e9	bddb3fc5-93d3-4c42-a66d-96227a6e8f0f	A	$\\frac{D}{2}$	0	\N
b04e05da-1341-4344-8d5f-33680fe2a596	bddb3fc5-93d3-4c42-a66d-96227a6e8f0f	B	$\\sqrt{2}D$	1	\N
c7d89faa-de68-457d-9596-3e26a6249e1e	bddb3fc5-93d3-4c42-a66d-96227a6e8f0f	C	$2D$	2	\N
f5b8bab3-92e8-4975-8803-ba4c0ed14581	bddb3fc5-93d3-4c42-a66d-96227a6e8f0f	D	$\\frac{D}{\\sqrt{2}}$	3	\N
d1bff3b8-b188-4fab-a633-86d44fabf414	e9c58f65-779c-4040-94a0-db21a41f3a7a	A	$220\\,\\text{Hz}$	0	\N
29147056-bee9-4475-96c0-b101d4b8132f	e9c58f65-779c-4040-94a0-db21a41f3a7a	B	$50\\,\\text{Hz}$	1	\N
bdaf68df-2a9b-405f-8a30-c40adbd0d9fa	e9c58f65-779c-4040-94a0-db21a41f3a7a	C	$25\\,\\text{Hz}$	2	\N
115e91d0-ea94-44f6-bb89-807e23cf5746	e9c58f65-779c-4040-94a0-db21a41f3a7a	D	$100\\,\\text{Hz}$	3	\N
f46005aa-188e-4f8d-87a9-ce30fde3d42e	98f61b5a-bb45-4b43-b6ac-d150779b2711	A	$\\frac{2c}{\\sqrt{3}}$	0	\N
8849401f-57d9-4184-b8ec-c5a3b179de63	98f61b5a-bb45-4b43-b6ac-d150779b2711	B	$\\frac{\\sqrt{3}}{2}c$	1	\N
26d6a805-a068-4014-8162-50629f94b133	98f61b5a-bb45-4b43-b6ac-d150779b2711	C	$c$	2	\N
768394d3-c75b-40de-b081-8f83ff3103f8	98f61b5a-bb45-4b43-b6ac-d150779b2711	D	$2c$	3	\N
2688160d-6691-4c97-bccf-dcc6180f079d	d8273d47-fb02-4186-aac8-9ca5e5541f2e	A	হ্রাস পাবে	0	\N
83807cdc-73ca-4896-99d6-d2c7b96d77ea	d8273d47-fb02-4186-aac8-9ca5e5541f2e	B	বৃদ্ধি পাবে	1	\N
cec19600-ad34-48f6-b18e-f2e1787c7cab	d8273d47-fb02-4186-aac8-9ca5e5541f2e	C	অপরিবর্তিত থাকবে	2	\N
55f32bc4-8abe-4cd7-8a42-f2e526996df4	d8273d47-fb02-4186-aac8-9ca5e5541f2e	D	কোনোটিই নয়	3	\N
faae00f7-eb37-4380-b0d8-d6988028c5fe	52130c99-6ddd-4199-99fc-1a9ced88011c	A	$2T$	0	\N
5a7db5a3-a90f-4f61-8241-24dd3366be8a	52130c99-6ddd-4199-99fc-1a9ced88011c	B	$T$	1	\N
50abb4dd-2855-4027-b80c-99335fd6562b	52130c99-6ddd-4199-99fc-1a9ced88011c	C	$4T$	2	\N
ab745669-68ec-413e-bdea-fb4a939136d2	52130c99-6ddd-4199-99fc-1a9ced88011c	D	$T/4$	3	\N
728fb87c-84aa-4743-bc62-d58fb71ef1a8	5679a8f3-dad5-48c3-8057-6caa1fbd2683	A	$1:2$	0	\N
fa399860-7154-4868-a16c-cc6c62784b61	5679a8f3-dad5-48c3-8057-6caa1fbd2683	B	$1:8$	1	\N
717853b1-9dbb-4c94-a1fa-3b7c5f0c1f4d	5679a8f3-dad5-48c3-8057-6caa1fbd2683	C	$1:4$	2	\N
9c571e40-1bdc-4333-b639-66d68841979c	5679a8f3-dad5-48c3-8057-6caa1fbd2683	D	$1:7$	3	\N
33040774-0171-4a29-a74c-6dbe514c829d	d8122c72-6c11-4278-835b-9d1e6df1a3c8	A	$0$	0	\N
4d2000e2-7721-4d13-9ecb-476167addcd1	d8122c72-6c11-4278-835b-9d1e6df1a3c8	B	$1$	1	\N
60992f30-fd1e-4589-8b3b-6f46faa956b6	d8122c72-6c11-4278-835b-9d1e6df1a3c8	C	$3$	2	\N
8f8bf39c-75a7-4c91-ba6a-18c0f669c52e	d8122c72-6c11-4278-835b-9d1e6df1a3c8	D	$5$	3	\N
429ff89b-2e4d-459b-a3ec-933ea6eb0385	6b7a2340-d204-4c9a-a820-90576cb4732e	A	$2\\,\\text{A}$	0	\N
be53c8b3-26c6-4982-9e11-a5cc167eb2d6	6b7a2340-d204-4c9a-a820-90576cb4732e	B	$3\\,\\text{A}$	1	\N
3a6224d7-2c06-4a7c-9968-5efeef08bd59	6b7a2340-d204-4c9a-a820-90576cb4732e	C	$6\\,\\text{A}$	2	\N
fd490b8b-e941-472e-b451-3993b62832e2	6b7a2340-d204-4c9a-a820-90576cb4732e	D	$12\\,\\text{A}$	3	\N
ba2e57ae-d6fb-41eb-bce9-9bc11a29f29f	ecfc3df5-ed6a-44f4-9485-2c29f731aa0b	A	$aL^2 + bLx^3$	0	\N
a0ba4205-4cfc-4c8e-b2a8-0ae82a1da0eb	ecfc3df5-ed6a-44f4-9485-2c29f731aa0b	B	$\\frac{aL^2}{2} + 2bL^2$	1	\N
676c9a4e-9fd0-4e78-b4a2-04d4c515dd53	ecfc3df5-ed6a-44f4-9485-2c29f731aa0b	C	$a + 2bL$	2	\N
414aefd7-55f6-4bf1-abd4-0a74e859ffaf	ecfc3df5-ed6a-44f4-9485-2c29f731aa0b	D	$\\frac{aL^2}{2} + \\frac{bL^3}{3}$	3	\N
c9011c68-aca6-4260-8e52-a1d0229aa5d3	860c1fc9-5098-4d31-856f-94e217189509	A	6	0	\N
38952a81-e0f3-4fbc-9186-de559b7cf42b	860c1fc9-5098-4d31-856f-94e217189509	B	5	1	\N
10dae20b-d767-4f8c-a7ea-7bdc8058d71f	860c1fc9-5098-4d31-856f-94e217189509	C	25	2	\N
00b83376-320e-4241-9b9f-ee06c757196a	860c1fc9-5098-4d31-856f-94e217189509	D	150	3	\N
d3aad691-df4d-410d-b775-07c8ad45bb81	f29d26aa-a051-4d45-b580-7f49cc55ac8e	A	$\\sqrt{(Ec)}$	0	\N
23726136-5477-4cd5-97f9-66d45f6fa744	f29d26aa-a051-4d45-b580-7f49cc55ac8e	B	$\\frac{E}{c}$	1	\N
d56428ee-c76b-486e-abfc-23b337fba0cf	f29d26aa-a051-4d45-b580-7f49cc55ac8e	C	$Ec$	2	\N
6f230780-a5d3-47bb-ac99-64004adb3dbe	f29d26aa-a051-4d45-b580-7f49cc55ac8e	D	শূন্য (0)	3	\N
c1f801a5-f5d9-4d0d-83d1-7a4876089ef5	06124444-db56-443e-8025-1c2c369f8576	A	$v = \\sqrt{\\frac{eV}{m}}$	0	\N
2a61bed2-ee25-4c83-995d-63d70b3a36bf	06124444-db56-443e-8025-1c2c369f8576	B	$v = \\sqrt{\\frac{2eV}{m}}$	1	\N
4ba1dba5-dd9b-4292-b3ae-12a1a5cd025a	06124444-db56-443e-8025-1c2c369f8576	C	$v = \\frac{eV^2}{m}$	2	\N
c07eae32-40a1-465d-8251-39d48afc3b9a	06124444-db56-443e-8025-1c2c369f8576	D	$v = \\frac{1}{2}mv^2$	3	\N
021bb5d8-5cff-4c38-a198-996bba815ff9	f606aac2-ea93-4afb-894f-6c4fa67e6b05	A	কমবে	0	\N
85e6a1aa-d65e-45c8-b323-6b07e4362451	f606aac2-ea93-4afb-894f-6c4fa67e6b05	B	স্থির থাকবে	1	\N
11d82650-fad7-4f3c-908d-8c10e5dcede1	f606aac2-ea93-4afb-894f-6c4fa67e6b05	C	বাড়বে	2	\N
687fd6c4-3404-416f-bd51-1bd94c352d9b	f606aac2-ea93-4afb-894f-6c4fa67e6b05	D	প্রথমে বাড়বে তারপর কমবে	3	\N
177f4cca-2723-42c7-9baa-22c8ef4a0369	24c0e56f-d2c6-4418-ae77-a82a0b94ee74	A	$\\Delta U$	0	\N
82a7ef53-75e0-4955-ab10-407d66ecc385	24c0e56f-d2c6-4418-ae77-a82a0b94ee74	B	$W$	1	\N
94ba5a21-21dc-4f94-9ee2-3ad3d794db9b	24c0e56f-d2c6-4418-ae77-a82a0b94ee74	C	$\\Delta P$	2	\N
a7af0c33-5506-405c-83d6-0808db959efb	24c0e56f-d2c6-4418-ae77-a82a0b94ee74	D	$\\Delta S$	3	\N
d5f48469-16b1-4827-9071-04d6094d227b	506e8e63-da7f-47f5-8881-520caa7dc5cc	A	$sp^3$	0	\N
0565534c-8748-4a9f-ae2e-9153eec87ecc	506e8e63-da7f-47f5-8881-520caa7dc5cc	B	$sp^2$	1	\N
95b86425-8fde-4c6c-9eaf-47000397bda3	506e8e63-da7f-47f5-8881-520caa7dc5cc	C	$sp$	2	\N
e398ff2e-eb59-4914-ac84-5f8827eb8b0f	506e8e63-da7f-47f5-8881-520caa7dc5cc	D	$sp^3d$	3	\N
68eddb6c-5762-4410-8c01-4d426d3ec475	0ca6f1c1-df84-42ea-9935-b6d2003e8887	A	$\\ce{2Na + Cl2 -> 2NaCl}$	0	\N
91b1af97-bfde-4175-8b52-d90de4e665b7	0ca6f1c1-df84-42ea-9935-b6d2003e8887	B	$\\ce{AgNO3 + NaCl -> NaNO3 + AgCl}$	1	\N
1dda6c1e-1876-484e-904a-31813a0a5ee4	0ca6f1c1-df84-42ea-9935-b6d2003e8887	C	$\\ce{Cl2 + H2O -> HCl + HOCl}$	2	\N
6c269c26-4980-4338-8de6-1249ef80e8a7	0ca6f1c1-df84-42ea-9935-b6d2003e8887	D	$\\ce{FeCl3 + SnCl2 -> SnCl4 + FeCl2}$	3	\N
7190b7bf-a536-44d0-9c2b-ee3ce71b6a12	af4ee6a2-b349-4f56-9724-57e7f5733462	A	Chlorobenzene	0	\N
09c564f2-508c-43e3-add4-6b56667352a8	af4ee6a2-b349-4f56-9724-57e7f5733462	B	Acetophenone	1	\N
e8e927bc-f918-4bab-8588-d6fbdee26821	af4ee6a2-b349-4f56-9724-57e7f5733462	C	Toluene	2	\N
3f4838af-d7ff-4626-908e-a91283b2026d	af4ee6a2-b349-4f56-9724-57e7f5733462	D	Benzoic acid	3	\N
f6cf255b-0db4-4899-b868-967baaddaf7e	ba5d1800-a552-426d-9a25-00a730f96b55	A	Cu and Mg	0	\N
06f04ac4-6abf-4b06-95cf-3ed3001e130c	ba5d1800-a552-426d-9a25-00a730f96b55	B	Cu and Zn	1	\N
63b0d37d-2d19-406b-895e-f1ecad970d75	ba5d1800-a552-426d-9a25-00a730f96b55	C	Zn and Pb	2	\N
0170d550-4503-42fa-8be3-af269d5482b8	ba5d1800-a552-426d-9a25-00a730f96b55	D	Pb and Cu	3	\N
cadd0cb0-399f-48d7-af8d-9ca8f14b2131	f27e5ca4-e904-425b-bdcd-e48d13279251	A	HCHO	0	\N
adbff70c-75f2-419b-bad6-d4c4d31440f4	f27e5ca4-e904-425b-bdcd-e48d13279251	B	$\\ce{CH3CHO}$	1	\N
e7df19bb-ba0b-4d98-88e6-8f973f3ab6da	f27e5ca4-e904-425b-bdcd-e48d13279251	C	$\\ce{CH3COCH3}$	2	\N
030e8f73-36e5-44f5-85f8-ad7e20f84dee	f27e5ca4-e904-425b-bdcd-e48d13279251	D	$\\ce{CH3OH}$	3	\N
f55ed017-8e30-4e61-a8e7-1ceef91dc193	3d653d1d-9292-4d8c-80c1-d0336f774115	A	ছেদকসহ সরলরেখা	0	\N
2901805d-3a62-4a3b-a887-412f869b788b	3d653d1d-9292-4d8c-80c1-d0336f774115	B	অধিবৃত্ত	1	\N
326dc40e-030f-429b-a872-0689bf0fed7c	3d653d1d-9292-4d8c-80c1-d0336f774115	C	X-অক্ষের সমান্তরাল সরলরেখা	2	\N
5804a19e-5b71-4877-9846-48668b09c67d	3d653d1d-9292-4d8c-80c1-d0336f774115	D	মূলবিন্দুগামী সরলরেখা	3	\N
da5af623-4367-4e1d-b58c-a1cd6865520f	21f09b4d-acc7-460a-add5-a6575c72228e	A	2	0	\N
f25002d3-574c-4100-84d1-5fd955913b13	21f09b4d-acc7-460a-add5-a6575c72228e	B	3	1	\N
bfa62a9f-41f3-4314-8d51-a7433c9fa281	21f09b4d-acc7-460a-add5-a6575c72228e	C	4	2	\N
72ebd22b-9459-462c-8d48-398ae32fb864	21f09b4d-acc7-460a-add5-a6575c72228e	D	5	3	\N
5d3c184f-5399-4ea2-8348-4bc83ccf7dc9	b0671e9e-0c42-4d18-a448-53489fe11a54	A	HCOOH	0	\N
7af08407-2cc5-405b-8aa3-80c9c1dd3ac7	b0671e9e-0c42-4d18-a448-53489fe11a54	B	$\\ce{CH3COOH}$	1	\N
1b542f85-8415-4e40-823f-44af29a4aceb	b0671e9e-0c42-4d18-a448-53489fe11a54	C	$\\ce{CH3CHO}$	2	\N
a07bac8e-d01e-432f-9aac-b42134c19290	b0671e9e-0c42-4d18-a448-53489fe11a54	D	$\\ce{CH3CH2CH2COOH}$	3	\N
6728c09d-9c3a-4748-88a7-4d7aa9125d3c	d0386e47-4ec0-4aec-a41d-ec1fe5d8402e	A	$\\ce{NaCl(aq)}$	0	\N
990d3123-029a-4c9d-99bf-25f079f8bd1e	d0386e47-4ec0-4aec-a41d-ec1fe5d8402e	B	$\\ce{HCl(aq)}$	1	\N
274978a5-d8bf-4219-b92a-8cd119b5e1d4	d0386e47-4ec0-4aec-a41d-ec1fe5d8402e	C	Ethanol	2	\N
ef777242-64d0-4058-841d-23097dd5b467	d0386e47-4ec0-4aec-a41d-ec1fe5d8402e	D	Hexane	3	\N
405e5e5a-8267-437d-b7e0-2936b65d457c	26a90ee1-1a28-4f25-99c1-62d64f2b39df	A	2d	0	\N
83483c77-efc6-4e35-9972-a1eb63dd16f7	26a90ee1-1a28-4f25-99c1-62d64f2b39df	B	3p	1	\N
f6a7b1bd-4cef-4cb7-b840-67f21501cfdb	26a90ee1-1a28-4f25-99c1-62d64f2b39df	D	1s	3	\N
f0b5558c-eee7-4fa4-9448-1d2f05ce7b3a	8e986fe2-243a-4893-8431-948c849deb63	A	$\\ce{CO2}$	0	\N
466762f4-9323-4a7e-b5ef-f650a8f4bd17	8e986fe2-243a-4893-8431-948c849deb63	B	$\\ce{H2S}$	1	\N
853bad92-bd56-4699-8ac7-04021f6b9546	8e986fe2-243a-4893-8431-948c849deb63	C	$\\ce{C2H2}$	2	\N
fc55a5e9-6e14-4283-a307-5edef634b11c	8e986fe2-243a-4893-8431-948c849deb63	D	$\\ce{O2}$	3	\N
6be62af7-8be5-4793-9872-21111fbafbb5	d11b362d-bff5-4d65-b63e-b8139343688d	A	$\\ce{HCOOH + HCOONa}$	0	\N
ca0f7584-7f3f-4ef5-a310-edacc92d3d2c	d11b362d-bff5-4d65-b63e-b8139343688d	B	$\\ce{NaOH + NaCl}$	1	\N
ea903d58-d025-4cce-83ec-313f8069d58f	d11b362d-bff5-4d65-b63e-b8139343688d	C	Aq. $\\ce{NH3 + NaOH}$	2	\N
50517c61-b2ae-470c-9600-9a78340846ea	d11b362d-bff5-4d65-b63e-b8139343688d	D	Aq. $\\ce{NH3 + NH4Cl}$	3	\N
64e9f4e8-c838-4476-90fb-9e0675218f78	cdb7ecbd-2d79-40bd-b8e3-2dd27475cbe5	A	128 g/mol	0	\N
859c3145-3a21-433a-bd1b-8c4a98ccdada	cdb7ecbd-2d79-40bd-b8e3-2dd27475cbe5	B	72 g/mol	1	\N
e3e55917-f5ae-4f38-8172-8c0dacc3b72d	cdb7ecbd-2d79-40bd-b8e3-2dd27475cbe5	C	32 g/mol	2	\N
848629c7-587b-4780-82ef-d9b10f1d1172	cdb7ecbd-2d79-40bd-b8e3-2dd27475cbe5	D	180 g/mol	3	\N
3484fab0-4239-411c-a169-60d0a32b4b7e	ffa877c4-87a7-45ff-b8a7-2ef85befb511	A	F > O > N > C	0	\N
c50a3fa4-976c-4c43-8477-148c367f174d	ffa877c4-87a7-45ff-b8a7-2ef85befb511	B	N > F > O > C	1	\N
534ff103-5c0f-45a8-8207-99638e983c5a	ffa877c4-87a7-45ff-b8a7-2ef85befb511	C	O > F > C > N	2	\N
409ab488-a34c-4ed3-be60-e0b66aaef52c	ffa877c4-87a7-45ff-b8a7-2ef85befb511	D	F > N > O > C	3	\N
1212e23e-48eb-4fab-bfab-fb483ff31922	976f19b3-8283-4bf1-84bc-bc7eaeb09d25	A	$\\ce{PCl5(g) = PCl3(g) + Cl2(g)}$	0	\N
5a2dda1f-0ed9-45e2-9d39-b3e2bdd328ec	976f19b3-8283-4bf1-84bc-bc7eaeb09d25	B	$\\ce{N2(g) + O2(g) = 2NO(g)}$	1	\N
5e8ce8df-59fe-499b-9d2b-8a36e521323c	976f19b3-8283-4bf1-84bc-bc7eaeb09d25	C	$\\ce{N2(g) + 3H2(g) = 2NH3(g)}$	2	\N
8531108b-1afd-4187-ab55-7ed6a6aaf017	976f19b3-8283-4bf1-84bc-bc7eaeb09d25	D	$\\ce{2SO3(g) = 2SO2(g) + O2(g)}$	3	\N
ef67519b-4803-4745-8b35-06b6af54c305	2a38065a-9145-4fec-a7d9-01b7f1c55f82	A	$\\frac{1}{2}$	0	\N
8b590898-6aef-4d12-bd62-d494bcda7a84	2a38065a-9145-4fec-a7d9-01b7f1c55f82	B	$3$	1	\N
a30be0f7-eb1b-4f9b-a055-21f751f8014a	2a38065a-9145-4fec-a7d9-01b7f1c55f82	C	$1$	2	\N
a404d346-700e-49ee-985c-dea1d37c87a6	2a38065a-9145-4fec-a7d9-01b7f1c55f82	D	$-3$	3	\N
d0d0dcd8-cb4b-4378-b569-a6268eba20bc	4fe12ae0-7d60-4acb-8993-3e1433dd7597	A	$15$	0	\N
b1b4e7ff-bdfd-495b-8e80-d9392cc466f3	4fe12ae0-7d60-4acb-8993-3e1433dd7597	B	$\\frac{2}{9}$	1	\N
f7dfe8c7-3ccb-4a97-b027-839e132bb25f	4fe12ae0-7d60-4acb-8993-3e1433dd7597	C	$1$	2	\N
0b0a69d1-0fb2-40a4-b916-eab6415477e9	4fe12ae0-7d60-4acb-8993-3e1433dd7597	D	$25$	3	\N
0566b2e0-9c04-42a1-89f0-219b67ef5626	9bc067b9-4270-4234-8748-7386739d0d7f	A	$\\frac{1}{\\sqrt{3}}$	0	\N
23c58b10-7656-4821-9577-0d8e6c02fccc	9bc067b9-4270-4234-8748-7386739d0d7f	B	$\\frac{1}{\\sqrt{2}}$	1	\N
d011982f-5323-4b04-ae38-691f2976ea17	9bc067b9-4270-4234-8748-7386739d0d7f	C	$\\frac{2}{\\sqrt{3}}$	2	\N
4982679c-2bec-4521-94ce-f91af4719e1c	9bc067b9-4270-4234-8748-7386739d0d7f	D	$\\frac{2}{3}$	3	\N
22f10bbe-d031-41e3-91f7-bb6eba9f322a	a958569f-32fe-46d5-9bd9-676fa92f39ba	A	$0$	0	\N
280e4fb0-535d-46cd-992f-6fcc7b5c8c30	a958569f-32fe-46d5-9bd9-676fa92f39ba	B	$-1$	1	\N
3cdd4fce-1348-4b0b-9581-49674924336f	a958569f-32fe-46d5-9bd9-676fa92f39ba	C	$2$	2	\N
0b298e12-f13b-4015-ba16-54d5eb772e4e	a958569f-32fe-46d5-9bd9-676fa92f39ba	D	$1$	3	\N
262472bb-c230-4b07-bb82-5de82904ffeb	91e8a796-bdb3-4b28-8f5e-573eaf629d1e	A	$135^\\circ$	0	\N
e9fce8f8-abdd-46f1-9f26-add8b98fdac1	91e8a796-bdb3-4b28-8f5e-573eaf629d1e	B	$45^\\circ$	1	\N
4c55268c-cdf8-482d-87c9-f60cf871dbcc	91e8a796-bdb3-4b28-8f5e-573eaf629d1e	C	$225^\\circ$	2	\N
d01abe18-4c34-44a4-a1d0-926382f851cb	91e8a796-bdb3-4b28-8f5e-573eaf629d1e	D	$90^\\circ$	3	\N
a268d84e-3d6a-4243-9dc7-4d0df658eec1	d7f81656-4ebe-4f48-8eb2-571d40e72f47	A	$a^2 - 4b = 0$	0	\N
ba5c6608-3c7b-46bc-b9d2-f2e303d5687a	d7f81656-4ebe-4f48-8eb2-571d40e72f47	B	$b^2 - 4a = 0$	1	\N
f09a68a2-2f91-45b1-9f87-aa62a61b7dad	d7f81656-4ebe-4f48-8eb2-571d40e72f47	C	$b^2 + 4a = 0$	2	\N
c99356cf-7070-4154-aeee-c4bfa289d7aa	d7f81656-4ebe-4f48-8eb2-571d40e72f47	D	$a^2 + 4b = 0$	3	\N
83ab7128-9531-4c6c-b78f-97a59691a95a	8442c1ae-8af4-4f4c-bf2e-2e1c677651cb	A	$8, -30$	0	\N
4ab01ed8-819d-4e88-8fc2-b9e369fc0abd	8442c1ae-8af4-4f4c-bf2e-2e1c677651cb	B	$-8, 30$	1	\N
e4403c1e-75ba-4601-bc5f-dc2bddaf5b65	8442c1ae-8af4-4f4c-bf2e-2e1c677651cb	C	$-10, 40$	2	\N
8ee97112-1663-4076-8be2-d9e5257e1f67	8442c1ae-8af4-4f4c-bf2e-2e1c677651cb	D	$10, -40$	3	\N
cbce9e14-c5d6-4f3c-8336-ef71dc735e5f	d9c63a71-5c7c-46cc-bfbb-80c8d08a6aef	A	$(-\\infty, 0)$	0	\N
6e61c133-4740-487e-9d95-6911b77b5de7	d9c63a71-5c7c-46cc-bfbb-80c8d08a6aef	B	$(-1, 1)$	1	\N
a55ccc50-5b06-412e-9a9c-2ec631b49d7d	d9c63a71-5c7c-46cc-bfbb-80c8d08a6aef	C	$(0, \\infty)$	2	\N
1e2fc8f7-2476-400c-99fc-8b0d1c0ed8c4	d9c63a71-5c7c-46cc-bfbb-80c8d08a6aef	D	$(-1, \\infty)$	3	\N
b0bd72c0-bc11-4184-abf0-328305d67a49	8a09e10c-661b-4dc2-b8f3-aa7caa3b4491	A	$(-1, 0)$	0	\N
49a94662-ae04-4b68-9219-e228dca59bb7	8a09e10c-661b-4dc2-b8f3-aa7caa3b4491	B	$(-c, 0)$	1	\N
7fb8c268-e891-45f1-b948-5915ecc40262	8a09e10c-661b-4dc2-b8f3-aa7caa3b4491	C	$(c, -c)$	2	\N
2a468e67-75fb-45b8-add6-7672d774dff2	8a09e10c-661b-4dc2-b8f3-aa7caa3b4491	D	$(-c, c)$	3	\N
c18dc3b6-31d4-458b-bf9f-ca8ff875c162	84dc9e5e-4d44-4a78-ab10-fd9be21b5286	A	$(3, 1)$	0	\N
722f67b3-c1fc-490d-a40f-099ba5664797	84dc9e5e-4d44-4a78-ab10-fd9be21b5286	B	$(3, 0)$	1	\N
65078358-7176-4234-b46a-8221da2ec5d4	84dc9e5e-4d44-4a78-ab10-fd9be21b5286	C	$(-1, 1)$	2	\N
03ed8ae8-ce5d-4d06-ae98-bd36921f9e5f	84dc9e5e-4d44-4a78-ab10-fd9be21b5286	D	$(2, 0)$	3	\N
938535dd-ff85-46cb-b78d-a02191678160	5de2a6c8-5daf-4557-a702-ad17cef4807f	A	$(-4, 0), (2, 0)$	0	\N
d42fbf48-bee4-44e1-9806-b9fbb56dc57b	5de2a6c8-5daf-4557-a702-ad17cef4807f	B	$(0, 4), (0, 2)$	1	\N
c2176a54-2315-46be-bb2d-0dba8a82258d	5de2a6c8-5daf-4557-a702-ad17cef4807f	C	$(0, -4), (0, -1)$	2	\N
59665990-4e17-4285-ad36-40ef09e5fa4b	5de2a6c8-5daf-4557-a702-ad17cef4807f	D	$(4, 0), (-2, 0)$	3	\N
e7c456a1-c485-4492-ac70-763fa639be75	87282edf-d675-42ea-8f03-ec8e09031ebf	A	$1$	0	\N
313941a2-b7ac-4c06-af03-86a45c825da9	87282edf-d675-42ea-8f03-ec8e09031ebf	B	$-1$	1	\N
6c663879-a6ab-4b91-b87a-313cbe8f85b4	87282edf-d675-42ea-8f03-ec8e09031ebf	C	$0$	2	\N
cc44d7c2-7df2-473a-bca3-90e72c93db41	87282edf-d675-42ea-8f03-ec8e09031ebf	D	$-\\frac{1}{2}$	3	\N
6d864ec9-8571-4987-9268-0338f77a16c5	a71e6d04-65d2-4501-b36e-e3972c5433c6	A	$y = \\cos^{-1}x$	0	\N
37ef1db3-aa11-4d25-9234-78a063c521e2	a71e6d04-65d2-4501-b36e-e3972c5433c6	B	$y = (\\cos^{-1}x)^2$	1	\N
6a2985d2-e715-4f0e-a0dc-3282599de8f6	a71e6d04-65d2-4501-b36e-e3972c5433c6	C	$y = \\sin^{-1}x$	2	\N
c4b2d175-d0ef-4d22-8115-c2095c8dc3ae	a71e6d04-65d2-4501-b36e-e3972c5433c6	D	$y = \\tan^{-1}x$	3	\N
c5460592-869d-4895-8c74-6c37a8edd57e	1b0029c4-1cbe-42bf-8d58-65f2ca53bfd1	A	$(4, 14)$	0	\N
3bc1b898-2b02-4d81-88c2-dc582fd3030c	1b0029c4-1cbe-42bf-8d58-65f2ca53bfd1	B	$(-10, 4)$	1	\N
3f99804b-1919-4fd8-87b5-8cc601f4d213	1b0029c4-1cbe-42bf-8d58-65f2ca53bfd1	C	$(14, 4)$	2	\N
2a004548-3863-4c82-a1b0-c616687e660b	1b0029c4-1cbe-42bf-8d58-65f2ca53bfd1	D	$(4, -10)$	3	\N
ac1f35b7-6e7a-4025-bdc4-e64a36e5dbdd	717a93bf-59cc-4db8-b817-682d44652d82	A	$3$	0	\N
5f016b81-3801-463e-a35b-6ea87185f2ea	717a93bf-59cc-4db8-b817-682d44652d82	B	$0$	1	\N
95568e8e-404a-46e8-bf8a-ec74aead74f5	717a93bf-59cc-4db8-b817-682d44652d82	C	$1$	2	\N
f2df0f71-0d76-4c03-8116-e9f8731789b3	717a93bf-59cc-4db8-b817-682d44652d82	D	$6$	3	\N
435ddf7c-7908-4f4b-bda7-41c12003da26	3fd1caba-78b3-459a-b77b-f07a40517c39	A	রাইবোসোম	0	\N
7e10f1b2-85a9-4d21-8522-9d86de5cf28d	3fd1caba-78b3-459a-b77b-f07a40517c39	B	প্লাস্টিড	1	\N
438dbc42-b198-4599-9c43-d28218848ba2	3fd1caba-78b3-459a-b77b-f07a40517c39	C	মাইটোকন্ড্রিয়া	2	\N
10934535-2d3d-4d18-b6cc-cf89a6afa77d	3fd1caba-78b3-459a-b77b-f07a40517c39	D	গলগি বডি	3	\N
0fc0a8c7-b172-4645-877f-1f4dbfc60ffd	b35dd373-995f-443c-9e34-caab29ac5108	A	ব্যাপন	0	\N
d6a3976f-2e83-4704-9f65-c71a7f24e6cf	b35dd373-995f-443c-9e34-caab29ac5108	B	ইমবাইবিশন	1	\N
5668280f-62bf-4961-906f-ace027d0ddc4	b35dd373-995f-443c-9e34-caab29ac5108	C	অভিস্রবণ	2	\N
bac262b6-3a2f-4475-b93d-f0a5b49618f1	b35dd373-995f-443c-9e34-caab29ac5108	D	প্রস্বেদন	3	\N
1f486471-27a8-451a-9d9c-d4c92c892236	9f8271df-56fc-4c02-a839-087e284eb9be	A	থাইলাকয়েডে	0	\N
6909e915-5ae5-4c9e-8999-486b86e313f5	9f8271df-56fc-4c02-a839-087e284eb9be	B	স্ট্রোমায়	1	\N
8ce45753-6cc3-4af6-9397-4a9d8678e627	9f8271df-56fc-4c02-a839-087e284eb9be	C	গ্রানায়	2	\N
1e489df2-fa95-41f4-a7a9-f91ab724d996	9f8271df-56fc-4c02-a839-087e284eb9be	D	সাইটোপ্লাজমে	3	\N
a7c16403-3c9f-40f7-b756-35e1bc7ed92a	facd3e6e-d556-4874-96de-0f6b23430a44	A	গলগি বডি	0	\N
773b90db-4448-4627-9985-c10b9a0d63cf	facd3e6e-d556-4874-96de-0f6b23430a44	B	রাইবোসোম	1	\N
f0086bed-5556-4004-88c7-f1e30b650412	facd3e6e-d556-4874-96de-0f6b23430a44	C	নিউক্লিয়াস	2	\N
1c6b31f5-2eea-4269-a181-70b96e9ded4b	facd3e6e-d556-4874-96de-0f6b23430a44	D	মাইটোকন্ড্রিয়া	3	\N
99c959c0-dbf8-440b-bcae-9e0908b80994	d5167ccb-684c-491a-8aab-56ae7dffd07e	A	ফলে	0	\N
968aaf7b-d0af-4043-887d-73f446e1e8f6	d5167ccb-684c-491a-8aab-56ae7dffd07e	B	এন্ডোস্পার্মে	1	\N
ef33581f-a793-4b54-b3a6-f84e7b31074e	d5167ccb-684c-491a-8aab-56ae7dffd07e	C	বীজে	2	\N
918f1d38-a414-40bc-87cd-41b08a55b652	d5167ccb-684c-491a-8aab-56ae7dffd07e	D	ভ্রূণত্বকে	3	\N
9adce002-2357-42be-9dde-78a6c53d8d55	4efde473-3e55-4fd6-82e0-b5309b1487f9	A	২ অণু	0	\N
2b05e196-3efa-43e2-8bf1-b6a6572f8bba	4efde473-3e55-4fd6-82e0-b5309b1487f9	B	৪ অণু	1	\N
42f67452-79c2-4cf6-817d-6434f7a7361d	4efde473-3e55-4fd6-82e0-b5309b1487f9	C	৬ অণু	2	\N
eb3e696b-903f-4b01-93c6-721c70b9c3a6	4efde473-3e55-4fd6-82e0-b5309b1487f9	D	৮ অণু	3	\N
76e5c593-abd2-408d-b7d5-23065c2df3a6	61e6946a-6297-4c71-9da5-6b95394f89c4	A	সঙ্গী কোষ	0	\N
2b200c0f-43c4-42ce-a572-1210cbec1991	61e6946a-6297-4c71-9da5-6b95394f89c4	B	ফ্লোয়েম ফাইবার	1	\N
ff1316b5-c1f5-43c6-9be4-058676e508e7	61e6946a-6297-4c71-9da5-6b95394f89c4	C	ফ্লোয়েম প্যারেনকাইমা	2	\N
1c961bfb-ccfe-4c44-b66b-47b211803b1d	61e6946a-6297-4c71-9da5-6b95394f89c4	D	সীভনল	3	\N
d1b3bc34-a2de-49b9-af06-87dee0b10142	3eaa3286-1150-4a8c-85d5-2bd354b2a144	A	জাইগোটিনে	0	\N
a27ab00a-39fb-4ea5-aed1-d9ea2721d95c	3eaa3286-1150-4a8c-85d5-2bd354b2a144	B	লেপ্টোটিনে	1	\N
11f34589-ab24-4c6c-8cd3-61f2aadba958	3eaa3286-1150-4a8c-85d5-2bd354b2a144	C	প্যাকাইটিনে	2	\N
80957f99-f015-4feb-86ca-8bfa160f5b49	3eaa3286-1150-4a8c-85d5-2bd354b2a144	D	ডিপ্লোটিনে	3	\N
dccd83f8-9ffb-4498-8860-eff018854f09	33200c93-c9fb-488b-8e23-64fe95ebce57	A	Annelida	0	\N
3e885f44-b1d8-4775-b41c-c0ae23afe3e7	33200c93-c9fb-488b-8e23-64fe95ebce57	B	Arthropoda	1	\N
6283ea62-63b7-48ef-b555-a05df2e2cda9	33200c93-c9fb-488b-8e23-64fe95ebce57	C	Mollusca	2	\N
cd9ca9b2-ed71-4a7a-b701-3264fd180d54	33200c93-c9fb-488b-8e23-64fe95ebce57	D	Nematoda	3	\N
78ad2864-3709-4d4c-8579-75586c968452	646acc68-6f4a-45cc-a32a-96895be5afcd	A	গ্লোবিউলিন	0	\N
58e2b49a-0de5-4655-867f-3394227cd560	646acc68-6f4a-45cc-a32a-96895be5afcd	B	ইনসুলিন	1	\N
6812ec02-5e3a-4e6c-81ac-6eaf33ec9249	646acc68-6f4a-45cc-a32a-96895be5afcd	C	হিম	2	\N
4a7dd1d1-3f66-4eb1-8112-86c71a958ba2	646acc68-6f4a-45cc-a32a-96895be5afcd	D	অ্যালবুমিন	3	\N
3a0ddbb4-cbb6-4642-903a-f4a91f83c83a	c0ac03a5-7de1-4297-8fbd-45f75d760c81	A	১০টি	0	\N
6ba24d93-0bc8-4e7f-8d9c-4736447ace97	c0ac03a5-7de1-4297-8fbd-45f75d760c81	B	২০টি	1	\N
06149eda-e8cb-4363-a679-aad7ad9372ba	c0ac03a5-7de1-4297-8fbd-45f75d760c81	C	৩০টি	2	\N
07b70a00-bd61-485c-a3bf-3d0ff7ceae2c	c0ac03a5-7de1-4297-8fbd-45f75d760c81	D	৪০টি	3	\N
96bdfa0a-02a3-4a60-abb7-4cbeffe08489	5680e052-c6e0-4065-af61-d3aff60c0cb7	A	মুকুলোদগম	0	\N
c33051e5-c414-4946-965a-a99c5d2a59b1	5680e052-c6e0-4065-af61-d3aff60c0cb7	B	বিভাজন	1	\N
bc6ea21d-70a7-4311-9988-8495e224f0c3	5680e052-c6e0-4065-af61-d3aff60c0cb7	C	স্পোরুলেশন	2	\N
06d6a855-2961-4b69-a829-4d3d976ea98d	5680e052-c6e0-4065-af61-d3aff60c0cb7	D	যৌন জনন	3	\N
297f4c26-c925-498d-957c-cbde37d7723a	c4e56762-c3ea-4674-966a-aa3d50014286	A	এপিডার্মিস, স্নায়ুতন্ত্র	0	\N
19a140fb-410c-4cf1-b589-4aa83dee679b	c4e56762-c3ea-4674-966a-aa3d50014286	B	কঙ্কালতন্ত্র, রক্ত সংবহনতন্ত্র	1	\N
c81889fd-2d4c-487b-a601-45763cf2443c	c4e56762-c3ea-4674-966a-aa3d50014286	C	পৌষ্টিকতন্ত্র, শ্বসনতন্ত্র	2	\N
d99db45e-7dd7-4df6-9b76-810a3b101b96	c4e56762-c3ea-4674-966a-aa3d50014286	D	এপিডার্মিস, পেশিতন্ত্র	3	\N
4083b702-adeb-41a3-8f4d-873c5f14ea2b	3a707285-340f-4d27-93e9-74d6518b576d	A	প্লীহা	0	\N
cd690521-b89a-4618-92a8-20e7caa4b8d6	3a707285-340f-4d27-93e9-74d6518b576d	B	মস্তিষ্ক	1	\N
0fe3c565-1fdb-46e2-a380-d4aea11c8249	3a707285-340f-4d27-93e9-74d6518b576d	C	যকৃৎ	2	\N
38229c3d-8402-4b90-b9eb-32f08eea4967	3a707285-340f-4d27-93e9-74d6518b576d	D	অগ্ন্যাশয়	3	\N
8b92513a-a3c4-4517-8c08-16fb3716ae20	49e3db7d-64cb-4d80-b4af-268750ca2b04	A	লোহিত রক্তকণিকা	0	\N
fb93ba14-4c5b-4f18-a4f2-9de74783e585	49e3db7d-64cb-4d80-b4af-268750ca2b04	B	শ্বেত রক্তকণিকা	1	\N
0d30c0d5-25d1-45af-af79-9ef14c39d79f	49e3db7d-64cb-4d80-b4af-268750ca2b04	C	স্নায়ুকোষ	2	\N
5b2ba0a1-f03b-4299-9eb2-9364f0adf980	49e3db7d-64cb-4d80-b4af-268750ca2b04	D	হৃদকোষ	3	\N
514657d8-3933-424f-803c-c3fb63db58f5	c44fab2b-eb92-4719-9d96-23dfbfe38b22	A	$C_v = (x - 1)R$	0	\N
972cfed9-d341-436b-a5d5-a8261dd208de	c44fab2b-eb92-4719-9d96-23dfbfe38b22	B	$C_v = \\frac{R}{(x - 1)}$	1	\N
04d019e9-86f0-469d-a380-da570f90f996	c44fab2b-eb92-4719-9d96-23dfbfe38b22	C	$C_v = \\frac{R}{(1 - x)}$	2	\N
398ebcd8-218e-4499-b60e-14c5680a5f25	c44fab2b-eb92-4719-9d96-23dfbfe38b22	D	$C_v = \\frac{R}{(1 + x)}$	3	\N
033f82b2-db54-4a3a-82b3-e7da336bc06f	759721fb-6efd-4fa0-873f-994c91fafae6	A	$\\text{m}^2 \\text{s}^{-2}$	0	\N
6f662c53-89ef-4a7c-b477-d3bfdb9f9a25	759721fb-6efd-4fa0-873f-994c91fafae6	B	$\\text{m}^2 \\text{s}^{-\\frac{1}{2}}$	1	\N
d5fe1ed9-5557-4b61-9e32-f46d46113879	759721fb-6efd-4fa0-873f-994c91fafae6	C	$\\text{m}^{-1} \\text{s}$	2	\N
f074a9e8-2a40-48f9-a7d6-706d410db83d	759721fb-6efd-4fa0-873f-994c91fafae6	D	$\\text{m}^{-2} \\text{s}^2$	3	\N
f57f6343-5acc-4676-9607-2bb81d893a60	2e1e2c65-8558-43dd-afec-c2d333b2aa14	A	$M$	0	\N
253a5242-a43a-4183-8a41-2f408c41987a	2e1e2c65-8558-43dd-afec-c2d333b2aa14	B	$\\sqrt{m}$	1	\N
4479b918-66ab-4237-8a6f-f18a6bb06475	2e1e2c65-8558-43dd-afec-c2d333b2aa14	C	$R^{\\frac{3}{2}}$	2	\N
458167dc-eed4-4aa8-92f5-202311d7e3e3	2e1e2c65-8558-43dd-afec-c2d333b2aa14	D	$R^2$	3	\N
dbfd1d65-ff54-4628-8db7-106a490a5252	0d9953e6-403e-4dfe-8d1b-81061084d971	A	$t^2$	0	\N
c421e068-38fc-4131-b8a7-382c65b7ec6b	0d9953e6-403e-4dfe-8d1b-81061084d971	B	$t^3$	1	\N
f9ff843d-eb5b-4858-b1eb-4663ed7d793f	0d9953e6-403e-4dfe-8d1b-81061084d971	C	$\\sqrt{t}$	2	\N
cf7f0e3d-d99d-4c47-945a-f03153b4694e	0d9953e6-403e-4dfe-8d1b-81061084d971	D	$t^4$	3	\N
e8f3f64a-5585-42ca-b478-9e86b90efae2	cf3b2c91-ad6f-4dd1-8e75-00f30732f932	A	$\\frac{q}{4\\pi\\epsilon_0 r^2}$	0	\N
41d1b2d3-8337-4f84-a339-99d3ccaada11	cf3b2c91-ad6f-4dd1-8e75-00f30732f932	B	$\\frac{q^2}{4\\pi\\epsilon_0 r^2}$	1	\N
202edf2c-46ad-4150-861b-85a29b9e2551	cf3b2c91-ad6f-4dd1-8e75-00f30732f932	C	$0$	2	\N
4c6924ff-41f6-4e92-ab35-2a873ba065aa	cf3b2c91-ad6f-4dd1-8e75-00f30732f932	D	$\\frac{5q}{4\\pi\\epsilon_0 r^2}$	3	\N
af7b93f3-8602-4d02-9eab-139198a6b45e	3ca8ae1a-6ccf-4d76-bbe9-913a8fc3cd5d	A	$\\frac{1}{3}$	0	\N
6b32f52a-bb49-4c06-be15-41de2a03fee6	3ca8ae1a-6ccf-4d76-bbe9-913a8fc3cd5d	B	$1$	1	\N
4b8db768-b020-4277-bce4-4af3be4f469b	3ca8ae1a-6ccf-4d76-bbe9-913a8fc3cd5d	C	$3$	2	\N
9cbd50f5-7915-4056-b53b-d3484e0ccd5e	3ca8ae1a-6ccf-4d76-bbe9-913a8fc3cd5d	D	$9$	3	\N
a664b470-8542-4f3b-964c-cf544118e12e	0d6a324b-4f00-466e-9db4-a00dca497c99	A	$\\hat{i} - 2\\hat{k}$	0	\N
07ecc590-7af9-47e3-bbd4-9500a0549762	0d6a324b-4f00-466e-9db4-a00dca497c99	B	$3\\hat{i} - 6\\hat{k}$	1	\N
b972265e-d18e-4ea1-ba33-0e2ddb5b85e7	0d6a324b-4f00-466e-9db4-a00dca497c99	C	$\\frac{-3(\\hat{i} + 2\\hat{k})}{\\sqrt{45}}$	2	\N
0307fdb7-3259-4e97-a374-bd9c8bd2ace9	0d6a324b-4f00-466e-9db4-a00dca497c99	D	$\\frac{-3(\\hat{i} - 2\\hat{k})}{\\sqrt{45}}$	3	\N
e1ba1234-7fb0-489d-bf67-52ec89fb61a2	225e280b-313c-45c5-ac01-002865223dfe	A	$3\\,\\text{cm}$	0	\N
cadcb874-2915-4c67-8283-474712342273	225e280b-313c-45c5-ac01-002865223dfe	B	$1\\,\\text{cm}$	1	\N
012adbac-b67a-498b-844e-c33c5746c415	225e280b-313c-45c5-ac01-002865223dfe	C	$2\\,\\text{cm}$	2	\N
6bc60520-cbdb-4899-9abf-eec04722ed7d	225e280b-313c-45c5-ac01-002865223dfe	D	$4\\,\\text{cm}$	3	\N
fd8f7f32-638c-4366-bac5-8b8d3a0acf12	52357405-5abf-4f44-98ff-230d83a1da72	A	পীড়ন	0	\N
fa4313a3-01c0-4702-8d1e-9c63e4f36a38	52357405-5abf-4f44-98ff-230d83a1da72	B	ইয়াং-এর গুণাঙ্ক	1	\N
4ff44aa1-2d56-46ba-a882-1a608760745f	52357405-5abf-4f44-98ff-230d83a1da72	C	বিকৃতি	2	\N
3fa8aa73-f655-45e8-9174-51e331f4faba	52357405-5abf-4f44-98ff-230d83a1da72	D	চাপ	3	\N
c8ad2869-5dd2-4f6c-b431-80131d80f069	49fe07e4-d291-4f8f-b4f9-0fc162ad8553	A	$2\\lambda$	0	\N
5c5305cd-ea15-43cc-a695-79cb7b397a96	49fe07e4-d291-4f8f-b4f9-0fc162ad8553	B	$\\lambda$	1	\N
b28ad0ce-8ace-4917-a90a-a840281d5363	49fe07e4-d291-4f8f-b4f9-0fc162ad8553	C	$\\frac{\\lambda}{2}$	2	\N
5c20dea9-c5e3-4433-b98f-bcf1aae067a9	49fe07e4-d291-4f8f-b4f9-0fc162ad8553	D	$\\frac{\\lambda}{4}$	3	\N
45f86b0f-cac0-4487-914e-9cb3cb4f61ea	4c87010d-60fd-4686-8d7a-0b11ad5aa2d8	A	$2000\\,\\text{J}$	0	\N
378319c2-c6bb-43c6-bcb4-d7ce72cb57e4	4c87010d-60fd-4686-8d7a-0b11ad5aa2d8	B	$1500\\,\\text{J}$	1	\N
38951f79-1d8e-4e85-8360-45eefa068aca	4c87010d-60fd-4686-8d7a-0b11ad5aa2d8	C	$500\\,\\text{J}$	2	\N
f3cc593a-6a2a-44f0-bd97-a9403b0c3567	4c87010d-60fd-4686-8d7a-0b11ad5aa2d8	D	$1000\\,\\text{J}$	3	\N
258c818f-2c8c-40e8-b657-573592674b48	9b17131f-11a6-4ea3-a6bb-38b56357e858	A	OR gate	0	\N
a5d99dd9-d59f-4e6f-9749-fa9812b0a9ca	9b17131f-11a6-4ea3-a6bb-38b56357e858	B	AND gate, OR gate, and NOT gate	1	\N
563912d6-50c7-41f7-9f1d-133c07504fc3	9b17131f-11a6-4ea3-a6bb-38b56357e858	C	AND gate and NOT gate	2	\N
ebf91f25-04e5-4192-9d0f-d1f69f8f64b1	9b17131f-11a6-4ea3-a6bb-38b56357e858	D	OR gate and NOT gate	3	\N
a72f8370-10d5-49b6-8e08-089969f8ef0f	fad7afa2-b0be-4bfd-ad77-992dd800cac6	A	$3d$	0	\N
14f06127-393d-478e-bcd9-4b736502af51	fad7afa2-b0be-4bfd-ad77-992dd800cac6	B	$9d$	1	\N
12b472fd-9cfa-4348-8898-443dcc6ab1a0	fad7afa2-b0be-4bfd-ad77-992dd800cac6	C	$\\frac{d}{3}$	2	\N
6132d474-7b5a-41a4-a740-f40ab751ae8d	fad7afa2-b0be-4bfd-ad77-992dd800cac6	D	$\\frac{d}{9}$	3	\N
87a9d650-2541-4834-a10b-d180e914a194	93402563-6af3-45ec-9de0-aede8c8fb6b0	A	$0.866\\,c$	0	\N
0ac34721-196f-43b9-b8ae-654bfb42c881	93402563-6af3-45ec-9de0-aede8c8fb6b0	B	$0.333\\,c$	1	\N
7899738f-3e8d-4d64-9abc-cda842408480	93402563-6af3-45ec-9de0-aede8c8fb6b0	C	$0.5\\,c$	2	\N
73ca50b3-b5bf-4214-9ed9-87e4f8024187	93402563-6af3-45ec-9de0-aede8c8fb6b0	D	$0.6\\,c$	3	\N
04dcc4bf-320e-4a40-bd08-f9cfb8b2000d	38f811fb-1c5b-48db-878a-e7492dac0d62	A	$-28\\,\\text{N}$	0	\N
d612b2d2-5855-43f0-8a7d-fd1d3fcd7f2e	38f811fb-1c5b-48db-878a-e7492dac0d62	B	$-14\\,\\text{N}$	1	\N
2b07ade2-212c-4b3b-ae99-7ea188750f01	38f811fb-1c5b-48db-878a-e7492dac0d62	C	$8\\,\\text{N}$	2	\N
0ba336ef-adad-4f9d-a6f8-ee351fa68a1b	38f811fb-1c5b-48db-878a-e7492dac0d62	D	$36\\,\\text{N}$	3	\N
813262c5-2ed8-4f21-a4cb-91a923805426	a9f84a82-da97-41da-a3d9-246cbccaa838	A	$\\ce{N2}$	0	\N
262abbe1-dce5-4b4c-a781-230ca4b9bd1d	a9f84a82-da97-41da-a3d9-246cbccaa838	B	$\\ce{H2}$	1	\N
729e91cd-e1b7-414f-b7ab-67b739b3329d	a9f84a82-da97-41da-a3d9-246cbccaa838	C	$\\ce{He}$	2	\N
3ee5f6fc-2d0f-4ecd-8888-f39df77c066d	a9f84a82-da97-41da-a3d9-246cbccaa838	D	$\\ce{O2}$	3	\N
90931d1b-e9b4-41e7-aa6a-1d3a6ed2c68e	d7872880-5ece-499d-b527-b4796e248d34	A	$\\ce{^{\\oplus}CH3}$	0	\N
a27128f2-22f2-4899-8be7-d751bf9083f4	d7872880-5ece-499d-b527-b4796e248d34	B	$\\ce{(CH3)2^{\\oplus}CH}$	1	\N
ce7bbbe0-444c-49c6-9e0f-8f81d74dd2f8	d7872880-5ece-499d-b527-b4796e248d34	C	$\\ce{H2C^{\\oplus}CH3}$	2	\N
76c749f0-e0bb-4f27-a733-428b71d2b3c7	d7872880-5ece-499d-b527-b4796e248d34	D	$\\ce{(CH3)3C^{\\oplus}}$	3	\N
b5febb31-ab23-443f-aea1-a288be1c6cf2	47a28298-905c-452d-b080-4d3afd9c77c2	A	$-2, +1$ and $0$	0	\N
e9ab5704-625b-422f-98b1-3c291a76a681	47a28298-905c-452d-b080-4d3afd9c77c2	B	$+1, -1$ and $0$	1	\N
ce4b5330-af53-4edc-93d7-a71c507064a7	47a28298-905c-452d-b080-4d3afd9c77c2	C	$-1, +1$ and $0$	2	\N
c0f75d79-1e03-456b-b7c6-8221126da084	47a28298-905c-452d-b080-4d3afd9c77c2	D	$+2, -1$ and $0$	3	\N
94ed82a6-ff9e-46aa-a5a0-c65bf02645aa	9e3646cf-4bf6-4dd6-b359-0e515a1f09c6	A	$5\\,^{\\circ}\\text{C}$ এ কার্বন মনোক্সাইড	0	\N
02aeab1e-2f96-4b94-8d2b-0619bf79ce64	9e3646cf-4bf6-4dd6-b359-0e515a1f09c6	B	$35\\,^{\\circ}\\text{C}$ এ কার্বন মনোক্সাইড	1	\N
f675d6ee-8fdf-4dce-9adf-cd0f70e50e81	9e3646cf-4bf6-4dd6-b359-0e515a1f09c6	C	$5\\,^{\\circ}\\text{C}$ এ নিয়ন	2	\N
62da220b-d02a-4d68-8852-0a71f8e3a291	9e3646cf-4bf6-4dd6-b359-0e515a1f09c6	D	$35\\,^{\\circ}\\text{C}$ এ নিয়ন	3	\N
53370f7e-815f-48e8-8ab2-9ea0c257be91	aa4ed04d-dabb-43ca-bef3-b8dc056cd245	A	$\\ce{C6H5CHBrCl}$	0	\N
2dc836bf-2cde-4891-a8c3-18cfc23f56b1	aa4ed04d-dabb-43ca-bef3-b8dc056cd245	B	$\\ce{ClCH=CHCl}$	1	\N
cf4c922d-2c81-466d-aca2-ce501e17753d	aa4ed04d-dabb-43ca-bef3-b8dc056cd245	C	$\\ce{CH2=CH2}$	2	\N
0df83502-65cb-455a-a09d-c3d37914a6cf	aa4ed04d-dabb-43ca-bef3-b8dc056cd245	D	$\\ce{CH3CH(OH)COOH}$	3	\N
6f2a2521-e725-4c05-b772-8b30489d7a8f	9c2b7680-c00f-42c7-97bd-ff7a6be4d96c	A	বেনজিন	0	\N
05740127-14fc-40ac-884b-ce5005e4f172	9c2b7680-c00f-42c7-97bd-ff7a6be4d96c	B	বেনজোয়িক অ্যাসিড	1	\N
aae61825-f775-4fc2-88d6-1eb6a56c17e7	9c2b7680-c00f-42c7-97bd-ff7a6be4d96c	C	টলুইন	2	\N
1f43c4f6-192a-4136-bf49-0d28b3acdb4c	9c2b7680-c00f-42c7-97bd-ff7a6be4d96c	D	ইথেন	3	\N
d689c9ec-c2f3-48e2-96c6-e9b091883ed8	95f0d1ec-d2f9-45ee-b3e2-a86de850e0ee	A	$\\ce{NO}$	0	\N
81e9548f-657f-41be-92c0-de83dcef81a4	95f0d1ec-d2f9-45ee-b3e2-a86de850e0ee	B	$\\ce{O3}$	1	\N
98db18ee-2541-4334-898b-aff32800bf98	95f0d1ec-d2f9-45ee-b3e2-a86de850e0ee	C	$\\ce{ClO}$	2	\N
d6bc2e99-865e-4d5e-963e-8ccfb03e350b	95f0d1ec-d2f9-45ee-b3e2-a86de850e0ee	D	$\\ce{N3^-}$	3	\N
d81434db-a0ee-426e-8353-413e9c292eb5	028d89d9-6378-4d7b-b939-154744a0ee83	A	$\\ce{NaOH}$	0	\N
526cb2ea-1449-4f64-adca-85c44de22c87	028d89d9-6378-4d7b-b939-154744a0ee83	B	$\\ce{K4[Fe(CN)6]}$	1	\N
28ba3c59-7532-4401-a4a8-fadebfd83c98	028d89d9-6378-4d7b-b939-154744a0ee83	C	$\\ce{NaOH, K2HgI4}$	2	\N
c39ca197-78b0-4cc1-abe8-867e6158e3e4	028d89d9-6378-4d7b-b939-154744a0ee83	D	$\\ce{(NH4)2C2O4}$	3	\N
03205cff-5547-4b70-968f-290ba556a14c	7de8c5bf-f5e8-4f99-a494-f8cf267eb2b0	A	আর্দ্রবিশ্লেষণ	0	\N
fddcf980-4ed8-4fe7-8fed-b1af2cff25bf	7de8c5bf-f5e8-4f99-a494-f8cf267eb2b0	B	গাঁজন	1	\N
28c2210d-f73a-40ca-9e8c-6ec4a06cc2d9	7de8c5bf-f5e8-4f99-a494-f8cf267eb2b0	C	কোয়াগুলেশন	2	\N
dc42f1df-8d08-4650-9b23-fadb42f3f683	7de8c5bf-f5e8-4f99-a494-f8cf267eb2b0	D	জারণ	3	\N
4fc9396c-4b6c-437b-a80f-a30b39446c8d	658a3d42-fde3-43e6-8be9-a206f94e8be2	A	$\\frac{36R_H}{5}$	0	\N
9f84073c-a98c-455f-83c4-22442b9d10b3	658a3d42-fde3-43e6-8be9-a206f94e8be2	B	$\\frac{16}{3R_H}$	1	\N
2dccde28-4637-4653-8ca1-c9b1f435e483	658a3d42-fde3-43e6-8be9-a206f94e8be2	C	$\\frac{3R_H}{16}$	2	\N
47f6ca9f-5420-438b-b340-93a099bcff1f	658a3d42-fde3-43e6-8be9-a206f94e8be2	D	$\\frac{5}{36R_H}$	3	\N
bbcded90-2240-4ab6-b2ba-2cb3195b2cf4	deb8a1ab-c0bc-4901-806d-14cebe1e7525	A	$50.0\\,\\text{mL}$	0	\N
72b73ada-14aa-4a52-b0ca-fe7044b9ee2b	deb8a1ab-c0bc-4901-806d-14cebe1e7525	B	$25.0\\,\\text{mL}$	1	\N
5b7e23b8-88c8-4cdd-96ca-6505761fa385	deb8a1ab-c0bc-4901-806d-14cebe1e7525	C	$100.0\\,\\text{mL}$	2	\N
f09f3205-c883-48f8-b40e-3990f01ab177	deb8a1ab-c0bc-4901-806d-14cebe1e7525	D	$10.0\\,\\text{mL}$	3	\N
1ecf5ee5-fef2-460b-be43-549b7645b8e8	97feda10-a2dc-4c18-8c53-5fc6219985e0	A	$\\ce{N2(g) + 3H2(g) <=> 2NH3(g)}$	0	\N
09b626cf-9b3a-43d4-a356-8e300acde6f9	97feda10-a2dc-4c18-8c53-5fc6219985e0	B	$\\ce{PCl5(g) <=> PCl3(g) + Cl2(g)}$	1	\N
f0ee1262-afeb-4a3b-9310-32dfc0981bf0	97feda10-a2dc-4c18-8c53-5fc6219985e0	C	$\\ce{I2(g) + H2(g) <=> 2HI(g)}$	2	\N
9a0bc64a-d28b-4d53-b8f9-a7814ce0a23f	97feda10-a2dc-4c18-8c53-5fc6219985e0	D	$\\ce{N2O4(g) <=> 2NO2(g)}$	3	\N
b9d2d3c6-86e7-4112-9d2f-c47252f881a9	9ac37697-f29e-4197-8aa2-9faf9d6697da	A	$-0.04\\,\\text{V}$	0	\N
845b3058-ca74-4e4d-b1fc-5bb67fe5e77d	9ac37697-f29e-4197-8aa2-9faf9d6697da	B	$+0.04\\,\\text{V}$	1	\N
383c0c47-e827-4cc6-b423-a6651a9dbdac	9ac37697-f29e-4197-8aa2-9faf9d6697da	C	$-1.56\\,\\text{V}$	2	\N
98164f86-f3f7-4a44-8529-a2e3965827ac	9ac37697-f29e-4197-8aa2-9faf9d6697da	D	$+1.56\\,\\text{V}$	3	\N
72019a70-b6a4-4b0d-a7b6-bde448364e83	dac10459-32a1-4bc1-8911-4880d1bcb38d	A	$sp^2, sp$	0	\N
e08714c5-41c1-4530-9b47-caeb4b75ba02	dac10459-32a1-4bc1-8911-4880d1bcb38d	B	$sp, sp^3$	1	\N
76282fb1-8000-4fa5-b3a5-c1b2a4ce8c9a	dac10459-32a1-4bc1-8911-4880d1bcb38d	C	$sp^2$	2	\N
84b36780-77a4-4f11-8aa0-c840db031691	dac10459-32a1-4bc1-8911-4880d1bcb38d	D	$sp, sp^2, sp^3$	3	\N
3d15de61-9bba-46f9-baeb-8c326c50b2e9	e8297b4c-eac2-4a04-b3ea-9a6bfc93c9a0	A	$\\ce{H2O}$	0	\N
8033c277-a289-4714-93f0-610b84bd58f9	e8297b4c-eac2-4a04-b3ea-9a6bfc93c9a0	B	$\\ce{H2S}$	1	\N
b5c5f373-9664-480e-958c-fb550c4c547f	e8297b4c-eac2-4a04-b3ea-9a6bfc93c9a0	C	$\\ce{HF}$	2	\N
af7f7317-c5bd-4593-b825-4003a8285e9b	e8297b4c-eac2-4a04-b3ea-9a6bfc93c9a0	D	$\\ce{NH3}$	3	\N
1785ff1a-c5ed-468f-ba2b-e3a814f8f82b	c334d74b-bcce-48df-9e88-ab997ad5e301	A	$\\frac{x^2 + 1}{x^2 - 1}$	0	\N
c8f71b41-b352-4e79-ba87-c413b2e7aacb	c334d74b-bcce-48df-9e88-ab997ad5e301	B	$\\frac{x^2 - 1}{x^2 + 1}$	1	\N
89aee314-5677-48ad-b4f2-913f11e1fa46	c334d74b-bcce-48df-9e88-ab997ad5e301	C	$\\frac{1 - x^2}{1 + x^2}$	2	\N
ac2b17ac-eec7-4bae-97e9-106216c7f63f	c334d74b-bcce-48df-9e88-ab997ad5e301	D	$\\frac{1 + x^2}{1 - x^2}$	3	\N
27f53621-b754-4330-b3e5-e77236ea43fc	ab674125-266b-4810-820d-51e01d9e9fa3	A	$1$	0	\N
19afe660-56c3-41a2-8be1-975b44c2ad2f	ab674125-266b-4810-820d-51e01d9e9fa3	B	$-1$	1	\N
11e297c1-5803-4ae0-aafe-78fc72a646fc	ab674125-266b-4810-820d-51e01d9e9fa3	C	$3$	2	\N
fd3a1e97-25f7-482e-ab77-04fd2da8e099	ab674125-266b-4810-820d-51e01d9e9fa3	D	$-\\frac{1}{2}$	3	\N
1692e0a6-4dca-42b6-88b2-eb7a14c84571	d119de1c-67bf-4122-b253-4faa9095dc9f	A	$x^{-4} \\ln x - 2x^{-2} - 3x^{-4}$	0	\N
86d71cef-6f18-4b4b-bb67-8aacaa33f67a	d119de1c-67bf-4122-b253-4faa9095dc9f	B	$6x^{-4} \\ln x - 5x^{-4}$	1	\N
4812a3d5-b205-453c-a69e-ee3f690a9aee	d119de1c-67bf-4122-b253-4faa9095dc9f	C	$6x^{-4} \\ln x - 2x^{-2} - 3x^{-4}$	2	\N
d9b6acb8-4286-478a-a839-d7c0aa1ddd28	d119de1c-67bf-4122-b253-4faa9095dc9f	D	$x^{-4} \\ln x - 2x^{-2} + 3x^{-4}$	3	\N
c22a4933-589d-4217-90da-2d819f1fe4ca	e3d860a5-7343-43e8-bcb8-ce5805debcf7	A	$\\tan^{-1}(e^{-x})$	0	\N
78423bb2-2ac4-4b7e-8c5c-abac73fc23b5	e3d860a5-7343-43e8-bcb8-ce5805debcf7	B	$\\tan(e^{-x})$	1	\N
f4b91db6-438a-4fca-a842-0ce0f01f40b4	e3d860a5-7343-43e8-bcb8-ce5805debcf7	C	$\\tan^{-1}(e^x)$	2	\N
2bf0ce5f-089e-4e26-a8eb-25adba56f3d0	e3d860a5-7343-43e8-bcb8-ce5805debcf7	D	$\\tan(e^x)$	3	\N
941f2e6d-b54c-4b33-8ed7-53bd11d35593	8777f4e0-13a5-4fd6-aacb-5c1e3b268511	A	$R = \\sqrt{3}H$	0	\N
49b07a16-cf4b-498b-b9da-ea51988a0e4f	8777f4e0-13a5-4fd6-aacb-5c1e3b268511	B	$R = 4H$	1	\N
95f2b5e8-0daf-4ec4-9e03-3179ac728ed6	8777f4e0-13a5-4fd6-aacb-5c1e3b268511	C	$R = 4\\sqrt{3}H$	2	\N
43d47f24-f0d0-47e2-9489-03e2650ba374	8777f4e0-13a5-4fd6-aacb-5c1e3b268511	D	$R = 3\\sqrt{2}H$	3	\N
ae099ef3-d00b-4eb9-bdbc-8967c930df31	d956b3b2-c375-457c-b36d-d7e5eda157db	A	350	0	\N
99cd4624-e8cd-444f-9100-eee3b76ccf22	d956b3b2-c375-457c-b36d-d7e5eda157db	B	10	1	\N
042371f5-4f7b-40bc-9d5f-fbb6610fc99f	d956b3b2-c375-457c-b36d-d7e5eda157db	C	35	2	\N
c8f71e5f-c558-4631-9824-9c706d0fcaf7	d956b3b2-c375-457c-b36d-d7e5eda157db	D	30	3	\N
79c1e6ab-ba4a-4a56-b940-c94a8e57904b	a7efeae1-ef25-439a-aab0-fd931154652f	A	4	0	\N
4a961c37-4770-4451-a569-21ee4c83403b	a7efeae1-ef25-439a-aab0-fd931154652f	B	3	1	\N
bfe69e9c-9ff9-48e9-b3b8-a04f557bd588	a7efeae1-ef25-439a-aab0-fd931154652f	C	5	2	\N
df1adbaf-5bd9-428b-a4aa-cffa2bde3dea	a7efeae1-ef25-439a-aab0-fd931154652f	D	2	3	\N
3cbf1270-0b09-493b-aa2c-94a22654c3fd	a6075742-074a-4d3f-a10c-27b235d9a593	A	$x + 2y + 3 = 0$	0	\N
9b44e7ab-1425-4c02-ade2-3c91cad52200	a6075742-074a-4d3f-a10c-27b235d9a593	B	$x + 2y - 3 = 0$	1	\N
463b52ca-5f6b-4ddb-88a2-01ba04e188af	a6075742-074a-4d3f-a10c-27b235d9a593	C	$x - 2y + 3 = 0$	2	\N
ac8a2580-beae-491d-bc0e-bd47919db7e8	a6075742-074a-4d3f-a10c-27b235d9a593	D	$x - 2y - 3 = 0$	3	\N
75e5e820-aaae-4573-8b3e-5c744e2637ad	53fb9947-7274-403a-9a29-feb6843d137c	A	$[-\\frac{9}{4}, -\\frac{7}{4}], x \\neq -2$	0	\N
11a58329-db56-45db-8d0b-a6f878cce6af	53fb9947-7274-403a-9a29-feb6843d137c	B	$[-\\frac{7}{4}, -\\frac{1}{4}]$	1	\N
d2570ca8-86ce-43bb-96fe-7e4af65dd090	53fb9947-7274-403a-9a29-feb6843d137c	C	$(-\\frac{9}{4}, -\\frac{7}{4}), x \\neq -2$	2	\N
b9c36a19-f8fd-4cf7-8c31-c9b6f8bd0d2b	53fb9947-7274-403a-9a29-feb6843d137c	D	$(-\\frac{7}{4}, \\frac{1}{4})$	3	\N
19ef9c20-eda2-41d8-a572-ddaca37cd6bf	cc0fdd4f-8c40-40bf-8baf-57fa71daf654	A	-1	0	\N
e77b481f-cea3-456a-9d38-aa0a7bd5ed5f	cc0fdd4f-8c40-40bf-8baf-57fa71daf654	B	$\\frac{1}{2}$	1	\N
fd98e817-1b50-4483-a2a5-88f428fdc979	cc0fdd4f-8c40-40bf-8baf-57fa71daf654	C	-2	2	\N
4cd7be84-bb42-47f8-95a8-3213e2652e0b	cc0fdd4f-8c40-40bf-8baf-57fa71daf654	D	2	3	\N
e8dae322-2443-4b74-8844-3da35e735a60	dc249b11-498d-4463-aab4-5802592894ce	A	$\\frac{\\pi}{4}$	0	\N
529821fb-8593-47ea-8a67-30d8fcf383d5	dc249b11-498d-4463-aab4-5802592894ce	B	$\\frac{5\\pi}{3}$	1	\N
eadba28a-01f2-415e-8867-f33b6c228ae6	dc249b11-498d-4463-aab4-5802592894ce	C	$\\frac{\\pi}{6}$	2	\N
c821ade5-bfc7-414d-8254-1b568551c515	dc249b11-498d-4463-aab4-5802592894ce	D	$\\frac{\\pi}{3}$	3	\N
21beb9d6-bd77-4bde-a2de-e2b94296c32e	338edf0f-8f39-40d2-8b1e-71461be5d206	A	$\\mathbb{R}$	0	\N
a54891b9-afd3-46c4-b5ba-e7481228e52d	338edf0f-8f39-40d2-8b1e-71461be5d206	B	$(3, \\infty)$	1	\N
9096b97f-8f7e-4547-bc95-fbfd4cf66f86	338edf0f-8f39-40d2-8b1e-71461be5d206	C	$(-\\infty, 3)$	2	\N
19fde950-dae8-41a8-84b7-a12d185ef4c8	338edf0f-8f39-40d2-8b1e-71461be5d206	D	$\\mathbb{R} - \\{3\\}$	3	\N
ec149adf-06c1-463a-a2d2-80ec1aabeda0	a9f9c912-74a4-4991-8001-6116bb741fe4	A	1, 2	0	\N
cda5aeae-d5d8-41af-8092-ccd352ced90c	a9f9c912-74a4-4991-8001-6116bb741fe4	B	-1, 2	1	\N
93977890-f087-45e8-a4d9-930ef4443ac9	a9f9c912-74a4-4991-8001-6116bb741fe4	C	1, -2	2	\N
b2a6f14a-7b81-4d62-b0d0-80d4d0588760	a9f9c912-74a4-4991-8001-6116bb741fe4	D	-1, -2	3	\N
e9c60051-5e10-4199-8a7f-2a05119d5417	09bf3bd8-4f02-4106-a93f-d2d6aa6b5f65	A	$30^\\circ$	0	\N
c0fdab51-bf51-4c7e-b71e-4e77c55b4f06	09bf3bd8-4f02-4106-a93f-d2d6aa6b5f65	B	$45^\\circ$	1	\N
4af2d386-408d-4961-8a9a-97c7ffecc536	09bf3bd8-4f02-4106-a93f-d2d6aa6b5f65	C	$60^\\circ$	2	\N
cf6235c5-9efb-43dc-aaae-255269d032a0	09bf3bd8-4f02-4106-a93f-d2d6aa6b5f65	D	$120^\\circ$	3	\N
23c38185-f29b-4e3f-8455-b8e144add385	fb6587ae-24ad-466c-985f-4cb2e66f89db	A	$13x - 23 = 0$	0	\N
33996608-0e19-453a-8fa4-4288702c92d6	fb6587ae-24ad-466c-985f-4cb2e66f89db	B	$3x - 7 = 0$	1	\N
95c60687-8754-4394-afe8-ae096b18563c	fb6587ae-24ad-466c-985f-4cb2e66f89db	C	$7x - 3 = 0$	2	\N
1cfc286c-5d7a-4af0-9081-e9d600826ae0	fb6587ae-24ad-466c-985f-4cb2e66f89db	D	$23x - 13 = 0$	3	\N
7cdec112-420f-4152-8981-0308e9282773	ea23238d-a7e6-471b-84a0-8caf1e38cb9b	A	ক্ষণপদীয় কোষ	0	\N
4765d59e-5313-47cd-a61a-bebe85e41c53	ea23238d-a7e6-471b-84a0-8caf1e38cb9b	B	সংবেদী কোষ	1	\N
6c3a84a5-a706-4dc2-a4a6-5f8fc0d77db1	ea23238d-a7e6-471b-84a0-8caf1e38cb9b	C	পেশি-আবরণী কোষ	2	\N
0ce1c854-b050-4f09-beba-abf06c236cf4	ea23238d-a7e6-471b-84a0-8caf1e38cb9b	D	নিডোসাইট	3	\N
34f7f3b2-8430-4d8e-b4e4-ab23209b98aa	dac45940-d59c-4a11-b299-80dacfcb7589	A	নেফ্রিডিয়া	0	\N
77c3fb16-a786-42ed-b542-d276e1cc650c	dac45940-d59c-4a11-b299-80dacfcb7589	B	শিখাকোষ	1	\N
dd38b8d2-0a65-4b94-a3c2-758f3e95d663	dac45940-d59c-4a11-b299-80dacfcb7589	C	ম্যালপিজিয়ান নালিকা	2	\N
3392790e-3ff1-4682-afe8-d6c9505f2bd0	dac45940-d59c-4a11-b299-80dacfcb7589	D	ম্যালপিজিয়ান বডি	3	\N
3e1f2894-a338-4348-ab70-063c892f6866	4069f7b7-0536-4f6c-94ce-328fad9a5a0c	A	RuBP	0	\N
33c0a7f7-5259-4337-803a-905e8356d0d7	4069f7b7-0536-4f6c-94ce-328fad9a5a0c	B	PGA	1	\N
f3d632c3-b7c8-4fdd-b2e7-9695d2b7e038	4069f7b7-0536-4f6c-94ce-328fad9a5a0c	C	PEP	2	\N
5d7ac697-69a5-46d7-904d-154367235a01	4069f7b7-0536-4f6c-94ce-328fad9a5a0c	D	OAA	3	\N
b9789523-e46d-4d74-974d-d023a1402d7b	6fa917df-a841-467b-baff-27c7e05a1d1d	A	সাইনাস ভেনোসাস	0	\N
a4cc0fc4-4e8d-4afc-ba11-d786c57a4a7c	6fa917df-a841-467b-baff-27c7e05a1d1d	B	অলিন্দ	1	\N
c9776120-ea69-4631-b5ee-4db4ef8047ad	6fa917df-a841-467b-baff-27c7e05a1d1d	C	বাল্বাস আর্টারিওসাস	2	\N
db55402c-bbf3-495f-9255-bc7e4b6c5849	6fa917df-a841-467b-baff-27c7e05a1d1d	D	কোনাস আর্টারিওসাস	3	\N
9c7a30a6-d263-435f-9745-e681519dd48a	208d069a-678c-4182-bc8d-28bf73935431	A	লাইপেজ	0	\N
517b4417-f887-41a3-8a0a-42f9cd1d1e81	208d069a-678c-4182-bc8d-28bf73935431	B	মল্টেজ	1	\N
329a50b4-3ec5-40d8-826f-1cc880786d74	208d069a-678c-4182-bc8d-28bf73935431	C	অ্যামাইলেজ	2	\N
92f2fa89-5877-4dc5-926f-2e93a31795a8	208d069a-678c-4182-bc8d-28bf73935431	D	পেপসিন	3	\N
fd4a7a31-1b6f-4e63-8ca2-e5c91f6da609	e8965833-4ffc-4f1e-945f-5ea351fe8438	A	13	0	\N
856d5337-661b-4ad9-a696-5f7cace00fef	e8965833-4ffc-4f1e-945f-5ea351fe8438	B	6	1	\N
9add0a3f-79ec-47c8-8918-4e5802db725c	e8965833-4ffc-4f1e-945f-5ea351fe8438	C	7	2	\N
db26d644-3b8b-47dd-88b2-8fa6ea764922	e8965833-4ffc-4f1e-945f-5ea351fe8438	D	8	3	\N
cbab44bc-a210-4f6c-be86-fe419fb0f8ec	e990262a-7c8c-47b5-a27c-b5ecae862d40	A	Dracaena	0	\N
fc7667dd-bea5-4319-a554-3f09eb04f553	e990262a-7c8c-47b5-a27c-b5ecae862d40	B	Lycopodium	1	\N
99d779f4-b806-45c0-8770-7e65401e7a12	e990262a-7c8c-47b5-a27c-b5ecae862d40	C	Pteris	2	\N
642986b4-dbcf-47b5-b5b3-316a8cee2ab0	e990262a-7c8c-47b5-a27c-b5ecae862d40	D	Selaginella	3	\N
912c0725-2b19-410d-b55c-db5e8034ff6c	ae7e8091-2c0e-4b49-b9a4-a37f6f20a1c9	A	একোনাইটেক	0	\N
a378581c-57e1-430a-8d21-f91fca48b120	ae7e8091-2c0e-4b49-b9a4-a37f6f20a1c9	B	হেক্সোকাইনেজ	1	\N
3dfd4f28-75e0-4993-9fed-45b966ef0176	ae7e8091-2c0e-4b49-b9a4-a37f6f20a1c9	C	ইনোলজ	2	\N
34c65e7a-933f-4dce-aaae-4ec13947faec	ae7e8091-2c0e-4b49-b9a4-a37f6f20a1c9	D	অ্যালডোলেজ	3	\N
3b4d5857-35d7-45b3-b7e0-9870e3163155	f8af3011-4290-4a1c-8271-54fc73b0bd7a	A	বোরন	0	\N
dda3416f-e5da-42d3-83a2-597414c98d46	f8af3011-4290-4a1c-8271-54fc73b0bd7a	B	জিঙ্ক	1	\N
39173c4f-9355-40d8-8165-a405c9937963	f8af3011-4290-4a1c-8271-54fc73b0bd7a	C	ম্যাঙ্গানিজ	2	\N
c623e2cf-1b2e-4cf4-9ca6-0ddcbd304989	f8af3011-4290-4a1c-8271-54fc73b0bd7a	D	কপার	3	\N
dcbad8c1-8b6b-4463-9977-82d3001a153b	d23e987a-feef-4709-887b-967e249c4efc	A	অনকোলজি	0	\N
f61927aa-e530-46d7-8b42-8f2f03b140f5	d23e987a-feef-4709-887b-967e249c4efc	B	হারপেটোলজি	1	\N
17cea82f-5ee1-42fe-8a21-f70eaf4e60ad	d23e987a-feef-4709-887b-967e249c4efc	C	অরনাইথোলজি	2	\N
98b67315-4d85-4b60-89a0-e12d416c1448	d23e987a-feef-4709-887b-967e249c4efc	D	জিওলজি	3	\N
3957458e-1d0a-4f27-af2c-4cedb90e86ab	67e22042-4261-493e-a8dc-9bc1fb403204	A	Loa loa	0	\N
c6622275-2b6b-4c2e-95a5-8baab6ac189d	67e22042-4261-493e-a8dc-9bc1fb403204	B	Ascaris lumbricoides	1	\N
888bdd54-7452-4e93-998c-9c790caa4530	67e22042-4261-493e-a8dc-9bc1fb403204	C	Necator americanus	2	\N
578588ab-fbb8-44aa-9640-fbfed2f8a643	67e22042-4261-493e-a8dc-9bc1fb403204	D	Wucheria bancrofti	3	\N
854994b2-f4ab-4564-9113-a61cdac84ac1	1bdcbc61-64ae-4a59-ad8d-5e7aa88eb89a	A	$2:2:1$	0	\N
cbeae7c3-f3ca-407a-ad94-39ba65b93d40	1bdcbc61-64ae-4a59-ad8d-5e7aa88eb89a	B	$15:1$	1	\N
06392f1e-9beb-45e8-9d52-2756807e2b52	1bdcbc61-64ae-4a59-ad8d-5e7aa88eb89a	C	$9:6:1$	2	\N
adeefc26-8ad0-4363-b950-92a82752b5a2	1bdcbc61-64ae-4a59-ad8d-5e7aa88eb89a	D	$1:2:1$	3	\N
4b8e79e0-9c73-4336-a791-f67be5f79bb7	5e41f6b4-dd83-4b34-9843-b7d9b026f3be	A	রজনীগন্ধা	0	\N
9e95cb5f-1b09-4d77-92f6-3081985d87f1	5e41f6b4-dd83-4b34-9843-b7d9b026f3be	B	সরিষা	1	\N
893ecec4-0e97-4eeb-9775-c7ac930c3db1	5e41f6b4-dd83-4b34-9843-b7d9b026f3be	C	ধান	2	\N
96c28240-6ce2-4288-ac52-2d786349d513	5e41f6b4-dd83-4b34-9843-b7d9b026f3be	D	জবা	3	\N
fc72d5ba-6338-4793-8d45-d8f14f8b749b	13c99bc0-1417-439d-af78-bf35c30c2cda	A	হ্যাপ্লয়েড	0	\N
0aa469ad-ee6a-47eb-913d-2ecb8fa17e80	13c99bc0-1417-439d-af78-bf35c30c2cda	B	ডিপ্লয়েড	1	\N
3a1c6a50-a119-4d9c-af90-0ac19c634377	13c99bc0-1417-439d-af78-bf35c30c2cda	C	ট্রিপ্লয়েড	2	\N
5f744a7a-6bdf-4b5a-b0e4-5a64c680349d	13c99bc0-1417-439d-af78-bf35c30c2cda	D	হেক্সাপ্লয়েড	3	\N
26363db5-a861-4104-804a-6451a7b8cd42	026416a5-d518-4eec-9dcf-9723437bc799	A	বেগুন	0	\N
e724c643-8796-4228-a50c-893f3786c247	026416a5-d518-4eec-9dcf-9723437bc799	B	আপেল	1	\N
6dfc4312-16a8-4d92-8609-50cc1beab95b	026416a5-d518-4eec-9dcf-9723437bc799	C	কলা	2	\N
39940fda-dcc2-4f92-948e-1debb6fad3c7	026416a5-d518-4eec-9dcf-9723437bc799	D	কাঁঠাল	3	\N
02a073a6-9d2f-4c4a-b162-80f74156beb9	cda0ca18-8820-4020-ad75-1a93511536b3	A	$|\\vec{A}| = |\\vec{B}|$	0	\N
6a2efe83-6918-4090-b852-2c5762f2851a	cda0ca18-8820-4020-ad75-1a93511536b3	B	$\\vec{A} \\cdot \\vec{B} = 0$	1	\N
29990c35-d8b2-4649-9710-b0e359a9ea91	cda0ca18-8820-4020-ad75-1a93511536b3	C	$\\vec{A} \\times \\vec{B} = 0$	2	\N
18c7fd11-ce86-4744-acf6-df6f2cb4881e	cda0ca18-8820-4020-ad75-1a93511536b3	D	$\\vec{A} = -2\\vec{B}$	3	\N
5a5e77b1-204a-451a-a72a-1ccb8e94d536	fcb4d325-5f11-4166-ba6e-0c718d6b8936	A	$F$	0	\N
da24e1fb-3e06-4634-afe1-971e39a4f294	fcb4d325-5f11-4166-ba6e-0c718d6b8936	B	$\\frac{F}{6}$	1	\N
0f6198e9-9ce1-4149-930b-9a0e22f6cf90	fcb4d325-5f11-4166-ba6e-0c718d6b8936	C	$\\frac{F}{3}$	2	\N
ae61ea84-0863-4be3-b210-278b3bdbf466	fcb4d325-5f11-4166-ba6e-0c718d6b8936	D	$\\frac{F}{2}$	3	\N
e8cd8b16-0ebc-4f53-b197-84fa214a2873	fb75ef93-d920-4f94-81ea-1d9ff5b08784	A	$0.3\\,\\text{cm}$	0	\N
ce68a8ae-1695-405c-bd1c-3b2e32fae304	fb75ef93-d920-4f94-81ea-1d9ff5b08784	B	$\\frac{3}{\\sqrt{10}}\\,\\text{cm}$	1	\N
c9fc5a96-e214-45c7-bc40-d44c7e42c903	fb75ef93-d920-4f94-81ea-1d9ff5b08784	C	$3\\,\\text{cm}$	2	\N
f0b660bb-d27f-4413-88d5-c9768a6fe9da	fb75ef93-d920-4f94-81ea-1d9ff5b08784	D	$0.9\\,\\text{cm}$	3	\N
2995b303-565e-45a5-906d-bcc85fa3d07f	ac6f50f6-6eab-41d1-833d-6740b87c9175	A	$\\frac{M}{6}$	0	\N
d882f84c-c1fe-4113-84df-59dac9cd6d6d	ac6f50f6-6eab-41d1-833d-6740b87c9175	B	$\\frac{M}{16}$	1	\N
58482efe-aca1-41aa-8e96-cd355e0e17dc	ac6f50f6-6eab-41d1-833d-6740b87c9175	C	$\\frac{M}{24}$	2	\N
27d2b98f-ef73-4cef-b1b7-57954f9b7879	ac6f50f6-6eab-41d1-833d-6740b87c9175	D	$\\frac{M}{96}$	3	\N
5ac4a167-3585-4f0f-a125-3402f50a856a	617ff669-f28b-49d1-8d4e-1d03aac4f140	A	পূর্বের সমান	0	\N
439abc2b-1e06-4301-a2eb-756dbec4ad3d	617ff669-f28b-49d1-8d4e-1d03aac4f140	B	পূর্বের অর্ধেক	1	\N
63ae813d-d2a2-45ab-954d-ee79280d9625	617ff669-f28b-49d1-8d4e-1d03aac4f140	C	পূর্বের দ্বিগুণ	2	\N
0cb7d021-b3ec-44c5-82f6-c0c66af1e10b	617ff669-f28b-49d1-8d4e-1d03aac4f140	D	পূর্বের চারগুণ	3	\N
736fdd33-bc61-4c3c-8dd4-8760ffab6e10	448025f6-abe6-42fa-8866-014b842f7785	A	$\\frac{A}{4}$	0	\N
1b9682da-c1dd-4417-8295-c48b8e43aba7	448025f6-abe6-42fa-8866-014b842f7785	B	$\\frac{A}{2}$	1	\N
307c1623-663b-4f9f-8c7f-3e9398bb7edd	448025f6-abe6-42fa-8866-014b842f7785	C	$\\frac{A}{\\sqrt{2}}$	2	\N
e69a6d32-3b23-4d33-9588-49c8e73f21cd	448025f6-abe6-42fa-8866-014b842f7785	D	$A\\sqrt{2}$	3	\N
5d86b19c-172e-4834-a4c9-fac08d67c670	d9ca492d-8ac0-487a-8a2e-0644d67689e2	A	Tourmaline	0	\N
5820909a-7b23-4330-b22f-cb4445223fb5	d9ca492d-8ac0-487a-8a2e-0644d67689e2	B	Fresnel biprism	1	\N
2c5b2483-b472-4499-ae29-5c48b32bc7df	d9ca492d-8ac0-487a-8a2e-0644d67689e2	C	Calcite	2	\N
7344518d-022d-40be-bea3-10adb053b9f7	d9ca492d-8ac0-487a-8a2e-0644d67689e2	D	Nicol prism	3	\N
825dfe0b-ca4b-40d5-a620-a113d170d5a3	6d111269-ad5b-401e-a1b2-4819ba463ee6	A	$U/3$	0	\N
45a8240a-0a26-4f2e-bce5-3d93edabccdd	6d111269-ad5b-401e-a1b2-4819ba463ee6	B	$U/2$	1	\N
9f3db144-7042-4fb1-850c-763b4c505b80	6d111269-ad5b-401e-a1b2-4819ba463ee6	C	$U$	2	\N
5237a0d9-d58a-4af2-a62d-e5a0efda4d76	6d111269-ad5b-401e-a1b2-4819ba463ee6	D	$2U/3$	3	\N
e370e3b0-e7b1-47af-869f-e1c1128f1aa8	fa60a6d0-fec7-41af-b837-dc417b5e36a9	A	$C/d$	0	\N
8ce0da04-16bd-4989-b03a-cd85be53923a	fa60a6d0-fec7-41af-b837-dc417b5e36a9	B	$C/2$	1	\N
17b220b5-011b-423d-bf62-0e42f419d620	fa60a6d0-fec7-41af-b837-dc417b5e36a9	C	$4Cd$	2	\N
9919c780-1cb4-4b7d-821f-6ad9829b547a	fa60a6d0-fec7-41af-b837-dc417b5e36a9	D	$2C$	3	\N
4d438cf5-7227-43bd-846e-c9dbf373004c	e568c7fc-715f-404d-b3ed-70048053b374	A	$24\\,\\Omega$ series	0	\N
746868a6-8b74-45a3-a83b-eb54ffa2efee	e568c7fc-715f-404d-b3ed-70048053b374	B	$24\\,\\Omega$, parallel	1	\N
b9745253-8ab5-49c8-84c3-20091e0e7f04	e568c7fc-715f-404d-b3ed-70048053b374	C	$48\\,\\Omega$ series	2	\N
2caee20b-353d-4777-a8b7-7d30a1c9be30	e568c7fc-715f-404d-b3ed-70048053b374	D	$48\\,\\Omega$, parallel	3	\N
8c9afad4-0555-46b6-abdf-8cc062e3b48a	6b73768d-7203-43eb-a59f-6730654649cd	A	$1/4$	0	\N
4e686ab3-9343-4c6b-a8e4-d4c948a935b4	6b73768d-7203-43eb-a59f-6730654649cd	B	$1/2$	1	\N
2b19f216-10a7-4d04-ba9a-647c61d94344	6b73768d-7203-43eb-a59f-6730654649cd	C	$1$	2	\N
31673875-9f84-4643-b4fb-027ec9355fb8	6b73768d-7203-43eb-a59f-6730654649cd	D	$2$	3	\N
ab8c57ae-23a6-4711-94b7-44469648eb8c	d16e6125-c814-44cb-86d7-0eaaa8baa883	A	লাল	0	\N
3f865796-4795-4bb7-8dc2-dfc2d1b34ba2	d16e6125-c814-44cb-86d7-0eaaa8baa883	B	হলুদ	1	\N
5f5ededf-21b4-455d-aa8c-5b43da0e2cef	d16e6125-c814-44cb-86d7-0eaaa8baa883	C	নীল	2	\N
652c3307-689c-4276-8a0d-a158faf80b85	d16e6125-c814-44cb-86d7-0eaaa8baa883	D	কমলা	3	\N
78345e50-b6bf-4b98-91f0-ac9eac16d658	9f65ed34-7e3f-42fd-88dc-49989c66c493	A	$n_i = 80, n_f = 2$	0	\N
513066cc-0b6e-4d9c-8c3a-4f048da7e3ae	9f65ed34-7e3f-42fd-88dc-49989c66c493	B	$n_i = 1, n_f = 2$	1	\N
551e59aa-dd9d-496c-b0a9-55e9c70c211e	9f65ed34-7e3f-42fd-88dc-49989c66c493	C	$n_i = 3, n_f = 90$	2	\N
f86f3f12-35e7-4c58-9af8-3ae2d2d5f96e	9f65ed34-7e3f-42fd-88dc-49989c66c493	D	$n_i = 2, n_f = 1$	3	\N
0702a8e2-a64f-45e9-9881-0bd867bef4c8	c619a5da-b633-425a-92b2-34cb831fd662	A	$A$	0	\N
5700bbba-d032-4aff-b2e7-49859426cb1f	c619a5da-b633-425a-92b2-34cb831fd662	B	$B$	1	\N
6f2e666e-38d0-4d3e-98f5-ac9725447ea2	c619a5da-b633-425a-92b2-34cb831fd662	C	$A.B$	2	\N
4c4addce-8ab4-4828-ac90-3e2c3cbf2a78	c619a5da-b633-425a-92b2-34cb831fd662	D	$\\bar{A} + B$	3	\N
a1a924f6-d76b-4b02-97e6-778633412e87	b8015bab-db1a-45e5-9320-352d8d698989	A	$\\frac{3}{2} v_e$	0	\N
dfbebb7b-e75b-4760-8ff2-5e039c5ba826	b8015bab-db1a-45e5-9320-352d8d698989	B	$\\frac{1}{2} v_e$	1	\N
9ee68910-710b-42d8-a3f0-bad28cd95f88	b8015bab-db1a-45e5-9320-352d8d698989	C	$\\frac{1}{\\sqrt{2}} v_e$	2	\N
d6121941-a910-40d4-82fb-cdc678fea3eb	b8015bab-db1a-45e5-9320-352d8d698989	D	$0$	3	\N
7c38d5be-65ab-46b8-a5f3-886183a75250	eaa7ab0b-1055-4d82-ad55-19c0d4c8a80c	A	$(3, 2, 0, +1/2)$	0	\N
38228331-4c62-44b2-9e97-16e25cb96a3a	eaa7ab0b-1055-4d82-ad55-19c0d4c8a80c	B	$(3, 1, 0, -1/2)$	1	\N
60889362-e8ac-49cc-9780-5c714fca825e	eaa7ab0b-1055-4d82-ad55-19c0d4c8a80c	C	$(3, 1, 0, -1/2)$	2	\N
9cc714f6-3559-4013-aa44-356a77ae7cb8	eaa7ab0b-1055-4d82-ad55-19c0d4c8a80c	D	$(3, 0, 0, +1/2)$	3	\N
25a2471e-24e1-404d-84fd-1b4dd21c2e4d	459d8dd8-e694-46d7-96d4-642b1c642a6b	A	$22.4\\,\\text{L}$	0	\N
b348778b-ad02-422e-ae90-92701efccb78	459d8dd8-e694-46d7-96d4-642b1c642a6b	B	$0.56\\,\\text{L}$	1	\N
2c157d49-2418-4c1b-85ca-3a533814f672	459d8dd8-e694-46d7-96d4-642b1c642a6b	C	$5.6\\,\\text{L}$	2	\N
120321de-c77e-41f0-8720-81698b87e231	459d8dd8-e694-46d7-96d4-642b1c642a6b	D	$11.2\\,\\text{L}$	3	\N
b3ed04c9-b08b-4f32-80c9-43331c7ff01b	04aaae42-2fa9-467c-b925-639c277a0012	A	$\\ce{CO}$	0	\N
bce73649-f655-43bc-8eb3-9b7d7c3d5f98	04aaae42-2fa9-467c-b925-639c277a0012	B	$\\ce{CFC-12}$	1	\N
506e39f8-5b3c-4a60-aa81-ee5685ef3b7b	04aaae42-2fa9-467c-b925-639c277a0012	C	$\\ce{CCl4}$	2	\N
4bd22206-d018-4cf0-a37c-2f56736b2aa9	04aaae42-2fa9-467c-b925-639c277a0012	D	$\\ce{UV radiation}$	3	\N
0b0bac90-9f32-4830-9a8d-aa7cbee30f0c	5db23618-cdd5-465f-81cc-81b141ee8abe	A	$\\ce{CH3COOH(aq) + NaOH(aq) -> CH3COONa(aq) + H2O(l)}$	0	\N
87a6635d-2e3a-4f6a-8235-55e6b1c5437e	5db23618-cdd5-465f-81cc-81b141ee8abe	B	$\\ce{CH3COOH(aq) + NH4OH(aq) -> CH3COONH4(aq) + H2O(l)}$	1	\N
51329f5c-a5c1-45d0-aafa-cad69158fde7	5db23618-cdd5-465f-81cc-81b141ee8abe	C	$\\ce{HCl(aq) + NH4OH(aq) -> NH4Cl(aq) + H2O(l)}$	2	\N
1a1fab85-1e93-4c81-8573-03ef98a7b2b8	5db23618-cdd5-465f-81cc-81b141ee8abe	D	$\\ce{HCl(aq) + NaOH(aq) -> NaCl(aq) + H2O(l)}$	3	\N
bf1a6a3f-0300-4e14-82f8-4f321c9b55a4	02643a07-d564-48a8-9cb1-5a7ae7fccbe2	A	$6$ and $4$	0	\N
4c7cf5c0-f12a-4c6b-9d24-6346bb7f6445	02643a07-d564-48a8-9cb1-5a7ae7fccbe2	B	$6$ and $3$	1	\N
a0d6a7eb-2d84-4d0f-ba2e-d790a04185ec	02643a07-d564-48a8-9cb1-5a7ae7fccbe2	C	$6$ and $2$	2	\N
d94473b3-4cbb-4ba7-8bea-3b999554d945	02643a07-d564-48a8-9cb1-5a7ae7fccbe2	D	$7$ and $0$	3	\N
d447b903-4efb-46cd-aa3d-6f6bfcf552cf	ba01119b-ad97-4723-b2b8-0c18dc6aeadb	A	1, 3- butadiene (১, ৩-বিউটাডাইন)	0	\N
d634baa4-3fa0-41a0-bbbe-42e42b64f86e	ba01119b-ad97-4723-b2b8-0c18dc6aeadb	B	Cyclohexane (সাইক্লোহেক্সেন)	1	\N
2b124bff-bf0b-462b-8405-ad588769d8aa	ba01119b-ad97-4723-b2b8-0c18dc6aeadb	C	Vinylbenzene (ভিনাইলবেনজিন)	2	\N
ada24d8b-1e22-48f3-82f4-8b7da064ac66	ba01119b-ad97-4723-b2b8-0c18dc6aeadb	D	1, 2-butadiene (১, ২-বিউটাডাইন)	3	\N
71e9a429-8bec-46f9-8b11-914f8ad4c587	e1c032ec-9a67-410d-80f6-7fc3975e82c1	A	$+5$	0	\N
a43ec8b8-1656-4461-92ae-37ec5bf94fa3	e1c032ec-9a67-410d-80f6-7fc3975e82c1	B	$+4$	1	\N
209c1458-1d49-4beb-9de4-b1b7504834c5	e1c032ec-9a67-410d-80f6-7fc3975e82c1	C	$+3$	2	\N
4bf9ba96-512e-4324-9fdc-bac79a8790fa	e1c032ec-9a67-410d-80f6-7fc3975e82c1	D	$+2$	3	\N
abeaec3a-f9a3-4ef6-bec5-645c509786ad	dcb26abf-e243-4e90-96f0-0e4f38819a1e	A	$\\text{pH} < 7.0; \\text{pOH} < 7.0$	0	\N
525ff629-fe81-4571-90af-e7afe8c973dc	dcb26abf-e243-4e90-96f0-0e4f38819a1e	B	$\\text{pH} < 7.0; \\text{pOH} > 7.0$	1	\N
5ee63421-6282-48c1-92a2-97a02571a3d7	dcb26abf-e243-4e90-96f0-0e4f38819a1e	C	$\\text{pH} > 7.0; \\text{pOH} < 7.0$	2	\N
795e6152-c3f9-4d60-a17b-1ae3463bf25a	dcb26abf-e243-4e90-96f0-0e4f38819a1e	D	$\\text{pH} > 7.0; \\text{pOH} > 7.0$	3	\N
b75bb6ca-5efc-4fd2-9ceb-07bf69e130b9	3b3b76c0-4e58-4da1-a1c2-97fc0116378d	A	$\\ce{CH4, HCl}$	0	\N
9d57f1f3-c3f7-4c0e-a6fd-1c89b5d10f63	3b3b76c0-4e58-4da1-a1c2-97fc0116378d	B	$\\ce{NaCl, CH3Cl}$	1	\N
21b18f9e-9dd3-4f32-9d5b-763f62505215	3b3b76c0-4e58-4da1-a1c2-97fc0116378d	C	$\\ce{H2S, HCl}$	2	\N
54ea8895-3864-40e7-b350-037870035e62	3b3b76c0-4e58-4da1-a1c2-97fc0116378d	D	$\\ce{CaCl2, C6H5Cl}$	3	\N
dc46f375-51a7-4140-b1be-3d82b4d61204	0c75180c-5fdd-4448-a211-17b053d34f06	A	$\\ce{Sn/HCl}$	0	\N
584df974-15db-406f-9eea-909b91b19550	0c75180c-5fdd-4448-a211-17b053d34f06	B	$\\ce{Zn.Hg/HCl}$	1	\N
cf230d49-2d8c-4afe-80ff-dc8c750593ba	0c75180c-5fdd-4448-a211-17b053d34f06	C	$\\ce{LiAlH4}$	2	\N
dc204d6a-e4d8-4770-a6e1-fdf8e856af7b	0c75180c-5fdd-4448-a211-17b053d34f06	D	$\\ce{KMnO4}$	3	\N
1d2653d4-6cc6-40fe-88b6-e8709ae8e21e	df50d5c0-02e4-4ced-afea-c1d41b642f4a	A	$\\ce{HCOOH}$	0	\N
7e86461f-0c0d-40d7-91d0-efcc3e0eb22d	df50d5c0-02e4-4ced-afea-c1d41b642f4a	B	$\\ce{CH3COOH}$	1	\N
56ec9fe1-5983-4bd8-8beb-86ec2d859e3f	df50d5c0-02e4-4ced-afea-c1d41b642f4a	C	$\\ce{CH3CH(OH)CH3}$	2	\N
887d9484-1b89-4c92-a862-89ef929c29e8	df50d5c0-02e4-4ced-afea-c1d41b642f4a	D	$\\ce{CH3COCH3}$	3	\N
d5672286-005a-4ec8-bd0a-e190ee46e100	b8b786df-cf12-4bbc-ad1d-37c1e583cf7e	A	50000	0	\N
93dc2af0-5fab-4e08-a11e-8bb2710a54cb	b8b786df-cf12-4bbc-ad1d-37c1e583cf7e	B	50	1	\N
8500da13-7cf0-4e7a-a38a-7ee53707d513	b8b786df-cf12-4bbc-ad1d-37c1e583cf7e	C	500	2	\N
9be1c829-db56-4c79-857e-f2ab9cec8bf7	b8b786df-cf12-4bbc-ad1d-37c1e583cf7e	D	5000	3	\N
2711f85c-447a-461b-86c2-4a9439823d2b	9791bce5-9364-4e4b-bf0d-6b3ca12aec1a	A	$\\ce{NH3 > RNH2 > R2NH}$	0	\N
188ed4b5-5ce5-48b2-b4eb-05ee9e2d0b50	9791bce5-9364-4e4b-bf0d-6b3ca12aec1a	B	$\\ce{R2NH > RNH2 > NH3}$	1	\N
1adc5bfa-8063-4b3d-8671-16b5d680b916	9791bce5-9364-4e4b-bf0d-6b3ca12aec1a	C	$\\ce{NH3 > R2NH > RNH2}$	2	\N
132fa08c-b92b-427c-be84-761a7c4d8eb0	9791bce5-9364-4e4b-bf0d-6b3ca12aec1a	D	$\\ce{RNH2 > NH3 > R2NH}$	3	\N
0b22c11c-2e1e-425e-929a-83a2f999f9c6	0becb42a-2a72-4638-9e3e-6317f6e91c1a	A	$20.0\\,\\text{g}$	0	\N
fdd2b90f-b9e6-4efe-b4c4-26f02899d845	0becb42a-2a72-4638-9e3e-6317f6e91c1a	B	$40.0\\,\\text{g}$	1	\N
e52e68b0-47d1-4a1e-8188-c74ec6264fc6	0becb42a-2a72-4638-9e3e-6317f6e91c1a	C	$80.0\\,\\text{g}$	2	\N
018c6ee3-cece-418f-82fd-9cab006e01df	0becb42a-2a72-4638-9e3e-6317f6e91c1a	D	$35.5\\,\\text{g}$	3	\N
85fb367e-993c-435f-9351-d4f78a04903d	0055f69d-d348-4e7c-9a7a-fdf9d19eaf07	A	$27s^2$	0	\N
6a16e974-30f5-49d4-926b-92a760e1540c	0055f69d-d348-4e7c-9a7a-fdf9d19eaf07	B	$s^4$	1	\N
1fab1753-4a48-4251-bbc4-e33c801a374b	0055f69d-d348-4e7c-9a7a-fdf9d19eaf07	C	$3s^4$	2	\N
7e6abdd6-f99e-4eed-afd5-b6d9b661d336	0055f69d-d348-4e7c-9a7a-fdf9d19eaf07	D	$27s^4$	3	\N
4dece242-018c-4348-8cf1-2952000485c3	a6db028f-0764-4dc6-a95c-ccc4231cccac	A	$\\frac{4}{3}$	0	\N
ad336d05-5344-47bf-ba0f-85b4b705d7ea	a6db028f-0764-4dc6-a95c-ccc4231cccac	B	$\\frac{3}{4}$	1	\N
f3f4147c-5d9a-4e64-b66f-8234b2ca319b	a6db028f-0764-4dc6-a95c-ccc4231cccac	C	$\\frac{5}{3}$	2	\N
52d0e2ec-2d41-4edd-8bee-3eee6c796487	a6db028f-0764-4dc6-a95c-ccc4231cccac	D	$\\frac{3}{5}$	3	\N
911036eb-b150-4c66-89d7-fc139b731b48	bbb69845-aa2e-4916-9c8d-ddb06a72b002	A	$3x + 2y - 5 = 0$	0	\N
216d58f8-3d14-4b23-9517-def6f447d88b	bbb69845-aa2e-4916-9c8d-ddb06a72b002	B	$3x + 2y + 5 = 0$	1	\N
6675516a-0422-4907-8806-970291fe02e9	bbb69845-aa2e-4916-9c8d-ddb06a72b002	C	$3x - 2y - 1 = 0$	2	\N
94601098-7a8e-47c3-9148-0fec717371a8	bbb69845-aa2e-4916-9c8d-ddb06a72b002	D	$-2x + 3y + 1 = 0$	3	\N
db32208f-4000-4593-a6d0-e08b71aa852a	ae335f47-e605-48a0-8fbf-eb4e8986f137	A	$(\\frac{1}{2}, 0), \\frac{1}{2}$	0	\N
4ab59894-4cb4-4c7a-8355-89c2ef51d22b	ae335f47-e605-48a0-8fbf-eb4e8986f137	B	$(0, 2), \\frac{1}{2}$	1	\N
71fe7e17-108b-4fc6-86aa-07206e62df5e	ae335f47-e605-48a0-8fbf-eb4e8986f137	C	$(0, \\frac{1}{2}), 2$	2	\N
250e98d8-7191-4e4f-aeec-7741bb229b8e	ae335f47-e605-48a0-8fbf-eb4e8986f137	D	$(0, \\frac{1}{2}), \\frac{1}{2}$	3	\N
be2281d2-c703-4052-82f7-5b991bf03a7f	5c4c5cde-9543-4cf7-af80-2549ff637522	A	$\\frac{1}{2-x}$	0	\N
1b4dbc6e-340f-484f-b144-214a935fe122	5c4c5cde-9543-4cf7-af80-2549ff637522	B	$\\frac{2}{2-x}$	1	\N
ac30a4c5-5b6e-476f-a366-f3ef84fdb333	5c4c5cde-9543-4cf7-af80-2549ff637522	C	$\\frac{x}{2-x}$	2	\N
c0c19e71-ee93-4f20-bf8d-0c872cfbccad	5c4c5cde-9543-4cf7-af80-2549ff637522	D	$\\frac{1}{x-2}$	3	\N
ca563c80-8020-417c-bb34-ab84880719f8	21fe7e28-1459-4168-a6df-820046fccf0e	A	$\\frac{\\pi}{4}$	0	\N
d435423c-911c-4695-9f55-9252019b8c1e	21fe7e28-1459-4168-a6df-820046fccf0e	B	$\\frac{\\pi}{2}$	1	\N
8ded6cd7-91cf-458c-9b6f-56fa251baa1c	21fe7e28-1459-4168-a6df-820046fccf0e	C	1	2	\N
84a3f3e8-773b-4936-94b7-f89ca35bebdd	21fe7e28-1459-4168-a6df-820046fccf0e	D	0	3	\N
b01e564b-d7b9-4a42-9665-a221a3c74832	b1451d45-98c4-44d3-bdce-3992225e8481	A	$-\\sqrt{x} + C$	0	\N
3fcc225a-84ea-4f26-81a9-1aef4284d669	b1451d45-98c4-44d3-bdce-3992225e8481	B	$-\\sqrt{1-x} + C$	1	\N
aa162bd8-d675-4946-830d-100c92d2b31f	b1451d45-98c4-44d3-bdce-3992225e8481	C	$\\sqrt{1-x^2} + C$	2	\N
9dbe362b-9aa1-4740-b36c-00291cdba41e	b1451d45-98c4-44d3-bdce-3992225e8481	D	$-\\sqrt{1-x^2} + C$	3	\N
c45531da-cd2c-449f-9622-9303240b8fee	30e4f9fd-92bf-491e-a45e-5f8bd63ff00a	A	1	0	\N
d35f78e6-116e-484d-a95d-25ebfa88f581	30e4f9fd-92bf-491e-a45e-5f8bd63ff00a	B	2	1	\N
c8cba076-784f-486c-95f4-7efb3c8a223c	30e4f9fd-92bf-491e-a45e-5f8bd63ff00a	C	-1	2	\N
94bb98dc-ac5f-4c17-beab-fc08e410862c	30e4f9fd-92bf-491e-a45e-5f8bd63ff00a	D	-2	3	\N
dea3bf10-fdbe-49ff-98da-426bbc02fe64	3556bbed-9cac-4f0c-b691-187f29028fa5	A	3	0	\N
46d65d80-3cf0-4416-870d-f61b035bde9a	3556bbed-9cac-4f0c-b691-187f29028fa5	B	4	1	\N
2384d7cd-ca2e-4668-8a6a-30c7ea45d8c8	3556bbed-9cac-4f0c-b691-187f29028fa5	C	5	2	\N
ca2d5861-98ac-4ba2-9bd6-9eca0062281d	3556bbed-9cac-4f0c-b691-187f29028fa5	D	6	3	\N
f4039f81-4d3b-4dff-bb61-c2d5af604363	78918a2f-7419-4c4e-89d9-cf193ad6d3b9	A	$(\\frac{9}{4}, -1)$	0	\N
f8de14ac-b136-4bcd-967e-646d5f01718d	78918a2f-7419-4c4e-89d9-cf193ad6d3b9	B	$(-\\frac{9}{4}, -1)$	1	\N
a77475e7-2b7b-4c5b-9773-febed78f58b7	78918a2f-7419-4c4e-89d9-cf193ad6d3b9	C	$(0, 2)$	2	\N
70425239-2d84-4f38-acad-7f52a87c6fda	78918a2f-7419-4c4e-89d9-cf193ad6d3b9	D	$(2, 0)$	3	\N
e60e1701-dfe1-4159-be49-c43bd79b57bb	b324d53d-259a-4afa-bc37-3d7dc876cda4	A	3	0	\N
380a67a5-a25d-4ada-a1d1-1d836d924b16	b324d53d-259a-4afa-bc37-3d7dc876cda4	B	$\\frac{4}{3}$	1	\N
4b06f1a6-9c04-4dbd-b6d0-4f38977afd16	b324d53d-259a-4afa-bc37-3d7dc876cda4	C	$\\frac{8}{3}$	2	\N
f08335ac-131f-4ef9-ac1d-a26a2e36c742	b324d53d-259a-4afa-bc37-3d7dc876cda4	D	$\\frac{5}{3}$	3	\N
419ce8f5-51cd-47c5-8fff-b7daf8565ed5	3cf007c0-fbd8-4f56-b9c8-b8057934c194	A	1	0	\N
ad684637-aadd-46b9-912c-a21678b65709	3cf007c0-fbd8-4f56-b9c8-b8057934c194	B	$-\\infty$	1	\N
fb1d6d2a-62da-4a36-a6ea-3dab88b117fe	3cf007c0-fbd8-4f56-b9c8-b8057934c194	C	$\\infty$	2	\N
3a81721e-b7b6-436f-b49b-913dcaaf1fbf	3cf007c0-fbd8-4f56-b9c8-b8057934c194	D	-1	3	\N
60ca2a98-f67b-40ad-a9d4-dc0ec46df224	38645518-b89a-4c6d-a0fc-ba993b31f8aa	A	$78.4\\,\\text{m}$	0	\N
574184c6-2ff9-4fd8-ba86-6eb3ce7de03e	38645518-b89a-4c6d-a0fc-ba993b31f8aa	B	$44.1\\,\\text{m}$	1	\N
cf9c3430-6a81-43db-b26c-3b468257ff87	38645518-b89a-4c6d-a0fc-ba993b31f8aa	C	$39.2\\,\\text{m}$	2	\N
b286b1a2-1dfb-47a7-9736-9129eb5504f3	38645518-b89a-4c6d-a0fc-ba993b31f8aa	D	$34.3\\,\\text{m}$	3	\N
c2211bbe-4215-410b-a66d-6c97768cd952	e118b659-ae11-4fc2-872b-ea9b90b39e9c	A	$\\frac{1-\\sqrt{3}}{1+\\sqrt{3}}$	0	\N
537676b9-ef04-4136-839e-6b273f256ef6	e118b659-ae11-4fc2-872b-ea9b90b39e9c	B	$\\frac{\\sqrt{3}+1}{\\sqrt{3}-1}$	1	\N
e1413b86-af2f-490e-b3c6-a50738742697	e118b659-ae11-4fc2-872b-ea9b90b39e9c	C	$\\frac{\\sqrt{3}-1}{\\sqrt{3}+1}$	2	\N
63aedd75-ef03-4fd2-94b0-2a9b64070df5	e118b659-ae11-4fc2-872b-ea9b90b39e9c	D	$\\frac{1+\\sqrt{3}}{1-\\sqrt{3}}$	3	\N
cd32b81b-e539-4166-aded-2b65f365d2e2	d8bd851c-e716-4bc4-93e0-365b13791941	A	অধিবৃত্ত	0	\N
8a7be391-4c62-4882-9a70-6dcf7bc23f20	d8bd851c-e716-4bc4-93e0-365b13791941	B	বৃত্ত	1	\N
2fdd0f84-d0e1-41d0-957a-e20b9e707629	d8bd851c-e716-4bc4-93e0-365b13791941	C	পরাবৃত্ত	2	\N
0a2a1c23-cd92-4f2e-9a69-d81e12e40699	d8bd851c-e716-4bc4-93e0-365b13791941	D	উপবৃত্ত	3	\N
03100a64-6028-4ba7-9149-813eecfed6ab	4baa74ca-84e2-4e87-bae8-96573878f24c	A	$\\cot \\frac{\\sqrt{5}}{2}$	0	\N
1a410d67-9f8f-460f-8380-22bbe87d23c8	4baa74ca-84e2-4e87-bae8-96573878f24c	B	$\\cot^{-1} \\frac{\\sqrt{5}}{2}$	1	\N
8b7ef508-f202-44b1-995e-6f87ab120f75	4baa74ca-84e2-4e87-bae8-96573878f24c	C	$\\tan \\sqrt{5}$	2	\N
1c0c664c-f2fa-4189-a47f-d728aa533c8e	4baa74ca-84e2-4e87-bae8-96573878f24c	D	$\\tan^{-1} \\frac{1}{\\sqrt{5}}$	3	\N
da11fa76-83ce-4f73-a794-dcf13d1e41ae	a0f340d4-78c6-44a2-bcdc-343d264deb9f	A	ক্যাপসোমিয়ার	0	\N
00fd96e3-305c-4ce6-9932-b529f1e7cc27	a0f340d4-78c6-44a2-bcdc-343d264deb9f	B	ক্যাপসিড	1	\N
aadd0e3a-c337-44fb-8e9a-1eb8a445ba58	a0f340d4-78c6-44a2-bcdc-343d264deb9f	C	ভিরয়েডস	2	\N
b92a6ac7-32fe-41d3-90b3-e92b69defcfc	a0f340d4-78c6-44a2-bcdc-343d264deb9f	D	গ্লাইকোপ্রোটিন	3	\N
bb6d5b26-7aa7-4894-9d68-d74bab8dc63c	c523ec25-ae48-4fac-acff-027323ea2e0c	A	অ্যামাইলেজ	0	\N
02393f4f-eac8-4434-ae34-837ad6d62ed0	c523ec25-ae48-4fac-acff-027323ea2e0c	B	রেনিন	1	\N
1095cf5d-10f6-40a8-9e4f-34471232be06	c523ec25-ae48-4fac-acff-027323ea2e0c	C	পেকটিনেজ	2	\N
1f3245e4-7b7d-402c-98d9-d971e4ea6e94	c523ec25-ae48-4fac-acff-027323ea2e0c	D	জাইমেজ	3	\N
7604a425-bb6b-4bd1-888c-430eccd7fd4c	5f467ec7-fc78-4ee4-bfcd-d02db2f495ce	A	রাইবুলোজ 1, 5- বিসফসফেট	0	\N
6c94ae86-2975-4a0f-98e2-36e72bc8123c	5f467ec7-fc78-4ee4-bfcd-d02db2f495ce	B	3-ফসফোগ্লিসারিক অ্যাসিড	1	\N
29e4aa48-9ab7-49ce-9f2e-44a7ca3d63e8	5f467ec7-fc78-4ee4-bfcd-d02db2f495ce	C	ফসফোইনল পাইরুভিক অ্যাসিড	2	\N
f0c9c427-b014-4eae-b467-605148a87ba5	5f467ec7-fc78-4ee4-bfcd-d02db2f495ce	D	অক্সালো অ্যাসিটিক অ্যাসিড	3	\N
01cab3af-29d4-487d-ac04-90ecf8cc57d2	90eb6420-7c1e-4aba-ad9b-f62a70ec7c28	A	সীবলল	0	\N
a4a6a2f4-c60e-42e3-90ab-656d1f9aaa27	90eb6420-7c1e-4aba-ad9b-f62a70ec7c28	B	প্যারেনকাইমা	1	\N
71d61eb5-146c-4ba3-aa98-dde9ef5f6e5f	90eb6420-7c1e-4aba-ad9b-f62a70ec7c28	C	কোলেনকাইমা	2	\N
61e7a315-70ed-4728-97ea-507709e16ba3	90eb6420-7c1e-4aba-ad9b-f62a70ec7c28	D	ট্রাকিড	3	\N
5fde025d-af87-4e64-8007-ecc81e462ab8	9177721a-8e16-4dd4-8b5d-aed56d73c0d9	A	পেপটাইড	0	\N
431f50d0-2edb-4ed5-99fc-95653dcd710d	9177721a-8e16-4dd4-8b5d-aed56d73c0d9	B	নাইট্রোজেন বেস	1	\N
938faa3f-fbf2-4a36-8cfa-601805c5a682	9177721a-8e16-4dd4-8b5d-aed56d73c0d9	C	নিউক্লিওসাইড	2	\N
1a8bfcc2-ba51-4065-b431-0eca3db36df3	9177721a-8e16-4dd4-8b5d-aed56d73c0d9	D	নিউক্লিওটাইড	3	\N
c6807a8d-3a18-425b-91c9-b28c9bf08f66	353f550b-1dbe-4d98-a917-82a1546ceca9	A	pBR322	0	\N
3f692035-92ed-41f4-acaa-7fc9ae15d76b	353f550b-1dbe-4d98-a917-82a1546ceca9	B	Eco RI	1	\N
5843436d-9c78-4765-8db5-085084c0933e	353f550b-1dbe-4d98-a917-82a1546ceca9	C	Hind III	2	\N
64d1dc35-27f8-4a3b-8186-641fec72ad94	353f550b-1dbe-4d98-a917-82a1546ceca9	D	Bam HI	3	\N
38259804-88c9-4ad8-8a32-f2da7f52816f	4b084110-815e-4fdf-9faf-31834bf8049e	A	সংযুক্ত	0	\N
297163c0-5350-424d-9d66-190a412716db	4b084110-815e-4fdf-9faf-31834bf8049e	B	সমপার্শ্বীয়	1	\N
dc8de98e-240f-4d06-b26b-4a454d4fd57a	4b084110-815e-4fdf-9faf-31834bf8049e	C	অরীয়	2	\N
1d224fec-085c-4bd5-bffe-dbce0414613a	4b084110-815e-4fdf-9faf-31834bf8049e	D	কেন্দ্রিক	3	\N
68ecc6e7-5858-4239-a48e-f17824eaf2e9	02162adc-0a34-4df0-96da-e9bed6d8cf2e	A	$9:3:3:1$	0	\N
c1c85a0a-5a92-4f0c-b2c1-8be4ad5f1325	02162adc-0a34-4df0-96da-e9bed6d8cf2e	B	$9:7$	1	\N
67dcef8b-fd61-40ea-bdd0-5b7a0759fa54	02162adc-0a34-4df0-96da-e9bed6d8cf2e	C	$13:3$	2	\N
c148879b-67de-4624-8c9b-2fd9b189cf54	02162adc-0a34-4df0-96da-e9bed6d8cf2e	D	$3:1$	3	\N
7aaa5cdb-09f5-44e3-ae8e-16a8748daece	b4d90d9d-26ec-4949-8490-c635978e139c	A	Wuchereria bancrofti	0	\N
4c964503-891f-4895-84c3-9bd042bdb1ee	b4d90d9d-26ec-4949-8490-c635978e139c	B	Octopus punctatus	1	\N
e8b1d097-c610-43e9-adb7-cbca8956809a	b4d90d9d-26ec-4949-8490-c635978e139c	C	Neanthes virens	2	\N
b8109984-2b7c-4122-ac3e-f676f0b56a51	b4d90d9d-26ec-4949-8490-c635978e139c	D	Aurelia aurita	3	\N
21fd41b5-029c-4afc-99d7-23ee913d2d0c	44a82cc4-8571-4355-b858-c026c058c47c	A	হৃৎপিণ্ড দুই প্রকোষ্ঠবিশিষ্ট	0	\N
7f4e3c98-81de-4cd6-9c78-5d075d69618e	44a82cc4-8571-4355-b858-c026c058c47c	B	ডায়াফ্রাম উপস্থিত	1	\N
641b8db7-d643-4598-af5a-c5231b968e17	44a82cc4-8571-4355-b858-c026c058c47c	C	শ্বসনতন্ত্রের অঙ্গ ট্রাকিয়া	2	\N
41d99037-6e47-48d6-bc02-6c96b298c36e	44a82cc4-8571-4355-b858-c026c058c47c	D	প্যারাপোডিয়া চলনে সহায়তা করে	3	\N
a1335414-c2a1-4b40-9553-d46cf056eb58	65dcf89e-1f61-48eb-900d-270a06b8227e	A	ম্যালিয়াস	0	\N
dd3c73e3-cea9-49fb-870d-7abae8a06769	65dcf89e-1f61-48eb-900d-270a06b8227e	B	ইনকাস	1	\N
d6d1d3dd-7e8e-4b74-b880-44d0d953f685	65dcf89e-1f61-48eb-900d-270a06b8227e	C	স্টেপিস	2	\N
4ec953c9-4162-49c8-9b84-1e88d85ac655	65dcf89e-1f61-48eb-900d-270a06b8227e	D	অটোলিথ	3	\N
efa3172e-6cb7-46e6-8c67-ba54f6bdea7c	095b7ee9-cd7a-434c-a4a0-e49648cc1b30	A	রেনিন	0	\N
fd6131ff-65b6-4df7-9d49-766af1caf3c3	095b7ee9-cd7a-434c-a4a0-e49648cc1b30	B	ট্রিপসিন	1	\N
a24ae97c-1d8e-4c0f-9b27-d924c9f1336f	095b7ee9-cd7a-434c-a4a0-e49648cc1b30	C	পেপসিন	2	\N
a61e08c5-f9b5-48f3-ab47-04d624fcdd95	095b7ee9-cd7a-434c-a4a0-e49648cc1b30	D	লাইপেজ	3	\N
9f7f53fa-e827-434a-aa5d-978b5dd2e917	60ea5af0-1151-4eeb-83f4-95e48418f6ae	A	পালমোনারি	0	\N
4188607e-5240-406f-b3c8-d9bf8edccdbf	60ea5af0-1151-4eeb-83f4-95e48418f6ae	B	করোনারি	1	\N
783d1add-624e-42be-abac-296f4d86b673	60ea5af0-1151-4eeb-83f4-95e48418f6ae	C	সাবক্ল্যাভিয়ান	2	\N
1ce54a37-495e-49e2-b1d3-1086d9b5c776	60ea5af0-1151-4eeb-83f4-95e48418f6ae	D	বৃক্কীয়	3	\N
27c67363-8f83-44df-b732-59d8ed9f6e33	2d418f6a-e8d0-4096-92ca-8e6670aac17b	A	Annelida	0	\N
e683464b-eeee-471e-a2ca-fbe8bc645b97	2d418f6a-e8d0-4096-92ca-8e6670aac17b	B	Porifera	1	\N
02a1a8ed-52aa-4631-959e-8f7d1091a59c	2d418f6a-e8d0-4096-92ca-8e6670aac17b	C	Cnidaria	2	\N
2902140c-f296-40b4-8070-22a5d14e3579	2d418f6a-e8d0-4096-92ca-8e6670aac17b	D	Mollusca	3	\N
30cfe4d4-6d37-48ba-9b3f-14fba1b2b068	d553c437-75ad-45f1-b4cc-fc726a92844f	A	গ্রুপ O	0	\N
c61410bd-99b2-46dd-a057-c2a275cdcecc	d553c437-75ad-45f1-b4cc-fc726a92844f	B	গ্রুপ A	1	\N
107abcd8-cefb-4663-9bfc-ee55588d86fc	d553c437-75ad-45f1-b4cc-fc726a92844f	C	গ্রুপ B	2	\N
f4fa06f7-f9fd-4aea-9f72-6c0281076697	d553c437-75ad-45f1-b4cc-fc726a92844f	D	গ্রুপ AB	3	\N
\.


--
-- Data for Name: admission_mcq_questions; Type: TABLE DATA; Schema: public; Owner: exambank
--

COPY public.admission_mcq_questions (id, paper_id, question_number, question_text, subject, chapter, correct_answer, solution, solution_status, created_at, university_name, exam_session, exam_unit, images, gemini_solution, gemini_correct_answer) FROM stdin;
cc8ba2b6-5eb6-4c30-a00d-d2a89b0ce831	55086422-ef06-4659-a0be-10579b6abde5	29	দুইটি সমান্তরাল তারের মধ্যে একই মানের তড়িৎ প্রবাহিত হয় এবং তার দুইটি প্রতি একক দৈর্ঘ্যে $F$ বল দ্বারা একে অপরকে বিকর্ষণ করে। যদি প্রবাহিত তড়িৎ দ্বিগুণ এবং তারদ্বয়ের মধ্যে দূরত্বকে তিন গুণ করা হয় তবে প্রতি একক দৈর্ঘ্যে বলের মান হবে?	physics	magnetic_effects_of_electric_current_and_magnetism	B	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	দুটি সমান্তরাল তারের প্রতি একক দৈর্ঘ্যে প্রযুক্ত বলের সমীকরণ হলো $F = \\frac{\\mu_0 I_1 I_2}{2\\pi d}$। এখানে তড়িৎ প্রবাহ $I_1 = I_2 = I$ হলে বল $F \\propto \\frac{I^2}{d}$। প্রশ্নমতে, নতুন তড়িৎ প্রবাহ $I' = 2I$ এবং নতুন দূরত্ব $d' = 3d$। সুতরাং নতুন বল $F' = \\frac{\\mu_0 (2I)(2I)}{2\\pi (3d)} = \\frac{4}{3} \\left( \\frac{\\mu_0 I^2}{2\\pi d} \\right) = \\frac{4}{3}F$।	B
3ecc6897-3b48-4930-b659-d597c69c83bc	55086422-ef06-4659-a0be-10579b6abde5	10.	বাইনারি সংখ্যা $(10110101)_2$ হতে বাইনারি সংখ্যা $(10011)_2$ এর বিয়োগফল হলো-	physics	semiconductor_and_electronics	B	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	বাইনারি বিয়োগের ক্ষেত্রে, $(10110101)_2$ থেকে $(10011)_2$ বিয়োগ করতে হবে। দশমিক পদ্ধতিতে রূপান্তর করলে পাই, $(10110101)_2 = 1 \\cdot 2^7 + 0 \\cdot 2^6 + 1 \\cdot 2^5 + 1 \\cdot 2^4 + 0 \\cdot 2^3 + 1 \\cdot 2^2 + 0 \\cdot 2^1 + 1 \\cdot 2^0 = 181_{10}$ এবং $(10011)_2 = 1 \\cdot 2^4 + 0 \\cdot 2^3 + 0 \\cdot 2^2 + 1 \\cdot 2^1 + 1 \\cdot 2^0 = 19_{10}$। এদের বিয়োগফল হলো $181 - 19 = 162$। এখন $162$ কে বাইনারিতে রূপান্তর করলে পাওয়া যায় $(10100010)_2$। সুতরাং সঠিক উত্তরটি হলো $(10100010)_2$।	B
cf3e3677-791a-4595-acca-dbdb0f4d2908	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	08	$2\\text{N}$ এবং $5\\text{N}$ মানের দুইটি বল একই রেখায় একই দিকে ক্রিয়ারত। উহাদের সর্বাধিক লব্ধি হবে -	physics	vector	A	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	যখন দুইটি বল একই রেখায় একই দিকে ক্রিয়া করে, তখন তাদের লব্ধি বলের মান হয় বলদ্বয়ের মানের যোগফল। এটিই সর্বাধিক লব্ধি। এখানে, বলদ্বয় $F_1 = 2\\,\\text{N}$ এবং $F_2 = 5\\,\\text{N}$। সুতরাং, লব্ধি বল $R = F_1 + F_2 = 2\\,\\text{N} + 5\\,\\text{N} = 7\\,\\text{N}$।	A
8348307d-6f89-4ee2-bcee-97ba4e2a32f8	55086422-ef06-4659-a0be-10579b6abde5	12	তিনটি ভেক্টর, $\\vec{a}, \\vec{b}, \\vec{c}$ যাদের মান যথাক্রমে $4, 3$ এবং $5$, যোগ করলে শূন্য হয় অর্থাৎ $\\vec{a} + \\vec{b} + \\vec{c} = 0$। তাহলে $|\\vec{c} \\times (\\vec{a} \\times \\vec{b})|$ এর মান হলো-	physics	vector	B	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	প্রদত্ত ভেক্টরগুলির মান হলো $|\\vec{a}| = 4$, $|\\vec{b}| = 3$, এবং $|\\vec{c}| = 5$। যেহেতু $\\vec{a} + \\vec{b} + \\vec{c} = 0$, আমরা লিখতে পারি $\\vec{a} + \\vec{b} = -\\vec{c}$। উভয় পাশে ডট গুণন করে পাই $(\\vec{a} + \\vec{b}) \\cdot (\\vec{a} + \\vec{b}) = (-\\vec{c}) \\cdot (-\\vec{c})$। এটি থেকে আমরা পাই $|\\vec{a}|^2 + |\\vec{b}|^2 + 2\\vec{a} \\cdot \\vec{b} = |\\vec{c}|^2$। মান বসিয়ে পাই $4^2 + 3^2 + 2\\vec{a} \\cdot \\vec{b} = 5^2 \\implies 16 + 9 + 2\\vec{a} \\cdot \\vec{b} = 25 \\implies 25 + 2\\vec{a} \\cdot \\vec{b} = 25 \\implies 2\\vec{a} \\cdot \\vec{b} = 0 \\implies \\vec{a} \\cdot \\vec{b} = 0$। এর অর্থ হলো $\\vec{a}$ এবং $\\vec{b}$ ভেক্টর দুটি পরস্পর লম্ব।\nএখন, আমরা ভেক্টর ট্রিপল প্রোডাক্টের সূত্র ব্যবহার করব: $\\vec{A} \\times (\\vec{B} \\times \\vec{C}) = (\\vec{A} \\cdot \\vec{C})\\vec{B} - (\\vec{A} \\cdot \\vec{B})\\vec{C}$।\nসুতরাং, $\\vec{c} \\times (\\vec{a} \\times \\vec{b}) = (\\vec{c} \\cdot \\vec{b})\\vec{a} - (\\vec{c} \\cdot \\vec{a})\\vec{b}$।\nআমরা জানি $\\vec{c} = -(\\vec{a} + \\vec{b})$। তাহলে,\n$\\vec{c} \\cdot \\vec{b} = -(\\vec{a} + \\vec{b}) \\cdot \\vec{b} = -(\\vec{a} \\cdot \\vec{b} + \\vec{b} \\cdot \\vec{b}) = -(0 + |\\vec{b}|^2) = -(3^2) = -9$।\nএবং $\\vec{c} \\cdot \\vec{a} = -(\\vec{a} + \\vec{b}) \\cdot \\vec{a} = -(\\vec{a} \\cdot \\vec{a} + \\vec{b} \\cdot \\vec{a}) = -(|\\vec{a}|^2 + 0) = -(4^2) = -16$।\nএই মানগুলি বসিয়ে পাই: $\\vec{c} \\times (\\vec{a} \\times \\vec{b}) = (-9)\\vec{a} - (-16)\\vec{b} = -9\\vec{a} + 16\\vec{b}$।\nএখন এর মান নির্ণয় করি: $|-9\\vec{a} + 16\\vec{b}|^2 = (-9\\vec{a} + 16\\vec{b}) \\cdot (-9\\vec{a} + 16\\vec{b}) = (-9)^2|\\vec{a}|^2 + (16)^2|\\vec{b}|^2 + 2(-9)(16)(\\vec{a} \\cdot \\vec{b})$।\nযেহেতু $\\vec{a} \\cdot \\vec{b} = 0$, আমরা পাই $|-9\\vec{a} + 16\\vec{b}|^2 = 81|\\vec{a}|^2 + 256|\\vec{b}|^2 = 81(4^2) + 256(3^2) = 81(16) + 256(9) = 1296 + 2304 = 3600$।\nসুতরাং, $|\\vec{c} \\times (\\vec{a} \\times \\vec{b})| = \\sqrt{3600} = 60$।	B
aed35f2e-37e1-442a-b518-86d99c84bcea	55086422-ef06-4659-a0be-10579b6abde5	06.	$c/\\sqrt{2}$ বেগে চলমান একটি কণার গতিশক্তি কত? (স্থির অবস্থায় কণাটির ভর $m_0$)	physics	introduction_to_modern_physics	A	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	আপেক্ষিকতা তত্ত্ব অনুযায়ী, গতিশীল কণার গতিশক্তি $E_k = (m - m_0)c^2$, যেখানে $m = \\frac{m_0}{\\sqrt{1 - v^2/c^2}}$। এখানে কণার বেগ $v = c/\\sqrt{2}$ দেওয়া আছে, তাই $v^2/c^2 = 1/2$। ফলে গতিশীল ভর $m = \\frac{m_0}{\\sqrt{1 - 1/2}} = \\sqrt{2}m_0$। সুতরাং গতিশক্তি $E_k = (\\sqrt{2}m_0 - m_0)c^2 = (\\sqrt{2} - 1)m_0c^2 \\approx (1.414 - 1)m_0c^2 = 0.414m_0c^2$।	A
2b101e61-141d-4d7f-b4c2-196138cf5fb2	55086422-ef06-4659-a0be-10579b6abde5	03.	একটি আদর্শ গ্যাস একটি তাপ অন্তরকের আবরণযুক্ত দৃঢ় পাত্রে শূন্য মাধ্যমে প্রসারিত হলো। ফলে নিম্নের কোনটি ঘটে?	physics	ideal_gas_and_gas_kinetics	A	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	একটি আদর্শ গ্যাসের অবাধ প্রসারণের (free expansion) ক্ষেত্রে বাহ্যিক চাপের বিরুদ্ধে কোনো কাজ সম্পাদিত হয় না, অর্থাৎ $W = 0$। যেহেতু পাত্রটি তাপ অন্তরক দ্বারা আবৃত, তাই তাপের আদান-প্রদান ঘটে না, অর্থাৎ $Q = 0$। তাপগতিবিদ্যার প্রথম সূত্রানুসারে, $\\Delta U = Q - W = 0 - 0 = 0$। সুতরাং, গ্যাসের অন্তস্থ শক্তির কোনো পরিবর্তন হয় না।	A
e1d1e7b0-bd77-4a21-95bc-ed3972271996	55086422-ef06-4659-a0be-10579b6abde5	22	একটি তারের ভিতর দিয়ে সাইনোসয়ডাল তরঙ্গ প্রবাহিত হলে তারের কণার সর্বোচ্চ দ্রুতি $v_s$। তারের একটি কণার সরণ সর্বোচ্চ সরণের অর্ধেক হলে ঐ কণার দ্রুতি হলো-	physics	periodic_motion	B	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	একটি সাইনোসয়ডাল তরঙ্গের কণার সর্বোচ্চ দ্রুতি $v_s = \\omega A$, যেখানে $A$ হলো বিস্তার এবং $\\omega$ হলো কৌণিক কম্পাঙ্ক। যেকোনো সরণ $y$ এর জন্য কণার দ্রুতি $v = \\omega \\sqrt{A^2 - y^2}$। প্রশ্নে দেওয়া আছে সরণ $y = A/2$। সুতরাং, কণার দ্রুতি $v = \\omega \\sqrt{A^2 - (A/2)^2} = \\omega \\sqrt{3A^2/4} = \\frac{\\sqrt{3}}{2} \\omega A$। যেহেতু $v_s = \\omega A$, তাই কণার দ্রুতি হবে $v = \\frac{\\sqrt{3}}{2} v_s$।	B
ae44507d-e359-4e47-b783-a5b9ca68f0eb	55086422-ef06-4659-a0be-10579b6abde5	25	যদি তড়িৎ ক্ষেত্রের প্রাবল্য $+x$ অক্ষ বরাবর ক্রিয়া করে এবং এর মান $E = cx^2$ হয়, যেখানে $c = \\text{ধ্রুবক}$, তবে তড়িৎ বিভব $V = ?$ 	physics	static_electricity	C	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	তড়িৎ প্রাবল্য $E$ এবং বিভব $V$ এর মধ্যে সম্পর্ক হলো $E = -\\frac{dV}{dx}$। এখান থেকে বিভব নির্ণয়ের সূত্রটি দাঁড়ায় $V = -\\int E \\, dx$। প্রশ্নে দেওয়া প্রাবল্যের মান $E = cx^2$ এই সমীকরণে বসিয়ে পাই $V = -\\int cx^2 \\, dx$। $x$ এর সাপেক্ষে সমাকলন (integration) করলে পাওয়া যায় $V = -\\frac{cx^3}{3}$। সুতরাং, তড়িৎ বিভবের মান হবে $-\\frac{cx^3}{3}$ যা অপশন (C) এর সাথে মিলে যায়।	C
59bfd3d6-e1bf-4233-8def-1f648b4c045e	55086422-ef06-4659-a0be-10579b6abde5	20	একটি নিউক্লিয়াস একটি নিউট্রন গ্রহণ করে একটি বিটা কণা ($\\beta^-$) নিঃসরণ করে ও দুইটি আলফা কণায় পরিণত হয়। আদি নিউক্লিয়াসের $A$ এবং $Z$ যথাক্রমে ছিল-	physics	atomic_model_and_nuclear_physics	C	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	ধরি, আদি নিউক্লিয়াসটি হলো $^A_Z X$। নিউক্লিয়াসটি একটি নিউট্রন ($^1_0 n$) গ্রহণ করলে এটি $^A_Z X + ^1_0 n \\rightarrow ^{A+1}_Z Y$ নিউক্লিয়াসে পরিণত হয়। এরপর এই নিউক্লিয়াসটি একটি বিটা কণা ($\beta^-$ বা $^0_{-1} e$) নিঃসরণ করে: $^{A+1}_Z Y \\rightarrow ^{A+1}_{Z+1} Z' + ^0_{-1} e$। অবশেষে, এই $Z'$ নিউক্লিয়াসটি দুইটি আলফা কণায় ($^4_2 He$) পরিণত হয়: $^{A+1}_{Z+1} Z' \\rightarrow 2 \\times ^4_2 He$। ভর সংখ্যা এবং পারমাণবিক সংখ্যার নিত্যতা সূত্রানুসারে, আমরা পাই: ভর সংখ্যা $A+1 = 2 \\times 4 = 8$ এবং পারমাণবিক সংখ্যা $Z+1 = 2 \\times 2 = 4$। এই সমীকরণগুলো সমাধান করলে পাই $A = 8 - 1 = 7$ এবং $Z = 4 - 1 = 3$। সুতরাং, আদি নিউক্লিয়াসের $A$ এবং $Z$ যথাক্রমে 7 এবং 3 ছিল।	C
b1f34359-813c-454a-87d2-8be081eec7d0	55086422-ef06-4659-a0be-10579b6abde5	19	একটি পিয়ানো তারের দৈর্ঘ্য $L$ এর ভর $M$। যদি এর মূল কম্পাঙ্ক $f$ হয়, তবে তারে টান হলো:	physics	periodic_motion	B	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	একটি পিয়ানো তারের মূল কম্পাঙ্কের সূত্র হলো $f = \\frac{1}{2L} \\sqrt{\\frac{T}{\\mu}}$, যেখানে $L$ তারের দৈর্ঘ্য, $T$ তারের টান এবং $\\mu$ রৈখিক ভর ঘনত্ব। রৈখিক ভর ঘনত্ব $\\mu = \\frac{M}{L}$, যেখানে $M$ তারের ভর। এই মানটি সূত্রে প্রতিস্থাপন করে পাই $f = \\frac{1}{2L} \\sqrt{\\frac{T}{M/L}} = \\frac{1}{2L} \\sqrt{\\frac{TL}{M}}$। উভয় পক্ষকে বর্গ করে পাই $f^2 = \\frac{1}{4L^2} \\frac{TL}{M} = \\frac{T}{4LM}$। এখন, টান $T$ এর জন্য সমাধান করলে পাই $T = 4LMf^2$।	B
a772c84b-1fe5-43b3-8631-af02fd8450a1	55086422-ef06-4659-a0be-10579b6abde5	16	শূন্য মাধ্যমে প্রবাহমান একটি সমতল তরঙ্গমুখের তড়িৎ চুম্বকীয় তরঙ্গের বিদ্যুৎ ও চৌম্বক ক্ষেত্রের বিস্তারের অনুপাত, $E/B$ এর মান S.I এককে হলো:	physics	introduction_to_modern_physics	C	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	শূন্য মাধ্যমে প্রবাহমান একটি সমতল তড়িৎ চুম্বকীয় তরঙ্গের জন্য, তড়িৎ ক্ষেত্রের বিস্তার ($E$) এবং চৌম্বক ক্ষেত্রের বিস্তার ($B$) এর অনুপাত শূন্য মাধ্যমে আলোর বেগের ($c_0$) সমান। এই সম্পর্কটি তড়িৎ চুম্বকীয় তরঙ্গের মৌলিক বৈশিষ্ট্যগুলির মধ্যে একটি। গাণিতিকভাবে, এটি $E/B = c_0$ দ্বারা প্রকাশ করা হয়। সুতরাং, সঠিক উত্তর হলো শূন্য মাধ্যমে আলোর বেগ।	C
895509f8-b03b-428b-9204-b769960ab6bb	55086422-ef06-4659-a0be-10579b6abde5	01.	$\\ce{TiO2(s)}$ এবং $\\ce{CO(g)}$ এর 'প্রমাণ গঠন এনথালপি' যথাক্রমে $-940\\text{ kJ mol}^{-1}$ এবং $-110\\text{ kJ mol}^{-1}$। $\\ce{TiO2(s) + 2C(s) -> Ti(s) + 2CO(g)}$, এই বিক্রিয়ার প্রমাণ এনথালপির পরিবর্তন কত?	chemistry	chemical_changes	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
70d67fa4-ff2f-4dce-8d8d-a05722edbb25	55086422-ef06-4659-a0be-10579b6abde5	02.	$\\ce{Li}$ এবং $\\ce{Ne}$ এর মধ্যবর্তী একটি মৌলের ১ম সাতটি আয়নিকরণ শক্তিসমূহ হলো: $1310, 3390, 5320, 7450, 11000, 13300, 71000\\text{ kJ mol}^{-1}$। মৌলটির পরমাণুর যোজ্যতা শেলের ইলেকট্রন বিন্যাস কী?	chemistry	periodic_properties_of_elements_and_chemical_bonding	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
ce2fc38e-54aa-47ce-937d-57af1aed1ee7	55086422-ef06-4659-a0be-10579b6abde5	03	নিচের কোনটি গ্যালভানিক সেল $\\ce{Zn(s)/Zn^{2+}(aq) || Cu^{2+}(aq)/Cu(s)}$ এর বিভব বাড়ায়?	chemistry	electrochemistry	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
929116a7-ddf4-40a5-a2bd-420368fee05c	55086422-ef06-4659-a0be-10579b6abde5	04	কোন বিক্রিয়ার "বিক্রিয়া এনথালপি" "আদর্শ গঠন এনথালপি" নির্দেশ করে?	chemistry	chemical_changes	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
625f1e10-b3af-4e25-9a59-3d91c728f490	55086422-ef06-4659-a0be-10579b6abde5	05	কোন পরমাণু বা আয়নে ইলেকট্রন ও নিউট্রনের সংখ্যা সমান?	chemistry	qualitative_chemistry	D	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
82853947-6870-412d-ac9b-8df48e33c00d	55086422-ef06-4659-a0be-10579b6abde5	06	কোন লবণ গাঢ় সালফিউরিক এসিডের সাথে বিক্রিয়া করে সালফার তৈরি করে?	chemistry	periodic_properties_of_elements_and_chemical_bonding	D	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
53856c05-7c1d-490d-9842-1cbd1379dac8	55086422-ef06-4659-a0be-10579b6abde5	07	$\\ce{2KNO3 -> 2KNO2 + O2}$ বিক্রিয়াটিতে জারিত ও বিজারিত মৌল যথাক্রমে কী কী?	chemistry	periodic_properties_of_elements_and_chemical_bonding	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
b0ec239f-dc9a-4f83-aba6-53e6f14d01d2	55086422-ef06-4659-a0be-10579b6abde5	08	$\\ce{Al2Cl6}$ অণুটিতে সমযোজী ও সন্নিবেশ সমযোজী বন্ধনের সংখ্যা যথাক্রমে কয়টি?	chemistry	periodic_properties_of_elements_and_chemical_bonding	A	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
84546171-00b6-447b-b7dc-488380953491	55086422-ef06-4659-a0be-10579b6abde5	09	প্রথম ট্রানজিশন ধাতু সিরিজের একটি ধাতু হতে প্রাপ্ত একটি $\\ce{M^{3+}}$ আয়নে পাঁচটি ইলেকট্রন 3d সাবশেলে অবস্থিত। $\\ce{M^{3+}}$ আয়নটি কী হতে পারে?	chemistry	periodic_properties_of_elements_and_chemical_bonding	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
6fb6f30d-7d6c-4c7e-a2d5-5cc6e78aeb86	55086422-ef06-4659-a0be-10579b6abde5	10	ব্যাসার্ধের সঠিক ক্রম কোনটি?	chemistry	periodic_properties_of_elements_and_chemical_bonding	A	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
db1f1d93-1124-496f-95b9-39b58ac51593	55086422-ef06-4659-a0be-10579b6abde5	11	$\\ce{CH3CH(OH)CH2CHO}$ এবং $\\ce{CH3COCH2CH2OH}$ এর মধ্যে পার্থক্য করার জন্য কোন বিকারক ব্যবহার করা যেতে পারে?	chemistry	organic_chemistry	D	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
a5a5df8b-0438-4c5e-84ee-97e93fe94eee	55086422-ef06-4659-a0be-10579b6abde5	12	প্রমাণ তাপমাত্রা ও চাপে (STP) কোন গ্যাসের 1.0 গ্রাম সবচেয়ে বেশি আয়তন দখল করে?	chemistry	quantitative_chemistry	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
729c646b-8532-4fd3-9772-6e99cc0c94ec	55086422-ef06-4659-a0be-10579b6abde5	13	কোন যৌগটি কেন্দ্রাকর্ষী সংযোজন বিক্রিয়া দিবে?	chemistry	organic_chemistry	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
ee2d55e5-ce12-45d5-94cc-60fa5b0d86c8	55086422-ef06-4659-a0be-10579b6abde5	14	কোন যৌগটি জলীয় NaOH এর সঙ্গে বিক্রিয়া করবে না?	chemistry	organic_chemistry	A	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
0736b02b-9661-4de6-b0c0-548a25e0bbff	55086422-ef06-4659-a0be-10579b6abde5	15	50 mL 1.0 M NaOH এবং 50 mL 0.8 M HCl এর মিশ্রণের pH কত?	chemistry	quantitative_chemistry	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
c0b04562-271b-4a8e-9233-492b18ab18fe	55086422-ef06-4659-a0be-10579b6abde5	16	$2.2\\,\\text{g}$ $\\ce{C3H8}$ পূর্ণ দহন করে $\\ce{CO2}$ ও $\\ce{H2O}$ তৈরি করতে কত মোল $\\ce{O2}$ প্রয়োজন?	chemistry	quantitative_chemistry	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
14e4de09-de4d-4164-97c0-6bab31ffc5eb	55086422-ef06-4659-a0be-10579b6abde5	17	প্রথম ক্রমের বিক্রিয়ার হার ধ্রুবকের মান নিচের কোনটির উপর নির্ভরশীল নয়?	chemistry	chemical_changes	D	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
d8fcce4d-8374-4016-9f7d-0191b5610c9e	55086422-ef06-4659-a0be-10579b6abde5	18	কোন এসিডের তীব্রতা সবচেয়ে বেশি?	chemistry	organic_chemistry	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
3128d748-503d-4d0a-9ac6-df5f7a81e93f	55086422-ef06-4659-a0be-10579b6abde5	19	$0.125\\,\\text{M}$ $\\ce{HCl}$ এসিডের $500\\,\\text{মি.লি.}$ দ্রবণকে $0.100\\,\\text{M}$ লঘু দ্রবণে পরিণত করতে কতটুকু পানি যোগ করতে হবে?	chemistry	quantitative_chemistry	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
1a2812c3-4af9-4e94-bf3e-6b81307d291a	55086422-ef06-4659-a0be-10579b6abde5	20	নিম্নোক্ত কোনটি দ্বারা ফেনল থেকে পিকরিক এসিড প্রস্তুত করা হয়?	chemistry	organic_chemistry	A	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
3e425357-2da0-435c-a491-0c029de6471a	55086422-ef06-4659-a0be-10579b6abde5	21	নিচের কোনটিতে বেশি পরমাণু আছে?	chemistry	quantitative_chemistry	A	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
6992614e-d77c-4d24-8695-f4699ab8a47f	55086422-ef06-4659-a0be-10579b6abde5	22	গ্রিনহাউজ প্রভাবের জন্য সর্বাপেক্ষা দায়ী কোন গ্যাসটি?	chemistry	environmental_chemistry	D	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
55805a43-a27d-4c26-8439-de828ba47cb0	55086422-ef06-4659-a0be-10579b6abde5	23	নিচের কোন যৌগের স্ফুটনাঙ্ক সবচেয়ে বেশি?	chemistry	periodic_properties_of_elements_and_chemical_bonding	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
f3f44de8-3551-49a1-9366-ec0bedf8c9b5	55086422-ef06-4659-a0be-10579b6abde5	24	$\\ce{CuSO4}$ এর জলীয় দ্রবণে $0.5$ অ্যাম্পিয়ার তড়িৎপ্রবাহ $10$ মিনিট ব্যাপী চালনা করলে কী পরিমাণ কপার জমা হবে?	chemistry	electrochemistry	A	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
34ad18c2-3e65-4c20-8121-c67cf5764f6f	55086422-ef06-4659-a0be-10579b6abde5	25	$sp^3$ হাইব্রিডাইজেশনে কয়টি $sp^3$ হাইব্রিড অরবিটাল তৈরি হয়?	chemistry	periodic_properties_of_elements_and_chemical_bonding	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
9db9d914-e93f-4de3-b6bf-30b1158f5173	55086422-ef06-4659-a0be-10579b6abde5	26	নিম্নলিখিত জারণ-বিজারণ বিক্রিয়ার উৎপাদসমূহ কী?\n$\\ce{K2Cr2O7(aq) + H2SO4(aq) + FeSO4(aq) ->}$ উৎপাদসমূহ	chemistry	quantitative_chemistry	D	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
ca252eac-40d5-4fe9-aad5-cef587161e6c	55086422-ef06-4659-a0be-10579b6abde5	27	যৌগ $X$, $\\ce{C6H12O}$, অম্লীয় $\\ce{Na2Cr2O7}$ দ্বারা জারিত হয়ে $Y$ যৌগ হয়। $Y$ যৌগটি অল্প পরিমাণ ঘন $\\ce{H2SO4}$ এর উপস্থিতিতে ইথানলের সঙ্গে বিক্রিয়া করে $Z$ যৌগ তৈরি করে। $Z$ এর সংকেত কী?	chemistry	organic_chemistry	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
333ebc97-aa2c-4c66-ae65-d81c97d2bfc8	55086422-ef06-4659-a0be-10579b6abde5	28	নিচের বিক্রিয়া স্কিমে $X$ ও $Y$ কী?\n$\\ce{CH3CH2CH2Br ->[X] CH3CH2CH2CN ->[Y] CH3CH2CH2COOH}$	chemistry	organic_chemistry	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
42981bc8-705a-4165-8fac-a289a0673583	55086422-ef06-4659-a0be-10579b6abde5	29	নিচের কোন যৌগটি চামড়া প্রক্রিয়াজাতকরণে ব্যবহৃত হয়?	chemistry	economic_chemistry	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
2c6aa640-77b4-4d21-a7db-6d7425228348	55086422-ef06-4659-a0be-10579b6abde5	30	নিম্নোক্ত কোনটি গ্লাসকে ক্ষয় করে?	chemistry	periodic_properties_of_elements_and_chemical_bonding	D	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
dedf970c-bc28-42e4-97a9-e40fc3b52910	55086422-ef06-4659-a0be-10579b6abde5	01.	$f(x) = 1 + x^3$ বক্ররেখাটির সাথে $x$-অক্ষের ছেদবিন্দুর সংখ্যা -	mathematics	polynomials_and_polynomial_equations	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
9756187f-492e-469e-8a23-5440b02e118d	55086422-ef06-4659-a0be-10579b6abde5	02.	$y = \\frac{(1+x)}{(1-x)}$ হলে $\\frac{dy}{dx}$ এর মান -	mathematics	differential_calculus	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
dc71a03f-b7c0-4e24-b019-2104aeda7e06	55086422-ef06-4659-a0be-10579b6abde5	04.	$y = kx$ সরলরেখাটি $y = x^2 + 4$ বক্ররেখার স্পর্শক হলে $k$ এর একটি মান-	mathematics	straight_lines	D	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
e67dc779-dc77-43b4-b0ce-c4894489103e	55086422-ef06-4659-a0be-10579b6abde5	05.	$y = 2$ এবং $y = |x|$ রেখাগুলো দ্বারা আবদ্ধ ক্ষেত্রের ক্ষেত্রফল-	mathematics	integral_calculus	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "graph", "box_2d": null, "filename": null, "markdown": null, "page_index": 5, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2018-2019-A-Unit/page_6", "extraction_status": "needs_review"}]	\N	\N
69a58ffa-5f06-43ad-9351-93fcac89a144	55086422-ef06-4659-a0be-10579b6abde5	06.	$\\int \\sqrt{e^x} dx = ?$	mathematics	integral_calculus	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
4c0d955d-1d07-4287-bf21-188b604a0255	55086422-ef06-4659-a0be-10579b6abde5	07.	$\\tan^{-1} \\frac{2}{3} + \\cos^{-1} \\frac{2}{\\sqrt{13}} = ?$	mathematics	inverse_trigonometric_functions_and_trigonometric_equations	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "geometry_figure", "box_2d": null, "filename": null, "markdown": null, "page_index": 5, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2018-2019-A-Unit/page_6", "extraction_status": "needs_review"}]	\N	\N
235b4eb3-fa4e-4e55-a04b-7eb052aecf74	55086422-ef06-4659-a0be-10579b6abde5	08.	$\\int \\frac{\\tan(\\sin^{-1} x)}{\\sqrt{1-x^2}} dx = ?$	mathematics	integral_calculus	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
94d6936a-6e54-46fc-88a2-0f7b1a95d577	55086422-ef06-4659-a0be-10579b6abde5	09.	$y = b$ এবং $\\sqrt{3}x - y + 1 = 0$ রেখাদ্বয়ের অন্তর্ভুক্ত সূক্ষ্মকোণের মান-	mathematics	straight_lines	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "graph", "box_2d": null, "filename": null, "markdown": null, "page_index": 5, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2018-2019-A-Unit/page_6", "extraction_status": "needs_review"}]	\N	\N
6ab638f1-de68-40dc-8cbf-9d70d18aed9e	55086422-ef06-4659-a0be-10579b6abde5	10.	$\\cot \\theta \\cot 3\\theta = 1$ সমীকরণের সাধারণ সমাধান-	mathematics	inverse_trigonometric_functions_and_trigonometric_equations	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
0d5eb94e-46e9-4e0a-9b5c-9795b00a3a2b	55086422-ef06-4659-a0be-10579b6abde5	11.	$2r \\sin^2 \\frac{\\theta}{2} = 1$ এর কার্তেসীয় সমীকরণ-	mathematics	conics	A	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
8ca720b4-8d46-40a9-85b9-71a1f611773c	55086422-ef06-4659-a0be-10579b6abde5	12	$y = x + 4$ এবং $y = x$ রেখাদ্বয়ের লম্ব দূরত্ব-	mathematics	straight_lines	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
4bf22e12-a335-4efa-9b66-8dd4cf2db6d7	55086422-ef06-4659-a0be-10579b6abde5	13	$y^2 - 4y - x^2 + 6x = 12$ সমীকরণটি কোন ধরনের কনিক?	mathematics	conics	D	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
e9e5918b-87d8-40d3-821b-8026e321680f	55086422-ef06-4659-a0be-10579b6abde5	14	$2x^2 - 8y^2 = 2$ অধিবৃত্তের উৎকেন্দ্রিকতার মান-	mathematics	conics	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
ce6762bd-9ad2-4110-bd59-4b014abe8a95	55086422-ef06-4659-a0be-10579b6abde5	15	$\\lim_{x \\to 0} \\frac{\\sin x}{\\tan^{-1}(3x)} = ?$	mathematics	differential_calculus	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
6a905554-2dd1-4a7c-a500-bd9e825e1c4f	55086422-ef06-4659-a0be-10579b6abde5	16	$x^2 - 7x + 2 = 0$ সমীকরণের মূলদ্বয় হতে $2$ কম মূলবিশিষ্ট সমীকরণটি	mathematics	polynomials_and_polynomial_equations	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
c04c6ea0-7ee3-4e5a-85dc-b72c7f6f3020	55086422-ef06-4659-a0be-10579b6abde5	17	$z = (-4 + 3i)/i$ এর কাল্পনিক অংশ-	mathematics	complex_numbers	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
723ea36f-88d0-4670-befb-326b583f045b	55086422-ef06-4659-a0be-10579b6abde5	18	$^nC_1 + ^nC_2 + ^nC_3 + ... + ^nC_n = ?$	mathematics	binomial_expansion	D	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
19108d8a-6555-46b1-9f75-d93b8fd0e4c6	55086422-ef06-4659-a0be-10579b6abde5	20	$3x^2 + 3y^2 - 5x - 6y + 4 = 0$ বৃত্তটির কেন্দ্র-	mathematics	circles	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
5b085180-8d95-4faa-b246-1baa9dc2dc92	55086422-ef06-4659-a0be-10579b6abde5	21	'PERMUTATION' শব্দটির বর্ণগুলোর মধ্যে স্বরবর্ণের অবস্থান পরিবর্তন না করে বর্ণগুলোকে কত রকমে পুনরায় সাজানো যাবে?	mathematics	permutations_and_combinations	D	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
5816d1c2-fe10-419f-97a9-c4b2995fe001	55086422-ef06-4659-a0be-10579b6abde5	22	$120$ জন ছাত্রের মধ্যে $75$ জন ক্রিকেট খেলে এবং $65$ জন ফুটবল খেলে। কতজন উভয় খেলাই খেলে?	mathematics	measure_of_dispersion_and_probability	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
37460786-8f6a-4562-a11d-a167c6305daf	55086422-ef06-4659-a0be-10579b6abde5	23	$|3 - \\frac{1}{x}| < \\frac{1}{2}$ অসমতাটির সমাধান সেট-	mathematics	real_numbers_and_inequalities	A	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
9b7cbbe1-1c92-4bd9-b792-34480ccd831c	55086422-ef06-4659-a0be-10579b6abde5	24	$(x^2 + \\frac{2}{x})^6$ এর বিস্তৃতিতে $x$ মুক্ত পদ-	mathematics	binomial_expansion	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
0b060917-e53b-4c70-8db2-389b2eaf1ecf	55086422-ef06-4659-a0be-10579b6abde5	25	4 থেকে 15 পর্যন্ত সংখ্যা হতে যে কোনো একটিকে দৈবচয়নের মাধ্যমে নিলে সেই সংখ্যাটি মৌলিক অথবা 3 এর গুণিতক হওয়ার সম্ভাবনা কত?	mathematics	measure_of_dispersion_and_probability	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
d9196d07-6259-4a68-9f98-a502a20080f1	55086422-ef06-4659-a0be-10579b6abde5	26	$f(x) = \\frac{-1}{|1-x|}$ ফাংশনের রেঞ্জ-	mathematics	functions_and_graphs	D	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
d8efe0db-6cfa-4e4c-b111-c7fe8248c4bc	55086422-ef06-4659-a0be-10579b6abde5	27	ভেক্টর $\\vec{u} = \\hat{i} + \\hat{j}$ ও $\\vec{v} = \\hat{j} + \\hat{k}$ এর অন্তর্ভুক্ত কোণ	mathematics	vectors	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
244f8058-cb97-45c0-b78e-4b2393795704	55086422-ef06-4659-a0be-10579b6abde5	28	$x^2 + y^2 + 2x - 4y + 4 = 0$ বৃত্তের একটি স্পর্শক	mathematics	circles	A	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
47a2db81-bbd5-4f67-bd3d-1e0423644fb0	55086422-ef06-4659-a0be-10579b6abde5	29	$\\cos^2(60^\\circ + A) + \\cos^2(60^\\circ - A)$ এর মান-	mathematics	associated_trigonometric_angles	A	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
f1de21b5-a199-45b1-8c93-94c0a1fab0e2	55086422-ef06-4659-a0be-10579b6abde5	30	$x = \\frac{1}{2}(-1 + \\sqrt{-3})$ এবং $y = \\frac{1}{2}(-1 - \\sqrt{-3})$ হলে, $x^2 + xy + y^2$ এর মান-	mathematics	complex_numbers	A	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
0ff94e30-07be-49f1-b626-ab10a70868e0	55086422-ef06-4659-a0be-10579b6abde5	01	কোনটিতে গাত্রীয় অমরা বিন্যাস পাওয়া যায়?	biology	gymnosperms_and_angiosperms	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
ac4ed30f-eb94-4a9f-9732-474d064d0a28	55086422-ef06-4659-a0be-10579b6abde5	02	অরীয় প্রতিসাম্যতা দেখা যায়-	biology	animal_diversity_and_classification	D	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
7b964edd-5141-4241-8361-6607fdc97545	55086422-ef06-4659-a0be-10579b6abde5	03	নিচের কোন রোগটি লিথাল জিনের প্রভাবে সংঘটিত হয়?	biology	genetics_and_evolution	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
befc229d-d0b2-42f9-9ff5-885b2df37ab8	55086422-ef06-4659-a0be-10579b6abde5	04	গ্লিসন ক্যাপসুল পর্দা মানবদেহের যে অঙ্গে দেখা যায়-	biology	human_physiology_digestion_and_absorption	A	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
e8034aa9-cb42-4061-a490-075e61ccb4ef	55086422-ef06-4659-a0be-10579b6abde5	05	কোষ বিভাজনের কোন পর্যায়ে টেট্রাডসমূহ পাওয়া যায়?	biology	cell_division	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
dfa30cb6-c26d-4978-9e28-8a6a63583eea	55086422-ef06-4659-a0be-10579b6abde5	06	গিনিপিগে দাঁতের সংখ্যা-	biology	animal_identity	A	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
639e19bd-dedd-4d8f-b4a9-e301c01c61bd	55086422-ef06-4659-a0be-10579b6abde5	07	নিচের কোনটিতে ইমব্রিকেট পুষ্পপত্র বিন্যাস থাকে?	biology	gymnosperms_and_angiosperms	A	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
252b88c0-d3fd-4d5d-85a5-b770a56ddc48	55086422-ef06-4659-a0be-10579b6abde5	08.	মানবদেহের রক্তে রক্তরসের হার কত?	biology	human_physiology_blood_and_circulation	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
611563ab-2616-4db5-a6fd-edf5d4601122	55086422-ef06-4659-a0be-10579b6abde5	09.	নিচের কোনটি রক্ত জমাট বাঁধতে বাধা দেয়?	biology	human_physiology_blood_and_circulation	A	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
c8dd689f-0b80-43bc-81da-9f1e01122104	55086422-ef06-4659-a0be-10579b6abde5	10.	সালামাণ্ডার কোন বর্গের প্রাণী?	biology	animal_diversity_and_classification	D	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
7d80b0ca-0599-4eb7-9955-862b2ff6c816	55086422-ef06-4659-a0be-10579b6abde5	11.	ডিম পাড়ে এমন স্তন্যপায়ী প্রাণী-	biology	animal_diversity_and_classification	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
e29f7dc7-dab8-4560-89ac-02ebea288803	55086422-ef06-4659-a0be-10579b6abde5	12.	সরীসৃপ সংক্রান্ত জ্ঞানকে কী বলা হয়?	biology	animal_diversity_and_classification	A	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
bab9447a-4fc7-419a-97a0-cb423d80687d	55086422-ef06-4659-a0be-10579b6abde5	13.	পরিপূরক জিনের কারণে প্রাপ্ত ফিনোটাইপিক অনুপাত কোনটি?	biology	genetics_and_evolution	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
acdd52eb-444b-4a96-a782-26ebde296637	55086422-ef06-4659-a0be-10579b6abde5	14.	'Enquiry into Plants' বইটি রচনা করেন-	biology	gymnosperms_and_angiosperms	D	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
b0dd1f29-90ac-4c47-9952-2fd84fadebd6	55086422-ef06-4659-a0be-10579b6abde5	15.	কুইড যে পর্বভুক্ত প্রাণী-	biology	animal_diversity_and_classification	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
dfc6a5de-674e-46ad-9c2b-77a46abe8c5d	55086422-ef06-4659-a0be-10579b6abde5	16.	হিপনোটক্সিন কোন ধরনের কোষে দেখা যায়?	biology	animal_identity	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
090e1d6a-890d-4fb7-92f8-ad252286e587	55086422-ef06-4659-a0be-10579b6abde5	17.	করোটির সর্ববৃহৎ অস্থির নাম-	biology	human_physiology_locomotion_and_movement	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
1043b4ba-f62b-45b2-99b5-0c1b5636ed45	55086422-ef06-4659-a0be-10579b6abde5	18.	লুটিনাইজিং হরমোন যে কাজকে প্রভাবিত করে-	biology	human_physiology_coordination_and_control	D	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
17ca7102-b756-4c15-a0cd-82bd42af56fe	55086422-ef06-4659-a0be-10579b6abde5	19.	কোনটি চা গাছে রোগ সৃষ্টি করে?	biology	microorganisms	D	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
1a22353f-b8d9-44d2-bd07-3872a6e4ae09	55086422-ef06-4659-a0be-10579b6abde5	20.	নিচের কোন উদ্ভিদে স্টোমিয়াম থাকে?	biology	bryophyta_and_pteridophyta	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
aa8b6797-a138-460b-8ed0-1ea04b90668d	55086422-ef06-4659-a0be-10579b6abde5	21.	কোন অণুজীব নাইট্রোজেন সংবন্ধনে সক্ষম?	biology	microorganisms	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
748e1a23-53a8-4c1b-b48b-2d4e03e00118	55086422-ef06-4659-a0be-10579b6abde5	22.	সংখ্যার পিরামিডে কোন জীবের আধিক্য থাকে?	biology	environment_expansion_and_conservation_of_organisms	A	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
8a2500b7-832b-4c7a-9124-bf9a97170121	55086422-ef06-4659-a0be-10579b6abde5	23.	মানব চক্ষুতে কয়টি রেক্টাস পেশি থাকে?	biology	human_physiology_coordination_and_control	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
1b6b68e8-23cc-47db-8064-0171f9fa6776	55086422-ef06-4659-a0be-10579b6abde5	24.	নিচের কোনটি ফসফোলিপিড?	biology	cell_chemistry	D	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
47119bcf-aec2-4d82-9fca-51f0a1187435	55086422-ef06-4659-a0be-10579b6abde5	25.	পলিপেপটাইড ট্রান্সলেশনের জন্য টারমিনেশন কোডন কোনটি?	biology	cell_and_its_structure	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
57eb8fb5-6663-483d-b5de-e6259ebff3d0	55086422-ef06-4659-a0be-10579b6abde5	26	কোষ প্রাচীরের ক্ষুদ্রতম গাঠনিক একক-	biology	cell_and_its_structure	A	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
42ed5662-52b7-42ef-b9db-62d793d7586d	55086422-ef06-4659-a0be-10579b6abde5	27	যে ধরনের উদ্ভিদে পরিবহন তন্ত্র নেই-	biology	bryophyta_and_pteridophyta	A	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
3b791f22-9541-4e07-9e63-a9053b682564	55086422-ef06-4659-a0be-10579b6abde5	28	নিচের কোনটিতে হরমোগোনিয়া থাকে-	biology	algae_and_fungi	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
2d074995-ec0c-4e8c-b0b0-4ba70e47708a	55086422-ef06-4659-a0be-10579b6abde5	29	বোঝামি কাছিমের বৈজ্ঞানিক নাম-	biology	animal_diversity_and_classification	B	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
35282711-e0a6-4f6e-ae17-3568df55c9ea	55086422-ef06-4659-a0be-10579b6abde5	30	গ্লুকোজ ভেঙে ইথাইল অ্যালকোহল ও পানিতে রূপান্তরিত হওয়ার বিক্রিয়ায় যে এনজাইম জড়িত-	biology	plant_physiology	C	\N	pending	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	\N	\N
f69b2d12-2038-41a9-b416-d3c480736f5b	55086422-ef06-4659-a0be-10579b6abde5	27	হাইড্রোজেন পরমাণুর প্রথম বোর কক্ষে ইলেকট্রনের মোটশক্তি $-13.6\\text{ eV}$। তৃতীয় বোর কক্ষে মোটশক্তি কত?	physics	atomic_model_and_nuclear_physics	A	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	হাইড্রোজেন পরমাণুর $n$-তম বোর কক্ষে ইলেকট্রনের মোটশক্তি $E_n = \\frac{E_1}{n^2}$ সমীকরণ দ্বারা নির্ণয় করা হয়। এখানে প্রথম কক্ষের শক্তি $E_1 = -13.6\\,\\text{eV}$ এবং তৃতীয় কক্ষের জন্য $n = 3$। মানগুলো বসিয়ে পাই, $E_3 = \\frac{-13.6\\,\\text{eV}}{3^2} = \\frac{-13.6}{9}\\,\\text{eV} \\approx -1.51\\,\\text{eV}$। সুতরাং, তৃতীয় বোর কক্ষে মোটশক্তি প্রায় $-1.5\\,\\text{eV}$ যা অপশন (A) এর সাথে মিলে যায়।	A
28c07dfe-cb42-44d4-9f2f-dda64ffb6882	55086422-ef06-4659-a0be-10579b6abde5	28	সরণ পাওয়া যায়:	physics	dynamics	C	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	সরণ ($s$) এবং বেগের ($v$) মধ্যে সম্পর্ক হলো $s = \\int v \\, dt$। জ্যামিতিকভাবে, কোনো ফাংশনের সমাকলন (integration) ওই ফাংশনের লেখচিত্রের নিচের ক্ষেত্রফল নির্দেশ করে। সুতরাং, বেগ-সময় ($v-t$) লেখচিত্রের নিচের ক্ষেত্রফল থেকে সরণ পাওয়া যায়। অন্যদিকে, বেগ-সময় লেখচিত্রের ঢাল ত্বরণ নির্দেশ করে এবং ত্বরণ-সময় লেখচিত্রের নিচের ক্ষেত্রফল বেগের পরিবর্তন নির্দেশ করে।	C
6b7a2340-d204-4c9a-a820-90576cb4732e	05a449d9-5db0-488f-936f-ab50cc72299e	09.	$6\\,\\Omega$ এবং $12\\,\\Omega$ মানের দুইটি রোধ সমান্তরালে সংযুক্ত আছে। এই সমান্তরাল সংযোগকে একটি $4\\,\\Omega$ মানের রোধ এবং $24\\,\\text{V}$ ব্যাটারির সাথে সিরিজে সংযুক্ত করা হলো। উক্ত সংযোগে $6\\,\\Omega$ রোধের ভিতরে প্রবাহিত তড়িৎ-এর পরিমাণ কত?	physics	current_electricity	A	\N	generated	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	$6\\,\\Omega$ এবং $12\\,\\Omega$ রোধদ্বয়ের সমান্তরাল তুল্য রোধ $R_p = \\frac{6 \\times 12}{6 + 12} = 4\\,\\Omega$। বর্তনীর মোট রোধ $R = R_p + 4\\,\\Omega = 4 + 4 = 8\\,\\Omega$। সুতরাং বর্তনীর মূল তড়িৎ প্রবাহ $I = \\frac{V}{R} = \\frac{24\\,\\text{V}}{8\\,\\Omega} = 3\\,\\text{A}$। তড়িৎ বিভাজন নীতি অনুযায়ী $6\\,\\Omega$ রোধের মধ্য দিয়ে প্রবাহিত তড়িৎ $I_1 = I \\times \\frac{12}{6 + 12} = 3 \\times \\frac{12}{18} = 2\\,\\text{A}$।	A
18cb2450-e0d6-41d9-87b7-d55e28876177	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	19	যদি তড়িৎপ্রবাহের সমীকরণ $I(t) = 20 \\sin(628t)$ হয়, তাহলে তড়িৎ এর কম্পাঙ্ক ও r.m.s মান কত?	physics	current_electricity	A	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	প্রদত্ত তড়িৎপ্রবাহের সমীকরণটি হলো $I(t) = 20 \\sin(628t)$। এটিকে আদর্শ AC সমীকরণ $I(t) = I_0 \\sin(\\omega t)$ এর সাথে তুলনা করে পাই, পিক তড়িৎপ্রবাহ $I_0 = 20\\,\\text{A}$ এবং কৌণিক কম্পাঙ্ক $\\omega = 628\\,\\text{rad/s}$।\nকম্পাঙ্ক $f$ নির্ণয়ের জন্য, আমরা জানি $\\omega = 2\\pi f$। সুতরাং, $f = \\frac{\\omega}{2\\pi} = \\frac{628}{2 \\times 3.14} = \\frac{628}{6.28} = 100\\,\\text{Hz}$।\nRMS (root mean square) মান নির্ণয়ের জন্য, আমরা জানি $I_{rms} = \\frac{I_0}{\\sqrt{2}}$। সুতরাং, $I_{rms} = \\frac{20}{\\sqrt{2}} = \\frac{20}{1.414} \\approx 14.14\\,\\text{A}$।\nঅতএব, তড়িৎ এর কম্পাঙ্ক $100\\,\\text{Hz}$ এবং r.m.s মান $14.14\\,\\text{A}$।	A
25ec7bf5-1589-4329-b1f7-516f0f8d37a0	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	02	চিত্রে প্রদর্শিত বর্তনীতে প্রবাহমাত্রা $I_2$ কত হবে? \n[IMAGE_1]	physics	current_electricity	A	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "circuit_diagram", "box_2d": null, "filename": "p01_q02_01.png", "markdown": null, "page_index": 0, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}]	প্রথমে, 12 Ω এবং 10 Ω রোধ দুটি সমান্তরাল সমবায়ে আছে। এদের তুল্য রোধ হবে $R_p = \\frac{12\\,\\Omega \\times 10\\,\\Omega}{12\\,\\Omega + 10\\,\\Omega} = \\frac{120}{22}\\,\\Omega = \\frac{60}{11}\\,\\Omega$. এরপর, এই $R_p$ রোধটি 20 Ω রোধের সাথে শ্রেণী সমবায়ে আছে। সুতরাং, বর্তনীর মোট তুল্য রোধ হবে $R_{eq} = 20\\,\\Omega + \\frac{60}{11}\\,\\Omega = \\frac{220 + 60}{11}\\,\\Omega = \\frac{280}{11}\\,\\Omega$. বর্তনীর মোট প্রবাহমাত্রা $I = \\frac{V}{R_{eq}} = \\frac{9\\,\\text{V}}{\\frac{280}{11}\\,\\Omega} = \\frac{99}{280}\\,\\text{A}$. সমান্তরাল সমবায়ের আড়াআড়ি বিভব পার্থক্য $V_p = I \\times R_p = \\frac{99}{280}\\,\\text{A} \\times \\frac{60}{11}\\,\\Omega = \\frac{27}{14}\\,\\text{V}$. অতএব, 10 Ω রোধের মধ্য দিয়ে প্রবাহিত প্রবাহমাত্রা $I_2 = \\frac{V_p}{10\\,\\Omega} = \\frac{27/14\\,\\text{V}}{10\\,\\Omega} = \\frac{27}{140}\\,\\text{A} \\approx 0.192857\\,\\text{A}$. প্রদত্ত অপশনগুলোর মধ্যে $0.16\\,\\text{A}$ আমাদের নির্ণীত মানের সবচেয়ে কাছাকাছি।	A
fa60a6d0-fec7-41af-b837-dc417b5e36a9	b0c3348a-46af-4e00-a298-7006c2a9785f	09.	পাত-দূরত্ব $d$ এবং ধারকত্ব $C$, এমন একটি সমান্তরাল পাত-ধারকের পাত দুইটির মাঝখানে $d/2$ পুরুত্ববিশিষ্ট একটি ধাতব পাত স্থাপন করা হলো। নতুন ধারকত্ব কত হবে?	physics	static_electricity	D	\N	generated	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	সমান্তরাল পাত-ধারকের ধারকত্ব $C = \\frac{\\epsilon_0 A}{d}$। যখন $d/2$ পুরুত্বের একটি ধাতব পাত (পরিবাহী) প্রবেশ করানো হয়, তখন ধারকের কার্যকর পাত-দূরত্ব হ্রাস পায়। ধাতব পাতের অভ্যন্তরে তড়িৎ ক্ষেত্র শূন্য হওয়ায় কার্যকর দূরত্ব হয় $d' = d - \\frac{d}{2} = \\frac{d}{2}$। সুতরাং নতুন ধারকত্ব $C' = \\frac{\\epsilon_0 A}{d'} = \\frac{\\epsilon_0 A}{d/2} = 2 \\frac{\\epsilon_0 A}{d} = 2C$।	D
38645518-b89a-4c6d-a0fc-ba993b31f8aa	b0c3348a-46af-4e00-a298-7006c2a9785f	12	মুক্তভাবে পড়ন্ত কোনো বস্তু চতুর্থ সেকেন্ডে কত দূরত্ব অতিক্রম করবে?	mathematics	dynamics	D	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
4599acb3-9d78-4bf9-8c9b-47bc3b7756d6	e50bdce2-e49e-4b4a-8279-da972fe9d089	14	একটি বস্তু $12\\,\\text{m}$ ব্যাসার্ধের একটি বৃত্তাকার পথে চলমান আছে। একটি মুহূর্তে বৃত্তাকার পথে এর দ্রুতি $6\\,\\text{m/s}$ এবং এটি $4\\,\\text{m/s}^2$ হারে বৃদ্ধি পাচ্ছে। ঐ মুহূর্তে বস্তুটির ত্বরণের মান কত?	physics	dynamics	D	\N	generated	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	বৃত্তাকার পথে চলমান বস্তুর মোট ত্বরণ $a = \\sqrt{a_t^2 + a_c^2}$। এখানে স্পর্শকীয় ত্বরণ $a_t = 4\\,\\text{m/s}^2$ এবং কেন্দ্রমুখী ত্বরণ $a_c = \\frac{v^2}{r} = \\frac{6^2}{12} = 3\\,\\text{m/s}^2$। মানগুলো বসিয়ে পাই, $a = \\sqrt{4^2 + 3^2} = \\sqrt{16 + 9} = 5\\,\\text{m/s}^2$। সুতরাং, ঐ মুহূর্তে বস্তুটির ত্বরণের মান $5\\,\\text{m/s}^2$।	D
e8bdfe3d-0799-4385-84a2-99e588b584f7	e50bdce2-e49e-4b4a-8279-da972fe9d089	08	$3N$ ও $2N$ মানের দুইটি বলের লব্ধি $R$। প্রথম বলের মান দ্বিগুণ করলে লব্ধির মানও দ্বিগুণ হয়। বলদ্বয়ের মধ্যবর্তী কোণের মান হবে-	mathematics	statics	D	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
7e95694e-7ce3-4768-b194-baf73df330b4	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	21	একটি বিন্দু চার্জ হতে $2\\,\\text{m}$ দূরত্বে তড়িৎক্ষেত্রের প্রাবল্যের মান $E$ হলে, $1\\,\\text{m}$ দূরত্বে তড়িৎক্ষেত্রের প্রাবল্যের মান কত?	physics	static_electricity	C	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	একটি বিন্দু চার্জের জন্য তড়িৎক্ষেত্রের প্রাবল্য $E$ দূরত্বের বর্গের ব্যস্তানুপাতিক, অর্থাৎ $E \\propto \\frac{1}{r^2}$।\nপ্রথম ক্ষেত্রে, $r_1 = 2\\,\\text{m}$ দূরত্বে প্রাবল্য $E_1 = E$।\nদ্বিতীয় ক্ষেত্রে, $r_2 = 1\\,\\text{m}$ দূরত্বে প্রাবল্য $E_2$ নির্ণয় করতে হবে।\nআমরা লিখতে পারি, $\\frac{E_2}{E_1} = \\frac{r_1^2}{r_2^2}$।\nমান বসিয়ে পাই, $\\frac{E_2}{E} = \\frac{(2\\,\\text{m})^2}{(1\\,\\text{m})^2} = \\frac{4}{1} = 4$।\nসুতরাং, $E_2 = 4E$।	C
ab80055d-216e-4731-926d-e2edebe712a0	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	20	একটি আনুভূমিক বিদ্যুৎ সরবরাহ লাইনে $70\\,\\text{A}$ তড়িৎ প্রবাহিত হচ্ছে। লাইনের $2\\,\\text{m}$ নিচে চৌম্বক ক্ষেত্রে মান কত?	physics	magnetic_effects_of_electric_current_and_magnetism	D	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	একটি দীর্ঘ সরল তারের কারণে $r$ দূরত্বে চৌম্বক ক্ষেত্রের মান নির্ণয়ের সূত্রটি হলো $B = \\frac{\\mu_0 I}{2\\pi r}$। এখানে, তড়িৎ প্রবাহ $I = 70\\,\\text{A}$, দূরত্ব $r = 2\\,\\text{m}$ এবং শূন্যস্থানের প্রবেশ্যতা $\\mu_0 = 4\\pi \\times 10^{-7}\\,\\text{T}\\cdot\\text{m/A}$।\nমানগুলো সূত্রে বসিয়ে পাই:\n$$B = \\frac{(4\\pi \\times 10^{-7}\\,\\text{T}\\cdot\\text{m/A}) \\times (70\\,\\text{A})}{2\\pi \\times (2\\,\\text{m})} = \\frac{4\\pi \\times 10^{-7} \\times 70}{4\\pi}\\,\\text{T}$$\n$$B = 70 \\times 10^{-7}\\,\\text{T} = 7 \\times 10^{-6}\\,\\text{T}$$\nসুতরাং, চৌম্বক ক্ষেত্রের মান $7 \\times 10^{-6}\\,\\text{T}$।	D
c7cb926c-cb05-4342-86c3-3c23a8749ebf	55086422-ef06-4659-a0be-10579b6abde5	17	$10\\,\\text{m/s}$ সমদ্রুতিতে $r$ ব্যাসার্ধের বৃত্তাকার পথে ঘূর্ণায়মান একটি কণার ক্ষেত্রে নিচের চারটি লেখচিত্রের কোনটি সঠিক (কণার ত্বরণ $a$)?	physics	dynamics	D	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p02_q17_01.png", "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": "token/file count mismatch on page 2: 6 tokens vs 5 files", "extraction_status": "needs_review"}, {"id": "IMAGE_2", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p02_q17_02.png", "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": "token/file count mismatch on page 2: 6 tokens vs 5 files", "extraction_status": "needs_review"}, {"id": "IMAGE_3", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p02_q17_03.png", "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": "token/file count mismatch on page 2: 6 tokens vs 5 files", "extraction_status": "needs_review"}, {"id": "IMAGE_4", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p02_q17_04.png", "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": "token/file count mismatch on page 2: 6 tokens vs 5 files", "extraction_status": "needs_review"}]	একটি কণা $v$ সমদ্রুতিতে $r$ ব্যাসার্ধের বৃত্তাকার পথে ঘূর্ণায়মান হলে এর কেন্দ্রমুখী ত্বরণ $a$ এর সূত্র হলো $a = \\frac{v^2}{r}$। প্রশ্নে দেওয়া আছে কণার দ্রুতি $v = 10\\,\\text{m/s}$ যা একটি ধ্রুবক। সুতরাং, ত্বরণ $a = \\frac{(10\\,\\text{m/s})^2}{r} = \\frac{100\\,\\text{m}^2/\\text{s}^2}{r}$। এই সমীকরণ থেকে দেখা যায় যে, ত্বরণ $a$ ব্যাসার্ধ $r$ এর ব্যস্তানুপাতিক ($a \\propto 1/r$)। এই সম্পর্কটি একটি অধিবৃত্তাকার লেখচিত্র দ্বারা প্রকাশ করা হয়, যেখানে $r$ বাড়লে $a$ কমে। প্রদত্ত লেখচিত্রগুলোর মধ্যে (D) এই সম্পর্কটি সঠিকভাবে নির্দেশ করে।	D
bb8e0d8a-95dc-4430-a5de-bbedcd1d8fda	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	07.	$E$ শক্তির একটি ফোটনের তরঙ্গদৈর্ঘ্য কত?	physics	introduction_to_modern_physics	B	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	ফোটনের শক্তি $E$ এবং এর কম্পাঙ্ক $f$ এর মধ্যে সম্পর্ক হলো $E = hf$, যেখানে $h$ হলো প্ল্যাঙ্কের ধ্রুবক। আলোকের বেগ $c$, কম্পাঙ্ক $f$ এবং তরঙ্গদৈর্ঘ্য $\\lambda$ এর মধ্যে সম্পর্ক হলো $c = f\\lambda$, যা থেকে আমরা পাই $f = c/\\lambda$। এখন, $f$ এর মানকে শক্তির সমীকরণে প্রতিস্থাপন করে পাই $E = h(c/\\lambda)$। এই সমীকরণ থেকে তরঙ্গদৈর্ঘ্য $\\lambda$ এর জন্য সমাধান করলে আমরা পাই $\\lambda = hc/E$।	B
854a05d3-849b-4dd9-a522-4b7c9d192a45	55086422-ef06-4659-a0be-10579b6abde5	26	একটি গাড়ি একটি সোজা রাস্তায় স্থির অবস্থা থেকে ত্বরণের মাধ্যমে যাত্রা শুরু করলো। কিছু সময় পরে গাড়িটি মন্দনের মাধ্যমে থেমে যায়। গাড়িটি একই পথে একইভাবে যাত্রা করে পূর্ববর্তী স্থানে ফিরে আসে। নিম্নলিখিত কোন লেখচিত্রটি গতির গতিকে প্রকাশ করে?	physics	dynamics	C	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p03_q26_01.png", "markdown": null, "page_index": 2, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}, {"id": "IMAGE_2", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p03_q26_02.png", "markdown": null, "page_index": 2, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}, {"id": "IMAGE_3", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p03_q26_03.png", "markdown": null, "page_index": 2, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}, {"id": "IMAGE_4", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p03_q26_04.png", "markdown": null, "page_index": 2, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}]	গাড়িটির গতিপথ বিশ্লেষণ করা যাক: প্রথমে, গাড়িটি স্থির অবস্থা থেকে ত্বরণের মাধ্যমে যাত্রা শুরু করে, যার অর্থ $t=0$ এ বেগ শূন্য এবং বেগ বাড়তে থাকে। একটি $x-t$ লেখচিত্রে, বেগ হলো ঢাল। তাই, লেখচিত্রের ঢাল $t=0$ এ শূন্য হবে এবং তারপর বাড়তে থাকবে। এরপর, গাড়িটি মন্দনের মাধ্যমে থেমে যায়, অর্থাৎ বেগ কমে শূন্য হয়ে যায়। লেখচিত্রে, ঢাল কমতে কমতে সর্বোচ্চ সরণের বিন্দুতে শূন্য হবে। সবশেষে, গাড়িটি একই পথে একইভাবে যাত্রা করে পূর্ববর্তী স্থানে ফিরে আসে, যার অর্থ গাড়িটি বিপরীত দিকে চলতে শুরু করে এবং আদি অবস্থানে ($x=0$) ফিরে আসে। বিপরীত দিকে চলার সময় বেগ ঋণাত্মক হবে এবং আদি অবস্থানে ফিরে আসার পর বেগ আবার শূন্য হবে।\n\nঅপশন (A) এবং (B) তে ধ্রুব বেগ দেখানো হয়েছে এবং বেগের পরিবর্তন তাৎক্ষণিক, যা ত্বরণ ও মন্দনের সাথে সঙ্গতিপূর্ণ নয়।\nঅপশন (C) তে, লেখচিত্রটি $t=0$ এ শূন্য ঢাল থেকে শুরু হয় (স্থির অবস্থা)। এরপর ঢাল বাড়তে থাকে (ত্বরণ), তারপর কমে শূন্য হয় সর্বোচ্চ সরণে (মন্দনে থেমে যাওয়া)। এরপর ঢাল ঋণাত্মক হয় এবং তার মান বাড়তে থাকে (বিপরীত দিকে ত্বরণ), তারপর মান কমে শূন্য হয় যখন গাড়িটি আদি অবস্থানে ফিরে আসে (বিপরীত দিকে মন্দনে থেমে যাওয়া)। এই লেখচিত্রটি বর্ণিত গতির সাথে সম্পূর্ণরূপে সঙ্গতিপূর্ণ।\nঅপশন (D) ও গুণগতভাবে একই রকম দেখালেও, (C) একটি মসৃণ এবং সাধারণ গতি প্রোফাইলের জন্য অধিক উপযুক্ত চিত্রায়ন।	C
08a035f1-feef-4d5b-8017-ef1773ce0f4d	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	25	নিচের কোন লেখচিত্রটি সরণ বনাম সময় সমবেগে চলমান বস্তুর গতি ব্যক্ত করে?	physics	dynamics	B	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p02_q25_01.png", "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}, {"id": "IMAGE_2", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p02_q25_02.png", "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}, {"id": "IMAGE_3", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p02_q25_03.png", "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}, {"id": "IMAGE_4", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p02_q25_04.png", "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}]	একটি বস্তুর সরণ-সময় লেখচিত্রে, লেখচিত্রের ঢাল বস্তুর বেগ নির্দেশ করে। যদি বস্তুটি সমবেগে চলে, তাহলে তার বেগ স্থির থাকবে, অর্থাৎ সরণ-সময় লেখচিত্রের ঢাল ধ্রুবক হবে। একটি সরলরেখার ঢাল ধ্রুবক হয়। বিকল্প (B) একটি সরলরেখা নির্দেশ করে যার ঢাল ঋণাত্মক কিন্তু ধ্রুবক। এটি একটি ধ্রুবক ঋণাত্মক বেগকে বোঝায়, যা সমবেগের একটি উদাহরণ। অন্য বিকল্পগুলিতে ঢাল পরিবর্তনশীল (বেগ পরিবর্তনশীল) অথবা শূন্য (বস্তু স্থির)।	B
6ebea734-46a1-4bc7-9949-cfd2128f81e9	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	14.	$8N$ এবং $3N$ দুইটি বল একটি বিন্দুতে $60^\\circ$ কোণে একটি বস্তুতে ক্রিয়ারত। বলদ্বয়ের লব্ধির মান-	physics	vector	B	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	দুটি বল $P$ এবং $Q$ যদি $\\alpha$ কোণে একটি বিন্দুতে ক্রিয়া করে, তবে তাদের লব্ধি $R$ এর মান নির্ণয়ের সূত্র হলো $R = \\sqrt{P^2 + Q^2 + 2PQ \\cos\\alpha}$। এখানে, $P = 8\\,\\text{N}$, $Q = 3\\,\\text{N}$ এবং $\\alpha = 60^\\circ$। মানগুলো সূত্রে বসিয়ে পাই: $R = \\sqrt{(8\\,\\text{N})^2 + (3\\,\\text{N})^2 + 2 \\times (8\\,\\text{N}) \\times (3\\,\\text{N}) \\times \\cos(60^\\circ)}$। এটি সরল করলে পাই $R = \\sqrt{64\\,\\text{N}^2 + 9\\,\\text{N}^2 + 48\\,\\text{N}^2 \\times 0.5} = \\sqrt{64\\,\\text{N}^2 + 9\\,\\text{N}^2 + 24\\,\\text{N}^2} = \\sqrt{97}\\,\\text{N}$।	B
fcb4d325-5f11-4166-ba6e-0c718d6b8936	b0c3348a-46af-4e00-a298-7006c2a9785f	02.	$m$ এবং $2m$ ভরের দুইটি আয়তাকার বাক্স একটি ঘর্ষণহীন অনুভূমিক পৃষ্ঠে একটি দড়ি দ্বারা সংযুক্ত। $F$ মাত্রার একটি সম্মুখ বল দ্বারা ভারী বাক্সটিকে ডানদিকে টানা হচ্ছে। ফলে, হালকা বাক্সটি দড়ি দ্বারা টান অনুভব করে। দড়িটিতে টান কত? 	physics	newtonian_mechanics	C	\N	generated	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	পুরো সিস্টেমের মোট ভর $M = m + 2m = 3m$। নিউটনের দ্বিতীয় সূত্রানুসারে সিস্টেমের ত্বরণ $a = \\frac{F}{M} = \\frac{F}{3m}$। হালকা বাক্সটির ($m$) ওপর প্রযুক্ত বল হলো দড়ির টান $T$, যা বাক্সটিকে ত্বরণ প্রদান করে। সুতরাং, $T = m \\times a = m \\times \\frac{F}{3m} = \\frac{F}{3}$। অতএব, দড়িটিতে টান হবে $\\frac{F}{3}$।	C
70b8f220-c374-4587-bcb2-12f7e2fa0bf7	56229cbd-4fab-4246-8461-c24189194ed2	17	একটি কৃত্রিম উপগ্রহ $7000\\,\\text{km}$ ব্যাসার্ধবিশিষ্ট বৃত্তাকার কক্ষপথে পৃথিবীকে প্রদক্ষিণ করছে। উপগ্রহটির পর্যায়কাল $2\\,\\text{h}$ হলে কেন্দ্রমুখী ত্বরণ কত?	physics	newtonian_mechanics	C	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	কেন্দ্রমুখী ত্বরণের সূত্র হলো $a_c = \\frac{4\\pi^2 r}{T^2}$। এখানে, কক্ষপথের ব্যাসার্ধ $r = 7000\\,\\text{km} = 7000 \\times 10^3\\,\\text{m} = 7 \\times 10^6\\,\\text{m}$ এবং পর্যায়কাল $T = 2\\,\\text{h} = 2 \\times 3600\\,\\text{s} = 7200\\,\\text{s}$।\n\nমানগুলো সূত্রে বসিয়ে পাই (এখানে $\\pi \\approx 3.14$ ব্যবহার করা হয়েছে):\n$$a_c = \\frac{4 \\times (3.14)^2 \\times (7 \\times 10^6\\,\\text{m})}{(7200\\,\\text{s})^2}$$\n$$a_c = \\frac{4 \\times 9.8596 \\times 7 \\times 10^6}{51840000}\\,\\text{m/s}^2$$\n$$a_c = \\frac{276.0688 \\times 10^6}{51.84 \\times 10^6}\\,\\text{m/s}^2$$\n$$a_c = \\frac{276.0688}{51.84}\\,\\text{m/s}^2$$\n$$a_c \\approx 5.3256\\,\\text{m/s}^2$$\n\nনিকটতম বিকল্পটি হলো $5.325\\,\\text{m/s}^2$।	C
9f75d35f-1455-4153-8056-423445f16fce	05a449d9-5db0-488f-936f-ab50cc72299e	01	একটি ব্যাটারির মধ্যে তড়িৎ প্রবাহ $i$ দ্বারা প্রকাশ করা হয়। ঐ ব্যাটারির তড়িৎচালক বল, এর দুই প্রান্তের বিভব পার্থক্যের সমান কখন হবে?	physics	current_electricity	C	\N	generated	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	একটি ব্যাটারির তড়িৎচালক বল ($E$) এবং এর দুই প্রান্তের বিভব পার্থক্য ($V$) এর মধ্যে সম্পর্ক হলো $V = E - ir$, যেখানে $i$ হলো ব্যাটারির মধ্য দিয়ে প্রবাহিত তড়িৎ প্রবাহ এবং $r$ হলো ব্যাটারির অভ্যন্তরীণ রোধ। যখন ব্যাটারির দুই প্রান্তের বিভব পার্থক্য এর তড়িৎচালক বলের সমান হবে, তখন $V = E$ হবে। এই শর্তটি সমীকরণে বসালে আমরা পাই $E = E - ir$, যা থেকে $ir = 0$ পাওয়া যায়। যেহেতু একটি বাস্তব ব্যাটারির অভ্যন্তরীণ রোধ $r$ শূন্য হয় না ($r > 0$), তাই এই শর্তটি পূরণ হওয়ার জন্য তড়িৎ প্রবাহ $i$ অবশ্যই শূন্য হতে হবে ($i = 0$)। অর্থাৎ, যখন ব্যাটারি থেকে কোনো তড়িৎ প্রবাহ নেওয়া হয় না (মুক্ত বর্তনী), তখনই এর দুই প্রান্তের বিভব পার্থক্য তড়িৎচালক বলের সমান হয়।	C
b5a6e81f-c016-4964-8cc9-cd77e4ec8fa3	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	11.	একটি কণার স্বাধীনতার মাত্রার সংখ্যা $5$ হলে শক্তির সমবিভাজন নীতি অনুযায়ী কণাটির মোট শক্তি কত?	physics	ideal_gas_and_gas_kinetics	D	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	শক্তির সমবিভাজন নীতি (Equipartition Theorem) অনুযায়ী, প্রতিটি স্বাধীনতার মাত্রার জন্য একটি কণার গড় শক্তি হলো $kT/2$, যেখানে $k$ হলো বোল্টজম্যান ধ্রুবক এবং $T$ হলো পরম তাপমাত্রা। যদি একটি কণার স্বাধীনতার মাত্রা $f$ হয়, তাহলে কণাটির মোট শক্তি হবে $E = f \\times \\frac{1}{2} kT$। এই প্রশ্নটিতে কণাটির স্বাধীনতার মাত্রার সংখ্যা $f = 5$ দেওয়া আছে। সুতরাং, কণাটির মোট শক্তি হবে $E = 5 \\times \\frac{1}{2} kT = \\frac{5}{2} kT$।	D
39913432-08d3-4da1-8101-76555b68789f	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	15.	একটি আদর্শ স্প্রিং-এর শেষ প্রান্তে ঝুলানো একটি ভর $T$ পর্যায়কাল নিয়ে উলম্বভাবে স্পন্দিত হয়। এখন স্পন্দনের বিস্তার দ্বিগুণ করা হলে, নতুন দোলনকাল হবে-	physics	periodic_motion	A	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	একটি আদর্শ স্প্রিং-এর সাথে যুক্ত ভরের উল্লম্ব স্পন্দনের দোলনকাল (period) $T = 2\\pi \\sqrt{\\frac{m}{k}}$ সূত্র দ্বারা নির্ধারিত হয়, যেখানে $m$ হলো ভর এবং $k$ হলো স্প্রিং ধ্রুবক। এই সূত্রে দোলনকাল $T$ স্পন্দনের বিস্তার (amplitude) এর উপর নির্ভরশীল নয়। যেহেতু ভর এবং স্প্রিং ধ্রুবক অপরিবর্তিত রয়েছে, তাই স্পন্দনের বিস্তার দ্বিগুণ করা হলেও দোলনকাল একই থাকবে। সুতরাং, নতুন দোলনকাল হবে $T$।	A
d254c27e-6371-48b8-96a2-4f5407502a92	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	29	হাইড্রোজেন পরমাণুর প্রথম বোর কক্ষের শক্তি $-13.6\\,\\text{V}$ হলে এর দ্বিতীয় কক্ষের শক্তি কত?	physics	atomic_model_and_nuclear_physics	B	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	হাইড্রোজেন পরমাণুর $n$-তম বোর কক্ষের শক্তির সূত্র হলো $E_n = \\frac{E_1}{n^2}$, যেখানে $E_1$ হলো প্রথম কক্ষের শক্তি এবং $n$ হলো কক্ষপথের ক্রমিক সংখ্যা। প্রশ্নানুসারে, প্রথম কক্ষের শক্তি $E_1 = -13.6\\,\\text{eV}$। দ্বিতীয় কক্ষের শক্তি ($n=2$) নির্ণয় করতে, আমরা সূত্রটি ব্যবহার করি: $E_2 = \\frac{E_1}{2^2} = \\frac{-13.6\\,\\text{eV}}{4}$। এটি গণনা করলে পাই $E_2 = -3.4\\,\\text{eV}$।	B
057d9d16-3096-49a9-9332-91786e8f7fde	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	16	একটি কণার উপর $\\vec{F} = (10\\hat{i} + 10\\hat{j} + 10\\hat{k})\\text{ N}$ বল প্রয়োগ করলে কণাটির সরণ হয়, $\\vec{r} = (2\\hat{i} + 2\\hat{j} - 2\\hat{k})\\text{ m}$। বল কর্তৃক সম্পাদিত কাজ কত হবে?	physics	work_energy_and_power	A	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	একটি কণার উপর বল $\\vec{F}$ প্রয়োগের ফলে সরণ $\\vec{r}$ হলে, বল কর্তৃক সম্পাদিত কাজ $W$ এর সূত্র হলো $W = \\vec{F} \\cdot \\vec{r}$।\nএখানে, $\\vec{F} = (10\\hat{i} + 10\\hat{j} + 10\\hat{k})\\,\\text{N}$ এবং $\\vec{r} = (2\\hat{i} + 2\\hat{j} - 2\\hat{k})\\,\\text{m}$।\nসুতরাং, সম্পাদিত কাজ হবে:\n$$W = (10\\hat{i} + 10\\hat{j} + 10\\hat{k}) \\cdot (2\\hat{i} + 2\\hat{j} - 2\\hat{k})$$\n$$W = (10 \\times 2) + (10 \\times 2) + (10 \\times -2)$$\n$$W = 20 + 20 - 20 = 20\\,\\text{J}$$\nঅতএব, বল কর্তৃক সম্পাদিত কাজ হলো $20\\,\\text{J}$।	A
dfa449d1-1841-483a-9d3c-fae10a197a8e	55086422-ef06-4659-a0be-10579b6abde5	02.	চিত্রে প্রদর্শিত বর্তনীতে $4\\,\\Omega$ রোধের মধ্যে তড়িৎপ্রবাহ কত? [IMAGE_1]	physics	current_electricity	C	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "circuit_diagram", "box_2d": null, "filename": "p01_q02_01.png", "markdown": null, "page_index": 0, "caption_hint": null, "review_notes": "token/file count mismatch on page 1: 2 tokens vs 1 files", "extraction_status": "needs_review"}]	প্রথমে, $2\\,\\Omega$ রোধ দুটি সমান্তরাল সমবায়ে যুক্ত আছে। তাদের তুল্য রোধ $R_p$ হবে: $$ \\frac{1}{R_p} = \\frac{1}{2\\,\\Omega} + \\frac{1}{2\\,\\Omega} = \\frac{2}{2\\,\\Omega} = \\frac{1}{1\\,\\Omega} \\implies R_p = 1\\,\\Omega $$ এরপর, এই $R_p$ এবং $4\\,\\Omega$ রোধটি শ্রেণী সমবায়ে যুক্ত আছে। বর্তনীর মোট তুল্য রোধ $R_{eq}$ হবে: $$ R_{eq} = R_p + 4\\,\\Omega = 1\\,\\Omega + 4\\,\\Omega = 5\\,\\Omega $$ ওহমের সূত্রানুযায়ী, বর্তনীর মোট তড়িৎপ্রবাহ $I$ হবে: $$ I = \\frac{V}{R_{eq}} = \\frac{5\\,\\text{V}}{5\\,\\Omega} = 1\\,\\text{A} $$ যেহেতু $4\\,\\Omega$ রোধটি বর্তনীর মোট তুল্য রোধের সাথে শ্রেণী সমবায়ে আছে, তাই এর মধ্য দিয়ে প্রবাহিত তড়িৎপ্রবাহ মোট তড়িৎপ্রবাহের সমান হবে, অর্থাৎ $1\\,\\text{A}$।	C
004f4b76-a500-47d3-a015-235e0717205b	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	30	NGC 4472 গ্যালাক্সি আমাদের গ্যালাক্সির সাপেক্ষে $770\\,\\text{km/s}$ দ্রুতিতে দূরে সরে যাচ্ছে। হাবল ধ্রুবক $55\\,\\text{km/s.MPC}$ হলে, আমাদের গ্যালাক্সি থেকে NGC 4472 গ্যালাক্সির দূরত্ব কত?	physics	astronomy	A	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	হাবলের সূত্র অনুযায়ী, একটি গ্যালাক্সির অপসরণ বেগ ($v$) হাবল ধ্রুবক ($H_0$) এবং গ্যালাক্সিটির দূরত্ব ($d$) এর গুণফলের সমান, অর্থাৎ $v = H_0 d$। আমাদের গ্যালাক্সির সাপেক্ষে NGC 4472 গ্যালাক্সির অপসরণ বেগ $v = 770\\,\\text{km/s}$ এবং হাবল ধ্রুবক $H_0 = 55\\,\\text{km/s.MPC}$ দেওয়া আছে। দূরত্ব নির্ণয়ের জন্য সূত্রটি পুনর্বিন্যাস করলে পাই $d = v / H_0$। মানগুলো বসিয়ে পাই: $$d = \\frac{770\\,\\text{km/s}}{55\\,\\text{km/s.MPC}} = 14\\,\\text{MPC}$$ সুতরাং, NGC 4472 গ্যালাক্সিটি আমাদের গ্যালাক্সি থেকে $14\\,\\text{MPC}$ দূরে অবস্থিত।	A
b51e5ec8-ad46-46b5-b689-d5e8a977463e	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	28	সমবাহু ত্রিভুজাকৃতির একটি প্রিজমের প্রতিসরাঙ্ক $\\sqrt{2}$ হলে এর ন্যূনতম বিচ্যুতি কোণ কত?	physics	geometrical_optics	C	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	একটি সমবাহু ত্রিভুজাকৃতির প্রিজমের জন্য প্রিজম কোণ $A = 60^\\circ$। ন্যূনতম বিচ্যুতির জন্য প্রিজমের প্রতিসরাঙ্কের সূত্র হলো $\\mu = \\frac{\\sin\\left(\\frac{A + \\delta_m}{2}\\right)}{\\sin\\left(\\frac{A}{2}\\right)}$। প্রদত্ত প্রতিসরাঙ্ক $\\mu = \\sqrt{2}$। মানগুলো বসিয়ে পাই: $\\sqrt{2} = \\frac{\\sin\\left(\\frac{60^\\circ + \\delta_m}{2}\\right)}{\\sin\\left(\\frac{60^\\circ}{2}\\right)}$। এটি সরল করলে দাঁড়ায় $\\sqrt{2} = \\frac{\\sin\\left(\\frac{60^\\circ + \\delta_m}{2}\\right)}{\\sin(30^\\circ)}$। যেহেতু $\\sin(30^\\circ) = 0.5$, আমরা পাই $\\sin\\left(\\frac{60^\\circ + \\delta_m}{2}\\right) = \\sqrt{2} \\times 0.5 = \\frac{\\sqrt{2}}{2}$। আমরা জানি $\\sin(45^\\circ) = \\frac{\\sqrt{2}}{2}$। সুতরাং, $\\frac{60^\\circ + \\delta_m}{2} = 45^\\circ$, যা থেকে $60^\\circ + \\delta_m = 90^\\circ$। অতএব, ন্যূনতম বিচ্যুতি কোণ $\\delta_m = 90^\\circ - 60^\\circ = 30^\\circ$।	C
c20cf417-98d4-41eb-8914-7e4e3f45fa83	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	27	একটি মাধ্যমে $600\\,\\text{Hz}$ ও $400\\,\\text{Hz}$ কম্পাঙ্কের দুটি শব্দ তরঙ্গের তরঙ্গদৈর্ঘ্যের পার্থক্য $1\\,\\text{m}$ হলে, ঐ মাধ্যমে শব্দের বেগ কত?	physics	waves	B	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	শব্দের বেগ ($v$), কম্পাঙ্ক ($f$) এবং তরঙ্গদৈর্ঘ্য ($\\lambda$) এর মধ্যে সম্পর্ক হলো $v = f\\lambda$, যা থেকে আমরা পাই $\\lambda = v/f$। যেহেতু শব্দ একই মাধ্যমে চলছে, তাই এর বেগ ($v$) একই থাকবে। দুটি ভিন্ন কম্পাঙ্কের শব্দ তরঙ্গের জন্য, তরঙ্গদৈর্ঘ্য হবে $\\lambda_1 = v/f_1$ এবং $\\lambda_2 = v/f_2$। প্রশ্নানুসারে, তরঙ্গদৈর্ঘ্যের পার্থক্য $1\\,\\text{m}$। যেহেতু $f_1 > f_2$, তাই $\\lambda_1 < \\lambda_2$ হবে। সুতরাং, $\\lambda_2 - \\lambda_1 = 1\\,\\text{m}$। মান বসিয়ে পাই: $v/f_2 - v/f_1 = 1\\,\\text{m}$। $v(1/f_2 - 1/f_1) = 1\\,\\text{m}$। $v\\left(\\frac{f_1 - f_2}{f_1 f_2}\\right) = 1\\,\\text{m}$। অতএব, $v = \\frac{f_1 f_2}{f_1 - f_2}\\,\\text{m}$। প্রদত্ত মানগুলো হলো $f_1 = 600\\,\\text{Hz}$ এবং $f_2 = 400\\,\\text{Hz}$। মানগুলো সমীকরণে বসিয়ে পাই: $v = \\frac{600\\,\\text{Hz} \\times 400\\,\\text{Hz}}{600\\,\\text{Hz} - 400\\,\\text{Hz}} = \\frac{240000\\,\\text{Hz}^2}{200\\,\\text{Hz}} = 1200\\,\\text{m/s}$। এটি $1.2 \\times 10^3\\,\\text{m/s}$ এর সমান।	B
1f71e2ec-348b-4269-9503-e39e1cc6db2c	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	22	$10\\,\\text{cm}$ দৈর্ঘ্যের $2\\,\\text{A}$ তড়িৎ প্রবাহবিশিষ্ট একটি তারকে $0.2\\,\\text{T}$ চৌম্বকক্ষেত্রের লম্বভাবে স্থাপন করা হলো। তারের উপর প্রযুক্ত বল কত?	physics	magnetic_effects_of_electric_current_and_magnetism	B	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	তারের উপর প্রযুক্ত চৌম্বক বলের সূত্র হলো $F = BIL\\sin\\theta$, যেখানে $B$ চৌম্বক ক্ষেত্র, $I$ তড়িৎ প্রবাহ, $L$ তারের দৈর্ঘ্য এবং $\\theta$ হলো তড়িৎ প্রবাহ ও চৌম্বক ক্ষেত্রের মধ্যবর্তী কোণ। প্রদত্ত মানগুলো হলো $B = 0.2\\,\\text{T}$, $I = 2\\,\\text{A}$, $L = 10\\,\\text{cm} = 0.1\\,\\text{m}$ এবং যেহেতু তারটি লম্বভাবে স্থাপন করা হয়েছে, $\\theta = 90^\\circ$।\\nসুতরাং, $F = (0.2\\,\\text{T}) \\times (2\\,\\text{A}) \\times (0.1\\,\\text{m}) \\times \\sin(90^\\circ) = 0.04\\,\\text{N}$.	B
816a0061-1e82-44b0-8914-79a1931908fd	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	14.	নিম্নের কোন তরঙ্গের প্রসারণ এর জন্য মাধ্যমের প্রয়োজন হয়?	physics	physical_optics	C	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	তরঙ্গকে প্রধানত দুই ভাগে ভাগ করা যায়: যান্ত্রিক তরঙ্গ (mechanical waves) এবং তড়িৎচুম্বকীয় তরঙ্গ (electromagnetic waves)। যান্ত্রিক তরঙ্গের প্রসারণের জন্য মাধ্যমের প্রয়োজন হয়, যেমন শব্দ তরঙ্গ। অন্যদিকে, তড়িৎচুম্বকীয় তরঙ্গের প্রসারণের জন্য কোনো মাধ্যমের প্রয়োজন হয় না; এরা শূন্যস্থান দিয়েও চলাচল করতে পারে। X-ray, Radio Wave এবং Ultra-Violet সবই তড়িৎচুম্বকীয় তরঙ্গের উদাহরণ। শব্দ তরঙ্গ (Sound Wave) একটি যান্ত্রিক তরঙ্গ, তাই এর প্রসারণের জন্য মাধ্যমের প্রয়োজন হয়।	C
1b7caef1-59fd-4b4a-aa70-42c2f635fe44	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	01.	প্রদত্ত বর্তনীতে $R_3$ রোধে তড়িৎপ্রবাহ কত? \n[IMAGE_1]	physics	current_electricity	D	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "circuit_diagram", "box_2d": null, "filename": "p01_q01_01.png", "markdown": null, "page_index": 0, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}]	প্রথমে, $R_2$ এবং $R_3$ রোধ দুটি সমান্তরাল সমবায়ে আছে। তাদের তুল্য রোধ $R_{23}$ হবে: $$ \\frac{1}{R_{23}} = \\frac{1}{R_2} + \\frac{1}{R_3} = \\frac{1}{2\\,\\Omega} + \\frac{1}{2\\,\\Omega} = \\frac{2}{2\\,\\Omega} = \\frac{1}{1\\,\\Omega} \\implies R_{23} = 1\\,\\Omega $$ এরপর, $R_1$ রোধটি $R_{23}$ এর সাথে শ্রেণী সমবায়ে আছে। বর্তনীর মোট তুল্য রোধ $R_{eq}$ হবে: $$ R_{eq} = R_1 + R_{23} = 1\\,\\Omega + 1\\,\\Omega = 2\\,\\Omega $$ বর্তনীর মোট তড়িৎপ্রবাহ $I_{total}$ হবে: $$ I_{total} = \\frac{V}{R_{eq}} = \\frac{2\\,\\text{V}}{2\\,\\Omega} = 1\\,\\text{A} $$ এই মোট তড়িৎপ্রবাহ $R_1$ এর মধ্য দিয়ে প্রবাহিত হয়ে $R_2$ এবং $R_3$ এর মধ্যে বিভক্ত হবে। যেহেতু $R_2 = R_3 = 2\\,\\Omega$, তড়িৎপ্রবাহ সমানভাবে ভাগ হবে। তাই $R_3$ রোধে তড়িৎপ্রবাহ $I_3$ হবে: $$ I_3 = \\frac{I_{total}}{2} = \\frac{1\\,\\text{A}}{2} = 0.5\\,\\text{A} $$	D
3f5b9d22-6edf-4b2b-a7e7-2b634e259061	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	10.	একটি আদর্শ গ্যাসের ক্ষেত্রে $C_p/C_v = x$ হলে, নিচের কোন সম্পর্কটি এক মোলের জন্য সঠিক?	physics	thermodynamics	B	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	একটি আদর্শ গ্যাসের জন্য, মোলার আপেক্ষিক তাপ $C_p$ এবং $C_v$-এর মধ্যে মেয়ারের সম্পর্কটি হলো $C_p - C_v = R$, যেখানে $R$ হলো সার্বজনীন গ্যাস ধ্রুবক। প্রশ্নানুসারে, আপেক্ষিক তাপের অনুপাত $C_p/C_v = x$ দেওয়া আছে, যা থেকে আমরা পাই $C_p = x C_v$। এখন, মেয়ারের সম্পর্কে $C_p$-এর মান প্রতিস্থাপন করে পাই: $x C_v - C_v = R$। $C_v$ কমন নিলে পাই $C_v (x - 1) = R$। সুতরাং, $C_v = R / (x - 1)$।	B
af038b7c-e600-4d33-8155-21719ce50014	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	03.	$1\\,\\text{g}$ ভরের একটি বস্তুকে $0.5\\,\\text{m}$ ব্যাসার্ধের একটি আনুভূমিক বৃত্তাকার পথে $2\\,\\text{m/s}$ সমদ্রুতিতে ঘোরানো হচ্ছে। এক পূর্ণ ঘূর্ণনের জন্য প্রয়োজনীয় কাজের মান কত?	physics	work_energy_and_power	A	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	একটি বস্তুকে আনুভূমিক বৃত্তাকার পথে সমদ্রুতিতে ঘোরানোর সময়, বস্তুর উপর ক্রিয়াশীল কেন্দ্রমুখী বল সর্বদা বৃত্তের কেন্দ্রের দিকে নির্দেশিত থাকে। অন্যদিকে, বস্তুর সরণ সর্বদা বৃত্তের স্পর্শক বরাবর হয়। এর ফলে, কেন্দ্রমুখী বল এবং সরণের মধ্যবর্তী কোণ সর্বদা $90^\text{o}$ হয়। কাজের সংজ্ঞা অনুযায়ী, $W = Fd\\cos\\theta$, যেখানে $F$ হল বল, $d$ হল সরণ এবং $\\theta$ হল বল ও সরণের মধ্যবর্তী কোণ। যেহেতু $\\theta = 90^\\text{o}$, তাই $\\cos(90^\\text{o}) = 0$। সুতরাং, এক পূর্ণ ঘূর্ণনের জন্য প্রয়োজনীয় কাজের মান $W = Fd \\times 0 = 0\\,\\text{J}$।	A
234ce33d-2f3e-44da-bb27-cb3c7539c50f	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	12.	একটি কার্নো ইঞ্জিনের জন্য যদি তাপ উৎসের তাপমাত্রা অপরিবর্তিত রেখে তাপ গ্রাহকের তাপমাত্রা ধীরে ধীরে কমানো হয়, তাহলে ইঞ্জিনের কর্মদক্ষতা কেমনভাবে পরিবর্তিত হবে?	physics	thermodynamics	A	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	একটি কার্নো ইঞ্জিনের কর্মদক্ষতা $\\eta = 1 - \\frac{T_2}{T_1}$ সূত্র দ্বারা প্রকাশ করা হয়, যেখানে $T_1$ হলো তাপ উৎসের তাপমাত্রা এবং $T_2$ হলো তাপ গ্রাহকের তাপমাত্রা (উভয়ই কেলভিন স্কেলে)। প্রশ্নানুসারে, তাপ উৎসের তাপমাত্রা ($T_1$) অপরিবর্তিত রাখা হয়েছে এবং তাপ গ্রাহকের তাপমাত্রা ($T_2$) ধীরে ধীরে কমানো হচ্ছে। যেহেতু $T_2$ কমছে এবং $T_1$ স্থির, তাই $\\frac{T_2}{T_1}$ অনুপাতটি কমতে থাকবে। ফলস্বরূপ, $1 - \\frac{T_2}{T_1}$ এর মান বৃদ্ধি পাবে, অর্থাৎ ইঞ্জিনের কর্মদক্ষতা বৃদ্ধি পাবে।	A
41a0acaa-dbdc-4719-9b7f-f796e1a8db5f	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	13.	কোন আদর্শ গ্যাসের তাপমাত্রা কেলভিন স্কেলে দ্বিগুণ করা হলে, তার অণুগুলোর r.m.s বেগ কত গুণ বৃদ্ধি পায়?	physics	ideal_gas_and_gas_kinetics	C	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	আদর্শ গ্যাসের অণুগুলোর r.m.s বেগ ($v_{rms}$) কেলভিন স্কেলে তাপমাত্রার ($T$) বর্গমূলের সমানুপাতিক। এর সূত্রটি হলো $v_{rms} = \\sqrt{\\frac{3RT}{M}}$, যেখানে $R$ সার্বজনীন গ্যাস ধ্রুবক এবং $M$ গ্যাসের মোলার ভর। যদি প্রাথমিক তাপমাত্রা $T_1$ হয় এবং r.m.s বেগ $v_{rms1}$ হয়, তাহলে $v_{rms1} \\propto \\sqrt{T_1}$। তাপমাত্রা দ্বিগুণ করা হলে, নতুন তাপমাত্রা $T_2 = 2T_1$ হবে। নতুন r.m.s বেগ $v_{rms2}$ হলে, $v_{rms2} \\propto \\sqrt{T_2} = \\sqrt{2T_1}$। অতএব, বেগের অনুপাত হবে $\\frac{v_{rms2}}{v_{rms1}} = \\frac{\\sqrt{2T_1}}{\\sqrt{T_1}} = \\sqrt{2} \\approx 1.414$। সুতরাং, r.m.s বেগ প্রায় $1.41$ গুণ বৃদ্ধি পায়।	C
993ab2ec-b5b1-45ce-8e69-172067cd19a5	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	08.	$1$ মিটার দৈর্ঘ্যের একটি ফেল তার প্রস্থ বরাবর $0.95\\,c$ বেগে চলমান হলে ল্যাবে এর পরিমিত দৈর্ঘ্যের মান কত?	physics	introduction_to_modern_physics	D	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	আপেক্ষিকতার তত্ত্ব অনুসারে, দৈর্ঘ্য সংকোচন শুধুমাত্র গতির দিকের সমান্তরাল মাত্রার ক্ষেত্রেই ঘটে। যেহেতু তারটি তার দৈর্ঘ্যের সাথে লম্বভাবে ($0.95\\,c$ বেগে) গতিশীল, তাই তার দৈর্ঘ্যের কোনো সংকোচন হবে না। ল্যাবে পরিমাপকৃত দৈর্ঘ্য তার প্রকৃত দৈর্ঘ্যের সমানই থাকবে। সুতরাং, $L = L_0 = 1.0\\,\\text{m}$।	D
338d8dcd-bd80-427d-8c4b-7cefaa73721f	56229cbd-4fab-4246-8461-c24189194ed2	30	আলো বক্রপথে অপটিক্যাল ফাইবারের মধ্য দিয়ে সঞ্চালিত হতে পারে। নিম্নের কোন ঘটনাটি একে ব্যাখ্যা করতে পারে?	physics	geometrical_optics	C	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	অপটিক্যাল ফাইবার আলোর পূর্ণ-অভ্যন্তরীণ প্রতিফলনের (Total Internal Reflection) নীতির উপর ভিত্তি করে কাজ করে। যখন আলো একটি ঘন মাধ্যম (ফাইবারের কোর) থেকে একটি হালকা মাধ্যম (ফাইবারের ক্ল্যাডিং) এর দিকে যায় এবং আপতন কোণ সংকট কোণের চেয়ে বেশি হয়, তখন আলো দুটি মাধ্যমের বিভেদতল থেকে সম্পূর্ণরূপে প্রতিফলিত হয়ে ঘন মাধ্যমে ফিরে আসে। এই ঘটনাটি আলোকে ফাইবারের বক্রপথ বরাবর সঞ্চালিত হতে সাহায্য করে।	C
d3b41295-7f1b-48e9-a96a-52043440d70b	56229cbd-4fab-4246-8461-c24189194ed2	27	একটি উত্তল লেন্সের ফোকাস দূরত্ব $1000\\,\\text{cm}$ হলে, লেন্সটির ক্ষমতা হবে -	physics	geometrical_optics	C	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	লেন্সের ক্ষমতা ($P$) নির্ণয়ের জন্য ফোকাস দূরত্ব ($f$) কে মিটারে প্রকাশ করতে হয়। প্রদত্ত ফোকাস দূরত্ব $f = 1000\\,\\text{cm}$। এটিকে মিটারে রূপান্তর করলে পাই $f = 1000/100\\,\\text{m} = 10\\,\\text{m}$। লেন্সের ক্ষমতার সূত্র হলো $P = 1/f$। মান বসিয়ে পাই $P = 1/(10\\,\\text{m}) = 0.1\\,\\text{D}$। $0.1\\,\\text{D}$ কে ভগ্নাংশে লিখলে $1/10\\,\\text{D}$ হয়।	C
75a24797-7a12-4fab-a527-e72c1d201203	56229cbd-4fab-4246-8461-c24189194ed2	25	একটি প্রক্ষেপককে আনুভূমিকের সাথে $60^\\circ$ কোণে $3\\,\\text{m/s}$ বেগে প্রক্ষেপ করা হলে, সর্বোচ্চ উচ্চতায় প্রক্ষেপকটির বেগ কত হবে?	physics	dynamics	A	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	একটি প্রক্ষেপকের সর্বোচ্চ উচ্চতায় উল্লম্ব বেগের উপাংশ শূন্য হয়, কিন্তু আনুভূমিক বেগের উপাংশ ধ্রুবক থাকে। প্রক্ষেপকের আদি বেগ $u = 3\\,\\text{m/s}$ এবং প্রক্ষেপণ কোণ $\\theta = 60^\\circ$। আনুভূমিক বেগের উপাংশ হলো $u_x = u \\cos\\theta$। সর্বোচ্চ উচ্চতায় প্রক্ষেপকের বেগ হবে এই আনুভূমিক উপাংশের সমান। তাই, $v_{\\text{max height}} = u \\cos\\theta = 3\\,\\text{m/s} \\times \\cos(60^\\circ) = 3\\,\\text{m/s} \\times \\frac{1}{2} = \\frac{3}{2}\\,\\text{m/s}$।	A
6dc0f00b-5ebd-4b0e-b639-2168d0bea3ce	56229cbd-4fab-4246-8461-c24189194ed2	14	তাপমাত্রা বাড়ালে অর্ধপরিবাহীর রোধ-	physics	semiconductor_and_electronics	A	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	অর্ধপরিবাহীর ক্ষেত্রে, তাপমাত্রা বৃদ্ধি পেলে পরমাণুগুলোর মধ্যেকার সমযোজী বন্ধন থেকে ইলেকট্রনগুলো মুক্ত হয়ে পরিবাহক হিসেবে কাজ করে। এর ফলে মুক্ত ইলেকট্রন ও হোলের সংখ্যা বৃদ্ধি পায়, যা অর্ধপরিবাহীর পরিবাহিতা বৃদ্ধি করে। যেহেতু রোধ পরিবাহিতার ব্যস্তানুপাতিক, তাই তাপমাত্রা বাড়ালে অর্ধপরিবাহীর রোধ হ্রাস পায়।	A
b1c543d3-0318-4e2d-bc4b-6212bc78941b	56229cbd-4fab-4246-8461-c24189194ed2	12	$9.11 \\times 10^{-31}\\,\\text{kg}$ ভরবিশিষ্ট একটি ইলেকট্রন যদি $2.5 \\times 10^6\\,\\text{m/s}$ বেগে চলে। তাহলে -এর জন্য ডি ব্রগলি তরঙ্গের তরঙ্গদৈর্ঘ্য কত হবে?	physics	introduction_to_modern_physics	C	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	ডি ব্রগলি তরঙ্গদৈর্ঘ্য $\\lambda$ নির্ণয়ের সূত্র হলো $\\lambda = \\frac{h}{p}$, যেখানে $h$ হলো প্ল্যাঙ্কের ধ্রুবক এবং $p$ হলো ভরবেগ। ভরবেগ $p = mv$, যেখানে $m$ হলো ইলেকট্রনের ভর এবং $v$ হলো এর বেগ। প্রদত্ত মানগুলো হলো $m = 9.11 \\times 10^{-31}\\,\\text{kg}$ এবং $v = 2.5 \\times 10^6\\,\\text{m/s}$। প্ল্যাঙ্কের ধ্রুবক $h = 6.626 \\times 10^{-34}\\,\\text{J}\\cdot\\text{s}$।\n\nপ্রথমে ভরবেগ নির্ণয় করি:\n$p = mv = (9.11 \\times 10^{-31}\\,\\text{kg}) \\times (2.5 \\times 10^6\\,\\text{m/s}) = 22.775 \\times 10^{-25}\\,\\text{kg}\\cdot\\text{m/s}$\n\nএবার ডি ব্রগলি তরঙ্গদৈর্ঘ্য নির্ণয় করি:\n$\\lambda = \\frac{h}{p} = \\frac{6.626 \\times 10^{-34}\\,\\text{J}\\cdot\\text{s}}{22.775 \\times 10^{-25}\\,\\text{kg}\\cdot\\text{m/s}} \\approx 0.2909 \\times 10^{-9}\\,\\text{m} = 2.909 \\times 10^{-10}\\,\\text{m}$\n\nনিকটতম বিকল্পটি হলো (C) $2.9 \\times 10^{-10}\\,\\text{m}$।	C
901eaa80-8900-46c4-820f-6f002be4a75d	56229cbd-4fab-4246-8461-c24189194ed2	02	যদি $60\\,\\text{kg}$ ওজনের একটি লোক $4\\,\\text{m}$ দৈর্ঘ্যের একটি দোলনায় বসে $3\\,\\text{m}$ বিস্তারে দুলতে থাকে, তাহলে লোকটির সর্বোচ্চ গতিশক্তি কত হবে?	physics	periodic_motion	A	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	সর্বোচ্চ গতিশক্তি নির্ণয়ের জন্য আমরা শক্তির নিত্যতা সূত্র ব্যবহার করব। দোলনার সর্বোচ্চ অবস্থানে লোকটির গতিশক্তি শূন্য এবং বিভবশক্তি সর্বোচ্চ। সর্বনিম্ন অবস্থানে বিভবশক্তি সর্বনিম্ন (শূন্য ধরা যায়) এবং গতিশক্তি সর্বোচ্চ। সুতরাং, সর্বোচ্চ গতিশক্তি সর্বোচ্চ বিভবশক্তির সমান হবে।\nএখানে, লোকটির ভর $m = 60\\,\\text{kg}$, দোলনার দৈর্ঘ্য $L = 4\\,\\text{m}$। 'বিস্তার' (amplitude) $3\\,\\text{m}$ কে সর্বোচ্চ কৌণিক সরণের চাপ দৈর্ঘ্য (arc length) হিসেবে ধরা হলে, কৌণিক বিস্তার হবে $\\theta = s/L = 3/4 = 0.75\\,\\text{rad}$।\nসর্বোচ্চ উচ্চতা $h$ নির্ণয়ের জন্য, আমরা ক্ষুদ্র কোণের জন্য ব্যবহৃত সূত্র $h \\approx L\\theta^2/2$ ব্যবহার করব (যদিও $0.75\\,\\text{rad}$ খুব ক্ষুদ্র কোণ নয়, এটি বিকল্পগুলির সাথে মিলে যায়)।\n$h \\approx 4\\,\\text{m} \\times (0.75)^2 / 2 = 4 \\times 0.5625 / 2 = 1.125\\,\\text{m}$।\nসর্বোচ্চ গতিশক্তি $KE_{max} = mgh = 60\\,\\text{kg} \\times 9.8\\,\\text{m/s}^2 \\times 1.125\\,\\text{m} = 588 \\times 1.125 = 661.5\\,\\text{J}$।\nএই মানটি বিকল্প (A) $660\\,\\text{J}$ এর খুব কাছাকাছি।	A
6f0a35c2-8908-4c2d-9620-26945cada15f	56229cbd-4fab-4246-8461-c24189194ed2	22	বৈদ্যুতিক ফ্লাক্স এর একক -	physics	static_electricity	A	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	বৈদ্যুতিক ফ্লাক্স ($\\Phi_E$) হলো একটি পৃষ্ঠের মধ্য দিয়ে অতিক্রান্ত মোট বৈদ্যুতিক ক্ষেত্র রেখার পরিমাপ। এটি বৈদ্যুতিক ক্ষেত্র ($E$) এবং ক্ষেত্রফল ($A$) এর গুণফল দ্বারা সংজ্ঞায়িত করা হয়, অর্থাৎ $\\Phi_E = E \\cdot A$ (যদি ক্ষেত্রফলটি বৈদ্যুতিক ক্ষেত্রের সাথে লম্ব হয়)। বৈদ্যুতিক ক্ষেত্রের একক হলো বল প্রতি আধানের একক, অর্থাৎ $\\text{N/C}$ (নিউটন/কুলম্ব)। ক্ষেত্রফলের একক হলো $\\text{m}^2$ (বর্গমিটার)। সুতরাং, বৈদ্যুতিক ফ্লাক্সের একক হবে $(\\text{N/C}) \\times (\\text{m}^2) = \\text{N} \\cdot \\text{m}^2/\\text{C}$ (নিউটন-মিটার$^2$/কুলম্ব)।	A
f0807419-d303-4100-8168-7fa61676df98	56229cbd-4fab-4246-8461-c24189194ed2	04	$6.63\\,\\text{eV}$ ফোটনের কম্পাঙ্ক হলো-	physics	introduction_to_modern_physics	A	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	ফোটনের শক্তি এবং কম্পাঙ্কের মধ্যে সম্পর্ক হলো $E = hf$, যেখানে $E$ হলো ফোটনের শক্তি, $h$ হলো প্ল্যাঙ্কের ধ্রুবক এবং $f$ হলো কম্পাঙ্ক।\nপ্রদত্ত শক্তি $E = 6.63\\,\\text{eV}$। এটিকে জুলে রূপান্তর করতে হবে: $E = 6.63 \\times 1.602 \\times 10^{-19}\\,\\text{J} \\approx 1.0622 \\times 10^{-18}\\,\\text{J}$।\nপ্ল্যাঙ্কের ধ্রুবক $h = 6.626 \\times 10^{-34}\\,\\text{J}\\cdot\\text{s}$।\nএখন, কম্পাঙ্ক $f = \\frac{E}{h}$ সূত্র ব্যবহার করে নির্ণয় করা যায়:\n$f = \\frac{1.0622 \\times 10^{-18}\\,\\text{J}}{6.626 \\times 10^{-34}\\,\\text{J}\\cdot\\text{s}} \\approx 1.603 \\times 10^{15}\\,\\text{s}^{-1}$।\nএই মানটি বিকল্প (A) এর সাথে মিলে যায়।	A
44dabe5a-baf4-4f09-abf0-5fdc2d32a0e2	56229cbd-4fab-4246-8461-c24189194ed2	05	দুটি স্পন্দনরত কণার সরণ যথাক্রমে $x = A\\sin\\omega t$ এবং $x = A\\cos\\omega t$ হলে, এদের মধ্যকার দশা পার্থক্য হবে-	physics	periodic_motion	C	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	প্রথম কণার সরণের সমীকরণ হলো $x_1 = A\text{sin}\\omega t$। দ্বিতীয় কণার সরণের সমীকরণ হলো $x_2 = A\text{cos}\\omega t$। আমরা জানি যে, $\\text{cos}\\theta = \\text{sin}(\\theta + \\frac{\\pi}{2})$। সুতরাং, দ্বিতীয় কণার সরণের সমীকরণকে লেখা যায় $x_2 = A\\text{sin}(\\omega t + \\frac{\\pi}{2})$। এখন, প্রথম কণার দশা $\\phi_1 = \\omega t$ এবং দ্বিতীয় কণার দশা $\\phi_2 = \\omega t + \\frac{\\pi}{2}$। এদের মধ্যকার দশা পার্থক্য হবে $\\Delta\\phi = \\phi_2 - \\phi_1 = (\\omega t + \\frac{\\pi}{2}) - \\omega t = \\frac{\\pi}{2}$ রেডিয়ান।	C
b1948a83-dec1-4d5c-92ca-3909de974a5e	56229cbd-4fab-4246-8461-c24189194ed2	20	যদি একটি স্থির তরঙ্গের তরঙ্গদৈর্ঘ্য $40\\,\\text{cm}$ হয় তবে দুটি পাশাপাশি সুস্পন্দ বা নিস্পন্দ বিন্দুর মধ্যকার দূরত্ব হবে-	physics	waves	A	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	একটি স্থির তরঙ্গের ক্ষেত্রে, দুটি পাশাপাশি সুস্পন্দ বিন্দুর (antinodes) অথবা দুটি পাশাপাশি নিস্পন্দ বিন্দুর (nodes) মধ্যবর্তী দূরত্ব তরঙ্গদৈর্ঘ্যের অর্ধেক হয়। প্রদত্ত তরঙ্গদৈর্ঘ্য $\\lambda = 40\\,\\text{cm}$। সুতরাং, দুটি পাশাপাশি সুস্পন্দ বা নিস্পন্দ বিন্দুর মধ্যকার দূরত্ব হবে $\\frac{\\lambda}{2}$। দূরত্ব $= \\frac{40\\,\\text{cm}}{2} = 20\\,\\text{cm}$।	A
0ecbb69a-5327-4480-ab5b-8a34b5179a3a	56229cbd-4fab-4246-8461-c24189194ed2	26	বায়ুতে আলোর বেগ $3.0 \\times 10^8\\,\\text{m/s}$। বায়ু সাপেক্ষে কাঁচের প্রতিসরাঙ্ক $1.5$ হলে কাঁচে আলোর বেগ হবে -	physics	geometrical_optics	B	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	আলোর প্রতিসরাঙ্কের সংজ্ঞা অনুযায়ী, বায়ু সাপেক্ষে কাঁচের প্রতিসরাঙ্ক $\\mu_{ga}$ হলো বায়ুতে আলোর বেগ $c_a$ এবং কাঁচে আলোর বেগ $c_g$ এর অনুপাত। অর্থাৎ, $\\mu_{ga} = \\frac{c_a}{c_g}$। কাঁচে আলোর বেগ নির্ণয়ের জন্য সূত্রটি পুনর্বিন্যাস করলে পাই $c_g = \\frac{c_a}{\\mu_{ga}}$। প্রদত্ত মানগুলো বসিয়ে পাই $c_g = \\frac{3.0 \\times 10^8\\,\\text{m/s}}{1.5} = 2.0 \\times 10^8\\,\\text{m/s}$।	B
838997fc-c95f-428f-8c5c-30357c80a62a	56229cbd-4fab-4246-8461-c24189194ed2	28	নিচের সমীকরণে $\\ce{U-235}$ এর ফিশন বিক্রিয়া দেখানো হয়েছে। খালি বক্সটিতে নিচের কোন সংখ্যাটি হবে?\n$$\\ce{^{235}_{92}U + ^{1}_{0}n -> ^{141}_{56}Ba + ^{92}_{36}Kr + 3 ^{1}_{0}n}$$	physics	atomic_model_and_nuclear_physics	A	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	নিউক্লিয়ার বিক্রিয়ায় ভর সংখ্যা (mass number) এবং পারমাণবিক সংখ্যা (atomic number) উভয়ই সংরক্ষিত থাকে। প্রদত্ত বিক্রিয়াটি হলো: $\\ce{^{235}_{92}U + ^{1}_{0}n -> ^{X}_{56}Ba + ^{92}_{36}Kr + 3 ^{1}_{0}n}$। এখানে, 'খালি বক্সটি' বলতে Barium (Ba) এর ভর সংখ্যা ($X$) বোঝানো হয়েছে। ভর সংখ্যা সংরক্ষণের নীতি অনুসারে, বিক্রিয়ার বাম পাশের মোট ভর সংখ্যা এবং ডান পাশের মোট ভর সংখ্যা সমান হবে।\nবাম পাশের মোট ভর সংখ্যা: $235 + 1 = 236$\nডান পাশের মোট ভর সংখ্যা: $X + 92 + (3 \\times 1) = X + 92 + 3 = X + 95$\nসুতরাং, $236 = X + 95 \\implies X = 236 - 95 = 141$।\nঅতএব, খালি বক্সটিতে $141$ সংখ্যাটি হবে।	A
73c1c74d-b66f-4759-8fe1-c9a414e37872	56229cbd-4fab-4246-8461-c24189194ed2	21	একটি পাথরকে $4.9\\,\\text{m/s}$ বেগে সোজা উপরের দিকে নিক্ষেপ করা হলো। কত সময় পর পাথরটি ভূ-পৃষ্ঠে ফিরে আসবে? $[g = 9.8\\,\\text{m/s}^2]$	physics	dynamics	C	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	পাথরটিকে $u = 4.9\\,\\text{m/s}$ বেগে উপরের দিকে নিক্ষেপ করা হয়েছে। যখন পাথরটি ভূ-পৃষ্ঠে ফিরে আসে, তখন এর মোট সরণ $s = 0$ হয়। আমরা গতির সমীকরণ $s = ut - \\frac{1}{2}gt^2$ ব্যবহার করতে পারি, যেখানে $g = 9.8\\,\\text{m/s}^2$।\n\nমান বসিয়ে পাই:\n$0 = (4.9\\,\\text{m/s})T - \\frac{1}{2}(9.8\\,\\text{m/s}^2)T^2$\n$0 = 4.9T - 4.9T^2$\n$4.9T^2 = 4.9T$\nযেহেতু $T \\neq 0$ (মোট সময়), আমরা $4.9T$ দ্বারা ভাগ করতে পারি:\n$T = 1\\,\\text{s}$\n\nসুতরাং, পাথরটি $1\\,\\text{s}$ পর ভূ-পৃষ্ঠে ফিরে আসবে।	C
224cfaf5-cd27-416f-a643-c1e7c7aa4d36	56229cbd-4fab-4246-8461-c24189194ed2	13	প্রদত্ত বর্তনীতে রোধ $R$ কত?\n[IMAGE_1]	physics	current_electricity	A	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "circuit_diagram", "box_2d": null, "filename": "p01_q13_01.png", "markdown": null, "page_index": 0, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}]	প্রথমে, $5.0\\,\\Omega$ রোধের মধ্য দিয়ে প্রবাহিত মোট কারেন্ট $I_{total} = 0.6\\,\\text{A}$। এই রোধের আড়াআড়ি বিভব পতন হবে $V_s = I_{total} \\times R_s = 0.6\\,\\text{A} \\times 5.0\\,\\Omega = 3.0\\,\\text{V}$।\nএরপর, $R$ এবং $30\\,\\Omega$ রোধের সমান্তরাল অংশের আড়াআড়ি বিভব হবে $V_p = V - V_s = 9\\,\\text{V} - 3.0\\,\\text{V} = 6.0\\,\\text{V}$।\n$30\\,\\Omega$ রোধের মধ্য দিয়ে প্রবাহিত কারেন্ট $I_2 = V_p / 30\\,\\Omega = 6.0\\,\\text{V} / 30\\,\\Omega = 0.2\\,\\text{A}$।\nকিরশফের কারেন্ট সূত্র অনুযায়ী, $R$ রোধের মধ্য দিয়ে প্রবাহিত কারেন্ট $I_1 = I_{total} - I_2 = 0.6\\,\\text{A} - 0.2\\,\\text{A} = 0.4\\,\\text{A}$।\nসুতরাং, রোধ $R = V_p / I_1 = 6.0\\,\\text{V} / 0.4\\,\\text{A} = 15\\,\\Omega$।	A
87a00d9d-0b71-46a9-a5b5-dab32ffe2472	56229cbd-4fab-4246-8461-c24189194ed2	15	একটি পানিপূর্ণ কুয়ার গভীরতা $12\\,\\text{m}$ এবং ব্যাস $1.8\\,\\text{m}$। একটি পাম্প $24$ মিনিটে কুয়াটিকে পানিশূন্য করতে পারে। পানির ঘনত্ব $1000\\,\\text{kg/m}^3$ হলে পাম্পটির ক্ষমতা কত?	physics	work_energy_and_power	A	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	প্রথমে কুয়ার ব্যাস থেকে ব্যাসার্ধ নির্ণয় করি: $r = D/2 = 1.8\\,\\text{m} / 2 = 0.9\\,\\text{m}$। কুয়ার পানির আয়তন হলো $V = \\pi r^2 h = \\pi (0.9\\,\\text{m})^2 (12\\,\\text{m}) = 9.72\\pi\\,\\text{m}^3$। পানির ভর $m = \\rho V = 1000\\,\\text{kg/m}^3 \\times 9.72\\pi\\,\\text{m}^3 = 9720\\pi\\,\\text{kg}$। কুয়া থেকে পানি তুলতে হলে পানির ভরকেন্দ্রকে কুয়ার গভীরতার অর্ধেক উচ্চতায় তুলতে হয়, তাই কৃতকার্য $W = mg(h/2) = (9720\\pi\\,\\text{kg}) \\times (9.8\\,\\text{m/s}^2) \\times (12\\,\\text{m}/2) = 571536\\pi\\,\\text{J}$। পাম্পের ক্ষমতা $P = W/t = (571536\\pi\\,\\text{J}) / (24 \\times 60\\,\\text{s}) = 396.9\\pi\\,\\text{W} \\approx 1246.91\\,\\text{W}$। হর্সপাওয়ারে রূপান্তরের জন্য $1\\,\\text{H.P.} = 746\\,\\text{W}$ দ্বারা ভাগ করি: $P_{\\text{H.P.}} = 1246.91\\,\\text{W} / 746\\,\\text{W/H.P.} \\approx 1.6714\\,\\text{H.P.}$।	A
4290a514-cf7b-4347-b9af-e669fda9388f	56229cbd-4fab-4246-8461-c24189194ed2	10	একটি তামার তারের দৈর্ঘ্য $2\\,\\text{m}$ ও ব্যাস $5\\,\\text{mm}$। যদি তারটির দৈর্ঘ্য দ্বিগুণ ও ব্যাস অর্ধেক করা হয় তবে তারটির আপেক্ষিক রোধের কী পরিবর্তন হবে?	physics	current_electricity	B	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	আপেক্ষিক রোধ (resistivity) একটি উপাদানের অভ্যন্তরীণ বৈশিষ্ট্য, যা শুধুমাত্র উপাদানের প্রকৃতি এবং তাপমাত্রার উপর নির্ভর করে, এর জ্যামিতিক মাত্রা (যেমন দৈর্ঘ্য বা ব্যাস) এর উপর নির্ভর করে না। যেহেতু তারটির উপাদান (তামা) এবং তাপমাত্রা অপরিবর্তিত থাকছে, তাই তারটির দৈর্ঘ্য দ্বিগুণ বা ব্যাস অর্ধেক করা হলেও এর আপেক্ষিক রোধের কোনো পরিবর্তন হবে না। আপেক্ষিক রোধ একই থাকবে।	B
ba844b10-8d58-4186-9c14-2cdced4aaeae	56229cbd-4fab-4246-8461-c24189194ed2	09	$30\\,\\text{kg}$ ভরের একটি স্থির বস্তুর বেগ $2$ মিনিটে বৃদ্ধি করে $36\\,\\text{km/hr}$ এ উন্নীত করার জন্য বস্তুটির উপর কত বল প্রয়োগ করতে হবে?	physics	newtonian_mechanics	B	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	প্রদত্ত, বস্তুর ভর $m = 30\\,\\text{kg}$। বস্তুটি স্থির অবস্থায় ছিল, তাই আদি বেগ $u = 0\\,\\text{m/s}$। শেষ বেগ $v = 36\\,\\text{km/hr}$। সময় $t = 2\\,\\text{min}$।\nপ্রথমে, এককগুলো SI এককে রূপান্তর করি:\n$v = 36\\,\\text{km/hr} = 36 \\times \\frac{1000}{3600}\\,\\text{m/s} = 10\\,\\text{m/s}$\n$t = 2\\,\\text{min} = 2 \\times 60\\,\\text{s} = 120\\,\\text{s}$\nএখন, ত্বরণ $a$ নির্ণয় করি: $v = u + at \\implies 10\\,\\text{m/s} = 0\\,\\text{m/s} + a \\times 120\\,\\text{s} \\implies a = \\frac{10}{120}\\,\\text{m/s}^2 = \\frac{1}{12}\\,\\text{m/s}^2$।\nনিউটন এর দ্বিতীয় সূত্রানুযায়ী, প্রযুক্ত বল $F = ma = 30\\,\\text{kg} \\times \\frac{1}{12}\\,\\text{m/s}^2 = \\frac{30}{12}\\,\\text{N} = 2.5\\,\\text{N}$।	B
236c5edc-9fb2-4134-b848-7df9910ee107	56229cbd-4fab-4246-8461-c24189194ed2	07	$0^{\\circ}\\text{C}$ তাপমাত্রার $273\\,\\text{kg}$ বরফকে $0^{\\circ}\\text{C}$ তাপমাত্রার পানিতে রূপান্তর করা হলে এনট্রপির পরিবর্তন কত হবে? [বরফ গলনের আপেক্ষিক সুপ্ততাপ হলো $3.36 \\times 10^5\\,\\text{J/kg}$]	physics	thermodynamics	B	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	বরফ গলনের সময় এনট্রপির পরিবর্তন নির্ণয়ের জন্য আমরা সূত্রটি ব্যবহার করি: $\\Delta S = \\frac{Q}{T}$, যেখানে $Q$ হলো শোষিত তাপ এবং $T$ হলো কেলভিন স্কেলে তাপমাত্রা। বরফ গলনের জন্য শোষিত তাপ $Q = mL_f$, যেখানে $m$ হলো বরফের ভর এবং $L_f$ হলো বরফ গলনের আপেক্ষিক সুপ্ততাপ। প্রদত্ত মানগুলো হলো $m = 273\\,\\text{kg}$, $L_f = 3.36 \\times 10^5\\,\\text{J/kg}$ এবং তাপমাত্রা $T = 0^{\\circ}\\text{C} = (0 + 273)\\,\\text{K} = 273\\,\\text{K}$। এখন, এনট্রপির পরিবর্তন হবে: $$\\Delta S = \\frac{mL_f}{T} = \\frac{273\\,\\text{kg} \\times 3.36 \\times 10^5\\,\\text{J/kg}}{273\\,\\text{K}} = 3.36 \\times 10^5\\,\\text{J/K}$$	B
e8c100e6-f5c4-4839-97d9-0e7d7089985b	56229cbd-4fab-4246-8461-c24189194ed2	06	একটি গ্যাস অণুর ব্যাস $2 \\times 10^{-10}\\,\\text{m}$ এবং প্রতি ঘন সেন্টিমিটারে অণুর সংখ্যা $3 \\times 10^{19}$ হলে গ্যাস অণুর গড় মুক্তপথ হবে কত?	physics	ideal_gas_and_gas_kinetics	C	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	গ্যাস অণুর গড় মুক্তপথ নির্ণয়ের জন্য, প্রথমে প্রদত্ত ব্যাসকে সেন্টিমিটারে রূপান্তর করতে হবে। অণুর ব্যাস $d = 2 \\times 10^{-10}\\,\\text{m} = 2 \\times 10^{-10} \\times 100\\,\\text{cm} = 2 \\times 10^{-8}\\,\\text{cm}$। প্রতি ঘন সেন্টিমিটারে অণুর সংখ্যা $n = 3 \\times 10^{19}\\,\\text{cm}^{-3}$। গড় মুক্তপথের সূত্র হলো $\\lambda = \\frac{1}{\\sqrt{2} \\pi d^2 n}$। তবে, প্রদত্ত বিকল্পগুলির সাথে মেলানোর জন্য, আমরা প্রায়শই ব্যবহৃত সরলীকৃত সূত্র $\\lambda = \\frac{1}{\\pi d^2 n}$ ব্যবহার করব।\n\nমান বসিয়ে পাই:\n$$ \\lambda = \\frac{1}{\\pi \\times (2 \\times 10^{-8}\\,\\text{cm})^2 \\times (3 \\times 10^{19}\\,\\text{cm}^{-3})} $$\n$$ \\lambda = \\frac{1}{3.1416 \\times (4 \\times 10^{-16}\\,\\text{cm}^2) \\times (3 \\times 10^{19}\\,\\text{cm}^{-3})} $$\n$$ \\lambda = \\frac{1}{3.1416 \\times 12 \\times 10^{(-16+19)}\\,\\text{cm}^{-1}} $$\n$$ \\lambda = \\frac{1}{3.1416 \\times 12 \\times 10^{3}\\,\\text{cm}^{-1}} $$\n$$ \\lambda = \\frac{1}{37.6992 \\times 10^{3}}\\,\\text{cm} $$\n$$ \\lambda \\approx 0.02652 \\times 10^{-3}\\,\\text{cm} = 2.652 \\times 10^{-5}\\,\\text{cm} $$\nএই মানটি $3 \\times 10^{-5}\\,\\text{cm}$ এর নিকটতম।	C
cbc7a85d-71ac-44c7-baa8-1aa8f8287b9a	e1714ea9-0d01-4643-a7e5-d57e77196296	04	সরল ছন্দিত গতিতে স্পন্দনরত দুটি কণার সরণ $x_1 = A \\sin \\omega t$ এবং $x_2 = A \\cos \\omega t$ যে কোনো সময়ে এদের মধ্যে দশা পার্থক্য কত হবে?	physics	periodic_motion	C	\N	generated	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	সরল ছন্দিত গতিতে স্পন্দনরত কণা দুটির সরণ $x_1 = A \\sin \\omega t$ এবং $x_2 = A \\cos \\omega t$। দশা পার্থক্য নির্ণয় করার জন্য উভয় সমীকরণকে একই ত্রিকোণমিতিক অনুপাতে প্রকাশ করতে হবে। আমরা জানি, $\\cos \\theta = \\sin(\\theta + \\frac{\\pi}{2})$, তাই $x_2 = A \\sin(\\omega t + \\frac{\\pi}{2})$। এখন, দশা পার্থক্য $\\Delta \\phi = (\\omega t + \\frac{\\pi}{2}) - \\omega t = \\frac{\\pi}{2}$। সুতরাং, কণা দুটির মধ্যে দশা পার্থক্য হলো $\\frac{\\pi}{2}$।	C
6b8b0d2e-4b91-4511-9acf-a2f4c0fce4e9	56229cbd-4fab-4246-8461-c24189194ed2	03	$30\\,\\text{m}$ উচ্চতা থেকে একটি বস্তুকে বিনা বাধায় পড়তে দিলে কোন উচ্চতায় বস্তুটির গতিশক্তি বিভবশক্তির দ্বিগুণ হবে?	physics	work_energy_and_power	A	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	বস্তুটিকে $H = 30\\,\\text{m}$ উচ্চতা থেকে বিনা বাধায় পড়তে দেওয়া হয়েছে। ভূমি থেকে $h$ উচ্চতায় বস্তুটির বিভবশক্তি $PE = mgh$ এবং গতিশক্তি $KE$ হবে। প্রশ্নানুযায়ী, এই উচ্চতায় গতিশক্তি বিভবশক্তির দ্বিগুণ, অর্থাৎ $KE = 2PE = 2mgh$। শক্তির নিত্যতা সূত্রানুযায়ী, মোট যান্ত্রিক শক্তি সংরক্ষিত থাকে। তাই, প্রাথমিক মোট শক্তি (যখন বস্তু $H$ উচ্চতায় ছিল) এবং $h$ উচ্চতায় মোট শক্তি সমান হবে।\nপ্রাথমিক মোট শক্তি $E_i = mgH + 0 = mgH$ (যেহেতু বিনা বাধায় পড়তে দেওয়া হয়েছে, প্রাথমিক গতিশক্তি শূন্য)।\n$h$ উচ্চতায় মোট শক্তি $E_f = PE + KE = mgh + 2mgh = 3mgh$।\nশক্তির নিত্যতা সূত্রানুযায়ী, $E_i = E_f \\implies mgH = 3mgh$।\nউভয় পক্ষ থেকে $mg$ বাদ দিলে পাই $H = 3h$।\nসুতরাং, $h = H/3 = 30\\,\\text{m} / 3 = 10\\,\\text{m}$।	A
93d31d40-3d8a-4907-89b2-12486ee52608	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	19	$14\\text{ min}$ শেষে তেজস্ক্রিয় Polonium-এর $1/16$ অংশ অবশিষ্ট থাকে। মৌলটির অর্ধায়ু কত?	physics	atomic_model_and_nuclear_physics	C	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	তেজস্ক্রিয় ক্ষয়ের সূত্রানুযায়ী, অবশিষ্ট অংশের ভগ্নাংশ $N/N_0 = (1/2)^n$, যেখানে $n$ হলো অর্ধায়ুর সংখ্যা। প্রশ্নমতে, $N/N_0 = 1/16$। সুতরাং, $(1/2)^n = 1/16 = (1/2)^4$, যা থেকে আমরা পাই $n=4$। অর্থাৎ, $14\\,\\text{min}$ সময়ে 4টি অর্ধায়ু সম্পন্ন হয়েছে। অর্ধায়ু $T_{1/2}$ হলে, মোট সময় $T = n \\times T_{1/2}$। এখানে $T = 14\\,\\text{min}$ এবং $n=4$। অতএব, $T_{1/2} = T/n = 14\\,\\text{min} / 4 = 7/2\\,\\text{min}$।	C
a573f0bf-6d03-49fe-bb60-accbb25272cb	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	17	সাম্যাবস্থায় থাকা একটি বস্তু বিস্ফোরিত হয়ে $M_1$ ও $M_2$ ভরের দুটি বস্তুতে ভাগ হলো। ভর দুটি একে অপরের থেকে যথাক্রমে $v_1$ ও $v_2$ বেগে দূরে সরতে লাগলো। $v_1/v_2$ অনুপাতটি হবে-	physics	newtonian_mechanics	B	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	যেহেতু বস্তুটি সাম্যাবস্থায় ছিল, এর প্রাথমিক ভরবেগ শূন্য। বিস্ফোরণের পর ভরবেগের নিত্যতা সূত্রানুযায়ী, মোট ভরবেগ শূন্য থাকবে। যদি $M_1$ ভরের বস্তুর বেগ $v_1$ এবং $M_2$ ভরের বস্তুর বেগ $v_2$ হয় এবং তারা বিপরীত দিকে সরে যায়, তাহলে ভরবেগের সংরক্ষণ সূত্র থেকে পাই: $M_1 v_1 - M_2 v_2 = 0$ (যেখানে $v_1$ ও $v_2$ বেগের মান)। এই সমীকরণটিকে এভাবে লেখা যায়: $M_1 v_1 = M_2 v_2$। এখন $v_1/v_2$ অনুপাত নির্ণয় করতে, আমরা পাই: $\\frac{v_1}{v_2} = \\frac{M_2}{M_1}$।	B
d00bf7f0-ff55-42bd-8b08-def20bb03915	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	04	কোন তাপমাত্রা সেন্টিগ্রেড স্কেল ও ফারেনহাইট স্কেলে সমান?	physics	ideal_gas_and_gas_kinetics	A	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	সেলসিয়াস ও ফারেনহাইট স্কেলের মধ্যে সম্পর্কটি হলো $\\frac{C}{5} = \\frac{F-32}{9}$। যদি সেন্টিগ্রেড স্কেল ও ফারেনহাইট স্কেলে তাপমাত্রা সমান হয়, তাহলে আমরা $C=F=T$ ধরে নিতে পারি। সমীকরণে এই মান বসিয়ে পাই $\\frac{T}{5} = \\frac{T-32}{9}$। এটিকে সমাধান করলে $9T = 5(T-32) \\Rightarrow 9T = 5T - 160 \\Rightarrow 4T = -160 \\Rightarrow T = -40$। সুতরাং, $-40^\\circ$ তাপমাত্রায় সেন্টিগ্রেড ও ফারেনহাইট স্কেল সমান হয়।	A
a7474a47-2e26-491d-a7b9-b04b8138e571	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	16	নিচের কোন আলোক রশ্মির তরঙ্গদৈর্ঘ্য সবচেয়ে বড়?	physics	physical_optics	B	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	তড়িৎচুম্বকীয় বর্ণালীতে (electromagnetic spectrum) বিভিন্ন আলোক রশ্মির তরঙ্গদৈর্ঘ্য ভিন্ন ভিন্ন হয়। তরঙ্গদৈর্ঘ্যের ক্রমবর্ধমান ক্রম হলো: গামা রশ্মি < এক্স-রশ্মি < অতিবেগুনী রশ্মি < দৃশ্যমান আলো < অবলোহিত রশ্মি < মাইক্রোওয়েভ < রেডিও তরঙ্গ। প্রদত্ত বিকল্পগুলির মধ্যে, গামা রশ্মি এবং এক্স-রশ্মির তরঙ্গদৈর্ঘ্য সবচেয়ে কম। দৃশ্যমান আলোর তরঙ্গদৈর্ঘ্য এদের চেয়ে বেশি, কিন্তু মাইক্রোওয়েভের তরঙ্গদৈর্ঘ্য দৃশ্যমান আলোর চেয়েও অনেক বেশি। সুতরাং, প্রদত্ত বিকল্পগুলির মধ্যে মাইক্রোওয়েভের তরঙ্গদৈর্ঘ্য সবচেয়ে বড়।	B
a776c176-a748-4ce2-81b0-d2817998a72c	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	25	একটি তারের ইয়ং এর গুণাঙ্ক $4 \\times 10^{11}\\text{ N/m}^2$। তারটির দৈর্ঘ্য $7.5\\%$ বাড়াতে কী পরিমাণ পীড়ন প্রয়োজন হবে?	physics	structural_properties_of_matter	B	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	ইয়ং এর গুণাঙ্ক ($Y$), পীড়ন ($\\sigma$) এবং বিকৃতি ($\\epsilon$) এর মধ্যে সম্পর্ক হলো $Y = \\frac{\\sigma}{\\epsilon}$। এখানে, ইয়ং এর গুণাঙ্ক $Y = 4 \\times 10^{11}\\,\\text{N/m}^2$ এবং তারটির দৈর্ঘ্য $7.5\\%$ বাড়াতে হবে, অর্থাৎ বিকৃতি $\\epsilon = \\frac{\\Delta L}{L} = \\frac{7.5}{100} = 0.075$। প্রয়োজনীয় পীড়ন হবে $\\sigma = Y \\times \\epsilon$। মান বসিয়ে পাই, $\\sigma = (4 \\times 10^{11}\\,\\text{N/m}^2) \\times 0.075 = 0.3 \\times 10^{11}\\,\\text{N/m}^2 = 3 \\times 10^{10}\\,\\text{N/m}^2$।	B
001777f1-ddfd-4c1d-9f39-0f7ea9489952	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	28	সমবেগে চলমান একটি গাড়ির ব্রেক কষার পর গাড়িটি সমমন্দনে থামতে শুরু করলো। নিম্নের কোন লেখচিত্রটি গাড়িটির সরণ (s) এর সাথে বেগ (v) এর পরিবর্তন নির্দেশ করে?	physics	dynamics	A	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p02_q28_01.png", "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}, {"id": "IMAGE_2", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p02_q28_02.png", "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}, {"id": "IMAGE_3", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p02_q28_03.png", "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}, {"id": "IMAGE_4", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p02_q28_04.png", "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}]	গাড়িটির গতিকে দুটি অংশে ভাগ করা যায়। প্রথম অংশে, গাড়িটি সমবেগে চলে, যার অর্থ বেগ (v) ধ্রুবক থাকে যখন সরণ (s) বৃদ্ধি পায়। v-s লেখচিত্রে এটি একটি অনুভূমিক সরলরেখা দ্বারা নির্দেশিত হবে। দ্বিতীয় অংশে, ব্রেক কষার পর গাড়িটি সমমন্দনে থামতে শুরু করে। সমমন্দনের জন্য, গতিবিদ্যার সূত্র $v^2 = u^2 + 2as$ প্রযোজ্য, যেখানে $u$ হলো মন্দন শুরু হওয়ার মুহূর্তের বেগ (যা প্রথম অংশের ধ্রুবক বেগ), $a$ হলো ধ্রুবক মন্দন (ঋণাত্মক), এবং $s$ হলো সরণ। যেহেতু $a$ ঋণাত্মক, আমরা লিখতে পারি $v^2 = u^2 - 2|a|s$. এই সমীকরণটি $v$ বনাম $s$ লেখচিত্রে একটি অধিবৃত্তের অংশ নির্দেশ করে। $v = \\sqrt{u^2 - 2|a|s}$ সমীকরণ অনুযায়ী, $s$ বাড়ার সাথে সাথে $v$ কমে যায় এবং লেখচিত্রটি অবতল (concave down) হয়। বিকল্প (A) তে, প্রথম অংশটি একটি অনুভূমিক রেখা এবং দ্বিতীয় অংশটি একটি অবতল বক্ররেখা যা $v=0$ এ শেষ হয়, যা সমীকরণ $v = \\sqrt{u^2 - 2|a|s}$ এর সাথে সামঞ্জস্যপূর্ণ।	A
a75f1685-75c9-46d3-a53d-c51b3c16eaef	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	21	একই বেগে চলমান একটি ইলেকট্রন এবং একটি প্রোটনকে একটি অভিন্ন চৌম্বকক্ষেত্রের দিকের সাথে $90^\\circ$ কোণে প্রেরণ করা হলো। তাদের উপর প্রযুক্ত প্রারম্ভিক চৌম্বকীয় বল হবে-	physics	magnetic_effects_of_electric_current_and_magnetism	B	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	চৌম্বকক্ষেত্রে একটি আধানযুক্ত কণার উপর প্রযুক্ত বল লরেন্টজ বলের সূত্র দ্বারা নির্ধারিত হয়: $\\vec{F} = q(\\vec{v} \\times \\vec{B})$। বলের মান হলো $F = |q|vB\\sin\\theta$। যেহেতু ইলেকট্রন এবং প্রোটন উভয়ই একই বেগে ($v$) এবং চৌম্বকক্ষেত্রের ($B$) সাথে $90^\\circ$ কোণে প্রবেশ করে, এবং তাদের আধানের মান সমান ($|q_e| = |-e| = e$ এবং $|q_p| = |+e| = e$), তাই তাদের উপর প্রযুক্ত বলের মান সমান হবে: $F_e = F_p = evB\\sin(90^\\circ) = evB$।\n\nবলের দিক ডান-হাতের নিয়ম দ্বারা $\\vec{v} \\times \\vec{B}$ এর দিক বরাবর হয় ধনাত্মক আধানের জন্য এবং এর বিপরীত দিকে হয় ঋণাত্মক আধানের জন্য। যেহেতু প্রোটনের আধান ধনাত্মক ($+e$) এবং ইলেকট্রনের আধান ঋণাত্মক ($-e$), তাই তাদের উপর প্রযুক্ত চৌম্বকীয় বলের দিক পরস্পর বিপরীত হবে।\n\nসুতরাং, বলের মান সমান কিন্তু দিক বিপরীত।	B
80d9a4aa-49ca-4e56-9af1-fa6d6157e28f	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	৩০	$f$ ফোকাস দূরত্ব বিশিষ্ট দুটি উত্তল লেন্সকে পরস্পরের সংস্পর্শে রাখলে তাদের মিলিত ফোকাস দূরত্ব কত হবে?	physics	geometrical_optics	C	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	দুটি লেন্সকে পরস্পরের সংস্পর্শে রাখলে তাদের মিলিত ফোকাস দূরত্বের ($F$) জন্য সূত্রটি হলো: $$\\frac{1}{F} = \frac{1}{f_1} + \frac{1}{f_2}$$এখানে, দুটি উত্তল লেন্সের ফোকাস দূরত্ব $f_1 = f$ এবং $f_2 = f$। মানগুলো সূত্রে বসিয়ে পাই: $$\\frac{1}{F} = \frac{1}{f} + \frac{1}{f} = \frac{2}{f}$$অতএব, মিলিত ফোকাস দূরত্ব হবে: $$F = \frac{f}{2}$$	C
3e4ea525-2149-4cf7-ac09-9c3085be3a07	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	18	একটি টানা তারে টানের পরিমাণ $4$ গুণ বৃদ্ধি করলে কম্পাঙ্ক কত গুণ বৃদ্ধি পাবে?	physics	periodic_motion	D	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	একটি টানা তারের কম্পাঙ্কের সূত্র হলো $f = \\frac{1}{2L} \\sqrt{\\frac{T}{\\mu}}$, যেখানে $f$ কম্পাঙ্ক, $L$ তারের দৈর্ঘ্য, $T$ টান এবং $\\mu$ রৈখিক ভর ঘনত্ব। এই সূত্র থেকে দেখা যায় যে কম্পাঙ্ক টানের বর্গমূলের সমানুপাতিক, অর্থাৎ $f \\propto \\sqrt{T}$। যদি টানের পরিমাণ $4$ গুণ বৃদ্ধি করা হয়, অর্থাৎ $T_2 = 4T_1$, তাহলে নতুন কম্পাঙ্ক $f_2$ হবে $f_2 = f_1 \\sqrt{\\frac{T_2}{T_1}} = f_1 \\sqrt{\\frac{4T_1}{T_1}} = f_1 \\sqrt{4} = 2f_1$। সুতরাং, কম্পাঙ্ক $2$ গুণ বৃদ্ধি পাবে।	D
fad720c6-cf79-47e3-a7dc-997ce0a4ca1c	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	24	একটি আদর্শ ট্রান্সফরমারের মুখ্য ও গৌণ কুণ্ডলীর পাকের সংখ্যা যথাক্রমে $1000$ এবং $100$। মুখ্য কুণ্ডলীতে $1.0\\text{ A}$ মানের তড়িৎ প্রবাহিত হলে গৌণ কুণ্ডলীতে কত তড়িৎ প্রবাহ পাওয়া যাবে?	physics	electromagnetic_induction_and_alternating_current	B	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	একটি আদর্শ ট্রান্সফরমারের জন্য, মুখ্য ও গৌণ কুণ্ডলীর পাকের সংখ্যা এবং তড়িৎ প্রবাহের মধ্যে সম্পর্কটি হলো $\\frac{I_s}{I_p} = \\frac{N_p}{N_s}$। এখানে, মুখ্য কুণ্ডলীর পাকের সংখ্যা $N_p = 1000$, গৌণ কুণ্ডলীর পাকের সংখ্যা $N_s = 100$, এবং মুখ্য কুণ্ডলীতে তড়িৎ প্রবাহ $I_p = 1.0\\,\\text{A}$। গৌণ কুণ্ডলীতে তড়িৎ প্রবাহ $I_s$ নির্ণয় করতে, আমরা পাই: $$I_s = I_p \\times \\frac{N_p}{N_s} = 1.0\\,\\text{A} \\times \\frac{1000}{100} = 1.0\\,\\text{A} \\times 10 = 10\\,\\text{A}$$ সুতরাং, গৌণ কুণ্ডলীতে $10\\,\\text{A}$ তড়িৎ প্রবাহ পাওয়া যাবে।	B
6dff14d7-14d7-4232-9a97-e4b24b18a43c	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	23	দুটি সমান চার্জের মধ্যবর্তী দূরত্ব অর্ধেক করা হলে এবং চার্জ দুটির মান কমিয়ে অর্ধেক করা হলে বলের মান-	physics	static_electricity	C	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	কুলম্বের সূত্রানুযায়ী দুটি চার্জের মধ্যবর্তী বল $F = k \\frac{q_1 q_2}{r^2}$। প্রাথমিকভাবে, চার্জ দুটি $q$ এবং তাদের মধ্যবর্তী দূরত্ব $r$ হলে বল $F_1 = k \\frac{q^2}{r^2}$। নতুন অবস্থায়, চার্জ দুটির মান অর্ধেক করা হয়েছে ($q/2$) এবং দূরত্বও অর্ধেক করা হয়েছে ($r/2$)। সুতরাং, নতুন বল হবে $F_2 = k \\frac{(q/2)(q/2)}{(r/2)^2} = k \\frac{q^2/4}{r^2/4} = k \\frac{q^2}{r^2}$। দেখা যাচ্ছে যে $F_1 = F_2$, অর্থাৎ বলের মান অপরিবর্তিত থাকবে।	C
52ec6e64-8b1a-461b-a878-0c0c035dbbd4	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	05	একটি ধাতুর কার্যঅপেক্ষক $6.63\\,\\text{eV}$। ধাতুটির ক্ষেত্রে ফটোইলেকট্রন নিঃসরণের সূচন কম্পাঙ্ক কত? [প্লাঙ্কের ধ্রুবক $= 6.63 \\times 10^{-34}\\,\\text{J.s.}$]	physics	introduction_to_modern_physics	A	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	ফটোইলেকট্রন নিঃসরণের সূচন কম্পাঙ্ক ($f_0$) এবং কার্যঅপেক্ষক ($W$) এর মধ্যে সম্পর্ক হলো $W = hf_0$, যেখানে $h$ হলো প্লাঙ্কের ধ্রুবক। প্রথমে, কার্যঅপেক্ষককে ইলেকট্রন ভোল্ট (eV) থেকে জুল (J) এ রূপান্তর করতে হবে। আমরা জানি, $1\\,\\text{eV} = 1.6 \\times 10^{-19}\\,\\text{J}$।\nসুতরাং, $W = 6.63\\,\\text{eV} = 6.63 \\times (1.6 \\times 10^{-19})\\,\\text{J}$।\nএখন, সূচন কম্পাঙ্ক নির্ণয় করি:\n$$f_0 = \\frac{W}{h} = \\frac{6.63 \\times 1.6 \\times 10^{-19}\\,\\text{J}}{6.63 \\times 10^{-34}\\,\\text{J.s.}}$$\n$$f_0 = 1.6 \\times \\frac{10^{-19}}{10^{-34}}\\,\\text{Hz} = 1.6 \\times 10^{(-19 - (-34))}\\,\\text{Hz}$$\n$$f_0 = 1.6 \\times 10^{15}\\,\\text{Hz}$$\nএই মানটিকে $16 \\times 10^{14}\\,\\text{Hz}$ হিসাবেও লেখা যায়, যা বিকল্প (A) এর সাথে মিলে যায়।	A
b6da5681-215c-4b93-b5f0-6e8f785b731b	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	01	$12\\,\\text{V}$ তড়িচ্চালক শক্তি এবং $0.1\\,\\Omega$ অভ্যন্তরীণ রোধের একটি ব্যাটারিকে একটি বৈদ্যুতিক মোটরের সঙ্গে সংযুক্ত করলে ব্যাটারির প্রান্তদ্বয়ের বিভব পার্থক্য দাঁড়ায় $7.0\\,\\text{V}$। মোটরে সরবরাহকৃত কারেন্টের মান কত?	physics	current_electricity	A	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	ব্যাটারির তড়িচ্চালক শক্তি ($E$), প্রান্তদ্বয়ের বিভব পার্থক্য ($V$), অভ্যন্তরীণ রোধ ($r$) এবং বর্তনীর কারেন্ট ($I$) এর মধ্যে সম্পর্কটি হলো $V = E - Ir$। এই সমীকরণ থেকে কারেন্ট নির্ণয় করা যায়: $I = \\frac{E - V}{r}$। প্রদত্ত মানগুলো বসিয়ে পাই: $I = \\frac{12\\,\\text{V} - 7.0\\,\\text{V}}{0.1\\,\\Omega} = \\frac{5.0\\,\\text{V}}{0.1\\,\\Omega} = 50\\,\\text{A}$। সুতরাং, মোটরে সরবরাহকৃত কারেন্টের মান $50\\,\\text{A}$।	A
0c357720-5066-4fd6-a7d7-64dde5fcb0c2	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	14	পার্শ্বের চিত্রটি কোন লজিক গেইটের সমতুল্য বর্তনী? \n[IMAGE_1]	physics	semiconductor_and_electronics	A	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "logic_gate_circuit", "box_2d": null, "filename": "p01_q14_01.png", "markdown": null, "page_index": 0, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}]	The given circuit diagram shows two switches, A and B, connected in parallel. This parallel combination is in series with a battery and a bulb. The bulb will light up (output is 1) if current can flow through it. Current will flow if switch A is closed (A=1) OR switch B is closed (B=1) OR both are closed (A=1 and B=1). If both switches A and B are open (A=0 and B=0), no current flows, and the bulb remains off (output is 0). This behavior perfectly matches the truth table of an OR gate, where the output is HIGH if any of the inputs are HIGH.	A
14e7bcbb-c2f7-48bc-aa90-74c03999d9e7	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	13	ভেক্টর $\\vec{A}, \\vec{B}$ ও $\\vec{C}$ এর মান যথাক্রমে $12, 5$ ও $13$ এবং $\\vec{A} + \\vec{B} = \\vec{C}$। $\\vec{A}$ ও $\\vec{B}$ ভেক্টরদ্বয়ের মধ্যবর্তী কোণের মান কত?	physics	vector	A	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	আমরা জানি, দুটি ভেক্টর $\\vec{A}$ ও $\\vec{B}$ এর লব্ধি $\\vec{C} = \\vec{A} + \\vec{B}$ হলে, লব্ধির মান নির্ণয়ের সূত্রটি হলো $C^2 = A^2 + B^2 + 2AB\\cos\\theta$, যেখানে $\\theta$ হলো $\\vec{A}$ ও $\\vec{B}$ ভেক্টরদ্বয়ের মধ্যবর্তী কোণ। প্রদত্ত মানগুলো বসিয়ে পাই: $13^2 = 12^2 + 5^2 + 2(12)(5)\\cos\\theta$. এটি সরল করলে হয় $169 = 144 + 25 + 120\\cos\\theta$, অর্থাৎ $169 = 169 + 120\\cos\\theta$. এখান থেকে আমরা পাই $120\\cos\\theta = 0$, যার অর্থ $\\cos\\theta = 0$. সুতরাং, $\\theta = \\frac{\\pi}{2}\\,\\text{rad}$.	A
011f55e3-6770-4d47-9e46-3b8cd0e83955	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	11	বৃত্তাকার পথে $72\\,\\text{km/h}$ সমদ্রুতিতে চলমান কোনো গাড়ির কেন্দ্রমুখী ত্বরণ $1\\,\\text{m/s}^2$ হলে, বৃত্তাকার পথের ব্যাসার্ধ কত?	physics	newtonian_mechanics	C	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	প্রথমে গাড়ির দ্রুতিকে $\\text{m/s}$ এককে রূপান্তর করতে হবে। $v = 72\\,\\text{km/h} = 72 \\times \\frac{1000}{3600}\\,\\text{m/s} = 20\\,\\text{m/s}$। কেন্দ্রমুখী ত্বরণের সূত্র হলো $a_c = \\frac{v^2}{r}$। এখানে, $a_c = 1\\,\\text{m/s}^2$ এবং $v = 20\\,\\text{m/s}$। বৃত্তাকার পথের ব্যাসার্ধ $r$ নির্ণয়ের জন্য সূত্রটি পুনর্বিন্যাস করলে পাই $r = \\frac{v^2}{a_c}$। মান বসিয়ে পাই $r = \\frac{(20\\,\\text{m/s})^2}{1\\,\\text{m/s}^2} = \\frac{400\\,\\text{m}^2/\\text{s}^2}{1\\,\\text{m/s}^2} = 400\\,\\text{m}$।	C
050c9a2a-afc8-4cf8-84d4-2c22be81abd0	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	07	কোনটি তড়িৎ চুম্বকীয় তরঙ্গ নয়?	physics	physical_optics	D	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	তড়িৎ চুম্বকীয় তরঙ্গ হলো এমন তরঙ্গ যা শূন্যস্থান সহ যেকোনো মাধ্যমে আলোর বেগে সঞ্চালিত হতে পারে এবং এর জন্য কোনো জড় মাধ্যমের প্রয়োজন হয় না। রেডিও তরঙ্গ, মাইক্রো তরঙ্গ এবং এক্স-রে সবই তড়িৎ চুম্বকীয় তরঙ্গের উদাহরণ। অন্যদিকে, আল্ট্রাসাউন্ড হলো এক প্রকার যান্ত্রিক তরঙ্গ (শব্দ তরঙ্গ) যার বিস্তারের জন্য একটি জড় মাধ্যমের প্রয়োজন হয় এবং এটি শূন্যস্থানে সঞ্চালিত হতে পারে না। তাই, আল্ট্রাসাউন্ড তড়িৎ চুম্বকীয় তরঙ্গ নয়।	D
66e563db-29f8-4f21-8537-c0127e5e63cc	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	06	যদি $A = B^n C^m$ এবং $A, B$ ও $C$ এর মাত্রা যথাক্রমে, $[LT], [L^2 T^{-1}]$ এবং $[LT^2]$ হয়, তবে $n$ ও $m$ এর মান হবে-	physics	physical_world_and_measurement	D	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	প্রদত্ত সমীকরণটি হলো $A = B^n C^m$। আমরা উভয় পক্ষের মাত্রা তুলনা করব।\n$A$ এর মাত্রা: $[LT]$\n$B$ এর মাত্রা: $[L^2 T^{-1}]$\n$C$ এর মাত্রা: $[LT^2]$\nসমীকরণে মাত্রা বসিয়ে পাই:\n$[LT] = ([L^2 T^{-1}])^n ([LT^2])^m$\n$[LT] = [L^{2n} T^{-n}] [L^m T^{2m}]$\n$[LT] = [L^{2n+m} T^{-n+2m}]$\nএখন, $L$ এবং $T$ এর ঘাত তুলনা করে দুটি সমীকরণ পাই:\n$2n + m = 1$ (1)\n$-n + 2m = 1$ (2)\nসমীকরণ (1) থেকে, $m = 1 - 2n$। এই মানটি সমীকরণ (2) এ বসিয়ে পাই:\n$-n + 2(1 - 2n) = 1$\n$-n + 2 - 4n = 1$\n$-5n = -1 \therefore n = 1/5$\n$n$ এর মান $m = 1 - 2n$ এ বসিয়ে পাই:\n$m = 1 - 2(1/5) = 1 - 2/5 = 3/5$\nসুতরাং, $n = 1/5$ এবং $m = 3/5$।	D
0bd7afbd-dcc0-410b-bde1-5355b8cb277f	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	12	রুদ্ধতাপীয় প্রক্রিয়ায় কোন ভৌত রাশিটি স্থির থাকে?	physics	thermodynamics	C	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	একটি রুদ্ধতাপীয় প্রক্রিয়া হলো এমন একটি তাপগতিবিদ্যা প্রক্রিয়া যেখানে সিস্টেম এবং পারিপার্শ্বিকের মধ্যে কোনো তাপের আদান-প্রদান হয় না, অর্থাৎ $dQ = 0$। প্রথম সূত্র অনুযায়ী, $dU = dQ - dW$, তাই রুদ্ধতাপীয় প্রক্রিয়ায় $dU = -dW$। এর অর্থ হলো, সিস্টেম কাজ করলে অভ্যন্তরীণ শক্তি কমে এবং সিস্টেমের উপর কাজ করা হলে অভ্যন্তরীণ শক্তি বাড়ে, তাই অভ্যন্তরীণ শক্তি স্থির থাকে না। তাপমাত্রা এবং চাপও রুদ্ধতাপীয় প্রক্রিয়ায় পরিবর্তিত হয়। একটি প্রত্যাবর্তী রুদ্ধতাপীয় প্রক্রিয়ায়, এনট্রপির পরিবর্তন $dS = \\frac{dQ}{T}$। যেহেতু $dQ = 0$, তাই $dS = 0$, যার অর্থ এনট্রপি স্থির থাকে। এই ধরনের প্রক্রিয়াকে আইসেন্ট্রপিক প্রক্রিয়াও বলা হয়।	C
73b59855-deaa-4f41-9913-5a53a9111826	e1714ea9-0d01-4643-a7e5-d57e77196296	08	একটি বস্তু $\\pi\\,\\text{m}$ ব্যাসার্ধের বৃত্তাকার পথে $4.0\\,\\text{m/s}$ সমদ্রুতিতে ঘুরছে। একবার ঘুরে আসতে বস্তুটির কত সময় লাগবে?	physics	dynamics	B	\N	generated	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	একটি বস্তু বৃত্তাকার পথে সমদ্রুতিতে ঘুরলে, তার দ্রুতি $v$, ব্যাসার্ধ $r$ এবং পর্যায়কাল $T$ এর মধ্যে সম্পর্ক হলো $v = \\frac{2\\pi r}{T}$। এই সূত্র থেকে পর্যায়কাল $T$ নির্ণয় করা যায়: $T = \\frac{2\\pi r}{v}$। প্রদত্ত মানগুলো বসিয়ে পাই, $r = \\pi\\,\\text{m}$ এবং $v = 4.0\\,\\text{m/s}$। সুতরাং, $T = \\frac{2\\pi (\\pi\\,\\text{m})}{4.0\\,\\text{m/s}} = \\frac{2\\pi^2}{4.0}\\,\\text{s} = \\frac{\\pi^2}{2}\\,\\text{s}$।	B
cb3208dc-39aa-44b3-8625-60ee6507cbf3	e1714ea9-0d01-4643-a7e5-d57e77196296	09	একটি গাড়ি স্থির অবস্থা ($P$ বিন্দু) হতে সোজা রাস্তায় যাত্রা শুরু করল। কিছু সময় পরে গাড়িটি মন্দনের ফলে থেমে গেল এবং একই ভাবে (প্রথম গতি বাড়িয়ে এবং পরে গতি কমিয়ে) আবার যাত্রা শুরু করে $P$ বিন্দুতে ফিরে আসলো। নিচের কোন লেখচিত্রটি গাড়ির গতিকে প্রকাশ করে?	physics	dynamics	D	\N	generated	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p01_q09_01.png", "markdown": null, "page_index": 0, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}, {"id": "IMAGE_2", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p01_q09_02.png", "markdown": null, "page_index": 0, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}, {"id": "IMAGE_3", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p01_q09_03.png", "markdown": null, "page_index": 0, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}, {"id": "IMAGE_4", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p01_q09_04.png", "markdown": null, "page_index": 0, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}]	গাড়িটি $P$ বিন্দু ($x=0$) থেকে স্থির অবস্থা থেকে যাত্রা শুরু করে, তাই সরণ-সময় ($x-t$) গ্রাফের শুরুতে ঢাল বা বেগ $v = \\frac{dx}{dt} = 0$ হবে। গাড়িটি প্রথমে গতি বাড়িয়ে (ত্বরণ) এবং পরে গতি কমিয়ে (মন্দন) থেমে যায়, যার ফলে গ্রাফটি একটি বক্ররেখা হিসেবে সর্বোচ্চ সরণে পৌঁছায় যেখানে ঢাল পুনরায় শূন্য হয়। এরপর একইভাবে বিপরীত দিকে ফিরে আসার সময় সরণ হ্রাস পেয়ে পুনরায় শূন্যে ($P$ বিন্দুতে) ফিরে আসে। যেহেতু গতির প্রতিটি পর্যায়ে বেগ পরিবর্তিত হয়, তাই গ্রাফটি সরলরৈখিক না হয়ে বক্রাকার হবে। চিত্র (D) এই নিরবচ্ছিন্ন সরণ-সময় সম্পর্ককে সঠিকভাবে প্রদর্শন করে যেখানে গাড়িটি যাত্রা শুরু করে পুনরায় $P$ বিন্দুতে ফিরে আসে।	D
ecfc3df5-ed6a-44f4-9485-2c29f731aa0b	05a449d9-5db0-488f-936f-ab50cc72299e	10.	একটি রাবার ব্যান্ডকে টেনে এর দৈর্ঘ্য $x$ পরিমাণ বৃদ্ধি করলে, রাবার ব্যান্ডে সৃষ্ট প্রত্যয়নী বল হলো $F = ax + bx^2$ (এখানে $a$ এবং $b$ ধ্রুবক)। রাবার ব্যান্ডটিকে $x = 0$ থেকে $x = L$ পর্যন্ত বৃদ্ধি করতে কৃত কাজের মান কত?	physics	work_energy_and_power	D	\N	generated	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	রাবার ব্যান্ডকে $x$ পরিমাণ বৃদ্ধি করতে প্রত্যয়নী বল $F = ax + bx^2$। $x = 0$ থেকে $x = L$ পর্যন্ত বৃদ্ধি করতে কৃত কাজ হলো বলের সরণ সাপেক্ষে সমাকলন।\n$$W = \\int_{0}^{L} F \\,dx$$\n$$W = \\int_{0}^{L} (ax + bx^2) \\,dx$$\n$$W = a \\left[ \\frac{x^2}{2} \\right]_{0}^{L} + b \\left[ \\frac{x^3}{3} \\right]_{0}^{L}$$\n$$W = a \\left( \\frac{L^2}{2} - 0 \\right) + b \\left( \\frac{L^3}{3} - 0 \\right)$$\n$$W = \\frac{aL^2}{2} + \\frac{bL^3}{3}$$\nসুতরাং, কৃত কাজের মান হলো $\\frac{aL^2}{2} + \\frac{bL^3}{3}$।	D
52130c99-6ddd-4199-99fc-1a9ced88011c	05a449d9-5db0-488f-936f-ab50cc72299e	06	$m$ ভরের একটি বস্তু একটি অনুভূমিক স্প্রিং-এর সাথে সংযুক্ত আছে, স্প্রিংটি $A$ পরিমাণ প্রসারিত করে ছেড়ে দেওয়া হলে এটি $T$ পর্যায়কাল নিয়ে ঘর্ষণবিহীন তলে স্পন্দিত হতে থাকল। যদি বস্তুর ভর $4m$ করা হয় তবে নতুন পর্যায়কাল কত হবে?	physics	periodic_motion	A	\N	generated	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	একটি অনুভূমিক স্প্রিং-এর সাথে সংযুক্ত $m$ ভরের বস্তুর পর্যায়কাল $T$ এর সূত্র হলো $T = 2\\pi\\sqrt{\\frac{m}{k}}$, যেখানে $k$ হলো স্প্রিং ধ্রুবক। যখন বস্তুর ভর $4m$ করা হয়, তখন নতুন পর্যায়কাল $T'$ হবে $T' = 2\\pi\\sqrt{\\frac{4m}{k}}$। এই সমীকরণটিকে এভাবে লেখা যায় $T' = 2\\pi\\sqrt{4 \\times \\frac{m}{k}} = 2\\pi \\times 2 \\times \\sqrt{\\frac{m}{k}}$। যেহেতু $T = 2\\pi\\sqrt{\\frac{m}{k}}$, আমরা পাই $T' = 2T$। সুতরাং, নতুন পর্যায়কাল হবে $2T$।	A
98f61b5a-bb45-4b43-b6ac-d150779b2711	05a449d9-5db0-488f-936f-ab50cc72299e	04	একটি বস্তুকণার মোট শক্তি এর স্থির ভর শক্তির দ্বিগুণ। আলোর দ্রুতি $c$ হলে, কণাটির দ্রুতি কত?	physics	introduction_to_modern_physics	B	\N	generated	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	আপেক্ষিকতা তত্ত্ব অনুযায়ী, একটি বস্তুকণার মোট শক্তি $E = \\frac{mc^2}{\\sqrt{1 - v^2/c^2}}$ এবং স্থির ভর শক্তি $E_0 = mc^2$, যেখানে $m$ হলো কণার স্থির ভর, $v$ হলো কণার দ্রুতি এবং $c$ হলো আলোর দ্রুতি। প্রশ্নানুসারে, মোট শক্তি স্থির ভর শক্তির দ্বিগুণ, অর্থাৎ $E = 2E_0$।\nমান বসিয়ে পাই:\n$$\\frac{mc^2}{\\sqrt{1 - v^2/c^2}} = 2mc^2$$\nউভয় পক্ষ থেকে $mc^2$ বাদ দিলে:\n$$\\frac{1}{\\sqrt{1 - v^2/c^2}} = 2$$\nউভয় পক্ষকে বর্গ করে পাই:\n$$\\frac{1}{1 - v^2/c^2} = 4$$\nপুনর্বিন্যাস করে পাই:\n$$1 - \\frac{v^2}{c^2} = \\frac{1}{4}$$\n$$\\frac{v^2}{c^2} = 1 - \\frac{1}{4} = \\frac{3}{4}$$\nউভয় পক্ষে বর্গমূল করে পাই:\n$$\\frac{v}{c} = \\sqrt{\\frac{3}{4}} = \\frac{\\sqrt{3}}{2}$$\nসুতরাং, কণাটির দ্রুতি $v = \\frac{\\sqrt{3}}{2}c$।	B
49fe07e4-d291-4f8f-b4f9-0fc162ad8553	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	10	দুটি সুসংগত উৎস থেকে $\\lambda$ দৈর্ঘ্যের দুটি তরঙ্গ সমদশায় বের হয়। একটি বিন্দুতে যেখানে তরঙ্গ দুটি মিলিত হয় সেখানে তাদের দশা পার্থক্য $90^\\circ$। তরঙ্গ দুটির অতিক্রান্ত পথ পার্থক্য তখন কত?	physics	physical_optics	D	\N	generated	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	দুটি তরঙ্গের দশা পার্থক্য ($\\Delta\\phi$) এবং পথ পার্থক্য ($\\Delta x$) এর মধ্যে সম্পর্কটি হলো $\\Delta\\phi = \\frac{2\\pi}{\\lambda} \\Delta x$, যেখানে $\\lambda$ হলো তরঙ্গদৈর্ঘ্য। প্রশ্নে দেওয়া আছে দশা পার্থক্য $\\Delta\\phi = 90^\\circ = \\frac{\\pi}{2}$ রেডিয়ান। এখন, পথ পার্থক্য নির্ণয়ের জন্য সূত্রটি পুনর্বিন্যাস করি: $\\Delta x = \\frac{\\lambda}{2\\pi} \\Delta\\phi$। মান বসিয়ে পাই: $\\Delta x = \\frac{\\lambda}{2\\pi} \\left( \\frac{\\pi}{2} \\right) = \\frac{\\lambda}{4}$।	D
cda0ca18-8820-4020-ad75-1a93511536b3	b0c3348a-46af-4e00-a298-7006c2a9785f	01.	দুইটি ভেক্টর $\\vec{A}$ এবং $\\vec{B}$-এর যোগফল তাদের পার্থক্যের ওপর লম্ব। নিচের কোন বিবৃতিটি অবশ্যই সত্য?	physics	vector	A	\N	generated	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	ধরি, দুইটি ভেক্টর $\\vec{A}$ এবং $\\vec{B}$। তাদের যোগফল $\\vec{S} = \\vec{A} + \\vec{B}$ এবং তাদের পার্থক্য $\\vec{D} = \\vec{A} - \\vec{B}$। প্রশ্নানুসারে, যোগফল এবং পার্থক্য পরস্পর লম্ব, অর্থাৎ তাদের ডট গুণফল শূন্য হবে: $$\\vec{S} \\cdot \\vec{D} = 0$$ $$(\\vec{A} + \\vec{B}) \\cdot (\\vec{A} - \\vec{B}) = 0$$ ডট গুণফল সম্প্রসারণ করে পাই: $$\\vec{A} \\cdot \\vec{A} - \\vec{A} \\cdot \\vec{B} + \\vec{B} \\cdot \\vec{A} - \\vec{B} \\cdot \\vec{B} = 0$$ যেহেতু $\\vec{A} \\cdot \\vec{A} = |\\vec{A}|^2$, $\\vec{B} \\cdot \\vec{B} = |\\vec{B}|^2$ এবং $\\vec{A} \\cdot \\vec{B} = \\vec{B} \\cdot \\vec{A}$, সমীকরণটি দাঁড়ায়: $$|\\vec{A}|^2 - |\\vec{B}|^2 = 0$$ $$|\\vec{A}|^2 = |\\vec{B}|^2$$ যেহেতু ভেক্টরের মান সর্বদা অঋণাত্মক, উভয় পাশে বর্গমূল করে পাই: $$|\\vec{A}| = |\\vec{B}|$$ সুতরাং, ভেক্টর দুইটির মান অবশ্যই সমান হবে।	A
448025f6-abe6-42fa-8866-014b842f7785	b0c3348a-46af-4e00-a298-7006c2a9785f	06.	একটি কণা $A$ বিস্তারে সরল ছন্দিত স্পন্দনে স্পন্দিত হচ্ছে। সাম্যাবস্থা থেকে কত দূরত্বে কণাটির বিভব শক্তি তার মোট শক্তির এক-চতুর্থাংশ হয়?	physics	periodic_motion	B	\N	generated	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	একটি সরল ছন্দিত স্পন্দনে স্পন্দিত কণার বিভব শক্তি ($PE$) এবং মোট শক্তি ($TE$) এর সূত্র হলো যথাক্রমে $PE = \\frac{1}{2} m \\omega^2 x^2$ এবং $TE = \\frac{1}{2} m \\omega^2 A^2$, যেখানে $m$ ভর, $\\omega$ কৌণিক কম্পাঙ্ক, $x$ সাম্যাবস্থা থেকে সরণ এবং $A$ বিস্তার। প্রশ্নানুযায়ী, বিভব শক্তি মোট শক্তির এক-চতুর্থাংশ, অর্থাৎ $PE = \\frac{1}{4} TE$। মান বসিয়ে পাই: $\\frac{1}{2} m \\omega^2 x^2 = \\frac{1}{4} \\left( \\frac{1}{2} m \\omega^2 A^2 \\right)$। উভয় পক্ষ থেকে $\\frac{1}{2} m \\omega^2$ বাদ দিলে পাই $x^2 = \\frac{1}{4} A^2$। বর্গমূল করে পাই $x = \\frac{A}{2}$।	B
d9ca492d-8ac0-487a-8a2e-0644d67689e2	b0c3348a-46af-4e00-a298-7006c2a9785f	07.	নিচের কোনটি পোলারাইজার নয়?	physics	physical_optics	B	\N	generated	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	পোলারাইজার হলো এমন একটি যন্ত্র যা অপোলারাইজড আলোকে পোলারাইজড আলোতে রূপান্তরিত করে। ট্যুরমালিন ক্রিস্টাল, ক্যালসাইট ক্রিস্টাল এবং নিকল প্রিজম (যা ক্যালসাইট দিয়ে তৈরি) সবই পোলারাইজার হিসেবে কাজ করে। অন্যদিকে, ফ্রেসনেলের বাইপ্রিজম হলো একটি অপটিক্যাল যন্ত্র যা আলোর ব্যতিচার (interference) প্রদর্শনের জন্য দুটি সুসংগত উৎস তৈরি করতে ব্যবহৃত হয়, এটি আলোকে পোলারাইজ করে না। সুতরাং, ফ্রেসনেলের বাইপ্রিজম পোলারাইজার নয়।	B
6d111269-ad5b-401e-a1b2-4819ba463ee6	b0c3348a-46af-4e00-a298-7006c2a9785f	08.	STP-তে একটি আদর্শ গ্যাসকে প্রথমে তার প্রাথমিক আয়তনের এক-তৃতীয়াংশে সংকুচিত করা হয়, এবং তারপর প্রসারিত হতে দেওয়া হয় যতক্ষণ না তার চাপ প্রাথমিক চাপের অর্ধেক হয়। উভয় প্রক্রিয়ায় গ্যাসের তাপমাত্রা স্থির থাকে। যদি গ্যাসের প্রাথমিক অভ্যন্তরীণ শক্তি $U$ হয়ে থাকে তাহলে এর চূড়ান্ত অভ্যন্তরীণ শক্তি কত?	physics	thermodynamics	C	\N	generated	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	একটি আদর্শ গ্যাসের অভ্যন্তরীণ শক্তি ($U$) শুধুমাত্র তার তাপমাত্রার ($T$) উপর নির্ভরশীল। প্রশ্নানুযায়ী, গ্যাসটি দুটি প্রক্রিয়ার মধ্য দিয়ে যায়, কিন্তু উভয় প্রক্রিয়ায় গ্যাসের তাপমাত্রা স্থির থাকে। যেহেতু তাপমাত্রা স্থির থাকে, তাই আদর্শ গ্যাসের অভ্যন্তরীণ শক্তির কোনো পরিবর্তন হবে না। যদি প্রাথমিক অভ্যন্তরীণ শক্তি $U$ হয়, তাহলে চূড়ান্ত অভ্যন্তরীণ শক্তিও $U$ হবে।	C
78416331-8465-4bc7-8067-af60abc59577	55086422-ef06-4659-a0be-10579b6abde5	18	একটি আলোক রশ্মি চিত্রে প্রদর্শিত তিনটি মাধ্যম দিয়ে অতিক্রম করছে। বেগগুলোর কোন ক্রমটি সঠিক? [IMAGE_1]	physics	geometrical_optics	A	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "diagram", "box_2d": null, "filename": "p02_q18_01.png", "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": "token/file count mismatch on page 2: 6 tokens vs 5 files", "extraction_status": "needs_review"}]	আলোর প্রতিসরণের সূত্রানুযায়ী, যখন আলোকরশ্মি একটি মাধ্যম থেকে অন্য মাধ্যমে প্রবেশ করে এবং অভিলম্বের দিকে বেঁকে যায়, তখন দ্বিতীয় মাধ্যমটি প্রথম মাধ্যম অপেক্ষা ঘন হয় এবং আলোকের বেগ কমে যায়। এর বিপরীতভাবে, যখন আলোকরশ্মি অভিলম্ব থেকে দূরে সরে যায়, তখন দ্বিতীয় মাধ্যমটি প্রথম মাধ্যম অপেক্ষা হালকা হয় এবং আলোকের বেগ বেড়ে যায়।\n\nচিত্র থেকে দেখা যায়:\n১. প্রথম মাধ্যম ($v_1$) থেকে দ্বিতীয় মাধ্যমে ($v_2$) আলোকরশ্মি অভিলম্বের দিকে বেঁকেছে। এর অর্থ হলো, দ্বিতীয় মাধ্যমটি প্রথম মাধ্যম অপেক্ষা ঘন। সুতরাং, $v_1 > v_2$।\n২. দ্বিতীয় মাধ্যম ($v_2$) থেকে তৃতীয় মাধ্যমে ($v_3$) আলোকরশ্মি অভিলম্ব থেকে দূরে সরে গেছে। এর অর্থ হলো, তৃতীয় মাধ্যমটি দ্বিতীয় মাধ্যম অপেক্ষা হালকা। সুতরাং, $v_3 > v_2$।\n৩. প্রথম মাধ্যমে আপতন কোণ ($i_1$) এবং তৃতীয় মাধ্যমে প্রতিসরণ কোণ ($r_2$) তুলনা করলে দেখা যায় যে, $r_2 > i_1$। স্নেলের সূত্রানুযায়ী, $\\frac{\\sin i_1}{v_1} = \\frac{\\sin r_2}{v_3}$। যেহেতু $r_2 > i_1$, তাই $\\sin r_2 > \\sin i_1$। এর ফলে, $v_3 > v_1$।\n\nউপরিউক্ত তিনটি সম্পর্ক একত্রিত করলে পাই: $v_3 > v_1 > v_2$।	A
fa4ff435-2391-4047-b44c-f685d53e9f55	55086422-ef06-4659-a0be-10579b6abde5	13	দুটি সমমানের ভেক্টর একটি বিন্দুতে ক্রিয়াশীল। এদের লব্ধির মান যেকোনো একটি ভেক্টরের মানের সমান। ভেক্টর দুটির মধ্যবর্তী কোণের মান কত?	physics	vector	C	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	ধরি, দুটি সমমানের ভেক্টর $P_1$ এবং $P_2$, যেখানে $|P_1| = |P_2| = P$। এদের লব্ধি ভেক্টর $R$ এর মানও যেকোনো একটি ভেক্টরের মানের সমান, অর্থাৎ $|R| = P$। দুটি ভেক্টরের মধ্যবর্তী কোণ $\\theta$ হলে, লব্ধির মানের সূত্রটি হলো: $R^2 = P_1^2 + P_2^2 + 2P_1P_2\\cos\\theta$। প্রদত্ত মানগুলো বসিয়ে পাই: $P^2 = P^2 + P^2 + 2(P)(P)\\cos\\theta$। এটিকে সরল করলে পাই: $P^2 = 2P^2 + 2P^2\\cos\\theta \\implies -P^2 = 2P^2\\cos\\theta \\implies \\cos\\theta = -\\frac{1}{2}$। সুতরাং, $\\theta = \\arccos\\left(-\\frac{1}{2}\\right) = 120^\\circ$।	C
ca52fa50-abaa-4fd0-bb0d-ae75039e1cbb	55086422-ef06-4659-a0be-10579b6abde5	23	$e$ মানের একটি চার্জ, $r$ ব্যাসার্ধের একটি বৃত্তাকার পথে $v$ দ্রুতিতে ঘুরছে। বৃত্তের কেন্দ্রে চৌম্বকক্ষেত্রের মান হবে-	physics	magnetic_effects_of_electric_current_and_magnetism	A	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	একটি $e$ চার্জ $r$ ব্যাসার্ধের বৃত্তাকার পথে $v$ দ্রুতিতে ঘুরলে, এর পর্যায়কাল হবে $T = \\frac{2\\pi r}{v}$. এই ঘূর্ণন একটি তড়িৎ প্রবাহের সমতুল্য, যার মান $I = \\frac{e}{T} = \\frac{e}{2\\pi r / v} = \\frac{ev}{2\\pi r}$. একটি বৃত্তাকার কুণ্ডলীর কেন্দ্রে চৌম্বকক্ষেত্রের মান $B = \\frac{\\mu_0 I}{2r}$ সূত্র দ্বারা নির্ণয় করা হয়। এখানে $I$-এর মান প্রতিস্থাপন করে পাই: $B = \\frac{\\mu_0}{2r} \\left( \\frac{ev}{2\\pi r} \\right) = \\frac{\\mu_0 ev}{4\\pi r^2}$.	A
d3ccca49-10b5-4f46-ac64-eb70abeb097a	55086422-ef06-4659-a0be-10579b6abde5	09.	কৌণিক ভরবেগের একক কোনটি?	physics	newtonian_mechanics	A	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	কৌণিক ভরবেগ ($L$) হলো জড়তার ভ্রামক ($I$) এবং কৌণিক বেগ ($\\omega$) এর গুণফল, অর্থাৎ $L = I\\omega$। জড়তার ভ্রামকের একক হলো $\\text{kg m}^2$ এবং কৌণিক বেগের একক হলো $\\text{s}^{-1}$ (রেডিয়ান মাত্রাহীন)। সুতরাং, কৌণিক ভরবেগের একক হবে $\\text{kg m}^2 \\times \\text{s}^{-1} = \\text{kg m}^2\\text{s}^{-1}$। বিকল্পভাবে, কৌণিক ভরবেগ হলো রৈখিক ভরবেগ ($p$) এবং ঘূর্ণন ব্যাসার্ধ ($r$) এর গুণফল, $L = rp$। রৈখিক ভরবেগের একক $\\text{kg m s}^{-1}$ এবং ঘূর্ণন ব্যাসার্ধের একক $\\text{m}$। তাই, $L$ এর একক হবে $\\text{m} \\times \\text{kg m s}^{-1} = \\text{kg m}^2\\text{s}^{-1}$।	A
0e7b1d5f-a655-4b21-a3e9-37c113cfc52e	55086422-ef06-4659-a0be-10579b6abde5	04.	একটি অতি সুসঙ্গত আলোক রশ্মি একটি সূক্ষ্ম তারের উপর আপতিত হলে তারের পিছনে যে ছায়া তৈরি হয় তা একটি তারের নয়, বরং অনেকগুলো সমান্তরাল তারের। এই ঘটনাটি ব্যাখ্যা করা যায় নিম্নের কোনটির দ্বারা?	physics	physical_optics	B	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	যখন একটি সুসঙ্গত আলোক রশ্মি একটি সূক্ষ্ম তারের উপর আপতিত হয়, তখন আলো তারের ধার বরাবর বেঁকে যায়। এই ঘটনাকে অপবর্তন (diffraction) বলে। অপবর্তিত আলোক তরঙ্গগুলো একে অপরের সাথে উপরিপাতিত হয়ে ব্যতিচার (interference) সৃষ্টি করে। এর ফলে তারের পিছনে একটি একক ছায়ার পরিবর্তে উজ্জ্বল ও অন্ধকার পটির একটি প্যাটার্ন তৈরি হয়, যা দেখে মনে হয় যেন অনেকগুলো সমান্তরাল তারের ছায়া।	B
49ac5214-08aa-4093-9790-8e3402278800	55086422-ef06-4659-a0be-10579b6abde5	01.	একটি তাপীয় ইঞ্জিন প্রতিটি চক্রে ধনাত্মক কাজ করে এবং তাপ হারায় কিন্তু ইঞ্জিনটি কোনো তাপ গ্রহণ করে না। ইঞ্জিনটি তাপগতিবিদ্যার কোন সূত্রকে লঙ্ঘন করে?	physics	thermodynamics	B	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	তাপগতিবিদ্যার প্রথম সূত্র অনুসারে, একটি চক্রীয় প্রক্রিয়ায় সিস্টেমের অভ্যন্তরীণ শক্তির কোনো পরিবর্তন হয় না ($\\Delta U = 0$)। তাই, মোট গৃহীত তাপ ($Q$) মোট কৃতকাজের ($W$) সমান হয়, অর্থাৎ $Q = W$। প্রশ্ন অনুযায়ী, ইঞ্জিনটি কোনো তাপ গ্রহণ করে না ($Q_{in} = 0$) এবং তাপ হারায় ($Q_{out} > 0$)। সুতরাং, মোট তাপ $Q = Q_{in} - Q_{out} = 0 - Q_{out} = -Q_{out}$। যেহেতু $Q_{out} > 0$, তাই $Q < 0$। কিন্তু ইঞ্জিনটি ধনাত্মক কাজ করে ($W > 0$)। এটি তাপগতিবিদ্যার প্রথম সূত্র ($Q = W$) এর সাথে সাংঘর্ষিক, কারণ একটি ঋণাত্মক তাপ একটি ধনাত্মক কাজের সমান হতে পারে না।	B
5679a8f3-dad5-48c3-8057-6caa1fbd2683	05a449d9-5db0-488f-936f-ab50cc72299e	07	একটি সুতার একপ্রান্তে একটি বস্তুকে বেঁধে উলম্বভাবে বৃত্তাকার পথে ঘুরানো হচ্ছে। বৃত্তের সর্বোচ্চ বিন্দুতে বস্তুটির বেগ $\\sqrt{3gr}$ ($r = \\text{বৃত্তের ব্যাসার্ধ এবং } g \\text{ অভিকর্ষজ ত্বরণ}$) হলে, বৃত্তের সর্বোচ্চ এবং সর্বনিম্ন বিন্দুতে সুতার টানের অনুপাত কত হবে?	physics	work_energy_and_power	C	\N	generated	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	উলম্ব বৃত্তাকার পথে সর্বোচ্চ বিন্দুতে সুতার টান $T_{top} = \\frac{mv_{top}^2}{r} - mg$। দেওয়া আছে $v_{top} = \\sqrt{3gr}$, তাই $T_{top} = \\frac{m(3gr)}{r} - mg = 2mg$। শক্তির সংরক্ষণশীলতা নীতি অনুযায়ী সর্বনিম্ন বিন্দুতে বেগের বর্গ $v_{bottom}^2 = v_{top}^2 + 2g(2r) = 3gr + 4gr = 7gr$। সর্বনিম্ন বিন্দুতে টান $T_{bottom} = \\frac{mv_{bottom}^2}{r} + mg = \\frac{m(7gr)}{r} + mg = 8mg$। সুতরাং, সর্বোচ্চ ও সর্বনিম্ন বিন্দুতে টানের অনুপাত $T_{top} : T_{bottom} = 2mg : 8mg = 1 : 4$।	C
f606aac2-ea93-4afb-894f-6c4fa67e6b05	05a449d9-5db0-488f-936f-ab50cc72299e	14.	একটি রান্নাঘরের দেয়াল, সিলিং এবং মেঝে তাপীয় অন্তরক পদার্থ দিয়ে তৈরি। রান্নাঘরে একটি সাধারণ রেফ্রিজারেটরের দরজা খুলে তা চালু রাখা হলে রান্নাঘরের তাপমাত্রা-	physics	thermodynamics	C	\N	generated	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	একটি রেফ্রিজারেটর যখন চলে, তখন এটি বৈদ্যুতিক কাজ $W$ সম্পন্ন করে এবং তাপ বর্জন করে। তাপগতিবিদ্যার প্রথম সূত্রানুসারে, বর্জিত তাপ $Q_H = Q_L + W$, যেখানে $Q_L$ হলো রেফ্রিজারেটরের ভেতর থেকে শোষিত তাপ। যেহেতু দরজা খোলা, তাই $Q_L$ এবং $Q_H$ উভয়ই একই ঘরের অংশ। ফলে ঘরে নিট তাপের পরিমাণ $Q_{net} = Q_H - Q_L = W$ বৃদ্ধি পায়। যেহেতু ঘরটি তাপীয়ভাবে অন্তরক, তাই এই অতিরিক্ত বৈদ্যুতিক শক্তির তাপে রূপান্তরের কারণে ঘরের তাপমাত্রা বাড়বে।	C
d8122c72-6c11-4278-835b-9d1e6df1a3c8	05a449d9-5db0-488f-936f-ab50cc72299e	08	একটি $3$ মানের ভেক্টরকে একটি $4$ মানের ভেক্টরের সাথে যোগ করলে লব্ধি ভেক্টরের মান নিচের কোনটি হবে না?	physics	vector	A	\N	generated	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	দুটি ভেক্টরের লব্ধির মান তাদের বিয়োগফলের সমান বা তার চেয়ে বড় এবং তাদের যোগফলের সমান বা তার চেয়ে ছোট হয়। এখানে ভেক্টর দুটির মান $P = 3$ এবং $Q = 4$। লব্ধির সর্বনিম্ন মান $R_{\\text{min}} = |P - Q| = |3 - 4| = 1$ এবং সর্বোচ্চ মান $R_{\\text{max}} = P + Q = 3 + 4 = 7$। সুতরাং লব্ধি ভেক্টরের মান $1 \\le R \\le 7$ সীমার মধ্যে থাকবে। যেহেতু $0$ এই সীমার বাইরে, তাই লব্ধির মান $0$ হওয়া সম্ভব নয়।	A
3685e2c6-f04d-478e-87ed-12d8cc72939c	e1714ea9-0d01-4643-a7e5-d57e77196296	05	ব্যতিচারের ক্ষেত্রে উজ্জ্বল বা গঠনমূলক ঝালরের শর্ত কোনটি?	physics	physical_optics	B	\N	generated	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	ব্যতিচারের ক্ষেত্রে গঠনমূলক বা উজ্জ্বল ঝালর সৃষ্টির জন্য পথপার্থক্য তরঙ্গদৈর্ঘ্যের ($\\lambda$) পূর্ণ গুণিতক হতে হবে। গাণিতিকভাবে, পথপার্থক্য $\\Delta x = n\\lambda$, যেখানে $n = 0, 1, 2, \\dots$। যদি চিরদ্বয়ের মধ্যবর্তী দূরত্ব $a$ এবং ব্যতিচার কোণ $\\theta$ হয়, তবে পথপার্থক্য $a \\sin \\theta = n\\lambda$। সুতরাং, উজ্জ্বল ঝালরের জন্য সঠিক শর্তটি হলো $a \\sin \\theta = n\\lambda$।	B
f43d91bf-4188-4d97-8011-e759b608a2e2	e1714ea9-0d01-4643-a7e5-d57e77196296	06	একটি কার্নো ইঞ্জিন $500\\,\\text{K}$ এবং $250\\,\\text{K}$ তাপমাত্রার আধারের মাধ্যমে পরিচালিত হয়। প্রত্যেক চক্রে ইঞ্জিন যদি উৎস থেকে $1\\,\\text{kcal}$ তাপ গ্রহণ করে তাহলে প্রত্যেক চক্রে তাপ গ্রাহকে তাপ বর্জন করার পরিমাণ কত?	physics	thermodynamics	C	\N	generated	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	কার্নো ইঞ্জিনের ক্ষেত্রে আমরা জানি, $\\frac{Q_1}{T_1} = \\frac{Q_2}{T_2}$। এখানে উৎসের তাপমাত্রা $T_1 = 500\\,\\text{K}$, গ্রাহকের তাপমাত্রা $T_2 = 250\\,\\text{K}$ এবং গৃহীত তাপ $Q_1 = 1\\,\\text{kcal} = 1000\\,\\text{cal}$। মানগুলো সমীকরণে বসিয়ে পাই, $Q_2 = Q_1 \\times \\frac{T_2}{T_1} = 1000\\,\\text{cal} \\times \\frac{250\\,\\text{K}}{500\\,\\text{K}} = 500\\,\\text{cal}$। সুতরাং, প্রত্যেক চক্রে তাপ গ্রাহকে বর্জিত তাপের পরিমাণ $500\\,\\text{cal}$।	C
d8273d47-fb02-4186-aac8-9ca5e5541f2e	05a449d9-5db0-488f-936f-ab50cc72299e	05	বৃষ্টির একটি বড় ফোঁটা ভেঙে অনেকগুলো ছোট ফোঁটায় পরিণত হলে, বড় ফোঁটাটির তুলনায় ছোট ফোঁটাগুলোর সমষ্টিগত ক্ষেত্রফল—	physics	structural_properties_of_matter	B	\N	generated	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	বৃষ্টির একটি বড় ফোঁটা ভেঙে অনেকগুলো ছোট ফোঁটায় পরিণত হলে আয়তন অপরিবর্তিত থাকে। যদি বড় ফোঁটার ব্যাসার্ধ $R$ এবং $n$ টি ছোট ফোঁটার প্রতিটির ব্যাসার্ধ $r$ হয়, তবে আয়তন সংরক্ষণের নীতি অনুযায়ী $\\frac{4}{3}\\pi R^3 = n \\cdot \\frac{4}{3}\\pi r^3$, যেখান থেকে পাওয়া যায় $r = R/n^{1/3}$। বড় ফোঁটার ক্ষেত্রফল $A_1 = 4\\pi R^2$ এবং ছোট ফোঁটাগুলোর সমষ্টিগত ক্ষেত্রফল $A_2 = n \\cdot 4\\pi r^2 = n \\cdot 4\\pi (R/n^{1/3})^2 = n^{1/3} \\cdot 4\\pi R^2$। যেহেতু $n > 1$, তাই $A_2 > A_1$, অর্থাৎ সমষ্টিগত ক্ষেত্রফল বৃদ্ধি পাবে।	B
0d6a324b-4f00-466e-9db4-a00dca497c99	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	07	$\\vec{P} = 2\\hat{i} + 2\\hat{j} - \\hat{k}$ এবং $\\vec{Q} = 6\\hat{i} + 3\\hat{j} - 3\\hat{k}$ ভেক্টরদ্বয়ের উভয়ের ওপর লম্ব দিকে একটি একক ভেক্টর কোনটি হবে?	physics	vector	C	\N	generated	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	$\\vec{P}$ এবং $\\vec{Q}$ ভেক্টরদ্বয়ের উভয়ের ওপর লম্ব ভেক্টরটি হলো তাদের ক্রস গুণফল $\\vec{R} = \\vec{P} \\times \\vec{Q}$। এখানে, $\\vec{P} \\times \\vec{Q} = \\hat{i}(2 \\cdot (-3) - (-1) \\cdot 3) - \\hat{j}(2 \\cdot (-3) - (-1) \\cdot 6) + \\hat{k}(2 \\cdot 3 - 2 \\cdot 6) = -3\\hat{i} - 6\\hat{k}$। এই ভেক্টরের মান $|\\vec{R}| = \\sqrt{(-3)^2 + (-6)^2} = \\sqrt{45}$। সুতরাং, লম্ব দিকে একটি একক ভেক্টর $\\hat{n} = \\frac{\\vec{R}}{|\\vec{R}|} = \\frac{-3\\hat{i} - 6\\hat{k}}{\\sqrt{45}} = \\frac{-3(\\hat{i} + 2\\hat{k})}{\\sqrt{45}}$। অতএব সঠিক উত্তরটি হলো (C)।	C
4c87010d-60fd-4686-8d7a-0b11ad5aa2d8	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	11	একটি কার্নো ইঞ্জিন $227^\\circ\\text{C}$ এবং $127^\\circ\\text{C}$ তাপমাত্রার মধ্যে কাজ করে। যদি ইঞ্জিন কর্তৃক কৃত কাজের পরিমাণ $500\\,\\text{J}$ হয়, তবে তাপ গ্রাহকে প্রত্যাখ্যাত তাপের পরিমাণ কত হবে?	physics	thermodynamics	A	\N	generated	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	কার্নো ইঞ্জিনের ক্ষেত্রে আমরা জানি, $\\frac{Q_1}{T_1} = \\frac{Q_2}{T_2}$ এবং $W = Q_1 - Q_2$। এখানে, উৎসের তাপমাত্রা $T_1 = 227 + 273 = 500\\,\\text{K}$ এবং গ্রাহকের তাপমাত্রা $T_2 = 127 + 273 = 400\\,\\text{K}$। কৃত কাজ $W = 500\\,\\text{J}$ হলে, তাপ গ্রাহকে বর্জিত তাপ $Q_2 = \\frac{W \\times T_2}{T_1 - T_2}$। মান বসিয়ে পাই, $Q_2 = \\frac{500 \\times 400}{500 - 400} = \\frac{200000}{100} = 2000\\,\\text{J}$।	A
c44fab2b-eb92-4719-9d96-23dfbfe38b22	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	01	একটি আদর্শ গ্যাসের ক্ষেত্রে $\\frac{C_p}{C_v} = x$ হলে, নিচের কোন সম্পর্কটি ঐ গ্যাসের এক মোলের জন্য সঠিক?	physics	ideal_gas_and_gas_kinetics	B	\N	generated	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	আদর্শ গ্যাসের ক্ষেত্রে মোলার আপেক্ষিক তাপদ্বয়ের মধ্যে সম্পর্ক হলো মেয়ারের সমীকরণ $C_p - C_v = R$। প্রশ্নে দেওয়া আছে, $\\frac{C_p}{C_v} = x$, যেখান থেকে আমরা পাই $C_p = x C_v$। এখন মেয়ারের সমীকরণে $C_p$-এর মান বসিয়ে পাই, $x C_v - C_v = R$। সাধারণ উৎপাদক $C_v$ কমন নিলে সমীকরণটি দাঁড়ায় $C_v(x - 1) = R$। সুতরাং, $C_v = \\frac{R}{x - 1}$।	B
759721fb-6efd-4fa0-873f-994c91fafae6	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	02	নিচের কোনটি $\\epsilon_0 \\mu_0$-এর একক?	physics	static_electricity	D	\N	generated	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	শূন্যস্থানে আলোর বেগ $c$ এবং প্রবেশ্যতা $\\mu_0$ ও ভেদ্যতা $\\epsilon_0$-এর মধ্যে সম্পর্ক হলো $c = \\frac{1}{\\sqrt{\\mu_0 \\epsilon_0}}$। এই সমীকরণ থেকে আমরা পাই $\\mu_0 \\epsilon_0 = \\frac{1}{c^2}$। যেহেতু আলোর বেগের একক $\\text{m s}^{-1}$, তাই $\\mu_0 \\epsilon_0$-এর একক হবে $\\frac{1}{(\\text{m s}^{-1})^2} = \\text{m}^{-2} \\text{s}^2$। সুতরাং সঠিক এককটি হলো $\\text{m}^{-2} \\text{s}^2$।	D
2e1e2c65-8558-43dd-afec-c2d333b2aa14	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	03	$m$ ভরের একটি উপগ্রহ $R$ ব্যাসার্ধের একটি বৃত্তাকার কক্ষপথে $M$ ভরের একটি গ্রহকে প্রদক্ষিণ করে। একটি পূর্ণ ঘূর্ণনের জন্য প্রয়োজনীয় সময় নিচের কোনটির সমানুপাতিক?	physics	gravitation_and_gravity	C	\N	generated	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	কেপলারের তৃতীয় সূত্র অনুযায়ী, কোনো উপগ্রহের আবর্তনকালের বর্গ এর কক্ষপথের ব্যাসার্ধের ঘনফলের সমানুপাতিক, অর্থাৎ $T^2 \\propto R^3$। মহাকর্ষীয় বল ও কেন্দ্রমুখী বলের সমতা থেকে আমরা পাই $\\frac{mv^2}{R} = \\frac{GMm}{R^2}$, যেখান থেকে আবর্তনকাল $T = \\frac{2\\pi R}{v} = \\sqrt{\\frac{4\\pi^2 R^3}{GM}}$ পাওয়া যায়। সমীকরণটি সাজালে পাই $T = \\frac{2\\pi}{\\sqrt{GM}} R^{\\frac{3}{2}}$। সুতরাং, একটি পূর্ণ ঘূর্ণনের জন্য প্রয়োজনীয় সময় $T$, ব্যাসার্ধ $R^{\\frac{3}{2}}$ এর সমানুপাতিক।	C
cf3b2c91-ad6f-4dd1-8e75-00f30732f932	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	05	$q$ মানের পাঁচটি ধনাত্মক চার্জ $r$ ব্যাসার্ধের একটি বৃত্তের পরিধি বরাবর প্রতিসমভাবে সাজানো হলো। বৃত্তের কেন্দ্রে বৈদ্যুতিক ক্ষেত্রের মান কত?	physics	static_electricity	C	\N	generated	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	$q$ মানের পাঁচটি চার্জ $r$ ব্যাসার্ধের বৃত্তের পরিধিতে প্রতিসমভাবে (সুষম পঞ্চভুজের শীর্ষবিন্দুতে) অবস্থিত হলে, বৃত্তের কেন্দ্রে প্রতিটি চার্জের জন্য সৃষ্ট তড়িৎ ক্ষেত্রের মান সমান হবে, অর্থাৎ $E = \\frac{1}{4\\pi\\epsilon_0} \\frac{q}{r^2}$। যেহেতু চার্জগুলো প্রতিসমভাবে বিন্যস্ত, তাই কেন্দ্র থেকে চার্জগুলোর দিকে নির্দেশিত ভেক্টরগুলোর মধ্যবর্তী কোণ হবে $\\frac{360^\\circ}{5} = 72^\\circ$। ভেক্টর যোগফলের নিয়ম অনুযায়ী, কোনো সুষম বহুভুজের কেন্দ্রে সমান মানের চার্জ থাকলে লব্ধি তড়িৎ ক্ষেত্রের মান শূন্য হয়। সুতরাং, বৃত্তের কেন্দ্রে বৈদ্যুতিক ক্ষেত্রের মান হবে $0$।	C
225e280b-313c-45c5-ac01-002865223dfe	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	08	সরল দোল গতিসম্পন্ন একটি বস্তু যখন তার সাম্যাবস্থান থেকে $2\\,\\text{cm}$ দূরে, তখন তার গতিশক্তি স্থিতিশক্তির $3$ গুণ। বস্তুটির দোলনের বিস্তার কত হবে?	physics	periodic_motion	D	\N	generated	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	সরল দোল গতিতে বিভব শক্তি $E_p = \\frac{1}{2}kx^2$ এবং গতিশক্তি $E_k = \\frac{1}{2}k(A^2-x^2)$। শর্তানুসারে, $x = 2\\,\\text{cm}$ অবস্থানে $E_k = 3E_p$, ফলে $\\frac{1}{2}k(A^2-x^2) = 3(\\frac{1}{2}kx^2)$ বা $A^2 - x^2 = 3x^2$। এখান থেকে আমরা পাই $A^2 = 4x^2$ বা $A = 2x$। যেহেতু $x = 2\\,\\text{cm}$, তাই বিস্তার $A = 2 \\times 2\\,\\text{cm} = 4\\,\\text{cm}$।	D
fad7afa2-b0be-4bfd-ad77-992dd800cac6	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	13	নয়টি বেলনাকৃতির তার, যাদের প্রতিটির ব্যাস $d$ ও দৈর্ঘ্য $L$, একত্রে শ্রেণি সজ্জায় সংযুক্ত আছে। সজ্জাটির রোধ যদি একটি $L$ দৈর্ঘ্যের বেলনাকৃতির তারের রোধের সমান হয়, তবে তারটির ব্যাস কত?	physics	current_electricity	C	\N	generated	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	একটি তারের রোধ $R = \\rho \\frac{L}{A} = \\frac{4\\rho L}{\\pi d^2}$। নয়টি তার শ্রেণি সজ্জায় যুক্ত থাকলে মোট রোধ হয় $R_s = 9R = \\frac{36\\rho L}{\\pi d^2}$। প্রশ্নানুসারে, এই রোধ $L$ দৈর্ঘ্যের এবং $D$ ব্যাসের একটি তারের রোধের সমান, অর্থাৎ $R_s = \\frac{4\\rho L}{\\pi D^2}$। সমীকরণটি সমাধান করলে আমরা পাই $\\frac{36\\rho L}{\\pi d^2} = \\frac{4\\rho L}{\\pi D^2}$, যা থেকে $D^2 = \\frac{d^2}{9}$ বা $D = \\frac{d}{3}$ পাওয়া যায়।	C
9b17131f-11a6-4ea3-a6bb-38b56357e858	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	12	একটি XOR লজিক গেট নিম্নলিখিত কোন লজিক গেট/গেটগুলোর সমন্বয়ে গঠিত হতে পারে?	physics	semiconductor_and_electronics	B	\N	generated	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	XOR গেটের বুলিয়ান সমীকরণ হলো $Y = A \\oplus B = A\\bar{B} + \\bar{A}B$। এই সমীকরণটি বিশ্লেষণ করলে দেখা যায় যে, এখানে ইনভারশনের জন্য NOT গেট, যৌক্তিক গুণের জন্য AND গেট এবং যৌক্তিক যোগের জন্য OR গেট প্রয়োজন। অর্থাৎ, মৌলিক গেটগুলোর (AND, OR, NOT) সমন্বয়ে একটি XOR গেট তৈরি করা সম্ভব। সুতরাং, সঠিক উত্তর হলো (B)।	B
b8015bab-db1a-45e5-9320-352d8d698989	b0c3348a-46af-4e00-a298-7006c2a9785f	15	ধর, পৃথিবীর ব্যাস বরাবর একটি সুড়ঙ্গ খনন করা হলো এবং পৃথিবীর পৃষ্ঠ থেকে একটি ক্ষুদ্র বস্তুকে সুড়ঙ্গের মধ্যে ছেড়ে দেওয়া হলো বস্তুটি যখন পৃথিবীর কেন্দ্রে পৌঁছাবে তখন মুক্তিবেগ $v_e$-এর সাপেক্ষে বস্তুটির বেগ কত হবে?	physics	gravitation_and_gravity	C	\N	generated	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	শক্তির সংরক্ষণশীলতা নীতি অনুযায়ী, পৃথিবীর পৃষ্ঠে বস্তুর মোট শক্তি এবং কেন্দ্রে মোট শক্তি সমান হবে। পৃথিবীর পৃষ্ঠে বিভব শক্তি $U_s = -\\frac{GMm}{R}$ এবং কেন্দ্রে বিভব শক্তি $U_c = -\\frac{3GMm}{2R}$। পৃষ্ঠ থেকে স্থির অবস্থায় ছেড়ে দিলে কেন্দ্রে গতিশক্তি হবে $K_c = U_s - U_c = -\\frac{GMm}{R} - (-\\frac{3GMm}{2R}) = \\frac{GMm}{2R}$। সুতরাং, $\\frac{1}{2}mv^2 = \\frac{GMm}{2R}$ বা $v = \\sqrt{\\frac{GM}{R}}$। আমরা জানি মুক্তিবেগ $v_e = \\sqrt{\\frac{2GM}{R}}$, তাই $v = \\frac{1}{\\sqrt{2}} v_e$।	C
fb75ef93-d920-4f94-81ea-1d9ff5b08784	b0c3348a-46af-4e00-a298-7006c2a9785f	03.	$10\\,\\text{g}$-এর একটি ভর ঘর্ষণহীন একটি অনুভূমিক তলের ওপর দিয়ে গিয়ে দেওয়ালের সাথে সংযুক্ত একটি অনুভূমিক স্প্রিংকে $6\\,\\text{m/s}$ বেগে আঘাত করে। যদি স্প্রিংটির স্প্রিং ধ্রুবকের মান $400\\,\\text{N/m}$ হয় তাহলে এটিতে সর্বোচ্চ সংকোচন কত হবে?	physics	work_energy_and_power	C	\N	generated	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	শক্তির সংরক্ষণশীলতা নীতি অনুযায়ী, বস্তুর গতিশক্তি স্প্রিংয়ের বিভব শক্তিতে রূপান্তরিত হবে। অর্থাৎ, $\\frac{1}{2}mv^2 = \\frac{1}{2}kx^2$। এখানে ভর $m = 10\\,\\text{g} = 0.01\\,\\text{kg}$, বেগ $v = 6\\,\\text{m/s}$ এবং স্প্রিং ধ্রুবক $k = 400\\,\\text{N/m}$। সমীকরণটি সমাধান করলে আমরা পাই $x = v\\sqrt{\\frac{m}{k}} = 6\\sqrt{\\frac{0.01}{400}} = 6 \\times \\frac{0.1}{20} = 0.03\\,\\text{m}$। সেন্টিমিটারে প্রকাশ করলে এটি হয় $0.03 \\times 100 = 3\\,\\text{cm}$।	C
1cba308b-e030-438f-bf35-8632f38605e8	55086422-ef06-4659-a0be-10579b6abde5	05.	$10\\,\\text{kg}$ ভরের একটি বস্তুর উপর $2F$ মানের বল প্রয়োগ করার ফলে বস্তুটির ত্বরণ হয় $60\\,\\text{m/s}^2$। $M$ ভরের একটি বস্তুর উপর $5F$ মানের বল প্রয়োগ করার ফলে যদি বস্তুটির ত্বরণ $50\\,\\text{m/s}^2$ হয়, তবে ভর $M$ কত?	physics	newtonian_mechanics	D	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	নিউটনের গতির দ্বিতীয় সূত্র $F = ma$ অনুযায়ী, প্রথম ক্ষেত্রে $2F = 10\\,\\text{kg} \\times 60\\,\\text{m/s}^2 = 600\\,\\text{N}$। এখান থেকে আমরা পাই $F = 300\\,\\text{N}$। দ্বিতীয় ক্ষেত্রে, $5F = M \\times 50\\,\\text{m/s}^2$। এখন $F$-এর মান বসিয়ে পাই, $5 \\times 300 = M \\times 50$, বা $1500 = 50M$। সুতরাং, বস্তুর ভর $M = \\frac{1500}{50} = 30\\,\\text{kg}$।	D
9eb2d84f-c683-46fd-b93a-def8d294ca2b	55086422-ef06-4659-a0be-10579b6abde5	30	গ্রহের গতির ক্ষেত্রে- “একটি নক্ষত্র থেকে গ্রহকে সংযোগকারী সরলরেখা সমান সময়ে সমান ক্ষেত্রফল অতিক্রম করে”- এটি কোন নীতির সরাসরি ফলাফল?	physics	gravitation_and_gravity	C	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	কেপলারের দ্বিতীয় সূত্র বা ক্ষেত্রফলের সূত্র অনুযায়ী, সূর্য ও গ্রহের সংযোগকারী সরলরেখা সমান সময়ে সমান ক্ষেত্রফল অতিক্রম করে। গাণিতিকভাবে, ক্ষেত্রফলীয় বেগ $\\frac{dA}{dt} = \\frac{L}{2m}$, যেখানে $L$ হলো কৌণিক ভরবেগ এবং $m$ হলো গ্রহের ভর। যেহেতু মহাকর্ষ বল একটি কেন্দ্রীয় বল (Central force), তাই গ্রহের ওপর প্রযুক্ত টর্ক শূন্য হয় এবং কৌণিক ভরবেগ $L$ ধ্রুবক থাকে। সুতরাং, ক্ষেত্রফলের এই সূত্রটি সরাসরি কৌণিক ভরবেগের সংরক্ষণ নীতির (Conservation of Angular Momentum) ফলাফল।	C
80f911b3-a969-481c-bb8d-6920cf9cb4c3	55086422-ef06-4659-a0be-10579b6abde5	03.	দুইটি সমান মানের বল $P$ এর সর্বনিম্ন লব্ধির মান কত?	physics	vector	B	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	দুইটি বল $P$ ও $Q$ এর লব্ধির মান সর্বনিম্ন হয় যখন তাদের মধ্যবর্তী কোণ $\\alpha = 180^\\circ$ হয়। লব্ধির সর্বনিম্ন মানের সূত্রটি হলো $R_{\\text{min}} = |P - Q|$। এখানে দুইটি বলের মান সমান অর্থাৎ $P = Q = P$। সুতরাং, সর্বনিম্ন লব্ধি হবে $R_{\\text{min}} = |P - P| = 0$।	B
b7a602a2-e595-4a46-8aca-637cb75a3eee	55086422-ef06-4659-a0be-10579b6abde5	19	একটি চলন্ত ট্রেনকে ব্রেক করে $10$ সেকেন্ড থামিয়ে দেওয়া হলো। ট্রেনটির গড় মন্দন $70\\,\\text{m/sec}^2$ হলে, এর গতিবেগ কত ছিল?	physics	dynamics	C	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	এখানে ট্রেনের শেষ বেগ $v = 0\\,\\text{m/s}$, সময় $t = 10\\,\\text{s}$ এবং গড় মন্দন $a = 70\\,\\text{m/s}^2$। আমরা জানি, গতির সমীকরণ অনুযায়ী $v = u - at$, যেখানে $u$ হলো আদি বেগ। মানগুলো বসিয়ে পাই, $0 = u - (70\\,\\text{m/s}^2 \\times 10\\,\\text{s})$। সুতরাং, আদি বেগ $u = 700\\,\\text{m/s}$।	C
1f2aa538-6e73-48e9-92b0-91ab71dd76aa	55086422-ef06-4659-a0be-10579b6abde5	14	অ্যালুমিনিয়াম পাত থেকে কেটে চিত্রে প্রদর্শিত একটি বলয়াকার অ্যালুমিনিয়াম রিং তৈরি করা হয়েছে। একটি গরম করলে কী ঘটে?   \n[IMAGE_1]	physics	structural_properties_of_matter	C	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "geometry_figure", "box_2d": null, "filename": "p02_q14_01.png", "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": "token/file count mismatch on page 2: 6 tokens vs 5 files", "extraction_status": "needs_review"}]	তাপ প্রয়োগ করলে কঠিন পদার্থের প্রতিটি রৈখিক মাত্রা একই অনুপাতে বৃদ্ধি পায়। একটি ছিদ্রযুক্ত পাতের ক্ষেত্রে, ছিদ্রটি এমনভাবে প্রসারিত হয় যেন সেটি ওই একই উপাদানে পূর্ণ ছিল। ক্ষেত্রফল প্রসারণের সূত্রানুসারে, $\\Delta A = A_0 \\beta \\Delta T$, যেখানে $\\beta$ হলো ক্ষেত্রফল প্রসারণ সহগ। যেহেতু $\\beta$ পুরো পাতের জন্য ধ্রুবক, তাই ছিদ্রের ক্ষেত্রফল বৃদ্ধির অনুপাত ($\\frac{\\Delta A}{A_0}$) অ্যালুমিনিয়ামের অন্য যেকোনো অংশের ক্ষেত্রফল বৃদ্ধির অনুপাতের সমান হবে।	C
1e77e791-b572-49c5-96d7-14115d517329	55086422-ef06-4659-a0be-10579b6abde5	15	ইয়ং-এর দ্বি-চিড় পরীক্ষায় দুইটি তরঙ্গের উপরিপাতনের ফলে একটি বিন্দুতে কালো ডোরা উৎপন্ন হয়। ঐ বিন্দুতে তরঙ্গদ্বয়ের মধ্যে দশা পার্থক্য হলো? [$m = \\text{পূর্ণসংখ্যা}$]	physics	physical_optics	D	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	ইয়ং-এর দ্বি-চিড় পরীক্ষায় ধ্বংসাত্মক ব্যতিচার বা কালো ডোরা সৃষ্টির শর্ত হলো তরঙ্গদ্বয়ের মধ্যে দশা পার্থক্য $\\pi$-এর বিজোড় গুণিতক হতে হবে। গাণিতিকভাবে, দশা পার্থক্য $\\phi = (2m + 1)\\pi$, যেখানে $m = 0, 1, 2, \\dots$ একটি পূর্ণসংখ্যা। এই সমীকরণটিকে বিস্তার করলে আমরা পাই $\\phi = 2\\pi m + \\pi$। সুতরাং, কালো ডোরা উৎপন্ন হওয়ার জন্য দশা পার্থক্য হবে $2\\pi m + \\pi$।	D
f6992e14-6260-4199-8666-6e9366738d82	55086422-ef06-4659-a0be-10579b6abde5	11.	নিম্নের কোনটি রাশির একক $\\mu_0 / \\epsilon_0$ এর এককের সমান?	physics	static_electricity	B	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	আমরা জানি, শূন্যস্থানে তড়িৎচৌম্বকীয় তরঙ্গের বৈশিষ্ট্যমূলক ইমপিডেন্স (characteristic impedance) $Z_0 = \\sqrt{\\frac{\\mu_0}{\\epsilon_0}}$ দ্বারা প্রকাশ করা হয়। এখানে $Z_0$ এর একক হলো ওহম ($\\Omega$), যা রোধের এককের সমান। সমীকরণটিকে বর্গ করলে আমরা পাই, $Z_0^2 = \\frac{\\mu_0}{\\epsilon_0}$। সুতরাং, $\\frac{\\mu_0}{\\epsilon_0}$ এর একক হবে $(\\text{Ohm})^2$ বা $(\\text{রোধ})^2$।	B
603aab63-8553-47a4-a088-d2d1ce0ccd17	55086422-ef06-4659-a0be-10579b6abde5	07.	সরলদোল গতি সম্পন্ন একটি কণার বিস্তার $0.02\\,\\text{m}$ এবং কম্পাঙ্ক $2.5\\,\\text{Hz}$ হলে, এর সর্বোচ্চ দ্রুতি কত হবে?	physics	periodic_motion	D	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	সরলদোল গতি সম্পন্ন কোনো কণার সর্বোচ্চ দ্রুতি $v_{\\text{max}} = \\omega A$ সূত্র দ্বারা নির্ণয় করা হয়, যেখানে $\\omega = 2\\pi f$। এখানে বিস্তার $A = 0.02\\,\\text{m}$ এবং কম্পাঙ্ক $f = 2.5\\,\\text{Hz}$। মানগুলো সমীকরণে বসিয়ে পাই, $v_{\\text{max}} = 2 \\times \\pi \\times 2.5 \\times 0.02 = 0.1\\pi \\approx 0.31416\\,\\text{ms}^{-1}$। সুতরাং, কণাটির সর্বোচ্চ দ্রুতি $0.314\\,\\text{ms}^{-1}$।	D
eab51de4-7348-4b0e-9609-064e88015dea	55086422-ef06-4659-a0be-10579b6abde5	24	উৎস হতে ধ্বনিত শব্দ একজন ব্যক্তি শুনতে পেলো $5\\text{ s}$ পরে, যখন একই শব্দ আরেকজন ব্যক্তি শুনতে পেলো $6\\text{ s}$ পরে। শব্দের বেগ $300\\text{ m/s}$। এই দুই ব্যক্তির মধ্যে সর্বোচ্চ এবং সর্বনিম্ন দূরত্ব কত?	physics	waves	D	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	উৎস থেকে প্রথম ব্যক্তির দূরত্ব $d_1 = v \\times t_1 = 300\\,\\text{m/s} \\times 5\\,\\text{s} = 1500\\,\\text{m} = 1.5\\,\\text{km}$ এবং দ্বিতীয় ব্যক্তির দূরত্ব $d_2 = v \\times t_2 = 300\\,\\text{m/s} \\times 6\\,\\text{s} = 1800\\,\\text{m} = 1.8\\,\\text{km}$। ব্যক্তিদ্বয় উৎসের বিপরীত দিকে সরলরেখায় অবস্থান করলে তাদের মধ্যবর্তী দূরত্ব সর্বোচ্চ হয়, অর্থাৎ $d_{\\text{max}} = d_1 + d_2 = 1.5 + 1.8 = 3.3\\,\\text{km}$। আবার ব্যক্তিদ্বয় উৎসের একই দিকে সরলরেখায় অবস্থান করলে তাদের মধ্যবর্তী দূরত্ব সর্বনিম্ন হয়, অর্থাৎ $d_{\\text{min}} = d_2 - d_1 = 1.8 - 1.5 = 0.3\\,\\text{km}$। সুতরাং সর্বোচ্চ ও সর্বনিম্ন দূরত্ব যথাক্রমে $3.3\\,\\text{km}$ এবং $0.30\\,\\text{km}$।	D
f4dded80-a2f9-4297-8907-775b0136b46a	e1714ea9-0d01-4643-a7e5-d57e77196296	10	$q$ পরিমাণ আধান একটি চৌম্বক ক্ষেত্র $\\vec{B}$ এর সাথে সমান্তরালে $\\vec{v}$ বেগে গতিশীল। উক্ত স্থানে একটি তড়িৎক্ষেত্র $\\vec{E}$ থাকলে আধানের উপর ক্রিয়াশীল বল কত হবে?	physics	magnetic_effects_of_electric_current_and_magnetism	C	\N	generated	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	একটি আধান $q$ এর উপর তড়িৎক্ষেত্র $\\vec{E}$ এবং চৌম্বক ক্ষেত্র $\\vec{B}$ এর উপস্থিতিতে মোট লোরেন্জ বল হলো $\\vec{F} = q(\\vec{E} + \\vec{v} \\times \\vec{B})$। যেহেতু আধানটি চৌম্বক ক্ষেত্রের সমান্তরালে গতিশীল, তাই $\\vec{v}$ এবং $\\vec{B}$ এর মধ্যবর্তী কোণ $0^\\circ$ বা $180^\\circ$। ফলে চৌম্বক বলের মান $F_m = qvB \\sin(0^\\circ) = 0$ হবে, অর্থাৎ $\\vec{v} \\times \\vec{B} = 0$। সুতরাং, আধানটির উপর ক্রিয়াশীল নিট বল হবে শুধুমাত্র তড়িৎ বল, অর্থাৎ $\\vec{F} = q\\vec{E}$।	C
ed6ec807-2624-4a5a-9f90-6aea86d4fa8b	e1714ea9-0d01-4643-a7e5-d57e77196296	13	$10\\,\\text{cm}$ লম্বা ও $0.5\\,\\text{cm}$ ব্যাসার্ধ বিশিষ্ট একটি তামা ও একটি লোহার তারকে জোড়া লাগিয়ে দৈর্ঘ্য $20\\,\\text{cm}$ করা হলো। জোড়া লাগানো তারটিকে বল প্রয়োগ করে লম্বা করা হলো। লোহার ইয়ং-এর গুণাঙ্ক তামার ইয়ং-এর গুণাঙ্কের দুইগুণ হলে লোহার দৈর্ঘ্য বৃদ্ধি ও তামার দৈর্ঘ্য বৃদ্ধির অনুপাত কত?	physics	structural_properties_of_matter	D	\N	generated	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	ইয়ং-এর গুণাঙ্ক $Y = \\frac{FL}{A\\Delta L}$ থেকে আমরা জানি দৈর্ঘ্য বৃদ্ধি $\\Delta L = \\frac{FL}{AY}$। যেহেতু তার দুটিকে শ্রেণিতে যুক্ত করা হয়েছে, তাই উভয়ের ওপর প্রযুক্ত বল $F$ সমান। আবার প্রশ্নে দেওয়া আছে যে উভয় তারের আদি দৈর্ঘ্য $L = 10\\,\\text{cm}$ এবং ব্যাসার্ধ $r = 0.5\\,\\text{cm}$ (অর্থাৎ ক্ষেত্রফল $A$ সমান)। সুতরাং, $\\Delta L \\propto \\frac{1}{Y}$। অতএব, লোহার ও তামার দৈর্ঘ্য বৃদ্ধির অনুপাত $\\frac{\\Delta L_{Fe}}{\\Delta L_{Cu}} = \\frac{Y_{Cu}}{Y_{Fe}}$। যেহেতু $Y_{Fe} = 2Y_{Cu}$, তাই অনুপাতটি হবে $\\frac{Y_{Cu}}{2Y_{Cu}} = \\frac{1}{2}$ বা $1:2$।	D
cdfddac8-993b-4063-a369-7e44a7d24b69	e50bdce2-e49e-4b4a-8279-da972fe9d089	11.	$\\ce{^{27}_{13}Al + ^{4}_{2}He -> ^{30}_{14}Si + ( )}$ নিউক্লিয় বিক্রিয়াটিতে অনুপস্থিত কণাটি হলো-	physics	atomic_model_and_nuclear_physics	C	\N	generated	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	নিউক্লিয় বিক্রিয়ায় পারমাণবিক সংখ্যা ($Z$) এবং ভর সংখ্যা ($A$) সংরক্ষিত থাকে। বিক্রিয়াটির বাম পাশের মোট পারমাণবিক সংখ্যা $13 + 2 = 15$ এবং সিলিকনের পারমাণবিক সংখ্যা $14$ হওয়ায় অনুপস্থিত কণাটির পারমাণবিক সংখ্যা $Z = 15 - 14 = 1$। একইভাবে, বাম পাশের মোট ভর সংখ্যা $27 + 4 = 31$ এবং সিলিকনের ভর সংখ্যা $30$ হওয়ায় অনুপস্থিত কণাটির ভর সংখ্যা $A = 31 - 30 = 1$। যেহেতু কণাটির পারমাণবিক সংখ্যা $1$ এবং ভর সংখ্যা $1$, তাই এটি একটি প্রোটন ($^{1}_{1}\\text{H}$)। সুতরাং সঠিক উত্তরটি হলো প্রোটন।	C
3bba5900-28d6-4761-ad6f-cfa430e73ebe	55086422-ef06-4659-a0be-10579b6abde5	21	একটি প্রত্যাবর্তী তড়িৎ প্রবাহকে $I = 100 \\sin 2\\pi t$ Ampere সমীকরণ দ্বারা প্রকাশ করা হয়। তড়িৎ প্রবাহের গড়-বর্গীয়-বর্গমূলের মান কত?	physics	electromagnetic_induction_and_alternating_current	A	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	প্রদত্ত তড়িৎ প্রবাহের সমীকরণ $I = 100 \\sin 2\\pi t$ থেকে দেখা যায় যে, তড়িৎ প্রবাহের শীর্ষ মান $I_0 = 100\\,\\text{A}$। তড়িৎ প্রবাহের গড়-বর্গীয়-বর্গমূল মান (RMS value) বের করার সূত্র হলো $I_{\\text{rms}} = \\frac{I_0}{\\sqrt{2}}$। এখানে মান বসিয়ে পাই, $I_{\\text{rms}} = \\frac{100}{\\sqrt{2}} \\approx \\frac{100}{1.414} = 70.71\\,\\text{A}$। সুতরাং, তড়িৎ প্রবাহের গড়-বর্গীয়-বর্গমূলের মান প্রায় $70.7\\,\\text{A}$।	A
c740ba7e-7386-4f2f-a462-c1d4778554e9	e50bdce2-e49e-4b4a-8279-da972fe9d089	13.	কোনো দিক পরিবর্তী তড়িৎচালক বলের গড়বর্গের বর্গমূল মান $10$ volt। তড়িৎচালক বলের শীর্ষমান হলো-	physics	electromagnetic_induction_and_alternating_current	B	\N	generated	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	দিক পরিবর্তী তড়িৎচালক বলের গড়বর্গের বর্গমূল মান ($E_{\\text{rms}}$) এবং শীর্ষমানের ($E_0$) মধ্যে সম্পর্ক হলো $E_{\\text{rms}} = \\frac{E_0}{\\sqrt{2}}$। এখানে দেওয়া আছে, $E_{\\text{rms}} = 10\\,\\text{V}$। সুতরাং, শীর্ষমান $E_0 = E_{\\text{rms}} \\times \\sqrt{2} = 10 \\times 1.4142\\,\\text{V} = 14.142\\,\\text{V}$। প্রাপ্ত মানটি অপশন (B) এর সাথে সামঞ্জস্যপূর্ণ।	B
61ea3a53-6193-49d9-a68a-80213ce57a55	e50bdce2-e49e-4b4a-8279-da972fe9d089	05.	$m$ ভরের বস্তু ঘর্ষণবিহীন একটি তলে $v$ বেগে চলার সময় একটি স্প্রিং-এর সাথে ধাক্কা লেগে স্প্রিংটিকে সংকুচিত করল। স্প্রিংটির বল-ধ্রুবক $k$ হলে স্প্রিংটি কতটুকু সংকুচিত হবে?	physics	work_energy_and_power	A	\N	generated	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	বস্তুটির গতিশক্তি স্প্রিং-এর বিভব শক্তিতে রূপান্তরিত হয়। শক্তির সংরক্ষণশীলতা নীতি অনুযায়ী, $\\frac{1}{2}mv^2 = \\frac{1}{2}kx^2$, যেখানে $x$ হলো স্প্রিং-এর সর্বোচ্চ সংকোচন। এই সমীকরণ থেকে আমরা পাই $x^2 = \\frac{m}{k}v^2$। বর্গমূল করলে সংকোচনের মান দাঁড়ায় $x = \\sqrt{\\frac{m}{k}}v$। সুতরাং সঠিক উত্তরটি হলো (A)।	A
461daa81-404c-4000-b336-e406acefa007	e50bdce2-e49e-4b4a-8279-da972fe9d089	06.	ইয়ং এর দ্বি-চিড় পরীক্ষার চিড়দ্বয়ের মধ্যবর্তী দূরত্ব হলো $d$ এবং চিড়দ্বয় থেকে পর্দা $D$ দূরত্বে অবস্থিত। পর্দার উপর প্রতি একক প্রস্থে ডোরার সংখ্যা হলো-	physics	physical_optics	B	\N	generated	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	ইয়ং এর দ্বি-চিড় পরীক্ষায় ডোরার প্রস্থ (fringe width) $\\beta$ এর সমীকরণ হলো $\\beta = \\frac{\\lambda D}{d}$, যেখানে $\\lambda$ হলো আলোর তরঙ্গদৈর্ঘ্য, $D$ হলো পর্দা থেকে চিড়ের দূরত্ব এবং $d$ হলো চিড়দ্বয়ের মধ্যবর্তী দূরত্ব। পর্দার প্রতি একক প্রস্থে ডোরার সংখ্যা ($n$) হলো ডোরার প্রস্থের বিপরীত রাশি। অর্থাৎ, $n = \\frac{1}{\\beta} = \\frac{1}{\\frac{\\lambda D}{d}} = \\frac{d}{\\lambda D}$। সুতরাং, প্রতি একক প্রস্থে ডোরার সংখ্যা হলো $\\frac{d}{D\\lambda}$।	B
e7f5bd3b-c6c0-40f2-8303-1977170cdd93	e50bdce2-e49e-4b4a-8279-da972fe9d089	08.	একটি সমান্তরাল পাত ধারককে চার্জিত করার পর ব্যাটারি খুলে ফেলা হলো। এ অবস্থায় ধারকটিতে সঞ্চিত শক্তির পরিমাণ $U_0$। পাত দুটির দূরত্ব যদি দ্বিগুণ করা হয়, তবে ধারকের সঞ্চিত শক্তি কতগুণ হবে?	physics	static_electricity	C	\N	generated	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	ব্যাটারি খুলে ফেলার কারণে ধারকের চার্জ $Q$ অপরিবর্তিত থাকে। সমান্তরাল পাত ধারকের ধারকত্ব $C = \\frac{\\epsilon_0 A}{d}$ এবং সঞ্চিত শক্তি $U = \\frac{Q^2}{2C}$। যদি পাত দুটির মধ্যবর্তী দূরত্ব $d$ দ্বিগুণ করা হয়, তবে নতুন ধারকত্ব হবে $C' = \\frac{\\epsilon_0 A}{2d} = \\frac{C}{2}$। সুতরাং নতুন সঞ্চিত শক্তি $U' = \\frac{Q^2}{2C'} = \\frac{Q^2}{2(C/2)} = 2 \\times \\frac{Q^2}{2C} = 2U_0$। অর্থাৎ সঞ্চিত শক্তি দ্বিগুণ হবে।	C
f1859d7a-e0a7-4fd0-b9c8-a04f01ee9d2a	e50bdce2-e49e-4b4a-8279-da972fe9d089	15	অভিকর্ষীয় ত্বরণ $g$ বনাম পৃথিবী পৃষ্ঠ হতে গভীরতা $h$ এর লেখচিত্র কোনটি?	physics	gravitation_and_gravity	A	\N	generated	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p02_q15_01.png", "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}, {"id": "IMAGE_2", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p02_q15_02.png", "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}, {"id": "IMAGE_3", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p02_q15_03.png", "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}, {"id": "IMAGE_4", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p02_q15_04.png", "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}]	The gravitational acceleration at a depth $h$ from the Earth's surface is given by the formula $g = g_0 (1 - \\frac{h}{R})$, where $g_0$ is the acceleration at the surface and $R$ is the radius of the Earth. This equation can be rewritten as $g = -\\frac{g_0}{R}h + g_0$, which is a linear equation of the form $y = mx + c$ with a negative slope $m = -\\frac{g_0}{R}$. At the surface ($h = 0$), $g = g_0$, and at the center of the Earth ($h = R$), $g = 0$. Therefore, the graph of $g$ versus $h$ is a straight line with a negative slope, as shown in option (A).	A
134c31cf-066e-4317-af88-173a7711068d	e50bdce2-e49e-4b4a-8279-da972fe9d089	01.	একটি সরল দোলকের দোলনকাল $50\\%$ বাড়াতে এর কার্যকর দৈর্ঘ্যের পরিবর্তন কত হবে?	physics	periodic_motion	C	\N	generated	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	সরল দোলকের দোলনকাল $T$ এবং কার্যকর দৈর্ঘ্য $L$ এর মধ্যে সম্পর্ক হলো $T = 2\\pi \\sqrt{\\frac{L}{g}}$, অর্থাৎ $L \\propto T^2$। দোলনকাল $50\\%$ বৃদ্ধি করলে নতুন দোলনকাল হয় $T_2 = T_1 + 0.5T_1 = 1.5T_1$। এখন, দৈর্ঘ্যের অনুপাত $\\frac{L_2}{L_1} = \\left(\\frac{T_2}{T_1}\\right)^2 = (1.5)^2 = 2.25$। সুতরাং, কার্যকর দৈর্ঘ্যের পরিবর্তন $\\Delta L = L_2 - L_1 = 2.25L_1 - L_1 = 1.25L_1$, যা আদি দৈর্ঘ্যের $125\\%$।	C
982593d5-f7ce-4d9e-813b-41e6df2b0bef	e50bdce2-e49e-4b4a-8279-da972fe9d089	03.	$q$ আধান বিশিষ্ট একটি গোলককে একটি অপরিবাহী সুতার একপ্রান্ত বেঁধে $\\omega$ কৌণিক বেগে ঘোরানো হচ্ছে। ঘূর্ণায়মান আধানটি কী পরিমাণ বিদ্যুৎ উৎপন্ন করবে?	physics	current_electricity	D	\N	generated	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	তড়িৎ প্রবাহের সংজ্ঞা অনুযায়ী, $I = \\frac{q}{T}$। এখানে $T$ হলো আধানটির একটি পূর্ণ ঘূর্ণনের সময় বা পর্যায়কাল। আমরা জানি, কৌণিক বেগ $\\omega = \\frac{2\\pi}{T}$, যেখান থেকে পাওয়া যায় $T = \\frac{2\\pi}{\\omega}$। এই মানটি প্রবাহের সমীকরণে বসালে আমরা পাই $I = \\frac{q}{\\frac{2\\pi}{\\omega}} = \\frac{q\\omega}{2\\pi}$। সুতরাং, উৎপন্ন বিদ্যুতের পরিমাণ হবে $\\frac{q\\omega}{2\\pi}$।	D
bddb3fc5-93d3-4c42-a66d-96227a6e8f0f	05a449d9-5db0-488f-936f-ab50cc72299e	02	ইয়ং-এর দ্বি-চিড় পরীক্ষায় চিড়-দ্বয়ের মধ্যবর্তী দূরত্ব দ্বিগুণ করা হলো। পর্দার প্রতি একক দৈর্ঘ্যে উজ্জ্বল ডোরার সংখ্যা স্থির রাখতে হলে চিড় থেকে পর্দার দূরত্ব $D$ কে কীভাবে পরিবর্তন করতে হবে?	physics	physical_optics	C	\N	generated	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	ইয়ং-এর দ্বি-চিড় পরীক্ষায় প্রতি একক দৈর্ঘ্যে উজ্জ্বল ডোরার সংখ্যা $n = \\frac{1}{\\beta} = \\frac{d}{\\lambda D}$, যেখানে $d$ হলো চিড়-দ্বয়ের মধ্যবর্তী দূরত্ব এবং $D$ হলো চিড় থেকে পর্দার দূরত্ব। প্রশ্নানুসারে, ডোরার সংখ্যা $n$ স্থির রাখতে হবে এবং চিড়-দ্বয়ের মধ্যবর্তী দূরত্ব দ্বিগুণ ($d' = 2d$) করা হয়েছে। সুতরাং, $\\frac{d}{\\lambda D} = \\frac{2d}{\\lambda D'}$ সমীকরণ থেকে আমরা পাই $D' = 2D$। অর্থাৎ, পর্দার প্রতি একক দৈর্ঘ্যে উজ্জ্বল ডোরার সংখ্যা স্থির রাখতে হলে চিড় থেকে পর্দার দূরত্ব দ্বিগুণ করতে হবে।	C
e568c7fc-715f-404d-b3ed-70048053b374	b0c3348a-46af-4e00-a298-7006c2a9785f	10.	একটি হুইটস্টোন ব্রিজের চারটি বাহু $P, Q, R$ এবং $S$-এ যথাক্রমে $8\\,\\Omega, 12\\,\\Omega, 16\\,\\Omega$ এবং $48\\,\\Omega$ রোধ যুক্ত আছে। ব্রিজটিকে সাম্যাবস্থায় আনতে চতুর্থ বাহুতে কত রোধ কীভাবে যুক্ত করতে হবে?	physics	current_electricity	D	\N	generated	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	একটি হুইটস্টোন ব্রিজের সাম্যাবস্থার শর্ত হলো $P/Q = R/S_{eq}$। প্রদত্ত মানগুলি হলো $P = 8\\,\\Omega$, $Q = 12\\,\\Omega$, এবং $R = 16\\,\\Omega$। সাম্যাবস্থায় চতুর্থ বাহুর প্রয়োজনীয় রোধ $S_{eq}$ হবে: $S_{eq} = (Q/P) \\times R = (12\\,\\Omega / 8\\,\\Omega) \\times 16\\,\\Omega = 1.5 \\times 16\\,\\Omega = 24\\,\\Omega$। চতুর্থ বাহুতে বর্তমানে $S = 48\\,\\Omega$ রোধ আছে। যেহেতু $S_{eq} < S$, তাই রোধ কমাতে হবে, যার অর্থ একটি অতিরিক্ত রোধকে বর্তমান রোধের সাথে সমান্তরালে যুক্ত করতে হবে। যদি $X$ রোধ সমান্তরালে যুক্ত করা হয়, তাহলে $1/S_{eq} = 1/S + 1/X$। মান বসিয়ে পাই: $1/24\\,\\Omega = 1/48\\,\\Omega + 1/X$। সুতরাং, $1/X = 1/24\\,\\Omega - 1/48\\,\\Omega = (2 - 1)/48\\,\\Omega = 1/48\\,\\Omega$। অতএব, $X = 48\\,\\Omega$। অর্থাৎ, $48\\,\\Omega$ রোধকে সমান্তরালে যুক্ত করতে হবে।	D
dc146fec-8cb1-4a88-9c45-440587c8f124	55086422-ef06-4659-a0be-10579b6abde5	08.	$5.0\\,\\text{N}$ এর একটি আনুভূমিক বল একটি $0.50\\,\\text{kg}$ ভরের আয়তাকার বস্তুকে একটি উলম্ব দেওয়ালে ধাক্কা দিচ্ছে। বস্তুটি আদিতে স্থির ছিল। যদি স্থৈতিক ও গতীয় ঘর্ষণ গুণাঙ্ক যথাক্রমে $\\mu_s = 0.6$ এবং $\\mu_k = 0.8$ হয়, তবে $\\text{m/s}^2$ এককে বস্তুটির ত্বরণ কত?	physics	newtonian_mechanics	A	\N	generated	2026-04-27 18:29:38.654719+00	Dhaka University	2018-2019	A	null	বস্তুটির ওজন $W = mg = 0.50\\,\\text{kg} \\times 9.8\\,\\text{m/s}^2 = 4.9\\,\\text{N}$ এবং দেওয়ালের লম্ব প্রতিক্রিয়া বল $N = 5.0\\,\\text{N}$। সর্বোচ্চ স্থৈতিক ঘর্ষণ বল $f_{s, \\text{max}} = \\mu_s N = 0.6 \\times 5.0\\,\\text{N} = 3.0\\,\\text{N}$। যেহেতু বস্তুর ওজন $W$, সর্বোচ্চ স্থৈতিক ঘর্ষণ বল $f_{s, \\text{max}}$ অপেক্ষা বেশি ($4.9\\,\\text{N} > 3.0\\,\\text{N}$), তাই বস্তুটি নিচের দিকে গতিশীল হবে। গতিশীল অবস্থায় গতীয় ঘর্ষণ বল $f_k = \\mu_k N = 0.8 \\times 5.0\\,\\text{N} = 4.0\\,\\text{N}$ কাজ করবে। সুতরাং বস্তুটির ত্বরণ $a = \\frac{W - f_k}{m} = \\frac{4.9 - 4.0}{0.50} = 1.8\\,\\text{m/s}^2$।	A
7452052d-1c3d-4aa8-8fcd-e58556513248	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	17	বাইনারী সংখ্যা $(110011)_2$ এবং $(101101)_2$ এর যোগফল কত?	physics	semiconductor_and_electronics	A	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	বাইনারী সংখ্যা যোগ করার জন্য, আমরা ডান থেকে বামে প্রতিটি বিট যোগ করি এবং ক্যারি (carry) থাকলে তা পরবর্তী কলামে যোগ করি।\n\n  1 1 0 0 1 1\n+ 1 0 1 1 0 1\n--------------\n  1 1 0 0 0 0 0\n\nধাপগুলি হলো:\n1. $1 + 1 = 0$ (ক্যারি 1)\n2. $1 + 0 + 1 (\text{ক্যারি}) = 0$ (ক্যারি 1)\n3. $0 + 1 + 1 (\text{ক্যারি}) = 0$ (ক্যারি 1)\n4. $0 + 1 + 1 (\text{ক্যারি}) = 0$ (ক্যারি 1)\n5. $1 + 0 + 1 (\text{ক্যারি}) = 0$ (ক্যারি 1)\n6. $1 + 1 + 1 (\text{ক্যারি}) = 1$ (ক্যারি 1)\n7. শেষ ক্যারিটি বামে যোগ হয়: $1$\n\nসুতরাং, যোগফল হলো $(1100000)_2$।	A
6b90fb4c-402a-49a3-95a2-75d1eb435bea	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	18	নিম্নের কোন উক্তিটি ফোটনের ক্ষেত্রে সঠিক নয়?	physics	introduction_to_modern_physics	B	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	ফোটন হলো আলোর কোয়ান্টা। ফোটনের শক্তি $E = hf = \\frac{hc}{\\lambda}$ এবং ভরবেগ $p = \\frac{E}{c} = \\frac{h}{\\lambda}$। এখানে $h$ হলো প্ল্যাঙ্কের ধ্রুবক, $f$ হলো কম্পাঙ্ক, $c$ হলো আলোর বেগ এবং $\\lambda$ হলো তরঙ্গদৈর্ঘ্য। সুতরাং, ফোটনের শক্তি ও ভরবেগ উভয়ই আছে। অপশন (B) বলছে ফোটনের ভরবেগ ও শক্তি নেই, যা ভুল। অন্যান্য অপশনগুলো ফোটনের সঠিক বৈশিষ্ট্য বর্ণনা করে: ফোটন শূন্য মাধ্যমে আলোর বেগে চলে (A), কণা ও তরঙ্গ উভয় ধর্ম প্রদর্শন করে (C), এবং এর স্থির ভর শূন্য (D)।	B
346f920b-88ea-4002-9f8c-54db78719db2	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	09.	ঘড়ির মিনিটের কাঁটার কৌণিক বেগের মান-	physics	periodic_motion	D	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	ঘড়ির মিনিটের কাঁটা একটি পূর্ণ ঘূর্ণন সম্পন্ন করতে $60$ মিনিট সময় নেয়। এই $60$ মিনিট হলো মিনিটের কাঁটার পর্যায়কাল ($T$)। আমরা জানি, $1$ মিনিট $= 60$ সেকেন্ড, সুতরাং $T = 60 \\times 60 = 3600\\,\\text{s}$। কৌণিক বেগের ($\\omega$) সূত্র হলো $\\omega = \\frac{2\\pi}{T}$। মান বসিয়ে পাই, $\\omega = \\frac{2\\pi}{3600}\\,\\text{rad/s} = \\frac{\\pi}{1800}\\,\\text{rad/s}$।	D
d465803b-1304-4d77-8002-5b7aedd3c83c	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	02.	যদি $5\\,\\text{A}$ তড়িৎ $3$ ঘণ্টা ধরে একটি বাতির মধ্য দিয়ে প্রবাহিত হয় তাহলে ঐ বাতির মধ্য দিয়ে প্রবাহিত চার্জের মান-	physics	current_electricity	B	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	তড়িৎ প্রবাহের সংজ্ঞা অনুযায়ী, প্রবাহিত চার্জের পরিমাণ $Q$ হলো তড়িৎ প্রবাহ $I$ এবং সময় $t$-এর গুণফল, অর্থাৎ $Q = I \\times t$। এখানে, তড়িৎ প্রবাহ $I = 5\\,\\text{A}$ এবং সময় $t = 3$ ঘণ্টা। সময়কে সেকেন্ডে রূপান্তর করতে হবে: $t = 3 \\times 60 \\times 60\\,\\text{s} = 10800\\,\\text{s}$। এখন চার্জের মান নির্ণয় করি: $Q = 5\\,\\text{A} \\times 10800\\,\\text{s} = 54000\\,\\text{C}$। এটিকে বৈজ্ঞানিকNotation-এ লিখলে হয় $Q = 5.4 \\times 10^4\\,\\text{C}$।	B
38286d3b-99a2-4122-b821-87eb0a236eca	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	05.	$10,000\\,\\text{kg}$ জ্বালানীসহ একটি রকেটের ভর $15000\\,\\text{kg}$। জ্বালানী যদি $200\\,\\text{kg/s}$ হারে পুড়ে রকেটের সাপেক্ষে $2000\\,\\text{m/s}$ বেগে নির্গত হয়, তাহলে রকেটের উপর প্রযুক্ত ধাক্কা বা থ্রাস্ট কত?	physics	newtonian_mechanics	A	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	রকেটের উপর প্রযুক্ত ধাক্কা বা থ্রাস্টের সূত্র হলো $F = v_e \\frac{dm}{dt}$, যেখানে $v_e$ হলো নির্গত গ্যাসের বেগ এবং $\\frac{dm}{dt}$ হলো জ্বালানী পোড়ার হার। প্রদত্ত মানগুলো হলো $v_e = 2000\\,\\text{m/s}$ এবং $\\frac{dm}{dt} = 200\\,\\text{kg/s}$। মানগুলো সূত্রে বসিয়ে পাই, $F = (2000\\,\\text{m/s}) \\times (200\\,\\text{kg/s}) = 400000\\,\\text{N}$। এটিকে বৈজ্ঞানিকNotation-এ লিখলে হয় $4 \\times 10^5\\,\\text{N}$।	A
631925ee-0015-485f-b444-04e213626498	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	06.	$3\\frac{d^2x}{dt^2} + 27x = 0$ সমীকরণটি একটি সরল ছন্দিত স্পন্দন বর্ণনা করে। এই স্পন্দনের কৌণিক কম্পাঙ্ক কত?	physics	periodic_motion	A	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	একটি সরল ছন্দিত স্পন্দনের আদর্শ অবকল সমীকরণ হলো $\\frac{d^2x}{dt^2} + \\omega^2x = 0$, যেখানে $\\omega$ হলো কৌণিক কম্পাঙ্ক। প্রদত্ত সমীকরণটি হলো $3\\frac{d^2x}{dt^2} + 27x = 0$। এই সমীকরণটিকে 3 দ্বারা ভাগ করে পাই $\\frac{d^2x}{dt^2} + 9x = 0$। আদর্শ সমীকরণের সাথে তুলনা করে আমরা পাই $\\omega^2 = 9$। সুতরাং, কৌণিক কম্পাঙ্ক $\\omega = \\sqrt{9} = 3\\,\\text{rad/s}$।	A
46017748-34b0-4df2-ba25-ae8a35202fd9	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	04.	যদি $\\vec{P} = \\hat{i} - \\hat{j} + \\hat{k}$ এবং $\\vec{Q} = \\hat{i} + \\hat{j} - \\hat{k}$ একটি সামান্তরিকের দুইটি সন্নিহিত বাহু নির্দেশ করে, তাহলে উপযুক্ত এককে সামান্তরিকের ক্ষেত্রফল নির্ণয় কর।	physics	vector	A	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	একটি সামান্তরিকের দুইটি সন্নিহিত বাহু $\\vec{P}$ এবং $\\vec{Q}$ দ্বারা নির্দেশিত হলে, এর ক্ষেত্রফল তাদের ক্রস গুণফলের মানের সমান, অর্থাৎ Area $= |\\vec{P} \\times \\vec{Q}|$. প্রথমে ক্রস গুণফল নির্ণয় করি: $$\\vec{P} \\times \\vec{Q} = \\begin{vmatrix} \\hat{i} & \\hat{j} & \\hat{k} \\\\ 1 & -1 & 1 \\\\ 1 & 1 & -1 \\end{vmatrix} = \\hat{i}(1-1) - \\hat{j}(-1-1) + \\hat{k}(1-(-1)) = 0\\hat{i} + 2\\hat{j} + 2\\hat{k}$$ এখন এই ভেক্টরের মান নির্ণয় করি: $$|\\vec{P} \\times \\vec{Q}| = \\sqrt{0^2 + 2^2 + 2^2} = \\sqrt{0 + 4 + 4} = \\sqrt{8} = 2\\sqrt{2}$$ সুতরাং, সামান্তরিকের ক্ষেত্রফল $2\\sqrt{2}$ উপযুক্ত একক।	A
cf30506d-2b21-48ac-ab56-f21bdea377c6	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	16	একটি পাতলা ফিল্মের উপর একবর্ণী আলো উলম্বভাবে আপতিত হলো। যদি ফিল্মের ভেতর আলোর তরঙ্গদৈর্ঘ্য $\\lambda$ হয়, তবে সর্বনিম্ন কত পুরুত্বের জন্য প্রতিফলিত আলো সবচেয়ে বেশি উজ্জ্বল হবে?	physics	physical_optics	C	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	একটি পাতলা ফিল্মে প্রতিফলিত আলোর উজ্জ্বলতার জন্য গঠনমূলক ব্যতিচারের শর্ত নির্ণয় করতে হবে। যখন আলো বায়ু থেকে ফিল্মে (উচ্চ প্রতিসরাঙ্ক) প্রবেশ করে প্রতিফলিত হয়, তখন $\\pi$ দশার পরিবর্তন (বা $\\lambda/2$ পথ পার্থক্য) ঘটে। ফিল্মের ভেতর থেকে বায়ুতে প্রতিফলনের সময় কোনো দশার পরিবর্তন হয় না। সুতরাং, দুটি প্রতিফলিত রশ্মির মধ্যে মোট দশার পার্থক্য $\\pi$ (বা $\\lambda/2$ পথ পার্থক্য)। ফিল্মের পুরুত্ব $t$ হলে, আলোর অতিরিক্ত পথ অতিক্রম করার কারণে পথ পার্থক্য $2t$ হয়। গঠনমূলক ব্যতিচারের জন্য, মোট পথ পার্থক্য $\\lambda$ এর বিজোড় গুণিতক হতে হবে। অর্থাৎ, $2t = (2m+1)\\frac{\\lambda}{2}$, যেখানে $m = 0, 1, 2, ...$। সর্বনিম্ন পুরুত্বের জন্য, $m=0$ বসিয়ে পাই $2t = (2(0)+1)\\frac{\\lambda}{2} = \\frac{\\lambda}{2}$। অতএব, $t = \\frac{\\lambda}{4}$।	C
a360f901-de88-4d26-8f31-c16713d3b6da	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	26	সর্বনিম্ন কত বেগে ভূপৃষ্ঠ হতে (m) ভরের একটি বস্তুকে উপরের দিকে নিক্ষেপ করলে তা আর কখনো ফিরে আসবে না?	physics	gravitation_and_gravity	A	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	ভূপৃষ্ঠ থেকে একটি বস্তুকে নিক্ষেপ করলে তা আর কখনো ফিরে না আসার জন্য প্রয়োজনীয় সর্বনিম্ন বেগ হলো মুক্তি বেগ (escape velocity)। শক্তি সংরক্ষণ নীতি অনুসারে, বস্তুর প্রাথমিক গতিশক্তি ও বিভবশক্তির যোগফল অসীম দূরত্বে তার চূড়ান্ত গতিশক্তি ও বিভবশক্তির যোগফলের সমান হবে। অসীম দূরত্বে বস্তুর গতিশক্তি ও বিভবশক্তি উভয়ই শূন্য ধরা হয়।\nসুতরাং, $\\frac{1}{2}mv_e^2 - \\frac{GMm}{R} = 0$, যেখানে $m$ বস্তুর ভর, $v_e$ মুক্তি বেগ, $G$ মহাকর্ষীয় ধ্রুবক, $M$ পৃথিবীর ভর এবং $R$ পৃথিবীর ব্যাসার্ধ।\nএখান থেকে আমরা পাই $v_e^2 = \\frac{2GM}{R}$।\nআমরা জানি, ভূপৃষ্ঠে অভিকর্ষজ ত্বরণ $g = \\frac{GM}{R^2}$। সুতরাং, $GM = gR^2$।\nএই মানটি প্রতিস্থাপন করে পাই $v_e^2 = \\frac{2(gR^2)}{R} = 2gR$।\nঅতএব, মুক্তি বেগ $v_e = \\sqrt{2gR}$।	A
568b2bc9-9a19-44c0-8b8b-8d0045475282	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	23	দুইটি কণার মধ্যে মহাকর্ষ বলের মান কেমন পরিবর্তন হবে যদি একটি কণার ভর পূর্বের দ্বিগুণ, অন্য কণার ভর তিনগুণ করা হয় এবং একই সাথে তাদের মাঝের দূরত্ব দ্বিগুণ করা হয়?	physics	gravitation_and_gravity	D	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	মহাকর্ষ বলের সূত্র হলো $F = G \\frac{m_1 m_2}{r^2}$, যেখানে $G$ মহাকর্ষীয় ধ্রুবক, $m_1$ ও $m_2$ কণাগুলির ভর এবং $r$ তাদের মধ্যবর্তী দূরত্ব। প্রাথমিকভাবে, বল $F_1 = G \\frac{m_1 m_2}{r^2}$। নতুন অবস্থায়, একটি কণার ভর $2m_1$, অন্য কণার ভর $3m_2$ এবং দূরত্ব $2r$ হয়। সুতরাং, নতুন বল হবে $F_2 = G \\frac{(2m_1)(3m_2)}{(2r)^2} = G \\frac{6m_1 m_2}{4r^2} = \\frac{3}{2} G \\frac{m_1 m_2}{r^2}$। এটি $F_1$-এর $\\frac{3}{2}$ গুণ, অর্থাৎ দেড়গুণ।	D
87e60be5-0a87-45da-ad2f-f8266e80c18c	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	24	পোলোনিয়াম $^{214}\\text{Po}(Z=84)$ এর $\\alpha$-বিকিরণের মাধ্যমে প্রাপ্ত মৌল হচ্ছে-	physics	atomic_model_and_nuclear_physics	B	\N	generated	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	আলফা ($\\alpha$) বিকিরণে একটি হিলিয়াম নিউক্লিয়াস ($^4_2\\text{He}$) নির্গত হয়। এর ফলে মূল নিউক্লিয়াসের ভর সংখ্যা (A) ৪ একক কমে যায় এবং পারমাণবিক সংখ্যা (Z) ২ একক কমে যায়। পোলোনিয়াম $^{214}\\text{Po}(Z=84)$ এর ক্ষেত্রে, নতুন ভর সংখ্যা হবে $214 - 4 = 210$ এবং নতুন পারমাণবিক সংখ্যা হবে $84 - 2 = 82$। পারমাণবিক সংখ্যা $Z=82$ মৌলটি হলো সীসা (Lead, Pb)। সুতরাং, প্রাপ্ত মৌলটি হলো $^{210}\\text{Pb}(Z=82)$।	B
88a8f4c9-ea06-4842-9c1d-97e855a3d71f	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	01.	$\\ce{CO(g) + 2H2(g) <=> CH3OH(g)}$ বিক্রিয়ায় $K_p$ এর মান হলো-	chemistry	chemical_changes	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
efe882a1-b0e9-451d-9053-921f352fa936	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	02.	$S_N2$ বিক্রিয়ায় অ্যালকাইল হ্যালাইডসমূহের সক্রিয়তার ক্রম হলো-	chemistry	organic_chemistry	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
1278d559-feee-4b48-aa97-24292f1da1ee	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	03.	প্রতিস্থাপন বিক্রিয়ায় কোন কার্যকরী মূলকটি অর্থো-প্যারা নির্দেশ করে?	chemistry	organic_chemistry	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
91988d5e-0978-4f79-83f7-3a2de7a2733e	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	04.	$\\ce{NaCl}$ এর সাথে $\\ce{H2O}$ যুক্ত করলে কি ঘটে?	chemistry	electrochemistry	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
28e2553a-c7f2-4662-813d-c9e9226da0f1	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	27	$\\ce{NaCl}$ এর জলীয় দ্রবণের তড়িৎ বিশ্লেষণে কোনটি উৎপন্ন হয় না?	chemistry	electrochemistry	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
2777ffa1-e79a-4e69-8144-3e4b14159177	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	28	কাঁচপাত্রের কোন সেটটি সঠিকভাবে আয়তন মাপার জন্য উপযুক্ত?	chemistry	safe_use_of_laboratory	C	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
8f713ee6-5884-42e5-8d02-4107e2eefdc5	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	05.	নিম্নের বিক্রিয়াগুলো হতে কার্বনের প্রমাণ দহন তাপ নির্ণয় কর।\ni. $\\ce{C(s) + 1/2 O2(g) -> CO(g)}$ $\\Delta H^\\circ = -111.0\\,\\text{kJ mol}^{-1}$\nii. $\\ce{CO(g) + 1/2 O2(g) -> CO2(g)}$ $\\Delta H^\\circ = -283.0\\,\\text{kJ mol}^{-1}$	chemistry	chemical_changes	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "energy_cycle_diagram", "box_2d": null, "filename": null, "markdown": null, "page_index": 2, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2015-2016-A-Unit/page_3", "extraction_status": "needs_review"}]	\N	\N
b3b4ac18-4ccf-4541-8660-a40bd7ffc907	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	06.	ইরিথ্রিটল হলো-	chemistry	organic_chemistry	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
2eadfc9d-ff57-4f49-b710-3bbdcabc99ee	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	07.	বিশুদ্ধ পানির ঘনমাত্রা (মোল/লিটার) হলো-	chemistry	quantitative_chemistry	C	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
b071fb5e-2247-45f5-940a-d6c959acaa5a	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	08.	অক্সি এসিড সমূহের শক্তির সঠিক ক্রম হলো-	chemistry	periodic_properties_of_elements_and_chemical_bonding	D	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
f2d50c47-9e08-413b-90c8-863ea371ef25	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	09.	নিম্নের কোনটি সবচেয়ে স্থায়ী কার্বো-ক্যাটায়ন?	chemistry	organic_chemistry	D	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
99bd16c8-681e-4cd7-95ea-a6d206a4561f	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	10.	নিম্নের কোন মৌলটির আয়নিকরণ শক্তি সবচেয়ে বেশি?	chemistry	periodic_properties_of_elements_and_chemical_bonding	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
66b92bce-847f-4ec9-a9d5-e5622d0e8600	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	11.	নিম্নের কোনটি ওজোন স্তর ধ্বংসের জন্য দায়ী নয়?	chemistry	environmental_chemistry	D	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
a997c0bd-b964-4ebf-87ba-b0539efb4f82	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	12.	রিডবার্গ ধ্রুবক $R_H$ দ্বারা প্রকাশ করা হলে, হাইড্রোজেন পরমাণুর বর্ণালীতে বামার সিরিজের জন্য সর্বনিম্ন কত তরঙ্গ-সংখ্যার রশ্মি বিকিরিত হয়?	chemistry	qualitative_chemistry	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
4e250e2d-3679-451d-92f3-b8a35ff1aabe	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	13.	লবণের দ্রাব্যতা গুণফল নির্ণয়ে কোন ধরণের দ্রবণ উপযোগী?	chemistry	qualitative_chemistry	C	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
9338ff51-8319-4d75-9b12-115fa40ad7d5	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	14	$\\ce{CH2=CHCH2CHO}$ যৌগটিতে যথাক্রমে $\\sigma$ এবং $\\pi$ বন্ধনের সংখ্যা হলো-	chemistry	organic_chemistry	D	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
e14decef-c912-4c67-9a74-6e228482bdf0	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	15	কোন বিক্রিয়ার সাম্য ধ্রুবক এবং হার ধ্রুবক উভয়েই যে নিয়ামক দ্বারা প্রভাবিত হয় তা হলো-	chemistry	chemical_changes	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
effc303c-be0b-4ab5-b77b-8c5782cbca48	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	16	লুকাস বিকারকের সাথে তাৎক্ষণিক বিক্রিয়া করে কোনটি?	chemistry	organic_chemistry	D	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
188e8474-d1f9-4b24-bc07-8c165de8c238	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	17	$0^{\\circ}\\text{C}$ তাপমাত্রায় অ্যানিলিন এবং $\\ce{NaNO2}$ ও $\\ce{HCl}$ এর বিক্রিয়ার উৎপাদকে কক্ষ তাপমাত্রায় রেখে দিলে কি পাওয়া যায়?	chemistry	organic_chemistry	D	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
79a79fe2-b88e-4109-a379-20fbd6f9bee8	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	18	তড়িৎ-রাসায়নিক কোষের সল্ট-ব্রিজে কোন লবণের সম্পৃক্ত জলীয় দ্রবণটি উৎকৃষ্ট?	chemistry	electrochemistry	D	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
54359da1-92d6-4bbc-a95c-006986f8aa6a	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	19	নিম্নের কোন অণুটি রৈখিক?	chemistry	periodic_properties_of_elements_and_chemical_bonding	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
160d3d55-632b-4eae-9f49-b71e561af0ef	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	20	দুর্বল এসিড $\\ce{HX}$ ও $\\ce{NaOH}$ এর বিক্রিয়ার সমীকরণটি হলো- $\\ce{HX(aq) + NaOH(aq) -> NaX(aq) + H2O(l)}$ $\\ce{NaX}$ এর জলীয় দ্রবণের সম্ভাব্য $\\text{pH}$ হবে-	chemistry	qualitative_chemistry	C	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
34a58ff5-146c-4b24-ab31-b496aa336d65	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	21	[IMAGE_1] যৌগটির IUPAC নাম হলো-	chemistry	organic_chemistry	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "chemical_structure", "box_2d": null, "filename": null, "markdown": null, "page_index": 3, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2015-2016-A-Unit/page_4", "extraction_status": "needs_review"}]	\N	\N
4ad10a1c-f759-44fc-b122-a342e5345a2d	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	22	নিম্নের যৌগগুলোর মধ্যে সবচেয়ে কম স্ফুটনাংক কোনটির?	chemistry	organic_chemistry	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
b608c211-3a82-452f-a440-f03381ff6cdb	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	23	নিম্নের কোন যৌগটি সবচেয়ে শক্তিশালী হাইড্রোজেন বন্ধন গঠন করে?	chemistry	periodic_properties_of_elements_and_chemical_bonding	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
8d2ee9f7-696c-415b-a8aa-3d97e0bd4a8f	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	24	শিখা পরীক্ষায় কোন মৌলটি সোনালী হলুদ শিখা প্রদর্শন করে?	chemistry	qualitative_chemistry	C	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
65ea1367-817f-45f1-925c-f07d4ff78c1c	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	25	নিম্নের বিক্রিয়াটির ক্ষেত্রে কোনটি সত্য? $$\\ce{SnCl2 + 2FeCl3 -> SnCl4 + 2FeCl2}$$	chemistry	quantitative_chemistry	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
d4c961fd-e7c3-41c4-bfe0-b0947b6b1791	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	26	আদর্শ গ্যাস আচরণ থেকে বিচ্যুতির ক্রম কোনটি?	chemistry	ideal_gas_and_gas_kinetics	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
837b9a9e-058a-4d0c-ab74-739f69655f67	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	29	কোন মৌলটির উপস্থিতি কয়লার মান নষ্ট করে?	chemistry	environmental_chemistry	C	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
2e739d1c-0a19-4655-acd6-3c0afdac88f7	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	30	সিরামিক শিল্পের গুরুত্বপূর্ণ কাঁচামাল, ক্যাওলিনাইটের রাসায়নিক সংকেত হলো-	chemistry	economic_chemistry	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
90f4458e-db6a-42a5-974f-e7838ff95383	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	01	$\\cot^2\\theta - (\\sqrt{3} + 1) \\cot\\theta + \\sqrt{3} = 0, 0 < \\theta < \\frac{\\pi}{2}$ হলে, $\\theta = ?$	mathematics	inverse_trigonometric_functions_and_trigonometric_equations	D	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
00a8153e-8901-4f13-8ded-a2f2e4e13ffe	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	02	কোন বিন্দুর পোলার স্থানাঙ্ক $(3, 150^\\circ)$ হলে, ঐ বিন্দুর কার্তেসীয় স্থানাঙ্ক-	mathematics	straight_lines	C	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
64013a8d-e3f5-4db2-94af-1521227c85f1	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	03	$y = kx - 1$ সরলরেখাটি $y = x^2 + 3$ বক্ররেখার স্পর্শক হলে, $k$ এর একটি মান-	mathematics	straight_lines	D	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
280db66c-4465-492b-be96-2df7528ac624	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	04	$\\sec^2(\\cot^{-1}3) + \\csc^2(\\tan^{-1}2) = ?$	mathematics	inverse_trigonometric_functions_and_trigonometric_equations	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
3ff2320b-449f-4642-a3b2-44b42845af9f	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	05	$y = \\frac{\\sin x + \\cos x}{\\sqrt{1 + \\sin 2x}}$ হলে, $\\frac{dy}{dx} = ?$	mathematics	differential_calculus	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
684ae4f8-35a7-4cae-9b36-d6a5e6b5ecad	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	06	$\\int_0^{10} |x - 5| dx = ?$	mathematics	integral_calculus	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
88055b7b-1d2a-4214-8b2f-764bf18631fd	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	07	$\\int \\frac{e^x(1 + x)}{\\cos^2(xe^x)} dx = f(x) + c; f(x) = ?$	mathematics	integral_calculus	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
d6a54fcb-9063-4b1e-9ea6-d7af276a9e3d	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	08	$\\int_0^x f(p)f'(p) dp = ?$	mathematics	integral_calculus	C	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
dfe2f375-038e-404b-84c8-d180703d4066	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	09.	$\\lim_{x \\to 0} \\frac{\\sin 7x - \\sin x}{\\sin 6x} = ?$	mathematics	differential_calculus	C	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
fa5859ec-2974-4fb0-a78e-381edc86ba1b	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	10.	$ABC$ ত্রিভুজে $a:b:c = 3:7:5$ হলে, $\\angle B = ?$	mathematics	trigonometric_ratios	D	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
d6a74f81-a1f0-4490-8734-6a72f92fc963	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	11.	$2x^2 - 7x + 5 = 0$ সমীকরণের মূলদ্বয় $\\alpha, \\beta$ এবং $x^2 - 4x + 3 = 0$ সমীকরণের মূলদ্বয় $\\beta$ এবং $\\gamma$ হলে, $(\\gamma + \\alpha) : (\\gamma - \\alpha) = ?$	mathematics	polynomials_and_polynomial_equations	C	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
729b8f97-7237-4a56-b3c1-32b088e0d05e	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	12.	$k$ এর কোন মানের জন্য $y = kx(1-x)$ বক্ররেখার মূলবিন্দুতে স্পর্শকটি $x$ অক্ষের সাথে $30^\\circ$ কোণ উৎপন্ন করে?	mathematics	differential_calculus	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
059f3416-8a2a-4f39-b02d-8c91930a3182	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	13.	$y^2 = 16x$ এবং $y = 4x$ দ্বারা আবদ্ধ ক্ষেত্রের ক্ষেত্রফল-	mathematics	integral_calculus	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
2bff07da-b0ce-4a86-8516-089b41c61b98	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	15.	$\\sin A + \\cos A = \\sin B + \\cos B$ হলে, $A + B = ?$	mathematics	inverse_trigonometric_functions_and_trigonometric_equations	C	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
f7308d4e-842c-48a5-ab56-13e3c775a9bf	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	16.	$|5 - \\frac{2}{3x}| < 1$ অসমতাটির সমাধান সেট-	mathematics	real_numbers_and_inequalities	C	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
b107e72d-5b35-48a9-844e-8debf4367482	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	17.	$f: \\mathbb{R} \\to \\mathbb{R}$ কে $f(x) = e^{x-3}$ দ্বারা সংজ্ঞায়িত করা হলে, $f^{-1}(e)$ এর মান-	mathematics	functions_and_graphs	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
ca7ca25e-f07d-423d-9b1e-5fa91a2bf578	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	18.	দ্বিমিক সংখ্যা $1111111$ কে দ্বিমিক সংখ্যা $101$ দ্বারা ভাগ করলে ভাগশেষ-	mathematics	polynomials_and_polynomial_equations	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
be3b4e34-7d71-43a8-9a9a-12a60e7bdbd9	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	19.	$(2x - \\frac{1}{4x^2})^{12}$ এর বিস্তৃতিতে $x^3$ এর সহগ-	mathematics	binomial_expansion	C	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
e3496790-8253-4d55-ac02-c62789a3aa79	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	20	$x \\geq 0, y \\geq 0, x + y \\leq 5, x + 2y \\geq 8$ শর্তানুসারে $z = 2x - y$ এর সর্বনিম্ন মান-	mathematics	linear_programming	D	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
eb443241-a0e6-419c-9b43-9c2b638a0d79	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	21	$\\vec{a} = \\hat{i} + 2\\hat{j} - 3\\hat{k}$ এবং $\\vec{b} = 3\\hat{i} - \\hat{j} + 2\\hat{k}$ হলে, নিম্নের কোনটি সত্য?	mathematics	vectors	C	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
f3fd98df-40b0-4dc2-a6b7-423b3130671c	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	22	$(-4, 3)$ এবং $(12, -1)$ বিন্দুদ্বয়ের সংযোগ রেখাংশকে ব্যাস ধরে অঙ্কিত বৃত্তের সমীকরণ-	mathematics	circles	D	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
ef9f39c1-8a27-4472-a265-1705ec549c3a	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	23	6 জন বালক এবং 5 জন বালিকার একটি দল থেকে কত উপায়ে 3 জন বালক এবং 2 জন বালিকার একটি দল গঠন করা যেতে পারে-	mathematics	permutations_and_combinations	D	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
d8b127a1-4e4c-4125-a55f-2b39cec54c6f	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	24	এককের একটি কাল্পনিক ঘনমূল $\\omega$ হলে, $(1 - \\omega)(1 - \\omega^2)(1 - \\omega^4)(1 - \\omega^8)$ এর মান কত?	mathematics	complex_numbers	C	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
06d590b9-a4b4-435d-80d2-e00892d57ee2	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	25	$y = \\frac{1}{\\sqrt{4 - x}}$ ফাংশনটির ডোমেইন এবং রেঞ্জ-	mathematics	functions_and_graphs	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
7d7ecf56-2a4c-4c75-821e-a8442b60bd53	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	26	$(x - 2)^2 + (y - 3)^2 = 16$ এবং $(x - 2)^2 + (y - 10)^2 = 9$ বৃত্তদ্বয়ের স্পর্শবিন্দুর স্থানাঙ্ক-	mathematics	circles	D	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
8c9b0948-331e-4bf9-b380-79f3b91f4035	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	27	$z = 1 - \\frac{i}{1 - \\frac{1}{1 + i}}$ জটিল সংখ্যাটির মডুলাস ও আর্গুমেন্ট-	mathematics	complex_numbers	D	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
3b282d93-6894-4dd4-be9a-097db02400fa	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	28	$-7 < x < -1$ কে পরমমানের সাহায্যে লিখলে দাঁড়ায়-	mathematics	real_numbers_and_inequalities	C	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
a87b01e9-3ec3-41cf-92da-517b413d3aa6	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	29	ABC একটি সমকোণী ত্রিভুজ হলে, $\\cos^2 A + \\cos^2 B + \\cos^2 C = ?$	mathematics	trigonometric_ratios	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
2577e578-d372-4932-b1f1-a963c8261dd1	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	30	$1 + (1 + 2) + (1 + 2 + 3) + \\dots + n$ তম পদ পর্যন্ত =?	mathematics	binomial_expansion	C	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
36e5af15-9705-415b-85bf-31b806740b80	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	01	লেমা ও প্যালিয়া কিসের অংশবিশেষ?	biology	gymnosperms_and_angiosperms	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
1ec0f453-a44c-44b3-89cd-6bdaea5ce980	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	02	কোষ বিভাজনের কোন পর্যায়ে বাইভ্যালেন্ট সংঘটিত হয়?	biology	cell_division	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
3dbf509d-5a9a-42d9-96c3-65b09b7f4f65	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	03	কোন প্রাণিকুলের তিন জোড়া বক্ষদেশীয় পা ও একজোড়া শুঙ্গ আছে?	biology	animal_diversity_and_classification	D	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
98fa0cdb-db98-4516-b6a9-5b0a4cd7fe31	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	04	হাইড্রার দ্রুত চলন প্রক্রিয়ার নাম কি?	biology	animal_identity	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
a8176b61-70e6-4a44-8927-2e0e940205cd	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	05	অস্থি যে আবরণ দ্বারা আবৃত থাকে-	biology	human_physiology_locomotion_and_movement	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
f7217c62-ca80-447d-9def-5918cec789b8	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	06	'O' রক্ত গ্রুপের বৈশিষ্ট্য কোনটি?	biology	human_physiology_blood_and_circulation	D	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
498ae4f4-1af9-4c0a-858c-42b6f4776e99	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	07	কোনটি দ্বৈত প্রচ্ছন্ন এপিস্ট্যাসিস?	biology	genetics_and_evolution	D	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
edeec63f-3598-40e4-a76b-20026bd38e6f	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	08	'অরিজিন অব স্পেসিস্ বাই মিনস অব ন্যাচারাল সিলেকশান' বইটি কত সালে প্রকাশিত হয়?	biology	genetics_and_evolution	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
9f25db43-7419-4324-9f10-10513c923a31	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	09	হিমোসিল কোন প্রাণীতে দেখা যায়?	biology	animal_identity	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
63aaf4d9-ee45-4153-8dde-3b0af400b968	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	10	মুখ গহ্বরে কোন খাদ্যটির আংশিক পরিপাক ঘটে?	biology	human_physiology_digestion_and_absorption	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
c517231f-41c8-4e37-9389-fbbec3adad17	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	11	রক্ষীকোষ কোনটির অংশ?	biology	tissue_and_tissue_system	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
ea03d5f3-88ce-4d02-9bcf-3737e9b9be25	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	12	গ্লাইকোলাইসিস প্রক্রিয়ায় কতটা ATP খরচ হয়?	biology	plant_physiology	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
ca1083be-b2b5-473c-b3dc-7325603180bb	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	13	কোনটি রোধ করার জন্য পুষ্পে ইমাসকুলেশন প্রয়োজন হয়?	biology	plant_reproduction	C	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
3169f68f-ec7b-4989-8244-d96ed5b3c99c	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	14	কোন খনিজ লবণের অভাবে গাছের পাতা ও ফুল ঝরে পড়ে?	biology	plant_physiology	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
57d1b1a7-ab09-42b4-812f-bd9ba0173801	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	15	মানুষের করোটিক স্নায়ুর সংখ্যা কয়টি?	biology	human_physiology_coordination_and_control	D	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
79fc02c9-79b0-47dd-8ee9-71365ef709cb	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	16	নিচের কোনটিতে হোল্ডফাস্ট আছে?	biology	algae_and_fungi	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
7bacb6f5-4157-4154-8fd2-6d7261e40013	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	17	কোনটি Riccia-র বৈশিষ্ট্য নয়?	biology	bryophyta_and_pteridophyta	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
4e0281ab-153b-477c-b6da-d2e84b39c456	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	18	Cry1Ac জিনের উৎস কোনটি?	biology	biotechnology	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
421ea082-a221-472e-80ea-f7dd9eac7001	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	19	নিচের কোনটি মরু উদ্ভিদ?	biology	gymnosperms_and_angiosperms	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
46c6faa7-10cd-4eb0-ad3a-bc90abe4ce6a	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	20	কোষ নামকরণ করেন-	biology	cell_and_its_structure	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
4aa70cdc-5e9c-4837-86bc-b14a9fedc56f	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	21	নিচের কোনটি ক্রিস্টি ধারণ করে?	biology	cell_and_its_structure	D	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
d3611d76-989c-4d17-ae58-6d2259a20e9b	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	22	নিচের কোনটিতে অ্যান্টিকোডন পাওয়া যায়?	biology	cell_and_its_structure	C	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
ae7cab33-73af-4c6e-82e0-b9b1d817e6c3	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	23	নিচের কোনটি ডাইস্যাকারাইড?	biology	cell_chemistry	C	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
294554a8-a348-4257-9e51-c30b30876435	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	24	নিচের কোন উদ্ভিদটি বিলুপ্তপ্রায়?	biology	environment_expansion_and_conservation_of_organisms	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
73cba5b2-f4e0-4498-8fa2-6fa6de8c3caa	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	25	অসমোরেগুলেশন মানবদেহের কোন অঙ্গের মাধ্যমে হয়ে থাকে?	biology	human_physiology_waste_and_excretion	C	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
0c1935b9-a0b7-4203-8df2-d82f06aa21ea	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	26	ভ্যাক্সিন বা টিকা কে আবিষ্কার করেন?	biology	microorganisms	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
d8c1eb85-f71b-49aa-9e63-c7ea75d06097	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	27	কোন অস্থিতে গ্লেনয়েড গহ্বর থাকে?	biology	human_physiology_locomotion_and_movement	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
1a19b128-3a4e-4b9f-a10e-fb4d1997d584	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	28	মানবদেহের ভারসাম্য রক্ষায় কর্ণের কোন অংশটি সম্পৃক্ত?	biology	human_physiology_coordination_and_control	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
8ce61a29-e36b-494f-b4f3-a38b28373425	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	29	নিচের কোন হরমোনটি মানুষের ডিম্বাশয় থেকে নিঃসৃত হয়?	biology	human_physiology_coordination_and_control	B	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
1a7e5863-9b1b-432c-9ea2-5eb346823307	2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	30	কোন প্রাণীটি শুধুমাত্র ওরিয়েন্টাল অঞ্চলে পাওয়া যায়?	biology	animal_diversity_and_classification	A	\N	pending	2026-04-27 17:34:47.206478+00	Dhaka University	2015-2016	A	null	\N	\N
42ed3074-0269-4669-9f60-ed38853ba85a	56229cbd-4fab-4246-8461-c24189194ed2	16	দশমিক সংখ্যা $368$ এর বাইনারীতে পরিবর্তিত সংখ্যাটি হবে -	physics	semiconductor_and_electronics	A	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	দশমিক সংখ্যা $368$ কে বাইনারীতে রূপান্তর করতে, আমরা সংখ্যাটিকে পর্যায়ক্রমে $2$ দ্বারা ভাগ করি এবং ভাগশেষগুলি রেকর্ড করি। ভাগফল শূন্য না হওয়া পর্যন্ত এই প্রক্রিয়া চলতে থাকে।\n$368 \\div 2 = 184$ (ভাগশেষ $0$)\n$184 \\div 2 = 92$ (ভাগশেষ $0$)\n$92 \\div 2 = 46$ (ভাগশেষ $0$)\n$46 \\div 2 = 23$ (ভাগশেষ $0$)\n$23 \\div 2 = 11$ (ভাগশেষ $1$)\n$11 \\div 2 = 5$ (ভাগশেষ $1$)\n$5 \\div 2 = 2$ (ভাগশেষ $1$)\n$2 \\div 2 = 1$ (ভাগশেষ $0$)\n$1 \\div 2 = 0$ (ভাগশেষ $1$)\nভাগশেষগুলি নিচ থেকে উপরে সাজিয়ে পাই: $(101110000)_2$।	A
461e205a-bb8a-4bdd-81fb-f8a21d854215	56229cbd-4fab-4246-8461-c24189194ed2	11	নিচের কোন তড়িৎ-চুম্বকীয় বিকিরণের কম্পাঙ্ক সবচেয়ে কম?	physics	physical_optics	B	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	তড়িৎ-চুম্বকীয় বর্ণালীতে, কম্পাঙ্ক (frequency) এবং তরঙ্গদৈর্ঘ্য (wavelength) একে অপরের ব্যস্তানুপাতিক। কম্পাঙ্কের ক্রম অনুসারে, সর্বনিম্ন থেকে সর্বোচ্চ পর্যন্ত বিকিরণগুলি হলো: রেডিও তরঙ্গ, মাইক্রোওয়েভ, অবলোহিত রশ্মি, দৃশ্যমান আলো, অতিবেগুনি রশ্মি, এক্স-রে এবং গামা রশ্মি। প্রদত্ত বিকল্পগুলির মধ্যে, গামা রশ্মির কম্পাঙ্ক সর্বোচ্চ, এরপর এক্স-রে, তারপর অতিবেগুনি রশ্মি। অবলোহিত রশ্মির কম্পাঙ্ক এই তিনটির চেয়ে কম। সুতরাং, অবলোহিত রশ্মির কম্পাঙ্ক সবচেয়ে কম।	B
4b3fd082-8394-4ecc-afda-a36b07d05658	56229cbd-4fab-4246-8461-c24189194ed2	08	$127^{\\circ}\\text{C}$ এবং $27^{\\circ}\\text{C}$ তাপমাত্রার মধ্যে কর্মরত একটি কার্নো ইঞ্জিনের কর্মদক্ষতা কত?	physics	thermodynamics	B	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	কার্নো ইঞ্জিনের কর্মদক্ষতা নির্ণয়ের সূত্র হলো $\\eta = 1 - \\frac{T_C}{T_H}$, যেখানে $T_H$ হলো উষ্ণ উৎসের তাপমাত্রা এবং $T_C$ হলো শীতল উৎসের তাপমাত্রা, উভয়ই কেলভিন স্কেলে। প্রদত্ত তাপমাত্রাগুলিকে কেলভিনে রূপান্তর করি: $T_H = 127^{\\circ}\\text{C} + 273 = 400\\,\\text{K}$ এবং $T_C = 27^{\\circ}\\text{C} + 273 = 300\\,\\text{K}$। এখন কর্মদক্ষতা গণনা করি: $\\eta = 1 - \\frac{300\\,\\text{K}}{400\\,\\text{K}} = 1 - \\frac{3}{4} = \\frac{1}{4}$। শতকরায় প্রকাশ করলে, $\\eta = \\frac{1}{4} \\times 100\\% = 25\\%$।	B
8af36a16-997a-4f49-8622-77c5f80334df	56229cbd-4fab-4246-8461-c24189194ed2	01	নিচের কোনটি মৌলিক একক?	physics	physical_world_and_measurement	B	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	মৌলিক একক হলো সেইসব একক যা অন্য কোনো এককের উপর নির্ভরশীল নয় এবং যা থেকে অন্যান্য লব্ধ একক গঠিত হয়। আন্তর্জাতিক একক পদ্ধতি (SI) অনুযায়ী, ৭টি মৌলিক একক রয়েছে: মিটার, কিলোগ্রাম, সেকেন্ড, অ্যাম্পিয়ার, কেলভিন, মোল এবং ক্যান্ডেলা। প্রদত্ত বিকল্পগুলোর মধ্যে, (A) কুলম্ব হলো চার্জের একক ($C = A \times s$), (C) ভোল্ট হলো বিভব পার্থক্যের একক ($V = J/C$), এবং (D) ওহম হলো রোধের একক ($\\Omega = V/A$)। শুধুমাত্র (B) অ্যাম্পিয়ার (Ampere) হলো তড়িৎ প্রবাহের মৌলিক একক।	B
9c09af5e-a1c7-4691-9711-b9cd745d9753	56229cbd-4fab-4246-8461-c24189194ed2	29	বেগ হচ্ছে -	physics	dynamics	C	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	বেগ ($v$) হলো সরণের পরিবর্তনের হার। গাণিতিকভাবে, এটি সরণ ($x$) কে সময় ($t$) এর সাপেক্ষে অন্তরীকরণ করে পাওয়া যায়, অর্থাৎ $v = \\frac{dx}{dt}$। একটি সরণ-সময় লেখচিত্রের ঢালও $\\frac{\\Delta x}{\\Delta t}$ দ্বারা প্রকাশ করা হয়, যা বেগকে নির্দেশ করে। সুতরাং, সরণ-সময় লেখচিত্রের ঢালই বেগ।	C
e1f38048-f857-424d-bbec-4cfa15494f9c	56229cbd-4fab-4246-8461-c24189194ed2	23	শূন্য মাধ্যমে দুইটি ইলেকট্রনের মধ্যকার কুলম্ব বল $F_E$ এবং মহাকর্ষ বল $F_G$ এর অনুপাত হবে?	physics	static_electricity	C	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	দুটি ইলেকট্রনের মধ্যকার কুলম্ব বল ($F_E$) এবং মহাকর্ষ বল ($F_G$) এর অনুপাত নির্ণয় করতে হবে। কুলম্ব বলের সূত্র হলো $F_E = k \\frac{e^2}{r^2}$ এবং মহাকর্ষ বলের সূত্র হলো $F_G = G \\frac{m_e^2}{r^2}$, যেখানে $e$ ইলেকট্রনের চার্জ, $m_e$ ইলেকট্রনের ভর, $r$ তাদের মধ্যবর্তী দূরত্ব, $k$ কুলম্ব ধ্রুবক এবং $G$ মহাকর্ষ ধ্রুবক।\n\nঅনুপাতটি হবে:\n$$ \\frac{F_E}{F_G} = \\frac{k e^2 / r^2}{G m_e^2 / r^2} = \\frac{k e^2}{G m_e^2} $$\n\nপ্রয়োজনীয় ধ্রুবকগুলির মান হলো:\n$e = 1.602 \\times 10^{-19}\\,\\text{C}$\n$m_e = 9.109 \\times 10^{-31}\\,\\text{kg}$\n$k = 8.9875 \\times 10^9\\,\\text{N}\\cdot\\text{m}^2/\\text{C}^2$\n$G = 6.674 \\times 10^{-11}\\,\\text{N}\\cdot\\text{m}^2/\\text{kg}^2$\n\nমানগুলি প্রতিস্থাপন করে পাই:\n$$ \\frac{F_E}{F_G} = \\frac{(8.9875 \\times 10^9) \\times (1.602 \\times 10^{-19})^2}{(6.674 \\times 10^{-11}) \\times (9.109 \\times 10^{-31})^2} $$\n$$ \\frac{F_E}{F_G} = \\frac{8.9875 \\times 10^9 \\times 2.5664 \\times 10^{-38}}{6.674 \\times 10^{-11} \\times 82.9738 \\times 10^{-62}} $$\n$$ \\frac{F_E}{F_G} = \\frac{23.06 \\times 10^{-29}}{553.7 \\times 10^{-73}} = \\frac{23.06}{553.7} \\times 10^{44} \\approx 0.04164 \\times 10^{44} \\approx 4.164 \\times 10^{42} $$\n\nএটি $4.2 \\times 10^{42}$ এর খুব কাছাকাছি।	C
e7e5c15d-593a-41f6-a631-17cee6c3d6e2	56229cbd-4fab-4246-8461-c24189194ed2	18	যদি $\\vec{A} = 2\\hat{i} + a\\hat{j} + \\hat{k}$ এবং $\\vec{B} = -2\\hat{i} + \\hat{j} - 2\\hat{k}$ পরস্পর লম্ব হয় তবে $a$ এর মান হবে-	physics	vector	C	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	দুটি ভেক্টর $\\vec{A}$ এবং $\\vec{B}$ পরস্পর লম্ব হলে তাদের ডট গুণফল শূন্য হয়, অর্থাৎ $\\vec{A} \\cdot \\vec{B} = 0$। প্রদত্ত ভেক্টর দুটি হলো $\\vec{A} = 2\\hat{i} + a\\hat{j} + \\hat{k}$ এবং $\\vec{B} = -2\\hat{i} + \\hat{j} - 2\\hat{k}$। এদের ডট গুণফল নির্ণয় করি: $$(2)(-2) + (a)(1) + (1)(-2) = 0$$ $$-4 + a - 2 = 0$$ $$a - 6 = 0$$ অতএব, $a = 6$।	C
a01b5c95-1c9e-4319-b48f-90743f87f68c	56229cbd-4fab-4246-8461-c24189194ed2	24	কোনো তেজস্ক্রিয় মৌলের ক্ষয় ধ্রুবকের মান $0.01/\\text{s}$। এর অর্ধায়ু -	physics	atomic_model_and_nuclear_physics	C	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	তেজস্ক্রিয় মৌলের অর্ধায়ু ($T_{1/2}$) এবং ক্ষয় ধ্রুবক ($\\lambda$) এর মধ্যে সম্পর্কটি হলো $T_{1/2} = \\frac{\\ln(2)}{\\lambda}$। এখানে, ক্ষয় ধ্রুবকের মান $\\lambda = 0.01/\\text{s}$। আমরা জানি $\\ln(2) \\approx 0.693$। মানগুলো সূত্রে বসিয়ে পাই, $T_{1/2} = \\frac{0.693}{0.01/\\text{s}} = 69.3\\,\\text{s}$।	C
bd780c4e-1e12-4891-a7a0-e6a61eed1456	56229cbd-4fab-4246-8461-c24189194ed2	19	মহাকর্ষীয় ধ্রুবকের মাত্রা হলো -	physics	gravitation_and_gravity	B	\N	generated	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	মহাকর্ষীয় ধ্রুবক $G$-এর মাত্রা নির্ণয় করতে, আমরা নিউটনের মহাকর্ষ সূত্র ব্যবহার করি: $F = G \\frac{m_1 m_2}{r^2}$। এই সূত্র থেকে $G$-কে প্রকাশ করলে পাই: $G = \\frac{F r^2}{m_1 m_2}$। এখন, প্রতিটি রাশির মাত্রা বসাই: বলের মাত্রা $[F] = [MLT^{-2}]$, দূরত্বের মাত্রা $[r] = [L]$ (সুতরাং $[r^2] = [L^2]$), এবং ভরের মাত্রা $[m] = [M]$ (সুতরাং $[m_1 m_2] = [M^2]$)। এই মাত্রাগুলো প্রতিস্থাপন করে পাই: $[G] = \\frac{[MLT^{-2}] [L^2]}{[M^2]} = [M^{1-2}L^{1+2}T^{-2}] = [M^{-1}L^3T^{-2}]$।	B
bd60af41-e47f-4b2f-b7a4-98ef83b9084d	56229cbd-4fab-4246-8461-c24189194ed2	01.	নিচের কোন আয়নটির জলীয় দ্রবণ বর্ণহীন?	chemistry	periodic_properties_of_elements_and_chemical_bonding	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
816bbb35-34a6-4bae-baec-e4e2c5eeb8a6	56229cbd-4fab-4246-8461-c24189194ed2	02.	ক্লোরোপিক্রিন এর রাসায়নিক সংকেত কী?	chemistry	organic_chemistry	C	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
c4cc621e-d237-415f-9ea9-f8bb51f40fe8	56229cbd-4fab-4246-8461-c24189194ed2	03.	ফ্রি র‍্যাডিক্যালের ক্ষেত্রে কোনটি সত্য নয়?	chemistry	organic_chemistry	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
07e159ce-c75d-4515-aa66-29e1c860d3f4	56229cbd-4fab-4246-8461-c24189194ed2	04.	$26$ আণবিক সংখ্যাবিশিষ্ট একটি মৌলের M-শেলে ইলেকট্রনের সংখ্যা -	chemistry	qualitative_chemistry	C	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
2c305db3-16c3-4530-a455-8f9db42746ed	56229cbd-4fab-4246-8461-c24189194ed2	05.	কোনটি $\\ce{A + 2B -> P}$ বিক্রিয়াটির সঠিক হার-সমীকরণ নির্দেশ করে?	chemistry	chemical_changes	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
9257ad0d-f357-442a-8e42-1580316a87fa	56229cbd-4fab-4246-8461-c24189194ed2	06.	$\\ce{HCHO}$ ও $\\ce{CH3CHO}$ এর মধ্যে পার্থক্য করার জন্য প্রয়োজন -	chemistry	organic_chemistry	A	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
4f25ecab-439f-4260-a0f2-64396678d17d	56229cbd-4fab-4246-8461-c24189194ed2	07.	কোন যৌগটিতে একের অধিক ধরনের সংকরিত কার্বন আছে?	chemistry	organic_chemistry	C	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
664bc991-eece-45c1-8784-3f14656648a8	56229cbd-4fab-4246-8461-c24189194ed2	08.	বেনজামাইডের হফম্যান ক্ষুদ্রাংশকরণ বিক্রিয়ার উৎপাদ কি?	chemistry	organic_chemistry	A	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
e08fd6ff-3066-48f6-b9ce-d3bd8c01f09d	56229cbd-4fab-4246-8461-c24189194ed2	09.	কোনটি পর্যায় ধর্ম নয়?	chemistry	periodic_properties_of_elements_and_chemical_bonding	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
89dfebc4-65e9-4c03-bba7-d48a9dc5a24f	56229cbd-4fab-4246-8461-c24189194ed2	10.	$\\ce{3Fe(s) + 4H2O(g) <=> 4H2(g) + Fe3O4(s); ΔH = 35 kJ/mol}$ বিক্রিয়াটি সাম্যাবস্থায় আছে। চাপ বাড়ালে কি ঘটবে?	chemistry	chemical_changes	C	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
72a404da-1b6a-4d45-9af7-fdcdf2bcaa68	56229cbd-4fab-4246-8461-c24189194ed2	11.	ইথাইল আয়োডাইড জলীয় $\\ce{KOH}$ এর সাথে বিক্রিয়ায় উৎপন্ন হয় -	chemistry	organic_chemistry	C	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
83765096-e851-4699-a569-2839fc554f77	56229cbd-4fab-4246-8461-c24189194ed2	12.	PVC এর উপাদান কোনটি?	chemistry	organic_chemistry	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
c6f32376-7456-450a-a70d-c767370577b4	56229cbd-4fab-4246-8461-c24189194ed2	13.	অপরিশোধিত পেট্রোলিয়াম বিশোধনে যে প্রক্রিয়া অধিক কার্যকর -	chemistry	vocational_chemistry	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
f2267763-fb03-42a3-894c-b9854e737e1f	56229cbd-4fab-4246-8461-c24189194ed2	14.	$10\\,\\text{mL } 0.1\\,\\text{M HCl}$ দ্রবণে $5\\,\\text{mL } 0.1\\,\\text{M NaOH}$ দ্রবণ যোগ করলে যে আয়নগুলো থাকার সম্ভাবনা -	chemistry	quantitative_chemistry	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
413d4cdd-6355-419d-8748-b74dc8d6e47a	56229cbd-4fab-4246-8461-c24189194ed2	15.	$4$ সন্নিবেশ সংখ্যাবিশিষ্ট জটিল যৌগটি হলো -	chemistry	periodic_properties_of_elements_and_chemical_bonding	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
a1f16c35-2a65-4030-962a-ecaf97d66c2f	56229cbd-4fab-4246-8461-c24189194ed2	16	মাটির pH বাড়াতে ব্যবহৃত যৌগটি হলো -	chemistry	environmental_chemistry	C	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
51763612-673d-4149-9e59-850e3835a7e0	56229cbd-4fab-4246-8461-c24189194ed2	17	কার্বিলঅ্যামিন পরীক্ষার মাধ্যমে কোন ধরনের জৈব যৌগ শনাক্ত করা যায়?	chemistry	organic_chemistry	A	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
0ee5ddf0-213f-422f-8bef-a7da9d44352f	56229cbd-4fab-4246-8461-c24189194ed2	18	কী অবস্থায় বাস্তব গ্যাস আদর্শ গ্যাস সমীকরণ অনুসরণ করে?	chemistry	ideal_gas_and_gas_kinetics	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
d721f23e-f8af-405e-8f83-34378a70d728	56229cbd-4fab-4246-8461-c24189194ed2	19	IR বর্ণালীতে $\\ce{-OH}$ এবং $\\ce{>C=O}$ কার্যকরী মূলকগুলো কোন তরঙ্গসংখ্যায় শোষণ করে?	chemistry	qualitative_chemistry	A	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
49bfe20a-d222-4189-b848-04925f7086a7	56229cbd-4fab-4246-8461-c24189194ed2	20	তরল অবস্থায় পরিবর্তিত না হয়ে কঠিন অবস্থা থেকে সরাসরি গ্যাসীয় অবস্থায় রূপান্তরিত হওয়ার পদ্ধতিকে বলে -	chemistry	qualitative_chemistry	A	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
9bfa121a-95a9-4f33-a552-48f13675a94b	56229cbd-4fab-4246-8461-c24189194ed2	21	মুক্ত শিকল কাঠামোরুক্ত গ্লুকোজ অণুতে কয়টি সেকেন্ডারি অ্যালকোহলীয় গ্রুপ আছে?	chemistry	organic_chemistry	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
26dfe77c-efc3-4080-963d-cf32abdb13b6	56229cbd-4fab-4246-8461-c24189194ed2	22	কোন বিক্রিয়ার ঘনমাত্রা-সময় লেখচিত্র অন্যগুলো থেকে আলাদা?	chemistry	chemical_changes	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "graph", "box_2d": null, "filename": null, "markdown": null, "page_index": 3, "caption_hint": "১. শূন্য ক্রম", "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2016-2017-A-Unit/page_4", "extraction_status": "needs_review"}, {"id": "IMAGE_2", "kind": "diagram", "label": "graph", "box_2d": null, "filename": null, "markdown": null, "page_index": 3, "caption_hint": "২. ১ম ক্রম", "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2016-2017-A-Unit/page_4", "extraction_status": "needs_review"}, {"id": "IMAGE_3", "kind": "diagram", "label": "graph", "box_2d": null, "filename": null, "markdown": null, "page_index": 3, "caption_hint": "৩. ২য় ক্রম", "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2016-2017-A-Unit/page_4", "extraction_status": "needs_review"}]	\N	\N
07ac1fdd-07d6-48fe-a989-0981f110d6f3	56229cbd-4fab-4246-8461-c24189194ed2	23	$0.01\\,\\text{M HCl}$ দ্রবণের pOH এবং pH হলো-	chemistry	quantitative_chemistry	C	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
1751398b-f5bb-46c5-b484-2513d8290a3d	56229cbd-4fab-4246-8461-c24189194ed2	24	নিচের কোনটি ঠিক তাপীয় বিয়োজন ক্রম?	chemistry	periodic_properties_of_elements_and_chemical_bonding	C	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
94483e8c-3caa-435f-b8a6-427ab98d5223	56229cbd-4fab-4246-8461-c24189194ed2	25	নিচের কোন এসিডের $K_a$ এর মান সবচেয়ে বেশী?	chemistry	chemical_changes	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
d3bb3752-0477-4cb2-9469-31c3bfeb8775	56229cbd-4fab-4246-8461-c24189194ed2	26	গ্যাসের ঘনত্ব মাপতে ব্যবহৃত হয়-	chemistry	ideal_gas_and_gas_kinetics	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
75971f6b-4db1-4a85-bb4c-348f436bd47a	56229cbd-4fab-4246-8461-c24189194ed2	27	ইথাইল অ্যালকোহল ঘন $\\ce{H2SO4}$ এর সাথে উত্তপ্ত করা হলো। উৎপন্ন উৎপাদ হলো-	chemistry	organic_chemistry	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
28e0109a-abc4-410f-98df-7b0ab3e06b62	56229cbd-4fab-4246-8461-c24189194ed2	28	$5\\,\\text{L } 0.1\\,\\text{M}$ দ্রবণ তৈরি করতে কী পরিমাণ $\\ce{Na2CO3}$ প্রয়োজন?	chemistry	quantitative_chemistry	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
a1216396-dd21-4d46-b6d9-5f9baa33c0ad	56229cbd-4fab-4246-8461-c24189194ed2	29	উদ্ভিদ মূলের সাহায্যে ইউরিয়া সার কী অবস্থায় শোষণ করে?	chemistry	economic_chemistry	C	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
73025035-d12c-4dd3-a548-a066ef26a300	56229cbd-4fab-4246-8461-c24189194ed2	01.	$5x - 7y - 15 = 0$ সরলরেখার উপর লম্ব এবং $(2, -3)$ বিন্দুগামী সরলরেখার সমীকরণ হবে-	mathematics	straight_lines	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
14495dd6-f4c8-48c2-9cea-e1f1c93b92a8	56229cbd-4fab-4246-8461-c24189194ed2	02.	$2x + 3y - 4 = 0$ এবং $x \\cos\\alpha + y \\sin\\alpha = P$ একই সরলরেখা নির্দেশ করলে $P$ এর মান-	mathematics	straight_lines	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
76343b23-ae51-4c07-9734-a17b5fb17fa4	56229cbd-4fab-4246-8461-c24189194ed2	03.	$x = a$ এবং $\\sqrt{3}x - y + 1 = 0$ রেখাদ্বয়ের মধ্যবর্তী সূক্ষ্মকোণের মান-	mathematics	straight_lines	A	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
91f2907b-13de-4f68-89c3-26664aff072b	56229cbd-4fab-4246-8461-c24189194ed2	04.	সমাধান কর: $\\sec^2\\theta + \\tan^2\\theta = \\frac{5}{3}, 0 < \\theta < \\pi$	mathematics	inverse_trigonometric_functions_and_trigonometric_equations	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
fcbfeb79-7f9b-4168-a154-8268ad3ffaaf	56229cbd-4fab-4246-8461-c24189194ed2	05.	$4x^2 + y^2 = 2$ উপবৃত্তটির বৃহৎ ও ক্ষুদ্র অক্ষের দৈর্ঘ্য যথাক্রমে-	mathematics	conics	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
1fbc98e0-4c41-4d0b-bcf3-b78ba3170441	56229cbd-4fab-4246-8461-c24189194ed2	06.	$\\lim_{x \\to 0} \\frac{e^{\\cos x}}{\\cos x}$ এর মান-	mathematics	differential_calculus	A	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
278a11e6-e51a-4147-ab85-5b33145c4b4f	56229cbd-4fab-4246-8461-c24189194ed2	07.	$\\int_1^4 f(x) dx = 5$ হলে, $\\int_0^1 f(3x + 1) dx$ এর মান-	mathematics	integral_calculus	C	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
e73a39b5-852e-4ff6-941c-17bf84b210d2	56229cbd-4fab-4246-8461-c24189194ed2	08.	$y = x, y = 0$ রেখাদ্বয় এবং $x^2 + y^2 = 16$ বৃত্ত দ্বারা প্রথম চতুর্ভাগে আবদ্ধ ক্ষেত্রের ক্ষেত্রফল-	mathematics	integral_calculus	A	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "geometry_figure", "box_2d": null, "filename": null, "markdown": null, "page_index": 4, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2016-2017-A-Unit/page_5", "extraction_status": "needs_review"}]	\N	\N
6fb6e116-0fd3-471d-ba3c-ba45510a024b	56229cbd-4fab-4246-8461-c24189194ed2	09.	$x$ এর কোন মানের জন্য $y = x + \\frac{1}{x}$ বক্ররেখাটির ঢাল শূন্য হবে?	mathematics	differential_calculus	C	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
4592e698-0afb-4d68-9d5b-4ff5996e72c0	56229cbd-4fab-4246-8461-c24189194ed2	10.	$y^2 + 4x + 2y - 8 = 0$ পরাবৃত্তের শীর্ষবিন্দু হবে-	mathematics	conics	A	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
b719be80-d9d9-4ab9-ac30-4f9ffb9e75f4	56229cbd-4fab-4246-8461-c24189194ed2	11.	যদি $y = \\sin^{-1}(\\sin x)$ হয়, তবে $\\frac{dy}{dx}$ হবে-	mathematics	differential_calculus	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
c58cb579-ea91-40a0-9671-5caff7d789c3	56229cbd-4fab-4246-8461-c24189194ed2	12	$3x^3 - 1 = 0$ এর মূলগুলো $\\alpha, \\beta, \\gamma$ হলে, $\\alpha^3 + \\beta^3 + \\gamma^3$ এর মান-	mathematics	polynomials_and_polynomial_equations	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
3c8324f4-f243-40a5-9cf7-c8f0400442c9	56229cbd-4fab-4246-8461-c24189194ed2	13	$\\frac{3x - 1}{(x + 1)(x^2 + 1)} = \\frac{A}{x + 1} + \\frac{Bx + 1}{x^2 + 1}$ অভেদে $(A, B)$ এর মান হবে-	mathematics	matrices_and_determinants	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
5a5757fc-54ec-42c9-8c7d-9e79e2b779ec	56229cbd-4fab-4246-8461-c24189194ed2	14	$y$ অক্ষকে $(0, 4)$ বিন্দুতে স্পর্শ করে এবং কেন্দ্র $5x - 7y - 2 = 0$ রেখার উপর অবস্থিত বৃত্তের সমীকরণ হবে-	mathematics	circles	C	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
822237e1-862f-4d85-aa99-278dca464bcc	56229cbd-4fab-4246-8461-c24189194ed2	15	$\\tan^{-1}(x + \\frac{1}{3}) + \\tan^{-1}(x - \\frac{1}{3}) = \\tan^{-1}2$ হলে, $x$ এর মান-	mathematics	inverse_trigonometric_functions_and_trigonometric_equations	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
3a8afe71-35fc-4592-a122-8d83a713e9e2	56229cbd-4fab-4246-8461-c24189194ed2	16	একটি সমবাহু ত্রিভুজের বাহুত্রয়ের সমান্তরালে একইক্রমে সমবিন্দুতে কার্যরত $6, 10, 14$ একক মানের তিনটি বেগের লব্ধির মান হবে-	mathematics	statics	A	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
3c7cac49-945e-475a-bcec-dd9baa98e4b4	56229cbd-4fab-4246-8461-c24189194ed2	17	$|x^2 + 1| < 10$ এর সমাধান-	mathematics	real_numbers_and_inequalities	A	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
53a06aa2-abf8-40e7-a48a-fe5ed88a006f	56229cbd-4fab-4246-8461-c24189194ed2	18	$\\sin(A - 30^\\circ) + \\sin(150^\\circ + A)$ এর মান-	mathematics	associated_trigonometric_angles	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
5b4a15e7-8b68-40a7-a5c1-9100079ec87e	56229cbd-4fab-4246-8461-c24189194ed2	19	$f(x) = \\sin x$ এবং $g(x) = x^2$ হলে, $(fog)\\left(\\frac{\\sqrt{\\pi}}{2}\\right)$ এর মান হবে -	mathematics	functions_and_graphs	A	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
14bc131c-3a3c-496c-947c-029d7c7f9c86	56229cbd-4fab-4246-8461-c24189194ed2	20	$\\vec{P} = 5\\hat{i} - 3\\hat{j} + 2\\hat{k}$ ভেক্টরের উপর $\\vec{Q} = 2\\hat{i} + \\hat{j} - 2\\hat{k}$ ভেক্টরের অভিক্ষেপ-	mathematics	vectors	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
494e26be-ddc6-46e8-8f85-02017a97a9a8	56229cbd-4fab-4246-8461-c24189194ed2	21	$32\\,\\text{ft/s}$ আদিবেগে এবং ভূমির সাথে $30^\\circ$ কোণে একটি বস্তু নিক্ষেপ করা হলো। ইহার ভ্রমণকাল-	mathematics	dynamics	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
9ad62dcb-36f2-4724-a79f-8a405e26a116	56229cbd-4fab-4246-8461-c24189194ed2	22	$z = x + iy$ হলে, $|z - 5| + |z + 5| = 16$ নির্দেশ করে-	mathematics	conics	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
35a4c577-4532-465c-9034-2e13b7aab087	56229cbd-4fab-4246-8461-c24189194ed2	23	$\\frac{1}{a + i} = \\frac{i}{a - i}$ হলে, $a$ এর মান -	mathematics	complex_numbers	C	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
96b1335d-6f4e-4999-897e-e9b5497af568	56229cbd-4fab-4246-8461-c24189194ed2	24	$(2x^2 - \\frac{1}{2x^3})^{10}$ এর বিস্তৃতিতে $x$ বর্জিত পদের মান -	mathematics	binomial_expansion	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
a9253795-0981-4530-836a-7708a2ae0b45	56229cbd-4fab-4246-8461-c24189194ed2	25	$1, 2, 0$ দ্বারা গঠিত তিন অঙ্কবিশিষ্ট সংখ্যাগুলোর মধ্যে কয়টি সংখ্যা $2$ দ্বারা বিভাজ্য?	mathematics	permutations_and_combinations	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
1434f64d-6b43-45c0-ab47-b89cad8465cc	56229cbd-4fab-4246-8461-c24189194ed2	26	'MATHEMATICS' শব্দটির বর্ণগুলোকে কত রকমে সাজানো যাবে যেখানে প্রথম ও শেষ স্থানে 'T' থাকবে?	mathematics	permutations_and_combinations	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
0bcd7650-c0f9-49fd-a011-7833c7b7bbd7	56229cbd-4fab-4246-8461-c24189194ed2	27	$A = \\{1, 2, 3, 5, 9\\}$ এবং $B = \\{1, 2, 9, 10\\}$ হলে, $(A \\setminus B) \\cup (B \\setminus A)$ এর সমান হবে -	mathematics	null	C	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
69ccb9cd-13f7-4e9a-acf2-88c246e38c07	56229cbd-4fab-4246-8461-c24189194ed2	28	$\\frac{1}{2}(e^x - e^{-x})$ ধারাটির বিস্তৃতি কি?	mathematics	null	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
a5484c83-9534-4ac5-b60c-eb8ce222ccf6	56229cbd-4fab-4246-8461-c24189194ed2	29	একটি বাক্সে $3$ টি লাল, $3$ টি সবুজ ও $2$ টি নীল বল আছে। দৈবভাবে $3$ টি বল তোলা হলে, $2$ টি বল সবুজ হবার সম্ভাবনা কত?	mathematics	measure_of_dispersion_and_probability	A	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
c34aa487-10b3-401a-9571-d771f69d09d8	56229cbd-4fab-4246-8461-c24189194ed2	30	যদি $9\\theta = \\pi$ হয়, তবে $\\cos\\theta \\cos2\\theta \\cos4\\theta$ এর মান-	mathematics	trigonometric_ratios	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
2d6c847e-a7b4-44c0-8392-a046d64740be	56229cbd-4fab-4246-8461-c24189194ed2	01	মাইটোসিস কোষ বিভাজনের কোন ধাপে নিউক্লিওলাস-এর বিলুপ্তি ঘটে?	biology	cell_division	A	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
fbb20a08-77e8-4cf1-8639-713fba6275e2	56229cbd-4fab-4246-8461-c24189194ed2	02	$C_4$ উদ্ভিদের প্রথম স্থায়ী পদার্থ কোনটি?	biology	plant_physiology	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
15c9bfc4-c6e6-474a-84b7-9ea57e556064	56229cbd-4fab-4246-8461-c24189194ed2	03	*Cucumis sativus* -এর প্লাসেন্টেশন কোন প্রকৃতির?	biology	gymnosperms_and_angiosperms	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
92005291-f426-4e0f-818c-48beef76042b	56229cbd-4fab-4246-8461-c24189194ed2	04	পাটের আঁশ কোন জাতীয় টিস্যু?	biology	tissue_and_tissue_system	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
e62596bd-c9e8-4dfd-8dd2-1e5cabb12725	56229cbd-4fab-4246-8461-c24189194ed2	05	নিচের কোনটি হ্যাপ্লয়েড পার্থেনোজেনেসিস-এর উদাহরণ?	biology	plant_reproduction	A	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
0b1c1d43-442e-46a7-81e3-a76cc54f365a	56229cbd-4fab-4246-8461-c24189194ed2	06.	3 PGA কোন প্রক্রিয়ার মাধ্যমে উৎপন্ন হয়?	biology	plant_physiology	C	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
bfe7b666-a851-4156-a5aa-dd164029ebf7	56229cbd-4fab-4246-8461-c24189194ed2	07.	কোনটি $Hydra$-তে থাকে না?	biology	animal_identity	C	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
89ac0c06-7b1c-4c99-a632-595114dbf986	56229cbd-4fab-4246-8461-c24189194ed2	08.	রুই মাছের বর্গের নাম হলো-	biology	animal_identity	A	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
6b3de2ef-eac7-49cf-b36a-382a09a64f19	56229cbd-4fab-4246-8461-c24189194ed2	09.	মানুষের অস্থির সাথে যে হরমোন জড়িত তা হলো-	biology	human_physiology_coordination_and_control	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
75138e12-93c2-4a7b-b86c-5c95a065bf15	56229cbd-4fab-4246-8461-c24189194ed2	10.	কোনটি মাছ নয়?	biology	animal_diversity_and_classification	C	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
f430ea32-c5dc-4851-9992-938cb2c77a2a	56229cbd-4fab-4246-8461-c24189194ed2	11.	ফুসফুস আবৃত থাকে যে পর্দা দ্বারা তাকে বলা হয়-	biology	human_physiology_breathing_and_respiration	C	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
485e6fce-a058-4ec1-a1fc-2bf1a110798f	56229cbd-4fab-4246-8461-c24189194ed2	12.	রক্ত জমাট বাঁধার জন্য কোনটির প্রয়োজন নাই?	biology	human_physiology_blood_and_circulation	C	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
8ccb80ce-de3b-47d8-8cc4-8e376cdfcd0c	56229cbd-4fab-4246-8461-c24189194ed2	13.	কোনটি সেক্স-লিঙ্কড বৈশিষ্ট্য?	biology	genetics_and_evolution	A	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
2ab9f2b5-9176-4e69-b582-e78328a8e2ff	56229cbd-4fab-4246-8461-c24189194ed2	14.	প্রবাল কোন পর্বভুক্ত?	biology	animal_diversity_and_classification	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
bbae0831-2f32-4d55-8561-e7ff7aa814e0	56229cbd-4fab-4246-8461-c24189194ed2	15.	কনড্রিকথিস শ্রেণিভুক্ত মাছে কোন ধরনের আঁইশ থাকে?	biology	animal_diversity_and_classification	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
db27080c-93bb-4bfe-a03a-b3613c0a0a36	56229cbd-4fab-4246-8461-c24189194ed2	16.	নিচের কোনটি আমাদেরকে রোগ প্রতিরোধে সাহায্য করে?	biology	immunity_of_human_body	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
66a8c37b-6490-45ab-9535-a35fb5cb3f53	56229cbd-4fab-4246-8461-c24189194ed2	17.	কখন নালিকা নিউক্লিয়াস উৎপন্ন হয়?	biology	plant_reproduction	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
605c3e67-1a2a-4601-97bd-e68935ea571b	56229cbd-4fab-4246-8461-c24189194ed2	18.	কোনটিতে জরায়ুজ অঙ্কুরোদগম হয়?	biology	gymnosperms_and_angiosperms	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
6de7115c-baac-48d1-aa68-abffed612b0e	56229cbd-4fab-4246-8461-c24189194ed2	19.	রাইজোফোর কোথা থেকে উৎপন্ন হয়?	biology	bryophyta_and_pteridophyta	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
f2c2eda6-7843-4e42-800a-9a11c06f8de1	56229cbd-4fab-4246-8461-c24189194ed2	20.	বাণিজ্যিকভাবে নিচের কোনটি থেকে পেনিসিলিন তৈরি হয়?	biology	microorganisms	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
c88b3891-ffae-4ade-975e-1fb05affc027	56229cbd-4fab-4246-8461-c24189194ed2	21	শ্বেতসার জাতীয় পদার্থ সঞ্চয়কারী লিউকোপ্লাস্ট কোনটি?	biology	cell_and_its_structure	A	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
a62032a1-d1cc-4736-8425-0f2e921f4fd7	56229cbd-4fab-4246-8461-c24189194ed2	22	নিচের কোনটিতে সি-ফাইকোসায়ানিন থাকে?	biology	algae_and_fungi	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
5daf662b-be0e-4354-b921-4a52bd745a0e	56229cbd-4fab-4246-8461-c24189194ed2	23	আলুর স্ক্যাব রোগ সৃষ্টিকারী অণুজীব কোনটি?	biology	microorganisms	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
f85f5472-7255-41ae-9f88-65f974586019	56229cbd-4fab-4246-8461-c24189194ed2	24	বাংলাদেশের জিএম ফসল বেগুনে কোন ব্যাকটেরিয়ার জিন যোগ করে পোকার আক্রমণ থেকে রক্ষা করেছে?	biology	biotechnology	C	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
f58574cb-2588-4cc8-90eb-356220619c91	56229cbd-4fab-4246-8461-c24189194ed2	25	কোন পদ্ধতিতে রোগমুক্ত উদ্ভিদ চারা উৎপাদন করা যায়?	biology	biotechnology	A	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
910ac715-d034-40c2-91de-40725ffa374c	56229cbd-4fab-4246-8461-c24189194ed2	26	নিচের কোনটি শুক্রাণু তৈরি করে?	biology	continuation_of_human_life	A	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
0f113169-736b-4c61-b902-5a2ef43f7b5e	56229cbd-4fab-4246-8461-c24189194ed2	27	'অর্গান অব কর্টি' যে অঙ্গে থাকে-	biology	human_physiology_coordination_and_control	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
89f71357-2e12-4d2a-927e-a1ef6b168558	56229cbd-4fab-4246-8461-c24189194ed2	28	গোদরোগ সৃষ্টিকারী পরজীবীর নাম-	biology	animal_identity	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
50abb947-d3a0-451e-8221-e6a2398017ce	56229cbd-4fab-4246-8461-c24189194ed2	29	রেনিন কোথায় তৈরি হয়?	biology	human_physiology_waste_and_excretion	D	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
a01533cf-6c59-45ee-83fa-f7418d8cc33b	56229cbd-4fab-4246-8461-c24189194ed2	30	বহুনিউক্লিয়াসযুক্ত ম্যালেরিয়া পরজীবীকে বলা হয়-	biology	microorganisms	B	\N	pending	2026-04-27 17:34:47.300026+00	Dhaka University	2016-2017	A	null	\N	\N
454c4c4e-a9c0-4349-9861-1d2394b1c495	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	08	স্বাভাবিক তাপমাত্রায় P-টাইপ অর্ধপরিবাহীর আধান পরিবাহী কোনটি?	physics	semiconductor_and_electronics	A	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	P-টাইপ অর্ধপরিবাহী তৈরি হয় যখন একটি বিশুদ্ধ অর্ধপরিবাহীকে ত্রিযোজী অপদ্রব্য দ্বারা ডোপ করা হয়। এই অপদ্রব্যগুলি স্ফটিক জালিতে 'হোল' তৈরি করে, যা ধনাত্মক আধান বহন করে। P-টাইপ অর্ধপরিবাহীতে হোলগুলি হল সংখ্যাগরিষ্ঠ আধান পরিবাহী এবং এগুলিই মূলত তড়িৎ পরিবহনের জন্য দায়ী। যদিও তাপীয় উদ্দীপনার কারণে কিছু ইলেকট্রন (সংখ্যালঘু আধান পরিবাহী) উপস্থিত থাকে, তবে P-টাইপ অর্ধপরিবাহীর বৈশিষ্ট্যগত আধান পরিবাহী হল হোল।	A
19e6c77e-9cfc-4eec-99c4-afdb0ba05ca5	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	03	$100^\\circ\\text{C}$ তাপমাত্রার $373\\,\\text{kg}$ পানিকে $100^\\circ\\text{C}$ তাপমাত্রার বাষ্পে পরিণত করা হলে, এনট্রপির পরিবর্তন হবে- [পানির বাষ্পীভবনের সুপ্ততাপ $= 2.26 \\times 10^6\\,\\text{J/kg}$]	physics	thermodynamics	A	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	এনট্রপির পরিবর্তন ($\\Delta S$) একটি ধ্রুব তাপমাত্রায় (যেমন, ফেজ পরিবর্তন) সংঘটিত হলে, এর সূত্র হলো $\\Delta S = \\frac{Q}{T}$, যেখানে $Q$ হলো শোষিত বা বর্জিত তাপ এবং $T$ হলো কেলভিন স্কেলে তাপমাত্রা।\nপ্রদত্ত মানগুলো হলো:\nপানির ভর, $m = 373\\,\\text{kg}$\nতাপমাত্রা, $T = 100^\\circ\\text{C} = (100 + 273)\\,\\text{K} = 373\\,\\text{K}$\nবাষ্পীভবনের সুপ্ততাপ, $L_v = 2.26 \\times 10^6\\,\\text{J/kg}$\n\nপ্রথমে, বাষ্পীভূত করতে প্রয়োজনীয় তাপ $Q$ নির্ণয় করি:\n$Q = m L_v = 373\\,\\text{kg} \\times 2.26 \\times 10^6\\,\\text{J/kg} = 843.98 \\times 10^6\\,\\text{J}$\n\nএখন, এনট্রপির পরিবর্তন নির্ণয় করি:\n$\\Delta S = \\frac{Q}{T} = \\frac{843.98 \\times 10^6\\,\\text{J}}{373\\,\\text{K}} = 2.26268 \\times 10^6\\,\\text{J/K}$\n\nযদি আমরা $T = 373\\,\\text{K}$ ব্যবহার করি, তাহলে সরাসরি:\n$\\Delta S = \\frac{m L_v}{T} = \\frac{373\\,\\text{kg} \\times 2.26 \\times 10^6\\,\\text{J/kg}}{373\\,\\text{K}} = 2.26 \\times 10^6\\,\\text{J/K}$\n\nএটি বিকল্প (A) এর সাথে মিলে যায়।	A
0b5f0817-9307-4039-a24b-2cad9cc12a35	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	15	যদি একটি সরল দোলকের বিস্তার দ্বিগুণ করা হয়, তাহলে সরল দোলকটির পর্যায়কাল-	physics	periodic_motion	D	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	একটি সরল দোলকের পর্যায়কালের সূত্র হলো $T = 2\\pi \\sqrt{\\frac{L}{g}}$, যেখানে $L$ হলো দোলকের কার্যকরী দৈর্ঘ্য এবং $g$ হলো অভিকর্ষজ ত্বরণ। এই সূত্রটি ছোট বিস্তারের (সাধারণত $10^\\circ$ থেকে $15^\\circ$ এর কম) জন্য প্রযোজ্য। সূত্র অনুযায়ী, পর্যায়কাল $T$ শুধুমাত্র দোলকের দৈর্ঘ্য $L$ এবং অভিকর্ষজ ত্বরণ $g$ এর উপর নির্ভরশীল, বিস্তারের উপর নয়। সুতরাং, যদি সরল দোলকের বিস্তার দ্বিগুণ করা হয় (এবং এটি ছোট বিস্তারের সীমার মধ্যে থাকে), তাহলে এর পর্যায়কাল অপরিবর্তিত থাকবে।	D
98043387-e7c4-4277-99f0-6815949e7288	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	10	শক্তির মাত্রা কী হবে?	physics	work_energy_and_power	D	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	শক্তির মাত্রা নির্ণয় করতে, আমরা কাজের মাত্রা ব্যবহার করতে পারি, কারণ কাজ এবং শক্তির মাত্রা একই। কাজ ($W$) হলো বল ($F$) এবং সরণ ($s$)-এর গুণফল, অর্থাৎ $W = F \\times s$। আমরা জানি, বলের মাত্রা হলো $[MLT^{-2}]$ এবং সরণের মাত্রা হলো $[L]$। সুতরাং, শক্তির মাত্রা হবে $[MLT^{-2}] \\times [L] = [ML^2 T^{-2}]$।	D
0d3a863f-1bdc-4700-9fde-50a6789967a6	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	09	আলোক বর্ষ কিসের একক?	physics	physical_world_and_measurement	B	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	আলোক বর্ষ (Light-year) হলো সেই দূরত্ব যা আলো এক বছরে শূন্যস্থানে অতিক্রম করে। যেহেতু এটি আলো দ্বারা অতিক্রান্ত দূরত্বকে নির্দেশ করে, তাই এটি দূরত্বের একক। এর মান প্রায় $9.461 \\times 10^{15}\\,\\text{m}$।	B
ff1a1634-1cba-4dfd-a821-3c681b5fd44e	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	২৯	একটি পাথরকে একটি উঁচু জায়গা থেকে নিচে ফেলে দেওয়া হলো। নিম্নের কোন লেখচিত্রটি এর গতিকে প্রকাশ করে?	physics	dynamics	B	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p03_qq_01.png", "markdown": null, "page_index": 2, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}, {"id": "IMAGE_2", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p03_qq_02.png", "markdown": null, "page_index": 2, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}, {"id": "IMAGE_3", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p03_qq_03.png", "markdown": null, "page_index": 2, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}, {"id": "IMAGE_4", "kind": "diagram", "label": "graph", "box_2d": null, "filename": "p03_qq_04.png", "markdown": null, "page_index": 2, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}]	যখন একটি পাথরকে উঁচু জায়গা থেকে নিচে ফেলে দেওয়া হয়, তখন এর প্রাথমিক বেগ $u=0$ হয় এবং এটি অভিকর্ষজ ত্বরণ $g$ এর প্রভাবে নিচে পড়ে। অতিক্রান্ত দূরত্ব $s$ এবং সময় $t$ এর মধ্যে সম্পর্ক হলো $s = ut + \\frac{1}{2}gt^2$। যেহেতু $u=0$, তাই সম্পর্কটি দাঁড়ায় $s = \\frac{1}{2}gt^2$। এর অর্থ হলো অতিক্রান্ত দূরত্ব সময়ের বর্গের সমানুপাতিক ($s \\propto t^2$)। একটি $s-t$ লেখচিত্রে এই সম্পর্কটি একটি অধিবৃত্ত (parabola) দ্বারা প্রকাশ করা হয়, যেখানে লেখচিত্রের ঢাল (যা বেগ নির্দেশ করে) সময়ের সাথে সাথে বৃদ্ধি পায়। অপশন (B) তে প্রদর্শিত লেখচিত্রটি এই বৈশিষ্ট্য ধারণ করে, যেখানে ঢাল ক্রমাগত বৃদ্ধি পাচ্ছে, যা ক্রমবর্ধমান বেগকে নির্দেশ করে।	B
79fac420-1fdd-40d0-b324-11d7fdf6767b	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	26	দুটি সুরেলা কাঁটার কম্পাঙ্ক $220\\text{ Hz}$ ও $210\\text{ Hz}$। যদি সুরেলা কাঁটা দুটি একত্রে শব্দ তৈরি করে তবে প্রতি সেকেন্ডে উৎপন্ন বীট সংখ্যা হবে-	physics	waves	D	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	দুটি ভিন্ন কম্পাঙ্কের শব্দ তরঙ্গ যখন একই সময়ে একই মাধ্যমে বিস্তার লাভ করে, তখন তাদের উপরিপাতনের ফলে বীট উৎপন্ন হয়। প্রতি সেকেন্ডে উৎপন্ন বীট সংখ্যা হলো তরঙ্গদ্বয়ের কম্পাঙ্কের পার্থক্যের পরম মান। এখানে, প্রথম সুরেলা কাঁটার কম্পাঙ্ক $f_1 = 220\\,\\text{Hz}$ এবং দ্বিতীয় সুরেলা কাঁটার কম্পাঙ্ক $f_2 = 210\\,\\text{Hz}$। বীট সংখ্যা $f_b = |f_1 - f_2|$ সূত্র দ্বারা নির্ণয় করা হয়। সুতরাং, $f_b = |220\\,\\text{Hz} - 210\\,\\text{Hz}| = 10\\,\\text{Hz}$।	D
8dc11970-9511-4442-a739-3d999548678b	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	20	তিনটি সুরশলাকা নেওয়া হলো যাদের কম্পাঙ্ক যথাক্রমে $105\\text{ Hz}$, $315\\text{ Hz}$ এবং $525\\text{ Hz}$। শলাকা তিনটি দিয়ে বায়ুতে শব্দ সৃষ্টি করলে সৃষ্ট শব্দের তরঙ্গদৈর্ঘ্যের অনুপাত কী হবে?	physics	waves	C	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	শব্দের বেগ ($v$) ধ্রুবক হলে, তরঙ্গদৈর্ঘ্য ($\\lambda$) কম্পাঙ্কের ($f$) ব্যস্তানুপাতিক হয়, অর্থাৎ $\\lambda = v/f$। প্রদত্ত কম্পাঙ্কগুলো হলো $f_1 = 105\\,\\text{Hz}$, $f_2 = 315\\,\\text{Hz}$ এবং $f_3 = 525\\,\\text{Hz}$।\nসুতরাং, তরঙ্গদৈর্ঘ্যের অনুপাত হবে:\n$$\\lambda_1 : \\lambda_2 : \\lambda_3 = \\frac{v}{f_1} : \\frac{v}{f_2} : \\frac{v}{f_3} = \\frac{1}{105} : \\frac{1}{315} : \\frac{1}{525}$$\nএই অনুপাতকে সরল করার জন্য, আমরা $105, 315, 525$ এর ল.সা.গু. ($1575$) দিয়ে গুণ করি:\n$$\\frac{1575}{105} : \\frac{1575}{315} : \\frac{1575}{525} = 15 : 5 : 3$$\nঅতএব, সৃষ্ট শব্দের তরঙ্গদৈর্ঘ্যের অনুপাত $15:5:3$।	C
907c9c8d-a368-4884-bbbd-04bfd8d150b8	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	27	পৃথিবী পৃষ্ঠে $[g_e = 9.8\\text{ m/s}^2]$ একটি দোলক ঘড়ি সঠিক সময় দেয়। ঘড়িটি চন্দ্রপৃষ্ঠে $[g_m = 1.6\\text{ m/s}^2]$ নেওয়া হলে পৃথিবী পৃষ্ঠের $1\\text{ h}$ সময় চন্দ্রপৃষ্ঠে হবে-	physics	periodic_motion	B	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	একটি সরল দোলকের পর্যায়কাল $T = 2\\pi \\sqrt{\\frac{L}{g}}$ সূত্র দ্বারা নির্ধারিত হয়, যেখানে $L$ দোলকের দৈর্ঘ্য এবং $g$ অভিকর্ষজ ত্বরণ। পৃথিবী পৃষ্ঠে পর্যায়কাল $T_e = 2\\pi \\sqrt{\\frac{L}{g_e}}$ এবং চন্দ্রপৃষ্ঠে পর্যায়কাল $T_m = 2\\pi \\sqrt{\\frac{L}{g_m}}$। দোলক ঘড়িটি সঠিক সময় দেয় মানে এটি পৃথিবী পৃষ্ঠে $T_e$ পর্যায়কাল মেনে চলে। চন্দ্রপৃষ্ঠে নেওয়া হলে, দোলকের দৈর্ঘ্য $L$ অপরিবর্তিত থাকে।\n\nআমরা পর্যায়কালের অনুপাত নির্ণয় করতে পারি: $\\frac{T_m}{T_e} = \\frac{2\\pi \\sqrt{\\frac{L}{g_m}}}{2\\pi \\sqrt{\\frac{L}{g_e}}} = \\sqrt{\\frac{g_e}{g_m}}$।\n\nযদি পৃথিবী পৃষ্ঠে $t_e$ সময় অতিবাহিত হয়, তবে চন্দ্রপৃষ্ঠে অতিবাহিত সময় $t_m$ হবে $t_m = t_e \\frac{T_m}{T_e}$।\n\nপ্রদত্ত মানগুলো বসিয়ে পাই: $g_e = 9.8\\,\\text{m/s}^2$, $g_m = 1.6\\,\\text{m/s}^2$, এবং $t_e = 1\\,\\text{h}$।\n\nসুতরাং, $t_m = 1\\,\\text{h} \\times \\sqrt{\\frac{9.8\\,\\text{m/s}^2}{1.6\\,\\text{m/s}^2}} = \\sqrt{\\frac{9.8}{1.6}}\\,\\text{h}$।\n\nএটি বিকল্প (C) এর সাথে মিলে যায়।	C
8867a36b-758a-4c7e-ab60-1596edc4c28e	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	22	একটি কাঁচ স্ল্যাবের সংকট কোণ $60^\\circ$ হলে কাঁচ উপাদানের প্রতিসরাঙ্ক হবে-	physics	geometrical_optics	D	\N	generated	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	সংকট কোণ ($\theta_c$) এবং প্রতিসরাঙ্ক ($n$) এর মধ্যে সম্পর্কটি হলো $n = \\frac{1}{\\sin \\theta_c}$। প্রদত্ত সংকট কোণ $\\theta_c = 60^\\circ$। এই মানটি সূত্রে বসিয়ে পাই $n = \\frac{1}{\\sin 60^\\circ}$। যেহেতু $\\sin 60^\\circ = \\frac{\\sqrt{3}}{2}$, সুতরাং প্রতিসরাঙ্ক হবে $n = \\frac{1}{\\frac{\\sqrt{3}}{2}} = \\frac{2}{\\sqrt{3}}$।	D
ae15f6c7-0d25-43b1-8e14-d37e484872ce	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	০১	নিচের কোন জলীয় দ্রবণটির pH সবচেয়ে বেশি?	chemistry	qualitative_chemistry	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
51d69466-c78a-4b91-8219-f4af4a02a717	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	০২	প্রশমন এনথালপি $-57.0\\text{ kJ mol}^{-1}$ হলে $\\ce{Ba(OH)2(aq) + 2HCl(aq) -> BaCl2(aq) + 2H2O(l)}$ বিক্রিয়াটির এনথালপির পরিবর্তন কত?	chemistry	chemical_changes	D	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
edf6c621-dc98-4e38-b0e7-28fb0705ef7d	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	০৩	কোনটি ইলেকট্রোফাইল?	chemistry	organic_chemistry	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
d618e137-7897-4e44-845d-19efabbed372	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	০৪	নিচের কোন যৌগটি চতুস্তলকীয় আকৃতির নয়?	chemistry	periodic_properties_of_elements_and_chemical_bonding	D	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
bdc03323-6d57-4d58-9401-066566deb512	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	০৫	$\\ce{MnO4^-}$ আয়নকে ethandioate ion দিয়ে বিজারিত করলে $\\ce{Mn}$ এর জারণ মান হলো-	chemistry	quantitative_chemistry	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
71c25a35-73e3-41f6-a8bf-c3a473786382	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	০৬	$\\ce{Co}$ এবং $\\ce{Co^{2+}}$ এর জন্য নিচের কোন যোগ্যতা ইলেকট্রন বিন্যাসটি সঠিক?	chemistry	qualitative_chemistry	D	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
ef9feb31-e7cf-4efd-ba13-605ce79e5251	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	০৭	IUPAC পদ্ধতিতে $\\ce{CH3-CH(CH3)-CH2-C(CH3)OH-CH2-CH3}$ এর নাম হচ্ছে-	chemistry	organic_chemistry	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
99529fb9-4e7c-4921-88bf-afd6530c176e	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	০৮	নিচের কোনটি জারণ-বিজারণ বিক্রিয়া নয়?	chemistry	quantitative_chemistry	D	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
4d51c540-42e6-4445-b690-ad8f1c9841d5	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	০৯	$\\ce{2NO(g) + Cl2(g) <=> 2NOCl(g)}$ বিক্রিয়ার জন্য $25^{\\circ}\\text{C}$ তাপমাত্রায় $K_p$ এর মান $1.9 \\times 10^3 \\text{ atm}^{-1}$; একই তাপমাত্রায় $K_c$ এর সংখ্যা মান কত?	chemistry	chemical_changes	A	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
818b5172-787d-44d7-afd0-7a96d94b69ed	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	১০	ফেহলিং দ্রবণ ও টলেন বিকারক দ্বারা নিচের কোন গ্রুপ এর মধ্যে পার্থক্য করা যায়?	chemistry	organic_chemistry	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
36bf17f5-128a-45ef-b983-71a2e8d6b2d5	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	১১	ইলেকট্রোকেমিক্যাল সেল নোটেশনের ক্ষেত্রে নিচের কোনটি সঠিক?	chemistry	electrochemistry	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
32373f1f-9075-41bc-bb81-2bfa7fafbd32	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	১২	কোনটি জ্বালানি নয়?	chemistry	environmental_chemistry	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
ea27a43b-778c-46f7-96d8-f698a257513e	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	13	নিচের কোন বিন্যাসটি পাউলির বর্জন নীতি ও হুন্ড নীতি সমর্থন করে?	chemistry	qualitative_chemistry	D	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "orbital_diagram", "box_2d": null, "filename": null, "markdown": null, "page_index": 3, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2017-2018-A-Unit/page_4", "extraction_status": "needs_review"}, {"id": "IMAGE_2", "kind": "diagram", "label": "orbital_diagram", "box_2d": null, "filename": null, "markdown": null, "page_index": 3, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2017-2018-A-Unit/page_4", "extraction_status": "needs_review"}, {"id": "IMAGE_3", "kind": "diagram", "label": "orbital_diagram", "box_2d": null, "filename": null, "markdown": null, "page_index": 3, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2017-2018-A-Unit/page_4", "extraction_status": "needs_review"}, {"id": "IMAGE_4", "kind": "diagram", "label": "orbital_diagram", "box_2d": null, "filename": null, "markdown": null, "page_index": 3, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2017-2018-A-Unit/page_4", "extraction_status": "needs_review"}]	\N	\N
a8a901a9-da07-4be3-a4db-ff8d81cb71db	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	14	প্রমাণ অবস্থায় $10.0\\,\\text{L}$ মিথেন গ্যাসে অণুর সংখ্যা কত?	chemistry	quantitative_chemistry	A	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
081618ed-512b-4c10-a895-edf6823b6664	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	15	নিম্নের কোনটি জুইটার আয়ন তৈরি করে?	chemistry	organic_chemistry	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "chemical_structure", "box_2d": null, "filename": null, "markdown": null, "page_index": 3, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2017-2018-A-Unit/page_4", "extraction_status": "needs_review"}, {"id": "IMAGE_2", "kind": "diagram", "label": "chemical_structure", "box_2d": null, "filename": null, "markdown": null, "page_index": 3, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2017-2018-A-Unit/page_4", "extraction_status": "needs_review"}, {"id": "IMAGE_3", "kind": "diagram", "label": "chemical_structure", "box_2d": null, "filename": null, "markdown": null, "page_index": 3, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2017-2018-A-Unit/page_4", "extraction_status": "needs_review"}, {"id": "IMAGE_4", "kind": "diagram", "label": "chemical_structure", "box_2d": null, "filename": null, "markdown": null, "page_index": 3, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2017-2018-A-Unit/page_4", "extraction_status": "needs_review"}]	\N	\N
1e33bbb3-91c6-46a7-ad67-806b1d18161a	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	17	নিম্নের কোন যৌগটি optical isomerism দেখায়?	chemistry	organic_chemistry	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
79cc36ab-9263-417d-81e5-15ead1475094	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	18	কোন প্রক্রিয়ায় $\\ce{^{234}_{90}Th}$ থেকে $\\ce{^{234}_{91}Pa}$ তৈরি হয়?	chemistry	qualitative_chemistry	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
b1bc1143-f068-4b94-93f6-17b65baec896	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	19	নিচের কোনটি লুইস এসিড?	chemistry	periodic_properties_of_elements_and_chemical_bonding	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
f4d09186-46ba-4f88-a5c9-04b0433f7835	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	20	$\\ce{C6H5-CHO + CH3NH2 -> q + H2O}$ বিক্রিয়ায় $q$ এর আণবিক সংকেত কোনটি?	chemistry	organic_chemistry	A	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "chemical_structure", "box_2d": null, "filename": null, "markdown": null, "page_index": 3, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2017-2018-A-Unit/page_4", "extraction_status": "needs_review"}, {"id": "IMAGE_2", "kind": "diagram", "label": "chemical_structure", "box_2d": null, "filename": null, "markdown": null, "page_index": 3, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2017-2018-A-Unit/page_4", "extraction_status": "needs_review"}, {"id": "IMAGE_3", "kind": "diagram", "label": "chemical_structure", "box_2d": null, "filename": null, "markdown": null, "page_index": 3, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2017-2018-A-Unit/page_4", "extraction_status": "needs_review"}, {"id": "IMAGE_4", "kind": "diagram", "label": "chemical_structure", "box_2d": null, "filename": null, "markdown": null, "page_index": 3, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2017-2018-A-Unit/page_4", "extraction_status": "needs_review"}]	\N	\N
fdbc5078-665d-4f74-a850-e00ed1345627	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	21	তাপ উৎপাদী বিক্রিয়ায় তাপমাত্রা বাড়ালে কোনটি সত্য নয়?	chemistry	chemical_changes	A	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
f6255bbd-d781-4edb-b2d1-9aad47b7132b	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	22	গ্যাসীয় অবস্থায় এক মোল পরমাণুতে এক মোল ইলেকট্রন যোগ করলে যে শক্তির পরিবর্তন হয় তা হলো-	chemistry	periodic_properties_of_elements_and_chemical_bonding	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
f00b57c6-0a5c-4809-a880-7401078f3b13	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	23	নিচের কোনটি সঠিক নয়?	chemistry	chemical_changes	D	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
136398ca-8194-4ed3-a2ea-f931285eabd0	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	24	নিচের বিক্রিয়ার উৎপাদ/উৎপাদসমূহ কী?\n$$\\ce{HCHO \\xrightarrow[\\text{(conc.NaOH solution)}]{\\text{(গাঢ় NaOH দ্রবণ)}} Products(s)}$$	chemistry	organic_chemistry	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
30f37909-3dbb-4a80-b190-e39259217d2a	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	25	$\\ce{[Co(NH3)4(H2O)2]Cl3}$ জটিল যৌগটিতে অবস্থান্তর ধাতুটির সন্নিবেশ সংখ্যা কত?	chemistry	periodic_properties_of_elements_and_chemical_bonding	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
5734fe7c-2150-4d15-9c09-fe80dd6493a2	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	26	গলিত $\\ce{NaCl}$ এর মধ্য দিয়ে 1F তড়িৎ চালনা করলে ক্যাথোডে জমাকৃত $\\ce{Na}$ এর পরিমাণ হচ্ছে-	chemistry	electrochemistry	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
1ff83c52-dd81-4e69-904a-3f1555c693a6	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	27	$\\ce{CH3-CH=CH2}$ যৌগে কার্বনগুলোর সংকরণ কিরূপ?	chemistry	organic_chemistry	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
06c9561c-1eb8-41ac-9b33-b0b757817c2c	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	28	নিম্নের কোন উক্তি বা উক্তিসমূহ সঠিক?\ni. চামড়া শিল্প থেকে $\\ce{Cr^{6+}}$ বর্জ্য নির্গত হয়\nii. ইউরিয়া সার শিল্প থেকে $\\ce{Hg^{2+}}$ নির্গত হয়\niii. ব্যাটারি তৈরির কারখানা থেকে $\\ce{Pb^{2+}}$ নির্গত হয়	chemistry	environmental_chemistry	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
ab6542ff-6b20-49cd-b58a-cfd06c2b7235	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	29	কোনটি সিমেন্ট-ক্লিংকার এর উপাদান নয়?	chemistry	economic_chemistry	D	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
f7453ae7-25bb-450e-808c-7ef9876f705f	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	30	$0.10\\,\\text{mol L}^{-1}$ দ্রবণ থেকে নির্দিষ্ট আয়তনের $0.01\\,\\text{mol L}^{-1}$ দ্রবণ তৈরিতে নিম্নের কোন সেটটি সবচেয়ে বেশি উপযুক্ত?	chemistry	safe_use_of_laboratory	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
16e61ff3-b78f-4f50-bfba-1ffb10761b16	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	01.	$P(2, 5)$, $Q(5, 9)$ এবং $S(6, 8)$ বিন্দুত্রয় $PQRS$ রম্বসের শীর্ষবিন্দু হলে, $R$ এর স্থানাঙ্ক -	mathematics	vectors	D	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
e6e0e1ce-ab24-457e-b0be-f8e99c2b867a	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	02.	$y$-অক্ষের সমান্তরাল এবং $2x - 7y + 11 = 0$ ও $x + 3y = 8$ রেখাদ্বয়ের ছেদবিন্দু দিয়ে অতিক্রমকারী সরলরেখার সমীকরণ-	mathematics	straight_lines	A	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
9e4a4db0-6a84-4fe2-85eb-8d61c4eadd4d	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	03.	$x^4 - 4x^3 + 4x^2 + 5$ এর লঘিষ্ঠ মান -	mathematics	differential_calculus	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
dca56350-0ec7-480f-841f-3d0b0d098135	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	04.	$\\int_{-1}^{1} |x| dx$ এর মান-	mathematics	integral_calculus	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
360baecf-34a7-437c-8c7f-c5b3d1d8b27d	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	05.	$0 \\leq x \\leq 90^\\circ$ হলে, $\\sin 3x = \\cos x$ সমীকরণের সমাধান হবে।	mathematics	inverse_trigonometric_functions_and_trigonometric_equations	D	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
02f9760b-6ba8-4014-95b2-2fd38671158c	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	06.	$A = \\begin{bmatrix} a & 2 & 5 \\\\ -2 & b & -3 \\\\ -5 & 3 & c \\end{bmatrix}$ একটি বক্র প্রতিসম ম্যাট্রিক্স হলে, $a, b, c$ এর মানগুলো-	mathematics	matrices_and_determinants	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
c77902b3-6550-4c6d-a2cd-3aa4f40423f9	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	07.	$\\int \\frac{dx}{x\\sqrt{x^2 - 1}} = f(x) + c$ হলে, $f(x)$ সমান-	mathematics	integral_calculus	D	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
12134285-1e26-45a8-b59f-6cda2798a7fc	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	09	যদি $\\int_{0}^{6} f(t) dt = 8$ হয়, তবে $\\int_{0}^{3} f(2x) dx$ এর মান -	mathematics	integral_calculus	D	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
858d0097-93f9-4bac-87dd-2d101bbd68bf	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	10	$y = x^2, x = 1, x = 3$ এবং $x$ অক্ষ দ্বারা সীমাবদ্ধ ক্ষেত্রের ক্ষেত্রফল-	mathematics	integral_calculus	A	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
40b17b5e-c209-4c7b-9fe0-acb9ed1a0c48	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	11	$\\sin^{-1} x + \\sin^{-1} y = \\frac{\\pi}{2}$ হলে কোনটি সঠিক?	mathematics	inverse_trigonometric_functions_and_trigonometric_equations	A	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
850faec6-68af-49ef-83ad-e98c2046befd	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	12	$k$ এর কোন মানের জন্য $\\begin{vmatrix} 1 & 1 & 1 \\\\ 1 & k & k^2 \\\\ 1 & k^2 & k^4 \\end{vmatrix}$ নির্ণায়কটির মান শূন্য হবে না?	mathematics	matrices_and_determinants	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
72f0d0eb-9f06-46e9-b116-dc9b59c32680	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	13	$25x^2 + 16y^2 = 400$ এর উৎকেন্দ্রিকতা হবে -	mathematics	conics	A	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
bb5e6ca7-1c67-4954-8b43-e6664aca219b	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	14	$\\lim_{x \\to -\\infty} \\frac{2x^2 + 3x + 5}{3x^2 + 5x - 6}$ এর মান -	mathematics	differential_calculus	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
03afcf27-cabb-4a4b-80d8-abfd1ee920ca	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	15	$(4, 3)$ বিন্দুতে $3x^2 - 4y^2 = 12$ অধিবৃত্তের স্পর্শকের ঢালের মান -	mathematics	conics	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
2a8fa087-27d8-453d-93bc-340a8fd2942e	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	16	কোনো দ্বিঘাত সমীকরণের একটি মূল $\\frac{1}{1+i}$ হলে সমীকরণটি হবে-	mathematics	polynomials_and_polynomial_equations	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
2455d12f-d4c4-4f3b-9ccf-7896d751003c	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	17	$1$ হতে $99$ পর্যন্ত সংখ্যাগুলি থেকে দৈবচয়ন পদ্ধতিতে একটি সংখ্যা নেয়া হলে সেটি বর্গ হওয়ার সম্ভাবনা হবে-	mathematics	measure_of_dispersion_and_probability	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
50eca9d6-a660-49f4-886e-21ef757b589b	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	18	$x + 2y \\leq 10$, $x + y \\leq 6$, $x \\leq 4$, $x, y \\geq 0$ শর্তাধীনে $z = 2x + 3y$ এর সর্বোচ্চ মান-	mathematics	linear_programming	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
06d698e8-232a-49ee-8128-f63ac88d04d2	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	19	$f(x) = \\frac{1}{\\sqrt{|x|}}$ এর ডোমেন।	mathematics	functions_and_graphs	D	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
398cf02a-8e91-487f-99c4-9986f19e2b39	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	20	যদি $u$ বেগে অনুভূমিকের সাথে $\\alpha$ কোণে প্রক্ষিপ্ত বস্তু '$T$' সময়ে তার গতিপথের সর্বোচ্চ উচ্চতা $H$ এ পৌঁছায়, তবে $\\frac{H}{T^2}$ হবে -	mathematics	dynamics	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
b89d5282-f81b-43c3-8741-614a877c86ad	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	21	$f(x) = \\sqrt{x-1}$ হলে, $f^{-1}(2)$ এর মান -	mathematics	functions_and_graphs	D	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
6cfffde6-51cf-41b4-a4d4-c71e22c23870	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	22	RAJSHAHI শব্দটির অক্ষরগুলোর একত্রে বিন্যাস সংখ্যা BARISAL শব্দটির অক্ষরগুলোর একত্রে বিন্যাস সংখ্যার $k$ গুণ হলে, $k$ এর মান-	mathematics	permutations_and_combinations	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
a939077d-db2a-4f99-82ed-b8fa8d7f9e5d	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	23	$(x - \\frac{1}{x})^{16}$ এর বিস্তৃতির মধ্যপদটি হবে-	mathematics	binomial_expansion	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
d422abd4-872c-408d-ac31-d32d55b374ea	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	24	অসমতা $|5 - 2x| \\geq 4$ এর সমাধান সেট-	mathematics	real_numbers_and_inequalities	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
642ceec3-d1b1-44da-9724-05d0c03df45b	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	25	যদি $z_1 = 1 - i, z_2 = \\sqrt{3} + i$ হয়, তবে $\\frac{z_2}{z_1}$ এর নতি-	mathematics	complex_numbers	A	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
c2c3a64e-b2cb-4256-b8dc-fb6b1f66ed03	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	26	মূলবিন্দুগামী একটি বৃত্ত ধনাত্মক $x$ অক্ষ হতে 4 একক এবং ধনাত্মক $y$ অক্ষ হতে 2 একক ছেদক কর্তন করলে, এর সমীকরণ হবে- [IMAGE_1]	mathematics	circles	A	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "geometry_figure", "box_2d": null, "filename": null, "markdown": null, "page_index": 6, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2017-2018-A-Unit/page_7", "extraction_status": "needs_review"}]	\N	\N
cc1a8a38-da4b-4ffb-bead-d9293e2a321a	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	27	ভেক্টর $\\vec{u} = 2\\hat{i} + \\hat{j} - 3\\hat{k}$ ও $\\vec{v} = 3\\hat{i} - 2\\hat{j} - \\hat{k}$ এর অন্তর্ভুক্ত কোণ-	mathematics	vectors	A	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
ae85c7fb-3043-4f6c-93bb-593346503a90	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	28	$\\vec{a} = 4\\hat{i} - 3\\hat{j} + 2\\hat{k}$ ও $\\vec{b} = 2\\hat{i} - 3\\hat{j} + 4\\hat{k}$ ভেক্টর দুইটি যে সামান্তরিকের সন্নিহিত বাহু তার ক্ষেত্রফল হবে-	mathematics	vectors	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
462f083c-d6dc-4988-9632-c59710763f0a	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	29	$A + B = \\frac{\\pi}{2}$ হলে, $\\cos^2 A - \\cos^2 B$ এর মান -	mathematics	trigonometric_ratios	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
481d86de-d333-486b-af5a-9a1bd481a2f7	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	30	$1 + \\frac{1}{3} + \\left(\\frac{1}{3}\\right)^2 + \\left(\\frac{1}{3}\\right)^3 + \\dots$ অসীম পর্যন্ত এর মান-	mathematics	associated_trigonometric_angles	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
ab6987fc-cd5d-47b8-b253-3bded6040ef5	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	01	কোনটিতে হ্যাড্রোসেন্ট্রিক ভাস্কুলার বান্ডল থাকে?	biology	tissue_and_tissue_system	A	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
2821f398-5302-478c-b499-259c7dc29937	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	02	কোন উদ্ভিদের শুক্রাণু সর্ববৃহৎ?	biology	gymnosperms_and_angiosperms	D	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
aae62c26-f151-420a-8872-735d520ca8d0	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	03	সর্বমুখ পরাগধানী, পালকের ন্যায় গর্ভমুণ্ড, ক্যারিওপসিস ফল কোন গোত্রের শনাক্তকারী বৈশিষ্ট্য?	biology	gymnosperms_and_angiosperms	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
2d83b941-c6e6-4c00-b25a-bbf7d96ff482	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	04	কোনটি ডিপ্লয়েড পার্থেনোজেনেসিস এর উদাহরণ?	biology	plant_reproduction	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
0551c75e-5559-4163-8f4a-8884bcfae7b0	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	05	ম্যান্টল দ্বারা আবৃত অখন্ডায়িত কোমল দেহবিশিষ্ট প্রাণিকুল যে পর্বের অন্তর্গত তা হলো-	biology	animal_diversity_and_classification	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
f69ffa1a-a6d1-41fb-a035-01b81a1827d9	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	06	কোন পর্বের প্রাণিদের স্যুডোসিলোমেট বলা হয়?	biology	animal_diversity_and_classification	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
8ef8154e-4927-4902-b420-1de5d6080cf0	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	07	কোন উপাঙ্গটি ঘাসফড়িং খাদ্য কর্তনে ব্যবহার করে?	biology	animal_identity	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
a075b5c2-6407-482f-8c2a-f36f20237262	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	08	তরুণাস্থিযুক্ত মাছে কয় জোড়া ফুলকা ছিদ্র থাকে?	biology	animal_diversity_and_classification	D	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
757833d3-baca-4e74-b8c2-b8bb3667c3b0	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	09	কোন শ্রেণিভুক্ত প্রাণীদের এপিডার্মাল আঁইশ থাকে?	biology	animal_diversity_and_classification	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
8fda6522-142a-4ec3-95a8-c373ca83437a	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	10	গ্লুকোনিওজেনেসিস হলো-	biology	plant_physiology	A	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
b1c73711-447f-4b00-aa6a-88f81edb82f0	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	11	পাকস্থলি প্রাচীরের কোন কোষ $\\ce{HCl}$ নিঃসরণ করে?	biology	human_physiology_digestion_and_absorption	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
9f53e265-4917-4208-ab93-995ea0bcbfff	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	12	কোন বাক্যটি সিলোম ও হিমোসিল উভয়ের জন্য সঠিক?	biology	animal_diversity_and_classification	A	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
ba3792ee-1e18-4743-835c-92deb1e266b2	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	13	মানব হৃৎপিণ্ডের কোন স্থানে সাইনোঅ্যাট্রিয়াল নোড অবস্থিত?	biology	human_physiology_blood_and_circulation	A	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
7e62838f-d484-4dca-9617-595d9bfd0bd2	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	14	নিচের কোনটিতে র‍্যামেন্টাম থাকে?	biology	bryophyta_and_pteridophyta	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
1639acbb-7206-4b85-983c-add68fe6a74c	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	15	কোনটি সিনোসাইটিক শৈবালের উদাহরণ?	biology	algae_and_fungi	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
93d5cd06-b557-45d1-bd29-20690a4f3df3	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	16	কোষ পর্দার ফ্লুইড মোজাইক মডেল কে প্রস্তাব করেন?	biology	cell_and_its_structure	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
f12d0cda-d5a6-4c13-ae7f-6861ad9c4141	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	17	লাইকেনে শতকরা কত ভাগ শৈবালের উপস্থিতি থাকে?	biology	microorganisms	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
220000a0-d1ed-4354-8a39-e7ac1d00f389	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	18	নিচের কোনটি অ-প্রোটিনীয় অ্যামিনো অ্যাসিড?	biology	cell_chemistry	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
116df7ab-762b-44ba-8af4-5d866d28aedd	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	19	কোনটি রেইনডিয়ার মস নামে পরিচিত?	biology	algae_and_fungi	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
35c7efb2-0fd3-4be9-bac4-e918263e9033	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	20	DNA ডবল হেলিক্স-এর দুটি স্ট্র্যান্ড-এর মধ্যবর্তী দূরত্ব-	biology	cell_and_its_structure	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
574bd461-a733-4802-b218-73d8044103fc	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	21	কোনটি ইন-সিটু সংরক্ষণ এর উদাহরণ?	biology	environment_expansion_and_conservation_of_organisms	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
cfaad6fd-92a1-435a-8475-5ecd234da16e	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	22	কোনটিতে ইনসুলিন তৈরির জিন সংযোজন করা হয়েছে?	biology	biotechnology	C	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
3aab1dfa-d407-4897-9e36-bc30e8f15a82	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	23	নিচের কোনটি RNA ভাইরাস?	biology	microorganisms	D	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
d10b6e36-5b5b-477e-9140-70866e9e367b	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	24	কোনটি দাদরোগের জন্য দায়ী?	biology	algae_and_fungi	D	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
65f31937-aedf-4548-8ed2-0580d0e78973	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	25	তরুণাস্থি কোন আবরণ দ্বারা আবৃত থাকে?	biology	human_physiology_locomotion_and_movement	A	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
ad97fc36-394b-4e9c-8716-9bf149aeccc8	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	26.	কোন করোটিক স্নায়ু জিহ্বা নাড়াতে সাহায্য করে?	biology	human_physiology_coordination_and_control	D	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
72cd0a9b-c680-466a-adb2-5fb00c5e9d83	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	27.	শীতের পাখির অভিপ্রয়াণ (পরিযান) কোন ধরনের আচরণ?	biology	animal_behavior	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
268dfbaf-ace5-47d8-8099-60a6b502cb28	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	28.	নিচের কোনটি মাইটোকন্ড্রিয়ার দ্বিন্তর আবরণের মাঝখানে থাকে?	biology	cell_and_its_structure	B	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
ab4d7ade-8a5b-449f-b31f-494aedf2e19e	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	29.	ডি.এন.এ. সিঁড়ির প্রতি প্যাঁচের দৈর্ঘ্য কত?	biology	cell_and_its_structure	D	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
b8a9a920-ed6d-4703-bf9f-ecb99715dc11	ccdf4d8c-7726-4a78-be51-49d2cc7e4401	30.	ওয়ালেস ও ওয়েবার লাইন এর মধ্যবর্তী অঞ্চলের নাম হলো-	biology	environment_expansion_and_conservation_of_organisms	A	\N	pending	2026-04-27 17:34:47.394232+00	Dhaka University	2017-2018	A	null	\N	\N
e089d5d2-bb03-4471-86c2-2c3407530f61	e1714ea9-0d01-4643-a7e5-d57e77196296	09.	$\\frac{1+i}{1-i}$ এর পরম মান হলো-	mathematics	complex_numbers	B	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
e92084ad-292d-4840-abe3-026cbdede660	e1714ea9-0d01-4643-a7e5-d57e77196296	01	দুইটি ভেক্টর $\\vec{A} = 3\\hat{i} - 3\\hat{j}$ এবং $\\vec{B} = 5\\hat{i} + 5\\hat{k}$ এর মধ্যবর্তী কোণ কত?	physics	vector	A	\N	generated	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	প্রথমে ভেক্টরদ্বয়ের ডট গুণফল নির্ণয় করি: $\\vec{A} \\cdot \\vec{B} = (3 \\times 5) + (-3 \\times 0) + (0 \\times 5) = 15$। এরপর ভেক্টরদ্বয়ের মান নির্ণয় করি: $|\\vec{A}| = \\sqrt{3^2 + (-3)^2} = \\sqrt{18}$ এবং $|\\vec{B}| = \\sqrt{5^2 + 5^2} = \\sqrt{50}$। আমরা জানি, ভেক্টরদ্বয়ের মধ্যবর্তী কোণ $\\theta$ হলে, $\\cos \\theta = \\frac{\\vec{A} \\cdot \\vec{B}}{|\\vec{A}| |\\vec{B}|} = \\frac{15}{\\sqrt{18} \\times \\sqrt{50}} = \\frac{15}{\\sqrt{900}} = \\frac{15}{30} = \\frac{1}{2}$। সুতরাং, $\\theta = \\cos^{-1}(\\frac{1}{2}) = 60^\\circ$।	A
01cdbfcd-5a74-450f-b9fa-69200db938c3	e1714ea9-0d01-4643-a7e5-d57e77196296	03	নিচের কোনটি ভরের একক নয়?	physics	introduction_to_modern_physics	C	\N	generated	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	amu (atomic mass unit) হলো পারমাণবিক ভরের একটি ক্ষুদ্র একক। নিউটনের দ্বিতীয় সূত্র $F = ma$ থেকে আমরা পাই $m = \\frac{F}{a}$, যার একক $\\text{N}/(\\text{m/s}^2) = \\text{Nm}^{-1}\\text{s}^2$, যা ভরের সমতুল্য। আইনস্টাইনের ভর-শক্তি সমীকরণ $E = mc^2$ অনুযায়ী $m = \\frac{E}{c^2}$, তাই $\\frac{\\text{MeV}}{c^2}$ ভরের একটি একক হিসেবে ব্যবহৃত হয়। অন্যদিকে, MeV (Mega electron-volt) সরাসরি শক্তির একক ($1\\,\\text{MeV} = 1.6 \\times 10^{-13}\\,\\text{J}$), এটি ভরের একক নয়।	C
1b88a88c-cb2d-4184-a5e0-de08129088a2	e1714ea9-0d01-4643-a7e5-d57e77196296	02	স্থির অবস্থায় থাকা একটি বস্তু বিস্ফোরিত হয়ে $m_1$ ও $m_2$ ভরের দুইটি বস্তুতে পরিণত হয়ে যথাক্রমে $v_1$ ও $v_2$ বেগে বিপরীত দিকে চলমান। $\\frac{v_1}{v_2}$ এর অনুপাত কত?	physics	newtonian_mechanics	C	\N	generated	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	ভরবেগের সংরক্ষণ সূত্র অনুযায়ী, আদি ভরবেগ = শেষ ভরবেগ। যেহেতু বস্তুটি শুরুতে স্থির ছিল, তাই আদি ভরবেগ $0$। বিস্ফোরণের পর ভরবেগদ্বয়ের সমষ্টি শূন্য হবে, অর্থাৎ $m_1 v_1 + m_2 v_2 = 0$। এখান থেকে আমরা পাই $m_1 v_1 = -m_2 v_2$, যা নির্দেশ করে বেগদ্বয় পরস্পর বিপরীতমুখী। বেগের মানের অনুপাত হিসাব করলে আমরা পাই $\\frac{v_1}{v_2} = \\frac{m_2}{m_1}$।	C
2ed4d1d4-dbdf-4ccc-8fd9-0194c445f242	e1714ea9-0d01-4643-a7e5-d57e77196296	15	অ্যালুমিনিয়াম, হিলিয়াম এবং সিলিকনের পারমাণবিক সংখ্যা যথাক্রমে $13, 2$ এবং $14$ হলে, $\\ce{^{27}Al + ^{4}He -> ^{28}Si + (?)}$ নিউক্লিয়ার বিক্রিয়াতে অনুপস্থিত কণা কোনটি?	physics	atomic_model_and_nuclear_physics	\N	\N	generated	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	নিউকিয়ার বিক্রিয়ায় পারমাণবিক সংখ্যা ($Z$) এবং ভর সংখ্যা ($A$) সংরক্ষিত থাকে। বিক্রিয়ার বামপাশে মোট পারমাণবিক সংখ্যা $13 + 2 = 15$ এবং মোট ভর সংখ্যা $27 + 4 = 31$। ডানপাশে সিলিকনের ($Si$) পারমাণবিক সংখ্যা $14$ এবং ভর সংখ্যা $28$ দেওয়া আছে। সুতরাং, অনুপস্থিত কণাটির পারমাণবিক সংখ্যা $Z = 15 - 14 = 1$ এবং ভর সংখ্যা $A = 31 - 28 = 3$। যেহেতু পারমাণবিক সংখ্যা $1$, তাই কণাটি একটি প্রোটন বা তার আইসোটোপ হবে, যা অপশন (D) এর সাথে সামঞ্জস্যপূর্ণ।	D
2a7dc3da-9520-4108-929c-a14782e25c36	e1714ea9-0d01-4643-a7e5-d57e77196296	12	$5\\,\\text{m}$ উচ্চতা হতে একটি বলকে $20\\,\\text{m/s}$ বেগে অনুভূমিকের সাথে $30^\\circ$ কোণে উপরের দিকে নিক্ষেপ করা হলো। তাহলে বলটির বিচরণকাল কত?	physics	dynamics	A	\N	generated	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	উল্লম্ব সরণের সমীকরণ $h = (v_0 \\sin \\theta)t - \\frac{1}{2}gt^2$ ব্যবহার করে পাই, $-5 = (20 \\sin 30^\\circ)t - \\frac{1}{2}(9.8)t^2$। এখানে আদি উচ্চতা সাপেক্ষে ভূমি $5\\,\\text{m}$ নিচে অবস্থিত বলে সরণ $h = -5\\,\\text{m}$ ধরা হয়েছে। সমীকরণটি সাজালে পাই $4.9t^2 - 10t - 5 = 0$। দ্বিঘাত সমীকরণের সমাধান হতে $t = \\frac{10 \\pm \\sqrt{100 + 98}}{9.8}$ পাওয়া যায়। যেহেতু সময় ঋণাত্মক হতে পারে না, তাই বিচরণকাল $t = \\frac{10 + \\sqrt{198}}{9.8}\\,\\text{s}$।	A
4ce9e2ef-41c9-44d4-9476-d83c495c093d	e1714ea9-0d01-4643-a7e5-d57e77196296	14	একটি স্থির তরঙ্গে পরপর দুটি নিস্পন্দ বিন্দুর মধ্যবর্তী দূরত্ব $1\\,\\text{m}$, এর তরঙ্গদৈর্ঘ্য কত?	physics	periodic_motion	D	\N	generated	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	একটি স্থির তরঙ্গে পরপর দুটি নিস্পন্দ বিন্দুর (nodes) মধ্যবর্তী দূরত্ব হলো তরঙ্গদৈর্ঘ্যের অর্ধেক, অর্থাৎ $d = \\frac{\\lambda}{2}$। প্রশ্নে দেওয়া আছে, $d = 1\\,\\text{m}$। সুতরাং, $\\frac{\\lambda}{2} = 1\\,\\text{m}$ বা $\\lambda = 2\\,\\text{m}$। যেহেতু $1\\,\\text{m} = 100\\,\\text{cm}$, তাই তরঙ্গদৈর্ঘ্য $\\lambda = 2 \\times 100\\,\\text{cm} = 200\\,\\text{cm}$।	D
f94170d0-cff7-45cc-961c-a4730e275392	e1714ea9-0d01-4643-a7e5-d57e77196296	01	প্রোটিন অণুর মধ্যে অ্যামাইনো এসিডের অণুসমূহ যে বন্ধন দ্বারা যুক্ত থাকে-	chemistry	organic_chemistry	B	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
738590ae-23a1-4699-bc44-edbe819148d2	e1714ea9-0d01-4643-a7e5-d57e77196296	11	কাগজের ভার হিসাবে ব্যবহৃত একটি পুরু কাচ (প্রতিসরাঙ্ক $1.5$) খণ্ডের উপর থেকে খাড়া নিচের দিকে তাকালে কাগজের উপর একটি দাগ কাচের উপর প্রান্ত থেকে $6\\,\\text{cm}$ নিচে দেখা যায়। কাচ খণ্ডটির পুরুত্ব কত?	physics	geometrical_optics	C	\N	generated	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	কাচ খণ্ডের পুরুত্ব (বাস্তব গভীরতা) এবং কাগজের দাগের আপাত গভীরতার মধ্যে সম্পর্কটি প্রতিসরাঙ্ক দ্বারা নির্ধারিত হয়। সূত্রটি হলো $n = \\frac{\\text{বাস্তব গভীরতা}}{\\text{আপাত গভীরতা}}$। এখানে, প্রতিসরাঙ্ক $n = 1.5$ এবং আপাত গভীরতা $d' = 6\\,\\text{cm}$। সুতরাং, কাচ খণ্ডটির পুরুত্ব $d = n \\times d' = 1.5 \\times 6\\,\\text{cm} = 9\\,\\text{cm}$।	C
19ccfdd4-936b-41cd-b943-379ebb3eb295	e1714ea9-0d01-4643-a7e5-d57e77196296	07	নিচের বর্তনীতে তড়িৎপ্রবাহ $I_1$ এর মান কত?\n[IMAGE_1]	physics	current_electricity	B	\N	generated	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "circuit_diagram", "box_2d": null, "filename": "p01_q07_01.png", "markdown": null, "page_index": 0, "caption_hint": null, "review_notes": null, "extraction_status": "ok"}]	প্রথমে, $5\\,\\Omega$ রোধের মধ্য দিয়ে প্রবাহিত $0.6\\,\\text{A}$ তড়িৎপ্রবাহের কারণে বিভব পতন নির্ণয় করি। $V_{5\\Omega} = I \\times R_s = 0.6\\,\\text{A} \\times 5\\,\\Omega = 3\\,\\text{V}$। এরপর, সমান্তরাল শাখাগুলির বিভব পার্থক্য নির্ণয় করি। $V_p = V_{source} - V_{5\\Omega} = 9\\,\\text{V} - 3\\,\\text{V} = 6\\,\\text{V}$। এখন, $30\\,\\Omega$ রোধের মধ্য দিয়ে প্রবাহিত তড়িৎপ্রবাহ $I_2$ নির্ণয় করি: $I_2 = V_p / 30\\,\\Omega = 6\\,\\text{V} / 30\\,\\Omega = 0.2\\,\\text{A}$। সবশেষে, কার্শফের তড়িৎপ্রবাহ সূত্র (KCL) ব্যবহার করে $I_1$ এর মান নির্ণয় করি: $I = I_1 + I_2 \\implies I_1 = I - I_2 = 0.6\\,\\text{A} - 0.2\\,\\text{A} = 0.4\\,\\text{A}$।	B
96d6c2e1-271c-4e56-9c4e-af357a936773	e1714ea9-0d01-4643-a7e5-d57e77196296	02	$\\ce{Fe(s) | Fe^{2+}(aq) || Br2(l) ; Br^{-}(aq) | Pt(s)}$ তড়িৎ রাসায়নিক কোষের সঠিক কোষ-বিক্রিয়া কোনটি?	chemistry	electrochemistry	A	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
b6378ecd-e623-4031-ad9d-b1ee9069b25e	e1714ea9-0d01-4643-a7e5-d57e77196296	03	নিম্নের কোনটিকে সাধারণত তরল-তরল ক্রোমাটোগ্রাফি বলে?	chemistry	qualitative_chemistry	B	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	[{"id": "IMAGE_1", "kind": "table", "label": "data_table", "box_2d": null, "filename": null, "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2019-2020-A-Unit/page_2", "extraction_status": "needs_review"}]	\N	\N
8867992c-ed13-405c-99b3-a754695250aa	e1714ea9-0d01-4643-a7e5-d57e77196296	04	নিম্নের কোন যৌগটি জ্যামিতিক সমানুর্তা প্রদর্শন করে?	chemistry	organic_chemistry	D	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
92a4ce58-aad4-4b26-99af-b0b87c0eba6c	e1714ea9-0d01-4643-a7e5-d57e77196296	05	আর্দ্র বাতাসের সংস্পর্শে ক্যালসিয়াম কার্বাইড নিম্নের কোন যৌগটি উৎপন্ন করে?	chemistry	organic_chemistry	C	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
ad041f98-b102-428f-af61-3fcb3932ab0c	e1714ea9-0d01-4643-a7e5-d57e77196296	06	উত্তেজিত অবস্থায় হাইড্রোজেন পরমাণুর কোয়ান্টাম সংখ্যা $n = 4, l = 1$ বিশিষ্ট অরবিটালটি কি?	chemistry	qualitative_chemistry	B	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
9aaa9699-b55d-4ec4-a388-055c432e742c	e1714ea9-0d01-4643-a7e5-d57e77196296	07	$\\ce{CH3-CH(C2H5)-CH2-CHBr-CHCl-CH3}$ যৌগটির IUPAC নাম হলো- [IMAGE_1]	chemistry	organic_chemistry	D	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "chemical_structure", "box_2d": null, "filename": null, "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2019-2020-A-Unit/page_2", "extraction_status": "needs_review"}]	\N	\N
8c3a0a97-ed9f-4c12-acaf-bdcbbad422fa	e1714ea9-0d01-4643-a7e5-d57e77196296	08	কার্বন মৌল হীরা ও গ্রাফাইট-এ ভিন্নরূপ। এদের ক্ষেত্রে কোন উক্তিটি সত্য নয়?	chemistry	periodic_properties_of_elements_and_chemical_bonding	D	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
8217d294-a502-4f6a-b208-c62dcfffe02c	e1714ea9-0d01-4643-a7e5-d57e77196296	09	MRI যন্ত্রের সাহায্যে মানবদেহের রোগ নির্ণয়ে কোন মৌলটির ভূমিকা রয়েছে?	chemistry	qualitative_chemistry	C	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
5b753a9c-bc52-44d3-b843-a3689a895b35	e1714ea9-0d01-4643-a7e5-d57e77196296	10	নাইট্রেট অ্যানায়নে কয়টি ইলেকট্রন রয়েছে?	chemistry	qualitative_chemistry	D	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
ba63839e-0aa0-4751-9038-76320811eb23	e1714ea9-0d01-4643-a7e5-d57e77196296	11	$50\\,\\text{mL}$ তরল পরিমাপ করতে নিম্নের কোনটির ব্যবহার যথার্থ?	chemistry	safe_use_of_laboratory	B	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
7e2a200d-36b5-406b-bf8d-eb9986458db5	e1714ea9-0d01-4643-a7e5-d57e77196296	12	$0.98\\,\\text{g}$ $\\ce{H2SO4}$ ব্যবহার করে $1.0\\,\\text{L}$ জলীয় দ্রবণ তৈরি করা হলে। দ্রবণটির ঘনমাত্রা কত?	chemistry	quantitative_chemistry	C	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
fa2b9b58-980f-49d5-ae3f-e60173b6fb40	e1714ea9-0d01-4643-a7e5-d57e77196296	13	$\\ce{BaMnF4}$ এবং $\\ce{Li2MgFeF6}$ যৌগদ্বয়ে $\\ce{Mn}$ ও $\\ce{Fe}$ এর জারণ সংখ্যা যথাক্রমে-	chemistry	periodic_properties_of_elements_and_chemical_bonding	A	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
c6168bd7-37a5-4afc-8d9b-ee157d9eba01	e1714ea9-0d01-4643-a7e5-d57e77196296	14	কোনটি অম্লীয় জলীয় দ্রবণ তৈরি করে?	chemistry	environmental_chemistry	D	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
98cea303-757a-4474-8e7e-0b8afa2b0288	e1714ea9-0d01-4643-a7e5-d57e77196296	15	নিম্নের কোন পরীক্ষাটি সালফিউরিক এসিড ও নাইট্রিক এসিডের মধ্যে পার্থক্য করতে ব্যবহার করা যায়?	chemistry	qualitative_chemistry	D	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
80c5c9d7-d501-420c-a2a1-c1922ab19807	e1714ea9-0d01-4643-a7e5-d57e77196296	01.	$A = \\begin{pmatrix} 3 & -4 \\\\ 2 & -3 \\end{pmatrix}$ হলে, $\\text{det}(2A^{-1})$ এর মান হলো -	mathematics	matrices_and_determinants	B	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
23ba8888-8e6d-4dd8-8c37-f448819ee2ca	e1714ea9-0d01-4643-a7e5-d57e77196296	02.	$\\lim_{x \\to -\\infty} \\frac{\\sqrt{x^2 + 2x}}{-x}$ এর মান হলো-	mathematics	differential_calculus	A	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
da1e1550-a9a6-43e8-94e1-8581937d1d94	e1714ea9-0d01-4643-a7e5-d57e77196296	03.	$25x^2 + 16y^2 = 400$ উপবৃত্তের উৎকেন্দ্রিকতা কত?	mathematics	conics	D	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
6a27ed3e-e0af-40ab-b3d8-a064753c7ebe	e1714ea9-0d01-4643-a7e5-d57e77196296	04.	$\\int \\frac{dx}{(e^x + e^{-x})^2} = ?$	mathematics	integral_calculus	B	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
41cd39b1-ca7d-4575-b95c-fc839dc20cdf	e1714ea9-0d01-4643-a7e5-d57e77196296	05.	$\\cot(\\sin^{-1} \\frac{1}{2}) = ?$	mathematics	inverse_trigonometric_functions_and_trigonometric_equations	C	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
ecde36b4-4d95-4b69-b86b-952c1723f834	e1714ea9-0d01-4643-a7e5-d57e77196296	06.	$[0, 2]$ ব্যবধিতে $y = x - 1$ এবং $y = 0$ রেখা দ্বারা আবদ্ধ অঞ্চলের মোট ক্ষেত্রফল কত?	mathematics	integral_calculus	D	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "graph", "box_2d": null, "filename": null, "markdown": null, "page_index": 2, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2019-2020-A-Unit/page_3", "extraction_status": "needs_review"}]	\N	\N
62b45fa3-5a84-4c32-84a5-c2bd8fbf7309	e1714ea9-0d01-4643-a7e5-d57e77196296	07.	কোনো একটি বিন্দুতে ক্রিয়ারত $\\vec{p}$ ও $2\\vec{p}$ বলদ্বয়ের লব্ধি $\\sqrt{7}\\vec{p}$ হলে, তাদের মধ্যবর্তী কোণ কত?	mathematics	vectors	C	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
bc22adfe-a7ce-4ce7-b7b1-4b77be764eda	e1714ea9-0d01-4643-a7e5-d57e77196296	08.	যদি $f(x) = x^2 - 2|x|$ এবং $g(x) = x^2 + 1$ হয়, তাহলে $g(f(-2))$ এর মান কত?	mathematics	functions_and_graphs	B	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
6ca4ca64-aa11-49a8-b740-f4aa541d150e	e1714ea9-0d01-4643-a7e5-d57e77196296	10.	$(4, 3)$ কেন্দ্রবিশিষ্ট এবং $5x - 12y + 3 = 0$ সরলরেখাকে স্পর্শ করে এমন বৃত্তের সমীকরণ কোনটি?	mathematics	circles	B	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
91207fa5-34c4-4ff7-b892-2b63c864520d	e1714ea9-0d01-4643-a7e5-d57e77196296	11.	$\\vec{b} = 6\\hat{i} + 7\\hat{j} - 6\\hat{k}$ ভেক্টর বরাবর $\\vec{a} = 2\\hat{i} - 2\\hat{j} + \\hat{k}$ ভেক্টরের উপাংশ হলো-	mathematics	vectors	B	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
da7a4805-ff0e-4d85-8208-2a919d682dc1	e1714ea9-0d01-4643-a7e5-d57e77196296	12.	$(2x + \\frac{1}{8x})^8$ এর বিস্তৃতিতে $x$ বর্জিত পদের মান হলো-	mathematics	binomial_expansion	C	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
e4a4312d-9b7e-4862-a29f-2de94713cc60	e1714ea9-0d01-4643-a7e5-d57e77196296	13.	'GEOMETRY' শব্দটির বর্ণগুলোর সবগুলো একত্রে নিয়ে কত প্রকারে সাজানো যায় যেন প্রথম ও শেষ অক্ষর 'E' থাকে?	mathematics	permutations_and_combinations	C	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
085a79c7-14c3-4218-962f-e64b04e1c576	e1714ea9-0d01-4643-a7e5-d57e77196296	14.	$\\frac{1}{|3x - 1|} > 1$ এর সমাধান হলো-	mathematics	real_numbers_and_inequalities	D	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
5ffa9e49-ab9b-4f56-8ae1-82f03898b371	e1714ea9-0d01-4643-a7e5-d57e77196296	15.	$f(x) = \\sqrt{2 - \\sqrt{2 - x}}$ এর ডোমেইন হলো-	mathematics	functions_and_graphs	D	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
2008a1b5-2c4c-4190-aa4e-f4c56f50c794	e1714ea9-0d01-4643-a7e5-d57e77196296	01.	শিখা কোষ যে পর্বের বৈশিষ্ট্য?	biology	animal_diversity_and_classification	D	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	[{"id": "IMAGE_1", "kind": "table", "label": "data_table", "box_2d": null, "filename": null, "markdown": null, "page_index": 3, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2019-2020-A-Unit/page_4", "extraction_status": "needs_review"}]	\N	\N
e4c4feed-a17c-498d-9247-c5a43ea89ad9	e1714ea9-0d01-4643-a7e5-d57e77196296	02.	Poaceae গোত্রের উদ্ভিদের ফলকে বলা হয়-	biology	gymnosperms_and_angiosperms	B	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
aa8691c4-4ca8-4d64-be2c-fc2b10494982	e1714ea9-0d01-4643-a7e5-d57e77196296	03.	কোন প্রাণীতে প্লাকয়েড আঁইশ রয়েছে?	biology	animal_diversity_and_classification	A	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
860d75a9-b6b6-4674-95d6-85d0f8ba8233	e1714ea9-0d01-4643-a7e5-d57e77196296	04	পলিজিন এর প্রভাব-	biology	genetics_and_evolution	D	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
d41b3a01-c52b-4729-955d-8848a8d533e9	e1714ea9-0d01-4643-a7e5-d57e77196296	05	পনির তৈরিতে ব্যবহৃত এনজাইমের নাম-	biology	plant_physiology	B	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
f497e262-dfbe-44d7-9638-0c14d9b4a43e	e1714ea9-0d01-4643-a7e5-d57e77196296	06	মানুষদেহে ইমিউনোগ্লোবিনের কত ভাগ IgG?	biology	immunity_of_human_body	A	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	[{"id": "IMAGE_1", "kind": "table", "label": "data_table", "box_2d": null, "filename": null, "markdown": null, "page_index": 4, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2019-2020-A-Unit/page_5", "extraction_status": "needs_review"}]	\N	\N
6da1c88a-d204-4ade-97f4-9cae350814a5	e1714ea9-0d01-4643-a7e5-d57e77196296	07	কোনটি পত্রঝরা উদ্ভিদ?	biology	environment_expansion_and_conservation_of_organisms	C	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	[{"id": "IMAGE_1", "kind": "table", "label": "data_table", "box_2d": null, "filename": null, "markdown": null, "page_index": 4, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2019-2020-A-Unit/page_5", "extraction_status": "needs_review"}]	\N	\N
92929cc0-1722-42b5-b8c5-b1277a6f82b6	e1714ea9-0d01-4643-a7e5-d57e77196296	08	কোন হরমোনের উৎস পিটুইটারি গ্রন্থি নয়?	biology	human_physiology_coordination_and_control	B	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
9785367b-9c02-4c3a-abc8-67f09aa409c7	e1714ea9-0d01-4643-a7e5-d57e77196296	09	কোন অ্যামিনো অ্যাসিডের জন্য ৪টি কোড রয়েছে?	biology	genetics_and_evolution	C	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	[{"id": "IMAGE_1", "kind": "table", "label": "data_table", "box_2d": null, "filename": null, "markdown": null, "page_index": 4, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2019-2020-A-Unit/page_5", "extraction_status": "needs_review"}]	\N	\N
e13dfe24-27fd-489f-8b0a-06fbf736f560	e1714ea9-0d01-4643-a7e5-d57e77196296	10	মানব জিনোমে ক্ষারক-যুগলের সংখ্যা-	biology	genetics_and_evolution	D	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	[{"id": "IMAGE_1", "kind": "table", "label": "data_table", "box_2d": null, "filename": null, "markdown": null, "page_index": 4, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2019-2020-A-Unit/page_5", "extraction_status": "needs_review"}]	\N	\N
765add34-d5b1-4807-886c-3f7fed343151	e1714ea9-0d01-4643-a7e5-d57e77196296	11	কোন অঙ্গাণুতে অক্সিসোম দেখা যায়?	biology	cell_and_its_structure	A	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
4e63f36b-a4da-45a9-8d7f-4b5759d54f7d	e1714ea9-0d01-4643-a7e5-d57e77196296	12	মানুষের মস্তিষ্ক ও সুষুম্নাকাণ্ডের আবরণ কোনটি?	biology	human_physiology_coordination_and_control	A	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
f1f2e16b-2474-4dd0-835b-43f3e3bf8c26	e1714ea9-0d01-4643-a7e5-d57e77196296	13	অ্যাড্রেনাল গ্রন্থি থেকে কোন হরমোন নিঃসৃত হয়?	biology	human_physiology_coordination_and_control	A	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
6f88beac-bf8d-4706-b7a0-84a680424689	e1714ea9-0d01-4643-a7e5-d57e77196296	14	কোন উদ্ভিদটি বাংলাদেশে বিলুপ্তপ্রায়?	biology	environment_expansion_and_conservation_of_organisms	B	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	[{"id": "IMAGE_1", "kind": "table", "label": "data_table", "box_2d": null, "filename": null, "markdown": null, "page_index": 4, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2019-2020-A-Unit/page_5", "extraction_status": "needs_review"}]	\N	\N
9c0f0b25-fcc0-49df-a3ef-6df03929744a	e1714ea9-0d01-4643-a7e5-d57e77196296	15	কোনটির পরিবহনতন্ত্র আছে, কিন্তু ফুল হয় না?	biology	bryophyta_and_pteridophyta	C	\N	pending	2026-04-27 17:34:47.579053+00	Dhaka University	2019-2020	A	null	\N	\N
d0ff282d-2b31-4f6d-a72b-f0e522b93a60	e50bdce2-e49e-4b4a-8279-da972fe9d089	07.	$a$ এর মান কত হলে $\\vec{A} = 2\\hat{i} + 2\\hat{j} - \\hat{k}$ এবং $\\vec{B} = a\\hat{i} + \\hat{j}$ ভেক্টরদ্বয় পরস্পর লম্ব হবে?	physics	vector	A	\N	generated	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	দুটি ভেক্টর $\\vec{A}$ এবং $\\vec{B}$ পরস্পর লম্ব হওয়ার শর্ত হলো তাদের ডট গুণফল শূন্য হওয়া, অর্থাৎ $\\vec{A} \\cdot \\vec{B} = 0$। এখানে, $\\vec{A} = 2\\hat{i} + 2\\hat{j} - \\hat{k}$ এবং $\\vec{B} = a\\hat{i} + \\hat{j} + 0\\hat{k}$। ডট গুণফলের সূত্রানুসারে, $(2)(a) + (2)(1) + (-1)(0) = 0$। সমীকরণটি সমাধান করলে আমরা পাই, $2a + 2 = 0$ বা $2a = -2$, যা থেকে পাওয়া যায় $a = -1$। সুতরাং, $a$ এর মান $-1$ হলে ভেক্টরদ্বয় পরস্পর লম্ব হবে।	A
a1ae8350-1cd7-42bd-8999-4a5c1a275990	e50bdce2-e49e-4b4a-8279-da972fe9d089	10.	কোন ত্রুটি দূরীকরণে উত্তল লেন্স ব্যবহার করা হয়?	physics	geometrical_optics	B	\N	generated	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	দূর দৃষ্টি বা হাইপারমেট্রোপিয়া (Hypermetropia) ত্রুটির ক্ষেত্রে চোখের লেন্সের অভিসারী ক্ষমতা কমে যায় বা অক্ষিগোলকের ব্যাসার্ধ কমে যায়, ফলে প্রতিবিম্ব রেটিনার পেছনে গঠিত হয়। এই ত্রুটি দূর করার জন্য উত্তল লেন্স (Convex lens) ব্যবহার করা হয়, যা আলোক রশ্মিকে অভিসারী করে রেটিনার ওপর নিখুঁত প্রতিবিম্ব তৈরি করতে সাহায্য করে। অন্যদিকে, ক্ষীণ দৃষ্টি বা মায়োপিয়া (Myopia) প্রতিকারে অবতল লেন্স ব্যবহৃত হয়।	B
27cfb107-5cd9-4f06-9464-e31b0758e1a3	e50bdce2-e49e-4b4a-8279-da972fe9d089	12.	$14$ মিনিট পরে একটি তেজস্ক্রিয় মৌলের $\\frac{1}{16}$ অংশ অবশিষ্ট থাকে। এর অর্ধায়ু হবে?	physics	atomic_model_and_nuclear_physics	C	\N	generated	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	তেজস্ক্রিয় ক্ষয়ের সূত্রানুসারে, অবশিষ্ট অংশ $\\frac{N}{N_0} = (\\frac{1}{2})^n$, যেখানে $n$ হলো অর্ধায়ুর সংখ্যা। এখানে দেওয়া আছে $\\frac{N}{N_0} = \\frac{1}{16} = (\\frac{1}{2})^4$, সুতরাং $n = 4$। আমরা জানি, মোট সময় $t = n \\times T_{1/2}$। অতএব, অর্ধায়ু $T_{1/2} = \\frac{t}{n} = \\frac{14}{4} = \\frac{7}{2}\\,\\text{min}$।	C
91b366bd-9fda-470d-99fa-9daae2309649	e50bdce2-e49e-4b4a-8279-da972fe9d089	09.	স্থিতিস্থাপক গুণাঙ্কের মাত্রা কী?	physics	structural_properties_of_matter	B	\N	generated	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	স্থিতিস্থাপক গুণাঙ্ক হলো পীড়ন ও বিকৃতির অনুপাত। বিকৃতি একটি মাত্রাহীন রাশি হওয়ায় স্থিতিস্থাপক গুণাঙ্কের মাত্রা পীড়নের মাত্রার সমান। পীড়ন হলো একক ক্ষেত্রফলের ওপর প্রযুক্ত বল, অর্থাৎ $\\text{Stress} = \\frac{F}{A}$। এর মাত্রা হলো $\\frac{[MLT^{-2}]}{[L^2]} = [ML^{-1}T^{-2}]$। সুতরাং, স্থিতিস্থাপক গুণাঙ্কের মাত্রা হলো $[ML^{-1}T^{-2}]$।	B
4706a514-8c18-4c10-911a-ca041142edc2	e50bdce2-e49e-4b4a-8279-da972fe9d089	02.	কোনো আদর্শ গ্যাসের তাপমাত্রা কেলভিন স্কেলে $4$ গুণ বৃদ্ধি পেলে তার অণুগুলোর মূল গড় বর্গবেগ কত গুণ বৃদ্ধি পায়?	physics	ideal_gas_and_gas_kinetics	C	\N	generated	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	আদর্শ গ্যাসের অণুগুলোর মূল গড় বর্গবেগ ($v_{rms}$) এবং পরম তাপমাত্রার ($T$) মধ্যে সম্পর্ক হলো $v_{rms} = \\sqrt{\\frac{3RT}{M}}$, অর্থাৎ $v_{rms} \\propto \\sqrt{T}$। প্রশ্নমতে, তাপমাত্রা $4$ গুণ বৃদ্ধি করা হলে নতুন তাপমাত্রা হয় $T_2 = 4T_1$। সুতরাং নতুন মূল গড় বর্গবেগ হবে $v_2 \\propto \\sqrt{4T_1} = 2\\sqrt{T_1} = 2v_1$। অর্থাৎ, অণুগুলোর মূল গড় বর্গবেগ $2$ গুণ হবে।	C
314c5e8f-d335-43b8-9d15-98ddd83054ac	e50bdce2-e49e-4b4a-8279-da972fe9d089	04.	কত বেগে চললে একটি রকেটের গতিশীল দৈর্ঘ্য এর নিশ্চল দৈর্ঘ্যের অর্ধেক হবে?	physics	introduction_to_modern_physics	B	\N	generated	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	দৈর্ঘ্য সংকোচনের সূত্রানুসারে, গতিশীল দৈর্ঘ্য $L = L_0 \\sqrt{1 - \\frac{v^2}{c^2}}$। এখানে দেওয়া আছে যে গতিশীল দৈর্ঘ্য নিশ্চল দৈর্ঘ্যের অর্ধেক, অর্থাৎ $L = \\frac{1}{2} L_0$। সমীকরণে মান বসিয়ে পাই, $\\frac{1}{2} L_0 = L_0 \\sqrt{1 - \\frac{v^2}{c^2}}$ বা $\\frac{1}{4} = 1 - \\frac{v^2}{c^2}$। এখান থেকে পাওয়া যায় $\\frac{v^2}{c^2} = 1 - \\frac{1}{4} = \\frac{3}{4}$, সুতরাং $v = \\frac{\\sqrt{3}}{2}c$।	B
8fd95e13-4647-45f0-9000-6db05b6026e8	e50bdce2-e49e-4b4a-8279-da972fe9d089	01	হাইড্রোনিয়াম আয়নে কোন কোন বন্ধন বিদ্যমান?	chemistry	periodic_properties_of_elements_and_chemical_bonding	C	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
21061bb7-2fad-4900-a39c-a8b7c7d4de4d	e50bdce2-e49e-4b4a-8279-da972fe9d089	02	ক্রোমিক অ্যাসিড দ্বারা কাঁচপাত্র পরিষ্কার করার সময় কোন ধরনের বিক্রিয়া ঘটে?	chemistry	qualitative_chemistry	D	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
7d461d8e-72d3-43c3-b1d0-12d0b4e3d772	e50bdce2-e49e-4b4a-8279-da972fe9d089	03	বিশুদ্ধ পানিতে $\\ce{OH-}$ এবং $\\ce{H+}$ এর মোলার ঘনমাত্রা এর অনুপাত কত?	chemistry	chemical_changes	D	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
4231fa1b-a194-4a21-9db1-38f8030b9a6e	e50bdce2-e49e-4b4a-8279-da972fe9d089	04	অষ্টক সম্প্রসারণ এর উদাহরণ কোনটি?	chemistry	periodic_properties_of_elements_and_chemical_bonding	B	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
163a9454-4b90-4405-af92-d6bfd760718a	e50bdce2-e49e-4b4a-8279-da972fe9d089	05	নিচের কোন তড়িৎদ্বারটির প্রমাণ বিজারণ বিভবের মান সবচেয়ে কম?	chemistry	electrochemistry	C	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
fd7ced10-1180-4fde-90ed-9381a96b789e	e50bdce2-e49e-4b4a-8279-da972fe9d089	06	$\\ce{aA -> bB}$ বিক্রিয়াটির ক্ষেত্রে কোনটি বিক্রিয়ার হার নির্দেশ করে?	chemistry	chemical_changes	B	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
a7d85557-9917-4bab-af32-d9673fe57186	e50bdce2-e49e-4b4a-8279-da972fe9d089	07	দুধের প্রোটিন কোনটি?	chemistry	vocational_chemistry	C	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
7e61a652-0e81-456b-9c02-97f81dd7a84b	e50bdce2-e49e-4b4a-8279-da972fe9d089	08	নিচের কোন যৌগটি সিলভার দর্পণ পরীক্ষা দেয়?	chemistry	organic_chemistry	D	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
0c0333a8-db06-4c7b-bea0-578be51a63df	e50bdce2-e49e-4b4a-8279-da972fe9d089	09	বেনজিন বলয় সক্রিয়কারী মূলক কোনটি?	chemistry	organic_chemistry	C	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
caf34160-873b-451e-ba8e-aefcf0a5e2d9	e50bdce2-e49e-4b4a-8279-da972fe9d089	10	$\\ce{NaCl}$ এর সাথে $\\ce{H2O}$ যোগ করলে কোনটি ঘটে?	chemistry	qualitative_chemistry	A	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
f59f0363-3312-4d2b-b7f0-4a67e92a6d43	e50bdce2-e49e-4b4a-8279-da972fe9d089	11	$R_H$ রিডবার্গ ধ্রুবক হলে, হাইড্রোজেন পরমাণুর বর্ণালিতে বামার সিরিজের জন্য সর্বনিম্ন কত তরঙ্গ সংখ্যার রশ্মি বিকিরিত হয়?	chemistry	qualitative_chemistry	B	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
9758b3e8-e5f5-4bad-a925-609b556c384d	e50bdce2-e49e-4b4a-8279-da972fe9d089	12	নিম্নের বিক্রিয়াগুলো হতে কার্বনের গণনাকৃত দহনতাপ হলো—\ni. $\\ce{C(s) + 1/2 O2(g) -> CO(g); \\Delta H = -111 kJ/mol}$\nii. $\\ce{CO(g) + 1/2 O2(g) -> CO2(g); \\Delta H = -283 kJ/mol}$	chemistry	chemical_changes	B	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
f5711a00-a72f-4b09-ac83-19de367a4db1	e50bdce2-e49e-4b4a-8279-da972fe9d089	13	$\\ce{As}$ এ কয়টি যোজন ইলেকট্রন আছে?	chemistry	periodic_properties_of_elements_and_chemical_bonding	C	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
a51d7c27-ebce-4cc4-9b5b-441d5ff104c8	e50bdce2-e49e-4b4a-8279-da972fe9d089	14	অ্যালকাইল হ্যালাইডের $E_2$ অপসারণ বিক্রিয়ায়, অ্যালকোহলিক $\\ce{KOH/NaOH}$ এর ভূমিকা হলো-	chemistry	organic_chemistry	A	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
fec8cafa-9a31-4118-997a-2dc4ff1452d9	e50bdce2-e49e-4b4a-8279-da972fe9d089	15	নিচের কোনটি সত্য নয়?	chemistry	quantitative_chemistry	D	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
e22a26cf-e7ce-464b-b19c-7fe1766f7c72	e50bdce2-e49e-4b4a-8279-da972fe9d089	01	$x^2 - 2x + 1 = 0$ সমীকরণটির মূলদ্বয়ের ত্রিঘাত এর সমষ্টি হলো-	mathematics	polynomials_and_polynomial_equations	A	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
5e0e6008-65cb-4a3f-9135-33ca1bbef1ee	e50bdce2-e49e-4b4a-8279-da972fe9d089	02	$2x = y^2 + 8y + 22$ পরাবৃত্তের শীর্ষবিন্দুর স্থানাঙ্ক হবে-	mathematics	conics	A	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
d731f844-7267-4331-8e61-e9b3d4f84248	e50bdce2-e49e-4b4a-8279-da972fe9d089	03	$\\lim_{x \\to 0} \\frac{1 - \\cos x}{\\sin^2 2x}$ এর মান হবে-	mathematics	differential_calculus	B	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
36cf314e-7f2e-4dbb-9f51-3b44b39668a9	e50bdce2-e49e-4b4a-8279-da972fe9d089	04	$\\int_{0}^{2} |x - 1| dx = ?$	mathematics	integral_calculus	B	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	[{"id": "IMAGE_1", "kind": "table", "label": "data_table", "box_2d": null, "filename": null, "markdown": null, "page_index": 2, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2020-2021-A-Unit/page_3", "extraction_status": "needs_review"}]	\N	\N
cb064a5d-b595-47d2-82f0-62cae4d01f6e	e50bdce2-e49e-4b4a-8279-da972fe9d089	05	$\\frac{d}{dx} \\{\\cos^2(\\ln x)\\} = ?$	mathematics	differential_calculus	\N	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
0e6f388d-33a0-4f0a-88e4-3e5b6f56072e	e50bdce2-e49e-4b4a-8279-da972fe9d089	06	যদি $A, B, C$ ম্যাট্রিক্স তিনটির আকার যথাক্রমে $4 \\times 5, 5 \\times 5$ এবং $4 \\times 2$ হয়, তবে $(A^T + B)C$ ম্যাট্রিক্সটির আকার কী?	mathematics	matrices_and_determinants	C	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
4d48eb67-9224-4cda-ada6-72237c81dc55	e50bdce2-e49e-4b4a-8279-da972fe9d089	07	$\\text{cosec} \\theta + \\cot \\theta = \\sqrt{3}$ $(0 < \\theta < \\pi)$ হলে, $\\theta$ এর মান হবে-	mathematics	inverse_trigonometric_functions_and_trigonometric_equations	B	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
f03efe1d-a96d-45db-ad85-9a0ef8dad3e7	e50bdce2-e49e-4b4a-8279-da972fe9d089	09.	$(1+x)^7(1-x)^8$ এর বিস্তৃতিতে $x^7$ এর সহগ হলো-	mathematics	binomial_expansion	D	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
2518e0e8-9206-4450-b11a-13117a8ad1e1	e50bdce2-e49e-4b4a-8279-da972fe9d089	10.	যদি $y = kx(2x + \\sqrt{3})$ বক্ররেখার মূলবিন্দুতে স্পর্শকটি $x$-অক্ষের সাথে $30^\\circ$ কোণ উৎপন্ন করে তাহলে $k$ এর মান হবে-	mathematics	differential_calculus	B	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
25d93e66-2e35-4311-a08a-e1daf77f5cd5	e50bdce2-e49e-4b4a-8279-da972fe9d089	11.	$x = a \\cos\\theta + b \\sin\\theta, y = a \\sin\\theta - b \\cos\\theta$ কোন কনিকের সমীকরণ-	mathematics	conics	C	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
028d89d9-6378-4d7b-b939-154744a0ee83	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	08	$\\ce{NH4^+}$ আয়নের উপস্থিতি নির্ণয়ে ব্যবহৃত বিকারকটি হলো-	chemistry	qualitative_chemistry	C	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
1d109fae-1ac2-4f89-8067-e9ba7c36622d	e50bdce2-e49e-4b4a-8279-da972fe9d089	12.	তিনটি ছক্কা একবারে নিক্ষেপ করা হলে তিনটিতেই একই সংখ্যা পাওয়ার সম্ভাবনা কত?	mathematics	measure_of_dispersion_and_probability	D	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
87e9fd93-2808-42fd-b422-83f211bb7322	e50bdce2-e49e-4b4a-8279-da972fe9d089	13.	$f(x) = \\sqrt{3 - \\sqrt{x - 2}}$ ফাংশনটির ডোমেন কত?	mathematics	functions_and_graphs	C	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
cfc4d4f2-7399-4d28-a66d-32cad02fe053	e50bdce2-e49e-4b4a-8279-da972fe9d089	14.	পোলার স্থানাঙ্কে $r^2 - 2r \\sin\\theta = 3$ একটি বৃত্তের সমীকরণ বৃত্তটির ব্যাসার্ধ হবে-	mathematics	circles	A	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
c92c73b1-0152-4405-a2fa-756266d65d68	e50bdce2-e49e-4b4a-8279-da972fe9d089	15.	$2u$ আদিবেগ এবং অনুভূমিকের সাথে লম্বভাবে প্রক্ষিপ্ত বস্তুর সর্বোচ্চ উচ্চতা হবে-	mathematics	dynamics	B	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
00b03986-74f2-40b4-9af6-ce3925b007dc	e50bdce2-e49e-4b4a-8279-da972fe9d089	01.	নিচের কোনটিতে কোরালয়েড মূল পাওয়া যায়?	biology	gymnosperms_and_angiosperms	A	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
e8ee2da2-bf87-4c75-8c8f-2e9c0d8f6ffa	e50bdce2-e49e-4b4a-8279-da972fe9d089	02.	দ্বৈত প্রচ্ছন্ন এপিস্ট্যাসিস-এর অনুপাত হলো-	biology	genetics_and_evolution	C	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
5f20e571-1124-47e8-b85d-e3e560f8f78c	e50bdce2-e49e-4b4a-8279-da972fe9d089	03.	চ্যাপ্টা কৃমির বৈজ্ঞানিক নাম কি?	biology	animal_diversity_and_classification	B	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
e49544ab-0be3-452c-8c27-063d7ccdfd9a	e50bdce2-e49e-4b4a-8279-da972fe9d089	04.	ম্যান্টল নিচের কোন পর্বের বৈশিষ্ট্য?	biology	animal_diversity_and_classification	B	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
b9d4bc25-127c-4c39-bb6a-f74fab2daa5b	e50bdce2-e49e-4b4a-8279-da972fe9d089	05.	উদ্ভিদের রোম অথবা ট্রাইকোম কোনটির অংশ?	biology	tissue_and_tissue_system	A	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
3e67f4a4-ca8a-4bd9-9ee2-e16bd6c81433	e50bdce2-e49e-4b4a-8279-da972fe9d089	06.	প্রোফেজ-১ এর কোন পর্যায়ে কায়াজমা সৃষ্টি হয়?	biology	cell_division	D	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
a3aaef78-8e59-433f-ac68-4519f4760806	e50bdce2-e49e-4b4a-8279-da972fe9d089	07.	মানবদেহের রক্তের প্লাজমার স্বাভাবিক pH কত?	biology	human_physiology_blood_and_circulation	B	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
ac9c2eda-3782-4ada-810c-06a385ce0a78	e50bdce2-e49e-4b4a-8279-da972fe9d089	08.	মানবদেহে স্টেম কোষ কোথায় পাওয়া যায়?	biology	human_physiology_blood_and_circulation	C	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
d08735b1-aae3-42f7-8532-2c5c6bc6c925	e50bdce2-e49e-4b4a-8279-da972fe9d089	09.	পতঙ্গের অসম্পূর্ণ রূপান্তর নিম্নলিখিত কোন ধাপগুলো নিয়ে গঠিত?	biology	animal_identity	A	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
b97ea374-8a87-4ee2-a8b4-90834d50371a	e50bdce2-e49e-4b4a-8279-da972fe9d089	10.	জলাভূমির উদ্ভিদ কোনটি?	biology	environment_expansion_and_conservation_of_organisms	B	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
f518c5a0-69dd-4fb3-8e38-173f7491c10d	e50bdce2-e49e-4b4a-8279-da972fe9d089	11.	কোন ব্যাকটেরিয়ার একটিমাত্র ফ্ল্যাজেলাম থাকে?	biology	microorganisms	B	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
f3ccae87-8df4-45b5-a2f8-f092d524eaa9	e50bdce2-e49e-4b4a-8279-da972fe9d089	12.	নিচের কোনটিতে একিনিটি এবং হেটারোসিস্ট পাওয়া যায়?	biology	algae_and_fungi	B	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
39dd46a2-325a-4193-8e31-6dfdfc974b3a	e50bdce2-e49e-4b4a-8279-da972fe9d089	13.	কোন কোডনটি কোনো অ্যামিনো অ্যাসিড নির্দেশ করে না?	biology	cell_chemistry	C	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
aac47faa-1e1c-444f-8beb-d6e87baf4e7e	e50bdce2-e49e-4b4a-8279-da972fe9d089	14.	নিচের কোন অ্যান্টিবডি বুকের দুধের মাধ্যমে প্রবাহিত হয়?	biology	immunity_of_human_body	B	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
a07a61b1-3cd7-476b-89f6-8a8c7efa8e60	e50bdce2-e49e-4b4a-8279-da972fe9d089	15.	মানবদেহের কটিদেশীয় অঞ্চলে কশেরুকার সংখ্যা কত?	biology	human_physiology_locomotion_and_movement	B	\N	pending	2026-04-27 17:34:47.627909+00	Dhaka University	2020-2021	A	null	\N	\N
e9c58f65-779c-4040-94a0-db21a41f3a7a	05a449d9-5db0-488f-936f-ab50cc72299e	03	একটি ব্রিজ রেক্টিফায়ার বর্তনীর ইনপুট সংকেতের কম্পাঙ্ক $50\\,\\text{Hz}$ হলে এর আউটপুট সংকেতের কম্পাঙ্ক কত হবে?	physics	semiconductor_and_electronics	D	\N	generated	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	একটি ব্রিজ রেক্টিফায়ার হলো পূর্ণ-তরঙ্গ রেক্টিফায়ার (Full-wave rectifier)। পূর্ণ-তরঙ্গ রেক্টিফায়ারের ক্ষেত্রে আউটপুট কম্পাঙ্ক ইনপুট কম্পাঙ্কের দ্বিগুণ হয়, অর্থাৎ $f_{out} = 2f_{in}$। এখানে ইনপুট কম্পাঙ্ক $f_{in} = 50\\,\\text{Hz}$ দেওয়া আছে। অতএব, আউটপুট কম্পাঙ্ক হবে $f_{out} = 2 \\times 50\\,\\text{Hz} = 100\\,\\text{Hz}$।	D
860c1fc9-5098-4d31-856f-94e217189509	05a449d9-5db0-488f-936f-ab50cc72299e	11.	$6\\frac{d^2x}{dt^2} + 150x = 0$ তরঙ্গের কৌণিক কম্পাঙ্ক কত?	physics	periodic_motion	B	\N	generated	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	প্রদত্ত সমীকরণটি হলো $6\\frac{d^2x}{dt^2} + 150x = 0$। এটি সরল ছন্দিত গতির (Simple Harmonic Motion) একটি সমীকরণ। সরল ছন্দিত গতির আদর্শ সমীকরণ হলো $\\frac{d^2x}{dt^2} + \\omega^2x = 0$, যেখানে $\\omega$ হলো কৌণিক কম্পাঙ্ক। প্রদত্ত সমীকরণটিকে আদর্শ রূপে আনতে, আমরা এটিকে 6 দ্বারা ভাগ করি: $$\\frac{d^2x}{dt^2} + \\frac{150}{6}x = 0$$ $$\\frac{d^2x}{dt^2} + 25x = 0$$ এখন, আদর্শ সমীকরণের সাথে তুলনা করে পাই, $\\omega^2 = 25$। সুতরাং, কৌণিক কম্পাঙ্ক $\\omega = \\sqrt{25} = 5\\,\\text{rad/s}$।	B
24c0e56f-d2c6-4418-ae77-a82a0b94ee74	05a449d9-5db0-488f-936f-ab50cc72299e	15.	একটি প্রত্যাবর্তী চক্রাকার প্রক্রিয়ার এক চক্রের পরে নিচের কোনটি শূন্য নাও হতে পারে? (এখানে $U = $ অভ্যন্তরীণ শক্তি, $P = $ চাপ, $W = $ সিস্টেমের দ্বারা কৃতকাজ, $S = $ এনট্রপি)	physics	thermodynamics	B	\N	generated	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	একটি প্রত্যাবর্তী চক্রাকার প্রক্রিয়ার ক্ষেত্রে, অভ্যন্তরীণ শক্তি ($U$), চাপ ($P$) এবং এনট্রপি ($S$) হলো অবস্থা অপেক্ষক (state functions)। এর অর্থ হলো, এক চক্র সম্পন্ন হওয়ার পর সিস্টেম তার আদি অবস্থায় ফিরে আসে, তাই এই রাশিগুলোর মোট পরিবর্তন শূন্য হয়। অর্থাৎ, $\\Delta U = 0$, $\\Delta P = 0$ এবং প্রত্যাবর্তী প্রক্রিয়ার জন্য $\\Delta S = 0$। কিন্তু, সিস্টেমের দ্বারা কৃতকাজ ($W$) একটি অবস্থা অপেক্ষক নয়। একটি চক্রাকার প্রক্রিয়ায়, P-V চিত্রে চক্র দ্বারা আবদ্ধ ক্ষেত্রফলই হলো মোট কৃতকাজ, যা সাধারণত শূন্য হয় না। তাই, এক চক্রের পরে $W$ শূন্য নাও হতে পারে।	B
506e8e63-da7f-47f5-8881-520caa7dc5cc	05a449d9-5db0-488f-936f-ab50cc72299e	01.	গ্রাফাইটে কোন ধরনের সংকরণ বিদ্যমান?	chemistry	periodic_properties_of_elements_and_chemical_bonding	B	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
0ca6f1c1-df84-42ea-9935-b6d2003e8887	05a449d9-5db0-488f-936f-ab50cc72299e	02.	নিচের কোনটি অসামঞ্জস্যকরণ বিক্রিয়া?	chemistry	chemical_changes	C	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
af4ee6a2-b349-4f56-9724-57e7f5733462	05a449d9-5db0-488f-936f-ab50cc72299e	03.	অনাব্র $\\ce{AlCl3}$-এর উপস্থিতিতে বেনজিনের সাথে অ্যাসিটাইল ক্লোরাইডের বিক্রিয়ায় উৎপন্ন হয়-	chemistry	organic_chemistry	B	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "chemical_reaction", "box_2d": null, "filename": null, "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": "token/file count mismatch on page 2: 2 tokens vs 1 files", "extraction_status": "needs_review"}]	\N	\N
ba5d1800-a552-426d-9a25-00a730f96b55	05a449d9-5db0-488f-936f-ab50cc72299e	04	ড্যানিয়েল কোষে যে সকল ধাতু ইলেকট্রোড হিসেবে ব্যবহৃত হয় তা হলো-	chemistry	electrochemistry	B	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
f27e5ca4-e904-425b-bdcd-e48d13279251	05a449d9-5db0-488f-936f-ab50cc72299e	05	$\\ce{CH3MgX}$ এর সাথে নিচের কোন যৌগটির বিক্রিয়ায় আইসোপ্রোপানল উৎপন্ন হয়?	chemistry	organic_chemistry	B	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
06124444-db56-443e-8025-1c2c369f8576	05a449d9-5db0-488f-936f-ab50cc72299e	13.	একটি ইলেকট্রনকে $V$ বিভব পার্থক্যের মধ্যে রাখলে, ইলেকট্রনের বেগ $v$ এবং প্রযুক্ত বিভব পার্থক্যের মধ্যে সম্পর্ক কোনটি?	physics	introduction_to_modern_physics	B	\N	generated	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	একটি ইলেকট্রনকে $V$ বিভব পার্থক্যের মধ্য দিয়ে ত্বরান্বিত করলে এর ওপর সম্পাদিত কাজ বা অর্জিত গতিশক্তি হয় $W = eV$। আমরা জানি, গতিশক্তির সমীকরণ হলো $K = \\frac{1}{2}mv^2$। শক্তির সংরক্ষণশীলতা নীতি অনুযায়ী, $\\frac{1}{2}mv^2 = eV$। এখান থেকে বেগের মান নির্ণয় করলে পাওয়া যায় $v^2 = \\frac{2eV}{m}$ বা $v = \\sqrt{\\frac{2eV}{m}}$। সুতরাং, ইলেকট্রনের বেগ এবং বিভব পার্থক্যের সঠিক সম্পর্কটি হলো $v = \\sqrt{\\frac{2eV}{m}}$।	B
f29d26aa-a051-4d45-b580-7f49cc55ac8e	05a449d9-5db0-488f-936f-ab50cc72299e	12.	শূন্য ভর এবং $E$ শক্তিবিশিষ্ট একটি কণার ভরবেগ কোনটি?	physics	introduction_to_modern_physics	B	\N	generated	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	আপেক্ষিক তত্ত্ব অনুযায়ী কোনো কণার মোট শক্তি $E$, ভরবেগ $p$ এবং নিশ্চল ভর $m_0$ এর মধ্যে সম্পর্ক হলো $E^2 = (pc)^2 + (m_0 c^2)^2$। প্রশ্নে বলা হয়েছে কণাটির ভর শূন্য, অর্থাৎ $m_0 = 0$। ফলে সমীকরণটি দাঁড়ায় $E^2 = (pc)^2$ বা $E = pc$। সুতরাং, কণাটির ভরবেগ হবে $p = \\frac{E}{c}$।	B
3d653d1d-9292-4d8c-80c1-d0336f774115	05a449d9-5db0-488f-936f-ab50cc72299e	06	একটি আদর্শ গ্যাসের জন্য PV বনাম $\\frac{1}{P}$ লেখচিত্র হবে একটি-	chemistry	environmental_chemistry	C	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "graph", "box_2d": null, "filename": null, "markdown": null, "page_index": 2, "caption_hint": "চিত্র-১: PV বনাম 1/P লেখচিত্র", "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2021-2022-A-Unit/page_3", "extraction_status": "needs_review"}]	\N	\N
21f09b4d-acc7-460a-add5-a6575c72228e	05a449d9-5db0-488f-936f-ab50cc72299e	07	$\\ce{C5H12}$ যৌগের গাঠনিক সমাণু কয়টি?	chemistry	organic_chemistry	B	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
b0671e9e-0c42-4d18-a448-53489fe11a54	05a449d9-5db0-488f-936f-ab50cc72299e	08	$\\ce{C2H5OH}$ জারিত হয়ে তৈরি হয় Z, যা $\\ce{C2H5OH}$-এর সাথে এস্টার প্রস্তুত করে। Z কী?	chemistry	organic_chemistry	B	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
d0386e47-4ec0-4aec-a41d-ec1fe5d8402e	05a449d9-5db0-488f-936f-ab50cc72299e	09	সোডিয়াম ধাতু সংরক্ষণের জন্য নিচের কোনটি উপযুক্ত?	chemistry	periodic_properties_of_elements_and_chemical_bonding	D	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
26a90ee1-1a28-4f25-99c1-62d64f2b39df	05a449d9-5db0-488f-936f-ab50cc72299e	10	কোন উপস্তরটি সম্ভব নয়?	chemistry	qualitative_chemistry	A	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
8e986fe2-243a-4893-8431-948c849deb63	05a449d9-5db0-488f-936f-ab50cc72299e	11	কোন যৌগটি সরলরৈখিক নয়?	chemistry	periodic_properties_of_elements_and_chemical_bonding	B	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	[{"id": "IMAGE_1", "kind": "table", "label": "data_table", "box_2d": null, "filename": null, "markdown": null, "page_index": 2, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2021-2022-A-Unit/page_3", "extraction_status": "needs_review"}]	\N	\N
d11b362d-bff5-4d65-b63e-b8139343688d	05a449d9-5db0-488f-936f-ab50cc72299e	12	কোনটি ক্ষারীয় বাফার দ্রবণ?	chemistry	chemical_changes	D	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
cdb7ecbd-2d79-40bd-b8e3-2dd27475cbe5	05a449d9-5db0-488f-936f-ab50cc72299e	13	হাইড্রোজেন গ্যাসের ব্যাপনের হার কোনো একটি গ্যাসের ব্যাপনের হারের ৬ গুণ। গ্যাসটির আণবিক ভর কত?	chemistry	environmental_chemistry	B	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
ffa877c4-87a7-45ff-b8a7-2ef85befb511	05a449d9-5db0-488f-936f-ab50cc72299e	14	C, O, N এবং F-এর তড়িৎ ঋণাত্মকতার সঠিক ক্রম কোনটি?	chemistry	periodic_properties_of_elements_and_chemical_bonding	A	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
976f19b3-8283-4bf1-84bc-bc7eaeb09d25	05a449d9-5db0-488f-936f-ab50cc72299e	15	নিচের বিক্রিয়াসমূহের মধ্যে কোনটির জন্য $K_p = K_c$?	chemistry	chemical_changes	B	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
2a38065a-9145-4fec-a7d9-01b7f1c55f82	05a449d9-5db0-488f-936f-ab50cc72299e	01.	$k$ এর কোন মানের জন্য $2x^2 - kx + 1 = 0$ এর একটি মূল অপর মূলের বর্গের চারগুণের সমান হবে?	mathematics	polynomials_and_polynomial_equations	B	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
4fe12ae0-7d60-4acb-8993-3e1433dd7597	05a449d9-5db0-488f-936f-ab50cc72299e	02.	$\\text{cosec}^2(\\tan^{-1} \\frac{1}{2}) - 3 \\sec^2(\\cot^{-1} \\sqrt{3}) = ?$	mathematics	inverse_trigonometric_functions_and_trigonometric_equations	C	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
9bc067b9-4270-4234-8748-7386739d0d7f	05a449d9-5db0-488f-936f-ab50cc72299e	03.	একটি উপবৃত্তের উপকেন্দ্রিক লম্বের দৈর্ঘ্য বৃহদাক্ষের দৈর্ঘ্যের অর্ধেক, উপবৃত্তটির উৎকেন্দ্রিকতা কত?	mathematics	conics	B	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
a958569f-32fe-46d5-9bd9-676fa92f39ba	05a449d9-5db0-488f-936f-ab50cc72299e	04.	$k$ এর কোন মানের জন্য $x = 1$ বিন্দুতে $f(x) = x^2 + \\frac{k}{x}$ এর লঘুমান পাওয়া যাবে?	mathematics	differential_calculus	C	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
91e8a796-bdb3-4b28-8f5e-573eaf629d1e	05a449d9-5db0-488f-936f-ab50cc72299e	05.	কোনো একটি বিন্দুতে ক্রিয়ারত $2N$ ও $2\\sqrt{2}N$ বলদ্বয়ের লব্ধি $2\\sqrt{5}N$ হলে, তাদের মধ্যবর্তী কোণ-	mathematics	statics	B	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
d7f81656-4ebe-4f48-8eb2-571d40e72f47	05a449d9-5db0-488f-936f-ab50cc72299e	06.	$\\frac{1}{x} + a - bx = 0$ সমীকরণের মূলদ্বয় সমান হলে কোনটি সঠিক?	mathematics	polynomials_and_polynomial_equations	D	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
8442c1ae-8af4-4f4c-bf2e-2e1c677651cb	05a449d9-5db0-488f-936f-ab50cc72299e	07.	$3x + 4y = k$ রেখাটি $x^2 + y^2 = 10x$ বৃত্তকে স্পর্শ করে। $k$ এর মান কত?	mathematics	circles	C	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
d9c63a71-5c7c-46cc-bfbb-80c8d08a6aef	05a449d9-5db0-488f-936f-ab50cc72299e	08.	কোন ব্যবধিতে $f(x) = \\frac{x}{x^2 + 1}$ ক্রমবর্ধমান?	mathematics	differential_calculus	B	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
8a09e10c-661b-4dc2-b8f3-aa7caa3b4491	05a449d9-5db0-488f-936f-ab50cc72299e	09.	কোনো বিন্দুর পোলার স্থানাঙ্ক $(c, \\pi)$ হলে বিন্দুটির কার্তেসীয় স্থানাঙ্ক কত?	mathematics	straight_lines	B	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
84dc9e5e-4d44-4a78-ab10-fd9be21b5286	05a449d9-5db0-488f-936f-ab50cc72299e	10.	$y^2 = 8x + 2y - 9$ পরাবৃত্তটির উপকেন্দ্রের স্থানাঙ্ক কত?	mathematics	conics	A	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
5de2a6c8-5daf-4557-a702-ad17cef4807f	05a449d9-5db0-488f-936f-ab50cc72299e	11.	$x^2 - 3y^2 - 2x = 8$ অধিবৃত্তের শীর্ষবিন্দুদ্বয়	mathematics	conics	D	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
87282edf-d675-42ea-8f03-ec8e09031ebf	05a449d9-5db0-488f-936f-ab50cc72299e	12.	$A = \\begin{bmatrix} 1 & 2 \\\\ 2 & 5 \\end{bmatrix}$ হলে, $\\text{det}(AA^{-1})$ এর মান কত?	mathematics	matrices_and_determinants	A	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
a71e6d04-65d2-4501-b36e-e3972c5433c6	05a449d9-5db0-488f-936f-ab50cc72299e	13	কোন ফাংশনটির জন্য $(1-x^2) \\frac{d^2y}{dx^2} - x \\frac{dy}{dx} = 2$ সত্য?	mathematics	differential_calculus	B	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
7de8c5bf-f5e8-4f99-a494-f8cf267eb2b0	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	09	দুধ থেকে ছানা তৈরির প্রক্রিয়া হলো-	chemistry	qualitative_chemistry	C	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
1b0029c4-1cbe-42bf-8d58-65f2ca53bfd1	05a449d9-5db0-488f-936f-ab50cc72299e	14	$x - 3y - 2 = 0$ রেখার ওপর অবস্থিত $P$ বিন্দুটি $(2, 3)$ এবং $(6, -5)$ হতে সমদূরবর্তী হতে $P$ বিন্দুর স্থানাঙ্ক কত?	mathematics	straight_lines	C	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
717a93bf-59cc-4db8-b817-682d44652d82	05a449d9-5db0-488f-936f-ab50cc72299e	15	$\\int_{-2}^{-1} (x + |x|) dx = ?$	mathematics	integral_calculus	B	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
3fd1caba-78b3-459a-b77b-f07a40517c39	05a449d9-5db0-488f-936f-ab50cc72299e	01	অক্সিসোম কোন অঙ্গাণুর অংশ?	biology	cell_and_its_structure	C	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
b35dd373-995f-443c-9e34-caab29ac5108	05a449d9-5db0-488f-936f-ab50cc72299e	02	অঙ্কুরোদগমের সময় বীজ কোন প্রক্রিয়ায় পানি শোষণ করে?	biology	plant_physiology	B	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
9f8271df-56fc-4c02-a839-087e284eb9be	05a449d9-5db0-488f-936f-ab50cc72299e	03	সালোকসংশ্লেষণের রঞ্জক পদার্থগুলো কোথায় থাকে?	biology	plant_physiology	A	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
facd3e6e-d556-4874-96de-0f6b23430a44	05a449d9-5db0-488f-936f-ab50cc72299e	04	ATP Synthases কোষের কোথায় থাকে?	biology	cell_and_its_structure	D	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
d5167ccb-684c-491a-8aab-56ae7dffd07e	05a449d9-5db0-488f-936f-ab50cc72299e	05	নিষিক্ত ডিম্বাণু কিসে পরিণত হয়?	biology	plant_reproduction	\N	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	[{"id": "IMAGE_1", "kind": "table", "label": "data_table", "box_2d": null, "filename": null, "markdown": null, "page_index": 4, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2021-2022-A-Unit/page_5", "extraction_status": "needs_review"}]	\N	\N
4efde473-3e55-4fd6-82e0-b5309b1487f9	05a449d9-5db0-488f-936f-ab50cc72299e	06	অবাত শ্বসনে এক অণু গ্লুকোজ থেকে কয় অণু ল্যাকটিক অ্যাসিড তৈরি হয়?	biology	plant_physiology	A	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
61e6946a-6297-4c71-9da5-6b95394f89c4	05a449d9-5db0-488f-936f-ab50cc72299e	07	ফ্লোয়েমের কোন উপাদানটি মৃত?	biology	tissue_and_tissue_system	B	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
3eaa3286-1150-4a8c-85d5-2bd354b2a144	05a449d9-5db0-488f-936f-ab50cc72299e	08	কোষ বিভাজনের কোন উপ-দশায় সমসংস্থ ক্রোমোজোমের মধ্যে সিন্যাপসিস ঘটে?	biology	cell_division	A	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
33200c93-c9fb-488b-8e23-64fe95ebce57	05a449d9-5db0-488f-936f-ab50cc72299e	09	নিচের কোন পর্বের প্রাণী ইউসিলোমেট নয়?	biology	animal_diversity_and_classification	D	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
646acc68-6f4a-45cc-a32a-96895be5afcd	05a449d9-5db0-488f-936f-ab50cc72299e	10	লোহিত রক্তকণিকার প্রধান প্রোটিন কোনটি?	biology	human_physiology_blood_and_circulation	A	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
c0ac03a5-7de1-4297-8fbd-45f75d760c81	05a449d9-5db0-488f-936f-ab50cc72299e	11	ঘাসফড়িং-এর দেহের উভয় পার্শ্বে মোট কয়টি স্পাইরাকল থাকে?	biology	animal_identity	B	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
5680e052-c6e0-4065-af61-d3aff60c0cb7	05a449d9-5db0-488f-936f-ab50cc72299e	12	কোনটি হাইড্রার প্রজননের পদ্ধতি নয়?	biology	animal_identity	C	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	[{"id": "IMAGE_1", "kind": "table", "label": "data_table", "box_2d": null, "filename": null, "markdown": null, "page_index": 5, "caption_hint": null, "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2021-2022-A-Unit/page_6", "extraction_status": "needs_review"}]	\N	\N
c4e56762-c3ea-4674-966a-aa3d50014286	05a449d9-5db0-488f-936f-ab50cc72299e	13	ভ্রূণীয় মেসোডার্ম থেকে কোন অঙ্গটি গঠিত হয়?	biology	continuation_of_human_life	B	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	[{"id": "IMAGE_1", "kind": "table", "label": "data_table", "box_2d": null, "filename": null, "markdown": null, "page_index": 5, "caption_hint": "তিনটি ভ্রূণীয় স্তরের পরিণতি হলো :", "review_notes": "no manual crops in /Users/mdsayeddelowar/Documents/TestProjects/ExamBank/backend/../test-cropping/cropped_images/DU-2021-2022-A-Unit/page_6", "extraction_status": "needs_review"}]	\N	\N
3a707285-340f-4d27-93e9-74d6518b576d	05a449d9-5db0-488f-936f-ab50cc72299e	14	Kuffer's cell কোন অঙ্গে থাকে?	biology	human_physiology_digestion_and_absorption	C	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
49e3db7d-64cb-4d80-b4af-268750ca2b04	05a449d9-5db0-488f-936f-ab50cc72299e	15	মানবদেহে নিউক্লিয়াসবিহীন কোষ কোনটি?	biology	human_physiology_blood_and_circulation	A	\N	pending	2026-04-27 17:34:47.677589+00	Dhaka University	2021-2022	A	null	\N	\N
9c2b7680-c00f-42c7-97bd-ff7a6be4d96c	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	06	যদি ইথাইল বেনজিনকে $\\ce{KMnO4}$ এর সাথে তাপ দেওয়া হয়, তবে নিচের কোনটি উৎপন্ন হয়?	chemistry	organic_chemistry	B	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
0d9953e6-403e-4dfe-8d1b-81061084d971	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	04	একটি কণা $t = 0$ সময়ে স্থির অবস্থা থেকে যাত্রা শুরু করে। কণাটির ওপর প্রযুক্ত লব্ধি বল, সময় $t$ এর সমানুপাতিক। কণাটির গতিশক্তি নিচের কোনটির সমানুপাতিক হবে?	physics	dynamics	D	\N	generated	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	দেওয়া আছে, লব্ধি বল সময়ের সমানুপাতিক, অর্থাৎ $F \\propto t$ বা $ma \\propto t$। যেহেতু ভর $m$ ধ্রুবক, তাই ত্বরণ $a \\propto t$ বা $a = kt$ (যেখানে $k$ একটি ধ্রুবক)। এখন, বেগের পরিবর্তন $v = \\int a \\, dt = \\int kt \\, dt = \\frac{1}{2}kt^2$। কণাটির গতিশক্তি $K = \\frac{1}{2}mv^2 = \\frac{1}{2}m(\\frac{1}{2}kt^2)^2 = \\frac{mk^2}{8}t^4$। সুতরাং, গতিশক্তি $K \\propto t^4$।	D
93402563-6af3-45ec-9de0-aede8c8fb6b0	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	14	একটি ট্রেনের স্থির অবস্থায় দৈর্ঘ্য হলো $100\\,\\text{m}$। একটি অতি উচ্চ বেগে $80\\,\\text{m}$ দৈর্ঘ্যের একটি সুড়ঙ্গের মধ্য দিয়ে যায়। সুড়ঙ্গের দুই প্রান্তে অবস্থিত পর্যবেক্ষকরা লক্ষ করেন যে, একটি মুহূর্তে ট্রেনটির দৈর্ঘ্য ঠিক সুড়ঙ্গের দৈর্ঘ্যের সমান হয়। $c$ এর এককে ট্রেন এর বেগ কত?	physics	introduction_to_modern_physics	D	\N	generated	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	আপেক্ষিকতার দৈর্ঘ্য সংকোচন সূত্র অনুযায়ী, $L = L_0 \\sqrt{1 - \\frac{v^2}{c^2}}$, যেখানে $L_0$ হলো স্থির অবস্থায় দৈর্ঘ্য, $L$ হলো গতিশীল অবস্থায় পর্যবেক্ষক কর্তৃক পরিমাপকৃত দৈর্ঘ্য, $v$ হলো বস্তুর বেগ এবং $c$ হলো আলোর বেগ। প্রদত্ত তথ্য অনুযায়ী, ট্রেনের স্থির অবস্থায় দৈর্ঘ্য $L_0 = 100\\,\\text{m}$ এবং গতিশীল অবস্থায় পরিমাপকৃত দৈর্ঘ্য $L = 80\\,\\text{m}$।\nআমরা সূত্রটিকে $v/c$ এর জন্য পুনর্বিন্যাস করতে পারি: $\\frac{L}{L_0} = \\sqrt{1 - \\frac{v^2}{c^2}}$।\nউভয় পাশে বর্গ করে পাই: $(\\frac{L}{L_0})^2 = 1 - \\frac{v^2}{c^2}$।\nসুতরাং, $\\frac{v^2}{c^2} = 1 - (\\frac{L}{L_0})^2$।\nমান বসিয়ে পাই: $\\frac{v}{c} = \\sqrt{1 - (\\frac{80\\,\\text{m}}{100\\,\\text{m}})^2} = \\sqrt{1 - (0.8)^2} = \\sqrt{1 - 0.64} = \\sqrt{0.36} = 0.6$।\nঅতএব, ট্রেনের বেগ হলো $0.6\\,c$।	D
3ca8ae1a-6ccf-4d76-bbe9-913a8fc3cd5d	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	06	$a$ দৈর্ঘ্য বিশিষ্ট দুটি বর্গাকার পাত দিয়ে গঠিত ধারক যার পাত দুটির মধ্যবর্তী দূরত্ব $d$ এবং $d \\ll a$। ধারকের সমস্ত রৈখিক মাত্রা তিনগুণ করা হলে ধারকত্ব কতগুণ পরিবর্তন হবে?	physics	static_electricity	C	\N	generated	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	সমান্তরাল পাত ধারকের ধারকত্ব $C = \\frac{\\epsilon_0 A}{d}$, যেখানে $A$ হলো পাতের ক্ষেত্রফল এবং $d$ হলো পাতদ্বয়ের মধ্যবর্তী দূরত্ব। বর্গাকার পাতের ক্ষেত্রে $A = a^2$, সুতরাং ধারকত্ব $C = \\frac{\\epsilon_0 a^2}{d}$। প্রশ্নমতে, রৈখিক মাত্রা তিনগুণ করা হলে নতুন বাহুর দৈর্ঘ্য $a' = 3a$ এবং নতুন দূরত্ব $d' = 3d$ হয়। অতএব নতুন ধারকত্ব $C' = \\frac{\\epsilon_0 (3a)^2}{3d} = \\frac{9 \\epsilon_0 a^2}{3d} = 3 \\frac{\\epsilon_0 a^2}{d} = 3C$। সুতরাং ধারকত্ব ৩ গুণ বৃদ্ধি পাবে বা পরিবর্তিত হবে।	C
a9f84a82-da97-41da-a3d9-246cbccaa838	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	01	নিচের কোনটি গ্যাস ক্রোমাটোগ্রাফিতে বাহক হিসেবে ব্যবহার করা হয় না?	chemistry	safe_use_of_laboratory	D	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
d7872880-5ece-499d-b527-b4796e248d34	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	02	নিচের কোন কার্বোক্যাটায়নটি সবচেয়ে বেশি স্থিতিশীল?	chemistry	organic_chemistry	D	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
47a28298-905c-452d-b080-4d3afd9c77c2	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	03	$\\alpha, \\beta$ এবং $\\gamma$ কণাগুলোর চার্জ, যথাক্রমে- [IMAGE_1]	chemistry	atomic_model_and_nuclear_physics	D	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	[{"id": "IMAGE_1", "kind": "table", "label": "data_table", "box_2d": null, "filename": null, "markdown": null, "page_index": 1, "caption_hint": null, "review_notes": null, "extraction_status": "pending"}]	\N	\N
9e3646cf-4bf6-4dd6-b359-0e515a1f09c6	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	04	নিচের কোন ক্ষেত্রে ব্যাপন সর্বাধিক হবে?	chemistry	environmental_chemistry	D	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
aa4ed04d-dabb-43ca-bef3-b8dc056cd245	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	05	নিচের কোন যৌগটি সিস-ট্রান্স সমাণুতা প্রদর্শন করে?	chemistry	organic_chemistry	B	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
95f0d1ec-d2f9-45ee-b3e2-a86de850e0ee	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	07	$\\ce{CO2}$-এর সমইলেকট্রন বিশিষ্ট আয়নটি হলো-	chemistry	qualitative_chemistry	D	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
52357405-5abf-4f44-98ff-230d83a1da72	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	09	নিচের কোনটির মাত্রা নেই?	physics	structural_properties_of_matter	C	\N	generated	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	বিকৃতি হলো একই জাতীয় দুটি রাশির অনুপাত, যেমন দৈর্ঘ্যের পরিবর্তন ও আদি দৈর্ঘ্যের অনুপাত। এর গাণিতিক প্রকাশ $\\text{Strain} = \\frac{\\Delta L}{L}$, যার ফলে এর কোনো মাত্রা নেই ($[M^0L^0T^0]$)। অন্যদিকে পীড়ন, ইয়াং-এর গুণাঙ্ক এবং চাপের মাত্রা হলো $[ML^{-1}T^{-2}]$। সুতরাং বিকৃতি একটি মাত্রাহীন রাশি।	C
38f811fb-1c5b-48db-878a-e7492dac0d62	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	15	$0.50\\,\\text{kg}$ ভরের একটি কণা $x$ অক্ষ বরাবর $x(t) = -13.00 + 2.00t + 4.00t^2 - 3.00t^3$ সমীকরণ অনুযায়ী চলছে, যেখানে $x$ এর একক মিটার এবং $t$ এর একক সেকেন্ড। $t = 2.0\\,\\text{s}$-এ কণার ওপর লব্ধি বল কত?	physics	newtonian_mechanics	B	\N	generated	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	কণার অবস্থান $x(t) = -13.00 + 2.00t + 4.00t^2 - 3.00t^3$। একে সময়ের সাপেক্ষে ব্যবকলন করে বেগ $v(t) = \\frac{dx}{dt} = 2.00 + 8.00t - 9.00t^2$ এবং পুনরায় ব্যবকলন করে ত্বরণ $a(t) = \\frac{dv}{dt} = 8.00 - 18.00t$ পাওয়া যায়। $t = 2.0\\,\\text{s}$ সময়ে ত্বরণ $a(2) = 8.00 - 18.00(2.0) = -28.0\\,\\text{m/s}^2$। নিউটনের দ্বিতীয় সূত্রানুসারে লব্ধি বল $F = ma = 0.50\\,\\text{kg} \\times (-28.0\\,\\text{m/s}^2) = -14.0\\,\\text{N}$।	B
658a3d42-fde3-43e6-8be9-a206f94e8be2	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	10	$R_H$ রিডবার্গ ধ্রুবক হলে, হাইড্রোজেন বর্ণালীর বামার সিরিজের ২য় লাইনের তরঙ্গদৈর্ঘ্য কত হবে?	chemistry	qualitative_chemistry	B	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
deb8a1ab-c0bc-4901-806d-14cebe1e7525	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	11	$100\\,\\text{mL}$ $0.2\\,\\text{M}$ $\\ce{Na2CO3}$ জলীয় দ্রবণকে প্রশমিত করতে কত আয়তনের $0.4\\,\\text{M}$ $\\ce{HCl}$ প্রয়োজন হবে?	chemistry	quantitative_chemistry	C	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
97feda10-a2dc-4c18-8c53-5fc6219985e0	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	12	নিচের কোন বিক্রিয়াটির $K_p$ ও $K_c$ এর মান সমান?	chemistry	chemical_changes	C	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
9ac37697-f29e-4197-8aa2-9faf9d6697da	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	13	$\\ce{Zn^{2+}(aq) | Zn(s)}$ ও $\\ce{Ag^+(aq) | Ag(s)}$ তড়িৎদ্বার দুটির বিজারণ বিভব যথাক্রমে $-0.76\\,\\text{V}$ এবং $+0.80\\,\\text{V}$। এই তড়িৎদ্বার দুটি দ্বারা তৈরি কোষের মোট বিভব কত?	chemistry	electrochemistry	D	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
dac10459-32a1-4bc1-8911-4880d1bcb38d	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	14	$\\ce{CH2=CH-CH=CH2}$ এর কার্বন পরমাণুসমূহের সংকরায়ন কী ধরনের?	chemistry	organic_chemistry	C	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
e8297b4c-eac2-4a04-b3ea-9a6bfc93c9a0	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	15	নিচের কোন যৌগে সর্বাধিক শক্তিশালী হাইড্রোজেন বন্ধন রয়েছে?	chemistry	periodic_properties_of_elements_and_chemical_bonding	C	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
c334d74b-bcce-48df-9e88-ab997ad5e301	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	01	$\\tan\\theta + \\sec\\theta = x$ হলে, $\\text{cosec}\\theta$-এর মান কত?	mathematics	inverse_trigonometric_functions_and_trigonometric_equations	A	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
ab674125-266b-4810-820d-51e01d9e9fa3	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	02	$\\lim_{x \\to 1} \\frac{2x^3 - (2k + 1)x^2 + 2x + k}{x - 1} = -6$ হলে, $k$-এর মান কত?	mathematics	differential_calculus	C	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
d119de1c-67bf-4122-b253-4faa9095dc9f	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	03	$y = x^{-2} \\ln x$ হলে, $\\frac{d^2y}{dx^2}$ এর মান কত?	mathematics	differential_calculus	B	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
e3d860a5-7343-43e8-bcb8-ce5805debcf7	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	04.	$\\int \\frac{dx}{e^x + e^{-x}}$ এর মান কত?	mathematics	integral_calculus	C	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
8777f4e0-13a5-4fd6-aacb-5c1e3b268511	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	05.	যদি $H$ সর্বোচ্চ উচ্চতা এবং $R$ আনুভূমিক পাল্লা হয়, তবে একটি বস্তুকে ভূমির সাথে $30^\\circ$ কোণে নিক্ষেপ করা হলে নিচের কোনটি সঠিক?	mathematics	dynamics	C	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
d956b3b2-c375-457c-b36d-d7e5eda157db	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	06.	7 জন সিনেটর ও 5 জন গভর্নরের একটি দল থেকে কত উপায়ে 4 জন সিনেটর ও 3 জন গভর্নরের একটি কমিটি গঠন করা যায়?	mathematics	permutations_and_combinations	A	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
a7efeae1-ef25-439a-aab0-fd931154652f	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	07.	যদি $2401(7^{-2x}) = 1$ হয়, তবে $x$ এর মান কত?	mathematics	polynomials_and_polynomial_equations	D	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
a6075742-074a-4d3f-a10c-27b235d9a593	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	08.	$y = 1 + \\frac{1}{2+x}$ বক্ররেখা $x$-অক্ষকে $A$ বিন্দুতে এবং $y$-অক্ষকে $B$ বিন্দুতে ছেদ করলে $AB$ সরলরেখার সমীকরণ নিচের কোনটি?	mathematics	straight_lines	C	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
53fb9947-7274-403a-9a29-feb6843d137c	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	09.	$\\frac{1}{|x+2|} > 4$ অসমতাটির সমাধান সেট হবে নিচের কোনটি?	mathematics	real_numbers_and_inequalities	C	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
cc0fdd4f-8c40-40bf-8baf-57fa71daf654	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	10.	$\\text{cosec}10^\\circ - 4\\sin70^\\circ$ এর মান কত?	mathematics	associated_trigonometric_angles	D	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
dc249b11-498d-4463-aab4-5802592894ce	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	11.	$\\tan\\theta + \\cot\\theta = 2\\text{cosec}\\theta, 0 \\leq \\theta < \\frac{\\pi}{2}$ হলে $\\theta$-এর মান কত?	mathematics	inverse_trigonometric_functions_and_trigonometric_equations	D	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
338edf0f-8f39-40d2-8b1e-71461be5d206	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	12.	যদি $f(x) = \\frac{2x+1}{x-3}$ হয়, তবে $f^{-1}(x)$ এর কোডোমেন কোনটি?	mathematics	functions_and_graphs	D	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
a9f9c912-74a4-4991-8001-6116bb741fe4	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	13.	$\\vec{P} = a\\hat{i} - 2\\hat{j} + k$ এবং $\\vec{Q} = 2a\\hat{i} - a\\hat{j} - 4\\hat{k}$ পরস্পর লম্ব হলে, $a$-এর মান কত?	mathematics	vectors	C	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
09bf3bd8-4f02-4106-a93f-d2d6aa6b5f65	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	14.	$(0, 2)$ এবং $(-2, 0)$ বিন্দুগামী সরলরেখা $x$-অক্ষের ধনাত্মক দিকের সাথে কী কোণ উৎপন্ন করে?	mathematics	straight_lines	B	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
fb6587ae-24ad-466c-985f-4cb2e66f89db	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	15.	$y$-অক্ষের সমান্তরাল এবং $2x - 7y + 11 = 0$ ও $x + 3y - 8 = 0$ রেখাদ্বয়ের ছেদবিন্দু দিয়ে অতিক্রমকারী সরলরেখার সমীকরণ নিচের কোনটি?	mathematics	straight_lines	A	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
ea23238d-a7e6-471b-84a0-8caf1e38cb9b	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	01.	Hydra-র বহিস্তরের কোষ নয় কোনটি?	biology	animal_identity	A	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
dac45940-d59c-4a11-b299-80dacfcb7589	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	02.	ঘাসফড়িংয়ের রেচন অঙ্গের নাম কি?	biology	animal_identity	C	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
4069f7b7-0536-4f6c-94ce-328fad9a5a0c	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	03.	ক্যালভিন চক্রে $\\ce{CO2}$ গ্রহীতা কোনটি?	biology	plant_physiology	A	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
6fa917df-a841-467b-baff-27c7e05a1d1d	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	04.	রুই মাছের হৃৎপিণ্ডে কোন অংশটি নেই?	biology	animal_identity	D	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
208d069a-678c-4182-bc8d-28bf73935431	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	05.	কোন এনজাইম স্নেহ জাতীয় খাদ্যকে পরিপাক করে?	biology	human_physiology_digestion_and_absorption	A	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
e8965833-4ffc-4f1e-945f-5ea351fe8438	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	06.	একজন মানুষের বাম ফুসফুসে কয়টি লোবিউল পাওয়া যায়?	biology	human_physiology_breathing_and_respiration	D	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
e990262a-7c8c-47b5-a27c-b5ecae862d40	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	07.	নিচের কোন উদ্ভিদে লেপ্টোসেন্ট্রিক ভাস্কুলার বান্ডল পাওয়া যায়?	biology	tissue_and_tissue_system	A	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
ae7e8091-2c0e-4b49-b9a4-a37f6f20a1c9	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	08.	সাইট্রিক অ্যাসিড থেকে আইসোসাইট্রিক অ্যাসিড উৎপন্নর জন্য কোন এনজাইমের প্রয়োজন?	biology	plant_physiology	A	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "chemical_reaction_flow", "box_2d": null, "filename": null, "markdown": null, "page_index": 4, "caption_hint": null, "review_notes": null, "extraction_status": "pending"}]	\N	\N
f8af3011-4290-4a1c-8271-54fc73b0bd7a	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	09.	পানির সালোক বিভাজনের জন্য নিচের কোনটি প্রয়োজন?	biology	plant_physiology	C	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	[{"id": "IMAGE_1", "kind": "diagram", "label": "chemical_equation", "box_2d": null, "filename": null, "markdown": null, "page_index": 4, "caption_hint": null, "review_notes": null, "extraction_status": "pending"}]	\N	\N
d23e987a-feef-4709-887b-967e249c4efc	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	10.	জীববিজ্ঞানের কোন শাখায় সাপ নিয়ে আলোচনা করা হয়?	biology	animal_diversity_and_classification	B	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
67e22042-4261-493e-a8dc-9bc1fb403204	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	11.	কোন কৃমি চোখকে আক্রান্ত করে?	biology	animal_diversity_and_classification	A	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
1bdcbc61-64ae-4a59-ad8d-5e7aa88eb89a	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	12.	সমপ্রকটতার ফিনোটাইপিক অনুপাত কত?	biology	genetics_and_evolution	D	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
5e41f6b4-dd83-4b34-9843-b7d9b026f3be	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	13	নিযত বর্ধনশীল মঞ্জরিদণ্ডযুক্ত পুষ্পমঞ্জরি দেখা যায় কোন উদ্ভিদে?	biology	gymnosperms_and_angiosperms	D	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
13c99bc0-1417-439d-af78-bf35c30c2cda	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	14	দ্বিনিষেকের ফলে উৎপন্ন সস্য কী ধরনের হয়?	biology	plant_reproduction	C	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
026416a5-d518-4eec-9dcf-9723437bc799	b1329360-5b77-4c9f-a5a9-5e5652a9c99b	15	নিচের কোন ফলটি পার্থেনোকার্পিক?	biology	plant_physiology	C	\N	pending	2026-04-27 17:34:47.727988+00	Dhaka University	2022-2023	A	null	\N	\N
617ff669-f28b-49d1-8d4e-1d03aac4f140	b0c3348a-46af-4e00-a298-7006c2a9785f	05.	একটি ইস্পাতের তারের উপাদানের ইয়ং গুণাঙ্ক $Y$। যদি তারের ব্যাস দ্বিগুণ করা হয় তাহলে পরিবর্তিত ইয়ং গুণাঙ্ক কত হবে?	physics	structural_properties_of_matter	A	\N	generated	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	ইয়ং গুণাঙ্ক ($Y$) একটি উপাদানের স্থিতিস্থাপক ধর্ম, যা শুধুমাত্র উপাদানের প্রকৃতি এবং তাপমাত্রার উপর নির্ভর করে। এটি তারের দৈর্ঘ্য, ব্যাস বা প্রস্থচ্ছেদের ক্ষেত্রফলের মতো জ্যামিতিক মাত্রার উপর নির্ভরশীল নয়। তারের ব্যাস দ্বিগুণ করা হলে তারের প্রস্থচ্ছেদের ক্ষেত্রফল পরিবর্তিত হবে, কিন্তু উপাদানের অভ্যন্তরীণ আণবিক বন্ধন বা কাঠামোর কোনো পরিবর্তন হবে না। সুতরাং, ইয়ং গুণাঙ্ক অপরিবর্তিত থাকবে।	A
ac6f50f6-6eab-41d1-833d-6740b87c9175	b0c3348a-46af-4e00-a298-7006c2a9785f	04.	চাঁদের অভিকর্ষজ ত্বরণ পৃথিবীর অভিকর্ষজ ত্বরণের ছয় ভাগের এক ভাগ। চাঁদের ব্যাসার্ধ পৃথিবীর ব্যাসার্ধের এক-চতুর্থাংশ। পৃথিবীর ভর $M$-এর তুলনায় চাঁদের ভর কত?	physics	gravitation_and_gravity	D	\N	generated	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	আমরা জানি, অভিকর্ষজ ত্বরণ $g = \\frac{GM}{R^2}$, যেখান থেকে ভরের সমীকরণ পাওয়া যায় $M = \\frac{gR^2}{G}$। প্রশ্নমতে, চাঁদের অভিকর্ষজ ত্বরণ $g_m = \\frac{g_e}{6}$ এবং ব্যাসার্ধ $R_m = \\frac{R_e}{4}$। এখন চাঁদের ভর $M_m$ এবং পৃথিবীর ভর $M$-এর অনুপাত হবে $\\frac{M_m}{M} = \\frac{g_m}{g_e} \\times \\left(\\frac{R_m}{R_e}\\right)^2$। মান বসিয়ে পাই, $\\frac{M_m}{M} = \\frac{1}{6} \\times \\left(\\frac{1}{4}\\right)^2 = \\frac{1}{6} \\times \\frac{1}{16} = \\frac{1}{96}$। সুতরাং, চাঁদের ভর $M_m = \\frac{M}{96}$।	D
d16e6125-c814-44cb-86d7-0eaaa8baa883	b0c3348a-46af-4e00-a298-7006c2a9785f	12.	একটি ধাতুর ওপর সবুজ আলো আপতিত হলে ফটোইলেকট্রন নির্গত হয়। নিচের কোন বর্ণের আলো আপতিত হলে ওই তল থেকে অবশ্যই ফটোইলেকট্রন নির্গত হবে?	physics	introduction_to_modern_physics	C	\N	generated	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	ফটোইলেকট্রন নির্গমনের জন্য আপতিত আলোর ফোটন শক্তি ($E$) ধাতুর কার্য অপেক্ষক ($\\phi$) এর চেয়ে বেশি বা সমান হতে হবে, অর্থাৎ $E \\ge \\phi$। ফোটন শক্তি $E = hf = hc/\\lambda$, যেখানে $h$ প্লাঙ্কের ধ্রুবক, $f$ আলোর কম্পাঙ্ক, $c$ আলোর বেগ এবং $\\lambda$ আলোর তরঙ্গদৈর্ঘ্য। সবুজ আলো আপতিত হলে ফটোইলেকট্রন নির্গত হয়, অর্থাৎ সবুজ আলোর ফোটন শক্তি কার্য অপেক্ষকের চেয়ে বেশি। দৃশ্যমান আলোর বর্ণালীতে, কম্পাঙ্ক বৃদ্ধির ক্রম হলো লাল < কমলা < হলুদ < সবুজ < নীল < বেগুনী। যেহেতু নীল আলোর কম্পাঙ্ক সবুজ আলোর কম্পাঙ্কের চেয়ে বেশি, তাই নীল আলোর ফোটন শক্তিও সবুজ আলোর ফোটন শক্তির চেয়ে বেশি হবে। সুতরাং, নীল আলো অবশ্যই ফটোইলেকট্রন নির্গত করবে।	C
eaa7ab0b-1055-4d82-ad55-19c0d4c8a80c	b0c3348a-46af-4e00-a298-7006c2a9785f	01	$\\ce{Sc}$ মৌলের $3d^1$ ইলেকট্রনটির কোয়ান্টাম সংখ্যার সম্ভাব্য সেট কোনটি?	chemistry	qualitative_chemistry	A	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
459d8dd8-e694-46d7-96d4-642b1c642a6b	b0c3348a-46af-4e00-a298-7006c2a9785f	02	$2.5$ গ্রাম $\\ce{CaCO3}$ থেকে NTP-তে কী পরিমাণ $\\ce{CO2}$ উৎপন্ন হবে?	chemistry	quantitative_chemistry	B	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
04aaae42-2fa9-467c-b925-639c277a0012	b0c3348a-46af-4e00-a298-7006c2a9785f	03	কোনটি ওজোন স্তর ক্ষয়ের জন্য দায়ী নয়?	chemistry	environmental_chemistry	A	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
5db23618-cdd5-465f-81cc-81b141ee8abe	b0c3348a-46af-4e00-a298-7006c2a9785f	04	কোন বিক্রিয়ায় এনথালপির পরিবর্তন সর্বনিম্ন?	chemistry	chemical_changes	B	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
02643a07-d564-48a8-9cb1-5a7ae7fccbe2	b0c3348a-46af-4e00-a298-7006c2a9785f	05	$\\ce{Al2Cl6}$ অণুতে সমযোজী ও সন্নিবেশ সমযোজী বন্ধনের সংখ্যা যথাক্রমে কয়টি?	chemistry	periodic_properties_of_elements_and_chemical_bonding	C	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
ba01119b-ad97-4723-b2b8-0c18dc6aeadb	b0c3348a-46af-4e00-a298-7006c2a9785f	06	কোন যৌগের কার্বনে একাধিক ধরনের সংকরণ আছে?	chemistry	organic_chemistry	D	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
e1c032ec-9a67-410d-80f6-7fc3975e82c1	b0c3348a-46af-4e00-a298-7006c2a9785f	07	$\\ce{(NH4)3[Fe(CN)6]}$ যৌগে আয়রনের জারণ মান কত?	chemistry	quantitative_chemistry	C	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
dcb26abf-e243-4e90-96f0-0e4f38819a1e	b0c3348a-46af-4e00-a298-7006c2a9785f	08	$25^\\circ\\text{C}$ তাপমাত্রায় পানির $\\text{pH}$ ও $\\text{pOH}$ উভয়ই $7.0$ হলে অধিক তাপমাত্রায় নিচের কোন সম্পর্কটি সঠিক?	chemistry	chemical_changes	A	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
9f65ed34-7e3f-42fd-88dc-49989c66c493	b0c3348a-46af-4e00-a298-7006c2a9785f	13	হাইড্রোজেন পরমাণুর আদি শক্তিস্তর $n_i$ থেকে চূড়ান্ত শক্তিস্তর $n_f$-এ স্থানান্তরের ফলে নিম্নলিখিত কোনটির ক্ষেত্রে সর্বাধিক শক্তি নির্গত হয়?	physics	atomic_model_and_nuclear_physics	D	\N	generated	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	হাইড্রোজেন পরমাণুর $n$-তম শক্তিস্তরের শক্তি $E_n = -\\frac{13.6}{n^2}\\,\\text{eV}$। যখন একটি ইলেকট্রন $n_i$ আদি শক্তিস্তর থেকে $n_f$ চূড়ান্ত শক্তিস্তরে স্থানান্তরিত হয় এবং শক্তি নির্গত হয়, তখন $n_i > n_f$ হতে হবে। নির্গত শক্তির পরিমাণ হলো $\\Delta E = E_{n_i} - E_{n_f} = 13.6 \\left( \\frac{1}{n_f^2} - \\frac{1}{n_i^2} \\right)\\,\\text{eV}$।\n\nআমরা প্রতিটি বিকল্পের জন্য নির্গত শক্তি গণনা করি:\n(A) $n_i = 80, n_f = 2$: $\\Delta E_A = 13.6 \\left( \\frac{1}{2^2} - \\frac{1}{80^2} \\right) = 13.6 \\left( \\frac{1}{4} - \\frac{1}{6400} \\right) \\approx 13.6 \\times 0.2498 = 3.3978\\,\\text{eV}$।\n(B) $n_i = 1, n_f = 2$: এখানে $n_i < n_f$, তাই শক্তি নির্গত না হয়ে শোষিত হবে।\n(C) $n_i = 3, n_f = 90$: এখানেও $n_i < n_f$, তাই শক্তি নির্গত না হয়ে শোষিত হবে।\n(D) $n_i = 2, n_f = 1$: $\\Delta E_D = 13.6 \\left( \\frac{1}{1^2} - \\frac{1}{2^2} \\right) = 13.6 \\left( 1 - \\frac{1}{4} \\right) = 13.6 \\times \\frac{3}{4} = 10.2\\,\\text{eV}$।\n\nতুলনা করে দেখা যায়, বিকল্প (D) এর ক্ষেত্রে সর্বাধিক $10.2\\,\\text{eV}$ শক্তি নির্গত হয়।	D
6b73768d-7203-43eb-a59f-6730654649cd	b0c3348a-46af-4e00-a298-7006c2a9785f	11.	দুইটি এক-পরমাণুক আদর্শ গ্যাস পরস্পরের সাথে তাপীয় সাম্যাবস্থায় আছে। A গ্যাস $m$ ভরের অণু দ্বারা গঠিত, এবং B গ্যাস $4m$ ভরের অণু দ্বারা গঠিত। A গ্যাসের আয়তন B গ্যাসের আয়তনের দ্বিগুণ। এদের চাপের অনুপাত $P_A/P_B$ কত?	physics	ideal_gas_and_gas_kinetics	B	\N	generated	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	তাপীয় সাম্যাবস্থায় উভয় গ্যাসের তাপমাত্রা সমান থাকে, অর্থাৎ $T_A = T_B$। আদর্শ গ্যাসের সমীকরণ $PV = NkT$ থেকে আমরা পাই $P = \\frac{NkT}{V}$, যেখানে $N$ হলো অণুর সংখ্যা এবং $k$ হলো বোল্টজম্যান ধ্রুবক। অণুর সংখ্যা সমান ($N_A = N_B$) বিবেচনা করলে চাপের অনুপাত হয় $\\frac{P_A}{P_B} = \\frac{N_A k T_A / V_A}{N_B k T_B / V_B} = \\frac{V_B}{V_A}$। যেহেতু প্রশ্নে দেওয়া আছে $V_A = 2V_B$, তাই চাপের অনুপাত হবে $\\frac{P_A}{P_B} = \\frac{V_B}{2V_B} = \\frac{1}{2}$।	B
c619a5da-b633-425a-92b2-34cb831fd662	b0c3348a-46af-4e00-a298-7006c2a9785f	14	বুলিয়ান বীজগণিত $A + A.B$-এর সমতুল্য কোনটি?	physics	semiconductor_and_electronics	A	\N	generated	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	বুলিয়ান বীজগণিতের শোষণ উপপাদ্য (Absorption Law) অনুযায়ী, $A + A \\cdot B$ রাশিটি থেকে $A$ কমন নিলে পাওয়া যায় $A(1 + B)$। আমরা জানি যে, বুলিয়ান নিয়মানুসারে $1 + B = 1$। সুতরাং, রাশিটি দাঁড়ায় $A \\cdot 1 = A$। অতএব, $A + A \\cdot B$-এর সমতুল্য মান হলো $A$।	A
3b3b76c0-4e58-4da1-a1c2-97fc0116378d	b0c3348a-46af-4e00-a298-7006c2a9785f	09	নিচের কোন জোড়া যৌগে সমআয়ন প্রভাব বিদ্যমান?	chemistry	chemical_changes	C	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
0c75180c-5fdd-4448-a211-17b053d34f06	b0c3348a-46af-4e00-a298-7006c2a9785f	10	$\\ce{R-CO-R -> R-CH2-R}$ পরিবর্তনের জন্য কোন বিকারকটি প্রয়োজন?	chemistry	organic_chemistry	B	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
df50d5c0-02e4-4ced-afea-c1d41b642f4a	b0c3348a-46af-4e00-a298-7006c2a9785f	11	কোনটি ফেহলিং দ্রবণের সাথে বিক্রিয়া করে?	chemistry	organic_chemistry	A	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
b8b786df-cf12-4bbc-ad1d-37c1e583cf7e	b0c3348a-46af-4e00-a298-7006c2a9785f	12	$100\\,\\text{mL}$ $\\ce{NaOH}$ এর দ্রবণে $0.5\\,\\text{g}$ $\\ce{NaOH}$ আছে। এই দ্রবণের ঘনমাত্রা ppm এককে কত হবে?	chemistry	quantitative_chemistry	D	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
9791bce5-9364-4e4b-bf0d-6b3ca12aec1a	b0c3348a-46af-4e00-a298-7006c2a9785f	13	$\\ce{NH3, RNH2, R2NH}$ যৌগগুলোর ক্ষার-ধর্ম প্রদর্শনের ক্রম হচ্ছে-	chemistry	organic_chemistry	B	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
0becb42a-2a72-4638-9e3e-6317f6e91c1a	b0c3348a-46af-4e00-a298-7006c2a9785f	14	গলিত $\\ce{CaCl2}$ এর মধ্য দিয়ে $1\\text{F}$ তড়িৎ চালনা করলে ক্যাথোডে কত গ্রাম $\\ce{Ca}$ ধাতু জমা হবে?	chemistry	electrochemistry	A	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
0055f69d-d348-4e7c-9a7a-fdf9d19eaf07	b0c3348a-46af-4e00-a298-7006c2a9785f	15	$\\ce{Al(OH)3}$ এর দ্রাব্যতা যদি '$s$' হয় তবে এর দ্রাব্যতা গুণফলের মান কত?	chemistry	qualitative_chemistry	D	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
a6db028f-0764-4dc6-a95c-ccc4231cccac	b0c3348a-46af-4e00-a298-7006c2a9785f	01.	$\\begin{vmatrix} 1 & 3 & 2 \\\\ 2 & 0 & 3 \\\\ 1 & -1 & P \\end{vmatrix}$ ম্যাট্রিক্সটি ব্যতিক্রমী হলে P এর মান কত?	mathematics	matrices_and_determinants	A	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
bbb69845-aa2e-4916-9c8d-ddb06a72b002	b0c3348a-46af-4e00-a298-7006c2a9785f	02.	$(1,1)$ বিন্দুগামী ও $2x - 3y - 5 = 0$ রেখার ওপর লম্বরেখার সমীকরণ কোনটি?	mathematics	straight_lines	A	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
ae335f47-e605-48a0-8fbf-eb4e8986f137	b0c3348a-46af-4e00-a298-7006c2a9785f	03.	$r = \\sin\\theta$ বৃত্তের কেন্দ্র ও ব্যাসার্ধ কত হবে?	mathematics	circles	D	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
5c4c5cde-9543-4cf7-af80-2549ff637522	b0c3348a-46af-4e00-a298-7006c2a9785f	04.	$y = \\ln(2-x)$ হলে $\\frac{dy}{dx} = ?$	mathematics	differential_calculus	D	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
21fe7e28-1459-4168-a6df-820046fccf0e	b0c3348a-46af-4e00-a298-7006c2a9785f	05.	$2\\tan^{-1}\\frac{1}{3} + \\tan^{-1}\\frac{1}{7} = ?$	mathematics	inverse_trigonometric_functions_and_trigonometric_equations	A	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
b1451d45-98c4-44d3-bdce-3992225e8481	b0c3348a-46af-4e00-a298-7006c2a9785f	06.	$\\int \\frac{x\\,dx}{\\sqrt{1-x^2}} = ?$	mathematics	integral_calculus	D	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
30e4f9fd-92bf-491e-a45e-5f8bd63ff00a	b0c3348a-46af-4e00-a298-7006c2a9785f	07.	1-এর একটি জটিল ঘনমূল $\\omega$ হলে $\\omega^{16} + \\omega^{32} = ?$	mathematics	complex_numbers	C	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
3556bbed-9cac-4f0c-b691-187f29028fa5	b0c3348a-46af-4e00-a298-7006c2a9785f	08.	k-এর কোন মানের জন্য $2x^2 - (k+1)x + k = 0$-এর একটি মূল অপর মূলের বিপরীতের তিন গুণের সমান হবে?	mathematics	polynomials_and_polynomial_equations	D	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
78918a2f-7419-4c4e-89d9-cf193ad6d3b9	b0c3348a-46af-4e00-a298-7006c2a9785f	09.	$y^2 + 4x + 2y - 8 = 0$ পরাবৃত্তের শীর্ষবিন্দু কত?	mathematics	conics	A	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
b324d53d-259a-4afa-bc37-3d7dc876cda4	b0c3348a-46af-4e00-a298-7006c2a9785f	10.	$y^2 = 4x$ পরাবৃত্ত এবং $y = x$ সরলরেখা দ্বারা আবদ্ধ ক্ষেত্রের ক্ষেত্রফল কত?	mathematics	integral_calculus	C	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
3cf007c0-fbd8-4f56-b9c8-b8057934c194	b0c3348a-46af-4e00-a298-7006c2a9785f	11.	$\\lim_{x \\to -\\infty} \\frac{\\sqrt{x^2 + x}}{x + 1} = ?$	mathematics	differential_calculus	D	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
e118b659-ae11-4fc2-872b-ea9b90b39e9c	b0c3348a-46af-4e00-a298-7006c2a9785f	13	$\\tan 75^\\circ = ?$	mathematics	trigonometric_ratios	B	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
d8bd851c-e716-4bc4-93e0-365b13791941	b0c3348a-46af-4e00-a298-7006c2a9785f	14	$16y^2 - 9x^2 + 18x + 64y + 199 = 0$ দ্বারা নির্দেশিত কনিক কোনটি?	mathematics	conics	A	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
4baa74ca-84e2-4e87-bae8-96573878f24c	b0c3348a-46af-4e00-a298-7006c2a9785f	15	নিচের কোনটি $\\sin^{-1} \\frac{2}{3}$ এর সমান?	mathematics	inverse_trigonometric_functions_and_trigonometric_equations	B	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	[{"id": "IMAGE_1", "kind": "diagram", "label": "geometry_figure", "box_2d": null, "filename": null, "markdown": null, "page_index": 3, "caption_hint": null, "review_notes": null, "extraction_status": "pending"}]	\N	\N
a0f340d4-78c6-44a2-bcdc-343d264deb9f	b0c3348a-46af-4e00-a298-7006c2a9785f	01	টোবাকো মোজাইক ভাইরাসের প্রোটিন আবরণকে বলে-	biology	microorganisms	B	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
c523ec25-ae48-4fac-acff-027323ea2e0c	b0c3348a-46af-4e00-a298-7006c2a9785f	02	নিচের কোনটি পনির তৈরিতে ব্যবহৃত হয়?	biology	biotechnology	B	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
5f467ec7-fc78-4ee4-bfcd-d02db2f495ce	b0c3348a-46af-4e00-a298-7006c2a9785f	03	নিচের কোনটি হ্যাচ ও স্ল্যাক চক্রে $\\ce{CO2}$ গ্রহীতা?	biology	plant_physiology	C	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
90eb6420-7c1e-4aba-ad9b-f62a70ec7c28	b0c3348a-46af-4e00-a298-7006c2a9785f	04	নিচের কোন কোষটি নিউক্লিয়াসবিহীন?	biology	tissue_and_tissue_system	A	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
9177721a-8e16-4dd4-8b5d-aed56d73c0d9	b0c3348a-46af-4e00-a298-7006c2a9785f	05	নিউক্লিক অ্যাসিডের পুনরাবৃত্ত একক কোনটি?	biology	cell_chemistry	D	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
353f550b-1dbe-4d98-a917-82a1546ceca9	b0c3348a-46af-4e00-a298-7006c2a9785f	06	নিচের কোনটি রেস্ট্রিকশন এনজাইম নয়?	biology	biotechnology	A	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	[{"id": "IMAGE_1", "kind": "table", "label": "data_table", "box_2d": null, "filename": null, "markdown": null, "page_index": 3, "caption_hint": null, "review_notes": null, "extraction_status": "pending"}]	\N	\N
4b084110-815e-4fdf-9faf-31834bf8049e	b0c3348a-46af-4e00-a298-7006c2a9785f	07	পুষ্পক উদ্ভিদের মূলে কোন ধরনের ভাস্কুলার বান্ডল থাকে?	biology	tissue_and_tissue_system	C	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
02162adc-0a34-4df0-96da-e9bed6d8cf2e	b0c3348a-46af-4e00-a298-7006c2a9785f	08	দুই বা ততোধিক জোড়া বিপরীত বৈশিষ্ট্যসম্পন্ন জীবের মধ্যে ক্রস ঘটালে $F_2$ জনুতে কোন ধরনের ফিনোটাইপিক অনুপাত পাওয়া যাবে?	biology	genetics_and_evolution	A	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
b4d90d9d-26ec-4949-8490-c635978e139c	b0c3348a-46af-4e00-a298-7006c2a9785f	09	নিচের কোনটি Mollusca পর্বের প্রাণী?	biology	animal_diversity_and_classification	B	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	[{"id": "IMAGE_1", "kind": "table", "label": "data_table", "box_2d": null, "filename": null, "markdown": null, "page_index": 3, "caption_hint": null, "review_notes": null, "extraction_status": "pending"}]	\N	\N
44a82cc4-8571-4355-b858-c026c058c47c	b0c3348a-46af-4e00-a298-7006c2a9785f	10	নিচের কোনটি Arthropoda পর্বের বৈশিষ্ট্য?	biology	animal_diversity_and_classification	C	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
65dcf89e-1f61-48eb-900d-270a06b8227e	b0c3348a-46af-4e00-a298-7006c2a9785f	11	মানবদেহে ক্ষুদ্রতম হাড় কোনটি?	biology	human_physiology_locomotion_and_movement	C	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
095b7ee9-cd7a-434c-a4a0-e49648cc1b30	b0c3348a-46af-4e00-a298-7006c2a9785f	12	নিচের কোনটি আমিষ পরিপাকে সহায়তা করে না?	biology	human_physiology_digestion_and_absorption	D	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	[{"id": "IMAGE_1", "kind": "table", "label": "data_table", "box_2d": null, "filename": null, "markdown": null, "page_index": 4, "caption_hint": null, "review_notes": null, "extraction_status": "pending"}]	\N	\N
60ea5af0-1151-4eeb-83f4-95e48418f6ae	b0c3348a-46af-4e00-a298-7006c2a9785f	13	কোন ধমনি হৃৎপিণ্ডের প্রাচীরে রক্ত সরবরাহ করে?	biology	human_physiology_blood_and_circulation	B	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
2d418f6a-e8d0-4096-92ca-8e6670aac17b	b0c3348a-46af-4e00-a298-7006c2a9785f	14	কোন পর্বের প্রাণীতে মেসোগ্লিয়া থাকে?	biology	animal_identity	C	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
d553c437-75ad-45f1-b4cc-fc726a92844f	b0c3348a-46af-4e00-a298-7006c2a9785f	15	রক্তের কোন গ্রুপে অ্যান্টিজেন অনুপস্থিত?	biology	human_physiology_blood_and_circulation	A	\N	pending	2026-04-27 17:34:47.777291+00	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	null	\N	\N
\.


--
-- Data for Name: admission_written_questions; Type: TABLE DATA; Schema: public; Owner: exambank
--

COPY public.admission_written_questions (id, paper_id, question_number, question_text, university_name, exam_session, exam_unit, subject, chapter, solution, solution_status, created_at, images) FROM stdin;
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: exambank
--

COPY public.alembic_version (version_num) FROM stdin;
e5d31493a649
\.


--
-- Data for Name: attempt_answers; Type: TABLE DATA; Schema: public; Owner: exambank
--

COPY public.attempt_answers (id, attempt_id, question_id, selected_label, is_correct, answered_at) FROM stdin;
c838fa2c-654d-4f49-bb46-bb03183994da	2557bb3a-9869-422c-ac10-8000966fb728	9c09af5e-a1c7-4691-9711-b9cd745d9753	C	t	2026-04-28 13:18:51.666408+00
10c2ad7d-946e-4ba1-9aa2-fa6766846646	2557bb3a-9869-422c-ac10-8000966fb728	001777f1-ddfd-4c1d-9f39-0f7ea9489952	A	t	2026-04-28 13:19:12.97047+00
f9e027d7-22a0-458d-b5ff-534016958065	71805292-835e-4ff3-a365-f30fcfc06048	0d3a863f-1bdc-4700-9fde-50a6789967a6	C	f	2026-04-28 13:01:01.264298+00
28d8930d-1dfb-414d-944b-8795a03b93f4	bc9170e2-363a-4c00-85a1-419765d2f7c1	3c8324f4-f243-40a5-9cf7-c8f0400442c9	B	t	2026-04-28 07:17:24.391518+00
08648a6b-dd03-43f5-b0de-18b21b776148	bc9170e2-363a-4c00-85a1-419765d2f7c1	02f9760b-6ba8-4014-95b2-2fd38671158c	B	t	2026-04-28 07:17:26.033222+00
add9150e-fee5-4c54-aa30-0fa32e2d9016	bc9170e2-363a-4c00-85a1-419765d2f7c1	0e6f388d-33a0-4f0a-88e4-3e5b6f56072e	A	f	2026-04-28 07:17:27.523188+00
3ba17611-d8cf-4f03-9204-5cdca2f200cb	bc9170e2-363a-4c00-85a1-419765d2f7c1	14bc131c-3a3c-496c-947c-029d7c7f9c86	B	t	2026-04-28 07:17:33.887112+00
11956923-1ef5-4dfa-ae06-4c0b2fd85eeb	bc9170e2-363a-4c00-85a1-419765d2f7c1	94d6936a-6e54-46fc-88a2-0f7b1a95d577	C	t	2026-04-28 07:17:37.273589+00
4500d387-a42e-485f-8142-9d1532be9436	bc9170e2-363a-4c00-85a1-419765d2f7c1	717a93bf-59cc-4db8-b817-682d44652d82	D	f	2026-04-28 07:17:54.741438+00
f2618250-babf-4cc1-a6c0-724a8b7c272a	bc9170e2-363a-4c00-85a1-419765d2f7c1	e3d860a5-7343-43e8-bcb8-ce5805debcf7	B	f	2026-04-28 07:17:55.623883+00
81cd450c-7c02-4026-ac44-74f97f734f36	bc9170e2-363a-4c00-85a1-419765d2f7c1	e67dc779-dc77-43b4-b0ce-c4894489103e	C	f	2026-04-28 07:17:57.185415+00
9435a843-4c01-4c0e-89a9-f0ac599bb04d	bc9170e2-363a-4c00-85a1-419765d2f7c1	69a58ffa-5f06-43ad-9351-93fcac89a144	D	f	2026-04-28 07:17:58.34087+00
ff59f282-f0a7-47da-a871-82c71dcbd6cf	29cdc3de-814d-4f5c-825a-06abb47b5a1a	8af36a16-997a-4f49-8622-77c5f80334df	D	f	2026-04-28 07:37:33.995619+00
235c85b8-bea6-4410-904b-630a52b298ea	29cdc3de-814d-4f5c-825a-06abb47b5a1a	66e563db-29f8-4f21-8537-c0127e5e63cc	B	f	2026-04-28 07:37:35.151726+00
82ad6fcf-6255-4605-b806-95e34a205139	bf130cc3-2254-4ad4-a900-3560e173d1c8	8af36a16-997a-4f49-8622-77c5f80334df	C	f	2026-04-28 07:43:07.05972+00
7409a020-8763-4f61-b8f0-882cbd773f62	bf130cc3-2254-4ad4-a900-3560e173d1c8	66e563db-29f8-4f21-8537-c0127e5e63cc	A	f	2026-04-28 07:43:10.74179+00
ddfa8cbb-5689-487d-8f78-a16b46e0ade7	bf130cc3-2254-4ad4-a900-3560e173d1c8	0d3a863f-1bdc-4700-9fde-50a6789967a6	B	t	2026-04-28 07:43:11.706273+00
34a27ed7-663b-4865-bb2b-9ffa3f04b949	bf130cc3-2254-4ad4-a900-3560e173d1c8	e7e5c15d-593a-41f6-a631-17cee6c3d6e2	A	f	2026-04-28 07:43:14.310744+00
62d0f8ee-0f97-4750-b1a0-9abbe60267f4	bf130cc3-2254-4ad4-a900-3560e173d1c8	cf3e3677-791a-4595-acca-dbdb0f4d2908	A	t	2026-04-28 07:43:15.757892+00
0dadad5a-67df-4434-9b08-c207fbbcfc81	bf130cc3-2254-4ad4-a900-3560e173d1c8	14e7bcbb-c2f7-48bc-aa90-74c03999d9e7	C	f	2026-04-28 07:43:17.522221+00
e2fe340e-7ded-4476-82d5-56088b3320de	bf130cc3-2254-4ad4-a900-3560e173d1c8	d0ff282d-2b31-4f6d-a72b-f0e522b93a60	C	f	2026-04-28 07:43:19.324021+00
11d8cd26-67b8-413b-b331-e52e37bdf198	bf130cc3-2254-4ad4-a900-3560e173d1c8	d8122c72-6c11-4278-835b-9d1e6df1a3c8	C	f	2026-04-28 07:43:20.742948+00
f92e7c04-0323-45b6-a1a8-d4f66a566b16	bf130cc3-2254-4ad4-a900-3560e173d1c8	004f4b76-a500-47d3-a015-235e0717205b	B	f	2026-04-28 07:43:34.342651+00
5062face-d051-4e5e-aba0-1d058bb05e38	bf130cc3-2254-4ad4-a900-3560e173d1c8	3ecc6897-3b48-4930-b659-d597c69c83bc	A	f	2026-04-28 07:43:38.742189+00
d802b76d-ddd8-4870-b709-6b978fb2273d	bf130cc3-2254-4ad4-a900-3560e173d1c8	c619a5da-b633-425a-92b2-34cb831fd662	B	f	2026-04-28 07:43:39.875413+00
aeb734a1-e590-48cf-8218-e3b42d6af43c	bf130cc3-2254-4ad4-a900-3560e173d1c8	9b17131f-11a6-4ea3-a6bb-38b56357e858	D	f	2026-04-28 07:43:40.926329+00
517fc80b-f78a-479a-b898-f8166c90a14c	bf130cc3-2254-4ad4-a900-3560e173d1c8	e9c58f65-779c-4040-94a0-db21a41f3a7a	B	f	2026-04-28 07:43:41.99041+00
bfd8e137-1d22-4585-996c-76b0558d0682	bf130cc3-2254-4ad4-a900-3560e173d1c8	0c357720-5066-4fd6-a7d7-64dde5fcb0c2	D	f	2026-04-28 07:43:43.175106+00
8f994b40-f542-4cb7-a374-66afb0fd3e5e	bf130cc3-2254-4ad4-a900-3560e173d1c8	454c4c4e-a9c0-4349-9861-1d2394b1c495	C	f	2026-04-28 07:43:46.143949+00
55601b51-efdc-477a-ad83-c5c6e05917d1	bf130cc3-2254-4ad4-a900-3560e173d1c8	6dc0f00b-5ebd-4b0e-b639-2168d0bea3ce	A	t	2026-04-28 07:43:48.418434+00
d4ae8aa7-5db0-46ba-adca-4f68613c5755	1ca4deb3-7b3d-4983-8c8c-b70d88eddcaf	ecfc3df5-ed6a-44f4-9485-2c29f731aa0b	D	t	2026-04-28 09:40:43.165685+00
94ff9b26-8f47-47ae-bf7d-e1ff24134a1c	a3d35273-6851-4c00-96de-1bbf6dfc9257	8af36a16-997a-4f49-8622-77c5f80334df	B	t	2026-04-28 12:57:51.706585+00
8eafef0f-4a31-496a-9d10-5ec4858a08f3	2557bb3a-9869-422c-ac10-8000966fb728	8af36a16-997a-4f49-8622-77c5f80334df	B	t	2026-04-28 12:58:02.911853+00
d52b7942-7672-4ac0-aad2-fb0e9b54b45e	a3d35273-6851-4c00-96de-1bbf6dfc9257	e7e5c15d-593a-41f6-a631-17cee6c3d6e2	C	t	2026-04-28 13:01:14.490012+00
9ff83b00-2069-4bfc-81b7-e25cff572f30	71805292-835e-4ff3-a365-f30fcfc06048	8af36a16-997a-4f49-8622-77c5f80334df	B	t	2026-04-28 12:58:27.722625+00
91435839-3b77-4f87-8330-bf4293a4f2a2	a3d35273-6851-4c00-96de-1bbf6dfc9257	0d3a863f-1bdc-4700-9fde-50a6789967a6	B	t	2026-04-28 12:58:29.481022+00
e5467a17-48b1-4094-a5de-ecfff28100ba	2557bb3a-9869-422c-ac10-8000966fb728	0d3a863f-1bdc-4700-9fde-50a6789967a6	B	t	2026-04-28 12:59:21.084404+00
c82bf6cf-3eb8-4802-aee0-87b45ad104f1	a3d35273-6851-4c00-96de-1bbf6dfc9257	6ebea734-46a1-4bc7-9949-cfd2128f81e9	B	t	2026-04-28 13:00:17.732429+00
6307ab3b-3dc3-4f1f-ae92-922ffa8914bb	2557bb3a-9869-422c-ac10-8000966fb728	73b59855-deaa-4f41-9913-5a53a9111826	B	t	2026-04-28 13:20:39.245582+00
65918bbb-a191-46a0-99e6-38ae856de921	71805292-835e-4ff3-a365-f30fcfc06048	80f911b3-a969-481c-bb8d-6920cf9cb4c3	C	f	2026-04-28 13:21:31.506245+00
83d0250a-421f-4d8c-9ff9-7abfa7b25e7d	a3d35273-6851-4c00-96de-1bbf6dfc9257	cf3e3677-791a-4595-acca-dbdb0f4d2908	A	t	2026-04-28 13:01:37.968117+00
23dbce95-a401-4102-bedb-bfbc57f96d08	2557bb3a-9869-422c-ac10-8000966fb728	46017748-34b0-4df2-ba25-ae8a35202fd9	A	t	2026-04-28 13:02:15.434536+00
3ff8b95b-509a-41f4-9f23-eff1fc0eea55	71805292-835e-4ff3-a365-f30fcfc06048	08a035f1-feef-4d5b-8017-ef1773ce0f4d	C	f	2026-04-28 13:24:10.551053+00
c464ae00-e1d8-442e-bc1a-cd1c301b7421	2557bb3a-9869-422c-ac10-8000966fb728	75a24797-7a12-4fab-a527-e72c1d201203	D	f	2026-04-28 13:24:43.496178+00
b8f799e9-0c87-4b42-8324-3ebc3a3219c5	71805292-835e-4ff3-a365-f30fcfc06048	75a24797-7a12-4fab-a527-e72c1d201203	D	f	2026-04-28 13:24:45.524006+00
d2344927-caf9-4651-8bbb-153f94f6dd6d	71805292-835e-4ff3-a365-f30fcfc06048	46017748-34b0-4df2-ba25-ae8a35202fd9	A	t	2026-04-28 13:02:25.692064+00
0178e74d-38b8-4d1d-b378-4571ecefe38d	2557bb3a-9869-422c-ac10-8000966fb728	6ebea734-46a1-4bc7-9949-cfd2128f81e9	B	t	2026-04-28 13:02:44.370303+00
c3792b5c-419c-4988-81d7-d0aa62612d8b	2557bb3a-9869-422c-ac10-8000966fb728	cf3e3677-791a-4595-acca-dbdb0f4d2908	A	t	2026-04-28 13:03:18.659383+00
9c7c3f8e-e22a-4d53-9a28-4d116459c5ae	71805292-835e-4ff3-a365-f30fcfc06048	6ebea734-46a1-4bc7-9949-cfd2128f81e9	B	t	2026-04-28 13:03:32.588798+00
011fcb6b-df0f-47bb-9eac-59986b17ef36	a3d35273-6851-4c00-96de-1bbf6dfc9257	e92084ad-292d-4840-abe3-026cbdede660	A	t	2026-04-28 13:04:26.991721+00
3b3bff72-81af-4872-b766-abdf37b79acf	a3d35273-6851-4c00-96de-1bbf6dfc9257	d0ff282d-2b31-4f6d-a72b-f0e522b93a60	A	t	2026-04-28 13:05:11.196261+00
8eb028b8-a075-451b-af0d-804babb3593e	71805292-835e-4ff3-a365-f30fcfc06048	cf3e3677-791a-4595-acca-dbdb0f4d2908	A	t	2026-04-28 13:05:13.473779+00
8dc8cd90-1478-4b88-af99-4dfe2b488560	2557bb3a-9869-422c-ac10-8000966fb728	14e7bcbb-c2f7-48bc-aa90-74c03999d9e7	A	t	2026-04-28 13:05:15.118894+00
32ac35ed-e573-4bdd-92b6-d561844324c7	2557bb3a-9869-422c-ac10-8000966fb728	e7e5c15d-593a-41f6-a631-17cee6c3d6e2	C	t	2026-04-28 13:07:43.037184+00
7c5a23c2-fb93-42fe-8250-febb25e10c0c	a3d35273-6851-4c00-96de-1bbf6dfc9257	0d6a324b-4f00-466e-9db4-a00dca497c99	C	t	2026-04-28 13:07:53.398567+00
57135ffd-4285-41b9-beb2-021cd28bc3cb	71805292-835e-4ff3-a365-f30fcfc06048	e7e5c15d-593a-41f6-a631-17cee6c3d6e2	C	t	2026-04-28 13:08:36.110171+00
8e7b91b2-91e9-4832-97d0-62742c3cc29b	2557bb3a-9869-422c-ac10-8000966fb728	e92084ad-292d-4840-abe3-026cbdede660	D	f	2026-04-28 13:08:56.810227+00
73d65e82-c622-4a56-a395-86892a7efd49	a3d35273-6851-4c00-96de-1bbf6dfc9257	80f911b3-a969-481c-bb8d-6920cf9cb4c3	B	t	2026-04-28 13:09:10.333949+00
ca524268-7fa1-4e00-84be-76d1ba396d79	2557bb3a-9869-422c-ac10-8000966fb728	d0ff282d-2b31-4f6d-a72b-f0e522b93a60	A	t	2026-04-28 13:10:25.343271+00
f0ce5d20-e5a6-4a9c-986c-dbbb3bcacbaf	2557bb3a-9869-422c-ac10-8000966fb728	d8122c72-6c11-4278-835b-9d1e6df1a3c8	A	t	2026-04-28 13:11:25.670671+00
1da62cf6-2b11-4b50-a0d3-3864fe96af36	a3d35273-6851-4c00-96de-1bbf6dfc9257	fa4ff435-2391-4047-b44c-f685d53e9f55	B	f	2026-04-28 13:11:51.344366+00
92221f20-31ff-4fc2-aa5f-f816ac29722d	71805292-835e-4ff3-a365-f30fcfc06048	73c1c74d-b66f-4759-8fe1-c9a414e37872	C	t	2026-04-28 13:25:16.498005+00
d1d7d5ef-94d6-457b-b863-104c2cd648cd	a3d35273-6851-4c00-96de-1bbf6dfc9257	08a035f1-feef-4d5b-8017-ef1773ce0f4d	C	f	2026-04-28 13:12:42.317472+00
a136bc26-383c-49eb-ab1f-177e94ef5eed	a3d35273-6851-4c00-96de-1bbf6dfc9257	73c1c74d-b66f-4759-8fe1-c9a414e37872	C	t	2026-04-28 13:13:19.039046+00
2d884381-4dec-4b0c-a175-0581efb3591e	71805292-835e-4ff3-a365-f30fcfc06048	9c09af5e-a1c7-4691-9711-b9cd745d9753	A	f	2026-04-28 13:26:20.405919+00
f48ee382-0799-49fe-bf79-cd2261ad9853	71805292-835e-4ff3-a365-f30fcfc06048	14e7bcbb-c2f7-48bc-aa90-74c03999d9e7	A	t	2026-04-28 13:13:21.537438+00
f670f629-dafa-4958-8e87-2f30fd6ac701	2557bb3a-9869-422c-ac10-8000966fb728	80f911b3-a969-481c-bb8d-6920cf9cb4c3	B	t	2026-04-28 13:14:01.753572+00
52f23eeb-a7b5-4393-adcf-428e070a0447	71805292-835e-4ff3-a365-f30fcfc06048	e92084ad-292d-4840-abe3-026cbdede660	B	f	2026-04-28 13:15:39.316156+00
b61ab5ad-ce8c-4a3d-80bb-d6b24e233d76	2557bb3a-9869-422c-ac10-8000966fb728	08a035f1-feef-4d5b-8017-ef1773ce0f4d	C	f	2026-04-28 13:16:02.972837+00
7333228f-68bf-4ec4-a129-9e18b0f5658a	a3d35273-6851-4c00-96de-1bbf6dfc9257	75a24797-7a12-4fab-a527-e72c1d201203	D	f	2026-04-28 13:16:20.717585+00
d5c33ec8-9b8c-4acc-b533-aafb38de2cac	a3d35273-6851-4c00-96de-1bbf6dfc9257	9c09af5e-a1c7-4691-9711-b9cd745d9753	C	t	2026-04-28 13:16:34.159711+00
04d9f132-1e51-4f6a-90f3-9fe77b56db26	71805292-835e-4ff3-a365-f30fcfc06048	d0ff282d-2b31-4f6d-a72b-f0e522b93a60	C	f	2026-04-28 13:17:06.569736+00
8885a2ad-2006-401c-8074-6d311fa13789	a3d35273-6851-4c00-96de-1bbf6dfc9257	001777f1-ddfd-4c1d-9f39-0f7ea9489952	B	f	2026-04-28 13:17:10.698489+00
d756716e-8509-4359-b192-2aa1b3bd9053	a3d35273-6851-4c00-96de-1bbf6dfc9257	ff1a1634-1cba-4dfd-a821-3c681b5fd44e	(A)	f	2026-04-28 13:17:19.460621+00
03e9f71f-661f-4014-9adb-e69b13637033	2557bb3a-9869-422c-ac10-8000966fb728	73c1c74d-b66f-4759-8fe1-c9a414e37872	C	t	2026-04-28 13:17:28.901085+00
ba990d81-5880-459c-9a81-339c9f7794ee	71805292-835e-4ff3-a365-f30fcfc06048	d8122c72-6c11-4278-835b-9d1e6df1a3c8	A	t	2026-04-28 13:17:48.290356+00
897597a2-a86a-416e-a5cd-7e66027e79eb	a3d35273-6851-4c00-96de-1bbf6dfc9257	73b59855-deaa-4f41-9913-5a53a9111826	B	t	2026-04-28 13:18:22.725008+00
059c3b58-6fb8-4dd8-9e50-39b80fac1676	a3d35273-6851-4c00-96de-1bbf6dfc9257	87e60be5-0a87-45da-ad2f-f8266e80c18c	B	t	2026-04-28 13:26:37.567277+00
d64467e7-48eb-4419-a882-252540532fe9	a3d35273-6851-4c00-96de-1bbf6dfc9257	d254c27e-6371-48b8-96a2-4f5407502a92	B	t	2026-04-28 13:27:19.027741+00
3e509e0e-1a4e-414f-8997-2f6da6d466f3	71805292-835e-4ff3-a365-f30fcfc06048	73b59855-deaa-4f41-9913-5a53a9111826	B	t	2026-04-28 13:28:39.162915+00
caf14e67-304f-4264-a1dc-d29d50c09c68	71805292-835e-4ff3-a365-f30fcfc06048	001777f1-ddfd-4c1d-9f39-0f7ea9489952	B	f	2026-04-28 13:27:24.396266+00
2b8ce959-d7c0-406b-8c4f-0faccfcb1d90	a3d35273-6851-4c00-96de-1bbf6dfc9257	a01b5c95-1c9e-4319-b48f-90743f87f68c	C	t	2026-04-28 13:27:56.696756+00
8fb32e53-ff02-47a2-80e2-a922f9abd117	a3d35273-6851-4c00-96de-1bbf6dfc9257	93d31d40-3d8a-4907-89b2-12486ee52608	C	t	2026-04-28 13:29:03.609848+00
a0b66e6e-67da-46e4-a61f-2ee3a5df154f	a3d35273-6851-4c00-96de-1bbf6dfc9257	cdfddac8-993b-4063-a369-7e44a7d24b69	C	t	2026-04-28 13:29:27.522193+00
06bd51e2-f9b1-448b-9381-dec55ddc9c19	2557bb3a-9869-422c-ac10-8000966fb728	c7cb926c-cb05-4342-86c3-3c23a8749ebf	A	f	2026-04-28 13:29:37.303327+00
7f690937-29c1-4c2e-8f10-27cdb73cc7be	71805292-835e-4ff3-a365-f30fcfc06048	cb3208dc-39aa-44b3-8625-60ee6507cbf3	A	f	2026-04-28 13:29:41.829961+00
8ebbd72d-4913-4495-85e5-4b27f343db08	2557bb3a-9869-422c-ac10-8000966fb728	4599acb3-9d78-4bf9-8c9b-47bc3b7756d6	C	f	2026-04-28 13:29:50.159668+00
96ea46bb-3db8-4f0a-bcb6-d723b9503fde	a3d35273-6851-4c00-96de-1bbf6dfc9257	27cfb107-5cd9-4f06-9464-e31b0758e1a3	C	t	2026-04-28 13:29:50.280391+00
63787edc-107d-4ce0-b468-ba60a86ea0a5	2557bb3a-9869-422c-ac10-8000966fb728	b7a602a2-e595-4a46-8aca-637cb75a3eee	C	t	2026-04-28 13:30:21.679606+00
60670842-5321-4e73-83c8-69136b9f409f	a3d35273-6851-4c00-96de-1bbf6dfc9257	f69b2d12-2038-41a9-b416-d3c480736f5b	A	t	2026-04-28 13:32:17.332904+00
25cdb1e4-a61e-4f70-b422-00ea630db744	2557bb3a-9869-422c-ac10-8000966fb728	28c07dfe-cb42-44d4-9f2f-dda64ffb6882	A	f	2026-04-28 13:32:17.893482+00
4b7d4ec1-1955-4f27-8369-29768b75cece	71805292-835e-4ff3-a365-f30fcfc06048	2a7dc3da-9520-4108-929c-a14782e25c36	B	f	2026-04-28 13:32:56.890146+00
d8c0325f-4af0-475e-9246-53c5ba91b94b	a3d35273-6851-4c00-96de-1bbf6dfc9257	7452052d-1c3d-4aa8-8fcd-e58556513248	A	t	2026-04-28 13:33:09.8762+00
07bd79e8-caae-40ad-8fb8-479e20492a63	a3d35273-6851-4c00-96de-1bbf6dfc9257	6dc0f00b-5ebd-4b0e-b639-2168d0bea3ce	A	t	2026-04-28 13:33:19.1763+00
8c02950f-2629-4957-a9c7-85880a3d85ed	2557bb3a-9869-422c-ac10-8000966fb728	38286d3b-99a2-4122-b821-87eb0a236eca	A	t	2026-04-28 13:34:20.179714+00
2afe9637-33cb-4283-9c60-33ecd54751f6	a3d35273-6851-4c00-96de-1bbf6dfc9257	454c4c4e-a9c0-4349-9861-1d2394b1c495	A	t	2026-04-28 13:34:45.157709+00
d12c2287-6c80-40ca-baf2-e139d3538906	71805292-835e-4ff3-a365-f30fcfc06048	4599acb3-9d78-4bf9-8c9b-47bc3b7756d6	A	f	2026-04-28 13:34:50.506421+00
26c74dec-cd5b-4f32-a7c6-08b5c3b3e94e	a3d35273-6851-4c00-96de-1bbf6dfc9257	0c357720-5066-4fd6-a7d7-64dde5fcb0c2	A	t	2026-04-28 13:35:35.157643+00
b2501fc1-ca38-4471-b3df-a3339b039239	2557bb3a-9869-422c-ac10-8000966fb728	ba844b10-8d58-4186-9c14-2cdced4aaeae	B	t	2026-04-28 13:35:37.932222+00
6fa6adef-77cc-4bb3-a4b1-f61847833aa6	a3d35273-6851-4c00-96de-1bbf6dfc9257	e9c58f65-779c-4040-94a0-db21a41f3a7a	D	t	2026-04-28 13:35:43.09537+00
ecc45170-923f-490c-844a-507a8bd9fa7e	71805292-835e-4ff3-a365-f30fcfc06048	0d9953e6-403e-4dfe-8d1b-81061084d971	A	f	2026-04-28 13:35:57.202707+00
58ac6a6d-9558-4b48-a32c-9e689c09ee27	a3d35273-6851-4c00-96de-1bbf6dfc9257	9b17131f-11a6-4ea3-a6bb-38b56357e858	B	t	2026-04-28 13:36:14.859981+00
f2df7c2b-fd51-4369-af16-b601ea1dc52f	a3d35273-6851-4c00-96de-1bbf6dfc9257	c619a5da-b633-425a-92b2-34cb831fd662	A	t	2026-04-28 13:36:45.707364+00
249037ec-ce09-4827-a14f-a0d1864fe3b7	71805292-835e-4ff3-a365-f30fcfc06048	c7cb926c-cb05-4342-86c3-3c23a8749ebf	A	f	2026-04-28 13:36:51.793217+00
fd68bf50-136a-4fc1-825a-df58fe6abb6f	a3d35273-6851-4c00-96de-1bbf6dfc9257	3ecc6897-3b48-4930-b659-d597c69c83bc	B	t	2026-04-28 13:37:33.226028+00
83419ae8-59c4-42e0-91f6-199c9adf480c	71805292-835e-4ff3-a365-f30fcfc06048	b7a602a2-e595-4a46-8aca-637cb75a3eee	C	t	2026-04-28 13:38:11.542169+00
f7e0c7d7-9c49-40cc-bcd8-c794899f6b8f	a3d35273-6851-4c00-96de-1bbf6dfc9257	42ed3074-0269-4669-9f60-ed38853ba85a	A	t	2026-04-28 13:38:22.325478+00
4854cd92-847b-40b1-b0e8-f0566d8a92c0	2557bb3a-9869-422c-ac10-8000966fb728	a573f0bf-6d03-49fe-bb60-accbb25272cb	B	t	2026-04-28 13:38:34.356172+00
86fa765a-8bbb-4b1f-98a5-d705613067a5	71805292-835e-4ff3-a365-f30fcfc06048	87a00d9d-0b71-46a9-a5b5-dab32ffe2472	A	t	2026-04-28 14:03:17.387583+00
47f846f9-6fc5-4261-b665-553f0ea4632b	2557bb3a-9869-422c-ac10-8000966fb728	9eb2d84f-c683-46fd-b93a-def8d294ca2b	C	t	2026-04-28 14:03:37.786337+00
a4695aec-3be2-4e5e-ba26-f398b1061277	a3d35273-6851-4c00-96de-1bbf6dfc9257	49ac5214-08aa-4093-9790-8e3402278800	B	t	2026-04-28 14:03:41.372904+00
178ea1bf-5f9a-4bca-a352-9ca0ea6b8897	71805292-835e-4ff3-a365-f30fcfc06048	854a05d3-849b-4dd9-a522-4b7c9d192a45	A	f	2026-04-28 13:38:39.04178+00
d8f902a3-739a-4047-8fd5-fc745c2190ee	a3d35273-6851-4c00-96de-1bbf6dfc9257	9f65ed34-7e3f-42fd-88dc-49989c66c493	B	f	2026-04-28 13:38:52.253607+00
3ff8616b-4076-48fc-b567-9ef09efd627b	71805292-835e-4ff3-a365-f30fcfc06048	28c07dfe-cb42-44d4-9f2f-dda64ffb6882	C	t	2026-04-28 13:39:23.787353+00
34ce5e46-61d7-4095-b939-8b987dd4664c	2557bb3a-9869-422c-ac10-8000966fb728	1b88a88c-cb2d-4184-a5e0-de08129088a2	C	t	2026-04-28 13:40:13.391063+00
ba26879f-e78c-4cea-93be-c430539286b4	a3d35273-6851-4c00-96de-1bbf6dfc9257	a772c84b-1fe5-43b3-8631-af02fd8450a1	C	t	2026-04-28 13:40:17.875711+00
fb0c4854-e027-4686-9588-c83477426f69	a3d35273-6851-4c00-96de-1bbf6dfc9257	aed35f2e-37e1-442a-b518-86d99c84bcea	A	t	2026-04-28 13:42:09.363739+00
e99f3f6b-f0cf-4b45-81ec-e6b1e3292ca7	71805292-835e-4ff3-a365-f30fcfc06048	ba844b10-8d58-4186-9c14-2cdced4aaeae	B	t	2026-04-28 13:42:16.026875+00
66624d83-86e1-42a8-9396-e7e1fda84619	a3d35273-6851-4c00-96de-1bbf6dfc9257	d16e6125-c814-44cb-86d7-0eaaa8baa883	A	f	2026-04-28 13:42:28.003509+00
b9666895-9fed-4d50-b44e-e52b49f5863d	2557bb3a-9869-422c-ac10-8000966fb728	fcb4d325-5f11-4166-ba6e-0c718d6b8936	D	f	2026-04-28 13:43:10.146277+00
136b583f-6260-4901-ac35-b503a79995f1	2557bb3a-9869-422c-ac10-8000966fb728	38f811fb-1c5b-48db-878a-e7492dac0d62	B	t	2026-04-28 13:43:38.008607+00
e74d5b9b-c8b3-402b-8891-8bd62609d28e	71805292-835e-4ff3-a365-f30fcfc06048	70b8f220-c374-4587-bcb2-12f7e2fa0bf7	C	t	2026-04-28 13:43:50.568172+00
cd9b4f73-b795-4ca9-91ec-37f200da88c1	a3d35273-6851-4c00-96de-1bbf6dfc9257	93402563-6af3-45ec-9de0-aede8c8fb6b0	D	t	2026-04-28 13:44:07.133574+00
e171394c-0491-467b-a73e-10efaf34a3e4	a3d35273-6851-4c00-96de-1bbf6dfc9257	06124444-db56-443e-8025-1c2c369f8576	B	t	2026-04-28 13:44:45.025185+00
3317353a-1b55-4943-9258-100fd0b0964e	a3d35273-6851-4c00-96de-1bbf6dfc9257	f29d26aa-a051-4d45-b580-7f49cc55ac8e	B	t	2026-04-28 13:44:56.969433+00
541b84c3-0a05-4c36-ba37-c41b42da0b3d	71805292-835e-4ff3-a365-f30fcfc06048	011f55e3-6770-4d47-9e46-3b8cd0e83955	C	t	2026-04-28 13:45:00.2591+00
c741e886-b5a0-4309-a3f9-7a8bce1fcdd1	2557bb3a-9869-422c-ac10-8000966fb728	1cba308b-e030-438f-bf35-8632f38605e8	D	t	2026-04-28 13:45:47.970569+00
911f03a5-e8e5-4ab0-8d1d-593e6f086c0f	a3d35273-6851-4c00-96de-1bbf6dfc9257	314c5e8f-d335-43b8-9d15-98ddd83054ac	B	t	2026-04-28 13:46:46.272268+00
40f50a58-99c9-4021-9f43-3df9cc6269a2	2557bb3a-9869-422c-ac10-8000966fb728	d3ccca49-10b5-4f46-ac64-eb70abeb097a	A	t	2026-04-28 13:46:56.883997+00
245f0694-f805-4632-8045-a71f7681c5de	a3d35273-6851-4c00-96de-1bbf6dfc9257	01cdbfcd-5a74-450f-b9fa-69200db938c3	C	t	2026-04-28 13:46:58.155784+00
09523284-f827-4af4-91a1-9b13a69af970	2557bb3a-9869-422c-ac10-8000966fb728	af038b7c-e600-4d33-8155-21719ce50014	A	t	2026-04-28 13:47:10.64207+00
23ed58fc-156b-497f-981f-d9b15bb08eff	71805292-835e-4ff3-a365-f30fcfc06048	a573f0bf-6d03-49fe-bb60-accbb25272cb	A	f	2026-04-28 13:47:40.306011+00
2158c490-cf59-4d9f-a2b1-31098aad0b60	a3d35273-6851-4c00-96de-1bbf6dfc9257	52ec6e64-8b1a-461b-a878-0c0c035dbbd4	A	t	2026-04-28 13:47:54.726156+00
d218fb05-175e-41a7-ba5d-60552988adc2	2557bb3a-9869-422c-ac10-8000966fb728	6b8b0d2e-4b91-4511-9acf-a2f4c0fce4e9	A	t	2026-04-28 13:47:59.768194+00
72fbf19a-82a4-4bc9-9d1b-c58819d46140	71805292-835e-4ff3-a365-f30fcfc06048	1b88a88c-cb2d-4184-a5e0-de08129088a2	C	t	2026-04-28 13:48:25.799589+00
02d1cab4-c24e-453c-989d-38070e3638e5	a3d35273-6851-4c00-96de-1bbf6dfc9257	b1c543d3-0318-4e2d-bc4b-6212bc78941b	C	t	2026-04-28 13:49:03.458505+00
04023f3a-65d1-42b1-b001-78a70257626f	a3d35273-6851-4c00-96de-1bbf6dfc9257	f0807419-d303-4100-8168-7fa61676df98	A	t	2026-04-28 13:49:25.090163+00
12ad333a-12ba-43e0-b6b3-bf91e708e6ca	a3d35273-6851-4c00-96de-1bbf6dfc9257	6b90fb4c-402a-49a3-95a2-75d1eb435bea	B	t	2026-04-28 13:49:40.041969+00
84a19c75-5230-48e8-8082-f0a068ed17fa	2557bb3a-9869-422c-ac10-8000966fb728	87a00d9d-0b71-46a9-a5b5-dab32ffe2472	A	t	2026-04-28 13:49:47.123676+00
598792b1-e07a-4e57-b7ee-12a6032d59e5	a3d35273-6851-4c00-96de-1bbf6dfc9257	993ab2ec-b5b1-45ce-8e69-172067cd19a5	D	t	2026-04-28 13:49:55.979657+00
dfe46d24-9023-41b5-bcce-3e6a1b034a1a	a3d35273-6851-4c00-96de-1bbf6dfc9257	bb8e0d8a-95dc-4430-a5de-bbedcd1d8fda	B	t	2026-04-28 13:50:14.410927+00
cbdd6955-6a4a-4588-b04f-31964f8b2b2f	2557bb3a-9869-422c-ac10-8000966fb728	98043387-e7c4-4277-99f0-6815949e7288	B	f	2026-04-28 13:50:42.102261+00
f950ccbf-5f08-4d63-945c-476a2d76cc9c	71805292-835e-4ff3-a365-f30fcfc06048	38f811fb-1c5b-48db-878a-e7492dac0d62	B	t	2026-04-28 13:51:21.148823+00
2983de05-dedb-423b-a855-1af03de9e397	a3d35273-6851-4c00-96de-1bbf6dfc9257	1e77e791-b572-49c5-96d7-14115d517329	D	t	2026-04-28 13:51:40.386099+00
941709a4-9067-43fe-b5ea-be7cbd81da90	2557bb3a-9869-422c-ac10-8000966fb728	057d9d16-3096-49a9-9332-91786e8f7fde	A	t	2026-04-28 13:51:57.366838+00
5ac1d2de-9299-4936-affc-649753de0ad2	a3d35273-6851-4c00-96de-1bbf6dfc9257	0e7b1d5f-a655-4b21-a3e9-37c113cfc52e	B	t	2026-04-28 13:52:24.991547+00
1ce87955-0440-4a58-9785-922d5d63c49d	a3d35273-6851-4c00-96de-1bbf6dfc9257	d9ca492d-8ac0-487a-8a2e-0644d67689e2	B	t	2026-04-28 13:52:41.492095+00
734da60c-ac9f-407d-9bba-939ce09cbb7a	a3d35273-6851-4c00-96de-1bbf6dfc9257	49fe07e4-d291-4f8f-b4f9-0fc162ad8553	D	t	2026-04-28 13:53:16.493827+00
26144a1b-dbe3-4cb3-a631-34d6c8e9ee36	a3d35273-6851-4c00-96de-1bbf6dfc9257	bddb3fc5-93d3-4c42-a66d-96227a6e8f0f	C	t	2026-04-28 13:54:01.522018+00
00c94a79-43c7-4051-bc9d-72bb0a02e46e	71805292-835e-4ff3-a365-f30fcfc06048	fcb4d325-5f11-4166-ba6e-0c718d6b8936	C	t	2026-04-28 13:54:06.496458+00
de4ddcaf-c50f-4a71-9d21-ab8feab022c7	a3d35273-6851-4c00-96de-1bbf6dfc9257	3685e2c6-f04d-478e-87ed-12d8cc72939c	B	t	2026-04-28 13:54:52.54935+00
f4a42b25-af6e-42b5-a24d-1d8899817408	a3d35273-6851-4c00-96de-1bbf6dfc9257	a7474a47-2e26-491d-a7b9-b04b8138e571	B	t	2026-04-28 13:55:10.250489+00
43c2b2e4-395f-4f4f-b365-d0fbf5f141e2	a3d35273-6851-4c00-96de-1bbf6dfc9257	050c9a2a-afc8-4cf8-84d4-2c22be81abd0	C	f	2026-04-28 13:55:24.827833+00
1289c66a-777d-4e71-b8ad-7909251ddc1b	a3d35273-6851-4c00-96de-1bbf6dfc9257	461e205a-bb8a-4bdd-81fb-f8a21d854215	B	t	2026-04-28 13:55:41.177279+00
cd6e487f-65f4-4233-9a05-146e534991d9	71805292-835e-4ff3-a365-f30fcfc06048	1cba308b-e030-438f-bf35-8632f38605e8	D	t	2026-04-28 13:56:07.338581+00
c568ea3d-6a1e-4062-a7c3-bada2e4a1028	2557bb3a-9869-422c-ac10-8000966fb728	fb75ef93-d920-4f94-81ea-1d9ff5b08784	B	f	2026-04-28 13:56:20.076365+00
8858186b-3e63-4ba5-9c8c-2e15652dd281	a3d35273-6851-4c00-96de-1bbf6dfc9257	816a0061-1e82-44b0-8914-79a1931908fd	C	t	2026-04-28 13:56:51.122751+00
8ef5388b-8497-495c-a080-a9ac783ba0bc	a3d35273-6851-4c00-96de-1bbf6dfc9257	4b3fd082-8394-4ecc-afda-a36b07d05658	B	t	2026-04-28 13:58:06.306185+00
b95608f7-3095-45e6-b8b9-9689e002206d	2557bb3a-9869-422c-ac10-8000966fb728	568b2bc9-9a19-44c0-8b8b-8d0045475282	D	t	2026-04-28 13:58:07.793427+00
76232c17-7291-46e7-8022-bbfb72616433	2557bb3a-9869-422c-ac10-8000966fb728	a360f901-de88-4d26-8f31-c16713d3b6da	A	t	2026-04-28 13:58:15.880382+00
66f7b592-9f2a-4e5a-8d8a-6065891dc669	71805292-835e-4ff3-a365-f30fcfc06048	d3ccca49-10b5-4f46-ac64-eb70abeb097a	A	t	2026-04-28 13:58:25.66343+00
c42da56a-e21a-459f-aba0-abc2fc759a23	a3d35273-6851-4c00-96de-1bbf6dfc9257	19e6c77e-9cfc-4eec-99c4-afdb0ba05ca5	A	t	2026-04-28 13:58:48.302048+00
48deaac1-23a1-4931-9a8c-de779672bf7d	a3d35273-6851-4c00-96de-1bbf6dfc9257	0bd7afbd-dcc0-410b-bde1-5355b8cb277f	C	t	2026-04-28 13:58:52.200384+00
f6739831-a4f1-4798-8ff9-10549a80b3c5	a3d35273-6851-4c00-96de-1bbf6dfc9257	f43d91bf-4188-4d97-8011-e759b608a2e2	C	t	2026-04-28 13:59:23.470292+00
efc57772-1a55-430c-99e3-42d9b37704a0	a3d35273-6851-4c00-96de-1bbf6dfc9257	f606aac2-ea93-4afb-894f-6c4fa67e6b05	B	f	2026-04-28 13:59:50.55772+00
5f3bb74e-e03a-4f57-bf41-0c374386b2b1	2557bb3a-9869-422c-ac10-8000966fb728	bd780c4e-1e12-4891-a7a0-e6a61eed1456	B	t	2026-04-28 14:00:05.424692+00
d0f6b74f-3354-4fcd-9eac-3c7b8d50ab06	71805292-835e-4ff3-a365-f30fcfc06048	af038b7c-e600-4d33-8155-21719ce50014	D	f	2026-04-28 14:00:47.001915+00
9501cef9-0a0d-4b10-afd4-5e1d03d42588	2557bb3a-9869-422c-ac10-8000966fb728	f1859d7a-e0a7-4fd0-b9c8-a04f01ee9d2a	A	t	2026-04-28 14:01:10.412253+00
3547a6e6-750a-479e-8ff4-07a9fb1df2bd	71805292-835e-4ff3-a365-f30fcfc06048	6b8b0d2e-4b91-4511-9acf-a2f4c0fce4e9	A	t	2026-04-28 14:01:20.047096+00
4cb90103-44de-4000-b6d0-5b8ba89a6149	2557bb3a-9869-422c-ac10-8000966fb728	2e1e2c65-8558-43dd-afec-c2d333b2aa14	A	f	2026-04-28 14:01:47.08748+00
f24bb437-41c2-4568-85c2-74cca3acd795	a3d35273-6851-4c00-96de-1bbf6dfc9257	4c87010d-60fd-4686-8d7a-0b11ad5aa2d8	A	t	2026-04-28 14:02:19.500038+00
3a2e8827-ec8e-4883-a67b-c14b53774571	2557bb3a-9869-422c-ac10-8000966fb728	b8015bab-db1a-45e5-9320-352d8d698989	D	f	2026-04-28 14:03:43.31168+00
37659367-8c4b-4a85-ba9e-b0637891f4b9	71805292-835e-4ff3-a365-f30fcfc06048	98043387-e7c4-4277-99f0-6815949e7288	D	t	2026-04-28 14:03:47.248677+00
8d380c1d-be4a-4ad6-86f9-48f04b626cef	71805292-835e-4ff3-a365-f30fcfc06048	057d9d16-3096-49a9-9332-91786e8f7fde	A	t	2026-04-28 14:04:14.852286+00
2ba2466f-6cb6-4b59-9338-a49ea0263c2d	a3d35273-6851-4c00-96de-1bbf6dfc9257	7e95694e-7ce3-4768-b194-baf73df330b4	C	t	2026-04-28 14:05:09.266621+00
6cbf06f7-8b69-4df0-8498-1e576fd760b7	a3d35273-6851-4c00-96de-1bbf6dfc9257	6f0a35c2-8908-4c2d-9620-26945cada15f	C	f	2026-04-28 14:06:04.336557+00
73111554-8191-4e76-bbcf-3f5739f82a53	71805292-835e-4ff3-a365-f30fcfc06048	5679a8f3-dad5-48c3-8057-6caa1fbd2683	C	t	2026-04-28 14:09:02.4346+00
c084c82d-8914-4d5c-bb84-91112b6fccab	a3d35273-6851-4c00-96de-1bbf6dfc9257	e7f5bd3b-c6c0-40f2-8303-1977170cdd93	A	f	2026-04-28 14:10:59.045223+00
ed14bdad-fdb7-4158-bd51-0701f304ebcd	a3d35273-6851-4c00-96de-1bbf6dfc9257	759721fb-6efd-4fa0-873f-994c91fafae6	C	f	2026-04-28 14:11:04.08901+00
8c47795a-a817-479e-ae6e-197c98928235	2557bb3a-9869-422c-ac10-8000966fb728	91b366bd-9fda-470d-99fa-9daae2309649	B	t	2026-04-28 14:11:33.329944+00
c218588d-b57b-419b-ae7f-7ab559b3f6b8	2557bb3a-9869-422c-ac10-8000966fb728	52357405-5abf-4f44-98ff-230d83a1da72	C	t	2026-04-28 14:12:27.339197+00
3ab62809-35d9-407f-8258-0c7d3258234e	a3d35273-6851-4c00-96de-1bbf6dfc9257	f6992e14-6260-4199-8666-6e9366738d82	C	f	2026-04-28 14:12:37.136834+00
45b227d9-24a9-4453-9cae-47b9fc40318f	2557bb3a-9869-422c-ac10-8000966fb728	617ff669-f28b-49d1-8d4e-1d03aac4f140	D	f	2026-04-28 14:15:37.346446+00
50ffce37-1bcf-40e5-b1dc-0bd0e4d33a17	71805292-835e-4ff3-a365-f30fcfc06048	a360f901-de88-4d26-8f31-c16713d3b6da	A	t	2026-04-28 14:17:37.378974+00
e1e783b0-b4a1-42f4-bf8b-4f5bf78d8fcb	a3d35273-6851-4c00-96de-1bbf6dfc9257	4290a514-cf7b-4347-b9af-e669fda9388f	B	t	2026-04-28 14:17:41.749267+00
76345521-3417-4f6b-a56a-f9be020d4ac7	2557bb3a-9869-422c-ac10-8000966fb728	a776c176-a748-4ce2-81b0-d2817998a72c	B	t	2026-04-28 14:05:35.133427+00
6c6b9b4c-d542-4078-b673-312ed0698079	2557bb3a-9869-422c-ac10-8000966fb728	ed6ec807-2624-4a5a-9f90-6aea86d4fa8b	D	t	2026-04-28 14:09:58.329079+00
1f3be4af-49f1-4373-a60e-a939dfeafbad	71805292-835e-4ff3-a365-f30fcfc06048	ecfc3df5-ed6a-44f4-9485-2c29f731aa0b	D	t	2026-04-28 14:11:17.718299+00
6f1eb31c-c91c-4f5a-b87c-bfb13d7ddc0b	a3d35273-6851-4c00-96de-1bbf6dfc9257	cf3b2c91-ad6f-4dd1-8e75-00f30732f932	C	t	2026-04-28 14:11:39.476261+00
a2615807-51ab-46a5-82c7-fbadf42b75ff	2557bb3a-9869-422c-ac10-8000966fb728	d8273d47-fb02-4186-aac8-9ca5e5541f2e	C	f	2026-04-28 14:11:52.412507+00
b85be4a8-245a-4e1f-a29f-7129da248d2a	71805292-835e-4ff3-a365-f30fcfc06048	fb75ef93-d920-4f94-81ea-1d9ff5b08784	B	f	2026-04-28 14:15:25.689612+00
13560e05-9cff-4257-99e2-4c787a419166	71805292-835e-4ff3-a365-f30fcfc06048	568b2bc9-9a19-44c0-8b8b-8d0045475282	D	t	2026-04-28 14:16:49.094256+00
2d962543-a63e-4346-bbf1-6acb9608e6de	71805292-835e-4ff3-a365-f30fcfc06048	f1859d7a-e0a7-4fd0-b9c8-a04f01ee9d2a	A	t	2026-04-28 14:19:06.400572+00
821a5fa4-23dd-4756-a744-940225752c1f	71805292-835e-4ff3-a365-f30fcfc06048	61ea3a53-6193-49d9-a68a-80213ce57a55	A	t	2026-04-28 14:05:52.039689+00
d6b5107f-93a1-4634-b60b-5310186fcff1	a3d35273-6851-4c00-96de-1bbf6dfc9257	1b7caef1-59fd-4b4a-aa70-42c2f635fe44	D	t	2026-04-28 14:14:16.069219+00
399fab88-51e4-467a-814e-e1f2989b918f	a3d35273-6851-4c00-96de-1bbf6dfc9257	18cb2450-e0d6-41d9-87b7-d55e28876177	A	t	2026-04-28 14:16:06.986557+00
8ef5e27a-f1ee-4d75-b060-f00d287e8034	71805292-835e-4ff3-a365-f30fcfc06048	2e1e2c65-8558-43dd-afec-c2d333b2aa14	C	t	2026-04-28 14:19:36.200674+00
c95b4435-bbd8-44ae-b78d-1a4d29315a4b	a3d35273-6851-4c00-96de-1bbf6dfc9257	6dff14d7-14d7-4232-9a97-e4b24b18a43c	C	t	2026-04-28 14:10:01.089163+00
fefd2ccf-cb5b-4986-a87a-b5691bee4272	a3d35273-6851-4c00-96de-1bbf6dfc9257	ae44507d-e359-4e47-b783-a5b9ca68f0eb	C	t	2026-04-28 14:13:44.904013+00
e6e71bbc-63da-4486-b7d3-8ed992720648	2557bb3a-9869-422c-ac10-8000966fb728	1f2aa538-6e73-48e9-92b0-91ab71dd76aa	B	f	2026-04-28 14:15:49.276801+00
3e614802-ef6b-401f-9d95-d289de6db53f	71805292-835e-4ff3-a365-f30fcfc06048	bd780c4e-1e12-4891-a7a0-e6a61eed1456	B	t	2026-04-28 14:18:19.954731+00
f6ce3b58-be36-4d6f-8c6d-3cdd4392a31a	2557bb3a-9869-422c-ac10-8000966fb728	346f920b-88ea-4002-9f8c-54db78719db2	D	t	2026-04-28 14:19:24.484101+00
18c35e43-d190-45c7-ac5a-f4b7a2a25987	71805292-835e-4ff3-a365-f30fcfc06048	ac6f50f6-6eab-41d1-833d-6740b87c9175	D	t	2026-04-28 14:20:27.969104+00
d7f6d30c-c59d-4877-b4ee-ce4ffa1f32ab	71805292-835e-4ff3-a365-f30fcfc06048	b8015bab-db1a-45e5-9320-352d8d698989	D	f	2026-04-28 14:21:27.748698+00
fe290cfc-c7ec-44e8-9fd7-f509a8020083	2557bb3a-9869-422c-ac10-8000966fb728	901eaa80-8900-46c4-820f-6f002be4a75d	D	f	2026-04-28 14:21:29.289075+00
21b3ec3e-76f6-4901-9a03-9ea5555145fd	2557bb3a-9869-422c-ac10-8000966fb728	44dabe5a-baf4-4f09-abf0-5fdc2d32a0e2	C	t	2026-04-28 14:21:44.304059+00
b98ece1b-e26d-4dbb-bd87-3e13573659a2	71805292-835e-4ff3-a365-f30fcfc06048	9eb2d84f-c683-46fd-b93a-def8d294ca2b	C	t	2026-04-28 14:22:00.175374+00
b25ce394-6f60-4e64-a2ca-24d49eeb9e5c	2557bb3a-9869-422c-ac10-8000966fb728	0b5f0817-9307-4039-a24b-2cad9cc12a35	C	f	2026-04-28 14:22:06.628028+00
596e8951-4e75-4c08-9b86-f707dd551d92	2557bb3a-9869-422c-ac10-8000966fb728	39913432-08d3-4da1-8101-76555b68789f	D	f	2026-04-28 14:22:19.708059+00
7ce71934-7b24-4bf6-9704-3fdc106a6e1a	2557bb3a-9869-422c-ac10-8000966fb728	cbc7a85d-71ac-44c7-baa8-1aa8f8287b9a	C	t	2026-04-28 14:22:52.580254+00
3a1e4b71-100a-43be-a84e-80d4f896afa4	a3d35273-6851-4c00-96de-1bbf6dfc9257	224cfaf5-cd27-416f-a643-c1e7c7aa4d36	A	t	2026-04-28 14:22:59.414927+00
bdf04228-8392-47b7-bb8c-3c3d89fef32d	71805292-835e-4ff3-a365-f30fcfc06048	a776c176-a748-4ce2-81b0-d2817998a72c	B	t	2026-04-28 14:23:18.225994+00
55cd71c0-0722-4249-a92a-13e6e7f84137	2557bb3a-9869-422c-ac10-8000966fb728	4ce9e2ef-41c9-44d4-9476-d83c495c093d	D	t	2026-04-28 14:23:48.150296+00
20536117-5f27-4c2a-ab29-99a80658ed1e	71805292-835e-4ff3-a365-f30fcfc06048	91b366bd-9fda-470d-99fa-9daae2309649	B	t	2026-04-28 14:24:50.121803+00
c95459dc-21af-4cb9-af4d-4c58849a5fc2	71805292-835e-4ff3-a365-f30fcfc06048	d8273d47-fb02-4186-aac8-9ca5e5541f2e	A	f	2026-04-28 14:25:08.280899+00
14de0557-b951-4581-a01b-43cfa6214346	2557bb3a-9869-422c-ac10-8000966fb728	134c31cf-066e-4317-af88-173a7711068d	C	t	2026-04-28 14:25:13.368342+00
d0629598-0bf4-4890-b23a-5f78b8c165b8	71805292-835e-4ff3-a365-f30fcfc06048	52357405-5abf-4f44-98ff-230d83a1da72	C	t	2026-04-28 14:25:15.508084+00
45c78103-fcf1-4c51-81ba-1c62febbcae0	2557bb3a-9869-422c-ac10-8000966fb728	52130c99-6ddd-4199-99fc-1a9ced88011c	B	f	2026-04-28 14:25:32.611263+00
dc9e17b5-1b0a-46ed-9c21-070bee1f2a4f	a3d35273-6851-4c00-96de-1bbf6dfc9257	25ec7bf5-1589-4329-b1f7-516f0f8d37a0	A	t	2026-04-28 14:25:40.799049+00
a0f6c2fe-be00-4554-bb6e-59a0edadecce	a3d35273-6851-4c00-96de-1bbf6dfc9257	19ccfdd4-936b-41cd-b943-379ebb3eb295	B	t	2026-04-28 14:26:48.784931+00
fd9346c5-37ee-4374-949f-d9c12c221d41	2557bb3a-9869-422c-ac10-8000966fb728	3e4ea525-2149-4cf7-ac09-9c3085be3a07	C	f	2026-04-28 14:26:52.519635+00
6f9ccced-2c56-4483-bdbf-8e42b1e2fd21	71805292-835e-4ff3-a365-f30fcfc06048	617ff669-f28b-49d1-8d4e-1d03aac4f140	D	f	2026-04-28 14:26:57.116377+00
64b57c22-885e-4066-83f0-cc81545b0914	2557bb3a-9869-422c-ac10-8000966fb728	631925ee-0015-485f-b444-04e213626498	A	t	2026-04-28 14:27:30.466595+00
964412e0-5abb-44c5-9106-f5003149d869	2557bb3a-9869-422c-ac10-8000966fb728	860c1fc9-5098-4d31-856f-94e217189509	A	f	2026-04-28 14:27:42.875838+00
82be4d3b-483b-4c5b-86b0-a3421c5dab29	71805292-835e-4ff3-a365-f30fcfc06048	1f2aa538-6e73-48e9-92b0-91ab71dd76aa	D	f	2026-04-28 14:27:58.736724+00
5df84609-2ae1-4966-823d-b1f43760fd28	71805292-835e-4ff3-a365-f30fcfc06048	631925ee-0015-485f-b444-04e213626498	A	t	2026-04-28 14:28:14.631746+00
0a1dabea-6350-4edf-bc1f-a89e17aab98a	71805292-835e-4ff3-a365-f30fcfc06048	346f920b-88ea-4002-9f8c-54db78719db2	D	t	2026-04-28 14:28:26.407604+00
e7d6def5-2eb8-47fa-98ed-4495bcfc5ee5	2557bb3a-9869-422c-ac10-8000966fb728	603aab63-8553-47a4-a088-d2d1ce0ccd17	A	f	2026-04-28 14:28:54.283579+00
7304d578-6040-4e8b-b474-2926423ab6cd	a3d35273-6851-4c00-96de-1bbf6dfc9257	982593d5-f7ce-4d9e-813b-41e6df2b0bef	D	t	2026-04-28 14:29:39.118507+00
114fcec6-2ad3-4ecd-8e2b-29e8726170e2	71805292-835e-4ff3-a365-f30fcfc06048	39913432-08d3-4da1-8101-76555b68789f	C	f	2026-04-28 14:29:46.815846+00
df70e082-44b6-48b6-8673-6be1c625f01c	a3d35273-6851-4c00-96de-1bbf6dfc9257	9f75d35f-1455-4153-8056-423445f16fce	C	t	2026-04-28 14:30:17.580294+00
6df065df-22e8-40c4-b139-10cee6f67496	2557bb3a-9869-422c-ac10-8000966fb728	b1948a83-dec1-4d5c-92ca-3909de974a5e	A	t	2026-04-28 14:30:41.348834+00
39c289b4-b772-460f-957f-d68d9069de2e	2557bb3a-9869-422c-ac10-8000966fb728	8dc11970-9511-4442-a739-3d999548678b	A	f	2026-04-28 14:31:49.687412+00
d1a16ea5-ceb2-4807-8e8c-815d1d908baa	71805292-835e-4ff3-a365-f30fcfc06048	901eaa80-8900-46c4-820f-6f002be4a75d	A	t	2026-04-28 14:32:04.838074+00
f5487ff3-781c-4270-9eaa-9313b2499e36	2557bb3a-9869-422c-ac10-8000966fb728	79fac420-1fdd-40d0-b324-11d7fdf6767b	D	t	2026-04-28 14:32:16.913649+00
5a1f66f0-fd4c-4263-8be2-7f09cd3cb7d5	a3d35273-6851-4c00-96de-1bbf6dfc9257	6b7a2340-d204-4c9a-a820-90576cb4732e	A	t	2026-04-28 14:32:44.313749+00
89fd4caf-d784-490e-ab28-b9eae8525409	71805292-835e-4ff3-a365-f30fcfc06048	44dabe5a-baf4-4f09-abf0-5fdc2d32a0e2	A	f	2026-04-28 14:32:54.474573+00
6e204cc3-2b47-4a9a-a35a-5e6ac80dfff2	2557bb3a-9869-422c-ac10-8000966fb728	b5a6e81f-c016-4964-8cc9-cd77e4ec8fa3	D	t	2026-04-28 14:33:17.594867+00
82adfc5f-5825-48ad-bcd5-1a8f537184e8	71805292-835e-4ff3-a365-f30fcfc06048	0b5f0817-9307-4039-a24b-2cad9cc12a35	A	f	2026-04-28 14:33:31.059588+00
f2dce45b-cd3e-4965-8893-15b704761624	2557bb3a-9869-422c-ac10-8000966fb728	d00bf7f0-ff55-42bd-8b08-def20bb03915	A	t	2026-04-28 14:33:38.76235+00
99878328-6321-48cb-820b-97aaf5ab2106	a3d35273-6851-4c00-96de-1bbf6dfc9257	e568c7fc-715f-404d-b3ed-70048053b374	D	f	2026-04-28 14:33:57.903718+00
60f0dfa4-54c1-487e-9a1b-7c5e8c493417	a3d35273-6851-4c00-96de-1bbf6dfc9257	dfa449d1-1841-483a-9d3c-fae10a197a8e	C	t	2026-04-28 14:34:09.378185+00
96368b00-747d-459f-b426-e5b4082f5d79	a3d35273-6851-4c00-96de-1bbf6dfc9257	ab80055d-216e-4731-926d-e2edebe712a0	D	t	2026-04-28 14:34:53.9161+00
c9dd9f59-a67f-4bc2-9b75-6057b7646b21	71805292-835e-4ff3-a365-f30fcfc06048	3e4ea525-2149-4cf7-ac09-9c3085be3a07	D	t	2026-04-28 14:35:07.950147+00
12e9ed64-b409-4ba6-9694-9cbc824213eb	a3d35273-6851-4c00-96de-1bbf6dfc9257	1f71e2ec-348b-4269-9503-e39e1cc6db2c	B	t	2026-04-28 14:35:56.083898+00
510dce70-4c8b-4d2c-ab07-45af3497750e	2557bb3a-9869-422c-ac10-8000966fb728	c44fab2b-eb92-4719-9d96-23dfbfe38b22	B	t	2026-04-28 14:36:40.471753+00
d5fe70de-08f2-412d-a20d-7bd352c0845a	2557bb3a-9869-422c-ac10-8000966fb728	41a0acaa-dbdc-4719-9b7f-f796e1a8db5f	C	t	2026-04-28 14:37:04.070631+00
125b3826-c71e-48fb-9503-91ae1b6ff3d9	71805292-835e-4ff3-a365-f30fcfc06048	907c9c8d-a368-4884-bbbd-04bfd8d150b8	C	f	2026-04-28 14:37:08.169744+00
4f51c123-be37-4c99-8f7a-fdc91017b71e	2557bb3a-9869-422c-ac10-8000966fb728	4706a514-8c18-4c10-911a-ca041142edc2	C	t	2026-04-28 14:37:09.12377+00
eb0cee9a-a402-42be-8bd4-454fceb1d455	a3d35273-6851-4c00-96de-1bbf6dfc9257	f4dded80-a2f9-4297-8907-775b0136b46a	D	f	2026-04-28 14:37:13.391733+00
9d576d17-bcbe-45fb-9db1-f15a86920379	71805292-835e-4ff3-a365-f30fcfc06048	cbc7a85d-71ac-44c7-baa8-1aa8f8287b9a	A	f	2026-04-28 14:37:28.977373+00
8db55546-a0da-44f0-adfa-9ce67ff0414e	2557bb3a-9869-422c-ac10-8000966fb728	3f5b9d22-6edf-4b2b-a7e7-2b634e259061	B	t	2026-04-28 14:39:10.7819+00
6aab04d8-3088-46e2-83fa-387c3ddf7523	71805292-835e-4ff3-a365-f30fcfc06048	134c31cf-066e-4317-af88-173a7711068d	A	f	2026-04-28 14:39:52.003984+00
12cc6bc2-5657-47ef-bf4b-26d6da4db2e6	a3d35273-6851-4c00-96de-1bbf6dfc9257	cc8ba2b6-5eb6-4c30-a00d-d2a89b0ce831	B	t	2026-04-28 14:41:31.975771+00
10b71005-885c-446a-9bb4-f1d14fe47c41	71805292-835e-4ff3-a365-f30fcfc06048	52130c99-6ddd-4199-99fc-1a9ced88011c	C	f	2026-04-28 14:41:58.061397+00
8075e8bb-a797-4e3b-94bd-4ad390e2c550	2557bb3a-9869-422c-ac10-8000966fb728	234ce33d-2f3e-44da-bb27-cb3c7539c50f	C	f	2026-04-28 14:41:59.716326+00
f4f749c4-4e1f-46dc-8d30-527f696040e8	a3d35273-6851-4c00-96de-1bbf6dfc9257	fad720c6-cf79-47e3-a7dc-997ce0a4ca1c	B	t	2026-04-28 14:42:12.322725+00
64e5d454-723e-424e-95f2-7efffc440085	71805292-835e-4ff3-a365-f30fcfc06048	860c1fc9-5098-4d31-856f-94e217189509	B	t	2026-04-28 14:42:13.229082+00
0790b340-0cc8-4088-899f-e1f8736a372f	2557bb3a-9869-422c-ac10-8000966fb728	236c5edc-9fb2-4134-b848-7df9910ee107	A	f	2026-04-28 14:42:29.887089+00
ea4d840b-032a-4fb0-8858-90c88af5970e	a3d35273-6851-4c00-96de-1bbf6dfc9257	c740ba7e-7386-4f2f-a462-c1d4778554e9	B	t	2026-04-28 14:42:33.675729+00
6afa78bf-915a-40e8-9ee3-00aa94fe7be2	a3d35273-6851-4c00-96de-1bbf6dfc9257	3bba5900-28d6-4761-ad6f-cfa430e73ebe	A	t	2026-04-28 14:42:53.968331+00
9e17dc37-2abc-4a12-ad23-6f91628f8893	71805292-835e-4ff3-a365-f30fcfc06048	225e280b-313c-45c5-ac01-002865223dfe	B	f	2026-04-28 14:43:37.023875+00
53094365-22b2-4272-91db-5a7d86ab8802	2557bb3a-9869-422c-ac10-8000966fb728	19e6c77e-9cfc-4eec-99c4-afdb0ba05ca5	B	f	2026-04-28 14:43:54.108582+00
161cb270-d0ff-4183-ab38-856901e271c7	a3d35273-6851-4c00-96de-1bbf6dfc9257	b51e5ec8-ad46-46b5-b689-d5e8a977463e	C	t	2026-04-28 14:44:02.295041+00
0a75f63a-12cf-4a52-b206-f3dea1b0e00c	a3d35273-6851-4c00-96de-1bbf6dfc9257	0ecbb69a-5327-4480-ab5b-8a34b5179a3a	B	t	2026-04-28 14:44:36.263633+00
23ef3bac-da11-4006-acce-ab5b226acc05	2557bb3a-9869-422c-ac10-8000966fb728	f43d91bf-4188-4d97-8011-e759b608a2e2	C	t	2026-04-28 14:44:53.096807+00
261e6b80-30f2-471f-80c6-6a3d66c5c19f	a3d35273-6851-4c00-96de-1bbf6dfc9257	d3b41295-7f1b-48e9-a96a-52043440d70b	C	t	2026-04-28 14:44:56.2902+00
09592e72-c702-4414-a566-d49f637b7a6f	71805292-835e-4ff3-a365-f30fcfc06048	448025f6-abe6-42fa-8866-014b842f7785	B	t	2026-04-28 14:44:57.120649+00
f829a3d3-ca7e-48b7-80a4-d808971fff64	a3d35273-6851-4c00-96de-1bbf6dfc9257	338d8dcd-bd80-427d-8c4b-7cefaa73721f	C	t	2026-04-28 14:45:14.334724+00
e2e165f4-43cc-4c2f-b581-744de2cd21c8	2557bb3a-9869-422c-ac10-8000966fb728	f606aac2-ea93-4afb-894f-6c4fa67e6b05	B	f	2026-04-28 14:45:25.070956+00
bc5ea4aa-ddfd-48fc-b009-4b9508eaa03f	a3d35273-6851-4c00-96de-1bbf6dfc9257	8867a36b-758a-4c7e-ab60-1596edc4c28e	D	t	2026-04-28 14:45:33.02136+00
bab8bf5e-f42c-4e31-8c06-cffd17af6450	2557bb3a-9869-422c-ac10-8000966fb728	0bd7afbd-dcc0-410b-bde1-5355b8cb277f	C	t	2026-04-28 14:45:53.108592+00
829600ee-da98-4060-ba56-164fb272bb4c	a3d35273-6851-4c00-96de-1bbf6dfc9257	80d9a4aa-49ca-4e56-9af1-fa6d6157e28f	C	t	2026-04-28 14:45:54.763431+00
733740e0-1caf-4393-8101-dda7fabed690	71805292-835e-4ff3-a365-f30fcfc06048	603aab63-8553-47a4-a088-d2d1ce0ccd17	A	f	2026-04-28 14:45:56.309265+00
ebf119ad-46ab-4f6c-a327-0c4da66d4481	2557bb3a-9869-422c-ac10-8000966fb728	24c0e56f-d2c6-4418-ae77-a82a0b94ee74	B	t	2026-04-28 14:46:21.137119+00
4117fd18-c2cb-419b-923d-5cb167ab3781	71805292-835e-4ff3-a365-f30fcfc06048	b1f34359-813c-454a-87d2-8be081eec7d0	B	t	2026-04-28 14:46:51.136156+00
d4098ecd-4ffe-4573-ac9d-2bb76d788646	71805292-835e-4ff3-a365-f30fcfc06048	e1d1e7b0-bd77-4a21-95bc-ed3972271996	A	f	2026-04-28 14:48:12.510617+00
3f99da3b-67f7-4f90-8911-7b71a880c652	a3d35273-6851-4c00-96de-1bbf6dfc9257	fa60a6d0-fec7-41af-b837-dc417b5e36a9	D	t	2026-04-28 14:48:20.70256+00
b1b5e17c-33f7-4293-9ab2-89b521081268	a3d35273-6851-4c00-96de-1bbf6dfc9257	bd780c4e-1e12-4891-a7a0-e6a61eed1456	B	t	2026-04-28 14:50:03.032642+00
24aa61b9-6be3-48ba-a541-90b8776cdac8	2557bb3a-9869-422c-ac10-8000966fb728	7e95694e-7ce3-4768-b194-baf73df330b4	C	t	2026-04-28 14:50:30.565917+00
c560874c-9b9b-4728-83fd-8deca5cef751	71805292-835e-4ff3-a365-f30fcfc06048	c20cf417-98d4-41eb-8914-7e4e3f45fa83	B	t	2026-04-28 14:50:40.543508+00
ef44262f-0a8b-492f-91fc-218dc2e800d6	a3d35273-6851-4c00-96de-1bbf6dfc9257	568b2bc9-9a19-44c0-8b8b-8d0045475282	D	t	2026-04-28 14:50:51.81383+00
9753f752-0613-4246-ba51-a3bf97712139	a3d35273-6851-4c00-96de-1bbf6dfc9257	a360f901-de88-4d26-8f31-c16713d3b6da	A	t	2026-04-28 14:50:59.912776+00
06be5e56-7783-4f60-bfc7-3087b74a1a39	a3d35273-6851-4c00-96de-1bbf6dfc9257	f1859d7a-e0a7-4fd0-b9c8-a04f01ee9d2a	A	t	2026-04-28 14:51:19.366628+00
a3030f04-6db0-466f-b444-6f9135a0b092	71805292-835e-4ff3-a365-f30fcfc06048	b1948a83-dec1-4d5c-92ca-3909de974a5e	A	t	2026-04-28 14:51:24.788059+00
3b2876df-2264-4869-83ef-6f7f4cdcc66e	a3d35273-6851-4c00-96de-1bbf6dfc9257	b8015bab-db1a-45e5-9320-352d8d698989	C	t	2026-04-28 14:54:51.296194+00
6683bbfc-eabe-4837-92a2-dc3b59690157	71805292-835e-4ff3-a365-f30fcfc06048	79fac420-1fdd-40d0-b324-11d7fdf6767b	D	t	2026-04-28 15:09:17.607738+00
6bd7c65d-7190-426f-a392-c72038bbded9	2557bb3a-9869-422c-ac10-8000966fb728	6dff14d7-14d7-4232-9a97-e4b24b18a43c	C	t	2026-04-28 15:10:25.430862+00
3314051b-0f8f-4fb7-8d14-8c5eb41a9688	71805292-835e-4ff3-a365-f30fcfc06048	d00bf7f0-ff55-42bd-8b08-def20bb03915	A	t	2026-04-28 15:13:04.27533+00
99b9e5e8-df06-40ec-83d3-bf3ed4e6b6f3	a3d35273-6851-4c00-96de-1bbf6dfc9257	4ce9e2ef-41c9-44d4-9476-d83c495c093d	C	f	2026-04-28 15:14:45.987082+00
8763fde0-bfdf-44e3-85a8-560b783a6d9d	71805292-835e-4ff3-a365-f30fcfc06048	2b101e61-141d-4d7f-b4c2-196138cf5fb2	C	f	2026-04-28 15:18:42.153414+00
6d07b815-3f71-4b14-be4d-67cebfadb2c5	71805292-835e-4ff3-a365-f30fcfc06048	3f5b9d22-6edf-4b2b-a7e7-2b634e259061	B	t	2026-04-28 15:19:01.045631+00
104abe55-7a3b-4d5a-8209-5564e590211a	71805292-835e-4ff3-a365-f30fcfc06048	234ce33d-2f3e-44da-bb27-cb3c7539c50f	A	t	2026-04-28 15:19:44.30027+00
90ea2fea-7950-4de0-a06b-da42b2fe3453	a3d35273-6851-4c00-96de-1bbf6dfc9257	603aab63-8553-47a4-a088-d2d1ce0ccd17	D	t	2026-04-28 15:20:28.407902+00
cdf02047-a8c2-4e2c-978d-ed40626728ad	a3d35273-6851-4c00-96de-1bbf6dfc9257	b1f34359-813c-454a-87d2-8be081eec7d0	B	t	2026-04-28 15:21:24.910171+00
aadb98f6-cd75-480f-9f7f-350759334ff3	71805292-835e-4ff3-a365-f30fcfc06048	0bd7afbd-dcc0-410b-bde1-5355b8cb277f	C	t	2026-04-28 15:22:15.757559+00
77133c19-42df-4736-a101-983a0f191ad9	71805292-835e-4ff3-a365-f30fcfc06048	f606aac2-ea93-4afb-894f-6c4fa67e6b05	B	f	2026-04-28 15:25:59.030773+00
ce7031e6-9535-4f16-9b30-6ae134efee40	a3d35273-6851-4c00-96de-1bbf6dfc9257	79fac420-1fdd-40d0-b324-11d7fdf6767b	D	t	2026-04-28 15:27:23.802662+00
968d83be-246c-4501-9ad3-472ff6f99517	2557bb3a-9869-422c-ac10-8000966fb728	49ac5214-08aa-4093-9790-8e3402278800	A	f	2026-04-28 14:51:37.58782+00
3f0c1317-690c-403b-bb39-f6a4942e15b7	a3d35273-6851-4c00-96de-1bbf6dfc9257	631925ee-0015-485f-b444-04e213626498	A	t	2026-04-28 15:09:25.253763+00
c2453cbb-14bc-4d3b-8788-89d4ea44ef68	71805292-835e-4ff3-a365-f30fcfc06048	eab51de4-7348-4b0e-9609-064e88015dea	A	f	2026-04-28 15:11:01.52781+00
5524e4a1-be3e-4a5e-a157-4427474098e5	a3d35273-6851-4c00-96de-1bbf6dfc9257	44dabe5a-baf4-4f09-abf0-5fdc2d32a0e2	C	t	2026-04-28 15:12:19.34808+00
1b2eeb5e-8d31-43c9-bf20-bfb7d003b1c5	2557bb3a-9869-422c-ac10-8000966fb728	cf3b2c91-ad6f-4dd1-8e75-00f30732f932	C	t	2026-04-28 15:13:32.208705+00
614d5dc8-0a01-402d-9311-f22bff4cbf53	a3d35273-6851-4c00-96de-1bbf6dfc9257	52130c99-6ddd-4199-99fc-1a9ced88011c	A	t	2026-04-28 15:16:43.798243+00
1530f52a-92cd-4935-86ef-2ecc87e1a00d	a3d35273-6851-4c00-96de-1bbf6dfc9257	448025f6-abe6-42fa-8866-014b842f7785	B	t	2026-04-28 15:19:49.175391+00
a06c241d-2cb7-4081-843d-332e319a3ed6	71805292-835e-4ff3-a365-f30fcfc06048	4b3fd082-8394-4ecc-afda-a36b07d05658	B	t	2026-04-28 15:21:25.128309+00
c11bd7f5-feee-43e1-9cc5-1e554de6c200	a3d35273-6851-4c00-96de-1bbf6dfc9257	e1d1e7b0-bd77-4a21-95bc-ed3972271996	A	f	2026-04-28 15:22:29.467824+00
346e5f01-8f75-4bcf-a306-3034ae7fea25	a3d35273-6851-4c00-96de-1bbf6dfc9257	b1948a83-dec1-4d5c-92ca-3909de974a5e	C	f	2026-04-28 15:24:17.538419+00
2cc14630-134f-4b22-824b-80f0f0e362cb	2557bb3a-9869-422c-ac10-8000966fb728	dfa449d1-1841-483a-9d3c-fae10a197a8e	C	t	2026-04-28 15:25:53.98621+00
5c3937e4-8468-4fb5-b292-6966911ad915	2557bb3a-9869-422c-ac10-8000966fb728	6d111269-ad5b-401e-a1b2-4819ba463ee6	D	f	2026-04-28 14:51:41.48853+00
d7b3117b-0a69-4ca0-88be-2ab8dd4946e5	71805292-835e-4ff3-a365-f30fcfc06048	b5a6e81f-c016-4964-8cc9-cd77e4ec8fa3	D	t	2026-04-28 15:11:50.950505+00
eaf01fd6-3270-4f70-b3ff-c3c337e45c84	a3d35273-6851-4c00-96de-1bbf6dfc9257	39913432-08d3-4da1-8101-76555b68789f	A	t	2026-04-28 15:11:52.535001+00
ee7384bb-fdfc-4337-b877-d69d45431e30	71805292-835e-4ff3-a365-f30fcfc06048	e8c100e6-f5c4-4839-97d9-0e7d7089985b	B	f	2026-04-28 15:12:53.792654+00
bca19e74-fbc4-4854-93ef-fc9a5da270bb	a3d35273-6851-4c00-96de-1bbf6dfc9257	134c31cf-066e-4317-af88-173a7711068d	C	t	2026-04-28 15:15:58.590538+00
09a19bcf-d351-4868-a010-3a07505e664a	2557bb3a-9869-422c-ac10-8000966fb728	b6da5681-215c-4b93-b5f0-6e8f785b731b	B	f	2026-04-28 15:19:49.203575+00
aede9037-7a13-41ff-b8b3-fa441a9a5ff2	71805292-835e-4ff3-a365-f30fcfc06048	236c5edc-9fb2-4134-b848-7df9910ee107	B	t	2026-04-28 15:20:37.31912+00
ee66545a-bcbb-4b19-bd41-316811b3c51e	2557bb3a-9869-422c-ac10-8000966fb728	6b7a2340-d204-4c9a-a820-90576cb4732e	B	f	2026-04-28 15:23:08.115831+00
a157f720-531f-43d5-bca4-fe97e81881a9	71805292-835e-4ff3-a365-f30fcfc06048	f43d91bf-4188-4d97-8011-e759b608a2e2	C	t	2026-04-28 15:25:14.511278+00
ad61b5f5-21c5-4152-b888-b051bcebe61d	2557bb3a-9869-422c-ac10-8000966fb728	ab80055d-216e-4731-926d-e2edebe712a0	D	t	2026-04-28 15:26:40.728941+00
7e1ca838-38cb-445a-9af2-006ce94eaa1d	a3d35273-6851-4c00-96de-1bbf6dfc9257	2e1e2c65-8558-43dd-afec-c2d333b2aa14	C	t	2026-04-28 14:51:49.847636+00
b189091c-012d-4cc6-b6c2-3cf059c24314	a3d35273-6851-4c00-96de-1bbf6dfc9257	346f920b-88ea-4002-9f8c-54db78719db2	B	f	2026-04-28 15:10:00.389998+00
644d6bc8-2c3a-48ff-9a70-398503727b4f	a3d35273-6851-4c00-96de-1bbf6dfc9257	0b5f0817-9307-4039-a24b-2cad9cc12a35	D	t	2026-04-28 15:11:43.471258+00
78ad683d-089f-419c-9388-ff5e6d73f3b7	a3d35273-6851-4c00-96de-1bbf6dfc9257	3e4ea525-2149-4cf7-ac09-9c3085be3a07	D	t	2026-04-28 15:12:47.305838+00
8bcb6dc4-3d49-4dc7-92ea-5d4bd733d7d8	a3d35273-6851-4c00-96de-1bbf6dfc9257	cbc7a85d-71ac-44c7-baa8-1aa8f8287b9a	C	t	2026-04-28 15:14:05.773458+00
ab2b9a3a-8cdb-4a8a-84c4-15d95fec2cb9	71805292-835e-4ff3-a365-f30fcfc06048	c44fab2b-eb92-4719-9d96-23dfbfe38b22	B	t	2026-04-28 15:15:12.508376+00
0fa8d476-e101-40e6-acdd-2d798d1a3382	a3d35273-6851-4c00-96de-1bbf6dfc9257	860c1fc9-5098-4d31-856f-94e217189509	B	t	2026-04-28 15:17:08.575505+00
4f0b399e-d680-4c54-9f25-d602db2e72a0	71805292-835e-4ff3-a365-f30fcfc06048	19e6c77e-9cfc-4eec-99c4-afdb0ba05ca5	A	t	2026-04-28 15:22:07.152223+00
002373b6-975d-421a-88ed-ee30eb5a0044	71805292-835e-4ff3-a365-f30fcfc06048	8dc11970-9511-4442-a739-3d999548678b	D	f	2026-04-28 14:52:30.271118+00
b238e247-4dc6-47bd-aea6-c6a68d0c39f1	a3d35273-6851-4c00-96de-1bbf6dfc9257	ac6f50f6-6eab-41d1-833d-6740b87c9175	D	t	2026-04-28 14:54:08.021857+00
87c24052-bcdc-480d-9786-4c26d407610d	2557bb3a-9869-422c-ac10-8000966fb728	e1f38048-f857-424d-bbec-4cfa15494f9c	C	t	2026-04-28 15:09:39.59343+00
547e0e7a-fba4-49e1-8dc2-56c171dcbd97	2557bb3a-9869-422c-ac10-8000966fb728	e7f5bd3b-c6c0-40f2-8303-1977170cdd93	D	f	2026-04-28 15:11:13.730264+00
ca98456a-3b95-4504-a32c-b95d0a5256d0	71805292-835e-4ff3-a365-f30fcfc06048	41a0acaa-dbdc-4719-9b7f-f796e1a8db5f	C	t	2026-04-28 15:12:23.287277+00
8211bac3-72dd-4ba4-a38a-9f2c931bb54f	71805292-835e-4ff3-a365-f30fcfc06048	4706a514-8c18-4c10-911a-ca041142edc2	C	t	2026-04-28 15:13:59.11081+00
6825ee6c-a251-4052-a621-f2edb28db8c9	71805292-835e-4ff3-a365-f30fcfc06048	6b73768d-7203-43eb-a59f-6730654649cd	D	f	2026-04-28 15:17:18.940249+00
93398483-62a5-47b9-b8fa-1b36793d3e6b	2557bb3a-9869-422c-ac10-8000966fb728	1b7caef1-59fd-4b4a-aa70-42c2f635fe44	C	f	2026-04-28 15:17:42.270667+00
8f5de6bd-f2af-4813-ae9f-6bedddc9f6f4	a3d35273-6851-4c00-96de-1bbf6dfc9257	225e280b-313c-45c5-ac01-002865223dfe	D	t	2026-04-28 15:18:18.819154+00
d8cd86e2-46b3-4273-894e-240db79e5cab	a3d35273-6851-4c00-96de-1bbf6dfc9257	c20cf417-98d4-41eb-8914-7e4e3f45fa83	C	f	2026-04-28 15:23:36.806966+00
2073e3c1-2c69-42d8-8ee3-afae87da6fe7	2557bb3a-9869-422c-ac10-8000966fb728	e568c7fc-715f-404d-b3ed-70048053b374	D	f	2026-04-28 15:25:26.32739+00
3e11fe43-4f3d-49be-893b-f6cedf3403e8	71805292-835e-4ff3-a365-f30fcfc06048	24c0e56f-d2c6-4418-ae77-a82a0b94ee74	A	f	2026-04-28 15:27:08.2221+00
a932ea24-f2ed-4ef7-bf0e-11f2c2308541	a3d35273-6851-4c00-96de-1bbf6dfc9257	b5a6e81f-c016-4964-8cc9-cd77e4ec8fa3	D	t	2026-04-28 15:28:05.188019+00
a7e2b676-899b-4ed2-af4e-ad66dbe01c42	2557bb3a-9869-422c-ac10-8000966fb728	1f71e2ec-348b-4269-9503-e39e1cc6db2c	B	t	2026-04-28 15:28:18.277227+00
1d36f404-f2c2-4007-84d7-af705aaa12ca	a3d35273-6851-4c00-96de-1bbf6dfc9257	41a0acaa-dbdc-4719-9b7f-f796e1a8db5f	C	t	2026-04-28 15:28:29.411768+00
755c52ee-6f74-429e-b029-50add4230765	2557bb3a-9869-422c-ac10-8000966fb728	a75f1685-75c9-46d3-a53d-c51b3c16eaef	B	t	2026-04-28 15:28:34.849574+00
7755509d-18c7-4948-81c5-214b9f608578	2557bb3a-9869-422c-ac10-8000966fb728	f4dded80-a2f9-4297-8907-775b0136b46a	A	f	2026-04-28 15:29:15.838331+00
e80eaac4-559d-40a4-84be-555ea33f382e	2557bb3a-9869-422c-ac10-8000966fb728	cc8ba2b6-5eb6-4c30-a00d-d2a89b0ce831	C	f	2026-04-28 15:29:40.011369+00
0f1d470b-9133-4c54-a37a-a315879171d9	71805292-835e-4ff3-a365-f30fcfc06048	4c87010d-60fd-4686-8d7a-0b11ad5aa2d8	C	f	2026-04-28 15:29:51.205525+00
e1a00d2c-4a76-4460-87ab-fd6ce2008f04	2557bb3a-9869-422c-ac10-8000966fb728	fad720c6-cf79-47e3-a7dc-997ce0a4ca1c	B	t	2026-04-28 15:30:15.416329+00
5d5c25a9-8ce2-41b3-ad35-69b6bd4f8aae	2557bb3a-9869-422c-ac10-8000966fb728	c740ba7e-7386-4f2f-a462-c1d4778554e9	B	t	2026-04-28 15:31:44.394253+00
fe7c22f5-017c-4670-a8e1-f4ae49e8c9f6	2557bb3a-9869-422c-ac10-8000966fb728	3bba5900-28d6-4761-ad6f-cfa430e73ebe	A	t	2026-04-28 15:32:21.505955+00
93c056d9-e405-40c5-bdbe-1db5b9f4a5e9	71805292-835e-4ff3-a365-f30fcfc06048	6d111269-ad5b-401e-a1b2-4819ba463ee6	D	f	2026-04-28 15:32:24.275903+00
74c78c70-1ecb-4fd5-9716-09df2c681675	a3d35273-6851-4c00-96de-1bbf6dfc9257	d00bf7f0-ff55-42bd-8b08-def20bb03915	A	t	2026-04-28 15:32:52.497568+00
f8d334c0-411f-454f-bb2d-625142f613c2	71805292-835e-4ff3-a365-f30fcfc06048	49ac5214-08aa-4093-9790-8e3402278800	C	f	2026-04-28 15:33:02.226826+00
cbc78289-c44d-4f28-ab74-1117c655d5fd	a3d35273-6851-4c00-96de-1bbf6dfc9257	4706a514-8c18-4c10-911a-ca041142edc2	C	t	2026-04-28 15:33:33.220925+00
4ed4c44b-4eb4-4a9e-82cb-4c7bd8b8d085	71805292-835e-4ff3-a365-f30fcfc06048	7e95694e-7ce3-4768-b194-baf73df330b4	B	f	2026-04-28 15:33:53.797971+00
ef3f2966-7aab-4f92-b3c2-a65aed246683	2557bb3a-9869-422c-ac10-8000966fb728	b51e5ec8-ad46-46b5-b689-d5e8a977463e	C	t	2026-04-28 15:34:11.125999+00
f834f102-6982-471a-acc8-5463ef3e531b	a3d35273-6851-4c00-96de-1bbf6dfc9257	c44fab2b-eb92-4719-9d96-23dfbfe38b22	B	t	2026-04-28 15:34:18.157296+00
99142049-1542-487b-bebc-89352ee831db	71805292-835e-4ff3-a365-f30fcfc06048	6f0a35c2-8908-4c2d-9620-26945cada15f	A	t	2026-04-28 15:35:00.223261+00
bb794dd4-fbb0-4ab1-87a1-7ee58f1252bf	a3d35273-6851-4c00-96de-1bbf6dfc9257	6b73768d-7203-43eb-a59f-6730654649cd	B	t	2026-04-28 15:35:37.36122+00
ad1205d1-56d4-43cf-8ddd-a332259488bc	2557bb3a-9869-422c-ac10-8000966fb728	d3b41295-7f1b-48e9-a96a-52043440d70b	C	t	2026-04-28 15:36:08.882539+00
380a447a-f975-4015-8921-2a02d3dc1338	a3d35273-6851-4c00-96de-1bbf6dfc9257	2b101e61-141d-4d7f-b4c2-196138cf5fb2	B	f	2026-04-28 15:36:24.140627+00
e7a64d70-7f94-4680-9399-e4416c388cb7	71805292-835e-4ff3-a365-f30fcfc06048	e1f38048-f857-424d-bbec-4cfa15494f9c	B	f	2026-04-28 15:36:24.816526+00
7c588a20-4140-4134-8d60-d3952d550c3c	2557bb3a-9869-422c-ac10-8000966fb728	0ecbb69a-5327-4480-ab5b-8a34b5179a3a	D	f	2026-04-28 15:36:37.356817+00
f4d9296c-d520-4505-aa81-13d9ef63f5e6	2557bb3a-9869-422c-ac10-8000966fb728	338d8dcd-bd80-427d-8c4b-7cefaa73721f	C	t	2026-04-28 15:36:43.69555+00
877b21df-34e3-41ea-8ca1-b13d71f9ffbe	a3d35273-6851-4c00-96de-1bbf6dfc9257	3f5b9d22-6edf-4b2b-a7e7-2b634e259061	B	t	2026-04-28 15:36:50.190173+00
f471f2bc-8d95-47ad-a5d4-27b227740baa	2557bb3a-9869-422c-ac10-8000966fb728	8867a36b-758a-4c7e-ab60-1596edc4c28e	C	f	2026-04-28 15:36:59.057491+00
45c087de-ae5a-48d2-8bf7-5e741c149b81	71805292-835e-4ff3-a365-f30fcfc06048	6dff14d7-14d7-4232-9a97-e4b24b18a43c	C	t	2026-04-28 15:37:02.730296+00
5ad295ea-5114-4988-aa7f-c2929aa11149	2557bb3a-9869-422c-ac10-8000966fb728	80d9a4aa-49ca-4e56-9af1-fa6d6157e28f	C	t	2026-04-28 15:37:16.790494+00
c30a4d98-5706-42f6-8a18-4a192aba26b0	a3d35273-6851-4c00-96de-1bbf6dfc9257	234ce33d-2f3e-44da-bb27-cb3c7539c50f	A	t	2026-04-28 15:37:25.147078+00
e8129a7e-6365-4381-8393-d8f03a486b14	a3d35273-6851-4c00-96de-1bbf6dfc9257	236c5edc-9fb2-4134-b848-7df9910ee107	B	t	2026-04-28 15:38:01.879393+00
47e94fa6-0013-435a-8a72-7f39766220d2	2557bb3a-9869-422c-ac10-8000966fb728	a1ae8350-1cd7-42bd-8999-4a5c1a275990	A	f	2026-04-28 15:38:27.558067+00
115b7140-6233-4f91-b4cc-ef510e381572	71805292-835e-4ff3-a365-f30fcfc06048	e7f5bd3b-c6c0-40f2-8303-1977170cdd93	A	f	2026-04-28 15:38:42.074906+00
1ecb75be-61eb-4b03-a23a-5dc3f6601db8	71805292-835e-4ff3-a365-f30fcfc06048	759721fb-6efd-4fa0-873f-994c91fafae6	A	f	2026-04-28 15:38:57.038236+00
9010c1db-5436-4772-8975-7a1dbe8d0fb3	2557bb3a-9869-422c-ac10-8000966fb728	78416331-8465-4bc7-8067-af60abc59577	C	f	2026-04-28 15:39:12.535792+00
839c7341-b4f8-492c-8749-e48c8de765f6	2557bb3a-9869-422c-ac10-8000966fb728	816a0061-1e82-44b0-8914-79a1931908fd	C	t	2026-04-28 15:39:19.642271+00
6976dd38-f8b8-47f5-aa8b-9ccd7634a0da	2557bb3a-9869-422c-ac10-8000966fb728	3685e2c6-f04d-478e-87ed-12d8cc72939c	B	t	2026-04-28 15:40:26.488792+00
2f38fe39-68eb-42e7-9702-31c4f1f4d77e	a3d35273-6851-4c00-96de-1bbf6dfc9257	b7a602a2-e595-4a46-8aca-637cb75a3eee	C	t	2026-04-28 15:40:43.691391+00
00e2f0e2-c419-4ac7-ab64-272e190208ad	2557bb3a-9869-422c-ac10-8000966fb728	0e7b1d5f-a655-4b21-a3e9-37c113cfc52e	B	t	2026-04-28 15:42:10.718036+00
eecb6c93-20fc-454b-a384-f5e3aceff52e	71805292-835e-4ff3-a365-f30fcfc06048	1b7caef1-59fd-4b4a-aa70-42c2f635fe44	B	f	2026-04-28 15:42:29.54305+00
ff6f4dc8-19c0-4b75-8d0f-1feca4d8f6ca	a3d35273-6851-4c00-96de-1bbf6dfc9257	28c07dfe-cb42-44d4-9f2f-dda64ffb6882	C	t	2026-04-28 15:42:31.721165+00
f471f830-51b1-4e1a-b02b-f9ca72b3ebc7	2557bb3a-9869-422c-ac10-8000966fb728	bb8e0d8a-95dc-4430-a5de-bbedcd1d8fda	B	t	2026-04-28 15:44:05.468816+00
18464052-a721-491d-a580-5e3402b09780	2557bb3a-9869-422c-ac10-8000966fb728	993ab2ec-b5b1-45ce-8e69-172067cd19a5	C	f	2026-04-28 15:44:30.325111+00
b52456e2-5119-4a96-a259-622480c6490f	71805292-835e-4ff3-a365-f30fcfc06048	d465803b-1304-4d77-8002-5b7aedd3c83c	B	t	2026-04-28 15:44:40.681678+00
cb53e70c-21af-4682-a58e-0b7f28440187	2557bb3a-9869-422c-ac10-8000966fb728	6b90fb4c-402a-49a3-95a2-75d1eb435bea	C	f	2026-04-28 15:44:50.946125+00
381bb9f7-7a11-4a38-85ce-83c26a51c7b2	a3d35273-6851-4c00-96de-1bbf6dfc9257	70b8f220-c374-4587-bcb2-12f7e2fa0bf7	C	t	2026-04-28 15:45:21.103593+00
fefa77d4-d420-417a-b5f5-9b562e2d6892	71805292-835e-4ff3-a365-f30fcfc06048	18cb2450-e0d6-41d9-87b7-d55e28876177	A	t	2026-04-28 15:45:43.91491+00
c4f9ca34-1146-42ee-a618-f989456e8321	2557bb3a-9869-422c-ac10-8000966fb728	01cdbfcd-5a74-450f-b9fa-69200db938c3	C	t	2026-04-28 15:46:08.17421+00
a18458a1-1761-4324-a685-45e5a68f0511	71805292-835e-4ff3-a365-f30fcfc06048	4290a514-cf7b-4347-b9af-e669fda9388f	B	t	2026-04-28 15:46:11.620856+00
eba48239-d6a0-4268-a9f3-01a7cb381479	a3d35273-6851-4c00-96de-1bbf6dfc9257	011f55e3-6770-4d47-9e46-3b8cd0e83955	C	t	2026-04-28 15:46:21.436184+00
01287d0c-3383-404a-9e21-6b385e45bc4e	2557bb3a-9869-422c-ac10-8000966fb728	f29d26aa-a051-4d45-b580-7f49cc55ac8e	D	f	2026-04-28 15:46:55.868068+00
16d305ad-a142-4555-bd28-31f055f948dd	a3d35273-6851-4c00-96de-1bbf6dfc9257	a573f0bf-6d03-49fe-bb60-accbb25272cb	D	f	2026-04-28 15:47:26.453388+00
02789a4f-afba-41be-a8ef-b854a3c2839a	a3d35273-6851-4c00-96de-1bbf6dfc9257	1b88a88c-cb2d-4184-a5e0-de08129088a2	D	f	2026-04-28 15:47:33.785895+00
d37eb2f6-d719-470b-a69c-34fb7d108649	2557bb3a-9869-422c-ac10-8000966fb728	93402563-6af3-45ec-9de0-aede8c8fb6b0	D	t	2026-04-28 15:48:21.459113+00
3b782b9c-8bde-4eeb-8c74-fe90d7e35119	2557bb3a-9869-422c-ac10-8000966fb728	d16e6125-c814-44cb-86d7-0eaaa8baa883	C	t	2026-04-28 15:49:06.431431+00
c0b9ad7c-26fc-4bbe-ae56-079e2b3c905e	71805292-835e-4ff3-a365-f30fcfc06048	b6da5681-215c-4b93-b5f0-6e8f785b731b	A	t	2026-04-28 15:49:18.763693+00
181f1bee-88a5-47bd-aac4-a6eb3df637ef	71805292-835e-4ff3-a365-f30fcfc06048	25ec7bf5-1589-4329-b1f7-516f0f8d37a0	C	f	2026-04-28 15:50:39.261253+00
f9cc34e5-299a-4068-9d9d-2b1dd0e9e603	2557bb3a-9869-422c-ac10-8000966fb728	87e60be5-0a87-45da-ad2f-f8266e80c18c	B	t	2026-04-28 15:50:50.04436+00
a3b1efd0-8464-4abc-a830-cf218fc036a9	2557bb3a-9869-422c-ac10-8000966fb728	a01b5c95-1c9e-4319-b48f-90743f87f68c	C	t	2026-04-28 15:51:34.905599+00
84960019-14ee-424f-b6cf-01c5d3e2d303	71805292-835e-4ff3-a365-f30fcfc06048	9f75d35f-1455-4153-8056-423445f16fce	D	f	2026-04-28 15:51:36.835096+00
612db474-742d-4fa4-af1d-e2c5e2a8378d	a3d35273-6851-4c00-96de-1bbf6dfc9257	af038b7c-e600-4d33-8155-21719ce50014	A	t	2026-04-28 15:52:52.286693+00
55734bb2-4fc5-48fb-820c-31d9579736b0	2557bb3a-9869-422c-ac10-8000966fb728	838997fc-c95f-428f-8c5c-30357c80a62a	A	t	2026-04-28 15:53:01.404256+00
5b7ac8db-a8a1-470f-8445-e0147c6df159	2557bb3a-9869-422c-ac10-8000966fb728	7452052d-1c3d-4aa8-8fcd-e58556513248	A	t	2026-04-28 15:54:27.170496+00
da35183b-cc13-4904-93c9-f3578f8a38a1	2557bb3a-9869-422c-ac10-8000966fb728	6dc0f00b-5ebd-4b0e-b639-2168d0bea3ce	A	t	2026-04-28 15:54:48.869044+00
b6bd4e45-ef20-415d-b70a-2b5127bebc41	2557bb3a-9869-422c-ac10-8000966fb728	42ed3074-0269-4669-9f60-ed38853ba85a	A	t	2026-04-28 15:55:01.507611+00
04527487-41a7-4f59-a73d-bdfde4814f11	2557bb3a-9869-422c-ac10-8000966fb728	d465803b-1304-4d77-8002-5b7aedd3c83c	B	t	2026-04-28 15:55:56.315725+00
43bca979-b88b-40a1-9121-36e88ea0b8ca	2557bb3a-9869-422c-ac10-8000966fb728	18cb2450-e0d6-41d9-87b7-d55e28876177	A	t	2026-04-28 15:56:11.323566+00
2c45a5a2-f5ca-4e05-af30-b0ff7020cd03	2557bb3a-9869-422c-ac10-8000966fb728	4290a514-cf7b-4347-b9af-e669fda9388f	B	t	2026-04-28 15:56:12.402604+00
63fd3b73-59ed-4428-babb-5ebc645543a7	2557bb3a-9869-422c-ac10-8000966fb728	25ec7bf5-1589-4329-b1f7-516f0f8d37a0	C	f	2026-04-28 15:56:22.079525+00
9c354e90-c6e1-47ae-b7b8-5f94235139bc	a3d35273-6851-4c00-96de-1bbf6dfc9257	5679a8f3-dad5-48c3-8057-6caa1fbd2683	A	f	2026-04-28 15:56:22.901574+00
752c54a1-cc72-4eb3-97b9-08acf1d5f170	2557bb3a-9869-422c-ac10-8000966fb728	9f75d35f-1455-4153-8056-423445f16fce	D	f	2026-04-28 15:56:33.94777+00
3c0118bc-063b-4b1c-a3ff-17dd70e9876f	71805292-835e-4ff3-a365-f30fcfc06048	ab80055d-216e-4731-926d-e2edebe712a0	D	t	2026-04-28 15:57:42.19304+00
04909607-1460-407b-be1e-bb2f26fd6dcb	71805292-835e-4ff3-a365-f30fcfc06048	e568c7fc-715f-404d-b3ed-70048053b374	B	t	2026-04-28 15:56:39.975541+00
56aa33f9-f260-4167-b2c7-8cb84c5cfa35	a3d35273-6851-4c00-96de-1bbf6dfc9257	057d9d16-3096-49a9-9332-91786e8f7fde	A	t	2026-04-28 15:56:56.681433+00
ce309a48-a79e-4fa9-8352-82d8e7cf9771	a3d35273-6851-4c00-96de-1bbf6dfc9257	98043387-e7c4-4277-99f0-6815949e7288	D	t	2026-04-28 15:57:23.22719+00
44686ebe-3db0-4585-b2ad-fb6bc3a72433	2557bb3a-9869-422c-ac10-8000966fb728	0c357720-5066-4fd6-a7d7-64dde5fcb0c2	A	t	2026-04-28 15:57:51.656443+00
44d30867-a82d-40db-85c6-d5fc69f1ef23	2557bb3a-9869-422c-ac10-8000966fb728	9b17131f-11a6-4ea3-a6bb-38b56357e858	B	t	2026-04-28 15:58:17.912038+00
0f8a43ac-2df3-40c8-a7ec-365993e9d547	2557bb3a-9869-422c-ac10-8000966fb728	3ecc6897-3b48-4930-b659-d597c69c83bc	B	t	2026-04-28 15:59:13.095442+00
b5233ac3-e46d-420e-8d1f-c1f59ae79702	71805292-835e-4ff3-a365-f30fcfc06048	1f71e2ec-348b-4269-9503-e39e1cc6db2c	A	f	2026-04-28 15:59:37.16159+00
7da89cf3-2a4c-41f8-975d-d8fba6a42efc	71805292-835e-4ff3-a365-f30fcfc06048	f4dded80-a2f9-4297-8907-775b0136b46a	A	f	2026-04-28 15:59:50.46168+00
c96f2d72-bb76-45f8-91a0-a63441711799	2557bb3a-9869-422c-ac10-8000966fb728	66e563db-29f8-4f21-8537-c0127e5e63cc	C	f	2026-04-28 16:00:09.571399+00
a1a2ba8e-ffbf-47d6-af52-0e5db16e7b4b	2557bb3a-9869-422c-ac10-8000966fb728	0d6a324b-4f00-466e-9db4-a00dca497c99	C	t	2026-04-28 16:00:18.283951+00
cf407840-ff1d-4cdd-8de5-c148ee370be7	2557bb3a-9869-422c-ac10-8000966fb728	cda0ca18-8820-4020-ad75-1a93511536b3	B	f	2026-04-28 16:00:28.204614+00
80cf8b6a-09a1-4890-9653-f04bca8f8712	2557bb3a-9869-422c-ac10-8000966fb728	8348307d-6f89-4ee2-bcee-97ba4e2a32f8	B	t	2026-04-28 16:00:40.068939+00
9a07fe1c-9269-4aee-af01-9f6c4aa2de7b	2557bb3a-9869-422c-ac10-8000966fb728	fa4ff435-2391-4047-b44c-f685d53e9f55	B	f	2026-04-28 16:00:44.375308+00
8f3ece33-e1bb-46de-9663-01e918320232	71805292-835e-4ff3-a365-f30fcfc06048	cc8ba2b6-5eb6-4c30-a00d-d2a89b0ce831	C	f	2026-04-28 16:00:57.503375+00
834929eb-fc96-4511-a9af-45dcd16a65bf	2557bb3a-9869-422c-ac10-8000966fb728	cb3208dc-39aa-44b3-8625-60ee6507cbf3	D	t	2026-04-28 16:01:04.826472+00
a17a7644-289c-45d3-86e8-5fd3c733ca3f	2557bb3a-9869-422c-ac10-8000966fb728	2a7dc3da-9520-4108-929c-a14782e25c36	B	f	2026-04-28 16:01:38.91301+00
98bb19da-abdc-45e7-a8fc-e71b350cab00	2557bb3a-9869-422c-ac10-8000966fb728	0d9953e6-403e-4dfe-8d1b-81061084d971	C	f	2026-04-28 16:01:47.991834+00
0c2c5be4-a65d-4b0a-9455-b1a45d1239bc	2557bb3a-9869-422c-ac10-8000966fb728	854a05d3-849b-4dd9-a522-4b7c9d192a45	C	t	2026-04-28 16:01:51.75294+00
ece8452e-e270-4928-8aa3-82f9e7b514fd	71805292-835e-4ff3-a365-f30fcfc06048	fad720c6-cf79-47e3-a7dc-997ce0a4ca1c	B	t	2026-04-28 16:02:12.973799+00
8afde7a5-0d61-4f6b-b3d7-c89ea4290230	a3d35273-6851-4c00-96de-1bbf6dfc9257	87a00d9d-0b71-46a9-a5b5-dab32ffe2472	A	t	2026-04-28 16:02:20.761763+00
84eeaa5d-c996-46dd-9630-577b81eaf90e	71805292-835e-4ff3-a365-f30fcfc06048	c740ba7e-7386-4f2f-a462-c1d4778554e9	B	t	2026-04-28 16:02:45.734159+00
b70714b3-7bb3-40c7-b3f1-2b865ac8f6f6	2557bb3a-9869-422c-ac10-8000966fb728	011f55e3-6770-4d47-9e46-3b8cd0e83955	B	f	2026-04-28 16:03:19.795457+00
28d13ccb-1e5e-4208-9532-8ecf2fe4bb5a	2557bb3a-9869-422c-ac10-8000966fb728	70b8f220-c374-4587-bcb2-12f7e2fa0bf7	B	f	2026-04-28 16:03:21.027923+00
7295b370-f3f1-4ea0-9ee7-c131b3160543	2557bb3a-9869-422c-ac10-8000966fb728	dc146fec-8cb1-4a88-9c45-440587c8f124	B	f	2026-04-28 16:03:27.501457+00
8e9b2789-0e1f-4c08-8f18-dbb98d3e9f5d	2557bb3a-9869-422c-ac10-8000966fb728	61ea3a53-6193-49d9-a68a-80213ce57a55	B	f	2026-04-28 16:03:33.111516+00
b75d7cde-05c3-4dde-b960-eecb18dbd038	2557bb3a-9869-422c-ac10-8000966fb728	5679a8f3-dad5-48c3-8057-6caa1fbd2683	B	f	2026-04-28 16:03:34.43782+00
61cfbee6-256a-4819-a50c-6336bf953c4e	71805292-835e-4ff3-a365-f30fcfc06048	3bba5900-28d6-4761-ad6f-cfa430e73ebe	A	t	2026-04-28 16:03:36.908938+00
e1ba18ef-d4a7-464e-a03f-506c099add4b	2557bb3a-9869-422c-ac10-8000966fb728	ecfc3df5-ed6a-44f4-9485-2c29f731aa0b	B	f	2026-04-28 16:03:38.47409+00
36d404e9-b774-4089-9981-847a7fb02700	71805292-835e-4ff3-a365-f30fcfc06048	d3b41295-7f1b-48e9-a96a-52043440d70b	C	t	2026-04-28 16:04:46.473937+00
ef62ae61-299e-4c94-80d1-d2826a4ff06c	2557bb3a-9869-422c-ac10-8000966fb728	ac6f50f6-6eab-41d1-833d-6740b87c9175	D	t	2026-04-28 16:04:50.734485+00
fc4fc9bb-ba81-4390-b06f-64519328440e	a3d35273-6851-4c00-96de-1bbf6dfc9257	1f2aa538-6e73-48e9-92b0-91ab71dd76aa	C	t	2026-04-28 16:05:16.265943+00
423a5dda-104a-420b-b6d5-78c476387520	71805292-835e-4ff3-a365-f30fcfc06048	0ecbb69a-5327-4480-ab5b-8a34b5179a3a	B	t	2026-04-28 16:05:32.070226+00
752ae46d-da0b-44e9-929b-84c8e75ccad7	71805292-835e-4ff3-a365-f30fcfc06048	338d8dcd-bd80-427d-8c4b-7cefaa73721f	C	t	2026-04-28 16:05:46.937976+00
69a51ae9-2062-4cc7-853d-15841534835f	433b1a37-02eb-48f9-ab38-1a546a6903bf	6ebea734-46a1-4bc7-9949-cfd2128f81e9	A	f	2026-04-29 13:50:41.171492+00
863a96f2-9e1a-4301-bbb8-63aeb86bec0a	e7ec87f6-3540-4528-bf0f-2f0ffc4edeeb	8348307d-6f89-4ee2-bcee-97ba4e2a32f8	D	f	2026-04-29 13:55:20.203539+00
9bed4969-13e3-4119-bbb2-29ba185202c2	e7ec87f6-3540-4528-bf0f-2f0ffc4edeeb	fa4ff435-2391-4047-b44c-f685d53e9f55	B	f	2026-04-29 13:55:21.13539+00
7309d7cd-033b-45e1-82e9-94850937ba4f	e7ec87f6-3540-4528-bf0f-2f0ffc4edeeb	08a035f1-feef-4d5b-8017-ef1773ce0f4d	A	f	2026-04-29 13:55:22.282716+00
266fdcd1-828f-4f4c-86d5-5608e5e56f49	e7ec87f6-3540-4528-bf0f-2f0ffc4edeeb	75a24797-7a12-4fab-a527-e72c1d201203	A	t	2026-04-29 13:55:25.018451+00
93e88c1d-519e-469e-82cf-567b850fd452	e7ec87f6-3540-4528-bf0f-2f0ffc4edeeb	9c09af5e-a1c7-4691-9711-b9cd745d9753	C	t	2026-04-29 13:55:26.926833+00
f7c5ad4a-1d63-45a7-abb1-6b0946e3c9d2	e7ec87f6-3540-4528-bf0f-2f0ffc4edeeb	001777f1-ddfd-4c1d-9f39-0f7ea9489952	C	f	2026-04-29 13:55:29.545498+00
14ff223f-78a1-434a-9eba-097aecfbeb03	e7ec87f6-3540-4528-bf0f-2f0ffc4edeeb	ff1a1634-1cba-4dfd-a821-3c681b5fd44e	(A)	f	2026-04-29 13:55:31.088205+00
e0a97ca8-64cd-4167-b924-2675d443ea06	433b1a37-02eb-48f9-ab38-1a546a6903bf	8af36a16-997a-4f49-8622-77c5f80334df	C	f	2026-04-29 14:02:51.275008+00
d92cc8f1-33db-48a4-a7cb-64cd73e9e214	433b1a37-02eb-48f9-ab38-1a546a6903bf	66e563db-29f8-4f21-8537-c0127e5e63cc	B	f	2026-04-29 14:02:52.104778+00
eb26471f-61bc-4e2b-b147-4a99f67c4be6	433b1a37-02eb-48f9-ab38-1a546a6903bf	0d3a863f-1bdc-4700-9fde-50a6789967a6	A	f	2026-04-29 14:02:53.316815+00
c38ad282-8096-46ab-9ceb-62089a61024a	433b1a37-02eb-48f9-ab38-1a546a6903bf	46017748-34b0-4df2-ba25-ae8a35202fd9	B	f	2026-04-29 14:02:54.914543+00
b5f8f4d5-9f3e-4942-8c9b-e497b824f282	433b1a37-02eb-48f9-ab38-1a546a6903bf	e7e5c15d-593a-41f6-a631-17cee6c3d6e2	C	t	2026-04-29 14:02:57.25925+00
c3ae819e-92e2-4000-b8d5-86ecc0427a7a	433b1a37-02eb-48f9-ab38-1a546a6903bf	cf3e3677-791a-4595-acca-dbdb0f4d2908	C	f	2026-04-29 14:02:59.992584+00
8f92c974-003f-45d9-a89a-e809d189d4c0	433b1a37-02eb-48f9-ab38-1a546a6903bf	14e7bcbb-c2f7-48bc-aa90-74c03999d9e7	C	f	2026-04-29 14:03:00.924459+00
9158d1d1-f545-4d15-aac8-f8c16821cd02	433b1a37-02eb-48f9-ab38-1a546a6903bf	e92084ad-292d-4840-abe3-026cbdede660	C	f	2026-04-29 14:03:02.385837+00
827aa84e-7752-497a-b74a-0e46ec8e9784	433b1a37-02eb-48f9-ab38-1a546a6903bf	d0ff282d-2b31-4f6d-a72b-f0e522b93a60	B	f	2026-04-29 14:03:03.344479+00
41c491c2-cd10-4c3d-a7cb-fce9c8dcea5a	433b1a37-02eb-48f9-ab38-1a546a6903bf	d8122c72-6c11-4278-835b-9d1e6df1a3c8	A	t	2026-04-29 14:03:04.373997+00
3af2dea2-737e-449d-a44b-c864b8fcfc50	433b1a37-02eb-48f9-ab38-1a546a6903bf	0d6a324b-4f00-466e-9db4-a00dca497c99	A	f	2026-04-29 14:03:05.440643+00
8cf095c2-7c6b-415a-b55b-bde2c17c6917	433b1a37-02eb-48f9-ab38-1a546a6903bf	cda0ca18-8820-4020-ad75-1a93511536b3	A	t	2026-04-29 14:03:06.52689+00
f828f82d-b95e-4082-9932-0875e4576198	433b1a37-02eb-48f9-ab38-1a546a6903bf	80f911b3-a969-481c-bb8d-6920cf9cb4c3	A	f	2026-04-29 14:03:09.049711+00
fa5d8051-4323-427d-b9ca-00826562603a	433b1a37-02eb-48f9-ab38-1a546a6903bf	8348307d-6f89-4ee2-bcee-97ba4e2a32f8	A	f	2026-04-29 14:03:10.090104+00
2de0a148-69f2-4283-9666-de09deeb0be2	433b1a37-02eb-48f9-ab38-1a546a6903bf	004f4b76-a500-47d3-a015-235e0717205b	D	f	2026-04-29 14:03:18.295938+00
ee42f5c6-0948-4213-9e0d-f3a6b2d77bd9	433b1a37-02eb-48f9-ab38-1a546a6903bf	3ecc6897-3b48-4930-b659-d597c69c83bc	D	f	2026-04-29 14:03:19.874359+00
\.


--
-- Data for Name: attempts; Type: TABLE DATA; Schema: public; Owner: exambank
--

COPY public.attempts (id, user_id, kind, mode, paper_id, drill_subject, drill_chapter, duration_sec, question_ids, status, started_at, submitted_at, score_correct, score_total, elapsed_sec, exam_type) FROM stdin;
bc9170e2-363a-4c00-85a1-419765d2f7c1	6d9eaffd-5659-4afd-b2a2-7b6c5e4ef8cb	subject_quiz	untimed	\N	mathematics	\N	\N	{3c8324f4-f243-40a5-9cf7-c8f0400442c9,02f9760b-6ba8-4014-95b2-2fd38671158c,850faec6-68af-49ef-83ad-e98c2046befd,80c5c9d7-d501-420c-a2a1-c1922ab19807,0e6f388d-33a0-4f0a-88e4-3e5b6f56072e,87282edf-d675-42ea-8f03-ec8e09031ebf,a6db028f-0764-4dc6-a95c-ccc4231cccac,eb443241-a0e6-419c-9b43-9c2b638a0d79,14bc131c-3a3c-496c-947c-029d7c7f9c86,16e61ff3-b78f-4f50-bfba-1ffb10761b16,cc1a8a38-da4b-4ffb-bead-d9293e2a321a,ae85c7fb-3043-4f6c-93bb-593346503a90,62b45fa3-5a84-4c32-84a5-c2bd8fbf7309,91207fa5-34c4-4ff7-b892-2b63c864520d,a9f9c912-74a4-4991-8001-6116bb741fe4,d8efe0db-6cfa-4e4c-b111-c7fe8248c4bc,00a8153e-8901-4f13-8ded-a2f2e4e13ffe,64013a8d-e3f5-4db2-94af-1521227c85f1,73025035-d12c-4dd3-a548-a066ef26a300,14495dd6-f4c8-48c2-9cea-e1f1c93b92a8,76343b23-ae51-4c07-9734-a17b5fb17fa4,e6e0e1ce-ab24-457e-b0be-f8e99c2b867a,8a09e10c-661b-4dc2-b8f3-aa7caa3b4491,1b0029c4-1cbe-42bf-8d58-65f2ca53bfd1,a6075742-074a-4d3f-a10c-27b235d9a593,09bf3bd8-4f02-4106-a93f-d2d6aa6b5f65,fb6587ae-24ad-466c-985f-4cb2e66f89db,bbb69845-aa2e-4916-9c8d-ddb06a72b002,dc71a03f-b7c0-4e24-b019-2104aeda7e06,94d6936a-6e54-46fc-88a2-0f7b1a95d577,8ca720b4-8d46-40a9-85b9-71a1f611773c,f3fd98df-40b0-4dc2-a6b7-423b3130671c,7d7ecf56-2a4c-4c75-821e-a8442b60bd53,5a5757fc-54ec-42c9-8c7d-9e79e2b779ec,c2c3a64e-b2cb-4256-b8dc-fb6b1f66ed03,6ca4ca64-aa11-49a8-b740-f4aa541d150e,cfc4d4f2-7399-4d28-a66d-32cad02fe053,8442c1ae-8af4-4f4c-bf2e-2e1c677651cb,ae335f47-e605-48a0-8fbf-eb4e8986f137,19108d8a-6555-46b1-9f75-d93b8fd0e4c6,244f8058-cb97-45c0-b78e-4b2393795704,ef9f39c1-8a27-4472-a265-1705ec549c3a,a9253795-0981-4530-836a-7708a2ae0b45,1434f64d-6b43-45c0-ab47-b89cad8465cc,6cfffde6-51cf-41b4-a4d4-c71e22c23870,e4a4312d-9b7e-4862-a29f-2de94713cc60,d956b3b2-c375-457c-b36d-d7e5eda157db,5b085180-8d95-4faa-b246-1baa9dc2dc92,fa5859ec-2974-4fb0-a78e-381edc86ba1b,a87b01e9-3ec3-41cf-92da-517b413d3aa6,c34aa487-10b3-401a-9571-d771f69d09d8,462f083c-d6dc-4988-9632-c59710763f0a,e118b659-ae11-4fc2-872b-ea9b90b39e9c,53a06aa2-abf8-40e7-a48a-fe5ed88a006f,481d86de-d333-486b-af5a-9a1bd481a2f7,cc0fdd4f-8c40-40bf-8baf-57fa71daf654,47a2db81-bbd5-4f67-bd3d-1e0423644fb0,b107e72d-5b35-48a9-844e-8debf4367482,06d590b9-a4b4-435d-80d2-e00892d57ee2,5b4a15e7-8b68-40a7-a5c1-9100079ec87e,06d698e8-232a-49ee-8128-f63ac88d04d2,b89d5282-f81b-43c3-8741-614a877c86ad,bc22adfe-a7ce-4ce7-b7b1-4b77be764eda,5ffa9e49-ab9b-4f56-8ae1-82f03898b371,87e9fd93-2808-42fd-b422-83f211bb7322,338edf0f-8f39-40d2-8b1e-71461be5d206,d9196d07-6259-4a68-9f98-a502a20080f1,3ff2320b-449f-4642-a3b2-44b42845af9f,dfe2f375-038e-404b-84c8-d180703d4066,729b8f97-7237-4a56-b3c1-32b088e0d05e,1fbc98e0-4c41-4d0b-bcf3-b78ba3170441,6fb6e116-0fd3-471d-ba3c-ba45510a024b,b719be80-d9d9-4ab9-ac30-4f9ffb9e75f4,9e4a4db0-6a84-4fe2-85eb-8d61c4eadd4d,bb5e6ca7-1c67-4954-8b43-e6664aca219b,23ba8888-8e6d-4dd8-8c37-f448819ee2ca,d731f844-7267-4331-8e61-e9b3d4f84248,2518e0e8-9206-4450-b11a-13117a8ad1e1,a958569f-32fe-46d5-9bd9-676fa92f39ba,d9c63a71-5c7c-46cc-bfbb-80c8d08a6aef,a71e6d04-65d2-4501-b36e-e3972c5433c6,ab674125-266b-4810-820d-51e01d9e9fa3,d119de1c-67bf-4122-b253-4faa9095dc9f,5c4c5cde-9543-4cf7-af80-2549ff637522,3cf007c0-fbd8-4f56-b9c8-b8057934c194,9756187f-492e-469e-8a23-5440b02e118d,ce6762bd-9ad2-4110-bd59-4b014abe8a95,684ae4f8-35a7-4cae-9b36-d6a5e6b5ecad,88055b7b-1d2a-4214-8b2f-764bf18631fd,d6a54fcb-9063-4b1e-9ea6-d7af276a9e3d,059f3416-8a2a-4f39-b02d-8c91930a3182,278a11e6-e51a-4147-ab85-5b33145c4b4f,e73a39b5-852e-4ff6-941c-17bf84b210d2,dca56350-0ec7-480f-841f-3d0b0d098135,c77902b3-6550-4c6d-a2cd-3aa4f40423f9,12134285-1e26-45a8-b59f-6cda2798a7fc,858d0097-93f9-4bac-87dd-2d101bbd68bf,6a27ed3e-e0af-40ab-b3d8-a064753c7ebe,ecde36b4-4d95-4b69-b86b-952c1723f834,36cf314e-7f2e-4dbb-9f51-3b44b39668a9,717a93bf-59cc-4db8-b817-682d44652d82,e3d860a5-7343-43e8-bcb8-ce5805debcf7,b1451d45-98c4-44d3-bdce-3992225e8481,b324d53d-259a-4afa-bc37-3d7dc876cda4,e67dc779-dc77-43b4-b0ce-c4894489103e,69a58ffa-5f06-43ad-9351-93fcac89a144,235b4eb3-fa4e-4e55-a04b-7eb052aecf74,f7308d4e-842c-48a5-ab56-13e3c775a9bf,3b282d93-6894-4dd4-be9a-097db02400fa,3c7cac49-945e-475a-bcec-dd9baa98e4b4,d422abd4-872c-408d-ac31-d32d55b374ea,085a79c7-14c3-4218-962f-e64b04e1c576,53fb9947-7274-403a-9a29-feb6843d137c,37460786-8f6a-4562-a11d-a167c6305daf,e3496790-8253-4d55-ac02-c62789a3aa79,50eca9d6-a660-49f4-886e-21ef757b589b,d8b127a1-4e4c-4125-a55f-2b39cec54c6f,8c9b0948-331e-4bf9-b380-79f3b91f4035,35a4c577-4532-465c-9034-2e13b7aab087,642ceec3-d1b1-44da-9724-05d0c03df45b,e089d5d2-bb03-4471-86c2-2c3407530f61,30e4f9fd-92bf-491e-a45e-5f8bd63ff00a,c04c6ea0-7ee3-4e5a-85dc-b72c7f6f3020,f1de21b5-a199-45b1-8c93-94c0a1fab0e2,d6a74f81-a1f0-4490-8734-6a72f92fc963,ca7ca25e-f07d-423d-9b1e-5fa91a2bf578,c58cb579-ea91-40a0-9671-5caff7d789c3,2a8fa087-27d8-453d-93bc-340a8fd2942e,e22a26cf-e7ce-464b-b19c-7fe1766f7c72,2a38065a-9145-4fec-a7d9-01b7f1c55f82,d7f81656-4ebe-4f48-8eb2-571d40e72f47,a7efeae1-ef25-439a-aab0-fd931154652f,3556bbed-9cac-4f0c-b691-187f29028fa5,dedf970c-bc28-42e4-97a9-e40fc3b52910,6a905554-2dd1-4a7c-a500-bd9e825e1c4f,be3b4e34-7d71-43a8-9a9a-12a60e7bdbd9,2577e578-d372-4932-b1f1-a963c8261dd1,96b1335d-6f4e-4999-897e-e9b5497af568,a939077d-db2a-4f99-82ed-b8fa8d7f9e5d,da7a4805-ff0e-4d85-8208-2a919d682dc1,f03efe1d-a96d-45db-ad85-9a0ef8dad3e7,723ea36f-88d0-4670-befb-326b583f045b,9b7cbbe1-1c92-4bd9-b792-34480ccd831c,fcbfeb79-7f9b-4168-a154-8268ad3ffaaf,4592e698-0afb-4d68-9d5b-4ff5996e72c0,9ad62dcb-36f2-4724-a79f-8a405e26a116,72f0d0eb-9f06-46e9-b116-dc9b59c32680,03afcf27-cabb-4a4b-80d8-abfd1ee920ca,da1e1550-a9a6-43e8-94e1-8581937d1d94,5e0e6008-65cb-4a3f-9135-33ca1bbef1ee,25d93e66-2e35-4311-a08a-e1daf77f5cd5,9bc067b9-4270-4234-8748-7386739d0d7f,84dc9e5e-4d44-4a78-ab10-fd9be21b5286,5de2a6c8-5daf-4557-a702-ad17cef4807f,78918a2f-7419-4c4e-89d9-cf193ad6d3b9,d8bd851c-e716-4bc4-93e0-365b13791941,0d5eb94e-46e9-4e0a-9b5c-9795b00a3a2b,4bf22e12-a335-4efa-9b66-8dd4cf2db6d7,e9e5918b-87d8-40d3-821b-8026e321680f,90f4458e-db6a-42a5-974f-e7838ff95383,280db66c-4465-492b-be96-2df7528ac624,2bff07da-b0ce-4a86-8516-089b41c61b98,91f2907b-13de-4f68-89c3-26664aff072b,822237e1-862f-4d85-aa99-278dca464bcc,360baecf-34a7-437c-8c7f-c5b3d1d8b27d,40b17b5e-c209-4c7b-9fe0-acb9ed1a0c48,41cd39b1-ca7d-4575-b95c-fc839dc20cdf,4d48eb67-9224-4cda-ada6-72237c81dc55,4fe12ae0-7d60-4acb-8993-3e1433dd7597,c334d74b-bcce-48df-9e88-ab997ad5e301,dc249b11-498d-4463-aab4-5802592894ce,21fe7e28-1459-4168-a6df-820046fccf0e,4baa74ca-84e2-4e87-bae8-96573878f24c,4c0d955d-1d07-4287-bf21-188b604a0255,6ab638f1-de68-40dc-8cbf-9d70d18aed9e,3a8afe71-35fc-4592-a122-8d83a713e9e2,e8bdfe3d-0799-4385-84a2-99e588b584f7,91e8a796-bdb3-4b28-8f5e-573eaf629d1e,494e26be-ddc6-46e8-8f85-02017a97a9a8,398cf02a-8e91-487f-99c4-9986f19e2b39,c92c73b1-0152-4405-a2fa-756266d65d68,8777f4e0-13a5-4fd6-aacb-5c1e3b268511,38645518-b89a-4c6d-a0fc-ba993b31f8aa,a5484c83-9534-4ac5-b60c-eb8ce222ccf6,2455d12f-d4c4-4f3b-9ccf-7896d751003c,1d109fae-1ac2-4f89-8067-e9ba7c36622d,5816d1c2-fe10-419f-97a9-c4b2995fe001,0b060917-e53b-4c70-8db2-389b2eaf1ecf,0bcd7650-c0f9-49fd-a011-7833c7b7bbd7,69ccb9cd-13f7-4e9a-acf2-88c246e38c07}	submitted	2026-04-28 07:17:21.75076+00	2026-04-28 07:18:09.398335+00	4	190	47	admission_test
29cdc3de-814d-4f5c-825a-06abb47b5a1a	6d9eaffd-5659-4afd-b2a2-7b6c5e4ef8cb	subject_quiz	untimed	\N	physics	\N	\N	{8af36a16-997a-4f49-8622-77c5f80334df,66e563db-29f8-4f21-8537-c0127e5e63cc,0d3a863f-1bdc-4700-9fde-50a6789967a6,46017748-34b0-4df2-ba25-ae8a35202fd9,6ebea734-46a1-4bc7-9949-cfd2128f81e9,e7e5c15d-593a-41f6-a631-17cee6c3d6e2,cf3e3677-791a-4595-acca-dbdb0f4d2908,14e7bcbb-c2f7-48bc-aa90-74c03999d9e7,e92084ad-292d-4840-abe3-026cbdede660,d0ff282d-2b31-4f6d-a72b-f0e522b93a60,d8122c72-6c11-4278-835b-9d1e6df1a3c8,0d6a324b-4f00-466e-9db4-a00dca497c99,cda0ca18-8820-4020-ad75-1a93511536b3,80f911b3-a969-481c-bb8d-6920cf9cb4c3,8348307d-6f89-4ee2-bcee-97ba4e2a32f8,fa4ff435-2391-4047-b44c-f685d53e9f55,08a035f1-feef-4d5b-8017-ef1773ce0f4d,73c1c74d-b66f-4759-8fe1-c9a414e37872,75a24797-7a12-4fab-a527-e72c1d201203,9c09af5e-a1c7-4691-9711-b9cd745d9753,001777f1-ddfd-4c1d-9f39-0f7ea9489952,ff1a1634-1cba-4dfd-a821-3c681b5fd44e,73b59855-deaa-4f41-9913-5a53a9111826,cb3208dc-39aa-44b3-8625-60ee6507cbf3,2a7dc3da-9520-4108-929c-a14782e25c36,4599acb3-9d78-4bf9-8c9b-47bc3b7756d6,0d9953e6-403e-4dfe-8d1b-81061084d971,c7cb926c-cb05-4342-86c3-3c23a8749ebf,b7a602a2-e595-4a46-8aca-637cb75a3eee,854a05d3-849b-4dd9-a522-4b7c9d192a45,28c07dfe-cb42-44d4-9f2f-dda64ffb6882,38286d3b-99a2-4122-b821-87eb0a236eca,ba844b10-8d58-4186-9c14-2cdced4aaeae,70b8f220-c374-4587-bcb2-12f7e2fa0bf7,011f55e3-6770-4d47-9e46-3b8cd0e83955,a573f0bf-6d03-49fe-bb60-accbb25272cb,1b88a88c-cb2d-4184-a5e0-de08129088a2,38f811fb-1c5b-48db-878a-e7492dac0d62,fcb4d325-5f11-4166-ba6e-0c718d6b8936,1cba308b-e030-438f-bf35-8632f38605e8,dc146fec-8cb1-4a88-9c45-440587c8f124,d3ccca49-10b5-4f46-ac64-eb70abeb097a,af038b7c-e600-4d33-8155-21719ce50014,6b8b0d2e-4b91-4511-9acf-a2f4c0fce4e9,87a00d9d-0b71-46a9-a5b5-dab32ffe2472,98043387-e7c4-4277-99f0-6815949e7288,057d9d16-3096-49a9-9332-91786e8f7fde,61ea3a53-6193-49d9-a68a-80213ce57a55,5679a8f3-dad5-48c3-8057-6caa1fbd2683,ecfc3df5-ed6a-44f4-9485-2c29f731aa0b,fb75ef93-d920-4f94-81ea-1d9ff5b08784,568b2bc9-9a19-44c0-8b8b-8d0045475282,a360f901-de88-4d26-8f31-c16713d3b6da,bd780c4e-1e12-4891-a7a0-e6a61eed1456,f1859d7a-e0a7-4fd0-b9c8-a04f01ee9d2a,2e1e2c65-8558-43dd-afec-c2d333b2aa14,ac6f50f6-6eab-41d1-833d-6740b87c9175,b8015bab-db1a-45e5-9320-352d8d698989,9eb2d84f-c683-46fd-b93a-def8d294ca2b,a776c176-a748-4ce2-81b0-d2817998a72c,ed6ec807-2624-4a5a-9f90-6aea86d4fa8b,91b366bd-9fda-470d-99fa-9daae2309649,d8273d47-fb02-4186-aac8-9ca5e5541f2e,52357405-5abf-4f44-98ff-230d83a1da72,617ff669-f28b-49d1-8d4e-1d03aac4f140,1f2aa538-6e73-48e9-92b0-91ab71dd76aa,631925ee-0015-485f-b444-04e213626498,346f920b-88ea-4002-9f8c-54db78719db2,39913432-08d3-4da1-8101-76555b68789f,901eaa80-8900-46c4-820f-6f002be4a75d,44dabe5a-baf4-4f09-abf0-5fdc2d32a0e2,0b5f0817-9307-4039-a24b-2cad9cc12a35,3e4ea525-2149-4cf7-ac09-9c3085be3a07,907c9c8d-a368-4884-bbbd-04bfd8d150b8,cbc7a85d-71ac-44c7-baa8-1aa8f8287b9a,4ce9e2ef-41c9-44d4-9476-d83c495c093d,134c31cf-066e-4317-af88-173a7711068d,52130c99-6ddd-4199-99fc-1a9ced88011c,860c1fc9-5098-4d31-856f-94e217189509,225e280b-313c-45c5-ac01-002865223dfe,448025f6-abe6-42fa-8866-014b842f7785,603aab63-8553-47a4-a088-d2d1ce0ccd17,b1f34359-813c-454a-87d2-8be081eec7d0,e1d1e7b0-bd77-4a21-95bc-ed3972271996,c20cf417-98d4-41eb-8914-7e4e3f45fa83,b1948a83-dec1-4d5c-92ca-3909de974a5e,8dc11970-9511-4442-a739-3d999548678b,79fac420-1fdd-40d0-b324-11d7fdf6767b,eab51de4-7348-4b0e-9609-064e88015dea,b5a6e81f-c016-4964-8cc9-cd77e4ec8fa3,41a0acaa-dbdc-4719-9b7f-f796e1a8db5f,e8c100e6-f5c4-4839-97d9-0e7d7089985b,d00bf7f0-ff55-42bd-8b08-def20bb03915,4706a514-8c18-4c10-911a-ca041142edc2,c44fab2b-eb92-4719-9d96-23dfbfe38b22,6b73768d-7203-43eb-a59f-6730654649cd,2b101e61-141d-4d7f-b4c2-196138cf5fb2,3f5b9d22-6edf-4b2b-a7e7-2b634e259061,234ce33d-2f3e-44da-bb27-cb3c7539c50f,236c5edc-9fb2-4134-b848-7df9910ee107,4b3fd082-8394-4ecc-afda-a36b07d05658,19e6c77e-9cfc-4eec-99c4-afdb0ba05ca5,0bd7afbd-dcc0-410b-bde1-5355b8cb277f,f43d91bf-4188-4d97-8011-e759b608a2e2,f606aac2-ea93-4afb-894f-6c4fa67e6b05,24c0e56f-d2c6-4418-ae77-a82a0b94ee74,4c87010d-60fd-4686-8d7a-0b11ad5aa2d8,6d111269-ad5b-401e-a1b2-4819ba463ee6,49ac5214-08aa-4093-9790-8e3402278800,7e95694e-7ce3-4768-b194-baf73df330b4,6f0a35c2-8908-4c2d-9620-26945cada15f,e1f38048-f857-424d-bbec-4cfa15494f9c,6dff14d7-14d7-4232-9a97-e4b24b18a43c,e7f5bd3b-c6c0-40f2-8303-1977170cdd93,759721fb-6efd-4fa0-873f-994c91fafae6,cf3b2c91-ad6f-4dd1-8e75-00f30732f932,3ca8ae1a-6ccf-4d76-bbe9-913a8fc3cd5d,fa60a6d0-fec7-41af-b837-dc417b5e36a9,f6992e14-6260-4199-8666-6e9366738d82,ae44507d-e359-4e47-b783-a5b9ca68f0eb,1b7caef1-59fd-4b4a-aa70-42c2f635fe44,d465803b-1304-4d77-8002-5b7aedd3c83c,18cb2450-e0d6-41d9-87b7-d55e28876177,4290a514-cf7b-4347-b9af-e669fda9388f,224cfaf5-cd27-416f-a643-c1e7c7aa4d36,b6da5681-215c-4b93-b5f0-6e8f785b731b,25ec7bf5-1589-4329-b1f7-516f0f8d37a0,19ccfdd4-936b-41cd-b943-379ebb3eb295,982593d5-f7ce-4d9e-813b-41e6df2b0bef,9f75d35f-1455-4153-8056-423445f16fce,6b7a2340-d204-4c9a-a820-90576cb4732e,fad7afa2-b0be-4bfd-ad77-992dd800cac6,e568c7fc-715f-404d-b3ed-70048053b374,dfa449d1-1841-483a-9d3c-fae10a197a8e,ab80055d-216e-4731-926d-e2edebe712a0,1f71e2ec-348b-4269-9503-e39e1cc6db2c,a75f1685-75c9-46d3-a53d-c51b3c16eaef,f4dded80-a2f9-4297-8907-775b0136b46a,ca52fa50-abaa-4fd0-bb0d-ae75039e1cbb,cc8ba2b6-5eb6-4c30-a00d-d2a89b0ce831,fad720c6-cf79-47e3-a7dc-997ce0a4ca1c,c740ba7e-7386-4f2f-a462-c1d4778554e9,3bba5900-28d6-4761-ad6f-cfa430e73ebe,b51e5ec8-ad46-46b5-b689-d5e8a977463e,0ecbb69a-5327-4480-ab5b-8a34b5179a3a,d3b41295-7f1b-48e9-a96a-52043440d70b,338d8dcd-bd80-427d-8c4b-7cefaa73721f,8867a36b-758a-4c7e-ab60-1596edc4c28e,80d9a4aa-49ca-4e56-9af1-fa6d6157e28f,738590ae-23a1-4699-bc44-edbe819148d2,a1ae8350-1cd7-42bd-8999-4a5c1a275990,78416331-8465-4bc7-8067-af60abc59577,816a0061-1e82-44b0-8914-79a1931908fd,cf30506d-2b21-48ac-ab56-f21bdea377c6,461e205a-bb8a-4bdd-81fb-f8a21d854215,050c9a2a-afc8-4cf8-84d4-2c22be81abd0,a7474a47-2e26-491d-a7b9-b04b8138e571,3685e2c6-f04d-478e-87ed-12d8cc72939c,461daa81-404c-4000-b336-e406acefa007,bddb3fc5-93d3-4c42-a66d-96227a6e8f0f,49fe07e4-d291-4f8f-b4f9-0fc162ad8553,d9ca492d-8ac0-487a-8a2e-0644d67689e2,0e7b1d5f-a655-4b21-a3e9-37c113cfc52e,1e77e791-b572-49c5-96d7-14115d517329,bb8e0d8a-95dc-4430-a5de-bbedcd1d8fda,993ab2ec-b5b1-45ce-8e69-172067cd19a5,6b90fb4c-402a-49a3-95a2-75d1eb435bea,f0807419-d303-4100-8168-7fa61676df98,b1c543d3-0318-4e2d-bc4b-6212bc78941b,52ec6e64-8b1a-461b-a878-0c0c035dbbd4,01cdbfcd-5a74-450f-b9fa-69200db938c3,314c5e8f-d335-43b8-9d15-98ddd83054ac,98f61b5a-bb45-4b43-b6ac-d150779b2711,f29d26aa-a051-4d45-b580-7f49cc55ac8e,06124444-db56-443e-8025-1c2c369f8576,93402563-6af3-45ec-9de0-aede8c8fb6b0,d16e6125-c814-44cb-86d7-0eaaa8baa883,aed35f2e-37e1-442a-b518-86d99c84bcea,a772c84b-1fe5-43b3-8631-af02fd8450a1,87e60be5-0a87-45da-ad2f-f8266e80c18c,d254c27e-6371-48b8-96a2-4f5407502a92,a01b5c95-1c9e-4319-b48f-90743f87f68c,838997fc-c95f-428f-8c5c-30357c80a62a,93d31d40-3d8a-4907-89b2-12486ee52608,cdfddac8-993b-4063-a369-7e44a7d24b69,27cfb107-5cd9-4f06-9464-e31b0758e1a3,9f65ed34-7e3f-42fd-88dc-49989c66c493,59bfd3d6-e1bf-4233-8def-1f648b4c045e,f69b2d12-2038-41a9-b416-d3c480736f5b,7452052d-1c3d-4aa8-8fcd-e58556513248,6dc0f00b-5ebd-4b0e-b639-2168d0bea3ce,42ed3074-0269-4669-9f60-ed38853ba85a,454c4c4e-a9c0-4349-9861-1d2394b1c495,0c357720-5066-4fd6-a7d7-64dde5fcb0c2,e9c58f65-779c-4040-94a0-db21a41f3a7a,9b17131f-11a6-4ea3-a6bb-38b56357e858,c619a5da-b633-425a-92b2-34cb831fd662,3ecc6897-3b48-4930-b659-d597c69c83bc,004f4b76-a500-47d3-a015-235e0717205b}	in_progress	2026-04-28 07:37:32.729481+00	\N	\N	\N	\N	admission_test
904a377d-3f41-42c0-a092-1ac3d2f83c5f	c00baaf7-94dd-4b0a-a92b-f010736f1ede	subject_quiz	untimed	\N	physics	\N	\N	{8af36a16-997a-4f49-8622-77c5f80334df,66e563db-29f8-4f21-8537-c0127e5e63cc,0d3a863f-1bdc-4700-9fde-50a6789967a6,46017748-34b0-4df2-ba25-ae8a35202fd9,6ebea734-46a1-4bc7-9949-cfd2128f81e9,e7e5c15d-593a-41f6-a631-17cee6c3d6e2,cf3e3677-791a-4595-acca-dbdb0f4d2908,14e7bcbb-c2f7-48bc-aa90-74c03999d9e7,e92084ad-292d-4840-abe3-026cbdede660,d0ff282d-2b31-4f6d-a72b-f0e522b93a60,d8122c72-6c11-4278-835b-9d1e6df1a3c8,0d6a324b-4f00-466e-9db4-a00dca497c99,cda0ca18-8820-4020-ad75-1a93511536b3,80f911b3-a969-481c-bb8d-6920cf9cb4c3,8348307d-6f89-4ee2-bcee-97ba4e2a32f8,fa4ff435-2391-4047-b44c-f685d53e9f55,08a035f1-feef-4d5b-8017-ef1773ce0f4d,73c1c74d-b66f-4759-8fe1-c9a414e37872,75a24797-7a12-4fab-a527-e72c1d201203,9c09af5e-a1c7-4691-9711-b9cd745d9753,001777f1-ddfd-4c1d-9f39-0f7ea9489952,ff1a1634-1cba-4dfd-a821-3c681b5fd44e,73b59855-deaa-4f41-9913-5a53a9111826,cb3208dc-39aa-44b3-8625-60ee6507cbf3,2a7dc3da-9520-4108-929c-a14782e25c36,4599acb3-9d78-4bf9-8c9b-47bc3b7756d6,0d9953e6-403e-4dfe-8d1b-81061084d971,c7cb926c-cb05-4342-86c3-3c23a8749ebf,b7a602a2-e595-4a46-8aca-637cb75a3eee,854a05d3-849b-4dd9-a522-4b7c9d192a45,28c07dfe-cb42-44d4-9f2f-dda64ffb6882,38286d3b-99a2-4122-b821-87eb0a236eca,ba844b10-8d58-4186-9c14-2cdced4aaeae,70b8f220-c374-4587-bcb2-12f7e2fa0bf7,011f55e3-6770-4d47-9e46-3b8cd0e83955,a573f0bf-6d03-49fe-bb60-accbb25272cb,1b88a88c-cb2d-4184-a5e0-de08129088a2,38f811fb-1c5b-48db-878a-e7492dac0d62,fcb4d325-5f11-4166-ba6e-0c718d6b8936,1cba308b-e030-438f-bf35-8632f38605e8,dc146fec-8cb1-4a88-9c45-440587c8f124,d3ccca49-10b5-4f46-ac64-eb70abeb097a,af038b7c-e600-4d33-8155-21719ce50014,6b8b0d2e-4b91-4511-9acf-a2f4c0fce4e9,87a00d9d-0b71-46a9-a5b5-dab32ffe2472,98043387-e7c4-4277-99f0-6815949e7288,057d9d16-3096-49a9-9332-91786e8f7fde,61ea3a53-6193-49d9-a68a-80213ce57a55,5679a8f3-dad5-48c3-8057-6caa1fbd2683,ecfc3df5-ed6a-44f4-9485-2c29f731aa0b,fb75ef93-d920-4f94-81ea-1d9ff5b08784,568b2bc9-9a19-44c0-8b8b-8d0045475282,a360f901-de88-4d26-8f31-c16713d3b6da,bd780c4e-1e12-4891-a7a0-e6a61eed1456,f1859d7a-e0a7-4fd0-b9c8-a04f01ee9d2a,2e1e2c65-8558-43dd-afec-c2d333b2aa14,ac6f50f6-6eab-41d1-833d-6740b87c9175,b8015bab-db1a-45e5-9320-352d8d698989,9eb2d84f-c683-46fd-b93a-def8d294ca2b,a776c176-a748-4ce2-81b0-d2817998a72c,ed6ec807-2624-4a5a-9f90-6aea86d4fa8b,91b366bd-9fda-470d-99fa-9daae2309649,d8273d47-fb02-4186-aac8-9ca5e5541f2e,52357405-5abf-4f44-98ff-230d83a1da72,617ff669-f28b-49d1-8d4e-1d03aac4f140,1f2aa538-6e73-48e9-92b0-91ab71dd76aa,631925ee-0015-485f-b444-04e213626498,346f920b-88ea-4002-9f8c-54db78719db2,39913432-08d3-4da1-8101-76555b68789f,901eaa80-8900-46c4-820f-6f002be4a75d,44dabe5a-baf4-4f09-abf0-5fdc2d32a0e2,0b5f0817-9307-4039-a24b-2cad9cc12a35,3e4ea525-2149-4cf7-ac09-9c3085be3a07,907c9c8d-a368-4884-bbbd-04bfd8d150b8,cbc7a85d-71ac-44c7-baa8-1aa8f8287b9a,4ce9e2ef-41c9-44d4-9476-d83c495c093d,134c31cf-066e-4317-af88-173a7711068d,52130c99-6ddd-4199-99fc-1a9ced88011c,860c1fc9-5098-4d31-856f-94e217189509,225e280b-313c-45c5-ac01-002865223dfe,448025f6-abe6-42fa-8866-014b842f7785,603aab63-8553-47a4-a088-d2d1ce0ccd17,b1f34359-813c-454a-87d2-8be081eec7d0,e1d1e7b0-bd77-4a21-95bc-ed3972271996,c20cf417-98d4-41eb-8914-7e4e3f45fa83,b1948a83-dec1-4d5c-92ca-3909de974a5e,8dc11970-9511-4442-a739-3d999548678b,79fac420-1fdd-40d0-b324-11d7fdf6767b,eab51de4-7348-4b0e-9609-064e88015dea,b5a6e81f-c016-4964-8cc9-cd77e4ec8fa3,41a0acaa-dbdc-4719-9b7f-f796e1a8db5f,e8c100e6-f5c4-4839-97d9-0e7d7089985b,d00bf7f0-ff55-42bd-8b08-def20bb03915,4706a514-8c18-4c10-911a-ca041142edc2,c44fab2b-eb92-4719-9d96-23dfbfe38b22,6b73768d-7203-43eb-a59f-6730654649cd,2b101e61-141d-4d7f-b4c2-196138cf5fb2,3f5b9d22-6edf-4b2b-a7e7-2b634e259061,234ce33d-2f3e-44da-bb27-cb3c7539c50f,236c5edc-9fb2-4134-b848-7df9910ee107,4b3fd082-8394-4ecc-afda-a36b07d05658,19e6c77e-9cfc-4eec-99c4-afdb0ba05ca5,0bd7afbd-dcc0-410b-bde1-5355b8cb277f,f43d91bf-4188-4d97-8011-e759b608a2e2,f606aac2-ea93-4afb-894f-6c4fa67e6b05,24c0e56f-d2c6-4418-ae77-a82a0b94ee74,4c87010d-60fd-4686-8d7a-0b11ad5aa2d8,6d111269-ad5b-401e-a1b2-4819ba463ee6,49ac5214-08aa-4093-9790-8e3402278800,7e95694e-7ce3-4768-b194-baf73df330b4,6f0a35c2-8908-4c2d-9620-26945cada15f,e1f38048-f857-424d-bbec-4cfa15494f9c,6dff14d7-14d7-4232-9a97-e4b24b18a43c,e7f5bd3b-c6c0-40f2-8303-1977170cdd93,759721fb-6efd-4fa0-873f-994c91fafae6,cf3b2c91-ad6f-4dd1-8e75-00f30732f932,3ca8ae1a-6ccf-4d76-bbe9-913a8fc3cd5d,fa60a6d0-fec7-41af-b837-dc417b5e36a9,f6992e14-6260-4199-8666-6e9366738d82,ae44507d-e359-4e47-b783-a5b9ca68f0eb,1b7caef1-59fd-4b4a-aa70-42c2f635fe44,d465803b-1304-4d77-8002-5b7aedd3c83c,18cb2450-e0d6-41d9-87b7-d55e28876177,4290a514-cf7b-4347-b9af-e669fda9388f,224cfaf5-cd27-416f-a643-c1e7c7aa4d36,b6da5681-215c-4b93-b5f0-6e8f785b731b,25ec7bf5-1589-4329-b1f7-516f0f8d37a0,19ccfdd4-936b-41cd-b943-379ebb3eb295,982593d5-f7ce-4d9e-813b-41e6df2b0bef,9f75d35f-1455-4153-8056-423445f16fce,6b7a2340-d204-4c9a-a820-90576cb4732e,fad7afa2-b0be-4bfd-ad77-992dd800cac6,e568c7fc-715f-404d-b3ed-70048053b374,dfa449d1-1841-483a-9d3c-fae10a197a8e,ab80055d-216e-4731-926d-e2edebe712a0,1f71e2ec-348b-4269-9503-e39e1cc6db2c,a75f1685-75c9-46d3-a53d-c51b3c16eaef,f4dded80-a2f9-4297-8907-775b0136b46a,ca52fa50-abaa-4fd0-bb0d-ae75039e1cbb,cc8ba2b6-5eb6-4c30-a00d-d2a89b0ce831,fad720c6-cf79-47e3-a7dc-997ce0a4ca1c,c740ba7e-7386-4f2f-a462-c1d4778554e9,3bba5900-28d6-4761-ad6f-cfa430e73ebe,b51e5ec8-ad46-46b5-b689-d5e8a977463e,0ecbb69a-5327-4480-ab5b-8a34b5179a3a,d3b41295-7f1b-48e9-a96a-52043440d70b,338d8dcd-bd80-427d-8c4b-7cefaa73721f,8867a36b-758a-4c7e-ab60-1596edc4c28e,80d9a4aa-49ca-4e56-9af1-fa6d6157e28f,738590ae-23a1-4699-bc44-edbe819148d2,a1ae8350-1cd7-42bd-8999-4a5c1a275990,78416331-8465-4bc7-8067-af60abc59577,816a0061-1e82-44b0-8914-79a1931908fd,cf30506d-2b21-48ac-ab56-f21bdea377c6,461e205a-bb8a-4bdd-81fb-f8a21d854215,050c9a2a-afc8-4cf8-84d4-2c22be81abd0,a7474a47-2e26-491d-a7b9-b04b8138e571,3685e2c6-f04d-478e-87ed-12d8cc72939c,461daa81-404c-4000-b336-e406acefa007,bddb3fc5-93d3-4c42-a66d-96227a6e8f0f,49fe07e4-d291-4f8f-b4f9-0fc162ad8553,d9ca492d-8ac0-487a-8a2e-0644d67689e2,0e7b1d5f-a655-4b21-a3e9-37c113cfc52e,1e77e791-b572-49c5-96d7-14115d517329,bb8e0d8a-95dc-4430-a5de-bbedcd1d8fda,993ab2ec-b5b1-45ce-8e69-172067cd19a5,6b90fb4c-402a-49a3-95a2-75d1eb435bea,f0807419-d303-4100-8168-7fa61676df98,b1c543d3-0318-4e2d-bc4b-6212bc78941b,52ec6e64-8b1a-461b-a878-0c0c035dbbd4,01cdbfcd-5a74-450f-b9fa-69200db938c3,314c5e8f-d335-43b8-9d15-98ddd83054ac,98f61b5a-bb45-4b43-b6ac-d150779b2711,f29d26aa-a051-4d45-b580-7f49cc55ac8e,06124444-db56-443e-8025-1c2c369f8576,93402563-6af3-45ec-9de0-aede8c8fb6b0,d16e6125-c814-44cb-86d7-0eaaa8baa883,aed35f2e-37e1-442a-b518-86d99c84bcea,a772c84b-1fe5-43b3-8631-af02fd8450a1,87e60be5-0a87-45da-ad2f-f8266e80c18c,d254c27e-6371-48b8-96a2-4f5407502a92,a01b5c95-1c9e-4319-b48f-90743f87f68c,838997fc-c95f-428f-8c5c-30357c80a62a,93d31d40-3d8a-4907-89b2-12486ee52608,cdfddac8-993b-4063-a369-7e44a7d24b69,27cfb107-5cd9-4f06-9464-e31b0758e1a3,9f65ed34-7e3f-42fd-88dc-49989c66c493,59bfd3d6-e1bf-4233-8def-1f648b4c045e,f69b2d12-2038-41a9-b416-d3c480736f5b,7452052d-1c3d-4aa8-8fcd-e58556513248,6dc0f00b-5ebd-4b0e-b639-2168d0bea3ce,42ed3074-0269-4669-9f60-ed38853ba85a,454c4c4e-a9c0-4349-9861-1d2394b1c495,0c357720-5066-4fd6-a7d7-64dde5fcb0c2,e9c58f65-779c-4040-94a0-db21a41f3a7a,9b17131f-11a6-4ea3-a6bb-38b56357e858,c619a5da-b633-425a-92b2-34cb831fd662,3ecc6897-3b48-4930-b659-d597c69c83bc,004f4b76-a500-47d3-a015-235e0717205b}	in_progress	2026-04-28 07:39:37.830219+00	\N	\N	\N	\N	admission_test
bf130cc3-2254-4ad4-a900-3560e173d1c8	eccc1ab0-dea0-4422-953d-3a820e512907	subject_quiz	untimed	\N	physics	\N	\N	{8af36a16-997a-4f49-8622-77c5f80334df,66e563db-29f8-4f21-8537-c0127e5e63cc,0d3a863f-1bdc-4700-9fde-50a6789967a6,46017748-34b0-4df2-ba25-ae8a35202fd9,6ebea734-46a1-4bc7-9949-cfd2128f81e9,e7e5c15d-593a-41f6-a631-17cee6c3d6e2,cf3e3677-791a-4595-acca-dbdb0f4d2908,14e7bcbb-c2f7-48bc-aa90-74c03999d9e7,e92084ad-292d-4840-abe3-026cbdede660,d0ff282d-2b31-4f6d-a72b-f0e522b93a60,d8122c72-6c11-4278-835b-9d1e6df1a3c8,0d6a324b-4f00-466e-9db4-a00dca497c99,cda0ca18-8820-4020-ad75-1a93511536b3,80f911b3-a969-481c-bb8d-6920cf9cb4c3,8348307d-6f89-4ee2-bcee-97ba4e2a32f8,fa4ff435-2391-4047-b44c-f685d53e9f55,08a035f1-feef-4d5b-8017-ef1773ce0f4d,73c1c74d-b66f-4759-8fe1-c9a414e37872,75a24797-7a12-4fab-a527-e72c1d201203,9c09af5e-a1c7-4691-9711-b9cd745d9753,001777f1-ddfd-4c1d-9f39-0f7ea9489952,ff1a1634-1cba-4dfd-a821-3c681b5fd44e,73b59855-deaa-4f41-9913-5a53a9111826,cb3208dc-39aa-44b3-8625-60ee6507cbf3,2a7dc3da-9520-4108-929c-a14782e25c36,4599acb3-9d78-4bf9-8c9b-47bc3b7756d6,0d9953e6-403e-4dfe-8d1b-81061084d971,c7cb926c-cb05-4342-86c3-3c23a8749ebf,b7a602a2-e595-4a46-8aca-637cb75a3eee,854a05d3-849b-4dd9-a522-4b7c9d192a45,28c07dfe-cb42-44d4-9f2f-dda64ffb6882,38286d3b-99a2-4122-b821-87eb0a236eca,ba844b10-8d58-4186-9c14-2cdced4aaeae,70b8f220-c374-4587-bcb2-12f7e2fa0bf7,011f55e3-6770-4d47-9e46-3b8cd0e83955,a573f0bf-6d03-49fe-bb60-accbb25272cb,1b88a88c-cb2d-4184-a5e0-de08129088a2,38f811fb-1c5b-48db-878a-e7492dac0d62,fcb4d325-5f11-4166-ba6e-0c718d6b8936,1cba308b-e030-438f-bf35-8632f38605e8,dc146fec-8cb1-4a88-9c45-440587c8f124,d3ccca49-10b5-4f46-ac64-eb70abeb097a,af038b7c-e600-4d33-8155-21719ce50014,6b8b0d2e-4b91-4511-9acf-a2f4c0fce4e9,87a00d9d-0b71-46a9-a5b5-dab32ffe2472,98043387-e7c4-4277-99f0-6815949e7288,057d9d16-3096-49a9-9332-91786e8f7fde,61ea3a53-6193-49d9-a68a-80213ce57a55,5679a8f3-dad5-48c3-8057-6caa1fbd2683,ecfc3df5-ed6a-44f4-9485-2c29f731aa0b,fb75ef93-d920-4f94-81ea-1d9ff5b08784,568b2bc9-9a19-44c0-8b8b-8d0045475282,a360f901-de88-4d26-8f31-c16713d3b6da,bd780c4e-1e12-4891-a7a0-e6a61eed1456,f1859d7a-e0a7-4fd0-b9c8-a04f01ee9d2a,2e1e2c65-8558-43dd-afec-c2d333b2aa14,ac6f50f6-6eab-41d1-833d-6740b87c9175,b8015bab-db1a-45e5-9320-352d8d698989,9eb2d84f-c683-46fd-b93a-def8d294ca2b,a776c176-a748-4ce2-81b0-d2817998a72c,ed6ec807-2624-4a5a-9f90-6aea86d4fa8b,91b366bd-9fda-470d-99fa-9daae2309649,d8273d47-fb02-4186-aac8-9ca5e5541f2e,52357405-5abf-4f44-98ff-230d83a1da72,617ff669-f28b-49d1-8d4e-1d03aac4f140,1f2aa538-6e73-48e9-92b0-91ab71dd76aa,631925ee-0015-485f-b444-04e213626498,346f920b-88ea-4002-9f8c-54db78719db2,39913432-08d3-4da1-8101-76555b68789f,901eaa80-8900-46c4-820f-6f002be4a75d,44dabe5a-baf4-4f09-abf0-5fdc2d32a0e2,0b5f0817-9307-4039-a24b-2cad9cc12a35,3e4ea525-2149-4cf7-ac09-9c3085be3a07,907c9c8d-a368-4884-bbbd-04bfd8d150b8,cbc7a85d-71ac-44c7-baa8-1aa8f8287b9a,4ce9e2ef-41c9-44d4-9476-d83c495c093d,134c31cf-066e-4317-af88-173a7711068d,52130c99-6ddd-4199-99fc-1a9ced88011c,860c1fc9-5098-4d31-856f-94e217189509,225e280b-313c-45c5-ac01-002865223dfe,448025f6-abe6-42fa-8866-014b842f7785,603aab63-8553-47a4-a088-d2d1ce0ccd17,b1f34359-813c-454a-87d2-8be081eec7d0,e1d1e7b0-bd77-4a21-95bc-ed3972271996,c20cf417-98d4-41eb-8914-7e4e3f45fa83,b1948a83-dec1-4d5c-92ca-3909de974a5e,8dc11970-9511-4442-a739-3d999548678b,79fac420-1fdd-40d0-b324-11d7fdf6767b,eab51de4-7348-4b0e-9609-064e88015dea,b5a6e81f-c016-4964-8cc9-cd77e4ec8fa3,41a0acaa-dbdc-4719-9b7f-f796e1a8db5f,e8c100e6-f5c4-4839-97d9-0e7d7089985b,d00bf7f0-ff55-42bd-8b08-def20bb03915,4706a514-8c18-4c10-911a-ca041142edc2,c44fab2b-eb92-4719-9d96-23dfbfe38b22,6b73768d-7203-43eb-a59f-6730654649cd,2b101e61-141d-4d7f-b4c2-196138cf5fb2,3f5b9d22-6edf-4b2b-a7e7-2b634e259061,234ce33d-2f3e-44da-bb27-cb3c7539c50f,236c5edc-9fb2-4134-b848-7df9910ee107,4b3fd082-8394-4ecc-afda-a36b07d05658,19e6c77e-9cfc-4eec-99c4-afdb0ba05ca5,0bd7afbd-dcc0-410b-bde1-5355b8cb277f,f43d91bf-4188-4d97-8011-e759b608a2e2,f606aac2-ea93-4afb-894f-6c4fa67e6b05,24c0e56f-d2c6-4418-ae77-a82a0b94ee74,4c87010d-60fd-4686-8d7a-0b11ad5aa2d8,6d111269-ad5b-401e-a1b2-4819ba463ee6,49ac5214-08aa-4093-9790-8e3402278800,7e95694e-7ce3-4768-b194-baf73df330b4,6f0a35c2-8908-4c2d-9620-26945cada15f,e1f38048-f857-424d-bbec-4cfa15494f9c,6dff14d7-14d7-4232-9a97-e4b24b18a43c,e7f5bd3b-c6c0-40f2-8303-1977170cdd93,759721fb-6efd-4fa0-873f-994c91fafae6,cf3b2c91-ad6f-4dd1-8e75-00f30732f932,3ca8ae1a-6ccf-4d76-bbe9-913a8fc3cd5d,fa60a6d0-fec7-41af-b837-dc417b5e36a9,f6992e14-6260-4199-8666-6e9366738d82,ae44507d-e359-4e47-b783-a5b9ca68f0eb,1b7caef1-59fd-4b4a-aa70-42c2f635fe44,d465803b-1304-4d77-8002-5b7aedd3c83c,18cb2450-e0d6-41d9-87b7-d55e28876177,4290a514-cf7b-4347-b9af-e669fda9388f,224cfaf5-cd27-416f-a643-c1e7c7aa4d36,b6da5681-215c-4b93-b5f0-6e8f785b731b,25ec7bf5-1589-4329-b1f7-516f0f8d37a0,19ccfdd4-936b-41cd-b943-379ebb3eb295,982593d5-f7ce-4d9e-813b-41e6df2b0bef,9f75d35f-1455-4153-8056-423445f16fce,6b7a2340-d204-4c9a-a820-90576cb4732e,fad7afa2-b0be-4bfd-ad77-992dd800cac6,e568c7fc-715f-404d-b3ed-70048053b374,dfa449d1-1841-483a-9d3c-fae10a197a8e,ab80055d-216e-4731-926d-e2edebe712a0,1f71e2ec-348b-4269-9503-e39e1cc6db2c,a75f1685-75c9-46d3-a53d-c51b3c16eaef,f4dded80-a2f9-4297-8907-775b0136b46a,ca52fa50-abaa-4fd0-bb0d-ae75039e1cbb,cc8ba2b6-5eb6-4c30-a00d-d2a89b0ce831,fad720c6-cf79-47e3-a7dc-997ce0a4ca1c,c740ba7e-7386-4f2f-a462-c1d4778554e9,3bba5900-28d6-4761-ad6f-cfa430e73ebe,b51e5ec8-ad46-46b5-b689-d5e8a977463e,0ecbb69a-5327-4480-ab5b-8a34b5179a3a,d3b41295-7f1b-48e9-a96a-52043440d70b,338d8dcd-bd80-427d-8c4b-7cefaa73721f,8867a36b-758a-4c7e-ab60-1596edc4c28e,80d9a4aa-49ca-4e56-9af1-fa6d6157e28f,738590ae-23a1-4699-bc44-edbe819148d2,a1ae8350-1cd7-42bd-8999-4a5c1a275990,78416331-8465-4bc7-8067-af60abc59577,816a0061-1e82-44b0-8914-79a1931908fd,cf30506d-2b21-48ac-ab56-f21bdea377c6,461e205a-bb8a-4bdd-81fb-f8a21d854215,050c9a2a-afc8-4cf8-84d4-2c22be81abd0,a7474a47-2e26-491d-a7b9-b04b8138e571,3685e2c6-f04d-478e-87ed-12d8cc72939c,461daa81-404c-4000-b336-e406acefa007,bddb3fc5-93d3-4c42-a66d-96227a6e8f0f,49fe07e4-d291-4f8f-b4f9-0fc162ad8553,d9ca492d-8ac0-487a-8a2e-0644d67689e2,0e7b1d5f-a655-4b21-a3e9-37c113cfc52e,1e77e791-b572-49c5-96d7-14115d517329,bb8e0d8a-95dc-4430-a5de-bbedcd1d8fda,993ab2ec-b5b1-45ce-8e69-172067cd19a5,6b90fb4c-402a-49a3-95a2-75d1eb435bea,f0807419-d303-4100-8168-7fa61676df98,b1c543d3-0318-4e2d-bc4b-6212bc78941b,52ec6e64-8b1a-461b-a878-0c0c035dbbd4,01cdbfcd-5a74-450f-b9fa-69200db938c3,314c5e8f-d335-43b8-9d15-98ddd83054ac,98f61b5a-bb45-4b43-b6ac-d150779b2711,f29d26aa-a051-4d45-b580-7f49cc55ac8e,06124444-db56-443e-8025-1c2c369f8576,93402563-6af3-45ec-9de0-aede8c8fb6b0,d16e6125-c814-44cb-86d7-0eaaa8baa883,aed35f2e-37e1-442a-b518-86d99c84bcea,a772c84b-1fe5-43b3-8631-af02fd8450a1,87e60be5-0a87-45da-ad2f-f8266e80c18c,d254c27e-6371-48b8-96a2-4f5407502a92,a01b5c95-1c9e-4319-b48f-90743f87f68c,838997fc-c95f-428f-8c5c-30357c80a62a,93d31d40-3d8a-4907-89b2-12486ee52608,cdfddac8-993b-4063-a369-7e44a7d24b69,27cfb107-5cd9-4f06-9464-e31b0758e1a3,9f65ed34-7e3f-42fd-88dc-49989c66c493,59bfd3d6-e1bf-4233-8def-1f648b4c045e,f69b2d12-2038-41a9-b416-d3c480736f5b,7452052d-1c3d-4aa8-8fcd-e58556513248,6dc0f00b-5ebd-4b0e-b639-2168d0bea3ce,42ed3074-0269-4669-9f60-ed38853ba85a,454c4c4e-a9c0-4349-9861-1d2394b1c495,0c357720-5066-4fd6-a7d7-64dde5fcb0c2,e9c58f65-779c-4040-94a0-db21a41f3a7a,9b17131f-11a6-4ea3-a6bb-38b56357e858,c619a5da-b633-425a-92b2-34cb831fd662,3ecc6897-3b48-4930-b659-d597c69c83bc,004f4b76-a500-47d3-a015-235e0717205b}	submitted	2026-04-28 07:43:05.18082+00	2026-04-28 07:44:08.204306+00	3	199	63	admission_test
21e4ab53-b829-4480-935e-88c81c79b3a7	eccc1ab0-dea0-4422-953d-3a820e512907	subject_quiz	untimed	\N	mathematics	\N	\N	{3c8324f4-f243-40a5-9cf7-c8f0400442c9,02f9760b-6ba8-4014-95b2-2fd38671158c,850faec6-68af-49ef-83ad-e98c2046befd,80c5c9d7-d501-420c-a2a1-c1922ab19807,0e6f388d-33a0-4f0a-88e4-3e5b6f56072e,87282edf-d675-42ea-8f03-ec8e09031ebf,a6db028f-0764-4dc6-a95c-ccc4231cccac,eb443241-a0e6-419c-9b43-9c2b638a0d79,14bc131c-3a3c-496c-947c-029d7c7f9c86,16e61ff3-b78f-4f50-bfba-1ffb10761b16,cc1a8a38-da4b-4ffb-bead-d9293e2a321a,ae85c7fb-3043-4f6c-93bb-593346503a90,62b45fa3-5a84-4c32-84a5-c2bd8fbf7309,91207fa5-34c4-4ff7-b892-2b63c864520d,a9f9c912-74a4-4991-8001-6116bb741fe4,d8efe0db-6cfa-4e4c-b111-c7fe8248c4bc,00a8153e-8901-4f13-8ded-a2f2e4e13ffe,64013a8d-e3f5-4db2-94af-1521227c85f1,73025035-d12c-4dd3-a548-a066ef26a300,14495dd6-f4c8-48c2-9cea-e1f1c93b92a8,76343b23-ae51-4c07-9734-a17b5fb17fa4,e6e0e1ce-ab24-457e-b0be-f8e99c2b867a,8a09e10c-661b-4dc2-b8f3-aa7caa3b4491,1b0029c4-1cbe-42bf-8d58-65f2ca53bfd1,a6075742-074a-4d3f-a10c-27b235d9a593,09bf3bd8-4f02-4106-a93f-d2d6aa6b5f65,fb6587ae-24ad-466c-985f-4cb2e66f89db,bbb69845-aa2e-4916-9c8d-ddb06a72b002,dc71a03f-b7c0-4e24-b019-2104aeda7e06,94d6936a-6e54-46fc-88a2-0f7b1a95d577,8ca720b4-8d46-40a9-85b9-71a1f611773c,f3fd98df-40b0-4dc2-a6b7-423b3130671c,7d7ecf56-2a4c-4c75-821e-a8442b60bd53,5a5757fc-54ec-42c9-8c7d-9e79e2b779ec,c2c3a64e-b2cb-4256-b8dc-fb6b1f66ed03,6ca4ca64-aa11-49a8-b740-f4aa541d150e,cfc4d4f2-7399-4d28-a66d-32cad02fe053,8442c1ae-8af4-4f4c-bf2e-2e1c677651cb,ae335f47-e605-48a0-8fbf-eb4e8986f137,19108d8a-6555-46b1-9f75-d93b8fd0e4c6,244f8058-cb97-45c0-b78e-4b2393795704,ef9f39c1-8a27-4472-a265-1705ec549c3a,a9253795-0981-4530-836a-7708a2ae0b45,1434f64d-6b43-45c0-ab47-b89cad8465cc,6cfffde6-51cf-41b4-a4d4-c71e22c23870,e4a4312d-9b7e-4862-a29f-2de94713cc60,d956b3b2-c375-457c-b36d-d7e5eda157db,5b085180-8d95-4faa-b246-1baa9dc2dc92,fa5859ec-2974-4fb0-a78e-381edc86ba1b,a87b01e9-3ec3-41cf-92da-517b413d3aa6,c34aa487-10b3-401a-9571-d771f69d09d8,462f083c-d6dc-4988-9632-c59710763f0a,e118b659-ae11-4fc2-872b-ea9b90b39e9c,53a06aa2-abf8-40e7-a48a-fe5ed88a006f,481d86de-d333-486b-af5a-9a1bd481a2f7,cc0fdd4f-8c40-40bf-8baf-57fa71daf654,47a2db81-bbd5-4f67-bd3d-1e0423644fb0,b107e72d-5b35-48a9-844e-8debf4367482,06d590b9-a4b4-435d-80d2-e00892d57ee2,5b4a15e7-8b68-40a7-a5c1-9100079ec87e,06d698e8-232a-49ee-8128-f63ac88d04d2,b89d5282-f81b-43c3-8741-614a877c86ad,bc22adfe-a7ce-4ce7-b7b1-4b77be764eda,5ffa9e49-ab9b-4f56-8ae1-82f03898b371,87e9fd93-2808-42fd-b422-83f211bb7322,338edf0f-8f39-40d2-8b1e-71461be5d206,d9196d07-6259-4a68-9f98-a502a20080f1,3ff2320b-449f-4642-a3b2-44b42845af9f,dfe2f375-038e-404b-84c8-d180703d4066,729b8f97-7237-4a56-b3c1-32b088e0d05e,1fbc98e0-4c41-4d0b-bcf3-b78ba3170441,6fb6e116-0fd3-471d-ba3c-ba45510a024b,b719be80-d9d9-4ab9-ac30-4f9ffb9e75f4,9e4a4db0-6a84-4fe2-85eb-8d61c4eadd4d,bb5e6ca7-1c67-4954-8b43-e6664aca219b,23ba8888-8e6d-4dd8-8c37-f448819ee2ca,d731f844-7267-4331-8e61-e9b3d4f84248,2518e0e8-9206-4450-b11a-13117a8ad1e1,a958569f-32fe-46d5-9bd9-676fa92f39ba,d9c63a71-5c7c-46cc-bfbb-80c8d08a6aef,a71e6d04-65d2-4501-b36e-e3972c5433c6,ab674125-266b-4810-820d-51e01d9e9fa3,d119de1c-67bf-4122-b253-4faa9095dc9f,5c4c5cde-9543-4cf7-af80-2549ff637522,3cf007c0-fbd8-4f56-b9c8-b8057934c194,9756187f-492e-469e-8a23-5440b02e118d,ce6762bd-9ad2-4110-bd59-4b014abe8a95,684ae4f8-35a7-4cae-9b36-d6a5e6b5ecad,88055b7b-1d2a-4214-8b2f-764bf18631fd,d6a54fcb-9063-4b1e-9ea6-d7af276a9e3d,059f3416-8a2a-4f39-b02d-8c91930a3182,278a11e6-e51a-4147-ab85-5b33145c4b4f,e73a39b5-852e-4ff6-941c-17bf84b210d2,dca56350-0ec7-480f-841f-3d0b0d098135,c77902b3-6550-4c6d-a2cd-3aa4f40423f9,12134285-1e26-45a8-b59f-6cda2798a7fc,858d0097-93f9-4bac-87dd-2d101bbd68bf,6a27ed3e-e0af-40ab-b3d8-a064753c7ebe,ecde36b4-4d95-4b69-b86b-952c1723f834,36cf314e-7f2e-4dbb-9f51-3b44b39668a9,717a93bf-59cc-4db8-b817-682d44652d82,e3d860a5-7343-43e8-bcb8-ce5805debcf7,b1451d45-98c4-44d3-bdce-3992225e8481,b324d53d-259a-4afa-bc37-3d7dc876cda4,e67dc779-dc77-43b4-b0ce-c4894489103e,69a58ffa-5f06-43ad-9351-93fcac89a144,235b4eb3-fa4e-4e55-a04b-7eb052aecf74,f7308d4e-842c-48a5-ab56-13e3c775a9bf,3b282d93-6894-4dd4-be9a-097db02400fa,3c7cac49-945e-475a-bcec-dd9baa98e4b4,d422abd4-872c-408d-ac31-d32d55b374ea,085a79c7-14c3-4218-962f-e64b04e1c576,53fb9947-7274-403a-9a29-feb6843d137c,37460786-8f6a-4562-a11d-a167c6305daf,e3496790-8253-4d55-ac02-c62789a3aa79,50eca9d6-a660-49f4-886e-21ef757b589b,d8b127a1-4e4c-4125-a55f-2b39cec54c6f,8c9b0948-331e-4bf9-b380-79f3b91f4035,35a4c577-4532-465c-9034-2e13b7aab087,642ceec3-d1b1-44da-9724-05d0c03df45b,e089d5d2-bb03-4471-86c2-2c3407530f61,30e4f9fd-92bf-491e-a45e-5f8bd63ff00a,c04c6ea0-7ee3-4e5a-85dc-b72c7f6f3020,f1de21b5-a199-45b1-8c93-94c0a1fab0e2,d6a74f81-a1f0-4490-8734-6a72f92fc963,ca7ca25e-f07d-423d-9b1e-5fa91a2bf578,c58cb579-ea91-40a0-9671-5caff7d789c3,2a8fa087-27d8-453d-93bc-340a8fd2942e,e22a26cf-e7ce-464b-b19c-7fe1766f7c72,2a38065a-9145-4fec-a7d9-01b7f1c55f82,d7f81656-4ebe-4f48-8eb2-571d40e72f47,a7efeae1-ef25-439a-aab0-fd931154652f,3556bbed-9cac-4f0c-b691-187f29028fa5,dedf970c-bc28-42e4-97a9-e40fc3b52910,6a905554-2dd1-4a7c-a500-bd9e825e1c4f,be3b4e34-7d71-43a8-9a9a-12a60e7bdbd9,2577e578-d372-4932-b1f1-a963c8261dd1,96b1335d-6f4e-4999-897e-e9b5497af568,a939077d-db2a-4f99-82ed-b8fa8d7f9e5d,da7a4805-ff0e-4d85-8208-2a919d682dc1,f03efe1d-a96d-45db-ad85-9a0ef8dad3e7,723ea36f-88d0-4670-befb-326b583f045b,9b7cbbe1-1c92-4bd9-b792-34480ccd831c,fcbfeb79-7f9b-4168-a154-8268ad3ffaaf,4592e698-0afb-4d68-9d5b-4ff5996e72c0,9ad62dcb-36f2-4724-a79f-8a405e26a116,72f0d0eb-9f06-46e9-b116-dc9b59c32680,03afcf27-cabb-4a4b-80d8-abfd1ee920ca,da1e1550-a9a6-43e8-94e1-8581937d1d94,5e0e6008-65cb-4a3f-9135-33ca1bbef1ee,25d93e66-2e35-4311-a08a-e1daf77f5cd5,9bc067b9-4270-4234-8748-7386739d0d7f,84dc9e5e-4d44-4a78-ab10-fd9be21b5286,5de2a6c8-5daf-4557-a702-ad17cef4807f,78918a2f-7419-4c4e-89d9-cf193ad6d3b9,d8bd851c-e716-4bc4-93e0-365b13791941,0d5eb94e-46e9-4e0a-9b5c-9795b00a3a2b,4bf22e12-a335-4efa-9b66-8dd4cf2db6d7,e9e5918b-87d8-40d3-821b-8026e321680f,90f4458e-db6a-42a5-974f-e7838ff95383,280db66c-4465-492b-be96-2df7528ac624,2bff07da-b0ce-4a86-8516-089b41c61b98,91f2907b-13de-4f68-89c3-26664aff072b,822237e1-862f-4d85-aa99-278dca464bcc,360baecf-34a7-437c-8c7f-c5b3d1d8b27d,40b17b5e-c209-4c7b-9fe0-acb9ed1a0c48,41cd39b1-ca7d-4575-b95c-fc839dc20cdf,4d48eb67-9224-4cda-ada6-72237c81dc55,4fe12ae0-7d60-4acb-8993-3e1433dd7597,c334d74b-bcce-48df-9e88-ab997ad5e301,dc249b11-498d-4463-aab4-5802592894ce,21fe7e28-1459-4168-a6df-820046fccf0e,4baa74ca-84e2-4e87-bae8-96573878f24c,4c0d955d-1d07-4287-bf21-188b604a0255,6ab638f1-de68-40dc-8cbf-9d70d18aed9e,3a8afe71-35fc-4592-a122-8d83a713e9e2,e8bdfe3d-0799-4385-84a2-99e588b584f7,91e8a796-bdb3-4b28-8f5e-573eaf629d1e,494e26be-ddc6-46e8-8f85-02017a97a9a8,398cf02a-8e91-487f-99c4-9986f19e2b39,c92c73b1-0152-4405-a2fa-756266d65d68,8777f4e0-13a5-4fd6-aacb-5c1e3b268511,38645518-b89a-4c6d-a0fc-ba993b31f8aa,a5484c83-9534-4ac5-b60c-eb8ce222ccf6,2455d12f-d4c4-4f3b-9ccf-7896d751003c,1d109fae-1ac2-4f89-8067-e9ba7c36622d,5816d1c2-fe10-419f-97a9-c4b2995fe001,0b060917-e53b-4c70-8db2-389b2eaf1ecf,0bcd7650-c0f9-49fd-a011-7833c7b7bbd7,69ccb9cd-13f7-4e9a-acf2-88c246e38c07}	in_progress	2026-04-28 08:40:10.573306+00	\N	\N	\N	\N	admission_test
1ca4deb3-7b3d-4983-8c8c-b70d88eddcaf	eccc1ab0-dea0-4422-953d-3a820e512907	subject_quiz	untimed	\N	physics	\N	\N	{8af36a16-997a-4f49-8622-77c5f80334df,66e563db-29f8-4f21-8537-c0127e5e63cc,0d3a863f-1bdc-4700-9fde-50a6789967a6,46017748-34b0-4df2-ba25-ae8a35202fd9,6ebea734-46a1-4bc7-9949-cfd2128f81e9,e7e5c15d-593a-41f6-a631-17cee6c3d6e2,cf3e3677-791a-4595-acca-dbdb0f4d2908,14e7bcbb-c2f7-48bc-aa90-74c03999d9e7,e92084ad-292d-4840-abe3-026cbdede660,d0ff282d-2b31-4f6d-a72b-f0e522b93a60,d8122c72-6c11-4278-835b-9d1e6df1a3c8,0d6a324b-4f00-466e-9db4-a00dca497c99,cda0ca18-8820-4020-ad75-1a93511536b3,80f911b3-a969-481c-bb8d-6920cf9cb4c3,8348307d-6f89-4ee2-bcee-97ba4e2a32f8,fa4ff435-2391-4047-b44c-f685d53e9f55,08a035f1-feef-4d5b-8017-ef1773ce0f4d,73c1c74d-b66f-4759-8fe1-c9a414e37872,75a24797-7a12-4fab-a527-e72c1d201203,9c09af5e-a1c7-4691-9711-b9cd745d9753,001777f1-ddfd-4c1d-9f39-0f7ea9489952,ff1a1634-1cba-4dfd-a821-3c681b5fd44e,73b59855-deaa-4f41-9913-5a53a9111826,cb3208dc-39aa-44b3-8625-60ee6507cbf3,2a7dc3da-9520-4108-929c-a14782e25c36,4599acb3-9d78-4bf9-8c9b-47bc3b7756d6,0d9953e6-403e-4dfe-8d1b-81061084d971,c7cb926c-cb05-4342-86c3-3c23a8749ebf,b7a602a2-e595-4a46-8aca-637cb75a3eee,854a05d3-849b-4dd9-a522-4b7c9d192a45,28c07dfe-cb42-44d4-9f2f-dda64ffb6882,38286d3b-99a2-4122-b821-87eb0a236eca,ba844b10-8d58-4186-9c14-2cdced4aaeae,70b8f220-c374-4587-bcb2-12f7e2fa0bf7,011f55e3-6770-4d47-9e46-3b8cd0e83955,a573f0bf-6d03-49fe-bb60-accbb25272cb,1b88a88c-cb2d-4184-a5e0-de08129088a2,38f811fb-1c5b-48db-878a-e7492dac0d62,fcb4d325-5f11-4166-ba6e-0c718d6b8936,1cba308b-e030-438f-bf35-8632f38605e8,dc146fec-8cb1-4a88-9c45-440587c8f124,d3ccca49-10b5-4f46-ac64-eb70abeb097a,af038b7c-e600-4d33-8155-21719ce50014,6b8b0d2e-4b91-4511-9acf-a2f4c0fce4e9,87a00d9d-0b71-46a9-a5b5-dab32ffe2472,98043387-e7c4-4277-99f0-6815949e7288,057d9d16-3096-49a9-9332-91786e8f7fde,61ea3a53-6193-49d9-a68a-80213ce57a55,5679a8f3-dad5-48c3-8057-6caa1fbd2683,ecfc3df5-ed6a-44f4-9485-2c29f731aa0b,fb75ef93-d920-4f94-81ea-1d9ff5b08784,568b2bc9-9a19-44c0-8b8b-8d0045475282,a360f901-de88-4d26-8f31-c16713d3b6da,bd780c4e-1e12-4891-a7a0-e6a61eed1456,f1859d7a-e0a7-4fd0-b9c8-a04f01ee9d2a,2e1e2c65-8558-43dd-afec-c2d333b2aa14,ac6f50f6-6eab-41d1-833d-6740b87c9175,b8015bab-db1a-45e5-9320-352d8d698989,9eb2d84f-c683-46fd-b93a-def8d294ca2b,a776c176-a748-4ce2-81b0-d2817998a72c,ed6ec807-2624-4a5a-9f90-6aea86d4fa8b,91b366bd-9fda-470d-99fa-9daae2309649,d8273d47-fb02-4186-aac8-9ca5e5541f2e,52357405-5abf-4f44-98ff-230d83a1da72,617ff669-f28b-49d1-8d4e-1d03aac4f140,1f2aa538-6e73-48e9-92b0-91ab71dd76aa,631925ee-0015-485f-b444-04e213626498,346f920b-88ea-4002-9f8c-54db78719db2,39913432-08d3-4da1-8101-76555b68789f,901eaa80-8900-46c4-820f-6f002be4a75d,44dabe5a-baf4-4f09-abf0-5fdc2d32a0e2,0b5f0817-9307-4039-a24b-2cad9cc12a35,3e4ea525-2149-4cf7-ac09-9c3085be3a07,907c9c8d-a368-4884-bbbd-04bfd8d150b8,cbc7a85d-71ac-44c7-baa8-1aa8f8287b9a,4ce9e2ef-41c9-44d4-9476-d83c495c093d,134c31cf-066e-4317-af88-173a7711068d,52130c99-6ddd-4199-99fc-1a9ced88011c,860c1fc9-5098-4d31-856f-94e217189509,225e280b-313c-45c5-ac01-002865223dfe,448025f6-abe6-42fa-8866-014b842f7785,603aab63-8553-47a4-a088-d2d1ce0ccd17,b1f34359-813c-454a-87d2-8be081eec7d0,e1d1e7b0-bd77-4a21-95bc-ed3972271996,c20cf417-98d4-41eb-8914-7e4e3f45fa83,b1948a83-dec1-4d5c-92ca-3909de974a5e,8dc11970-9511-4442-a739-3d999548678b,79fac420-1fdd-40d0-b324-11d7fdf6767b,eab51de4-7348-4b0e-9609-064e88015dea,b5a6e81f-c016-4964-8cc9-cd77e4ec8fa3,41a0acaa-dbdc-4719-9b7f-f796e1a8db5f,e8c100e6-f5c4-4839-97d9-0e7d7089985b,d00bf7f0-ff55-42bd-8b08-def20bb03915,4706a514-8c18-4c10-911a-ca041142edc2,c44fab2b-eb92-4719-9d96-23dfbfe38b22,6b73768d-7203-43eb-a59f-6730654649cd,2b101e61-141d-4d7f-b4c2-196138cf5fb2,3f5b9d22-6edf-4b2b-a7e7-2b634e259061,234ce33d-2f3e-44da-bb27-cb3c7539c50f,236c5edc-9fb2-4134-b848-7df9910ee107,4b3fd082-8394-4ecc-afda-a36b07d05658,19e6c77e-9cfc-4eec-99c4-afdb0ba05ca5,0bd7afbd-dcc0-410b-bde1-5355b8cb277f,f43d91bf-4188-4d97-8011-e759b608a2e2,f606aac2-ea93-4afb-894f-6c4fa67e6b05,24c0e56f-d2c6-4418-ae77-a82a0b94ee74,4c87010d-60fd-4686-8d7a-0b11ad5aa2d8,6d111269-ad5b-401e-a1b2-4819ba463ee6,49ac5214-08aa-4093-9790-8e3402278800,7e95694e-7ce3-4768-b194-baf73df330b4,6f0a35c2-8908-4c2d-9620-26945cada15f,e1f38048-f857-424d-bbec-4cfa15494f9c,6dff14d7-14d7-4232-9a97-e4b24b18a43c,e7f5bd3b-c6c0-40f2-8303-1977170cdd93,759721fb-6efd-4fa0-873f-994c91fafae6,cf3b2c91-ad6f-4dd1-8e75-00f30732f932,3ca8ae1a-6ccf-4d76-bbe9-913a8fc3cd5d,fa60a6d0-fec7-41af-b837-dc417b5e36a9,f6992e14-6260-4199-8666-6e9366738d82,ae44507d-e359-4e47-b783-a5b9ca68f0eb,1b7caef1-59fd-4b4a-aa70-42c2f635fe44,d465803b-1304-4d77-8002-5b7aedd3c83c,18cb2450-e0d6-41d9-87b7-d55e28876177,4290a514-cf7b-4347-b9af-e669fda9388f,224cfaf5-cd27-416f-a643-c1e7c7aa4d36,b6da5681-215c-4b93-b5f0-6e8f785b731b,25ec7bf5-1589-4329-b1f7-516f0f8d37a0,19ccfdd4-936b-41cd-b943-379ebb3eb295,982593d5-f7ce-4d9e-813b-41e6df2b0bef,9f75d35f-1455-4153-8056-423445f16fce,6b7a2340-d204-4c9a-a820-90576cb4732e,fad7afa2-b0be-4bfd-ad77-992dd800cac6,e568c7fc-715f-404d-b3ed-70048053b374,dfa449d1-1841-483a-9d3c-fae10a197a8e,ab80055d-216e-4731-926d-e2edebe712a0,1f71e2ec-348b-4269-9503-e39e1cc6db2c,a75f1685-75c9-46d3-a53d-c51b3c16eaef,f4dded80-a2f9-4297-8907-775b0136b46a,ca52fa50-abaa-4fd0-bb0d-ae75039e1cbb,cc8ba2b6-5eb6-4c30-a00d-d2a89b0ce831,fad720c6-cf79-47e3-a7dc-997ce0a4ca1c,c740ba7e-7386-4f2f-a462-c1d4778554e9,3bba5900-28d6-4761-ad6f-cfa430e73ebe,b51e5ec8-ad46-46b5-b689-d5e8a977463e,0ecbb69a-5327-4480-ab5b-8a34b5179a3a,d3b41295-7f1b-48e9-a96a-52043440d70b,338d8dcd-bd80-427d-8c4b-7cefaa73721f,8867a36b-758a-4c7e-ab60-1596edc4c28e,80d9a4aa-49ca-4e56-9af1-fa6d6157e28f,738590ae-23a1-4699-bc44-edbe819148d2,a1ae8350-1cd7-42bd-8999-4a5c1a275990,78416331-8465-4bc7-8067-af60abc59577,816a0061-1e82-44b0-8914-79a1931908fd,cf30506d-2b21-48ac-ab56-f21bdea377c6,461e205a-bb8a-4bdd-81fb-f8a21d854215,050c9a2a-afc8-4cf8-84d4-2c22be81abd0,a7474a47-2e26-491d-a7b9-b04b8138e571,3685e2c6-f04d-478e-87ed-12d8cc72939c,461daa81-404c-4000-b336-e406acefa007,bddb3fc5-93d3-4c42-a66d-96227a6e8f0f,49fe07e4-d291-4f8f-b4f9-0fc162ad8553,d9ca492d-8ac0-487a-8a2e-0644d67689e2,0e7b1d5f-a655-4b21-a3e9-37c113cfc52e,1e77e791-b572-49c5-96d7-14115d517329,bb8e0d8a-95dc-4430-a5de-bbedcd1d8fda,993ab2ec-b5b1-45ce-8e69-172067cd19a5,6b90fb4c-402a-49a3-95a2-75d1eb435bea,f0807419-d303-4100-8168-7fa61676df98,b1c543d3-0318-4e2d-bc4b-6212bc78941b,52ec6e64-8b1a-461b-a878-0c0c035dbbd4,01cdbfcd-5a74-450f-b9fa-69200db938c3,314c5e8f-d335-43b8-9d15-98ddd83054ac,98f61b5a-bb45-4b43-b6ac-d150779b2711,f29d26aa-a051-4d45-b580-7f49cc55ac8e,06124444-db56-443e-8025-1c2c369f8576,93402563-6af3-45ec-9de0-aede8c8fb6b0,d16e6125-c814-44cb-86d7-0eaaa8baa883,aed35f2e-37e1-442a-b518-86d99c84bcea,a772c84b-1fe5-43b3-8631-af02fd8450a1,87e60be5-0a87-45da-ad2f-f8266e80c18c,d254c27e-6371-48b8-96a2-4f5407502a92,a01b5c95-1c9e-4319-b48f-90743f87f68c,838997fc-c95f-428f-8c5c-30357c80a62a,93d31d40-3d8a-4907-89b2-12486ee52608,cdfddac8-993b-4063-a369-7e44a7d24b69,27cfb107-5cd9-4f06-9464-e31b0758e1a3,9f65ed34-7e3f-42fd-88dc-49989c66c493,59bfd3d6-e1bf-4233-8def-1f648b4c045e,f69b2d12-2038-41a9-b416-d3c480736f5b,7452052d-1c3d-4aa8-8fcd-e58556513248,6dc0f00b-5ebd-4b0e-b639-2168d0bea3ce,42ed3074-0269-4669-9f60-ed38853ba85a,454c4c4e-a9c0-4349-9861-1d2394b1c495,0c357720-5066-4fd6-a7d7-64dde5fcb0c2,e9c58f65-779c-4040-94a0-db21a41f3a7a,9b17131f-11a6-4ea3-a6bb-38b56357e858,c619a5da-b633-425a-92b2-34cb831fd662,3ecc6897-3b48-4930-b659-d597c69c83bc,004f4b76-a500-47d3-a015-235e0717205b}	submitted	2026-04-28 09:21:24.123674+00	2026-04-28 12:14:33.196393+00	1	199	10389	admission_test
a3d35273-6851-4c00-96de-1bbf6dfc9257	7fdaa405-67d8-4a9f-818e-7d44ca123eb7	subject_quiz	untimed	\N	physics	\N	\N	{8af36a16-997a-4f49-8622-77c5f80334df,66e563db-29f8-4f21-8537-c0127e5e63cc,0d3a863f-1bdc-4700-9fde-50a6789967a6,46017748-34b0-4df2-ba25-ae8a35202fd9,6ebea734-46a1-4bc7-9949-cfd2128f81e9,e7e5c15d-593a-41f6-a631-17cee6c3d6e2,cf3e3677-791a-4595-acca-dbdb0f4d2908,14e7bcbb-c2f7-48bc-aa90-74c03999d9e7,e92084ad-292d-4840-abe3-026cbdede660,d0ff282d-2b31-4f6d-a72b-f0e522b93a60,d8122c72-6c11-4278-835b-9d1e6df1a3c8,0d6a324b-4f00-466e-9db4-a00dca497c99,cda0ca18-8820-4020-ad75-1a93511536b3,80f911b3-a969-481c-bb8d-6920cf9cb4c3,8348307d-6f89-4ee2-bcee-97ba4e2a32f8,fa4ff435-2391-4047-b44c-f685d53e9f55,08a035f1-feef-4d5b-8017-ef1773ce0f4d,73c1c74d-b66f-4759-8fe1-c9a414e37872,75a24797-7a12-4fab-a527-e72c1d201203,9c09af5e-a1c7-4691-9711-b9cd745d9753,001777f1-ddfd-4c1d-9f39-0f7ea9489952,ff1a1634-1cba-4dfd-a821-3c681b5fd44e,73b59855-deaa-4f41-9913-5a53a9111826,cb3208dc-39aa-44b3-8625-60ee6507cbf3,2a7dc3da-9520-4108-929c-a14782e25c36,4599acb3-9d78-4bf9-8c9b-47bc3b7756d6,0d9953e6-403e-4dfe-8d1b-81061084d971,c7cb926c-cb05-4342-86c3-3c23a8749ebf,b7a602a2-e595-4a46-8aca-637cb75a3eee,854a05d3-849b-4dd9-a522-4b7c9d192a45,28c07dfe-cb42-44d4-9f2f-dda64ffb6882,38286d3b-99a2-4122-b821-87eb0a236eca,ba844b10-8d58-4186-9c14-2cdced4aaeae,70b8f220-c374-4587-bcb2-12f7e2fa0bf7,011f55e3-6770-4d47-9e46-3b8cd0e83955,a573f0bf-6d03-49fe-bb60-accbb25272cb,1b88a88c-cb2d-4184-a5e0-de08129088a2,38f811fb-1c5b-48db-878a-e7492dac0d62,fcb4d325-5f11-4166-ba6e-0c718d6b8936,1cba308b-e030-438f-bf35-8632f38605e8,dc146fec-8cb1-4a88-9c45-440587c8f124,d3ccca49-10b5-4f46-ac64-eb70abeb097a,af038b7c-e600-4d33-8155-21719ce50014,6b8b0d2e-4b91-4511-9acf-a2f4c0fce4e9,87a00d9d-0b71-46a9-a5b5-dab32ffe2472,98043387-e7c4-4277-99f0-6815949e7288,057d9d16-3096-49a9-9332-91786e8f7fde,61ea3a53-6193-49d9-a68a-80213ce57a55,5679a8f3-dad5-48c3-8057-6caa1fbd2683,ecfc3df5-ed6a-44f4-9485-2c29f731aa0b,fb75ef93-d920-4f94-81ea-1d9ff5b08784,568b2bc9-9a19-44c0-8b8b-8d0045475282,a360f901-de88-4d26-8f31-c16713d3b6da,bd780c4e-1e12-4891-a7a0-e6a61eed1456,f1859d7a-e0a7-4fd0-b9c8-a04f01ee9d2a,2e1e2c65-8558-43dd-afec-c2d333b2aa14,ac6f50f6-6eab-41d1-833d-6740b87c9175,b8015bab-db1a-45e5-9320-352d8d698989,9eb2d84f-c683-46fd-b93a-def8d294ca2b,a776c176-a748-4ce2-81b0-d2817998a72c,ed6ec807-2624-4a5a-9f90-6aea86d4fa8b,91b366bd-9fda-470d-99fa-9daae2309649,d8273d47-fb02-4186-aac8-9ca5e5541f2e,52357405-5abf-4f44-98ff-230d83a1da72,617ff669-f28b-49d1-8d4e-1d03aac4f140,1f2aa538-6e73-48e9-92b0-91ab71dd76aa,631925ee-0015-485f-b444-04e213626498,346f920b-88ea-4002-9f8c-54db78719db2,39913432-08d3-4da1-8101-76555b68789f,901eaa80-8900-46c4-820f-6f002be4a75d,44dabe5a-baf4-4f09-abf0-5fdc2d32a0e2,0b5f0817-9307-4039-a24b-2cad9cc12a35,3e4ea525-2149-4cf7-ac09-9c3085be3a07,907c9c8d-a368-4884-bbbd-04bfd8d150b8,cbc7a85d-71ac-44c7-baa8-1aa8f8287b9a,4ce9e2ef-41c9-44d4-9476-d83c495c093d,134c31cf-066e-4317-af88-173a7711068d,52130c99-6ddd-4199-99fc-1a9ced88011c,860c1fc9-5098-4d31-856f-94e217189509,225e280b-313c-45c5-ac01-002865223dfe,448025f6-abe6-42fa-8866-014b842f7785,603aab63-8553-47a4-a088-d2d1ce0ccd17,b1f34359-813c-454a-87d2-8be081eec7d0,e1d1e7b0-bd77-4a21-95bc-ed3972271996,c20cf417-98d4-41eb-8914-7e4e3f45fa83,b1948a83-dec1-4d5c-92ca-3909de974a5e,8dc11970-9511-4442-a739-3d999548678b,79fac420-1fdd-40d0-b324-11d7fdf6767b,eab51de4-7348-4b0e-9609-064e88015dea,b5a6e81f-c016-4964-8cc9-cd77e4ec8fa3,41a0acaa-dbdc-4719-9b7f-f796e1a8db5f,e8c100e6-f5c4-4839-97d9-0e7d7089985b,d00bf7f0-ff55-42bd-8b08-def20bb03915,4706a514-8c18-4c10-911a-ca041142edc2,c44fab2b-eb92-4719-9d96-23dfbfe38b22,6b73768d-7203-43eb-a59f-6730654649cd,2b101e61-141d-4d7f-b4c2-196138cf5fb2,3f5b9d22-6edf-4b2b-a7e7-2b634e259061,234ce33d-2f3e-44da-bb27-cb3c7539c50f,236c5edc-9fb2-4134-b848-7df9910ee107,4b3fd082-8394-4ecc-afda-a36b07d05658,19e6c77e-9cfc-4eec-99c4-afdb0ba05ca5,0bd7afbd-dcc0-410b-bde1-5355b8cb277f,f43d91bf-4188-4d97-8011-e759b608a2e2,f606aac2-ea93-4afb-894f-6c4fa67e6b05,24c0e56f-d2c6-4418-ae77-a82a0b94ee74,4c87010d-60fd-4686-8d7a-0b11ad5aa2d8,6d111269-ad5b-401e-a1b2-4819ba463ee6,49ac5214-08aa-4093-9790-8e3402278800,7e95694e-7ce3-4768-b194-baf73df330b4,6f0a35c2-8908-4c2d-9620-26945cada15f,e1f38048-f857-424d-bbec-4cfa15494f9c,6dff14d7-14d7-4232-9a97-e4b24b18a43c,e7f5bd3b-c6c0-40f2-8303-1977170cdd93,759721fb-6efd-4fa0-873f-994c91fafae6,cf3b2c91-ad6f-4dd1-8e75-00f30732f932,3ca8ae1a-6ccf-4d76-bbe9-913a8fc3cd5d,fa60a6d0-fec7-41af-b837-dc417b5e36a9,f6992e14-6260-4199-8666-6e9366738d82,ae44507d-e359-4e47-b783-a5b9ca68f0eb,1b7caef1-59fd-4b4a-aa70-42c2f635fe44,d465803b-1304-4d77-8002-5b7aedd3c83c,18cb2450-e0d6-41d9-87b7-d55e28876177,4290a514-cf7b-4347-b9af-e669fda9388f,224cfaf5-cd27-416f-a643-c1e7c7aa4d36,b6da5681-215c-4b93-b5f0-6e8f785b731b,25ec7bf5-1589-4329-b1f7-516f0f8d37a0,19ccfdd4-936b-41cd-b943-379ebb3eb295,982593d5-f7ce-4d9e-813b-41e6df2b0bef,9f75d35f-1455-4153-8056-423445f16fce,6b7a2340-d204-4c9a-a820-90576cb4732e,fad7afa2-b0be-4bfd-ad77-992dd800cac6,e568c7fc-715f-404d-b3ed-70048053b374,dfa449d1-1841-483a-9d3c-fae10a197a8e,ab80055d-216e-4731-926d-e2edebe712a0,1f71e2ec-348b-4269-9503-e39e1cc6db2c,a75f1685-75c9-46d3-a53d-c51b3c16eaef,f4dded80-a2f9-4297-8907-775b0136b46a,ca52fa50-abaa-4fd0-bb0d-ae75039e1cbb,cc8ba2b6-5eb6-4c30-a00d-d2a89b0ce831,fad720c6-cf79-47e3-a7dc-997ce0a4ca1c,c740ba7e-7386-4f2f-a462-c1d4778554e9,3bba5900-28d6-4761-ad6f-cfa430e73ebe,b51e5ec8-ad46-46b5-b689-d5e8a977463e,0ecbb69a-5327-4480-ab5b-8a34b5179a3a,d3b41295-7f1b-48e9-a96a-52043440d70b,338d8dcd-bd80-427d-8c4b-7cefaa73721f,8867a36b-758a-4c7e-ab60-1596edc4c28e,80d9a4aa-49ca-4e56-9af1-fa6d6157e28f,738590ae-23a1-4699-bc44-edbe819148d2,a1ae8350-1cd7-42bd-8999-4a5c1a275990,78416331-8465-4bc7-8067-af60abc59577,816a0061-1e82-44b0-8914-79a1931908fd,cf30506d-2b21-48ac-ab56-f21bdea377c6,461e205a-bb8a-4bdd-81fb-f8a21d854215,050c9a2a-afc8-4cf8-84d4-2c22be81abd0,a7474a47-2e26-491d-a7b9-b04b8138e571,3685e2c6-f04d-478e-87ed-12d8cc72939c,461daa81-404c-4000-b336-e406acefa007,bddb3fc5-93d3-4c42-a66d-96227a6e8f0f,49fe07e4-d291-4f8f-b4f9-0fc162ad8553,d9ca492d-8ac0-487a-8a2e-0644d67689e2,0e7b1d5f-a655-4b21-a3e9-37c113cfc52e,1e77e791-b572-49c5-96d7-14115d517329,bb8e0d8a-95dc-4430-a5de-bbedcd1d8fda,993ab2ec-b5b1-45ce-8e69-172067cd19a5,6b90fb4c-402a-49a3-95a2-75d1eb435bea,f0807419-d303-4100-8168-7fa61676df98,b1c543d3-0318-4e2d-bc4b-6212bc78941b,52ec6e64-8b1a-461b-a878-0c0c035dbbd4,01cdbfcd-5a74-450f-b9fa-69200db938c3,314c5e8f-d335-43b8-9d15-98ddd83054ac,98f61b5a-bb45-4b43-b6ac-d150779b2711,f29d26aa-a051-4d45-b580-7f49cc55ac8e,06124444-db56-443e-8025-1c2c369f8576,93402563-6af3-45ec-9de0-aede8c8fb6b0,d16e6125-c814-44cb-86d7-0eaaa8baa883,aed35f2e-37e1-442a-b518-86d99c84bcea,a772c84b-1fe5-43b3-8631-af02fd8450a1,87e60be5-0a87-45da-ad2f-f8266e80c18c,d254c27e-6371-48b8-96a2-4f5407502a92,a01b5c95-1c9e-4319-b48f-90743f87f68c,838997fc-c95f-428f-8c5c-30357c80a62a,93d31d40-3d8a-4907-89b2-12486ee52608,cdfddac8-993b-4063-a369-7e44a7d24b69,27cfb107-5cd9-4f06-9464-e31b0758e1a3,9f65ed34-7e3f-42fd-88dc-49989c66c493,59bfd3d6-e1bf-4233-8def-1f648b4c045e,f69b2d12-2038-41a9-b416-d3c480736f5b,7452052d-1c3d-4aa8-8fcd-e58556513248,6dc0f00b-5ebd-4b0e-b639-2168d0bea3ce,42ed3074-0269-4669-9f60-ed38853ba85a,454c4c4e-a9c0-4349-9861-1d2394b1c495,0c357720-5066-4fd6-a7d7-64dde5fcb0c2,e9c58f65-779c-4040-94a0-db21a41f3a7a,9b17131f-11a6-4ea3-a6bb-38b56357e858,c619a5da-b633-425a-92b2-34cb831fd662,3ecc6897-3b48-4930-b659-d597c69c83bc,004f4b76-a500-47d3-a015-235e0717205b}	submitted	2026-04-28 12:57:29.278715+00	2026-04-28 16:05:52.502168+00	122	199	11303	admission_test
2557bb3a-9869-422c-ac10-8000966fb728	d5393b18-6a59-4133-a743-10c9bdc3d16b	subject_quiz	untimed	\N	physics	\N	\N	{8af36a16-997a-4f49-8622-77c5f80334df,66e563db-29f8-4f21-8537-c0127e5e63cc,0d3a863f-1bdc-4700-9fde-50a6789967a6,46017748-34b0-4df2-ba25-ae8a35202fd9,6ebea734-46a1-4bc7-9949-cfd2128f81e9,e7e5c15d-593a-41f6-a631-17cee6c3d6e2,cf3e3677-791a-4595-acca-dbdb0f4d2908,14e7bcbb-c2f7-48bc-aa90-74c03999d9e7,e92084ad-292d-4840-abe3-026cbdede660,d0ff282d-2b31-4f6d-a72b-f0e522b93a60,d8122c72-6c11-4278-835b-9d1e6df1a3c8,0d6a324b-4f00-466e-9db4-a00dca497c99,cda0ca18-8820-4020-ad75-1a93511536b3,80f911b3-a969-481c-bb8d-6920cf9cb4c3,8348307d-6f89-4ee2-bcee-97ba4e2a32f8,fa4ff435-2391-4047-b44c-f685d53e9f55,08a035f1-feef-4d5b-8017-ef1773ce0f4d,73c1c74d-b66f-4759-8fe1-c9a414e37872,75a24797-7a12-4fab-a527-e72c1d201203,9c09af5e-a1c7-4691-9711-b9cd745d9753,001777f1-ddfd-4c1d-9f39-0f7ea9489952,ff1a1634-1cba-4dfd-a821-3c681b5fd44e,73b59855-deaa-4f41-9913-5a53a9111826,cb3208dc-39aa-44b3-8625-60ee6507cbf3,2a7dc3da-9520-4108-929c-a14782e25c36,4599acb3-9d78-4bf9-8c9b-47bc3b7756d6,0d9953e6-403e-4dfe-8d1b-81061084d971,c7cb926c-cb05-4342-86c3-3c23a8749ebf,b7a602a2-e595-4a46-8aca-637cb75a3eee,854a05d3-849b-4dd9-a522-4b7c9d192a45,28c07dfe-cb42-44d4-9f2f-dda64ffb6882,38286d3b-99a2-4122-b821-87eb0a236eca,ba844b10-8d58-4186-9c14-2cdced4aaeae,70b8f220-c374-4587-bcb2-12f7e2fa0bf7,011f55e3-6770-4d47-9e46-3b8cd0e83955,a573f0bf-6d03-49fe-bb60-accbb25272cb,1b88a88c-cb2d-4184-a5e0-de08129088a2,38f811fb-1c5b-48db-878a-e7492dac0d62,fcb4d325-5f11-4166-ba6e-0c718d6b8936,1cba308b-e030-438f-bf35-8632f38605e8,dc146fec-8cb1-4a88-9c45-440587c8f124,d3ccca49-10b5-4f46-ac64-eb70abeb097a,af038b7c-e600-4d33-8155-21719ce50014,6b8b0d2e-4b91-4511-9acf-a2f4c0fce4e9,87a00d9d-0b71-46a9-a5b5-dab32ffe2472,98043387-e7c4-4277-99f0-6815949e7288,057d9d16-3096-49a9-9332-91786e8f7fde,61ea3a53-6193-49d9-a68a-80213ce57a55,5679a8f3-dad5-48c3-8057-6caa1fbd2683,ecfc3df5-ed6a-44f4-9485-2c29f731aa0b,fb75ef93-d920-4f94-81ea-1d9ff5b08784,568b2bc9-9a19-44c0-8b8b-8d0045475282,a360f901-de88-4d26-8f31-c16713d3b6da,bd780c4e-1e12-4891-a7a0-e6a61eed1456,f1859d7a-e0a7-4fd0-b9c8-a04f01ee9d2a,2e1e2c65-8558-43dd-afec-c2d333b2aa14,ac6f50f6-6eab-41d1-833d-6740b87c9175,b8015bab-db1a-45e5-9320-352d8d698989,9eb2d84f-c683-46fd-b93a-def8d294ca2b,a776c176-a748-4ce2-81b0-d2817998a72c,ed6ec807-2624-4a5a-9f90-6aea86d4fa8b,91b366bd-9fda-470d-99fa-9daae2309649,d8273d47-fb02-4186-aac8-9ca5e5541f2e,52357405-5abf-4f44-98ff-230d83a1da72,617ff669-f28b-49d1-8d4e-1d03aac4f140,1f2aa538-6e73-48e9-92b0-91ab71dd76aa,631925ee-0015-485f-b444-04e213626498,346f920b-88ea-4002-9f8c-54db78719db2,39913432-08d3-4da1-8101-76555b68789f,901eaa80-8900-46c4-820f-6f002be4a75d,44dabe5a-baf4-4f09-abf0-5fdc2d32a0e2,0b5f0817-9307-4039-a24b-2cad9cc12a35,3e4ea525-2149-4cf7-ac09-9c3085be3a07,907c9c8d-a368-4884-bbbd-04bfd8d150b8,cbc7a85d-71ac-44c7-baa8-1aa8f8287b9a,4ce9e2ef-41c9-44d4-9476-d83c495c093d,134c31cf-066e-4317-af88-173a7711068d,52130c99-6ddd-4199-99fc-1a9ced88011c,860c1fc9-5098-4d31-856f-94e217189509,225e280b-313c-45c5-ac01-002865223dfe,448025f6-abe6-42fa-8866-014b842f7785,603aab63-8553-47a4-a088-d2d1ce0ccd17,b1f34359-813c-454a-87d2-8be081eec7d0,e1d1e7b0-bd77-4a21-95bc-ed3972271996,c20cf417-98d4-41eb-8914-7e4e3f45fa83,b1948a83-dec1-4d5c-92ca-3909de974a5e,8dc11970-9511-4442-a739-3d999548678b,79fac420-1fdd-40d0-b324-11d7fdf6767b,eab51de4-7348-4b0e-9609-064e88015dea,b5a6e81f-c016-4964-8cc9-cd77e4ec8fa3,41a0acaa-dbdc-4719-9b7f-f796e1a8db5f,e8c100e6-f5c4-4839-97d9-0e7d7089985b,d00bf7f0-ff55-42bd-8b08-def20bb03915,4706a514-8c18-4c10-911a-ca041142edc2,c44fab2b-eb92-4719-9d96-23dfbfe38b22,6b73768d-7203-43eb-a59f-6730654649cd,2b101e61-141d-4d7f-b4c2-196138cf5fb2,3f5b9d22-6edf-4b2b-a7e7-2b634e259061,234ce33d-2f3e-44da-bb27-cb3c7539c50f,236c5edc-9fb2-4134-b848-7df9910ee107,4b3fd082-8394-4ecc-afda-a36b07d05658,19e6c77e-9cfc-4eec-99c4-afdb0ba05ca5,0bd7afbd-dcc0-410b-bde1-5355b8cb277f,f43d91bf-4188-4d97-8011-e759b608a2e2,f606aac2-ea93-4afb-894f-6c4fa67e6b05,24c0e56f-d2c6-4418-ae77-a82a0b94ee74,4c87010d-60fd-4686-8d7a-0b11ad5aa2d8,6d111269-ad5b-401e-a1b2-4819ba463ee6,49ac5214-08aa-4093-9790-8e3402278800,7e95694e-7ce3-4768-b194-baf73df330b4,6f0a35c2-8908-4c2d-9620-26945cada15f,e1f38048-f857-424d-bbec-4cfa15494f9c,6dff14d7-14d7-4232-9a97-e4b24b18a43c,e7f5bd3b-c6c0-40f2-8303-1977170cdd93,759721fb-6efd-4fa0-873f-994c91fafae6,cf3b2c91-ad6f-4dd1-8e75-00f30732f932,3ca8ae1a-6ccf-4d76-bbe9-913a8fc3cd5d,fa60a6d0-fec7-41af-b837-dc417b5e36a9,f6992e14-6260-4199-8666-6e9366738d82,ae44507d-e359-4e47-b783-a5b9ca68f0eb,1b7caef1-59fd-4b4a-aa70-42c2f635fe44,d465803b-1304-4d77-8002-5b7aedd3c83c,18cb2450-e0d6-41d9-87b7-d55e28876177,4290a514-cf7b-4347-b9af-e669fda9388f,224cfaf5-cd27-416f-a643-c1e7c7aa4d36,b6da5681-215c-4b93-b5f0-6e8f785b731b,25ec7bf5-1589-4329-b1f7-516f0f8d37a0,19ccfdd4-936b-41cd-b943-379ebb3eb295,982593d5-f7ce-4d9e-813b-41e6df2b0bef,9f75d35f-1455-4153-8056-423445f16fce,6b7a2340-d204-4c9a-a820-90576cb4732e,fad7afa2-b0be-4bfd-ad77-992dd800cac6,e568c7fc-715f-404d-b3ed-70048053b374,dfa449d1-1841-483a-9d3c-fae10a197a8e,ab80055d-216e-4731-926d-e2edebe712a0,1f71e2ec-348b-4269-9503-e39e1cc6db2c,a75f1685-75c9-46d3-a53d-c51b3c16eaef,f4dded80-a2f9-4297-8907-775b0136b46a,ca52fa50-abaa-4fd0-bb0d-ae75039e1cbb,cc8ba2b6-5eb6-4c30-a00d-d2a89b0ce831,fad720c6-cf79-47e3-a7dc-997ce0a4ca1c,c740ba7e-7386-4f2f-a462-c1d4778554e9,3bba5900-28d6-4761-ad6f-cfa430e73ebe,b51e5ec8-ad46-46b5-b689-d5e8a977463e,0ecbb69a-5327-4480-ab5b-8a34b5179a3a,d3b41295-7f1b-48e9-a96a-52043440d70b,338d8dcd-bd80-427d-8c4b-7cefaa73721f,8867a36b-758a-4c7e-ab60-1596edc4c28e,80d9a4aa-49ca-4e56-9af1-fa6d6157e28f,738590ae-23a1-4699-bc44-edbe819148d2,a1ae8350-1cd7-42bd-8999-4a5c1a275990,78416331-8465-4bc7-8067-af60abc59577,816a0061-1e82-44b0-8914-79a1931908fd,cf30506d-2b21-48ac-ab56-f21bdea377c6,461e205a-bb8a-4bdd-81fb-f8a21d854215,050c9a2a-afc8-4cf8-84d4-2c22be81abd0,a7474a47-2e26-491d-a7b9-b04b8138e571,3685e2c6-f04d-478e-87ed-12d8cc72939c,461daa81-404c-4000-b336-e406acefa007,bddb3fc5-93d3-4c42-a66d-96227a6e8f0f,49fe07e4-d291-4f8f-b4f9-0fc162ad8553,d9ca492d-8ac0-487a-8a2e-0644d67689e2,0e7b1d5f-a655-4b21-a3e9-37c113cfc52e,1e77e791-b572-49c5-96d7-14115d517329,bb8e0d8a-95dc-4430-a5de-bbedcd1d8fda,993ab2ec-b5b1-45ce-8e69-172067cd19a5,6b90fb4c-402a-49a3-95a2-75d1eb435bea,f0807419-d303-4100-8168-7fa61676df98,b1c543d3-0318-4e2d-bc4b-6212bc78941b,52ec6e64-8b1a-461b-a878-0c0c035dbbd4,01cdbfcd-5a74-450f-b9fa-69200db938c3,314c5e8f-d335-43b8-9d15-98ddd83054ac,98f61b5a-bb45-4b43-b6ac-d150779b2711,f29d26aa-a051-4d45-b580-7f49cc55ac8e,06124444-db56-443e-8025-1c2c369f8576,93402563-6af3-45ec-9de0-aede8c8fb6b0,d16e6125-c814-44cb-86d7-0eaaa8baa883,aed35f2e-37e1-442a-b518-86d99c84bcea,a772c84b-1fe5-43b3-8631-af02fd8450a1,87e60be5-0a87-45da-ad2f-f8266e80c18c,d254c27e-6371-48b8-96a2-4f5407502a92,a01b5c95-1c9e-4319-b48f-90743f87f68c,838997fc-c95f-428f-8c5c-30357c80a62a,93d31d40-3d8a-4907-89b2-12486ee52608,cdfddac8-993b-4063-a369-7e44a7d24b69,27cfb107-5cd9-4f06-9464-e31b0758e1a3,9f65ed34-7e3f-42fd-88dc-49989c66c493,59bfd3d6-e1bf-4233-8def-1f648b4c045e,f69b2d12-2038-41a9-b416-d3c480736f5b,7452052d-1c3d-4aa8-8fcd-e58556513248,6dc0f00b-5ebd-4b0e-b639-2168d0bea3ce,42ed3074-0269-4669-9f60-ed38853ba85a,454c4c4e-a9c0-4349-9861-1d2394b1c495,0c357720-5066-4fd6-a7d7-64dde5fcb0c2,e9c58f65-779c-4040-94a0-db21a41f3a7a,9b17131f-11a6-4ea3-a6bb-38b56357e858,c619a5da-b633-425a-92b2-34cb831fd662,3ecc6897-3b48-4930-b659-d597c69c83bc,004f4b76-a500-47d3-a015-235e0717205b}	submitted	2026-04-28 12:57:51.813608+00	2026-04-28 16:06:46.406776+00	91	199	11334	admission_test
71805292-835e-4ff3-a365-f30fcfc06048	d4fd0752-82a0-45fb-828a-4aa1d7328c2c	subject_quiz	untimed	\N	physics	\N	\N	{8af36a16-997a-4f49-8622-77c5f80334df,66e563db-29f8-4f21-8537-c0127e5e63cc,0d3a863f-1bdc-4700-9fde-50a6789967a6,46017748-34b0-4df2-ba25-ae8a35202fd9,6ebea734-46a1-4bc7-9949-cfd2128f81e9,e7e5c15d-593a-41f6-a631-17cee6c3d6e2,cf3e3677-791a-4595-acca-dbdb0f4d2908,14e7bcbb-c2f7-48bc-aa90-74c03999d9e7,e92084ad-292d-4840-abe3-026cbdede660,d0ff282d-2b31-4f6d-a72b-f0e522b93a60,d8122c72-6c11-4278-835b-9d1e6df1a3c8,0d6a324b-4f00-466e-9db4-a00dca497c99,cda0ca18-8820-4020-ad75-1a93511536b3,80f911b3-a969-481c-bb8d-6920cf9cb4c3,8348307d-6f89-4ee2-bcee-97ba4e2a32f8,fa4ff435-2391-4047-b44c-f685d53e9f55,08a035f1-feef-4d5b-8017-ef1773ce0f4d,73c1c74d-b66f-4759-8fe1-c9a414e37872,75a24797-7a12-4fab-a527-e72c1d201203,9c09af5e-a1c7-4691-9711-b9cd745d9753,001777f1-ddfd-4c1d-9f39-0f7ea9489952,ff1a1634-1cba-4dfd-a821-3c681b5fd44e,73b59855-deaa-4f41-9913-5a53a9111826,cb3208dc-39aa-44b3-8625-60ee6507cbf3,2a7dc3da-9520-4108-929c-a14782e25c36,4599acb3-9d78-4bf9-8c9b-47bc3b7756d6,0d9953e6-403e-4dfe-8d1b-81061084d971,c7cb926c-cb05-4342-86c3-3c23a8749ebf,b7a602a2-e595-4a46-8aca-637cb75a3eee,854a05d3-849b-4dd9-a522-4b7c9d192a45,28c07dfe-cb42-44d4-9f2f-dda64ffb6882,38286d3b-99a2-4122-b821-87eb0a236eca,ba844b10-8d58-4186-9c14-2cdced4aaeae,70b8f220-c374-4587-bcb2-12f7e2fa0bf7,011f55e3-6770-4d47-9e46-3b8cd0e83955,a573f0bf-6d03-49fe-bb60-accbb25272cb,1b88a88c-cb2d-4184-a5e0-de08129088a2,38f811fb-1c5b-48db-878a-e7492dac0d62,fcb4d325-5f11-4166-ba6e-0c718d6b8936,1cba308b-e030-438f-bf35-8632f38605e8,dc146fec-8cb1-4a88-9c45-440587c8f124,d3ccca49-10b5-4f46-ac64-eb70abeb097a,af038b7c-e600-4d33-8155-21719ce50014,6b8b0d2e-4b91-4511-9acf-a2f4c0fce4e9,87a00d9d-0b71-46a9-a5b5-dab32ffe2472,98043387-e7c4-4277-99f0-6815949e7288,057d9d16-3096-49a9-9332-91786e8f7fde,61ea3a53-6193-49d9-a68a-80213ce57a55,5679a8f3-dad5-48c3-8057-6caa1fbd2683,ecfc3df5-ed6a-44f4-9485-2c29f731aa0b,fb75ef93-d920-4f94-81ea-1d9ff5b08784,568b2bc9-9a19-44c0-8b8b-8d0045475282,a360f901-de88-4d26-8f31-c16713d3b6da,bd780c4e-1e12-4891-a7a0-e6a61eed1456,f1859d7a-e0a7-4fd0-b9c8-a04f01ee9d2a,2e1e2c65-8558-43dd-afec-c2d333b2aa14,ac6f50f6-6eab-41d1-833d-6740b87c9175,b8015bab-db1a-45e5-9320-352d8d698989,9eb2d84f-c683-46fd-b93a-def8d294ca2b,a776c176-a748-4ce2-81b0-d2817998a72c,ed6ec807-2624-4a5a-9f90-6aea86d4fa8b,91b366bd-9fda-470d-99fa-9daae2309649,d8273d47-fb02-4186-aac8-9ca5e5541f2e,52357405-5abf-4f44-98ff-230d83a1da72,617ff669-f28b-49d1-8d4e-1d03aac4f140,1f2aa538-6e73-48e9-92b0-91ab71dd76aa,631925ee-0015-485f-b444-04e213626498,346f920b-88ea-4002-9f8c-54db78719db2,39913432-08d3-4da1-8101-76555b68789f,901eaa80-8900-46c4-820f-6f002be4a75d,44dabe5a-baf4-4f09-abf0-5fdc2d32a0e2,0b5f0817-9307-4039-a24b-2cad9cc12a35,3e4ea525-2149-4cf7-ac09-9c3085be3a07,907c9c8d-a368-4884-bbbd-04bfd8d150b8,cbc7a85d-71ac-44c7-baa8-1aa8f8287b9a,4ce9e2ef-41c9-44d4-9476-d83c495c093d,134c31cf-066e-4317-af88-173a7711068d,52130c99-6ddd-4199-99fc-1a9ced88011c,860c1fc9-5098-4d31-856f-94e217189509,225e280b-313c-45c5-ac01-002865223dfe,448025f6-abe6-42fa-8866-014b842f7785,603aab63-8553-47a4-a088-d2d1ce0ccd17,b1f34359-813c-454a-87d2-8be081eec7d0,e1d1e7b0-bd77-4a21-95bc-ed3972271996,c20cf417-98d4-41eb-8914-7e4e3f45fa83,b1948a83-dec1-4d5c-92ca-3909de974a5e,8dc11970-9511-4442-a739-3d999548678b,79fac420-1fdd-40d0-b324-11d7fdf6767b,eab51de4-7348-4b0e-9609-064e88015dea,b5a6e81f-c016-4964-8cc9-cd77e4ec8fa3,41a0acaa-dbdc-4719-9b7f-f796e1a8db5f,e8c100e6-f5c4-4839-97d9-0e7d7089985b,d00bf7f0-ff55-42bd-8b08-def20bb03915,4706a514-8c18-4c10-911a-ca041142edc2,c44fab2b-eb92-4719-9d96-23dfbfe38b22,6b73768d-7203-43eb-a59f-6730654649cd,2b101e61-141d-4d7f-b4c2-196138cf5fb2,3f5b9d22-6edf-4b2b-a7e7-2b634e259061,234ce33d-2f3e-44da-bb27-cb3c7539c50f,236c5edc-9fb2-4134-b848-7df9910ee107,4b3fd082-8394-4ecc-afda-a36b07d05658,19e6c77e-9cfc-4eec-99c4-afdb0ba05ca5,0bd7afbd-dcc0-410b-bde1-5355b8cb277f,f43d91bf-4188-4d97-8011-e759b608a2e2,f606aac2-ea93-4afb-894f-6c4fa67e6b05,24c0e56f-d2c6-4418-ae77-a82a0b94ee74,4c87010d-60fd-4686-8d7a-0b11ad5aa2d8,6d111269-ad5b-401e-a1b2-4819ba463ee6,49ac5214-08aa-4093-9790-8e3402278800,7e95694e-7ce3-4768-b194-baf73df330b4,6f0a35c2-8908-4c2d-9620-26945cada15f,e1f38048-f857-424d-bbec-4cfa15494f9c,6dff14d7-14d7-4232-9a97-e4b24b18a43c,e7f5bd3b-c6c0-40f2-8303-1977170cdd93,759721fb-6efd-4fa0-873f-994c91fafae6,cf3b2c91-ad6f-4dd1-8e75-00f30732f932,3ca8ae1a-6ccf-4d76-bbe9-913a8fc3cd5d,fa60a6d0-fec7-41af-b837-dc417b5e36a9,f6992e14-6260-4199-8666-6e9366738d82,ae44507d-e359-4e47-b783-a5b9ca68f0eb,1b7caef1-59fd-4b4a-aa70-42c2f635fe44,d465803b-1304-4d77-8002-5b7aedd3c83c,18cb2450-e0d6-41d9-87b7-d55e28876177,4290a514-cf7b-4347-b9af-e669fda9388f,224cfaf5-cd27-416f-a643-c1e7c7aa4d36,b6da5681-215c-4b93-b5f0-6e8f785b731b,25ec7bf5-1589-4329-b1f7-516f0f8d37a0,19ccfdd4-936b-41cd-b943-379ebb3eb295,982593d5-f7ce-4d9e-813b-41e6df2b0bef,9f75d35f-1455-4153-8056-423445f16fce,6b7a2340-d204-4c9a-a820-90576cb4732e,fad7afa2-b0be-4bfd-ad77-992dd800cac6,e568c7fc-715f-404d-b3ed-70048053b374,dfa449d1-1841-483a-9d3c-fae10a197a8e,ab80055d-216e-4731-926d-e2edebe712a0,1f71e2ec-348b-4269-9503-e39e1cc6db2c,a75f1685-75c9-46d3-a53d-c51b3c16eaef,f4dded80-a2f9-4297-8907-775b0136b46a,ca52fa50-abaa-4fd0-bb0d-ae75039e1cbb,cc8ba2b6-5eb6-4c30-a00d-d2a89b0ce831,fad720c6-cf79-47e3-a7dc-997ce0a4ca1c,c740ba7e-7386-4f2f-a462-c1d4778554e9,3bba5900-28d6-4761-ad6f-cfa430e73ebe,b51e5ec8-ad46-46b5-b689-d5e8a977463e,0ecbb69a-5327-4480-ab5b-8a34b5179a3a,d3b41295-7f1b-48e9-a96a-52043440d70b,338d8dcd-bd80-427d-8c4b-7cefaa73721f,8867a36b-758a-4c7e-ab60-1596edc4c28e,80d9a4aa-49ca-4e56-9af1-fa6d6157e28f,738590ae-23a1-4699-bc44-edbe819148d2,a1ae8350-1cd7-42bd-8999-4a5c1a275990,78416331-8465-4bc7-8067-af60abc59577,816a0061-1e82-44b0-8914-79a1931908fd,cf30506d-2b21-48ac-ab56-f21bdea377c6,461e205a-bb8a-4bdd-81fb-f8a21d854215,050c9a2a-afc8-4cf8-84d4-2c22be81abd0,a7474a47-2e26-491d-a7b9-b04b8138e571,3685e2c6-f04d-478e-87ed-12d8cc72939c,461daa81-404c-4000-b336-e406acefa007,bddb3fc5-93d3-4c42-a66d-96227a6e8f0f,49fe07e4-d291-4f8f-b4f9-0fc162ad8553,d9ca492d-8ac0-487a-8a2e-0644d67689e2,0e7b1d5f-a655-4b21-a3e9-37c113cfc52e,1e77e791-b572-49c5-96d7-14115d517329,bb8e0d8a-95dc-4430-a5de-bbedcd1d8fda,993ab2ec-b5b1-45ce-8e69-172067cd19a5,6b90fb4c-402a-49a3-95a2-75d1eb435bea,f0807419-d303-4100-8168-7fa61676df98,b1c543d3-0318-4e2d-bc4b-6212bc78941b,52ec6e64-8b1a-461b-a878-0c0c035dbbd4,01cdbfcd-5a74-450f-b9fa-69200db938c3,314c5e8f-d335-43b8-9d15-98ddd83054ac,98f61b5a-bb45-4b43-b6ac-d150779b2711,f29d26aa-a051-4d45-b580-7f49cc55ac8e,06124444-db56-443e-8025-1c2c369f8576,93402563-6af3-45ec-9de0-aede8c8fb6b0,d16e6125-c814-44cb-86d7-0eaaa8baa883,aed35f2e-37e1-442a-b518-86d99c84bcea,a772c84b-1fe5-43b3-8631-af02fd8450a1,87e60be5-0a87-45da-ad2f-f8266e80c18c,d254c27e-6371-48b8-96a2-4f5407502a92,a01b5c95-1c9e-4319-b48f-90743f87f68c,838997fc-c95f-428f-8c5c-30357c80a62a,93d31d40-3d8a-4907-89b2-12486ee52608,cdfddac8-993b-4063-a369-7e44a7d24b69,27cfb107-5cd9-4f06-9464-e31b0758e1a3,9f65ed34-7e3f-42fd-88dc-49989c66c493,59bfd3d6-e1bf-4233-8def-1f648b4c045e,f69b2d12-2038-41a9-b416-d3c480736f5b,7452052d-1c3d-4aa8-8fcd-e58556513248,6dc0f00b-5ebd-4b0e-b639-2168d0bea3ce,42ed3074-0269-4669-9f60-ed38853ba85a,454c4c4e-a9c0-4349-9861-1d2394b1c495,0c357720-5066-4fd6-a7d7-64dde5fcb0c2,e9c58f65-779c-4040-94a0-db21a41f3a7a,9b17131f-11a6-4ea3-a6bb-38b56357e858,c619a5da-b633-425a-92b2-34cb831fd662,3ecc6897-3b48-4930-b659-d597c69c83bc,004f4b76-a500-47d3-a015-235e0717205b}	submitted	2026-04-28 12:58:03.593405+00	2026-04-28 16:07:22.041576+00	72	199	11358	admission_test
e7ec87f6-3540-4528-bf0f-2f0ffc4edeeb	0ebac587-eccd-42a9-b693-915ee1917c51	subject_quiz	untimed	\N	physics	\N	\N	{8af36a16-997a-4f49-8622-77c5f80334df,66e563db-29f8-4f21-8537-c0127e5e63cc,0d3a863f-1bdc-4700-9fde-50a6789967a6,46017748-34b0-4df2-ba25-ae8a35202fd9,6ebea734-46a1-4bc7-9949-cfd2128f81e9,e7e5c15d-593a-41f6-a631-17cee6c3d6e2,cf3e3677-791a-4595-acca-dbdb0f4d2908,14e7bcbb-c2f7-48bc-aa90-74c03999d9e7,e92084ad-292d-4840-abe3-026cbdede660,d0ff282d-2b31-4f6d-a72b-f0e522b93a60,d8122c72-6c11-4278-835b-9d1e6df1a3c8,0d6a324b-4f00-466e-9db4-a00dca497c99,cda0ca18-8820-4020-ad75-1a93511536b3,80f911b3-a969-481c-bb8d-6920cf9cb4c3,8348307d-6f89-4ee2-bcee-97ba4e2a32f8,fa4ff435-2391-4047-b44c-f685d53e9f55,08a035f1-feef-4d5b-8017-ef1773ce0f4d,73c1c74d-b66f-4759-8fe1-c9a414e37872,75a24797-7a12-4fab-a527-e72c1d201203,9c09af5e-a1c7-4691-9711-b9cd745d9753,001777f1-ddfd-4c1d-9f39-0f7ea9489952,ff1a1634-1cba-4dfd-a821-3c681b5fd44e,73b59855-deaa-4f41-9913-5a53a9111826,cb3208dc-39aa-44b3-8625-60ee6507cbf3,2a7dc3da-9520-4108-929c-a14782e25c36,4599acb3-9d78-4bf9-8c9b-47bc3b7756d6,0d9953e6-403e-4dfe-8d1b-81061084d971,c7cb926c-cb05-4342-86c3-3c23a8749ebf,b7a602a2-e595-4a46-8aca-637cb75a3eee,854a05d3-849b-4dd9-a522-4b7c9d192a45,28c07dfe-cb42-44d4-9f2f-dda64ffb6882,38286d3b-99a2-4122-b821-87eb0a236eca,ba844b10-8d58-4186-9c14-2cdced4aaeae,70b8f220-c374-4587-bcb2-12f7e2fa0bf7,011f55e3-6770-4d47-9e46-3b8cd0e83955,a573f0bf-6d03-49fe-bb60-accbb25272cb,1b88a88c-cb2d-4184-a5e0-de08129088a2,38f811fb-1c5b-48db-878a-e7492dac0d62,fcb4d325-5f11-4166-ba6e-0c718d6b8936,1cba308b-e030-438f-bf35-8632f38605e8,dc146fec-8cb1-4a88-9c45-440587c8f124,d3ccca49-10b5-4f46-ac64-eb70abeb097a,af038b7c-e600-4d33-8155-21719ce50014,6b8b0d2e-4b91-4511-9acf-a2f4c0fce4e9,87a00d9d-0b71-46a9-a5b5-dab32ffe2472,98043387-e7c4-4277-99f0-6815949e7288,057d9d16-3096-49a9-9332-91786e8f7fde,61ea3a53-6193-49d9-a68a-80213ce57a55,5679a8f3-dad5-48c3-8057-6caa1fbd2683,ecfc3df5-ed6a-44f4-9485-2c29f731aa0b,fb75ef93-d920-4f94-81ea-1d9ff5b08784,568b2bc9-9a19-44c0-8b8b-8d0045475282,a360f901-de88-4d26-8f31-c16713d3b6da,bd780c4e-1e12-4891-a7a0-e6a61eed1456,f1859d7a-e0a7-4fd0-b9c8-a04f01ee9d2a,2e1e2c65-8558-43dd-afec-c2d333b2aa14,ac6f50f6-6eab-41d1-833d-6740b87c9175,b8015bab-db1a-45e5-9320-352d8d698989,9eb2d84f-c683-46fd-b93a-def8d294ca2b,a776c176-a748-4ce2-81b0-d2817998a72c,ed6ec807-2624-4a5a-9f90-6aea86d4fa8b,91b366bd-9fda-470d-99fa-9daae2309649,d8273d47-fb02-4186-aac8-9ca5e5541f2e,52357405-5abf-4f44-98ff-230d83a1da72,617ff669-f28b-49d1-8d4e-1d03aac4f140,1f2aa538-6e73-48e9-92b0-91ab71dd76aa,631925ee-0015-485f-b444-04e213626498,346f920b-88ea-4002-9f8c-54db78719db2,39913432-08d3-4da1-8101-76555b68789f,901eaa80-8900-46c4-820f-6f002be4a75d,44dabe5a-baf4-4f09-abf0-5fdc2d32a0e2,0b5f0817-9307-4039-a24b-2cad9cc12a35,3e4ea525-2149-4cf7-ac09-9c3085be3a07,907c9c8d-a368-4884-bbbd-04bfd8d150b8,cbc7a85d-71ac-44c7-baa8-1aa8f8287b9a,4ce9e2ef-41c9-44d4-9476-d83c495c093d,134c31cf-066e-4317-af88-173a7711068d,52130c99-6ddd-4199-99fc-1a9ced88011c,860c1fc9-5098-4d31-856f-94e217189509,225e280b-313c-45c5-ac01-002865223dfe,448025f6-abe6-42fa-8866-014b842f7785,603aab63-8553-47a4-a088-d2d1ce0ccd17,b1f34359-813c-454a-87d2-8be081eec7d0,e1d1e7b0-bd77-4a21-95bc-ed3972271996,c20cf417-98d4-41eb-8914-7e4e3f45fa83,b1948a83-dec1-4d5c-92ca-3909de974a5e,8dc11970-9511-4442-a739-3d999548678b,79fac420-1fdd-40d0-b324-11d7fdf6767b,eab51de4-7348-4b0e-9609-064e88015dea,b5a6e81f-c016-4964-8cc9-cd77e4ec8fa3,41a0acaa-dbdc-4719-9b7f-f796e1a8db5f,e8c100e6-f5c4-4839-97d9-0e7d7089985b,d00bf7f0-ff55-42bd-8b08-def20bb03915,4706a514-8c18-4c10-911a-ca041142edc2,c44fab2b-eb92-4719-9d96-23dfbfe38b22,6b73768d-7203-43eb-a59f-6730654649cd,2b101e61-141d-4d7f-b4c2-196138cf5fb2,3f5b9d22-6edf-4b2b-a7e7-2b634e259061,234ce33d-2f3e-44da-bb27-cb3c7539c50f,236c5edc-9fb2-4134-b848-7df9910ee107,4b3fd082-8394-4ecc-afda-a36b07d05658,19e6c77e-9cfc-4eec-99c4-afdb0ba05ca5,0bd7afbd-dcc0-410b-bde1-5355b8cb277f,f43d91bf-4188-4d97-8011-e759b608a2e2,f606aac2-ea93-4afb-894f-6c4fa67e6b05,24c0e56f-d2c6-4418-ae77-a82a0b94ee74,4c87010d-60fd-4686-8d7a-0b11ad5aa2d8,6d111269-ad5b-401e-a1b2-4819ba463ee6,49ac5214-08aa-4093-9790-8e3402278800,7e95694e-7ce3-4768-b194-baf73df330b4,6f0a35c2-8908-4c2d-9620-26945cada15f,e1f38048-f857-424d-bbec-4cfa15494f9c,6dff14d7-14d7-4232-9a97-e4b24b18a43c,e7f5bd3b-c6c0-40f2-8303-1977170cdd93,759721fb-6efd-4fa0-873f-994c91fafae6,cf3b2c91-ad6f-4dd1-8e75-00f30732f932,3ca8ae1a-6ccf-4d76-bbe9-913a8fc3cd5d,fa60a6d0-fec7-41af-b837-dc417b5e36a9,f6992e14-6260-4199-8666-6e9366738d82,ae44507d-e359-4e47-b783-a5b9ca68f0eb,1b7caef1-59fd-4b4a-aa70-42c2f635fe44,d465803b-1304-4d77-8002-5b7aedd3c83c,18cb2450-e0d6-41d9-87b7-d55e28876177,4290a514-cf7b-4347-b9af-e669fda9388f,224cfaf5-cd27-416f-a643-c1e7c7aa4d36,b6da5681-215c-4b93-b5f0-6e8f785b731b,25ec7bf5-1589-4329-b1f7-516f0f8d37a0,19ccfdd4-936b-41cd-b943-379ebb3eb295,982593d5-f7ce-4d9e-813b-41e6df2b0bef,9f75d35f-1455-4153-8056-423445f16fce,6b7a2340-d204-4c9a-a820-90576cb4732e,fad7afa2-b0be-4bfd-ad77-992dd800cac6,e568c7fc-715f-404d-b3ed-70048053b374,dfa449d1-1841-483a-9d3c-fae10a197a8e,ab80055d-216e-4731-926d-e2edebe712a0,1f71e2ec-348b-4269-9503-e39e1cc6db2c,a75f1685-75c9-46d3-a53d-c51b3c16eaef,f4dded80-a2f9-4297-8907-775b0136b46a,ca52fa50-abaa-4fd0-bb0d-ae75039e1cbb,cc8ba2b6-5eb6-4c30-a00d-d2a89b0ce831,fad720c6-cf79-47e3-a7dc-997ce0a4ca1c,c740ba7e-7386-4f2f-a462-c1d4778554e9,3bba5900-28d6-4761-ad6f-cfa430e73ebe,b51e5ec8-ad46-46b5-b689-d5e8a977463e,0ecbb69a-5327-4480-ab5b-8a34b5179a3a,d3b41295-7f1b-48e9-a96a-52043440d70b,338d8dcd-bd80-427d-8c4b-7cefaa73721f,8867a36b-758a-4c7e-ab60-1596edc4c28e,80d9a4aa-49ca-4e56-9af1-fa6d6157e28f,738590ae-23a1-4699-bc44-edbe819148d2,a1ae8350-1cd7-42bd-8999-4a5c1a275990,78416331-8465-4bc7-8067-af60abc59577,816a0061-1e82-44b0-8914-79a1931908fd,cf30506d-2b21-48ac-ab56-f21bdea377c6,461e205a-bb8a-4bdd-81fb-f8a21d854215,050c9a2a-afc8-4cf8-84d4-2c22be81abd0,a7474a47-2e26-491d-a7b9-b04b8138e571,3685e2c6-f04d-478e-87ed-12d8cc72939c,461daa81-404c-4000-b336-e406acefa007,bddb3fc5-93d3-4c42-a66d-96227a6e8f0f,49fe07e4-d291-4f8f-b4f9-0fc162ad8553,d9ca492d-8ac0-487a-8a2e-0644d67689e2,0e7b1d5f-a655-4b21-a3e9-37c113cfc52e,1e77e791-b572-49c5-96d7-14115d517329,bb8e0d8a-95dc-4430-a5de-bbedcd1d8fda,993ab2ec-b5b1-45ce-8e69-172067cd19a5,6b90fb4c-402a-49a3-95a2-75d1eb435bea,f0807419-d303-4100-8168-7fa61676df98,b1c543d3-0318-4e2d-bc4b-6212bc78941b,52ec6e64-8b1a-461b-a878-0c0c035dbbd4,01cdbfcd-5a74-450f-b9fa-69200db938c3,314c5e8f-d335-43b8-9d15-98ddd83054ac,98f61b5a-bb45-4b43-b6ac-d150779b2711,f29d26aa-a051-4d45-b580-7f49cc55ac8e,06124444-db56-443e-8025-1c2c369f8576,93402563-6af3-45ec-9de0-aede8c8fb6b0,d16e6125-c814-44cb-86d7-0eaaa8baa883,aed35f2e-37e1-442a-b518-86d99c84bcea,a772c84b-1fe5-43b3-8631-af02fd8450a1,87e60be5-0a87-45da-ad2f-f8266e80c18c,d254c27e-6371-48b8-96a2-4f5407502a92,a01b5c95-1c9e-4319-b48f-90743f87f68c,838997fc-c95f-428f-8c5c-30357c80a62a,93d31d40-3d8a-4907-89b2-12486ee52608,cdfddac8-993b-4063-a369-7e44a7d24b69,27cfb107-5cd9-4f06-9464-e31b0758e1a3,9f65ed34-7e3f-42fd-88dc-49989c66c493,59bfd3d6-e1bf-4233-8def-1f648b4c045e,f69b2d12-2038-41a9-b416-d3c480736f5b,7452052d-1c3d-4aa8-8fcd-e58556513248,6dc0f00b-5ebd-4b0e-b639-2168d0bea3ce,42ed3074-0269-4669-9f60-ed38853ba85a,454c4c4e-a9c0-4349-9861-1d2394b1c495,0c357720-5066-4fd6-a7d7-64dde5fcb0c2,e9c58f65-779c-4040-94a0-db21a41f3a7a,9b17131f-11a6-4ea3-a6bb-38b56357e858,c619a5da-b633-425a-92b2-34cb831fd662,3ecc6897-3b48-4930-b659-d597c69c83bc,004f4b76-a500-47d3-a015-235e0717205b}	submitted	2026-04-28 08:54:15.067835+00	2026-04-29 13:55:41.242104+00	2	199	104486	admission_test
433b1a37-02eb-48f9-ab38-1a546a6903bf	eccc1ab0-dea0-4422-953d-3a820e512907	subject_quiz	untimed	\N	physics	\N	\N	{8af36a16-997a-4f49-8622-77c5f80334df,66e563db-29f8-4f21-8537-c0127e5e63cc,0d3a863f-1bdc-4700-9fde-50a6789967a6,46017748-34b0-4df2-ba25-ae8a35202fd9,6ebea734-46a1-4bc7-9949-cfd2128f81e9,e7e5c15d-593a-41f6-a631-17cee6c3d6e2,cf3e3677-791a-4595-acca-dbdb0f4d2908,14e7bcbb-c2f7-48bc-aa90-74c03999d9e7,e92084ad-292d-4840-abe3-026cbdede660,d0ff282d-2b31-4f6d-a72b-f0e522b93a60,d8122c72-6c11-4278-835b-9d1e6df1a3c8,0d6a324b-4f00-466e-9db4-a00dca497c99,cda0ca18-8820-4020-ad75-1a93511536b3,80f911b3-a969-481c-bb8d-6920cf9cb4c3,8348307d-6f89-4ee2-bcee-97ba4e2a32f8,fa4ff435-2391-4047-b44c-f685d53e9f55,08a035f1-feef-4d5b-8017-ef1773ce0f4d,73c1c74d-b66f-4759-8fe1-c9a414e37872,75a24797-7a12-4fab-a527-e72c1d201203,9c09af5e-a1c7-4691-9711-b9cd745d9753,001777f1-ddfd-4c1d-9f39-0f7ea9489952,ff1a1634-1cba-4dfd-a821-3c681b5fd44e,73b59855-deaa-4f41-9913-5a53a9111826,cb3208dc-39aa-44b3-8625-60ee6507cbf3,2a7dc3da-9520-4108-929c-a14782e25c36,4599acb3-9d78-4bf9-8c9b-47bc3b7756d6,0d9953e6-403e-4dfe-8d1b-81061084d971,c7cb926c-cb05-4342-86c3-3c23a8749ebf,b7a602a2-e595-4a46-8aca-637cb75a3eee,854a05d3-849b-4dd9-a522-4b7c9d192a45,28c07dfe-cb42-44d4-9f2f-dda64ffb6882,38286d3b-99a2-4122-b821-87eb0a236eca,ba844b10-8d58-4186-9c14-2cdced4aaeae,70b8f220-c374-4587-bcb2-12f7e2fa0bf7,011f55e3-6770-4d47-9e46-3b8cd0e83955,a573f0bf-6d03-49fe-bb60-accbb25272cb,1b88a88c-cb2d-4184-a5e0-de08129088a2,38f811fb-1c5b-48db-878a-e7492dac0d62,fcb4d325-5f11-4166-ba6e-0c718d6b8936,1cba308b-e030-438f-bf35-8632f38605e8,dc146fec-8cb1-4a88-9c45-440587c8f124,d3ccca49-10b5-4f46-ac64-eb70abeb097a,af038b7c-e600-4d33-8155-21719ce50014,6b8b0d2e-4b91-4511-9acf-a2f4c0fce4e9,87a00d9d-0b71-46a9-a5b5-dab32ffe2472,98043387-e7c4-4277-99f0-6815949e7288,057d9d16-3096-49a9-9332-91786e8f7fde,61ea3a53-6193-49d9-a68a-80213ce57a55,5679a8f3-dad5-48c3-8057-6caa1fbd2683,ecfc3df5-ed6a-44f4-9485-2c29f731aa0b,fb75ef93-d920-4f94-81ea-1d9ff5b08784,568b2bc9-9a19-44c0-8b8b-8d0045475282,a360f901-de88-4d26-8f31-c16713d3b6da,bd780c4e-1e12-4891-a7a0-e6a61eed1456,f1859d7a-e0a7-4fd0-b9c8-a04f01ee9d2a,2e1e2c65-8558-43dd-afec-c2d333b2aa14,ac6f50f6-6eab-41d1-833d-6740b87c9175,b8015bab-db1a-45e5-9320-352d8d698989,9eb2d84f-c683-46fd-b93a-def8d294ca2b,a776c176-a748-4ce2-81b0-d2817998a72c,ed6ec807-2624-4a5a-9f90-6aea86d4fa8b,91b366bd-9fda-470d-99fa-9daae2309649,d8273d47-fb02-4186-aac8-9ca5e5541f2e,52357405-5abf-4f44-98ff-230d83a1da72,617ff669-f28b-49d1-8d4e-1d03aac4f140,1f2aa538-6e73-48e9-92b0-91ab71dd76aa,631925ee-0015-485f-b444-04e213626498,346f920b-88ea-4002-9f8c-54db78719db2,39913432-08d3-4da1-8101-76555b68789f,901eaa80-8900-46c4-820f-6f002be4a75d,44dabe5a-baf4-4f09-abf0-5fdc2d32a0e2,0b5f0817-9307-4039-a24b-2cad9cc12a35,3e4ea525-2149-4cf7-ac09-9c3085be3a07,907c9c8d-a368-4884-bbbd-04bfd8d150b8,cbc7a85d-71ac-44c7-baa8-1aa8f8287b9a,4ce9e2ef-41c9-44d4-9476-d83c495c093d,134c31cf-066e-4317-af88-173a7711068d,52130c99-6ddd-4199-99fc-1a9ced88011c,860c1fc9-5098-4d31-856f-94e217189509,225e280b-313c-45c5-ac01-002865223dfe,448025f6-abe6-42fa-8866-014b842f7785,603aab63-8553-47a4-a088-d2d1ce0ccd17,b1f34359-813c-454a-87d2-8be081eec7d0,e1d1e7b0-bd77-4a21-95bc-ed3972271996,c20cf417-98d4-41eb-8914-7e4e3f45fa83,b1948a83-dec1-4d5c-92ca-3909de974a5e,8dc11970-9511-4442-a739-3d999548678b,79fac420-1fdd-40d0-b324-11d7fdf6767b,eab51de4-7348-4b0e-9609-064e88015dea,b5a6e81f-c016-4964-8cc9-cd77e4ec8fa3,41a0acaa-dbdc-4719-9b7f-f796e1a8db5f,e8c100e6-f5c4-4839-97d9-0e7d7089985b,d00bf7f0-ff55-42bd-8b08-def20bb03915,4706a514-8c18-4c10-911a-ca041142edc2,c44fab2b-eb92-4719-9d96-23dfbfe38b22,6b73768d-7203-43eb-a59f-6730654649cd,2b101e61-141d-4d7f-b4c2-196138cf5fb2,3f5b9d22-6edf-4b2b-a7e7-2b634e259061,234ce33d-2f3e-44da-bb27-cb3c7539c50f,236c5edc-9fb2-4134-b848-7df9910ee107,4b3fd082-8394-4ecc-afda-a36b07d05658,19e6c77e-9cfc-4eec-99c4-afdb0ba05ca5,0bd7afbd-dcc0-410b-bde1-5355b8cb277f,f43d91bf-4188-4d97-8011-e759b608a2e2,f606aac2-ea93-4afb-894f-6c4fa67e6b05,24c0e56f-d2c6-4418-ae77-a82a0b94ee74,4c87010d-60fd-4686-8d7a-0b11ad5aa2d8,6d111269-ad5b-401e-a1b2-4819ba463ee6,49ac5214-08aa-4093-9790-8e3402278800,7e95694e-7ce3-4768-b194-baf73df330b4,6f0a35c2-8908-4c2d-9620-26945cada15f,e1f38048-f857-424d-bbec-4cfa15494f9c,6dff14d7-14d7-4232-9a97-e4b24b18a43c,e7f5bd3b-c6c0-40f2-8303-1977170cdd93,759721fb-6efd-4fa0-873f-994c91fafae6,cf3b2c91-ad6f-4dd1-8e75-00f30732f932,3ca8ae1a-6ccf-4d76-bbe9-913a8fc3cd5d,fa60a6d0-fec7-41af-b837-dc417b5e36a9,f6992e14-6260-4199-8666-6e9366738d82,ae44507d-e359-4e47-b783-a5b9ca68f0eb,1b7caef1-59fd-4b4a-aa70-42c2f635fe44,d465803b-1304-4d77-8002-5b7aedd3c83c,18cb2450-e0d6-41d9-87b7-d55e28876177,4290a514-cf7b-4347-b9af-e669fda9388f,224cfaf5-cd27-416f-a643-c1e7c7aa4d36,b6da5681-215c-4b93-b5f0-6e8f785b731b,25ec7bf5-1589-4329-b1f7-516f0f8d37a0,19ccfdd4-936b-41cd-b943-379ebb3eb295,982593d5-f7ce-4d9e-813b-41e6df2b0bef,9f75d35f-1455-4153-8056-423445f16fce,6b7a2340-d204-4c9a-a820-90576cb4732e,fad7afa2-b0be-4bfd-ad77-992dd800cac6,e568c7fc-715f-404d-b3ed-70048053b374,dfa449d1-1841-483a-9d3c-fae10a197a8e,ab80055d-216e-4731-926d-e2edebe712a0,1f71e2ec-348b-4269-9503-e39e1cc6db2c,a75f1685-75c9-46d3-a53d-c51b3c16eaef,f4dded80-a2f9-4297-8907-775b0136b46a,ca52fa50-abaa-4fd0-bb0d-ae75039e1cbb,cc8ba2b6-5eb6-4c30-a00d-d2a89b0ce831,fad720c6-cf79-47e3-a7dc-997ce0a4ca1c,c740ba7e-7386-4f2f-a462-c1d4778554e9,3bba5900-28d6-4761-ad6f-cfa430e73ebe,b51e5ec8-ad46-46b5-b689-d5e8a977463e,0ecbb69a-5327-4480-ab5b-8a34b5179a3a,d3b41295-7f1b-48e9-a96a-52043440d70b,338d8dcd-bd80-427d-8c4b-7cefaa73721f,8867a36b-758a-4c7e-ab60-1596edc4c28e,80d9a4aa-49ca-4e56-9af1-fa6d6157e28f,738590ae-23a1-4699-bc44-edbe819148d2,a1ae8350-1cd7-42bd-8999-4a5c1a275990,78416331-8465-4bc7-8067-af60abc59577,816a0061-1e82-44b0-8914-79a1931908fd,cf30506d-2b21-48ac-ab56-f21bdea377c6,461e205a-bb8a-4bdd-81fb-f8a21d854215,050c9a2a-afc8-4cf8-84d4-2c22be81abd0,a7474a47-2e26-491d-a7b9-b04b8138e571,3685e2c6-f04d-478e-87ed-12d8cc72939c,461daa81-404c-4000-b336-e406acefa007,bddb3fc5-93d3-4c42-a66d-96227a6e8f0f,49fe07e4-d291-4f8f-b4f9-0fc162ad8553,d9ca492d-8ac0-487a-8a2e-0644d67689e2,0e7b1d5f-a655-4b21-a3e9-37c113cfc52e,1e77e791-b572-49c5-96d7-14115d517329,bb8e0d8a-95dc-4430-a5de-bbedcd1d8fda,993ab2ec-b5b1-45ce-8e69-172067cd19a5,6b90fb4c-402a-49a3-95a2-75d1eb435bea,f0807419-d303-4100-8168-7fa61676df98,b1c543d3-0318-4e2d-bc4b-6212bc78941b,52ec6e64-8b1a-461b-a878-0c0c035dbbd4,01cdbfcd-5a74-450f-b9fa-69200db938c3,314c5e8f-d335-43b8-9d15-98ddd83054ac,98f61b5a-bb45-4b43-b6ac-d150779b2711,f29d26aa-a051-4d45-b580-7f49cc55ac8e,06124444-db56-443e-8025-1c2c369f8576,93402563-6af3-45ec-9de0-aede8c8fb6b0,d16e6125-c814-44cb-86d7-0eaaa8baa883,aed35f2e-37e1-442a-b518-86d99c84bcea,a772c84b-1fe5-43b3-8631-af02fd8450a1,87e60be5-0a87-45da-ad2f-f8266e80c18c,d254c27e-6371-48b8-96a2-4f5407502a92,a01b5c95-1c9e-4319-b48f-90743f87f68c,838997fc-c95f-428f-8c5c-30357c80a62a,93d31d40-3d8a-4907-89b2-12486ee52608,cdfddac8-993b-4063-a369-7e44a7d24b69,27cfb107-5cd9-4f06-9464-e31b0758e1a3,9f65ed34-7e3f-42fd-88dc-49989c66c493,59bfd3d6-e1bf-4233-8def-1f648b4c045e,f69b2d12-2038-41a9-b416-d3c480736f5b,7452052d-1c3d-4aa8-8fcd-e58556513248,6dc0f00b-5ebd-4b0e-b639-2168d0bea3ce,42ed3074-0269-4669-9f60-ed38853ba85a,454c4c4e-a9c0-4349-9861-1d2394b1c495,0c357720-5066-4fd6-a7d7-64dde5fcb0c2,e9c58f65-779c-4040-94a0-db21a41f3a7a,9b17131f-11a6-4ea3-a6bb-38b56357e858,c619a5da-b633-425a-92b2-34cb831fd662,3ecc6897-3b48-4930-b659-d597c69c83bc,004f4b76-a500-47d3-a015-235e0717205b}	submitted	2026-04-28 14:03:13.732926+00	2026-04-29 14:03:23.05032+00	3	199	86409	admission_test
\.


--
-- Data for Name: bookmarks; Type: TABLE DATA; Schema: public; Owner: exambank
--

COPY public.bookmarks (id, user_id, question_id, created_at) FROM stdin;
\.


--
-- Data for Name: exam_papers; Type: TABLE DATA; Schema: public; Owner: exambank
--

COPY public.exam_papers (id, source_filename, university_name, exam_session, exam_unit, page_count, output_json_path, created_at, exam_type, question_type, board_name, exam_year, subject, subject_paper, source_pdf_path) FROM stdin;
2d6e60ff-0b2e-48f4-b6ab-e92b2cb7a0d4	DU-2015-2016-A-Unit.pdf	Dhaka University	2015-2016	A	9	/app/data/results/Dhaka_University_2015-16_unit_A_mcq.json	2026-04-27 17:34:47.206478+00	admission_test	mcq	\N	\N	\N	\N	/app/data/results/Dhaka_University_2015-16_unit_A_mcq.pdf
56229cbd-4fab-4246-8461-c24189194ed2	DU-2016-2017-A-Unit.pdf	Dhaka University	2016-2017	A	9	/app/data/results/Dhaka_University_2016-17_unit_A_mcq.json	2026-04-27 17:34:47.300026+00	admission_test	mcq	\N	\N	\N	\N	/app/data/results/Dhaka_University_2016-17_unit_A_mcq.pdf
ccdf4d8c-7726-4a78-be51-49d2cc7e4401	DU-2017-2018-A-Unit.pdf	Dhaka University	2017-2018	A	10	/app/data/results/Dhaka_University_2017-18_unit_A_mcq.json	2026-04-27 17:34:47.394232+00	admission_test	mcq	\N	\N	\N	\N	/app/data/results/Dhaka_University_2017-18_unit_A_mcq.pdf
e1714ea9-0d01-4643-a7e5-d57e77196296	DU-2019-2020-A-Unit.pdf	Dhaka University	2019-2020	A	6	/app/data/results/Dhaka_University_2019-20_unit_A_mcq.json	2026-04-27 17:34:47.579053+00	admission_test	mcq	\N	\N	\N	\N	/app/data/results/Dhaka_University_2019-20_unit_A_mcq.pdf
e50bdce2-e49e-4b4a-8279-da972fe9d089	DU-2020-2021-A-Unit.pdf	Dhaka University	2020-2021	A	5	/app/data/results/Dhaka_University_2020-21_unit_A_mcq.json	2026-04-27 17:34:47.627909+00	admission_test	mcq	\N	\N	\N	\N	/app/data/results/Dhaka_University_2020-21_unit_A_mcq.pdf
05a449d9-5db0-488f-936f-ab50cc72299e	DU-2021-2022-A-Unit.pdf	Dhaka University	2021-2022	A	6	/app/data/results/Dhaka_University_2021-22_unit_A_mcq.json	2026-04-27 17:34:47.677589+00	admission_test	mcq	\N	\N	\N	\N	/app/data/results/Dhaka_University_2021-22_unit_A_mcq.pdf
b1329360-5b77-4c9f-a5a9-5e5652a9c99b	DU-2022-2023-A-Unit.pdf	Dhaka University	2022-2023	A	6	/app/data/results/Dhaka_University_2022-23_unit_A_mcq.json	2026-04-27 17:34:47.727988+00	admission_test	mcq	\N	\N	\N	\N	/app/data/results/Dhaka_University_2022-23_unit_A_mcq.pdf
b0c3348a-46af-4e00-a298-7006c2a9785f	DU-2023-2024-A-Unit.pdf	Dhaka University	2023-2024	বিজ্ঞান ইউনিট	5	/app/data/results/Dhaka_University_2023-24_unit___mcq.json	2026-04-27 17:34:47.777291+00	admission_test	mcq	\N	\N	\N	\N	/app/data/results/Dhaka_University_2023-24_unit___mcq.pdf
55086422-ef06-4659-a0be-10579b6abde5	DU-2018-2019-A-Unit.pdf	Dhaka University	2018-2019	A	10	/app/data/results/Dhaka_University_2018-19_unit_A_mcq.json	2026-04-27 18:29:38.654719+00	admission_test	mcq	\N	\N	\N	\N	/app/data/results/Dhaka_University_2018-19_unit_A_mcq.pdf
\.


--
-- Data for Name: hsc_mcq_options; Type: TABLE DATA; Schema: public; Owner: exambank
--

COPY public.hsc_mcq_options (id, question_id, label, text, display_order, image_filename) FROM stdin;
\.


--
-- Data for Name: hsc_mcq_questions; Type: TABLE DATA; Schema: public; Owner: exambank
--

COPY public.hsc_mcq_questions (id, paper_id, question_number, question_text, board_name, exam_year, subject, subject_paper, chapter, correct_answer, solution, solution_status, created_at, images, gemini_solution, gemini_correct_answer) FROM stdin;
\.


--
-- Data for Name: hsc_written_questions; Type: TABLE DATA; Schema: public; Owner: exambank
--

COPY public.hsc_written_questions (id, paper_id, question_number, board_name, exam_year, subject, subject_paper, uddipak_text, uddipak_has_image, created_at, images) FROM stdin;
\.


--
-- Data for Name: hsc_written_subparts; Type: TABLE DATA; Schema: public; Owner: exambank
--

COPY public.hsc_written_subparts (id, question_id, label, marks, text, display_order, solution, solution_status) FROM stdin;
\.


--
-- Data for Name: quiz_status; Type: TABLE DATA; Schema: public; Owner: exambank
--

COPY public.quiz_status (subject, exam_type, status, updated_at, updated_by_id) FROM stdin;
mathematics	admission_test	archived	2026-04-28 12:50:03.236943+00	0ebac587-eccd-42a9-b693-915ee1917c51
physics	admission_test	published	2026-04-29 14:02:36.775408+00	0ebac587-eccd-42a9-b693-915ee1917c51
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: exambank
--

COPY public.refresh_tokens (id, user_id, token_hash, issued_at, expires_at, revoked_at, replaced_by_id, user_agent, ip) FROM stdin;
f2311121-d2d5-49a9-b3aa-aca55df0f121	0ebac587-eccd-42a9-b693-915ee1917c51	05366726f8421f3d9fbe8a729fe09d5b7b6a047265aced76d2770b0c89249eae	2026-04-28 04:44:39.157685+00	2026-05-28 04:44:39.164217+00	2026-04-28 05:19:27.563024+00	ac0ad4a6-1c83-419b-ae7b-55a85967850a	\N	\N
a7a1fa0d-9e6b-4ea0-ae40-0d541927241c	c5dc66e4-2ed6-4028-99f0-4969e5882244	bfff1c9d28ab364558e4aa33708ac562c2ec2a7c1deffaad7bc172f7f568e7a4	2026-04-28 05:25:31.643257+00	2026-05-28 05:25:31.675613+00	\N	\N	curl/8.7.1	192.168.97.1
e68a920e-620d-46dc-ae05-285a91d65510	0ebac587-eccd-42a9-b693-915ee1917c51	1f0458b0d9cb1b0652afab820c89ce1a4138e23534eb799e443b187099df0e41	2026-04-28 03:55:33.734008+00	2026-05-28 03:55:33.780569+00	\N	\N	curl/8.7.1	192.168.97.1
156fc634-f2dc-4ada-aa6b-5b760cedd1bd	1d6fd74c-d441-46c0-b1a8-f0bbe67aaccf	ab4fdc734a215a11124c8162bf63bcd8781bbabb1f9d43aeb35a7890cec6e98e	2026-04-28 03:57:10.891918+00	2026-05-28 03:57:10.928296+00	2026-04-28 03:57:34.385707+00	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	192.168.97.1
217c4281-38ba-41d4-8328-ddf81a550075	1d6fd74c-d441-46c0-b1a8-f0bbe67aaccf	042cfba6efdf07c9849973356d9c77bcb92dca5fa581455375ea5dd0d400faee	2026-04-28 03:48:10.980927+00	2026-05-28 03:48:11.0087+00	2026-04-28 03:57:59.418798+00	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	192.168.97.1
4c6c4f13-b8a9-4675-a02c-041d563eb77f	44654123-7595-4670-9b2e-2b72b827f103	a77d999a9da6975923b53a1f9ac1cf7f277c0e5078ffe183b3da317aea904228	2026-04-28 04:01:44.12224+00	2026-05-28 04:01:44.148031+00	2026-04-28 04:02:43.72312+00	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	192.168.97.1
14c9d417-1296-496d-a8b4-7b333271c011	875a8ff1-8dde-411a-b215-085f658c69e8	6cee719572b7c9396d843bf6865d336a96e7af0dae7700e74f14f074f6195efe	2026-04-28 04:27:45.860849+00	2026-05-28 04:27:45.904672+00	\N	\N	curl/8.7.1	192.168.97.1
58bebc3a-7c03-47a1-a682-9fec75d3652b	e9348327-0598-46fe-9317-865e92fc6bec	137755face42b8c2a181025ace7b11907d5decb96adfaa7f7b00ec30647c2fe0	2026-04-28 04:27:51.296843+00	2026-05-28 04:27:51.340669+00	\N	\N	curl/8.7.1	192.168.97.1
c8c9d4d8-b990-406c-bb62-2d0384c44de0	50482f77-6b7c-45ce-bf84-5e3f0a4e94ee	804d0972b80512a4e103cb48bedee6bf520eeeaa9f5b6f7bbe0f628bf1689982	2026-04-28 04:28:28.096786+00	2026-05-28 04:28:28.129014+00	\N	\N	curl/8.7.1	192.168.97.1
ab759227-11cf-4e17-899f-3b60ea6e8dd0	3c414f2e-b3ac-4f0b-aed7-ab1c158b8b0f	bf1fbd2c23e8971a7ea456fd35a35d63527b986372392eec0c91401c23121fc0	2026-04-28 05:25:43.286122+00	2026-05-28 05:25:43.328901+00	\N	\N	curl/8.7.1	192.168.97.1
a0f82d20-2fc3-4f23-b956-0452e7ffd27c	0ebac587-eccd-42a9-b693-915ee1917c51	5d2a2016fe34df3c4cc3846bd160a3bd309533319fdcd3d0b98fa30ec6ca837b	2026-04-28 04:02:54.991831+00	2026-05-28 04:02:55.035831+00	2026-04-28 04:28:57.917779+00	5eeacb1c-6db5-4b46-b5cc-3436cae0b2cb	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	192.168.97.1
cd9ee3c3-f4c1-43e1-9fe1-d07ffe605a1b	3c414f2e-b3ac-4f0b-aed7-ab1c158b8b0f	4fc1c48e284dc69bf8b4d00a64a634b2d13978469127b85d2fa0552646708005	2026-04-28 05:25:51.116867+00	2026-05-28 05:25:51.145716+00	\N	\N	curl/8.7.1	192.168.97.1
ec6ae23b-4b31-4004-8c4a-0f99fd6b2f5f	44654123-7595-4670-9b2e-2b72b827f103	a37507b77e5e68217cf5258d03e7eefc00466bed73d6f4a9e9a37436524d449f	2026-04-28 04:04:43.339256+00	2026-05-28 04:04:43.38361+00	2026-04-28 04:32:10.553991+00	77fcb0bd-dd94-4a37-a06c-398743940842	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	192.168.97.1
e12f69bc-8c17-4885-89e3-7afdcb39a269	4ad7e221-7631-481f-99a5-3b710af24154	1fcc844a5e2f2209ef4a6d495d3b4a7c02ff12d0b9da11667cb37215b4f4187b	2026-04-28 05:26:01.396628+00	2026-05-28 05:26:01.440043+00	\N	\N	curl/8.7.1	192.168.97.1
5eeacb1c-6db5-4b46-b5cc-3436cae0b2cb	0ebac587-eccd-42a9-b693-915ee1917c51	99718cd5f55142a656fc5d66be67fce591f32cb62d53e76b681a57fa0b9857d1	2026-04-28 04:28:57.91643+00	2026-05-28 04:28:57.91902+00	2026-04-28 04:44:39.160921+00	f2311121-d2d5-49a9-b3aa-aca55df0f121	\N	\N
5e16e14b-6c73-4d06-bf65-95fbd7eefcd5	6d9eaffd-5659-4afd-b2a2-7b6c5e4ef8cb	0b68e207db890f5ea6fcd6ffe3471072ed54f479aec74422aca42e75d981f1f1	2026-04-28 05:58:04.852813+00	2026-05-28 05:58:04.855666+00	2026-04-28 06:27:28.012809+00	cdb71146-1b31-426f-901e-2ec166eced03	\N	\N
65bfcee5-cc46-4edc-bc17-c5c03400cbef	3c414f2e-b3ac-4f0b-aed7-ab1c158b8b0f	c9bbd965f3a41774178f967d6af9afda42dde07628f7b388d6d6721f504d9211	2026-04-28 05:26:14.067592+00	2026-05-28 05:26:14.099581+00	\N	\N	curl/8.7.1	192.168.97.1
21c8b1d0-c5c2-4eb0-b901-73aa150a771d	6d9eaffd-5659-4afd-b2a2-7b6c5e4ef8cb	810d25fe0c0cf4eb9b96ecb7d73e418e2a42da2bcf7b6307ad9c8ea5a0fe7e54	2026-04-28 07:02:25.467266+00	2026-05-28 07:02:25.468933+00	2026-04-28 07:17:26.016256+00	abdbb5a4-46a9-4347-9ad1-1ee68fc95729	\N	\N
77fcb0bd-dd94-4a37-a06c-398743940842	44654123-7595-4670-9b2e-2b72b827f103	9422f6e7c4767829b11e27b365d86fca6c930b1c8626fe440d98d9d5a5a512f5	2026-04-28 04:32:10.55248+00	2026-05-28 04:32:10.557505+00	2026-04-28 05:30:07.759778+00	4b66e8b5-c79c-49fd-903b-cc6251947d1f	\N	\N
ac0ad4a6-1c83-419b-ae7b-55a85967850a	0ebac587-eccd-42a9-b693-915ee1917c51	762e90b66c2f451b9f25337eab02d013f08ecedfb7dd0e98c80997b263fab59a	2026-04-28 05:19:27.561553+00	2026-05-28 05:19:27.564275+00	2026-04-28 05:37:47.73225+00	e5348972-a7b9-43a4-bf40-4bb9f1bd1017	\N	\N
4b66e8b5-c79c-49fd-903b-cc6251947d1f	44654123-7595-4670-9b2e-2b72b827f103	2fde3d7bf65d00f3a3d4b90658c448dfa11c0eac22ec0867794fa26f856aa2e0	2026-04-28 05:30:07.758218+00	2026-05-28 05:30:07.760896+00	2026-04-28 05:42:06.96563+00	\N	\N	\N
c9e93f94-be12-4988-9698-f6b39ff3eae6	0ebac587-eccd-42a9-b693-915ee1917c51	b74a94209572794af2848a48d23d8507c349b4c9f7891bfd819494e0eda1eca4	2026-04-28 05:58:04.830894+00	2026-05-28 05:58:04.832822+00	2026-04-28 06:30:20.296125+00	0ffc17f3-7ce6-47ea-9e43-1455dfbeb848	\N	\N
e5348972-a7b9-43a4-bf40-4bb9f1bd1017	0ebac587-eccd-42a9-b693-915ee1917c51	dae0aa27182de02a9f23f101fedcc37c5f4decddd3e88eec0319fb49c99b7771	2026-04-28 05:37:47.726959+00	2026-05-28 05:37:47.736051+00	2026-04-28 05:58:04.831808+00	c9e93f94-be12-4988-9698-f6b39ff3eae6	\N	\N
9103daa1-7611-4744-9c5b-66d235ddda7a	8a49c999-76e3-4ba0-8709-108a1f330d6a	a1eea53cada4b9279feda02b19a3fcb353f2ebb7bfab07774dce78602d41a9ec	2026-04-28 06:37:47.583149+00	2026-05-28 06:37:47.612002+00	\N	\N	curl/8.7.1	192.168.97.1
09c0fd8f-6838-4bd5-ae66-d7cabeee8c3a	6d9eaffd-5659-4afd-b2a2-7b6c5e4ef8cb	33ef42a3fa650eb420cd447a7f8d81b7a8ef489f563dda90030d9d5a40420ba2	2026-04-28 05:42:28.07784+00	2026-05-28 05:42:28.122758+00	2026-04-28 05:58:04.854342+00	5e16e14b-6c73-4d06-bf65-95fbd7eefcd5	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	192.168.97.1
8b76fa63-a4a1-4ef6-8673-7e1890032940	0c16584a-8291-4167-a175-b0ce21b3fd03	0e05a0db365c9bb0837c482be1b0f009aa0bfdd21f6202979c66d76ec5562435	2026-04-28 06:02:01.587245+00	2026-05-28 06:02:01.617751+00	\N	\N	curl/8.7.1	192.168.97.1
fb537032-85cf-42ab-b6ec-c37e3bbc1c5c	ddcc9450-c448-4080-97cb-3e9d1db2e42f	4e26ea5fdbd416bf46e090feb1c726ac9dc3e358f470f749b60c2e10c1b62faf	2026-04-28 06:37:59.190792+00	2026-05-28 06:37:59.23159+00	\N	\N	curl/8.7.1	192.168.97.1
e1cfb463-dbea-48d2-837e-4038761f412d	0ebac587-eccd-42a9-b693-915ee1917c51	298de71540e6349cf16f1890a06e0a0dee76b7ee3e8a13f3bfef63624d32f98a	2026-04-28 06:45:20.093942+00	2026-05-28 06:45:20.098692+00	2026-04-28 07:02:00.232769+00	04526477-2aeb-4b20-8a47-3e06ba24c719	\N	\N
cdb71146-1b31-426f-901e-2ec166eced03	6d9eaffd-5659-4afd-b2a2-7b6c5e4ef8cb	21d94e56d128ddf030b33badd6a47ab5424e53fb564f250babd67a7d5d45b98e	2026-04-28 06:27:28.010842+00	2026-05-28 06:27:28.013426+00	2026-04-28 06:42:39.251513+00	79b9c061-0e47-448b-85f4-740bd5ec302d	\N	\N
abdbb5a4-46a9-4347-9ad1-1ee68fc95729	6d9eaffd-5659-4afd-b2a2-7b6c5e4ef8cb	7e08c9ba5f342ffe4122f1607fe72d51ebf326e22ca1f6d209e8c369b5764a5f	2026-04-28 07:17:26.014761+00	2026-05-28 07:17:26.017027+00	2026-04-28 07:37:26.293192+00	d3088b75-8bdd-4558-899e-8f583f12111a	\N	\N
0ffc17f3-7ce6-47ea-9e43-1455dfbeb848	0ebac587-eccd-42a9-b693-915ee1917c51	2e5ae04f2cd5e022264b3a9ab42e4d59afde46f1493f68c80446ca9558835a5b	2026-04-28 06:30:20.294591+00	2026-05-28 06:30:20.296896+00	2026-04-28 06:45:20.095231+00	e1cfb463-dbea-48d2-837e-4038761f412d	\N	\N
79b9c061-0e47-448b-85f4-740bd5ec302d	6d9eaffd-5659-4afd-b2a2-7b6c5e4ef8cb	3332b2b1ba72c0e04afe475027e17a3acf7647fc2988937b45c5145718d4da22	2026-04-28 06:42:39.249577+00	2026-05-28 06:42:39.255673+00	2026-04-28 07:02:25.46794+00	21c8b1d0-c5c2-4eb0-b901-73aa150a771d	\N	\N
04526477-2aeb-4b20-8a47-3e06ba24c719	0ebac587-eccd-42a9-b693-915ee1917c51	587a82eb99b2e141a003382b8a93316d796c70c49ab0826e480940b27fa86d21	2026-04-28 07:02:00.231965+00	2026-05-28 07:02:00.233656+00	2026-04-28 07:22:41.688117+00	dfcdcd82-9a8a-44fc-83f1-eb4c4a97c9db	\N	\N
d3088b75-8bdd-4558-899e-8f583f12111a	6d9eaffd-5659-4afd-b2a2-7b6c5e4ef8cb	b0cf5ccf3c9dc26277064034324ac838c0fe54033882ab1637ce48b74123102b	2026-04-28 07:37:26.29249+00	2026-05-28 07:37:26.294017+00	2026-04-28 07:41:44.976906+00	\N	\N	\N
dfcdcd82-9a8a-44fc-83f1-eb4c4a97c9db	0ebac587-eccd-42a9-b693-915ee1917c51	bf83f4320be9bd5507972f3bf32a8cd02a7820e64db191ec5b9bd3b31f483825	2026-04-28 07:22:41.687393+00	2026-05-28 07:22:41.689636+00	2026-04-28 07:38:09.931436+00	8881aee0-58bc-4cc6-83df-14e3969e321d	\N	\N
b500bd33-50a1-4619-b309-2d9d5ba5f26a	cc384a5f-057f-4fed-9413-34aa09620c07	9af692801ca0567804f753f37efa19cb59ccbf3450b3f52444563ff3c7ab7084	2026-04-28 07:39:24.145808+00	2026-05-28 07:39:24.17535+00	\N	\N	curl/8.7.1	192.168.97.1
983abae7-e6c2-4e16-8b17-535dc1a35b91	c00baaf7-94dd-4b0a-a92b-f010736f1ede	4e34901373d3e89f7bf545839b16c71283c865ceb88c8bc0bb7620c55b4eda32	2026-04-28 07:39:37.78585+00	2026-05-28 07:39:37.81314+00	\N	\N	curl/8.7.1	192.168.97.1
9cd7501e-9568-46ec-803f-9b8429d124f4	3c414f2e-b3ac-4f0b-aed7-ab1c158b8b0f	b856e8ab80f89da6aeafca4c3ab7d4b9ef79b4c5d130dd0ca7f82a0e38d2e20b	2026-04-28 07:39:56.700891+00	2026-05-28 07:39:56.745423+00	\N	\N	curl/8.7.1	192.168.97.1
8881aee0-58bc-4cc6-83df-14e3969e321d	0ebac587-eccd-42a9-b693-915ee1917c51	db27e2dee600c97cb4f410c2db86c6276c4b53ab9a370807a515f0dc391f803a	2026-04-28 07:38:09.928744+00	2026-05-28 07:38:09.933116+00	2026-04-28 08:07:38.48176+00	599d599f-9b36-4625-b8b0-529b8e719f26	\N	\N
fd5e1736-1842-40ea-9996-377714c29e7a	eccc1ab0-dea0-4422-953d-3a820e512907	0bfa488a2cc8c15e7e2ebb9719afedf90dc38fd6788f3a6fc36f8a685977453a	2026-04-28 09:40:27.99434+00	2026-05-28 09:40:27.997121+00	2026-04-28 11:18:28.699878+00	6abaf9c1-7366-4f83-9857-93485e3c0b81	\N	\N
25c42405-f01c-4a5a-b1ad-fedfeda3c9fe	eccc1ab0-dea0-4422-953d-3a820e512907	67b80b744e1f48a047e8a6ea3b906f5e58ee8512059d8f177a71324963141916	2026-04-28 07:42:34.270113+00	2026-05-28 07:42:34.30947+00	2026-04-28 08:07:40.320531+00	cad46739-f840-4e95-a912-24b3f4153108	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	192.168.97.1
599d599f-9b36-4625-b8b0-529b8e719f26	0ebac587-eccd-42a9-b693-915ee1917c51	a6d1815a639df955bc65cb3750381151755b47727ac87570da6851a1a4fefbc8	2026-04-28 08:07:38.47588+00	2026-05-28 08:07:38.48514+00	2026-04-28 08:10:57.535007+00	\N	\N	\N
65543976-2653-432f-9c47-f8af81b2e2a7	eccc1ab0-dea0-4422-953d-3a820e512907	442587d039046c1ba0480cf7777f1d6ab0c64d2a4f87ae592e1245395fcaac4b	2026-04-28 08:11:21.897223+00	2026-05-28 08:11:21.943691+00	2026-04-28 08:12:31.9629+00	\N	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Mobile Safari/537.36	192.168.97.1
f976fcff-5dc4-49ec-baa0-dcc7f81d2382	7fdaa405-67d8-4a9f-818e-7d44ca123eb7	236d3a6a39762fc65edc9feb5c706ba33b293dd60e564433f3905a90d6cba4f3	2026-04-28 13:04:26.945756+00	2026-05-28 13:04:26.94945+00	2026-04-28 13:25:05.796621+00	9b4fdb92-915e-4c56-a96d-4533064c854c	\N	\N
0be9b44d-fb7d-4e18-8a99-35e1dd679d24	0ebac587-eccd-42a9-b693-915ee1917c51	312521297ba2e28d7b11690952ff93d3ad1a8acd65021903e4e6d617df71f8a5	2026-04-28 08:13:20.432454+00	2026-05-28 08:13:20.481579+00	2026-04-28 08:28:50.17279+00	220ff94a-f242-4bb6-8447-c9f2798df282	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Mobile Safari/537.36	192.168.97.1
cad46739-f840-4e95-a912-24b3f4153108	eccc1ab0-dea0-4422-953d-3a820e512907	c8cb39aeb95a8be810b9aac7789dbb9faa2a43f9ac7fdfdb6d19299420df159a	2026-04-28 08:07:40.314317+00	2026-05-28 08:07:40.323104+00	2026-04-28 08:40:04.988076+00	eaf17470-17a1-4e97-83b2-5140c3d67846	\N	\N
6abaf9c1-7366-4f83-9857-93485e3c0b81	eccc1ab0-dea0-4422-953d-3a820e512907	1be074aae2b9b93c21c0333ab1bae81512737350cf99099537ae99fa53004572	2026-04-28 11:18:28.698496+00	2026-05-28 11:18:28.703347+00	2026-04-28 12:12:34.281894+00	7b03a7f5-b7a9-4aac-98d7-484339fd5d56	\N	\N
220ff94a-f242-4bb6-8447-c9f2798df282	0ebac587-eccd-42a9-b693-915ee1917c51	eacb8fa3a7d9a4c42335e2e7ab5d813a601489347df582d50dedbd81bfbab264	2026-04-28 08:28:50.172209+00	2026-05-28 08:28:50.173893+00	2026-04-28 08:48:08.690578+00	59e7a6d6-34f8-4982-9c37-49f40c10eb16	\N	\N
eaf17470-17a1-4e97-83b2-5140c3d67846	eccc1ab0-dea0-4422-953d-3a820e512907	642c263bdb9b5175ffff15e3ccd72fe6522f15f661ddc8ac2ac378aa086c2c4f	2026-04-28 08:40:04.98661+00	2026-05-28 08:40:04.989507+00	2026-04-28 08:55:05.120719+00	fd2a3344-8edf-4c96-b777-2f96df694cfc	\N	\N
ecfa8517-5d8d-4b72-b17e-da6b060319f3	0ebac587-eccd-42a9-b693-915ee1917c51	64d7ca4173ecda8a2f3c152beadecbc378521c4c4ee6f291ce153f9294c9f3ae	2026-04-28 09:05:34.574355+00	2026-05-28 09:05:34.577152+00	\N	\N	\N	\N
59e7a6d6-34f8-4982-9c37-49f40c10eb16	0ebac587-eccd-42a9-b693-915ee1917c51	67ae8ad8b7f3dc5e3e4dde09942b5c94154411884af8225dc8d6bc572aa01119	2026-04-28 08:48:08.690256+00	2026-05-28 08:48:08.691232+00	2026-04-28 09:05:34.576323+00	ecfa8517-5d8d-4b72-b17e-da6b060319f3	\N	\N
da98a687-65b5-4792-80fe-1cc8de871855	0ebac587-eccd-42a9-b693-915ee1917c51	cd4bbd3aad85bcb5bd62e9f10867878f02ea21c427134a72f80919e9119e1517	2026-04-28 12:15:15.327769+00	2026-05-28 12:15:15.331506+00	\N	\N	\N	\N
fd2a3344-8edf-4c96-b777-2f96df694cfc	eccc1ab0-dea0-4422-953d-3a820e512907	64472251be88f04006c64d142ed71e0d7ea416ecfe00f42cbdc9ff45b0410ea0	2026-04-28 08:55:05.11726+00	2026-05-28 08:55:05.12234+00	2026-04-28 09:21:18.478579+00	1ab71830-d4f0-497e-a452-e484efd07e3a	\N	\N
4894b948-637c-4a10-bcbf-32bfa7fa14b3	0ebac587-eccd-42a9-b693-915ee1917c51	7672db0f747cfd53ec7097e1258dd181fe93802193a46915bfa3cce444ae5db4	2026-04-28 09:34:53.140973+00	2026-05-28 09:34:53.142325+00	2026-04-28 12:15:15.329619+00	da98a687-65b5-4792-80fe-1cc8de871855	\N	\N
76e8c503-d3f5-43e1-9c66-ad4d72b3c558	0ebac587-eccd-42a9-b693-915ee1917c51	8d968f5fb1eb7175b933f75525575aabe96014dcb2d97d0e01e13672b7a4e012	2026-04-28 09:07:42.567708+00	2026-05-28 09:07:42.60877+00	2026-04-28 09:34:53.141533+00	4894b948-637c-4a10-bcbf-32bfa7fa14b3	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	192.168.97.1
1ab71830-d4f0-497e-a452-e484efd07e3a	eccc1ab0-dea0-4422-953d-3a820e512907	09fe6755e7d79de92dd0edd7f81f76cc034dcb4977da2dfb3776f18292a7a947	2026-04-28 09:21:18.476325+00	2026-05-28 09:21:18.479765+00	2026-04-28 09:40:27.995614+00	fd5e1736-1842-40ea-9996-377714c29e7a	\N	\N
0d712df7-097d-4cd5-b37e-e198c10f60c9	0ebac587-eccd-42a9-b693-915ee1917c51	5f6f48b7729378c3449ab0e15fd9f0ee3762aae01d0db077cd5aaed43abb460a	2026-04-28 12:38:50.018438+00	2026-05-28 12:38:50.026311+00	2026-04-28 12:56:31.648136+00	990edc20-99fb-4b6c-ae5e-b31d478f6a7e	\N	\N
6b3865c7-e653-4efe-ad34-1e002481bfef	eccc1ab0-dea0-4422-953d-3a820e512907	b75a5b2948d15a3ff6c7d25b8378ba0da5be2b655f106347c5f96c098bf158b0	2026-04-28 12:14:05.853632+00	2026-05-28 12:14:05.901526+00	2026-04-28 12:34:22.007784+00	abc34aad-7c17-4f2f-9fcd-a76dd5370e22	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	192.168.97.1
28f64e88-9d3a-4692-a8c2-546cea7f2cef	0ebac587-eccd-42a9-b693-915ee1917c51	607417265703cf30a5a72312f7a8e836f5ddcd32ee38e53258b453d7d441340f	2026-04-28 12:15:38.971594+00	2026-05-28 12:15:39.015973+00	2026-04-28 12:38:50.023412+00	0d712df7-097d-4cd5-b37e-e198c10f60c9	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	192.168.97.1
4338769c-7c2a-43e2-9ed8-7f9188931509	d4fd0752-82a0-45fb-828a-4aa1d7328c2c	7309f078ac576419b7ffb0099fc9de71945d8f175448f8643198c9af1578927a	2026-04-28 12:47:00.844064+00	2026-05-28 12:47:00.888858+00	2026-04-28 13:02:22.186907+00	1e3e7d41-52c7-459d-af0d-f498b700727f	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	192.168.97.1
1eaf7236-f051-4a86-97ce-1b817c5e944c	d5393b18-6a59-4133-a743-10c9bdc3d16b	d55043e398677d54ff30ce42447f8086453d403781473d09d0b03b6096c905e6	2026-04-28 12:56:20.24065+00	2026-05-28 12:56:20.282341+00	2026-04-28 13:11:25.627491+00	93b21228-bf70-4fb8-b2f7-fa6ac00e2d60	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Mobile Safari/537.36	192.168.97.1
ab97ed4a-7896-49c0-a234-8e09968f0892	7fdaa405-67d8-4a9f-818e-7d44ca123eb7	698b870eb164d839e6941eb6b2158995f52cfa4447d416d08ae8a1455af78f79	2026-04-28 12:48:17.466292+00	2026-05-28 12:48:17.502083+00	2026-04-28 13:04:26.948466+00	f976fcff-5dc4-49ec-baa0-dcc7f81d2382	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	192.168.97.1
1e3e7d41-52c7-459d-af0d-f498b700727f	d4fd0752-82a0-45fb-828a-4aa1d7328c2c	bc8e27dbfc94898f42fa6d6ed1b2710f34b49af64bd3602f35258e137ceee302	2026-04-28 13:02:22.181875+00	2026-05-28 13:02:22.188825+00	2026-04-28 13:17:48.239212+00	8c0d1f9e-0474-4906-8b87-5f8e1927a0bb	\N	\N
93b21228-bf70-4fb8-b2f7-fa6ac00e2d60	d5393b18-6a59-4133-a743-10c9bdc3d16b	b932a41b66e5ce0f018fad323912eb4f482d3b4389488dacbe28d08483836424	2026-04-28 13:11:25.624439+00	2026-05-28 13:11:25.62885+00	2026-04-28 13:26:41.654101+00	e139f6cb-d1be-422f-8b51-60f2d755dccb	\N	\N
abc34aad-7c17-4f2f-9fcd-a76dd5370e22	eccc1ab0-dea0-4422-953d-3a820e512907	47a7b2f1faa4bb823126c6759d7275a45f10b1407b177d0d038798392d5c4bc3	2026-04-28 12:34:22.004476+00	2026-05-28 12:34:22.010271+00	2026-04-28 13:28:14.446196+00	3616f1bc-eba8-4451-936a-2642727c76d1	\N	\N
990edc20-99fb-4b6c-ae5e-b31d478f6a7e	0ebac587-eccd-42a9-b693-915ee1917c51	a4fec071ade4b629e3213d5942116f4fc9b87ffb9004411b8dd090ceb0a2e8a1	2026-04-28 12:56:31.646766+00	2026-05-28 12:56:31.649828+00	2026-04-28 13:28:14.445584+00	05f867a9-399b-42de-9a58-5ceb5629aca7	\N	\N
8c0d1f9e-0474-4906-8b87-5f8e1927a0bb	d4fd0752-82a0-45fb-828a-4aa1d7328c2c	1d3a066cbf609333670c2936b28bb9d6bcf64bf79468ad5e5bb8a870f84c388b	2026-04-28 13:17:48.238012+00	2026-05-28 13:17:48.240579+00	2026-04-28 13:32:56.84458+00	12d3d024-3549-40f9-8bfc-af2c19ef1dfa	\N	\N
9b4fdb92-915e-4c56-a96d-4533064c854c	7fdaa405-67d8-4a9f-818e-7d44ca123eb7	a8b62fd1147e6d423151e9963b4fb26379b2730d0fd2092436504eb1e7a328c4	2026-04-28 13:25:05.795543+00	2026-05-28 13:25:05.799163+00	2026-04-28 13:40:17.699049+00	ad2a6cf9-ea99-4dd6-9fff-8051ccb8c1cc	\N	\N
e139f6cb-d1be-422f-8b51-60f2d755dccb	d5393b18-6a59-4133-a743-10c9bdc3d16b	f211dced55556ea67c53d5e931d7882c4b7ec8352b15e4644dd93cb0739cc6fe	2026-04-28 13:26:41.651869+00	2026-05-28 13:26:41.657661+00	2026-04-28 13:43:10.09639+00	d4f6fcc1-41e9-4da0-8c38-dc2c08032c4f	\N	\N
7b03a7f5-b7a9-4aac-98d7-484339fd5d56	eccc1ab0-dea0-4422-953d-3a820e512907	84bd64db803452c5180441b5999ea2ceb06e34c9004e02d4fd4ffaa2b7d90b24	2026-04-28 12:12:34.275278+00	2026-05-28 12:12:34.284557+00	2026-04-28 13:58:03.033824+00	f87df02d-7641-4788-94bf-c8aa12b28377	\N	\N
05f867a9-399b-42de-9a58-5ceb5629aca7	0ebac587-eccd-42a9-b693-915ee1917c51	a15542b7aba5c58d36f87f4db88b99ed42ae70585d138d5d00966f686d35dcd8	2026-04-28 13:28:14.443326+00	2026-05-28 13:28:14.447774+00	2026-04-28 13:58:55.373557+00	49d20b22-dd62-40f1-9b36-2e9dfbd52026	\N	\N
2ef29c82-5efa-423a-9789-ba1111b5db01	d4fd0752-82a0-45fb-828a-4aa1d7328c2c	d9f97a1b5b1fb8876e61252a007118654f33a22c195fd76483fb16161530a603	2026-04-28 13:48:24.944313+00	2026-05-28 13:48:24.950869+00	2026-04-28 14:03:42.636789+00	42ad2f5e-a8df-4f36-8be9-8d88227b8356	\N	\N
031aefb5-4c12-4405-a197-1b7076ca9635	d5393b18-6a59-4133-a743-10c9bdc3d16b	4c331b1f6cd2cddba1562a3155e0c4bb26ed047841b07896091c47f999a4bfa7	2026-04-28 13:58:15.826846+00	2026-05-28 13:58:15.828794+00	2026-04-28 14:15:37.295756+00	70834185-ae2a-4f0b-9827-2f6a8e561463	\N	\N
3616f1bc-eba8-4451-936a-2642727c76d1	eccc1ab0-dea0-4422-953d-3a820e512907	d57ec5aebd6ed98bf3766532acc8ca8acc7a556f4cb827706ff8a46ab4efc2cb	2026-04-28 13:28:14.445966+00	2026-05-28 13:28:14.447337+00	2026-04-28 15:48:50.386499+00	c20c66c4-4da5-4d70-a385-1a57d402705b	\N	\N
12d3d024-3549-40f9-8bfc-af2c19ef1dfa	d4fd0752-82a0-45fb-828a-4aa1d7328c2c	30d006a871f46a69cb3ee72793ae5f67ff730fd25916087f132ed6da4fcc58cd	2026-04-28 13:32:56.8412+00	2026-05-28 13:32:56.846149+00	2026-04-28 13:48:24.948773+00	2ef29c82-5efa-423a-9789-ba1111b5db01	\N	\N
f87df02d-7641-4788-94bf-c8aa12b28377	eccc1ab0-dea0-4422-953d-3a820e512907	0b677e1d9152046184c281bd51724006bfe017d4e56712c22354c43893579024	2026-04-28 13:58:03.032226+00	2026-05-28 13:58:03.035097+00	2026-04-28 14:45:38.541714+00	e42434e7-a60a-4c5c-b3f4-fe78d539d26a	\N	\N
ad2a6cf9-ea99-4dd6-9fff-8051ccb8c1cc	7fdaa405-67d8-4a9f-818e-7d44ca123eb7	88835037a52f3b478267220da92a7efce1912e0020386a9944df674d3d238f82	2026-04-28 13:40:17.698029+00	2026-05-28 13:40:17.701936+00	2026-04-28 13:55:24.686085+00	1de4e28f-5d89-48b2-b97c-d91e4ab41521	\N	\N
d4f6fcc1-41e9-4da0-8c38-dc2c08032c4f	d5393b18-6a59-4133-a743-10c9bdc3d16b	0e497b9f50fdca3e09b3fe5e37839f93572ff54ac86b84d264e09d2ed634e6b8	2026-04-28 13:43:10.095151+00	2026-05-28 13:43:10.097142+00	2026-04-28 13:58:15.827632+00	031aefb5-4c12-4405-a197-1b7076ca9635	\N	\N
42ad2f5e-a8df-4f36-8be9-8d88227b8356	d4fd0752-82a0-45fb-828a-4aa1d7328c2c	e00d4997d73ef56f110dd1301a01b41234b8f016f47dbfa0c02329d83b00fb29	2026-04-28 14:03:42.63291+00	2026-05-28 14:03:42.643356+00	2026-04-28 14:19:04.506713+00	0eb2e1bc-5ff1-4d0e-afeb-0fb5bb7c046f	\N	\N
49d20b22-dd62-40f1-9b36-2e9dfbd52026	0ebac587-eccd-42a9-b693-915ee1917c51	dc13636d44b15b751f0bb6a39d299339f3ca7bddb582bda6a544225dadaf9b95	2026-04-28 13:58:55.371927+00	2026-05-28 13:58:55.375704+00	2026-04-28 14:26:57.072903+00	bd6eb337-1001-4269-b521-611c90af4807	\N	\N
70834185-ae2a-4f0b-9827-2f6a8e561463	d5393b18-6a59-4133-a743-10c9bdc3d16b	fd1ff9dd57df419692940876a5e5feab587a9a45eb6859260d1c3712c3e7eac5	2026-04-28 14:15:37.294709+00	2026-05-28 14:15:37.297365+00	2026-04-28 14:30:41.300692+00	4ed9ea7b-72b2-405e-98c6-1cf333de556b	\N	\N
1de4e28f-5d89-48b2-b97c-d91e4ab41521	7fdaa405-67d8-4a9f-818e-7d44ca123eb7	a497132a0e55f75ff36a211c452b539c10a2de43f037c5ef93f65760ecb67d92	2026-04-28 13:55:24.684856+00	2026-05-28 13:55:24.691758+00	2026-04-28 14:10:59.001686+00	39623cfd-57c9-4017-8777-331cc2cd49e4	\N	\N
39623cfd-57c9-4017-8777-331cc2cd49e4	7fdaa405-67d8-4a9f-818e-7d44ca123eb7	c9f61d93535b98243658537bec9904108dd21f85b91e9257b1ae40d221d32bf8	2026-04-28 14:10:59.000606+00	2026-05-28 14:10:59.005796+00	2026-04-28 14:26:48.736946+00	03b56f1d-e8b8-4005-94c0-50f3cb0cf064	\N	\N
e17feb05-96e2-4dfc-b58d-951a2602d38e	d5393b18-6a59-4133-a743-10c9bdc3d16b	56c9c76b00ac4b341e9b980492ed64f30675a534fadcdbb2386c5ab1e7f5402a	2026-04-28 16:32:19.268052+00	2026-05-28 16:32:19.274845+00	2026-04-28 17:42:41.431046+00	6c598858-ff03-4d0a-99df-b499591f7e71	\N	\N
0eb2e1bc-5ff1-4d0e-afeb-0fb5bb7c046f	d4fd0752-82a0-45fb-828a-4aa1d7328c2c	0a0f5fe77aad575878503f7ca474a9b10da61eb2ce0131645809505f74ad1ad9	2026-04-28 14:19:04.505105+00	2026-05-28 14:19:04.509628+00	2026-04-28 14:35:07.897756+00	5628555d-c83a-4631-912e-5401f8d8bc89	\N	\N
03b56f1d-e8b8-4005-94c0-50f3cb0cf064	7fdaa405-67d8-4a9f-818e-7d44ca123eb7	f74ce5d1a036809cb63f3bb7e0825870c22903edd77d088aaf47e50750cac4c8	2026-04-28 14:26:48.735025+00	2026-05-28 14:26:48.738349+00	2026-04-28 14:42:12.120307+00	71c93e3a-8ab7-4796-81e0-59769f59b024	\N	\N
24de6521-8ae6-4985-aa18-f3821d0bed6f	d4fd0752-82a0-45fb-828a-4aa1d7328c2c	66dc7b5ddbf4fab63128ca871ccd0d793b94f146dceeb9113bbef405c746da26	2026-04-28 15:09:17.564723+00	2026-05-28 15:09:17.567709+00	2026-04-28 15:25:14.473244+00	23d088aa-d683-44c0-8c70-dcb7d1708fa3	\N	\N
4ed9ea7b-72b2-405e-98c6-1cf333de556b	d5393b18-6a59-4133-a743-10c9bdc3d16b	83f24b96f3415f08ebd067bccdccbb1d2c70e337c50fe5b53232898e28cca917	2026-04-28 14:30:41.297569+00	2026-05-28 14:30:41.304603+00	2026-04-28 14:45:53.051914+00	03114df0-1443-4b32-9a95-d0d4ffdb198e	\N	\N
f7bf878e-b2a7-4308-a725-3d9aa2706959	0ebac587-eccd-42a9-b693-915ee1917c51	92b8c4cb853faf687a1ca89ee5fe0142e49b793c7acc14c13ea8d2a045d8f1f7	2026-04-28 14:47:52.605946+00	2026-05-28 14:47:52.610755+00	\N	\N	\N	\N
bd6eb337-1001-4269-b521-611c90af4807	0ebac587-eccd-42a9-b693-915ee1917c51	7220c60c04ffa5ee2d420f7a76870ee0729378499679bf3222cbbbfb8e2357d9	2026-04-28 14:26:57.071415+00	2026-05-28 14:26:57.073826+00	2026-04-28 14:47:52.607273+00	f7bf878e-b2a7-4308-a725-3d9aa2706959	\N	\N
5628555d-c83a-4631-912e-5401f8d8bc89	d4fd0752-82a0-45fb-828a-4aa1d7328c2c	9f94bbea65effe8b4ad5ccb1b582ff5f320ee717f4a33255e574da3ecbd6a023	2026-04-28 14:35:07.896222+00	2026-05-28 14:35:07.901868+00	2026-04-28 14:50:40.496857+00	2ccf11c7-ddd1-4c6c-b042-a73ae53cefd2	\N	\N
9ab62476-53ac-4ac6-9645-a2d567849051	d5393b18-6a59-4133-a743-10c9bdc3d16b	5419bb62c9e14e364baf5f20126e094ab07baeb77f0e050f0ff9df86b021887f	2026-04-28 15:23:08.026152+00	2026-05-28 15:23:08.029892+00	2026-04-28 15:38:19.515702+00	68327bd6-c105-4ce7-9f7e-a51fb0f0b948	\N	\N
e42434e7-a60a-4c5c-b3f4-fe78d539d26a	eccc1ab0-dea0-4422-953d-3a820e512907	e89d462d51932abdf6132818cfbf935bec4a65c7c76e0c39180d3a886ae8b935	2026-04-28 14:45:38.5398+00	2026-05-28 14:45:38.543857+00	2026-04-28 15:05:59.18907+00	229e3303-8277-497a-b2d8-0646f2da9278	\N	\N
9e41bab9-7b97-4695-b449-41ac20543768	0ebac587-eccd-42a9-b693-915ee1917c51	269d92a71d8c4e14504dd10561bd498b7e0e3df248d29975651901f21b797c7b	2026-04-28 15:17:37.98879+00	2026-05-28 15:17:38.03584+00	2026-04-28 16:04:46.351708+00	c1481008-dd9e-4f35-9051-03706b1ab6e1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	192.168.97.1
03114df0-1443-4b32-9a95-d0d4ffdb198e	d5393b18-6a59-4133-a743-10c9bdc3d16b	803124425e2dfc96aa315d4b58a3e082241d0e9030a0987845cf0b225900bba3	2026-04-28 14:45:53.050602+00	2026-05-28 14:45:53.053677+00	2026-04-28 15:07:56.159142+00	dddbfed4-100e-41fb-90b8-1089d99d78a7	\N	\N
71c93e3a-8ab7-4796-81e0-59769f59b024	7fdaa405-67d8-4a9f-818e-7d44ca123eb7	a09ab5c3ee64bf254760fe955a63a48766ffa7908febe2108dd0a7fc0410bf09	2026-04-28 14:42:12.116009+00	2026-05-28 14:42:12.121904+00	2026-04-28 15:08:53.376682+00	1972ccad-6a67-47a8-903a-35feec9e0f34	\N	\N
0cc8f85d-1aba-407b-b8e5-9794e0a443be	7fdaa405-67d8-4a9f-818e-7d44ca123eb7	c970175f9857c585d4703c3dde5203a34e6c8826c1ad78bb125b242d7eebae37	2026-04-28 15:24:17.502789+00	2026-05-28 15:24:17.507041+00	2026-04-28 15:40:43.65563+00	fd7483aa-67fa-4a00-bae2-612ff4342fcd	\N	\N
2ccf11c7-ddd1-4c6c-b042-a73ae53cefd2	d4fd0752-82a0-45fb-828a-4aa1d7328c2c	626240c82c9cb16caeebe9f9ee8da0740d679db02f6c29c6c9280606da2ed765	2026-04-28 14:50:40.495603+00	2026-05-28 14:50:40.499046+00	2026-04-28 15:09:17.566035+00	24de6521-8ae6-4985-aa18-f3821d0bed6f	\N	\N
229e3303-8277-497a-b2d8-0646f2da9278	eccc1ab0-dea0-4422-953d-3a820e512907	449081a4c24ed13d5077e349136a0135406904826c317d91e358f8bc1d7e17a5	2026-04-28 15:05:59.187355+00	2026-05-28 15:05:59.193638+00	2026-04-28 15:18:58.163829+00	\N	\N	\N
0191ee66-2899-4530-a2e9-fb5a0e6ff1a5	0ebac587-eccd-42a9-b693-915ee1917c51	a979d9d1ea856a49ac986cde6efad03deff3a6283af9839cc8895db866b2a4f8	2026-04-28 15:19:18.372779+00	2026-05-28 15:19:18.415353+00	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	192.168.97.1
dddbfed4-100e-41fb-90b8-1089d99d78a7	d5393b18-6a59-4133-a743-10c9bdc3d16b	38d71332a7811953a6c836dff0d999083d7a4150566d029b7a8c384f7ab46308	2026-04-28 15:07:56.157434+00	2026-05-28 15:07:56.160758+00	2026-04-28 15:23:08.026963+00	9ab62476-53ac-4ac6-9645-a2d567849051	\N	\N
1972ccad-6a67-47a8-903a-35feec9e0f34	7fdaa405-67d8-4a9f-818e-7d44ca123eb7	d676dada2a94c79d4e8c60f6f1a7d96bc8d127aeda8b81bf31a94060a8dd72da	2026-04-28 15:08:53.375801+00	2026-05-28 15:08:53.378574+00	2026-04-28 15:24:17.504382+00	0cc8f85d-1aba-407b-b8e5-9794e0a443be	\N	\N
23d088aa-d683-44c0-8c70-dcb7d1708fa3	d4fd0752-82a0-45fb-828a-4aa1d7328c2c	c544932b9377e59dd85c4fab82df1cba9a83f02aa5a41ae252043a31ab44de90	2026-04-28 15:25:14.472316+00	2026-05-28 15:25:14.474296+00	2026-04-28 15:42:29.499921+00	eef75208-b2c3-4234-ac2f-b888adb08707	\N	\N
81ccc662-a0c2-4013-b82c-9bf56eb41e64	d5393b18-6a59-4133-a743-10c9bdc3d16b	537b5d184147a7e7f4d5d8f4ebfd2a7e928442c4df1f85a3ccc4e83e1232b172	2026-04-28 15:54:27.097281+00	2026-05-28 15:54:27.100951+00	\N	\N	\N	\N
68327bd6-c105-4ce7-9f7e-a51fb0f0b948	d5393b18-6a59-4133-a743-10c9bdc3d16b	48440d5808ad2179219ef1c8cde30b8055bb296e9d113d353550bbc69ceafe7e	2026-04-28 15:38:19.514125+00	2026-05-28 15:38:19.518018+00	2026-04-28 15:54:27.099735+00	81ccc662-a0c2-4013-b82c-9bf56eb41e64	\N	\N
fd7483aa-67fa-4a00-bae2-612ff4342fcd	7fdaa405-67d8-4a9f-818e-7d44ca123eb7	489e73aa99010b49832be69d557d1749cf4530a3f9a3db6cd228ebf6977e4cbb	2026-04-28 15:40:43.65467+00	2026-05-28 15:40:43.657347+00	2026-04-28 15:56:22.834095+00	5f0fdefa-faeb-4b18-a60a-59a37e366ad9	\N	\N
5f0fdefa-faeb-4b18-a60a-59a37e366ad9	7fdaa405-67d8-4a9f-818e-7d44ca123eb7	226d78e7040a18651ca4b71b54f7331bb02bb3d7f6a75c74f9681eaa3b0d6d9f	2026-04-28 15:56:22.830704+00	2026-05-28 15:56:22.839218+00	2026-04-28 16:16:56.963734+00	91803e23-d53e-45d2-91eb-76605064d13c	\N	\N
86b90209-09c2-4150-becd-dddddb4448cf	d4fd0752-82a0-45fb-828a-4aa1d7328c2c	e0e8618ec496f7a64beb5c72f0bdffb5d1f3fa7fe71b54e47aa60bebd4c360d1	2026-04-28 15:57:42.13653+00	2026-05-28 15:57:42.144166+00	\N	\N	\N	\N
eef75208-b2c3-4234-ac2f-b888adb08707	d4fd0752-82a0-45fb-828a-4aa1d7328c2c	b5f3603c0b1ef18c2bb1b8f37ba9efff4fd41a1ee0209da387d2b64512a76c5c	2026-04-28 15:42:29.498948+00	2026-05-28 15:42:29.501543+00	2026-04-28 15:57:42.137209+00	86b90209-09c2-4150-becd-dddddb4448cf	\N	\N
91803e23-d53e-45d2-91eb-76605064d13c	7fdaa405-67d8-4a9f-818e-7d44ca123eb7	92896dd1c27def3380b9a537face96c261f71c3a680b327f29055ffd3045b4cc	2026-04-28 16:16:56.962438+00	2026-05-28 16:16:56.965781+00	2026-04-28 16:32:34.647763+00	45b8030d-59a1-422a-9658-beb924590749	\N	\N
be647af7-3ca7-414d-a254-772bcec04265	d5393b18-6a59-4133-a743-10c9bdc3d16b	ba1ea9cfb8f39c4f266a6307fe317ea80e722750a0b30205fe06137ff11addf9	2026-04-28 16:10:08.042146+00	2026-05-28 16:10:08.092982+00	2026-04-28 16:32:19.272833+00	e17feb05-96e2-4dfc-b58d-951a2602d38e	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	192.168.97.1
6c598858-ff03-4d0a-99df-b499591f7e71	d5393b18-6a59-4133-a743-10c9bdc3d16b	ddb1e786ff6b37682c32c5e9a52fa4de252af9df7e36c3bff00d734c386d442c	2026-04-28 17:42:41.429664+00	2026-05-28 17:42:41.43249+00	2026-04-28 17:44:15.518605+00	\N	\N	\N
2c73328a-aa34-4325-b2b3-933fa42779ad	7fdaa405-67d8-4a9f-818e-7d44ca123eb7	dec961136db16e9e559b8309dc414531ff85560c94ba81252ee2dc84244cf1d6	2026-04-28 16:53:54.610253+00	2026-05-28 16:53:54.630454+00	\N	\N	\N	\N
45b8030d-59a1-422a-9658-beb924590749	7fdaa405-67d8-4a9f-818e-7d44ca123eb7	871b10ec01ea26e8325fc92fed51884082eeafdf74d755e3682934e99195fad3	2026-04-28 16:32:34.646754+00	2026-05-28 16:32:34.648967+00	2026-04-28 16:53:54.621029+00	2c73328a-aa34-4325-b2b3-933fa42779ad	\N	\N
e176c32e-7dfc-482c-94c5-c5360222cec8	0ebac587-eccd-42a9-b693-915ee1917c51	3bc539dd83b7b1d181a9dc770b356a50fe7ed593c76671f224a17c4947234733	2026-04-28 17:42:41.437858+00	2026-05-28 17:42:41.439624+00	2026-04-28 17:45:32.789641+00	\N	\N	\N
afa37bd3-f2a9-4f71-ad5a-e21f4007fc66	0ebac587-eccd-42a9-b693-915ee1917c51	fed1074a30fe8ddaaae2e81d535f254ac4ba522ce915d4b04c6861153dc3f6a4	2026-04-29 04:22:05.987891+00	2026-05-29 04:22:06.015463+00	\N	\N	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Mobile Safari/537.36	192.168.97.1
c8e71677-aa08-492e-84af-1fc46a9f323e	eccc1ab0-dea0-4422-953d-3a820e512907	8a9495811f138395dd02c1ff0dd5e7f0fae9bf8f461bdcae16a0cf49b4777569	2026-04-28 17:42:41.436941+00	2026-05-28 17:42:41.440022+00	\N	\N	\N	\N
c20c66c4-4da5-4d70-a385-1a57d402705b	eccc1ab0-dea0-4422-953d-3a820e512907	4f7a3c603fce928f17b3806985d714439ff7549c5ade6467f9119f1e82630353	2026-04-28 15:48:50.383564+00	2026-05-28 15:48:50.387847+00	2026-04-28 17:42:41.439356+00	c8e71677-aa08-492e-84af-1fc46a9f323e	\N	\N
c1481008-dd9e-4f35-9051-03706b1ab6e1	0ebac587-eccd-42a9-b693-915ee1917c51	5ab002c6230f8ad842f3bd4c5ab23346e9f11070c8b6bd1949bd44f2a7a674b0	2026-04-28 16:04:46.348402+00	2026-05-28 16:04:46.356983+00	2026-04-28 17:42:41.438858+00	e176c32e-7dfc-482c-94c5-c5360222cec8	\N	\N
22f4bf3b-18c0-4180-973e-f7aec1a3501c	0ebac587-eccd-42a9-b693-915ee1917c51	41cd1c08f14d9420802c92699e8ade0ccb4e0675369cd87ab721ffc876fc10cc	2026-04-29 08:40:19.234501+00	2026-05-29 08:40:19.240172+00	\N	\N	\N	\N
085e5c15-35ec-4571-96f4-13cd770a37d9	0ebac587-eccd-42a9-b693-915ee1917c51	773ee18de77995489d52af66c89aa50a37fefe8db56781133cceb1a6bdfea013	2026-04-29 08:12:25.365502+00	2026-05-29 08:12:25.395124+00	2026-04-29 08:40:19.23735+00	22f4bf3b-18c0-4180-973e-f7aec1a3501c	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	192.168.97.1
ada09677-9548-43ea-b77b-70ef4409510c	0ebac587-eccd-42a9-b693-915ee1917c51	0cb068a9ebd7d01c4c07e54ea9d8437345d0e5cf01c568f68773ac850ffc8128	2026-04-29 13:39:37.247665+00	2026-05-29 13:39:37.282427+00	2026-04-29 13:55:08.281878+00	93e7f1cf-cad5-4807-8a49-f023649c3ddd	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	192.168.97.1
eaed802c-6435-437d-9f25-8ab2c8f372ab	eccc1ab0-dea0-4422-953d-3a820e512907	e333e653dafa160888784804a0a0f653350fcfb5631f7d55187719cfbccf68d7	2026-04-29 13:41:39.966039+00	2026-05-29 13:41:40.019838+00	2026-04-29 13:57:24.894559+00	795a7f33-202d-4953-a0f0-a32e79e32ca3	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	192.168.97.1
a54571b5-1be9-48cb-b309-9f59286caa39	eccc1ab0-dea0-4422-953d-3a820e512907	84b570e45f2f7091e67fcc602b504df56b93b9e423a421ffa30a00bc84b05dbb	2026-04-29 15:30:58.158495+00	2026-05-29 15:30:58.161454+00	2026-04-29 16:14:57.47005+00	1f84b989-aa60-4b8f-86c3-d2914a3b4950	\N	\N
93e7f1cf-cad5-4807-8a49-f023649c3ddd	0ebac587-eccd-42a9-b693-915ee1917c51	278833354538f548196d5f1d82ea6d4c2d0cec816bf6eabf2912bfaf58f19d23	2026-04-29 13:55:08.276696+00	2026-05-29 13:55:08.284157+00	2026-04-29 14:13:52.096465+00	fbba112f-d0bb-4064-9fa9-bb971dbd2d6b	\N	\N
795a7f33-202d-4953-a0f0-a32e79e32ca3	eccc1ab0-dea0-4422-953d-3a820e512907	ade3b70099fc9dfede5747c71ac36ff1aa8687975b5d89360313b6229379bdf2	2026-04-29 13:57:24.893637+00	2026-05-29 13:57:24.895109+00	2026-04-29 14:26:40.340762+00	500d9e04-d6c2-4ea1-b698-fca0210dac7b	\N	\N
fbba112f-d0bb-4064-9fa9-bb971dbd2d6b	0ebac587-eccd-42a9-b693-915ee1917c51	cf451495290280e01819b9eb14133a5f466bfc28f88d46e6cdb661742584b911	2026-04-29 14:13:52.092156+00	2026-05-29 14:13:52.099106+00	2026-04-29 14:29:02.955525+00	297beb02-9378-420a-84c6-3bc732a65797	\N	\N
165adac3-aeff-438c-a975-9ed195724d3c	0ebac587-eccd-42a9-b693-915ee1917c51	3386a5a34676fd98129bca0986c3804302abe88a031f506cafaf3715432e3656	2026-04-29 15:30:22.971865+00	2026-05-29 15:30:22.99509+00	2026-04-29 16:19:12.238097+00	90e24813-551b-427b-a891-164f1a3e7f19	\N	\N
500d9e04-d6c2-4ea1-b698-fca0210dac7b	eccc1ab0-dea0-4422-953d-3a820e512907	f743bcd002db0500889a51a48785b945c94da6096771d8cb417ac8eb6016d31e	2026-04-29 14:26:40.338933+00	2026-05-29 14:26:40.341875+00	2026-04-29 14:42:04.806225+00	9168d0df-c2a2-4f34-899c-c47edcf5cbe8	\N	\N
1c018314-0587-4de1-84bc-2154b84f0af6	0ebac587-eccd-42a9-b693-915ee1917c51	e7cfa9094dc485aec91890e690fb1babc6a915886b4d837dc2d92fce0d2c466e	2026-04-29 14:58:28.266868+00	2026-05-29 14:58:28.289985+00	\N	\N	\N	\N
297beb02-9378-420a-84c6-3bc732a65797	0ebac587-eccd-42a9-b693-915ee1917c51	687979291463eab9743ecf59efe206e3cd8ff41bf1b71fdbfd4679a1628a5618	2026-04-29 14:29:02.951975+00	2026-05-29 14:29:02.956769+00	2026-04-29 14:58:28.26841+00	1c018314-0587-4de1-84bc-2154b84f0af6	\N	\N
9168d0df-c2a2-4f34-899c-c47edcf5cbe8	eccc1ab0-dea0-4422-953d-3a820e512907	4658778a2d6328b6e47c30f6822831e3d08fc427dc988f6aa3ce1f821b9d047b	2026-04-29 14:42:04.80459+00	2026-05-29 14:42:04.807328+00	2026-04-29 14:58:28.505833+00	04ba77e3-a81b-48d8-9627-724f458b9eee	\N	\N
1f84b989-aa60-4b8f-86c3-d2914a3b4950	eccc1ab0-dea0-4422-953d-3a820e512907	f2c51691b08984d7fa515f91a0857f8ae7df9e119fa1b122a42a8af561eb631d	2026-04-29 16:14:57.466673+00	2026-05-29 16:14:57.4754+00	2026-04-29 16:33:11.146229+00	98af3d14-8c11-4cac-b3fa-9b46736df7be	\N	\N
04ba77e3-a81b-48d8-9627-724f458b9eee	eccc1ab0-dea0-4422-953d-3a820e512907	d6e3f8b790690a8d76353ea1b802847588250dc763228b20b5d8613f7bf6ede6	2026-04-29 14:58:28.505461+00	2026-05-29 14:58:28.506917+00	2026-04-29 15:14:04.426737+00	069d9994-8fb6-4bf7-9b1d-11b878524657	\N	\N
2d1ee797-dd53-4b5f-b3a5-4232318e0f01	0ebac587-eccd-42a9-b693-915ee1917c51	f636cf920441d9e051aae95f907b5d08f76b615021045da264ba30bf43868b19	2026-04-29 15:08:16.069925+00	2026-05-29 15:08:16.104238+00	2026-04-29 15:30:22.975797+00	165adac3-aeff-438c-a975-9ed195724d3c	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	192.168.97.1
069d9994-8fb6-4bf7-9b1d-11b878524657	eccc1ab0-dea0-4422-953d-3a820e512907	72bbc70b96ffad0f7de5eb8d3ac1f60b14be51b8e66face9107f83f805cbdab2	2026-04-29 15:14:04.422125+00	2026-05-29 15:14:04.427846+00	2026-04-29 15:30:58.159647+00	a54571b5-1be9-48cb-b309-9f59286caa39	\N	\N
90e24813-551b-427b-a891-164f1a3e7f19	0ebac587-eccd-42a9-b693-915ee1917c51	2d54b68be2525bb5cad1a169a6ad70907e2a518371aacd7a3f174352af435b68	2026-04-29 16:19:12.236553+00	2026-05-29 16:19:12.257736+00	2026-04-29 16:37:10.160265+00	df28b07e-db56-4149-bb6a-a6980bcf3d97	\N	\N
98af3d14-8c11-4cac-b3fa-9b46736df7be	eccc1ab0-dea0-4422-953d-3a820e512907	b97c094364c6c02577a7b05d244e219dca4ae17f7efbbf8d113259c4fb15095a	2026-04-29 16:33:11.139642+00	2026-05-29 16:33:11.176934+00	2026-04-29 16:46:10.010159+00	\N	\N	\N
9ec8c4cd-484c-438c-9f3a-4b18a5343ef7	7fdaa405-67d8-4a9f-818e-7d44ca123eb7	4d3ff2754767a9d7321cfd84deff01473611fd47d4fab676aa86c978d90cd304	2026-04-29 17:44:45.363091+00	2026-05-29 17:44:45.373713+00	\N	\N	\N	\N
ee890134-ed4b-407a-ba3b-87c5c442defc	7fdaa405-67d8-4a9f-818e-7d44ca123eb7	153f33d7958530cf0c87bbcf0782301c719174859c7729a10cf780abaaf31f46	2026-04-29 16:47:24.505204+00	2026-05-29 16:47:24.550442+00	2026-04-29 17:44:45.368573+00	9ec8c4cd-484c-438c-9f3a-4b18a5343ef7	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	192.168.97.1
df28b07e-db56-4149-bb6a-a6980bcf3d97	0ebac587-eccd-42a9-b693-915ee1917c51	d1552f7ba1cb8369cd1d025600fd760e42971bd802d122d75bcfcbbcf9d582d3	2026-04-29 16:37:10.159414+00	2026-05-29 16:37:10.160829+00	2026-04-29 17:44:45.760787+00	73573794-0162-4fc5-af68-5b8545d09ffa	\N	\N
c5091e46-5d9c-4341-9dfa-0c4dd947ed6f	0ebac587-eccd-42a9-b693-915ee1917c51	7ba80f047a190a81f30d7408e79598399b1ba2a96ac47d2094120d09776c9613	2026-04-29 18:15:36.548708+00	2026-05-29 18:15:36.550225+00	\N	\N	\N	\N
73573794-0162-4fc5-af68-5b8545d09ffa	0ebac587-eccd-42a9-b693-915ee1917c51	a1ec338840a4c4a8ffae2a456dcc0e3b9cf243335df0c0ddc343badc277c6c20	2026-04-29 17:44:45.756921+00	2026-05-29 17:44:45.762743+00	2026-04-29 18:15:36.54955+00	c5091e46-5d9c-4341-9dfa-0c4dd947ed6f	\N	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: exambank
--

COPY public.users (id, email, password_hash, display_name, is_active, created_at, updated_at, is_admin) FROM stdin;
0ebac587-eccd-42a9-b693-915ee1917c51	admin@exambank.com	$argon2id$v=19$m=65536,t=3,p=4$OlUE1SLXYXCQ1ben0/7NFg$Zaec56la1n66mWQDUzQgtloELKtj63O1f6o207ZvnGI	Admin	t	2026-04-28 03:44:37.425536+00	2026-04-28 03:44:37.425536+00	t
44654123-7595-4670-9b2e-2b72b827f103	user1@exambank.com	$argon2id$v=19$m=65536,t=3,p=4$BA+7GO5vRF6yw9M+ehY7Tg$ExHeUslNbJIeL+bUeCzeUPJvN6iyqKpGzwIulSTskus	User One	t	2026-04-28 03:44:37.425536+00	2026-04-28 03:44:37.425536+00	f
6d9eaffd-5659-4afd-b2a2-7b6c5e4ef8cb	user2@exambank.com	$argon2id$v=19$m=65536,t=3,p=4$6W0wNTRdGeS7EP5R/+W0mg$rC4W4FJUSqOoO+L1zb4a2Lwwu1+WSRATNlQQWVktKcI	User Two	t	2026-04-28 03:44:37.425536+00	2026-04-28 03:44:37.425536+00	f
1d6fd74c-d441-46c0-b1a8-f0bbe67aaccf	sdelowar.acimis@gmail.com	$argon2id$v=19$m=65536,t=3,p=4$ImedBS+JRZnEIoNF1L+bDA$CrhS6MBRL9PD8X1+aA/ZIBS2eqVS8ao0woPyeOnAESk	SD	t	2026-04-28 03:48:10.980927+00	2026-04-28 03:48:10.980927+00	f
875a8ff1-8dde-411a-b215-085f658c69e8	smoketest-1777350465@example.com	$argon2id$v=19$m=65536,t=3,p=4$l/9bY/1C29KFI0VBYJ8dKQ$75bPcqvCU3NLWrAktlmsRfpES9lWhNre4hmmstrNpPw	Smoke	t	2026-04-28 04:27:45.860849+00	2026-04-28 04:27:45.860849+00	f
e9348327-0598-46fe-9317-865e92fc6bec	smoketest-1777350471-2@example.com	$argon2id$v=19$m=65536,t=3,p=4$msENmfVbdxecip3QihU0hA$7XpIUWGxEMs5lMR3NdxNiz+ozdWLgd59/l3a3laNqgU	Smoke	t	2026-04-28 04:27:51.296843+00	2026-04-28 04:27:51.296843+00	f
50482f77-6b7c-45ce-bf84-5e3f0a4e94ee	smoketest-1777350508-3@example.com	$argon2id$v=19$m=65536,t=3,p=4$KzP7NR6EzstM03UhNi5kRg$V6X+UnWe9P4Bp73p7PjMrNIPXBrGz+KN8uQR6+9vN14	Smoke	t	2026-04-28 04:28:28.096786+00	2026-04-28 04:28:28.096786+00	f
c5dc66e4-2ed6-4028-99f0-4969e5882244	quiz-test-1777353931@example.com	$argon2id$v=19$m=65536,t=3,p=4$F+V88VMO3MsP3pPL4J7v1g$V4ZjRpu63hmPwdn4X4llw5MxLnRDPlO0+G0SKutyBqQ	QuizTest	t	2026-04-28 05:25:31.643257+00	2026-04-28 05:25:31.643257+00	f
3c414f2e-b3ac-4f0b-aed7-ab1c158b8b0f	quiz-admin-1777353943@example.com	$argon2id$v=19$m=65536,t=3,p=4$YwJP8MsxFXSMm7f+URzoRg$gy+RU/nElxNB80VVnTM+0avVdVlrm3vtt/zI7s7h9cM	Admin	t	2026-04-28 05:25:43.286122+00	2026-04-28 05:25:43.286122+00	t
4ad7e221-7631-481f-99a5-3b710af24154	qstudent-1777353961@example.com	$argon2id$v=19$m=65536,t=3,p=4$R5ebkz7r0D59QchdVDGVKg$e7hS2oZBf4/LgkhcTcMH+p6w/SSZqRJBTpGK8AHDWXU	S	t	2026-04-28 05:26:01.396628+00	2026-04-28 05:26:01.396628+00	f
0c16584a-8291-4167-a175-b0ce21b3fd03	ord-test-1777356121@example.com	$argon2id$v=19$m=65536,t=3,p=4$9n7yvOz0SeY94/wRMZikww$2Wea1LQLtd79uOxH1pSUs9IShEZUz4gqgSxIs0ni/QM	OT	t	2026-04-28 06:02:01.587245+00	2026-04-28 06:02:01.587245+00	f
8a49c999-76e3-4ba0-8709-108a1f330d6a	bn-test-1777358267@example.com	$argon2id$v=19$m=65536,t=3,p=4$o7Idx1H1ITzi7FBJBFY2VQ$COV4VmgJTQ304S0gUV3XkH/oH/kKQlEs4wOf9O88n6M	BT	t	2026-04-28 06:37:47.583149+00	2026-04-28 06:37:47.583149+00	f
ddcc9450-c448-4080-97cb-3e9d1db2e42f	ord-bn-1777358279@example.com	$argon2id$v=19$m=65536,t=3,p=4$fpqKG+wElPk1qwqRfX1zIA$JJaCrffTEN5hv2aM+jVsUGYZYP0+1HFr7PChPzUHKHE	OBT	t	2026-04-28 06:37:59.190792+00	2026-04-28 06:37:59.190792+00	f
cc384a5f-057f-4fed-9413-34aa09620c07	ok-1777361964@test.com	$argon2id$v=19$m=65536,t=3,p=4$vAUomcW6UN5uaNVoCoLMaA$9RneziPHxpKOSi80P0/X0EEUKrf9HQeuh6Ie1CWctUI	Rasel Khan	t	2026-04-28 07:39:24.145808+00	2026-04-28 07:39:24.145808+00	f
c00baaf7-94dd-4b0a-a92b-f010736f1ede	stu-1777361977@test.com	$argon2id$v=19$m=65536,t=3,p=4$ntIxS+PhWLvedN7DuwNwqA$eK2jAVAFjWJugLXIeW0LnFu4xfjnW3GDQ9itO+zFOjs	Test Student	t	2026-04-28 07:39:37.78585+00	2026-04-28 07:39:37.78585+00	f
eccc1ab0-dea0-4422-953d-3a820e512907	user4@exambank.com	$argon2id$v=19$m=65536,t=3,p=4$NDJjtnCDHd6bkz2na7astA$ic/Ors1qn9lIAeE3B2+4dvar6GAMNUD2VN+088stMUg	Rudra Roy	t	2026-04-28 07:42:34.270113+00	2026-04-28 07:42:34.270113+00	f
d4fd0752-82a0-45fb-828a-4aa1d7328c2c	tanvinrashid2007@gmail.com	$argon2id$v=19$m=65536,t=3,p=4$XDI1kElvtDFdHvc1EHmFDQ$wzPlDYwBxPLUN8vTCGZ+J+jDHyoqL0WvMOJHdE1vk4Y	Tanvin Rashid	t	2026-04-28 12:47:00.844064+00	2026-04-28 12:47:00.844064+00	f
7fdaa405-67d8-4a9f-818e-7d44ca123eb7	shamim.vibes@gmail.com	$argon2id$v=19$m=65536,t=3,p=4$b/B//Ih7zBZQEfCN+LFo5g$LBLuw9tF7Q5OXqp2Azd5x8YDot0fC5pCs+ubq9e5hoI	Shamim Islam	t	2026-04-28 12:48:17.466292+00	2026-04-28 12:48:17.466292+00	f
d5393b18-6a59-4133-a743-10c9bdc3d16b	drmc8638asp@gmail.com	$argon2id$v=19$m=65536,t=3,p=4$Z+4B/NcG6BN1muRKnjj0wA$2V9+nIqOKY5E/D8CqzO5AgNoqTTpmUJ3qlZ9TIkSoEU	Arindom Saha Pretho	t	2026-04-28 12:56:20.24065+00	2026-04-28 12:56:20.24065+00	f
\.


--
-- Name: admission_written_questions admission_written_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.admission_written_questions
    ADD CONSTRAINT admission_written_questions_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: attempt_answers attempt_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.attempt_answers
    ADD CONSTRAINT attempt_answers_pkey PRIMARY KEY (id);


--
-- Name: attempts attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.attempts
    ADD CONSTRAINT attempts_pkey PRIMARY KEY (id);


--
-- Name: bookmarks bookmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT bookmarks_pkey PRIMARY KEY (id);


--
-- Name: exam_papers exam_papers_pkey; Type: CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.exam_papers
    ADD CONSTRAINT exam_papers_pkey PRIMARY KEY (id);


--
-- Name: hsc_mcq_options hsc_mcq_options_pkey; Type: CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.hsc_mcq_options
    ADD CONSTRAINT hsc_mcq_options_pkey PRIMARY KEY (id);


--
-- Name: hsc_mcq_questions hsc_mcq_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.hsc_mcq_questions
    ADD CONSTRAINT hsc_mcq_questions_pkey PRIMARY KEY (id);


--
-- Name: hsc_written_questions hsc_written_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.hsc_written_questions
    ADD CONSTRAINT hsc_written_questions_pkey PRIMARY KEY (id);


--
-- Name: hsc_written_subparts hsc_written_subparts_pkey; Type: CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.hsc_written_subparts
    ADD CONSTRAINT hsc_written_subparts_pkey PRIMARY KEY (id);


--
-- Name: admission_mcq_options options_pkey; Type: CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.admission_mcq_options
    ADD CONSTRAINT options_pkey PRIMARY KEY (id);


--
-- Name: quiz_status pk_quiz_status; Type: CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.quiz_status
    ADD CONSTRAINT pk_quiz_status PRIMARY KEY (subject, exam_type);


--
-- Name: admission_mcq_questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.admission_mcq_questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_hash_key UNIQUE (token_hash);


--
-- Name: attempt_answers uq_attempt_answers_attempt_question; Type: CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.attempt_answers
    ADD CONSTRAINT uq_attempt_answers_attempt_question UNIQUE (attempt_id, question_id);


--
-- Name: bookmarks uq_bookmarks_user_question; Type: CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT uq_bookmarks_user_question UNIQUE (user_id, question_id);


--
-- Name: hsc_written_subparts uq_hsc_written_subparts_question_label; Type: CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.hsc_written_subparts
    ADD CONSTRAINT uq_hsc_written_subparts_question_label UNIQUE (question_id, label);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ix_admission_mcq_options_question_id; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_admission_mcq_options_question_id ON public.admission_mcq_options USING btree (question_id);


--
-- Name: ix_admission_mcq_questions_chapter; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_admission_mcq_questions_chapter ON public.admission_mcq_questions USING btree (chapter);


--
-- Name: ix_admission_mcq_questions_has_image; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_admission_mcq_questions_has_image ON public.admission_mcq_questions USING btree (has_image);


--
-- Name: ix_admission_mcq_questions_paper_id; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_admission_mcq_questions_paper_id ON public.admission_mcq_questions USING btree (paper_id);


--
-- Name: ix_admission_mcq_questions_solution_status; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_admission_mcq_questions_solution_status ON public.admission_mcq_questions USING btree (solution_status);


--
-- Name: ix_admission_mcq_questions_subject; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_admission_mcq_questions_subject ON public.admission_mcq_questions USING btree (subject);


--
-- Name: ix_admission_written_questions_chapter; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_admission_written_questions_chapter ON public.admission_written_questions USING btree (chapter);


--
-- Name: ix_admission_written_questions_has_image; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_admission_written_questions_has_image ON public.admission_written_questions USING btree (has_image);


--
-- Name: ix_admission_written_questions_paper_id; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_admission_written_questions_paper_id ON public.admission_written_questions USING btree (paper_id);


--
-- Name: ix_admission_written_questions_solution_status; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_admission_written_questions_solution_status ON public.admission_written_questions USING btree (solution_status);


--
-- Name: ix_admission_written_questions_subject; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_admission_written_questions_subject ON public.admission_written_questions USING btree (subject);


--
-- Name: ix_attempt_answers_attempt_id; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_attempt_answers_attempt_id ON public.attempt_answers USING btree (attempt_id);


--
-- Name: ix_attempt_answers_question_id; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_attempt_answers_question_id ON public.attempt_answers USING btree (question_id);


--
-- Name: ix_attempts_exam_type; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_attempts_exam_type ON public.attempts USING btree (exam_type);


--
-- Name: ix_attempts_paper_id; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_attempts_paper_id ON public.attempts USING btree (paper_id);


--
-- Name: ix_attempts_user_id; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_attempts_user_id ON public.attempts USING btree (user_id);


--
-- Name: ix_bookmarks_user_id; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_bookmarks_user_id ON public.bookmarks USING btree (user_id);


--
-- Name: ix_exam_papers_exam_type; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_exam_papers_exam_type ON public.exam_papers USING btree (exam_type);


--
-- Name: ix_exam_papers_question_type; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_exam_papers_question_type ON public.exam_papers USING btree (question_type);


--
-- Name: ix_hsc_mcq_options_question_id; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_hsc_mcq_options_question_id ON public.hsc_mcq_options USING btree (question_id);


--
-- Name: ix_hsc_mcq_questions_board_name; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_hsc_mcq_questions_board_name ON public.hsc_mcq_questions USING btree (board_name);


--
-- Name: ix_hsc_mcq_questions_chapter; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_hsc_mcq_questions_chapter ON public.hsc_mcq_questions USING btree (chapter);


--
-- Name: ix_hsc_mcq_questions_exam_year; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_hsc_mcq_questions_exam_year ON public.hsc_mcq_questions USING btree (exam_year);


--
-- Name: ix_hsc_mcq_questions_has_image; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_hsc_mcq_questions_has_image ON public.hsc_mcq_questions USING btree (has_image);


--
-- Name: ix_hsc_mcq_questions_paper_id; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_hsc_mcq_questions_paper_id ON public.hsc_mcq_questions USING btree (paper_id);


--
-- Name: ix_hsc_mcq_questions_solution_status; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_hsc_mcq_questions_solution_status ON public.hsc_mcq_questions USING btree (solution_status);


--
-- Name: ix_hsc_mcq_questions_subject; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_hsc_mcq_questions_subject ON public.hsc_mcq_questions USING btree (subject);


--
-- Name: ix_hsc_mcq_questions_subject_paper; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_hsc_mcq_questions_subject_paper ON public.hsc_mcq_questions USING btree (subject_paper);


--
-- Name: ix_hsc_written_questions_board_name; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_hsc_written_questions_board_name ON public.hsc_written_questions USING btree (board_name);


--
-- Name: ix_hsc_written_questions_exam_year; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_hsc_written_questions_exam_year ON public.hsc_written_questions USING btree (exam_year);


--
-- Name: ix_hsc_written_questions_paper_id; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_hsc_written_questions_paper_id ON public.hsc_written_questions USING btree (paper_id);


--
-- Name: ix_hsc_written_questions_subject; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_hsc_written_questions_subject ON public.hsc_written_questions USING btree (subject);


--
-- Name: ix_hsc_written_questions_subject_paper; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_hsc_written_questions_subject_paper ON public.hsc_written_questions USING btree (subject_paper);


--
-- Name: ix_hsc_written_questions_uddipak_has_image; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_hsc_written_questions_uddipak_has_image ON public.hsc_written_questions USING btree (uddipak_has_image);


--
-- Name: ix_hsc_written_subparts_has_image; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_hsc_written_subparts_has_image ON public.hsc_written_subparts USING btree (has_image);


--
-- Name: ix_hsc_written_subparts_question_id; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_hsc_written_subparts_question_id ON public.hsc_written_subparts USING btree (question_id);


--
-- Name: ix_hsc_written_subparts_solution_status; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_hsc_written_subparts_solution_status ON public.hsc_written_subparts USING btree (solution_status);


--
-- Name: ix_refresh_tokens_expires_at; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_refresh_tokens_expires_at ON public.refresh_tokens USING btree (expires_at);


--
-- Name: ix_refresh_tokens_user_id; Type: INDEX; Schema: public; Owner: exambank
--

CREATE INDEX ix_refresh_tokens_user_id ON public.refresh_tokens USING btree (user_id);


--
-- Name: admission_written_questions admission_written_questions_paper_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.admission_written_questions
    ADD CONSTRAINT admission_written_questions_paper_id_fkey FOREIGN KEY (paper_id) REFERENCES public.exam_papers(id) ON DELETE CASCADE;


--
-- Name: attempt_answers attempt_answers_attempt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.attempt_answers
    ADD CONSTRAINT attempt_answers_attempt_id_fkey FOREIGN KEY (attempt_id) REFERENCES public.attempts(id) ON DELETE CASCADE;


--
-- Name: attempt_answers attempt_answers_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.attempt_answers
    ADD CONSTRAINT attempt_answers_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.admission_mcq_questions(id) ON DELETE CASCADE;


--
-- Name: attempts attempts_paper_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.attempts
    ADD CONSTRAINT attempts_paper_id_fkey FOREIGN KEY (paper_id) REFERENCES public.exam_papers(id) ON DELETE SET NULL;


--
-- Name: attempts attempts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.attempts
    ADD CONSTRAINT attempts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: bookmarks bookmarks_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT bookmarks_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.admission_mcq_questions(id) ON DELETE CASCADE;


--
-- Name: bookmarks bookmarks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT bookmarks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: quiz_status fk_quiz_status_updated_by; Type: FK CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.quiz_status
    ADD CONSTRAINT fk_quiz_status_updated_by FOREIGN KEY (updated_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: hsc_mcq_options hsc_mcq_options_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.hsc_mcq_options
    ADD CONSTRAINT hsc_mcq_options_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.hsc_mcq_questions(id) ON DELETE CASCADE;


--
-- Name: hsc_mcq_questions hsc_mcq_questions_paper_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.hsc_mcq_questions
    ADD CONSTRAINT hsc_mcq_questions_paper_id_fkey FOREIGN KEY (paper_id) REFERENCES public.exam_papers(id) ON DELETE CASCADE;


--
-- Name: hsc_written_questions hsc_written_questions_paper_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.hsc_written_questions
    ADD CONSTRAINT hsc_written_questions_paper_id_fkey FOREIGN KEY (paper_id) REFERENCES public.exam_papers(id) ON DELETE CASCADE;


--
-- Name: hsc_written_subparts hsc_written_subparts_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.hsc_written_subparts
    ADD CONSTRAINT hsc_written_subparts_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.hsc_written_questions(id) ON DELETE CASCADE;


--
-- Name: admission_mcq_options options_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.admission_mcq_options
    ADD CONSTRAINT options_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.admission_mcq_questions(id) ON DELETE CASCADE;


--
-- Name: admission_mcq_questions questions_paper_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.admission_mcq_questions
    ADD CONSTRAINT questions_paper_id_fkey FOREIGN KEY (paper_id) REFERENCES public.exam_papers(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_replaced_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_replaced_by_id_fkey FOREIGN KEY (replaced_by_id) REFERENCES public.refresh_tokens(id) ON DELETE SET NULL;


--
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: exambank
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict 8KOnsQ8c9IeGGqPi2GKrL8OIDGXWaGRkWMtyT2jKgeDolhDgOLUjtTJdeUscMDh

