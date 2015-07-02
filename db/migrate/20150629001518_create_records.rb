class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
        t.integer :domain_id
        t.string :name, null: false
        t.string :zone_type, null: false
        t.string :data
        t.integer :priority, null: true, default: nil
        t.integer :port, null:true, default: nil # SRV port
        t.integer :weight, null:true, default: nil # SRV weight
        t.string :active, default: 'Y'
        t.string :provider_ref
        t.datetime :modification_timestamp


        t.timestamps null: false
    end

  end
end
