Warden::Strategies.add(:password) do
    def valid?
        params[:email] && params[:password]
    end

    def authenticate!
        user = User.authenticate(params[:email], params[:password])
        user.nil? ? fail!("could not log in") : success!(user)
    end
end
