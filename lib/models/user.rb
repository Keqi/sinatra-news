class User < ActiveRecord::Base
  self.table_name = "users"

  has_many :stories
  has_many :votes

  validates :username, :password, presence: true
  validates :password, length: { minimum: 6 }
end