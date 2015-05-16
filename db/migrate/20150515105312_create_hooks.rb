class CreateHooks < ActiveRecord::Migration
  def change
    create_table :hooks, id: false do |t|
      t.string :id
      t.string :slack_hook

      t.timestamps null: false
    end
  end
end
