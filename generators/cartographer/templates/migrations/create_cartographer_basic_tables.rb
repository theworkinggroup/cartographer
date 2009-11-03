class CreateCartographerBasicTables < ActiveRecord::Migration
  def self.up
    create_table :cartographer_locations do |t|
      t.string :full_address
      t.string :street_address
      t.string :city
      t.string :state_code, :limit => 10
      t.string :country_code, :limit => 2
      t.string :accuracy
      t.decimal :lat, :decimal, :precision => 9, :scale => 6
      t.decimal :lng, :decimal, :precision => 9, :scale => 6
      t.timestamps
    end
    
    create_table :cartographer_pins do |t|
      t.column :location_id, :integer
      t.column :lat, :decimal, :precision => 9, :scale => 6
      t.column :lng, :decimal, :precision => 9, :scale => 6
      (2..31).each do |n|
        t.integer "square_code_#{n}", :limit => ((n * 2 + 1).to_f / 8).ceil
      end
    end
    
    (2..31).each do |n|
      add_index :cartographer_pins, "square_code_#{n}"
    end
    
    add_index :cartographer_pins, :location_id
    
  end
  
  def self.down
    drop_table :cartographer_locations
    drop_table :cartographer_pins
  end
end
