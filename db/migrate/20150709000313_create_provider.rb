class CreateProvider < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :characteristics, default: '{}'
    end

    add_index :providers, :slug, unique: true
  end
end
