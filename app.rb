require 'sinatra'
require 'data_mapper'
require 'json'

require './notes.rb'

get '/' do
    content_type :json
    @notes = Note.all :order => :id.desc
    @notes.to_json()
end
