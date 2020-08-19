CREATE TABLE companies (
  id serial PRIMARY KEY,
  name text NOT NULL UNIQUE,
  ticker text NOT NULL UNIQUE CHECK(ticker = upper(ticker))
);

CREATE TABLE financial_report (
  id serial PRIMARY KEY,
  company_id integer NOT NULL REFERENCES companies(id),
  segment text NOT NULL,
  metric text NOT NULL,
  quarter integer NOT NULL CHECK(quarter BETWEEN 0 AND 4),
  year integer NOT NULL,
  period_end_date date NOT NULL
);
