require "./env"
require "haml"
require "omniauth"
require "omniauth-github"
require "sinatra"
require "logger"
require "./lib/partials"

DataMapper::Logger.new($stdout, :debug)

DataMapper.auto_upgrade!

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

  def logged_in?
    redirect '/' unless current_user
  end

  def all_locations
    @locations = Location.all
  end

  def user_listed_locations(&block)
    lists = List.find( :user_id => current_user.id )
    lists.each do |list|
      locations = Location.all( :list_id => list.id )
      locations.each do |location|
        logger.info "#{location.name}"
        block.call location
      end
    end
  end

  def logger
    self.class.logger
  end

  def winner?
    choices ||= []
    user_listed_locations do |location|
      choices << location.name
    end
    choices.sample
  end

end

helpers Sinatra::Partials

get '/' do
  haml :index
end

####
# Locations
####
get '/locations' do
  logged_in?
  haml :locations
end

post '/location/create' do
  logged_in?
  logger.info "#{params}"
  location = Location.new
  location.name = params['name']
  location.address = params['address']
  location.distance = params['distance']
  if location.save
    status 201
    redirect '/locations'
  else
    status 503
  end
end

get '/location/:id' do
  @location = Location.get(params[:id])
  haml :location_view
end

get '/location/:id/edit' do
  @location = Location.get(params[:id])
  haml :location_edit
end

put '/location/:id' do
  @location = Location.get(params[:id])
  @location.name = params['name']
  @location.address = params['address']
  @location.distance = params['distance']

  if @location.save
    status 201
    redirect "/location/#{@location.id}"
  else
    status 500
  end
end



post '/location/destroy' do
  logged_in?
  location = Location.first(:id => params['locationID'])
  if location.destroy
    logger.debug "Destroying Location: #{location.name}"
    status 201
    redirect '/locations'
  else
    status 500
  end
end

####
# Lists
####
get '/list' do
  logged_in?
  haml :list
end

post '/list/add' do
  logged_in?
  logger.info "params: #{params}"
  list = List.first_or_create(:user_id => current_user.id)
  logger.info "#{list.inspect}"
  location = Location.first(:id => params['locationID'])
  logger.info "location #{location.name}"
  location.list_id = list.id
  location.save
  logger.info "location's list: #{location.list_id}"
  redirect '/list'
end

####
# authentication
####
if production?
  use OmniAuth::Strategies::GitHub, '9c7ba91b25c1e0f66dbc', '8fc5b0db2249738c2704aae9d3fcd57f794e327c'
else
  use OmniAuth::Strategies::GitHub, 'dae71f2bbcadd5288245', '397ce8fea66137e6bf788f83a8d42f52f055d3c6'
end

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

