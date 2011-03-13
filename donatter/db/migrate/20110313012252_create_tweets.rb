class CreateTweets < ActiveRecord::Migration
  def self.up
    create_table :tweets do |t|
      t.string :tweet_id
      t.integer :twitter_id
      t.string :screen_name
      t.text :text

      t.timestamps
    end
  end

  def self.down
    drop_table :tweets
  end
end
