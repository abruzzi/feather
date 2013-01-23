require 'sinatra'
require 'omniauth-openid'
require 'omniauth-github'
require 'openid/store/filesystem'

require 'haml'
require 'data_mapper'

require 'json'

DataMapper::setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/notes.db")

require './lib/user.rb'
require './lib/notes.rb'

DataMapper.finalize.auto_upgrade!


before do
    content_type :json
end

# get all notes belong to a user
get '/users/:userid/notes' do
    user = User.get params[:userid]
    @notes = Note.all(:user => user, :order => :id.desc) || []
    @notes.to_json
end

# get a signle note belongs to a user
get '/users/:userid/notes/:noteid' do
    user = User.get params[:userid]
    @note = Note.all :user => user, :id => params[:noteid]
    @note.to_json
end

# create a new note for user
post '/users/:userid/notes' do
    user = User.get params[:userid]
    @note = Note.new
    @note.complete = false
    @note.content = params[:content]
    @note.created_at = Time.now
    @note.updated_at = Time.now
    @note.user = user 

    if @note.save
        {:note => @note, :status => 'success'}.to_json
    else
        {:note => @note, :status => 'failure'}.to_json
    end
end

# update an existing note
put '/users/:userid/notes/:noteid' do
    user = User.get params[:userid]
    @note = Note.get params[:noteid]

    @note.complete = params[:complete]
    @note.content = params[:content]
    @note.updated_at = Time.now
    @note.user = user 

    if @note.save
        {:note => @note, :status => 'success'}.to_json
    else
        {:note => @note, :status => 'failure'}.to_json
    end
end

# delete an existing note
delete '/users/:userid/notes/:noteid' do
    user = User.get params[:userid]
    @note = Note.get params[:noteid]

    if @note.destroy
        {:note => @note, :status => 'success'}.to_json
    else
        {:note => @note, :status => 'failure'}.to_json
    end
end
