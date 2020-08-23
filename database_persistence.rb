require "pg"
require 'pry'

class DatabasePersistence
  def initialize
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: "companies")
          end
  end

  def disconnect
    @db.close
  end

  def query(statement, *params)
    @db.exec_params(statement, params)
  end

  def find_company_id_from_ticker(ticker)
    sql = "SELECT id FROM companies WHERE ticker = $1"

    result = query(sql, ticker).first
    result["id"]
  end

  def find_company_nickname_from_ticker(ticker)
    sql = "SELECT nickname FROM companies WHERE ticker = $1"

    result = query(sql, ticker).first
    result["nickname"]
  end

  def find_current_report_id(company_id, quarter, year, source)
    sql = <<~SQL
      SELECT id FROM financial_report
       WHERE (company_id, quarter, year, source) = ($1, $2, $3, $4)
    SQL

    result = query(sql, company_id, quarter, year, source).first
    result["id"]
  end

  def find_raw_data(ticker, nickname, quarter, year, source)
    sql = <<~SQL
      SELECT fr.company_id, c.name, fd.report_id, fr.period_end_date, fr.source_url,
             fd.source_page, fd.segment, fd.metric, fd.currency, fd.data_current_period,
             fd.data_year_ago_period, fd.unit
        FROM companies AS c
       INNER JOIN financial_report AS fr ON c.id = fr.company_id
       INNER JOIN financial_data AS fd ON fr.id = fd.report_id
       WHERE (ticker, nickname, quarter, year, source) = ($1, $2, $3, $4, $5) 
    SQL

    query(sql, ticker, nickname, quarter, year, source)
  end

  def find_company_segments(company_id, report_id)
    sql = <<~SQL
      SELECT DISTINCT segment FROM financial_data
       WHERE company_id = $1 AND report_id = $2 AND segment != 'total'
    SQL

    result = query(sql, company_id, report_id)
    result.map do |tuple|
      tuple["segment"]
    end
  end

  def find_company_metrics(company_id, report_id)
    sql = <<~SQL
      SELECT DISTINCT metric FROM financial_data
       WHERE company_id = $1 AND report_id = $2 AND segment != 'total'
    SQL

    result = query(sql, company_id, report_id)
    result.map do |tuple|
      tuple["metric"]
    end
  end

  def find_individual_segment_metric_data(metric, segment, company_id, report_id)
    sql = <<~SQL
      SELECT data_current_period FROM financial_data
       WHERE metric LIKE $1
         AND segment LIKE $2
         AND company_id = $3
         AND report_id = $4
    SQL

    result = query(sql, metric, segment, company_id.to_i, report_id.to_i)
    result.first["data_current_period"]
  end

  def find_segments_metric_total(metric, company_id, report_id)
    sql = <<~SQL
      SELECT sum(data_current_period) AS metric_total FROM financial_data
       WHERE metric = $1
         AND company_id = $2
         AND report_id = $3
         AND segment != 'total'
         AND data_current_period >= 0
    SQL

    result = query(sql, metric, company_id, report_id)
    result.first["metric_total"]
  end

  def find_segment_metrics(company_id, report_id, segment)
    sql = <<~SQL
      SELECT metric, data_current_period, data_year_ago_period
        FROM financial_data
       WHERE company_id = $1 AND report_id = $2 AND segment = $3
    SQL

    query(sql, company_id, report_id, segment)
  end

  def add_company(name, nickname, ticker)
    sql = "INSERT INTO companies (name, nickname, ticker) VALUES ($1, $2, $3)"
    query(sql, name, nickname, ticker)
  end

  def add_financial_report(company_id, quarter, year, period_end, source, source_url, segments)
    sql = <<~SQL
      INSERT INTO financial_report
        (company_id, quarter, year, period_end_date, source, source_url, number_of_segments)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
    SQL

    query(sql, company_id, quarter, year, period_end, source, source_url, segments)
  end

  def add_financial_data(company_id, report_id, source_page, currency, segment, metric, unit, current_data, year_ago_data)
    sql = <<~SQL
      INSERT INTO financial_data
        (company_id, report_id, source_page, currency, segment, metric, unit, data_current_period, data_year_ago_period)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
    SQL

    query(sql, company_id, report_id, source_page, currency, segment, metric, unit, current_data, year_ago_data)
  end

  def all_company_names_nicknames_and_tickers
    sql = "SELECT name, nickname, ticker FROM companies"
    result = query(sql)
  end
end