class User < ActiveRecord::Base
  self.table_name = "users"

  has_many :stories
  has_many :votes
end