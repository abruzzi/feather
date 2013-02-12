require 'factory_girl'

FactoryGirl.define do
    factory :user, :class => User do
        name 'juntao'
        email 'juntao.qiu@gmail.com'
    end

    factory :note, :class => Note do
        content 'This is a note to remind me to raise up earlier'
        association :user
    end
end
