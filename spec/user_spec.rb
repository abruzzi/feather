require File.dirname(__FILE__) + '/spec_helper'

describe "user model" do
    it "validates when no email" do
        user = User.new(:name => 'name')
        res = user.save
        res.should eql(false)
        user.errors[:password].should eql(['Password must not be blank'])
        user.errors[:email].should eql(['Email must not be blank'])
    end

    it "validates when no password" do
        user = User.new(:name => 'name', 
                        :email => 'test@domain.com' )
        res = user.save
        res.should eql(false)
        user.errors[:password].should eql(['Password must not be blank'])
    end

    it "validates invalid email address format" do
        user = User.new(:name => 'name', 
                        :email => 'test.com', 
                        :password => 'pa$$w0rd')
        res = user.save
        res.should eql(false)
        user.errors[:email].should eql(['Email has an invalid format'])
    end

    it "creates an user" do
        user = User.new(:name => 'name', 
                        :email => 'test@domain.com', 
                        :password => 'pa$$w0rd')
        res = user.save
        res.should eql(true)
        user.name.should eql('name')
        user.email.should eql('test@domain.com')
        user.password.should eql('pa$$w0rd')
    end
end
