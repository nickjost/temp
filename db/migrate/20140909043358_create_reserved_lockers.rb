class CreateReservedLockers < ActiveRecord::Migration
  def change
    create_table :reserved_lockers do |t|
      t.integer :number
      t.string :size

      t.timestamps null: false
    end
  end
end
