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
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: court_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.court_applications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    body jsonb,
    subject_id uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: dummy_maat_reference_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dummy_maat_reference_seq
    START WITH 10000000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feature_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feature_flags (
    id bigint NOT NULL,
    name character varying,
    enabled boolean,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: feature_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.feature_flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feature_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.feature_flags_id_seq OWNED BY public.feature_flags.id;


--
-- Name: hearing_event_recordings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hearing_event_recordings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    hearing_id uuid,
    hearing_date date,
    body jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: hearing_repull_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hearing_repull_batches (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: hearings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hearings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    body jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: laa_references; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.laa_references (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    defendant_id uuid NOT NULL,
    maat_reference character varying NOT NULL,
    linked boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_name character varying NOT NULL,
    unlink_reason_code integer
);


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_grants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    resource_owner_id uuid NOT NULL,
    application_id uuid NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    resource_owner_id uuid,
    application_id uuid NOT NULL,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying,
    previous_refresh_token character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_applications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri text,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    confidential boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    contact_email character varying,
    requester_email character varying,
    requestee_email character varying
);


--
-- Name: prosecution_case_defendant_offences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prosecution_case_defendant_offences (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    prosecution_case_id uuid NOT NULL,
    defendant_id uuid NOT NULL,
    offence_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    deprecated_maat_reference character varying,
    deprecated_dummy_maat_reference boolean DEFAULT false NOT NULL,
    rep_order_status character varying,
    response_status integer,
    response_body json,
    status_date timestamp without time zone,
    effective_start_date timestamp without time zone,
    effective_end_date timestamp without time zone,
    defence_organisation json
);


--
-- Name: prosecution_case_hearing_repulls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prosecution_case_hearing_repulls (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    hearing_repull_batch_id uuid,
    prosecution_case_id uuid,
    status character varying DEFAULT 'pending'::character varying,
    maat_ids character varying,
    urn character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: prosecution_cases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prosecution_cases (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    body jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying,
    auth_token_digest character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: feature_flags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature_flags ALTER COLUMN id SET DEFAULT nextval('public.feature_flags_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: court_applications court_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.court_applications
    ADD CONSTRAINT court_applications_pkey PRIMARY KEY (id);


--
-- Name: feature_flags feature_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature_flags
    ADD CONSTRAINT feature_flags_pkey PRIMARY KEY (id);


--
-- Name: hearing_event_recordings hearing_event_recordings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hearing_event_recordings
    ADD CONSTRAINT hearing_event_recordings_pkey PRIMARY KEY (id);


--
-- Name: hearing_repull_batches hearing_repull_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hearing_repull_batches
    ADD CONSTRAINT hearing_repull_batches_pkey PRIMARY KEY (id);


--
-- Name: hearings hearings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hearings
    ADD CONSTRAINT hearings_pkey PRIMARY KEY (id);


--
-- Name: laa_references laa_references_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.laa_references
    ADD CONSTRAINT laa_references_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants oauth_access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications oauth_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: prosecution_case_defendant_offences prosecution_case_defendant_offences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prosecution_case_defendant_offences
    ADD CONSTRAINT prosecution_case_defendant_offences_pkey PRIMARY KEY (id);


--
-- Name: prosecution_case_hearing_repulls prosecution_case_hearing_repulls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prosecution_case_hearing_repulls
    ADD CONSTRAINT prosecution_case_hearing_repulls_pkey PRIMARY KEY (id);


--
-- Name: prosecution_cases prosecution_cases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prosecution_cases
    ADD CONSTRAINT prosecution_cases_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_on_hearing_repull_batch_id_61b4f3e760; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_on_hearing_repull_batch_id_61b4f3e760 ON public.prosecution_case_hearing_repulls USING btree (hearing_repull_batch_id);


--
-- Name: index_case_defendant_offences_on_prosecution_case; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_case_defendant_offences_on_prosecution_case ON public.prosecution_case_defendant_offences USING btree (prosecution_case_id);


--
-- Name: index_feature_flags_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_feature_flags_on_name ON public.feature_flags USING btree (name);


--
-- Name: index_hearing_event_recordings_on_hearing_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hearing_event_recordings_on_hearing_id ON public.hearing_event_recordings USING btree (hearing_id);


--
-- Name: index_laa_references_on_defendant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_laa_references_on_defendant_id ON public.laa_references USING btree (defendant_id);


--
-- Name: index_laa_references_on_maat_reference; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_laa_references_on_maat_reference ON public.laa_references USING btree (maat_reference) WHERE linked;


--
-- Name: index_oauth_access_grants_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_application_id ON public.oauth_access_grants USING btree (application_id);


--
-- Name: index_oauth_access_grants_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_resource_owner_id ON public.oauth_access_grants USING btree (resource_owner_id);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON public.oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_application_id ON public.oauth_access_tokens USING btree (application_id);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON public.oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON public.oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON public.oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON public.oauth_applications USING btree (uid);


--
-- Name: index_prosecution_case_defendant_offences_on_defendant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_prosecution_case_defendant_offences_on_defendant_id ON public.prosecution_case_defendant_offences USING btree (defendant_id);


--
-- Name: index_prosecution_case_defendant_offences_on_offence_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_prosecution_case_defendant_offences_on_offence_id ON public.prosecution_case_defendant_offences USING btree (offence_id);


--
-- Name: index_prosecution_case_hearing_repulls_on_prosecution_case_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_prosecution_case_hearing_repulls_on_prosecution_case_id ON public.prosecution_case_hearing_repulls USING btree (prosecution_case_id);


--
-- Name: prosecution_case_hearing_repulls fk_rails_02813a006e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prosecution_case_hearing_repulls
    ADD CONSTRAINT fk_rails_02813a006e FOREIGN KEY (prosecution_case_id) REFERENCES public.prosecution_cases(id);


--
-- Name: oauth_access_tokens fk_rails_732cb83ab7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_rails_732cb83ab7 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: prosecution_case_defendant_offences fk_rails_a5230a38ba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prosecution_case_defendant_offences
    ADD CONSTRAINT fk_rails_a5230a38ba FOREIGN KEY (prosecution_case_id) REFERENCES public.prosecution_cases(id);


--
-- Name: prosecution_case_hearing_repulls fk_rails_aaf719296a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prosecution_case_hearing_repulls
    ADD CONSTRAINT fk_rails_aaf719296a FOREIGN KEY (hearing_repull_batch_id) REFERENCES public.hearing_repull_batches(id);


--
-- Name: oauth_access_grants fk_rails_b4b53e07b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_rails_b4b53e07b8 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20250723135115'),
('20250626082346'),
('20250619153722'),
('20250327104429'),
('20220815120308'),
('20220815115514'),
('20220801171207'),
('20210427164141'),
('20210311145419'),
('20200723141728'),
('20200720123025'),
('20200519141938'),
('20200429163050'),
('20200424095754'),
('20200407083117'),
('20200310222258'),
('20200310210135'),
('20200304144205'),
('20200210053550'),
('20191211135014'),
('20191113174858'),
('20191111162455'),
('20191111162446');

