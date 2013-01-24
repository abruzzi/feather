require 'sinatra'
require 'omniauth-github'

require 'haml'
require 'data_mapper'

require 'json'

require './lib/user.rb'
require './lib/notes.rb'

configure do
    DataMapper::Logger.new(STDOUT, :debug)
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
                @current_user = User.first(:email => session[:user][:email])
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
                    error 401 unless send(name) == true
                end
            end
        end

        helpers do
            def valid?
                session[:user] != nil
            end
        end

        before do
            session[:user] = {:name => 'juntao', :email => 'juntao.qiu@gmail.com'}
            @current_user = User.first(:email => 'juntao.qiu@gmail.com')
            content_type :json
        end

        not_found do
            "404"
        end

        error do
            "error"
        end

        post '/users' do
            jdata = JSON.parse(request.body.read)
            @user = User.new(jdata)

            if @user.save
                {:user => @user, :status => 'success'}.to_json
            else
                {:user => @user, :status => 'failure'}.to_json
            end
        end

        # get all notes belong to a user
        get '/users/:userid/notes', :check => :valid? do
            user = User.get params[:userid]
            if @current_user == user
                notes = Note.all(:user => user, :order => :id.desc) || []
                notes.to_json
            end
        end

        # get a signle note belongs to a user
        get '/users/:userid/notes/:noteid', :check => :valid? do
            user = User.get params[:userid]
            if @current_user == user
                user = User.get params[:userid]
                note = Note.all :user => user, :id => params[:noteid]
                note.to_json
            end
        end

        # create a new note for user
        post '/users/:userid/notes', :check => :valid? do
            user = User.get params[:userid]
            if @current_user == user
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
            if @current_user == user
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
            if @current_user == user
                note = Note.get params[:noteid]

                if note.destroy
                    {:note => note, :status => 'success'}.to_json
                else
                    {:note => note, :status => 'failure'}.to_json
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
