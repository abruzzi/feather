require 'sinatra'
require 'omniauth-github'

require 'rack/contrib'

require 'haml'
require 'data_mapper'

require 'json'

require './lib/user.rb'
require './lib/notes.rb'

require './lib/helper/mobile.rb'

configure do
    DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/notes.db")
    DataMapper.finalize.auto_upgrade!
end

module Feather
    class NoteApplication < Sinatra::Base
        use Rack::PostBodyContentTypeParser

        if not test?
            use Rack::Session::Cookie, :secret => 's3c23t'
            use OmniAuth::Builder do
                provider :github, 'a5e58cdb3b2c6bebbdb7', 
                    'f8aa1d494bc731f448679620d8bd8222b3285bbf',
                    scope: "user,repo,gist"
            end
        end

        # auth callback
        [:get, :post].each do |method|
            send method, '/auth/:provider/callback' do
                auth = request.env['omniauth.auth'].info

                session[:user] = auth.email
                name = auth.name || auth.nickname

                User.first_or_create({:email => auth.email}, {
                    :name => name,
                    :email => auth.email
                })
                
                p session[:user]
                redirect '/'
            end
        end

        # if auth failure
        get '/auth/failure' do
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
                User.first(:email => session[:user])
            end
            # Regexes to match identifying portions of UA strings from iPhone and Android
            def mobile_user_agent_patterns
                [
                    /AppleWebKit.*Mobile/,
                    /Android.*AppleWebKit/
                ]
            end

            # Compares User Agent string against regexes of designated mobile devices
            def mobile_request? 
                mobile_user_agent_patterns.any? {|r| request.env['HTTP_USER_AGENT'] =~ r}
            end

            # If there is a mobile version of the view, use that. Otherwise revert to normal view
            def mobile_file(name)
                mobile_file = "#{options.views}/#{name}#{@mobile}.haml"
                if File.exist? mobile_file
                    view = "#{name}#{@mobile}"
                else
                    view = name
                end
            end

            # Set up rendering for partials
            def partial(name)
                haml mobile_file("_#{name}").to_sym, :layout => false
            end

            # Render appropriate file, with mobile layout if needed
            def deliver(name)
                haml mobile_file(name).to_sym, :layout => :"layout#{@mobile}"
            end


            def authorised?
                return session[:user] == nil?
            end
        end

        before do
            mobile_request? ? @mobile = ".mobile" : @mobile = ""
            content_type :json
        end

        not_found { "404" }

        error { "error" }

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
            note = Note.create(:complete => params[:complete], 
                              :content => params[:content],
                              :created_at => Time.now,
                              :updated_at => Time.now,
                              :user => current_user)
            if note.save
                {:note => note, :status => 'success'}.to_json
            else
                p note.errors
                {:note => note, :status => 'failure'}.to_json
            end
        end

        # update an existing note
        put '/notes/:noteid', :check => :valid? do
            note = Note.get params[:noteid]

            note.content = params[:content] 
            note.complete = params[:complete]
            note.updated_at = Time.now
            note.user = current_user

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
                    redirect "/notes"
                else
                    {:note => note, :status => 'failure'}.to_json
                end
            end
        end

        get '/' do
            content_type :html
            if current_user != nil
                deliver :home
            else
                deliver :index
            end
        end

        get '/logout' do
            session.clear
            redirect '/'
        end

    end
end
