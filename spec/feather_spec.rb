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
        last_response.status.should == 200
        last_response.body.should include('index')
    end

    it "returns not authentication error" do
        get '/users/1/notes'
        last_response.status.should == 401
    end

    it "returns not authentication error" do
        session[:user] = {:name => 'juntao', :email => 'juntao.qiu@gmail.com'}
        get "/users/#{@note.user.id}/notes", {}, 'rack.session' => session
        last_response.status.should == 200
        last_response.body.should eql('[{"id":1,"content":"todo","complete":false,"created_at":null,"updated_at":null,"user_id":1}]')
    end
end
