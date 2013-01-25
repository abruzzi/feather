class User
    include DataMapper::Resource
    property :id, Serial
    property :name, String, :required => true
    property :email, String, :format => :email_address, :required => true, :unique => true
    property :created_at, DateTime
    property :updated_at, DateTime
    has n, :notes

    def self.authorise email, password
        user = self.first(:email => email)
        return !user.nil? && user[:password] == password
    end
end
