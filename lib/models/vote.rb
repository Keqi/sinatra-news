class Vote < ActiveRecord::Base
  self.table_name = "votes"

  belongs_to :user
  belongs_to :story
end