class Story < ActiveRecord::Base
  self.table_name = "stories"

  belongs_to :user
end