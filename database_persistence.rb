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

  def all_company_names_and_tickers
    sql = "SELECT name, ticker FROM companies"
    result = query(sql)
  end
end