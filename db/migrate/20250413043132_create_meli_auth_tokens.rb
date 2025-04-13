class CreateMeliAuthTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :meli_auth_tokens do |t|
      t.belongs_to :meli_account, null: false, foreign_key: true
      t.string :access_token
      t.string :refresh_token
      t.datetime :expires_at

      t.timestamps
    end
  end
end
