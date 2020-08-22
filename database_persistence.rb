require "pg"

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

  def add_company(name, ticker)
    sql = "INSERT INTO companies (name, ticker) VALUES ($1, $2)"
    query(sql, name, ticker)
  end

  def find_company_id_from_ticker(ticker)
    sql = "SELECT id FROM companies WHERE ticker = $1"

    result = query(sql, ticker).first
    result["id"]
  end

  # def add_financial_report(company_id, quarter, year, period_end, source, source_url)
  #   sql = <<~SQL
  #     INSERT INTO financial_report (company_id, quarter, year, period_end_date, source, source_url)
  #     VALUES ($1, $2, $3, $4, $5, $6)
  #   SQL


  # end

  def all_company_names_and_tickers
    sql = "SELECT name, ticker FROM companies"
    result = query(sql)
  end
end