require 'sinatra'
require 'haml'
require 'data_mapper'

require './notes.rb'

get '/' do
    @notes = Note.all :order => :id.desc
    haml :home
end

post '/' do
    'no post by now'
end
