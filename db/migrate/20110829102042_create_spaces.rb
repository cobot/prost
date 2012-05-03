class CreateSpaces < ActiveRecord::Migration
  def up
    create_table :spaces do |t|
      t.string :url, :name
    end
    add_index :spaces, :url
    add_index :spaces, :name
  end

  def down
    drop_table :spaces
  end
end
