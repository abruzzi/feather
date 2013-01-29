require 'sinatra'
require 'omniauth-github'

require 'haml'
require 'data_mapper'

require 'json'

require './lib/user.rb'
require './lib/notes.rb'

configure do
    # DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/feather")
    DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/notes.db")
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

        # create a new note for user
        post '/users/:userid/notes', :check => :valid? do
            user = User.get params[:userid]
            if current_user == user
                note = Note.new
                note.content = params[:content]
                note.complete = false
                note.created_at = Time.now
                note.updated_at = Time.now
                note.user = user

                if note.save
                    redirect "/users/#{user.id}/notes"
                else
                    error 500
                end
            end
        end

        # update an existing note
        put '/users/:userid/notes/:noteid', :check => :valid? do
            user = User.get params[:userid]
            if current_user == user
                note = Note.get params[:noteid]
                note.content = params[:content]
                note.complete = params[:complete]
                note.updated_at = Time.now

                if note.save
                    redirect "/users/#{user.id}/notes"
                else
                    error 500
                end
            end
        end

        # delete an existing note
        delete '/users/:userid/notes/:noteid', :check => :valid? do
            user = User.get params[:userid]
            if current_user == user
                note = Note.get params[:noteid]

                if note.destroy
                    redirect "/users/#{user.id}/notes"
                else
                    error 500
                end
            end
        end

        get '/' do
            haml :index
            # unless session[:user]
            #     redirect '/login'
            # end
            # redirect "/users/#{session[:user].id}/notes"
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

        get '/logout' do
            session.clear
            redirect '/login'
        end

        # get '/signup' do
        #     haml :signup
        # end

        post '/signup' do
            user = User.new

            user.name = params[:email]
            user.password = params[:password]
            user.email = params[:email]

            if user.save
                redirect '/'
            else
                redirect '/signup'
            end
        end

    end
end
