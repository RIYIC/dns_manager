class AddColumnsToDomains < ActiveRecord::Migration
  def change
    add_column :domains, :user_id, :integer
    add_column :domains, :provider_id, :integer
  end
end
