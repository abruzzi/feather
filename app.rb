require 'sinatra'
require 'omniauth-github'

require 'haml'
require 'data_mapper'

require 'json'

require './lib/user.rb'
require './lib/notes.rb'

configure do
    DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/notes.db")
    DataMapper.finalize.auto_upgrade!
end

module Feather
    class NoteApplication < Sinatra::Base
        if not test?
            use Rack::Session::Cookie, :secret => 's3c23t'
            use OmniAuth::Builder do
                provider :github, 'a5e58cdb3b2c6bebbdb7', 
                    '30ebed2a49aef7be26e6866caa3da619073fe951',
                    scope: "user,repo,gist"
            end
        end

        # auth callback
        [:get, :post].each do |method|
            send method, '/auth/:provider/callback' do
                auth = request.env['omniauth.auth'].info
                session[:user] = User.first_or_create({:email => auth.email}, {
                    :name => auth.name,
                    :email => auth.email
                })
                
                p session[:user]
                redirect '/'
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

            def current_user
                session[:user]
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

        # get all notes belong to a user
        get '/notes', :check => :valid? do
            notes = Note.all(:user => current_user, :order => :id.desc) || []
            notes.to_json
        end

        # get a signle note belongs to a user
        get '/notes/:noteid', :check => :valid? do
            note = Note.all :user => current_user, :id => params[:noteid]
            note.to_json
        end

        # create a new note for user
        post '/notes', :check => :valid? do
            data = JSON.parse(request.body.read)
            data = data.merge(:complete => false, 
                              :created_at => Time.now, 
                              :updated_at => Time.now, 
                              :user => current_user)

            note = Note.new(data)

            if note.save
                {:note => note, :status => 'success'}.to_json
            else
                {:note => note, :status => 'failure'}.to_json
            end
        end

        # update an existing note
        put '/notes/:noteid', :check => :valid? do
            note = Note.get params[:noteid]

            data = JSON.parse(request.body.read)
            data = data.merge(:updated_at => Time.now, 
                              :user => current_user)
            note.attributes = data

            if note.save
                {:note => note, :status => 'success'}.to_json
            else
                {:note => note, :status => 'failure'}.to_json
            end
        end

        # delete an existing note
        delete '/notes/:noteid', :check => :valid? do
            note = Note.get params[:noteid]
            if current_user == note.user
                if note.destroy
                    {:note => note, :status => 'success'}.to_json
                else
                    {:note => note, :status => 'failure'}.to_json
                end
            end
        end

        get '/' do
            if current_user != nil
                content_type :html
                haml :index
            else
                redirect '/login'
            end
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
