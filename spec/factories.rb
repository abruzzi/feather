require 'factory_girl'

FactoryGirl.define do
    factory :user, :class => User do
        name 'juntao'
        email 'juntao.qiu@gmail.com'
        password 'pa$$w0rd'
    end

    factory :note, :class => Note do
        content 'todo'
        association :user
    end
end
