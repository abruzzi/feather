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
        use Rack::Session::Cookie
        use OmniAuth::Builder do
            provider :github, 'a5e58cdb3b2c6bebbdb7', '30ebed2a49aef7be26e6866caa3da619073fe951',
                scope: "user,repo,gist"
        end

        # auth callback
        [:get, :post].each do |method|
            send method, '/auth/:provider/callback' do
                auth = request.env['omniauth.auth'].info
                session[:user] = {:name => auth.name, :email => auth.email}
                @current_user = User.all(:email => session[:user][:email])
            end
        end

        # if auth failure
        get '/auth/failure' do
            "#{params[:message]}"
            redirect '/'
        end

        register do
            def check name
                condition do
                    redirect '/login' unless send(name) == true
                end
            end
        end

        helpers do
            def valid?
                session[:user] != nil
            end
        end

        before do
            content_type :json
        end

        not_found do
            "404"
        end

        error do
            "error"
        end

        post '/users' do
            @user = User.new
            @user.name = params[:name]
            @user.email = params[:email]
            @user.password = 'pa$$w0rd'
            
            if @user.save
                {:user => @user, :status => 'success'}.to_json
            else
                {:user => @user, :status => 'failure'}.to_json
            end
        end

        # get all notes belong to a user
        get '/users/:userid/notes', :check => :valid? do
            if @current_user[:id] == params[:userid]
                user = User.get params[:userid]
                @notes = Note.all(:user => user, :order => :id.desc) || []
                @notes.to_json
            end
        end

        # get a signle note belongs to a user
        get '/users/:userid/notes/:noteid', :check => :valid? do
            if @current_user[:id] == params[:userid]
                user = User.get params[:userid]
                @note = Note.all :user => user, :id => params[:noteid]
                @note.to_json
            end
        end

        # create a new note for user
        post '/users/:userid/notes', :check => :valid? do
            if @current_user[:id] == params[:userid]
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
        end

        # update an existing note
        put '/users/:userid/notes/:noteid', :check => :valid? do
            if @current_user[:id] == params[:userid]
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
        end

        # delete an existing note
        delete '/users/:userid/notes/:noteid', :check => :valid? do
            if @current_user[:id] == params[:userid]
                user = User.get params[:userid]
                @note = Note.get params[:noteid]

                if @note.destroy
                    {:note => @note, :status => 'success'}.to_json
                else
                    {:note => @note, :status => 'failure'}.to_json
                end
            end
        end

        get '/' do
            content_type :html
            haml :index
        end

        get '/login' do
            content_type :html
            haml :auth
        end

        get '/logout' do
            session.clear
            redirect '/'
        end

    end
end
