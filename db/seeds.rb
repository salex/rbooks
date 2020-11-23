# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

book = Books::Setup.new(id:1,name:'BizzAccts')
book.create_book_tree
#creates a new book with only basic accounts

User.create(email:'reviewer@guest.com',username:'reviewer',full_name:'Invited Guest',roles:['super','trustee'],password:'letmein',password_confirmation:'letmein')


# ActiveRecord::Base.connection.tables.each do |t|
#   ActiveRecord::Base.connection.reset_pk_sequence!(t)
# end

# use the above if you import an existing database using psql -d rbooks_xxxx < xxx.sql