require './app'

Warden::Strategies.add(:password) do
    def valid?
        params[:email] && params[:password]
    end

    def authenticate!
        user = User.authenticate(params[:email], params[:password])
        user.nil? ? fail!("could not log in") : success!(user)
    end
end

class NoteApplication < Sinatra::Base
    use Rack::Session::Cookie

    use Warden::Manager do |manager|
        manager.default_strategies :password
        manager.failure_app = NoteApplication
        manager.serialize_into_session{|user| user.id}
        manager.serialize_from_session{|id| User.find(id)}
    end


    Warden::Manager.before_failure do |env, opts|
        env['REQUEST_METHOD'] = "POST"
    end


    def warden_handler
        env['warden']
    end

    def check_authentication
        unless warden_handler.authenticated?
            session[:crumb_path] = env['PATH_INFO']
            redirect '/login'
        end
    end

    def current_user
        warden_handler.user
    end

    not_found do
        "404"
    end

    error do
        "error"
    end

    post '/unauthenticated/?' do
        status 401
        p "what the fuck is going on?"
        redirect '/login'
    end

    post '/login/?' do
        warden_handler.authenticate!
        haml :home
    end

    get '/home' do
        haml :home
    end

    get '/login' do
        haml :login
    end

    get '/logout' do
        warden_handler.logout
        redirect '/login'
    end
end

run NoteApplication
