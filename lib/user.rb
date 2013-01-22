class User
    include DataMapper::Resource
    property :id, Serial
    property :name, String, :required => true
    property :email, String, :format => :email_address, :unique => true
    property :password, String, :required => true
    has n, :notes

    def self.authenticate(email, password)
        user = self.first(:email => email)
        user && user.password  == password ? user : nil
    end
end
