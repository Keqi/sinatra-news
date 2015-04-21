class Board < ActiveRecord::Base
  self.table_name = "boards"

  has_many :stories
end