require 'sinatra'
require 'haml'
require 'data_mapper'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/notes.db")

require './lib/user.rb'
require './lib/notes.rb'

DataMapper.finalize.auto_upgrade!

require './lib/helper/mobile.rb'

before do
    mobile_request? ? @mobile = ".mobile" : @mobile = ""
end

enable :sessions

get '/' do
    if session[:user] == nil
        redirect '/login'
    else
        redirect '/notes'
    end
end

get '/login' do
    #haml :login
    deliver :login
end

get '/logout' do
    session[:user] = nil
    redirect '/'
end

post '/login' do
    email = params[:email]
    pass = params[:password]

    user = User.first(:email => email)
    if user.password == pass
        session[:user] = user
        redirect '/notes'
    else
        session[:user] = nil
        redirect '/login'
    end
end

get '/notes' do
    user = session[:user]
    if user
        @notes = Note.all(:user => user, :order => :id.desc) || []
        #haml :home
        deliver :home
    else
        redirect '/login'
    end
end

post '/notes' do
    user = session[:user]
    if user == nil
        redirect '/login'
    else
        note = Note.new
        note.content = params[:content]
        note.created_at = Time.now
        note.updated_at = Time.now
        note.user = user 
        note.save
        redirect '/notes'
    end
end

# update the existing note
post '/notes/:id' do
    user = session[:user]
    if user == nil
        redirect '/login'
    else
        note = Note.get params[:id]
        note.content = params[:content]
        note.complete = params[:complete] ? 1 : 0
        note.updated_at = Time.now
        note.save
        redirect '/notes'
    end
end

# delete a note
get '/notes/:id/delete' do
    user = session[:user]
    if user == nil
        redirect '/login'
    else
        note = Note.get params[:id]
        note.destroy
        redirect '/notes'
    end
end

get '/notes/:id/complete' do
    user = session[:user]
    if user == nil
        redirect '/login'
    else
        note = Note.get params[:id]
        note.complete = note.complete ? 0 : 1
        note.updated_at = Time.now
        note.save
        redirect '/notes'
    end
end

get '/rss.xml' do
    @notes = Note.all :order => :id.desc
    builder :rss
end
