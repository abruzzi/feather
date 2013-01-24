class User
    include DataMapper::Resource
    property :id, Serial
    property :name, String, :required => true
    property :email, String, :format => :email_address, :required => true, :unique => true
    property :password, String, :required => true
    has n, :notes
end
