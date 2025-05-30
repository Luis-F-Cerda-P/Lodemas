class CreateJwtTokenSets < ActiveRecord::Migration[8.0]
  def change
    create_table :jwt_token_sets do |t|
      t.string :access_token
      t.datetime :access_token_expires_at
      t.string :refresh_token
      t.datetime :refresh_token_expires_at
      t.string :aws_token
      t.datetime :aws_token_expires_at
      t.string :identity_id
      t.references :tax_account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
