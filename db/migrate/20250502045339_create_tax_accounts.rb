class CreateTaxAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :tax_accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :rut
      t.string :password

      t.timestamps
    end
  end
end
