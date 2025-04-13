class CreateMeliAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :meli_accounts do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :mercadolibre_identifier
      t.string :nickname
      t.string :site_code

      t.timestamps
    end
  end
end
