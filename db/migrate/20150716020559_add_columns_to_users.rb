class AddColumnsToUsers < ActiveRecord::Migration

    def change
        add_column :users, :uuid, :string
        add_column :users, :name, :string

        remove_index :users, :uid
        remove_column :users, :uid

        add_index :users, :uuid

    end
end
