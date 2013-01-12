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

get '/rss.xml' do
    @notes = Note.all :order => :id.desc
    builder :rss
end

get '/:id' do
    @note = Note.get params[:id]
    haml :edit
end

post '/:id' do
    note = Note.get params[:id]
    note.content = params[:content]
    note.complete = params[:complete] ? 1 : 0
    note.updated_at = Time.now
    note.save
    redirect '/'
end

delete '/:id' do
    note = Note.get params[:id]
    note.destroy
    redirect '/'
end

get '/:id/complete' do
    note = Note.get params[:id]
    note.complete = note.complete ? 0 : 1
    note.updated_at = Time.now
    note.save
    redirect '/'
end
