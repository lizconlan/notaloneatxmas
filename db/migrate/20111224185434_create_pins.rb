class CreatePins < ActiveRecord::Migration
  def self.up
    create_table :pins do |t|
      t.string :name
      t.string :tweet_id
      t.string :postcode
      t.string :message
      
      t.timestamps
    end
  end

  def self.down
    drop_table :pins
  end
end
