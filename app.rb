require 'sinatra'
require 'haml'
require 'data_mapper'

require './notes.rb'

get '/' do
    @notes = Note.all :order => :id.desc
    haml :home
end

post '/' do
    note = Note.new
    note.content = params[:content]
    note.created_at = Time.now
    note.updated_at = Time.now
    note.save
    redirect '/'
end
