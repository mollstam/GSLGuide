class CreateMatchSets < ActiveRecord::Migration
  def change
    create_table :match_sets do |t|
      t.integer :gom_id
      t.references :event
      t.integer :index
      t.text :players
      t.string :map
      t.string :uri
      t.string :forum_thread_uri
      t.string :league
      t.integer :round
      t.string :group
      t.text :ratings

      t.timestamps
    end
  end
end
