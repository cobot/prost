class CreateMemberships < ActiveRecord::Migration
  def up
    create_table :memberships do |t|
      t.belongs_to :space, :user
      t.string :name, :cobot_member_id
    end
    add_index :memberships, :space_id
  end

  def down
    drop_table :memberships
  end
end
