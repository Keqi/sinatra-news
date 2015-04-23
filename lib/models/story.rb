class Story < ActiveRecord::Base
  self.table_name = "stories"

  paginates_per 2

  belongs_to :user, dependent: :destroy
  belongs_to :board
  has_many :votes

  validates :title, :url, presence: true

  def self.popular
    joins(:votes).select("stories.*, sum(value) as rank")
                 .group("stories.title, stories.url, stories.id")
                 .order("rank desc")
  end

end