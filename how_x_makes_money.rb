require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require "date"
require "pry"

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

helpers do
  def add_commas_to_financial_data(figure)
    counter = -4
    iterations = figure.length / 3
    iterations -= 1 if figure.length % 3 == 0
    new_figure = figure

    iterations.times do
      new_figure.insert(counter, ',')
      counter -= 4
    end

    new_figure
  end

  def dis_abbreviate(unit)
    case unit
    when 't' then 'thousand'
    when 'm' then 'million'
    when 'b' then 'million'
    end
  end

  def full_number_from_units(figure, unit)
    new_figure = figure.to_i

    case unit
    when 't'
      new_figure *= 1000
    when 'm'
      new_figure *= 1000000
    when 'b'
      new_figure *= 1000000000
    end

    new_figure
  end

  def round_to_one_decimal(figure, currency)
    number_of_digits = figure.abs.digits.count
    suffix = ''
    rounded_figure = 0

    case number_of_digits
    when (1..3) 
      suffix = ''
      rounded_figure = figure
    when (4..6) 
      suffix = 'thousand'
      rounded_figure = (figure.to_f / 1000).round(1)
    when (7..9) 
      suffix = 'million'
      rounded_figure = (figure.to_f / 1_000_000).round(1)
    when (10..12) 
      suffix = 'billion'
      rounded_figure = (figure.to_f / 1_000_000_000).round(1)
    end

    if rounded_figure < 0
      rounded_figure = rounded_figure.abs
      "-#{currency}#{rounded_figure} #{suffix}"
    else
      "#{currency}#{rounded_figure} #{suffix}"
    end
  end

  def format_financial_data(data, currency, unit)
    if data[0] == '-'
      absolute_data = data.gsub('-', '')
      new_data = add_commas_to_financial_data(absolute_data)
      units = dis_abbreviate(unit)

      "-#{currency}#{new_data} #{units}"
    else
      new_data = add_commas_to_financial_data(data)
      units = dis_abbreviate(unit)

      "#{currency}#{new_data} #{units}"
    end
  end

  def yoy_growth_rate(current_figure, year_ago_figure)
    current = current_figure.to_i
    year_ago = year_ago_figure.to_i

    if current < 0 || year_ago < 0
      "N/A"
    else
      yoy = (((current.to_f / year_ago.to_f) - 1) * 100).round(1)
      "#{yoy}%"
    end
  end

  def current_date
    date = Time.now
    year = date.year
    month = Date::MONTHNAMES[date.month][0..2]
    day = date.day

    "#{month}. #{day}, #{year}"
  end

  def citation_source(source, quarter, period_end)
    year, month, day = period_end.split('-')
    month = Date::MONTHNAMES[month.to_i]

    if quarter == 0
      "Form #{source} for the fiscal year ended #{month} #{day}, #{year},"
    else
      "Form #{source} for the quarterly period ended #{month} #{day}, #{year}"
    end
  end

  def segment_share_totals(break_down_hash, segment, metric, company_id, report_id)
    return "100.0%" if segment == 'total'
    
    individual_metric = break_down_hash[segment][metric].to_f
    total_for_metric = @storage.find_segments_metric_total(metric, company_id, report_id).to_f

    "#{((individual_metric / total_for_metric) * 100).round(2)}%"
  end
end

def segment_breakdown_hash(segments, metrics, company_id, report_id)
  segments.each_with_object({}) do |segment, segment_hash|
    segment_hash[segment] = metrics.each_with_object({}) do |metric, metric_hash|
                              metric_hash[metric] = @storage.find_individual_segment_metric_data(metric, segment, company_id, report_id)
                            end
  end
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

  company_id = @storage.find_company_id_from_ticker(ticker)
  report_id = @storage.find_current_report_id(company_id, quarter, year, source)

  segments_arr = @storage.find_company_segments(company_id, report_id)
  metrics_arr = @storage.find_company_metrics(company_id, report_id)

  @segment_breakdown = segment_breakdown_hash(segments_arr, metrics_arr, company_id, report_id)

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
  session[:earnings_info] = params[:earnings_info]

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
  rev_segment = 'Total'
  rev_metric = params[:revenue_metric]
  rev_unit = params[:revenue_unit]
  rev_current_data = params[:current_total_revenue]
  rev_year_ago_data = params[:past_total_revenue]

  @storage.add_financial_data(company_id, report_id, rev_source_page, rev_currency, rev_segment, rev_metric, rev_unit, rev_current_data, rev_year_ago_data)

  # Total Earnings
  earn_source_page = params[:earnings_source_page]
  earn_currency = params[:earnings_currency]
  earn_segment = 'Total'
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

    if session[:earnings_info] == 'y'
      earn_source_page = params["earnings_source_page_#{segment_number}".to_sym]
      earn_currency = params["earnings_currency_#{segment_number}".to_sym]
      earn_segment = params["segment_#{segment_number}_name".to_sym]
      earn_metric = params["earnings_metric_#{segment_number}".to_sym]
      earn_unit = params["earnings_unit_#{segment_number}".to_sym]
      earn_current_data = params["current_total_earnings_#{segment_number}".to_sym]
      earn_year_ago_data = params["past_total_earnings_#{segment_number}".to_sym]

      @storage.add_financial_data(company_id, report_id, earn_source_page, earn_currency, earn_segment, earn_metric, earn_unit, earn_current_data, earn_year_ago_data)
    end
  end

  redirect "/company_list"
end

post "/retrieve_data" do
  session[:retrieve_data_quarter] = params[:quarter]
  session[:retrieve_data_year] = params[:year]
  session[:retrieve_data_source] = params[:source]

  redirect "/financial_data_output"
end
