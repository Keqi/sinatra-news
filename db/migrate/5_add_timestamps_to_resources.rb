class AddTimestampsToResources < ActiveRecord::Migration
  def change
    add_column :users, :created_at, :date
    add_column :users, :updated_at, :date

    add_column :votes, :created_at, :date
    add_column :votes, :updated_at, :date

    add_column :stories, :created_at, :date
    add_column :stories, :updated_at, :date
  end
end