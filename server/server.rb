require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'json'

get '/' do
	"Hello there!"
end

# request a suggestion
get '/take' do
  # Does suggestions collection exist?
  # Retrieve random entry from suggestions collection
  # Send response containing suggestion and id
  {suggestion: 'The suggestion'}.to_json
end

# rate a suggestion
post '/take' do
  begin
    jdata = JSON.parse(request.body.read, :symbolize_names => true) 
    if jdata.has_key?(:rating) && jdata.has_key?(:id)
      # Does _id have entry in suggestions collection?
      # Update rating for _id
      return {status: 'Rated! Good work!'}.to_json
    else
      return {status: "Unable to rate suggestion :("}.to_json
    end
  rescue Exception => e
      return {status: e}
  end
end

# submit a new suggestion
post '/make' do
  begin
    jdata = JSON.parse(request.body.read, :symbolize_names => true) 
    if jdata.has_key?(:suggestion)
      # Create new suggestion hash and add it to collection
      return {status: "Suggestion received. Thanks!"}.to_json
    else
      return {status: "Unable to receive suggestion."}.to_json
    end
  rescue Exception => e
      return {status: e}
  end
end

