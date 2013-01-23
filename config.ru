require './app'

module Feather
    class NoteApplication < Sinatra::Base
        use Rack::Session::Cookie
        use OmniAuth::Builder do
            # provider :open_id, :store => OpenID::Store::Filesystem.new('/tmp')
            # provider :open_id, 
            #     :name => 'google', 
            #     :store => OpenID::Store::Filesystem.new('/tmp'),
            #     :identifier => 'https://www.google.com/accounts/o8/id' 
            provider :github, 'a5e58cdb3b2c6bebbdb7', '30ebed2a49aef7be26e6866caa3da619073fe951',
                scope: "user,repo,gist"
        end

        not_found do
            "404"
        end

        error do
            "error"
        end

        get '/' do
            redirect '/home' if session[:user]
            <<-HTML
            Login using<a href='/auth/github'> github auth </a>
            HTML
        end

        get '/home' do
            @notes = []
            haml :home
        end

        get '/logout' do
            session[:user] = nil
        end

        [:get, :post].each do |method|
            send method, '/auth/:provider/callback' do
                auth = request.env['omniauth.auth'].info
                session[:user] = {:name => auth.name, :email => auth.email}
                redirect '/home'
            end
        end

        get '/auth/failure' do
            "#{params[:message]}"
            redirect '/'
        end
    end
end

run Feather::NoteApplication
