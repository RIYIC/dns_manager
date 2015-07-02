class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
        t.integer :domain_id
        t.string :name, null: false
        t.string :zone_type, null: false
        t.string :data
        t.string :extra, null: true, default: nil
        t.string :active, default: 'Y'
        t.datetime :modification_timestamp


        t.timestamps null: false
    end

  end
end
