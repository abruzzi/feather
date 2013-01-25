require File.dirname(__FILE__) + '/spec_helper'

session = {}
describe 'Feather' do
    include Rack::Test::Methods

    def app
        Feather::NoteApplication
    end

    before(:each) do
        @note = FactoryGirl.create(:note)
    end

    it "returns ok when access index" do
        get '/'
        last_response.status.should == 302
        follow_redirect!
        last_request.url.should include('/login')
    end

    it "returns not authentication error" do
        get '/users/1/notes'
        last_response.status.should == 401
    end

    it "returns not authentication error" do
        session[:user] = {:name => 'juntao', :email => 'juntao.qiu@gmail.com'}
        get "/users/#{@note.user.id}/notes", {}, 'rack.session' => session
        last_response.status.should == 200
        last_response.body.should include('This is a note to remind me to raise up earlier')
    end
end
