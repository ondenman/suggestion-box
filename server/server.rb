require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'json'

require 'mongo'

class SuggestionBox
  attr_accessor :suggestions_count
  attr_reader :client
  def initialize
    @client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'suggestion-box')
    create_collection
  end

  def create_collection
    @suggestions = @client[:suggestions]
    @suggestions.create unless @client[:suggestions]
    @suggestions_count = @client[:suggestions].count
  end

  def random_suggestion
    @client[:suggestions]
      .find()
      .limit(1)
      .skip(rand(@suggestions_count))
      .first
  end

  def find_suggestion(id)
    id = BSON::ObjectId(id)
    @client[:suggestions]
      .find({_id: id })
      .limit(1)
      .first || false
  end

  def update_rating(id, rating)
    id = BSON::ObjectId(id)
    @client[:suggestions]
      .update_one(
        { _id: id }, 
        { "$inc" => { rating: 1 } }
      )
  end

  def add_suggestion(str, ip)
    new_suggestion = {suggestion: str, ip: ip }
    result = @client[:suggestions].insert_one(new_suggestion)
    @suggestions_count += 1 unless result.n != 1
    result
  end

  def delete_suggestion(id)
    id = BSON::ObjectId(id)
    @suggestions_count -= 1
    @client[:suggestions]
      .delete_one( { _id: id } )
  end

  def all_suggestions
    @client[:suggestions].find()
  end

  def wipe
    @client[:suggestions].drop
    create_collection
  end
end


box = SuggestionBox.new

get '/' do
	"Hello there!"
end

# request a suggestion
get '/take' do
  suggestion = box.random_suggestion
  if suggestion       
    return { 
      suggestion: suggestion[:suggestion], 
      id: suggestion[:_id].to_s
      }.to_json
  end
  return {status: 'No suggestions to retrieve'}.to_json
end

# rate a suggestion
post '/take' do
  begin
    jdata = JSON.parse(request.body.read, :symbolize_names => true)
    if jdata.has_key?(:rating) && jdata.has_key?(:id)
      suggestion = box.find_suggestion(jdata[:id])
      if suggestion
        current_rating = suggestion[:rating] || 0
        current_rating += jdata[:rating]

        if current_rating.to_i < 2
          result = box.update_rating(jdata[:id], jdata[:rating])
          return {status: "Rated! Good work! #{result[:rating]}"}.to_json
        else
          result = box.delete_suggestion(jdata[:id])
        end

      else
        return {status: "Unable to rate that suggestion :("}.to_json
      end
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
      result = box.add_suggestion(jdata[:suggestion], request.ip)
      return {status: "Suggestion received. Thanks!  #{result.inserted_id}"}.to_json
    else
      return {status: "Unable to receive suggestion."}.to_json
    end
  rescue Exception => e
      return {status: e}
  end
end

# list all suggestions
get '/list' do
  result = { all_suggestions: [] }
  box.all_suggestions.each do |sug|
    result[:all_suggestions].push({
      suggestion: sug[:suggestion],
      id: sug[:_id].to_s,
      ip: sug[:ip]
      })
  end
  return result.to_json
end

# remove all suggestions
get '/wipe' do
  result = box.wipe
  { status: "All wiped!" }.to_json
end

