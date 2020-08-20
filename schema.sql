CREATE TABLE companies (
  id serial PRIMARY KEY,
  name text NOT NULL UNIQUE,
  ticker text NOT NULL UNIQUE CHECK(ticker = upper(ticker))
);

CREATE TABLE financial_data (
  id serial PRIMARY KEY,
  company_id integer NOT NULL REFERENCES companies(id),
  report_id integer NOT NULL REFERENCES financial_report(id),
  segment text NOT NULL,
  metric text NOT NULL,
  data_current_period integer NOT NULL,
  data_year_ago_period integer NOT NULL,
);

CREATE TABLE financial_report (
  id serial PRIMARY KEY,
  company_id integer NOT NULL REFERENCES companies(id),
  quarter integer NOT NULL CHECK(quarter BETWEEN 0 AND 4),
  year integer NOT NULL,
  period_end_date date NOT NULL,
  source text NOT NULL,
  source_url text NOT NULL
);
