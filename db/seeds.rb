# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
[ Account, ArchivedPresenter, Comment, Presenter, ProgramEntry, Program, PropileConfig, Review, Session, Vote ].each &:delete_all

module ActiveModel 
  module MassAssignmentSecurity 
    class Sanitizer 
      def sanitize(attributes, authorizer) 
        attributes 
      end 
    end 
  end 
end

Account.create!(
  id: 1,
  email: 'manuel.vacelet@gmail.com',
  role: 'maintainer',
  encrypted_password: '$2a$10$DGTDwo7Y0knxK8FSYufG6OQE9jaMsUGxsuSJw71V.9MFRAZbPA6eK',
  password_salt: '$2a$10$DGTDwo7Y0knxK8FSYufG6O',
  authentication_token: 'a19a45ad-0a47-67c8-31a2-e6ea89dd26a3',
  confirmed_at: Time.new( 2012, 5, 29, 12, 32 ),
  reset_at: nil,
  created_at: Time.new( 2012, 5, 24, 21, 47 ),
  updated_at: Time.new( 2012, 5, 29, 12, 32 ),
  last_login: nil,
)

table_name = Account.table_name
ActiveRecord::Base.connection.execute(
    "ALTER SEQUENCE #{table_name}_id_seq RESTART WITH 3"
)


Presenter.create!(
  id: 1,
  name: nil,
  bio: nil,
  created_at: Time.new( 2012, 5, 4, 8, 43 ),
  updated_at: Time.new( 2012, 5, 24, 21, 47 ),
  account_id: 1,
  twitter_id: nil,
  profile_image: nil,
  website: nil,
)

table_name = Presenter.table_name
ActiveRecord::Base.connection.execute(
    "ALTER SEQUENCE #{table_name}_id_seq RESTART WITH 3"
)


table_name = Session.table_name
ActiveRecord::Base.connection.execute(
    "ALTER SEQUENCE #{table_name}_id_seq RESTART WITH 2"
)


table_name = Review.table_name
ActiveRecord::Base.connection.execute(
    "ALTER SEQUENCE #{table_name}_id_seq RESTART WITH 3"
)

table_name = Comment.table_name
ActiveRecord::Base.connection.execute(
    "ALTER SEQUENCE #{table_name}_id_seq RESTART WITH 4"
)
email, pass = 'serge.hardy@wanadoo.fr', 'password'



me = Account.new
me.id=2
me.email = email
me.maintainer = true # set to false if you want a presenter account
me.password = pass
me.password_confirmation = pass
me.confirmed_at = Time.now

me.save

Presenter.create!(
  id: 2,
  name: nil,
  bio: nil,
  created_at: Time.new( 2012, 5, 4, 8, 43 ),
  updated_at: Time.new( 2012, 5, 24, 21, 47 ),
  account_id: me.id,
  twitter_id: nil,
  profile_image: nil,
  website: nil,
)


email, pass = 'serge.hardy@orange.fr', 'password'



me = Account.new
me.id=3
me.email = email
me.maintainer = false # set to false if you want a presenter account
me.password = pass
me.password_confirmation = pass
me.confirmed_at = Time.now

me.save

Presenter.create!(
  id: 3,
  name: nil,
  bio: nil,
  created_at: Time.new( 2012, 5, 4, 8, 43 ),
  updated_at: Time.new( 2012, 5, 24, 21, 47 ),
  account_id: me.id,
  twitter_id: nil,
  profile_image: nil,
  website: nil,
)

