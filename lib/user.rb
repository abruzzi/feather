class User
    include DataMapper::Resource
    property :id, Serial
    property :name, String, :required => true
    property :email, String, :format => :email_address, :unique => true
    property :password, String, :required => true
    has n, :notes
end
