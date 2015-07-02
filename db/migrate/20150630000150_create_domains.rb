class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
        t.string :name, null: false
        t.string :active, default: 'Y'
        
        t.timestamps null: false
    end

    add_index :domains, :name, unique: true
  end
end
