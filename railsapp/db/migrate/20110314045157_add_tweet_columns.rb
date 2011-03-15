class AddTweetColumns < ActiveRecord::Migration
  def self.up
    add_column :tweets, :profile_image_url, :text
    add_column :tweets, :location, :string
  end

  def self.down
    remove_column :tweets, :profile_image_url
    remove_column :tweets, :location
  end
end
