require 'sinatra'
require 'omniauth-github'

require 'haml'
require 'data_mapper'

require 'json'

require './lib/user.rb'
require './lib/notes.rb'

configure do
    DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/feather")
    DataMapper.finalize.auto_upgrade!
end

module Feather
    class NoteApplication < Sinatra::Base
        if not test?
            use Rack::Session::Cookie, :secret => 's3c23t'
        end

        register do
            def check name
                condition do
                    error 401 unless send(name) == true
                end
            end
        end

        helpers do
            def valid?
                session[:user] != nil
            end

            def current_user
                User.first(:email => session[:user][:email])
            end
        end

        not_found do
            haml :not_found
        end

        # get all notes belong to a user
        get '/users/:userid/notes', :check => :valid? do
            user = User.get params[:userid]
            if current_user == user
                @current_user = current_user
                @notes = Note.all(:user => user, :order => :id.desc) || []
                haml :home
            end
        end

        # get a signle note belongs to a user
        get '/users/:userid/notes/:noteid', :check => :valid? do
            user = User.get params[:userid]
            if current_user == user
                user = User.get params[:userid]
                note = Note.all :user => user, :id => params[:noteid]
                note.to_json
            end
        end

        # create a new note for user
        post '/users/:userid/notes', :check => :valid? do
            user = User.get params[:userid]
            if current_user == user
                data = JSON.parse(request.body.read)
                data = data.merge(:complete => false, :created_at => Time.now, :updated_at => Time.now, :user => user)

                note = Note.new(data)

                if note.save
                    {:note => note, :status => 'success'}.to_json
                else
                    {:note => note, :status => 'failure'}.to_json
                end
            end
        end

        # update an existing note
        put '/users/:userid/notes/:noteid', :check => :valid? do
            user = User.get params[:userid]
            if current_user == user
                note = Note.get params[:noteid]

                data = JSON.parse(request.body.read)
                data = data.merge(:updated_at => Time.now, :user => user)
                note.attributes = data

                if note.save
                    {:note => note, :status => 'success'}.to_json
                else
                    {:note => note, :status => 'failure'}.to_json
                end
            end
        end

        # delete an existing note
        delete '/users/:userid/notes/:noteid', :check => :valid? do
            user = User.get params[:userid]
            if current_user == user
                note = Note.get params[:noteid]

                if note.destroy
                    {:note => note, :status => 'success'}.to_json
                else
                    {:note => note, :status => 'failure'}.to_json
                end
            end
        end

        get '/' do
            haml :index
        end

        get '/login' do
            haml :login
        end

        post '/login' do
            email = params[:email]
            password = params[:password]
            if User.authorise(email, password)
                user = User.first(:email => email)
                session[:user] = user
                redirect "/users/#{session[:user].id}/notes"
            else
                redirect '/login'
            end
        end

        get '/signup' do
            haml :signup
        end

        post '/signup' do
            name = params[:email]
            email = params[:email]
            password = params[:password]
            
            user = User.new(:name => name, :email => email, :password => password)
            if user.save
                session[:user] = user
                redirect "/users/#{user.id}/notes"
            else
                redirect '/signup'
            end
        end

        get '/logout' do
            session.clear
            redirect '/'
        end

    end
end
