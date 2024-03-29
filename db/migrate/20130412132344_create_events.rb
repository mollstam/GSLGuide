class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.string :series, null: false
      t.datetime :date, null: false
      t.string :uri, null: false

      t.timestamps
    end
  end
end
