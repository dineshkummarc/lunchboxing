require "rubygems"
require "bundler/setup"
require "data_mapper"
require "dm-sqlite-adapter"
require "haml"
require "omniauth"
require "omniauth-github"
require "sinatra"
require "require_all"
require_rel "models/"
require_rel "lib/"


DataMapper::Logger.new($stdout, :debug)

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/database.db")

DataMapper.finalize
DataMapper.auto_upgrade!

use OmniAuth::Strategies::GitHub, 'dae71f2bbcadd5288245', '397ce8fea66137e6bf788f83a8d42f52f055d3c6'

enable :sessions

helpers do
  def current_user
    @current_user ||= User.get(session[:user_id]) if session[:user_id]
  end
end

helpers Sinatra::Partials

get '/' do
  haml :index
end

get '/auth/:name/callback' do
  auth = request.env["omniauth.auth"]
  user = User.first_or_create({ :uid => auth["uid"]}, {
    :uid => auth["uid"],
    :nickname => auth["info"]["nickname"], 
    :name => auth["info"]["name"],
    :created_at => Time.now })
  session[:user_id] = user.id
  redirect '/'
end

# any of the following routes should work to sign the user in: 
["/login/?", "/signup/?"].each do |path|
  get path do
    redirect '/auth/github'
  end
end

get '/logout' do
    session[:user_id] = nil
    redirect '/'
end

