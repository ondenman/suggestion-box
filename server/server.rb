require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'json'

get '/' do
	"Hello there!"
end

get '/take' do
	# requests a suggestion
	"A suggestion!"
end

post '/take' do
	return_message = {}
  
  begin
    jdata = JSON.parse(params[:data], :symbolize_names => true)
    if jdata.has_key?(:rating) && jdata.has_key?(:id)
      # rate suggestion
      return_message[:status] = 'Rated!'
    else
      return_message[:status] = 'Unable to rate :('
    end
  rescue Exception => e
    return_message[:status] = e
  end

	return_message.to_json
	# rates a suggestion
end

post '/make' do
	# submits a new suggestion
end

