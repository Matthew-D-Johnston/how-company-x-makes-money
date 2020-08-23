require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"

require_relative "database_persistence"

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "database_persistence.rb"
end

before do
  @storage = DatabasePersistence.new
end

after do
  @storage.disconnect
end

get "/" do
  redirect "/company_list"
end

get "/company_list" do
  @company_list = @storage.all_company_names_nicknames_and_tickers
  
  erb :company_list
end

get "/company_data_input" do
  session[:ticker] = params.keys[0]
  session[:nickname] = @storage.find_company_nickname_from_ticker(session[:ticker])

  erb :company_data_input
end

get "/add_company" do

  erb :add_company
end

get "/financial_data" do

  erb :financial_data_input
end

get "/retrieve_data" do
  session[:ticker] = params.keys[0]
  session[:nickname] = @storage.find_company_nickname_from_ticker(session[:ticker])

  erb :retrieve_data
end

get "/financial_data_output" do
  ticker = session[:ticker]
  nickname = session[:nickname]
  quarter = session[:retrieve_data_quarter]
  year = session[:retrieve_data_year]
  source = session[:retrieve_data_source]

  @raw_data = @storage.find_raw_data(ticker, nickname, quarter, year, source)
  # Get Raw Data:
  # - Total Revenue for current and year-ago periods
  # - Total Earnings for current and year-ago periods
  # - Segment Revenue/Earnings for current and year-ago periods

  # Get Formatted Data:
  # - Rounded data to proper decimal place with appropriate units
  # - YOY growth rate rounded to proper decimal place
  # - segment shares of total rounded to proper decimal place

  # All appropriate citations with link to url source

  erb :financial_data_output
end

post "/add_company" do
  @storage.add_company(params[:company_name], params[:company_nickname], params[:company_ticker])

  redirect "/company_list"
end

post "/financial_report" do
  company_id = @storage.find_company_id_from_ticker(session[:ticker])
  quarter = params[:quarter]
  year = params[:year]
  period_end = params[:period_end]
  source = params[:source]
  source_url = params[:source_url]
  segments = params[:number_of_segments]

  session[:company_id] = company_id
  session[:segments] = segments.to_i

  @storage.add_financial_report(company_id, quarter, year, period_end, source, source_url, segments)

  session[:report_id] = @storage.find_current_report_id(company_id, quarter, year, source).to_i

  redirect "/financial_data"
end

post "/financial_data" do
  company_id = session[:company_id]
  report_id = session[:report_id]

  # Total Revenue
  rev_source_page = params[:revenue_source_page]
  rev_currency = params[:revenue_currency]
  rev_segment = 'total'
  rev_metric = params[:revenue_metric]
  rev_unit = params[:revenue_unit]
  rev_current_data = params[:current_total_revenue]
  rev_year_ago_data = params[:past_total_revenue]

  @storage.add_financial_data(company_id, report_id, rev_source_page, rev_currency, rev_segment, rev_metric, rev_unit, rev_current_data, rev_year_ago_data)

  # Total Earnings
  earn_source_page = params[:earnings_source_page]
  earn_currency = params[:earnings_currency]
  earn_segment = 'total'
  earn_metric = params[:earnings_metric]
  earn_unit = params[:earnings_unit]
  earn_current_data = params[:current_total_earnings]
  earn_year_ago_data = params[:past_total_earnings]

  @storage.add_financial_data(company_id, report_id, earn_source_page, earn_currency, earn_segment, earn_metric, earn_unit, earn_current_data, earn_year_ago_data)

  # Segment Data

  session[:segments].times do |segment_number|
    segment_number += 1

    rev_source_page = params["revenue_source_page_#{segment_number}".to_sym]
    rev_currency = params["revenue_currency_#{segment_number}".to_sym]
    rev_segment = params["segment_#{segment_number}_name".to_sym]
    rev_metric = params["revenue_metric_#{segment_number}".to_sym]
    rev_unit = params["revenue_unit_#{segment_number}".to_sym]
    rev_current_data = params["current_total_revenue_#{segment_number}".to_sym]
    rev_year_ago_data = params["past_total_revenue_#{segment_number}".to_sym]

    @storage.add_financial_data(company_id, report_id, rev_source_page, rev_currency, rev_segment, rev_metric, rev_unit, rev_current_data, rev_year_ago_data)


    earn_source_page = params["earnings_source_page_#{segment_number}".to_sym]
    earn_currency = params["earnings_currency_#{segment_number}".to_sym]
    earn_segment = params["segment_#{segment_number}_name".to_sym]
    earn_metric = params["earnings_metric_#{segment_number}".to_sym]
    earn_unit = params["earnings_unit_#{segment_number}".to_sym]
    earn_current_data = params["current_total_earnings_#{segment_number}".to_sym]
    earn_year_ago_data = params["past_total_earnings_#{segment_number}".to_sym]

    @storage.add_financial_data(company_id, report_id, earn_source_page, earn_currency, earn_segment, earn_metric, earn_unit, earn_current_data, earn_year_ago_data)
  end

  redirect "/company_list"
end

post "/retrieve_data" do
  session[:retrieve_data_quarter] = params[:quarter]
  session[:retrieve_data_year] = params[:year]
  session[:retrieve_data_source] = params[:source]

  redirect "/financial_data_output"
end
