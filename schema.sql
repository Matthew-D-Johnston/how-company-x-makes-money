CREATE TABLE companies (
  id serial PRIMARY KEY,
  name text NOT NULL UNIQUE,
  nickname text NOT NULL UNIQUE,
  ticker text NOT NULL UNIQUE CHECK(ticker = upper(ticker))
);

CREATE TABLE financial_report (
  id serial PRIMARY KEY,
  company_id integer NOT NULL REFERENCES companies(id),
  quarter integer NOT NULL CHECK(quarter BETWEEN 0 AND 4),
  year integer NOT NULL,
  period_end_date date NOT NULL,
  source text NOT NULL,
  source_url text NOT NULL,
  number_of_segments integer NOT NULL,
  special_form_date text NOT NULL,
  UNIQUE(company_id, quarter, period_end_date, source)
);

CREATE TABLE financial_data (
  id serial PRIMARY KEY,
  company_id integer NOT NULL REFERENCES companies(id),
  report_id integer NOT NULL REFERENCES financial_report(id),
  source_page text NOT NULL,
  currency text NOT NULL,
  segment text NOT NULL,
  metric text NOT NULL,
  unit text NOT NULL CHECK(unit IN ('b', 'm', 't', 'N/A')),
  data_current_period integer NOT NULL,
  data_year_ago_period integer NOT NULL
);
