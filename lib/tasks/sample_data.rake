
namespace :db do
  desc 'Fill database with sample data'
  task populate: :environment do
    # Create test users
    User.create!( name: "Example User",
                  email: "example@railstutorial.org",
                  password: "foobar",
                  password_confirmation: "foobar" )
    99.times do |n|
      name = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password = "password"
      User.create!( name: name,
                    email: email,
                    password: password,
                    password_confirmation: password )
    end	# 99.times do

    # Create test keywords
    users = User.all( limit: 6 )
    50.times do
      keys = Faker::Lorem.sentence(1)
      users.each { |user| user.keywords.create!( keys: keys ) }
    end    # 50.times

  end	# task populate do
end	# namespace do

