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
  @company_list = @storage.all_company_names_and_tickers
  
  erb :company_list
end

get "/company_data_input" do
  session[:ticker] = params.keys[0]

  erb :company_data_input
end

get "/add_company" do

  erb :add_company
end

# get "/financial_data" do

#   erb :financial_data_input
# end

post "/add_company" do
  @storage.add_company(params[:company_name], params[:company_ticker])

  redirect "/company_list"
end

post "/financial_report" do
  session[:company_id] = @storage.find_company_id_from_ticker(session[:ticker])
  session[:quarter] = params[:quarter]
  session[:year] = params[:year]
  session[:period_end] = params[:period_end]
  session[:source] = params[:source]
  session[:source_url] = params[:source_url]
  session[:number_of_segments] = params[:number_of_segments]

  #add_financial_report(...)

  redirect "/financial_data"
end

