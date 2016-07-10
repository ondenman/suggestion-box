require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'json'

require 'mongo'

class SuggestionBox
  attr_accessor :suggestions_count
  attr_reader :client

  def initialize§
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
    @client[:suggestions]
      .find({_id: BSON::ObjectId(id) })
      .limit(1)
      .first || false
  end

  def update_rating(id, rating)
    @client[:suggestions].find({id: BSON::ObjectId(id)})
     .update_one({ :rating => rating })
  end

  def edit_suggestion(id, str)
    @client[:suggestions].find({_id: BSON::ObjectId(id)})
      .update_one({suggestion: str})
  end

  def add_suggestion(str, ip)
    new_suggestion = {suggestion: str, ip: ip, rating: 0 }
    result = @client[:suggestions].insert_one(new_suggestion)
    @suggestions_count += 1 unless result.n != 1
    result
  end

  def delete_suggestion(id)
    @suggestions_count -= 1
    @client[:suggestions]
      .delete_one( { _id: BSON::ObjectId(id) } )
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
      success: true,
      suggestion: suggestion[:suggestion], 
      id: suggestion[:_id].to_s
      }.to_json
  end
  return {success: false}.to_json
end

# rate a suggestion
post '/take' do
  begin
    jdata = JSON.parse(request.body.read, :symbolize_names => true)
    if jdata.has_key?(:rating) 
    && jdata.has_key?(:id) 
    && box.find_suggestion(jdata[:id])
      box.update_rating(jdata[:id], jdata[:rating])
      return {success: true}.to_json
    else
      return {success: false}.to_json
    end
  rescue Exception => e
      return {success: false, status: e}
  end
end

# submit a new suggestion
post '/make' do
  begin
    jdata = JSON.parse(request.body.read, :symbolize_names => true) 
    if jdata.has_key?(:suggestion)
      result = box.add_suggestion(jdata[:suggestion], request.ip)
      return {success: true}.to_json
    else
      return {success: false}.to_json
    end
  rescue Exception => e
      return {status: e, success: false}
  end
end

# list all suggestions
get '/list' do
  result = { all_suggestions: [] }
  box.all_suggestions.each do |e|
    result[:all_suggestions].push({
      suggestion: e[:suggestion],
      id: e[:_id].to_s,
      ip: e[:ip]
      })
  end
  result[:success] = true
  return result.to_json
end

# remove all suggestions
get '/wipe' do
  result = box.wipe
  { success: true }.to_json
end

