class CreateMeliNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :meli_notifications do |t|
      t.string :resource
      t.integer :meli_user_id
      t.string :topic
      t.integer :application_id
      t.integer :attempts
      t.datetime :sent
      t.datetime :received
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
