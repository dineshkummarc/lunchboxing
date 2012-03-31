require "./env"
require "haml"
require "omniauth"
require "omniauth-github"
require "sinatra"
require "logger"
require "./lib/partials"

DataMapper::Logger.new($stdout, :debug)

DataMapper.auto_upgrade!

use OmniAuth::Strategies::GitHub, 'dae71f2bbcadd5288245', '397ce8fea66137e6bf788f83a8d42f52f055d3c6'

enable :sessions

Sinatra::Application.instance_eval do
  def logger
    @___logger ||= Logger.new(STDOUT)
  end
end

set :haml, :format => :html5

helpers do
  def current_user
    @current_user ||= User.get(session[:user_id]) if session[:user_id]
  end

  def all_locations
    @locations = Location.all
  end

  def logger
    self.class.logger
  end
end

helpers Sinatra::Partials

get '/' do
  logger << "BEEF\n"
  haml :index
end

post '/location/create' do
  logger.info "#{params}"
  location = Location.new
  location.name = params['name']
  location.address = params['address']
  location.distance = params['distance']
  if location.save
    status 201
    redirect '/'
  else
    status 503
  end
end

##
# authentication
##

# callback for oauth 
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

