require File.dirname(__FILE__) + '/spec_helper'

describe "notes model" do
    it "validates when note has no content" do
        note = Note.new()
        res = note.save
        res.should eql(false)
        note.errors[:content].should eql(['Content must not be blank'])
    end

    it "validate when note has no owner" do
        note = Note.new(:content => 'todo')
        res = note.save
        res.should eql(false)
        note.errors[:user_id].should eql(['User must not be blank'])
    end

    it "creates a new note belongs to someone" do
        user = User.new(:name => 'name', :email => 'test@domain.com', :password => 'pa$$w0rd')
        note = Note.new(:content => 'todo', :user => user)
        res = note.save
        res.should eql(true)

        note.content.should eql('todo')
        note.user.name.should eql('name')
    end
end
