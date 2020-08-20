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