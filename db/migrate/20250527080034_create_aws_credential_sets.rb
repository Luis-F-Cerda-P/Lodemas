class CreateAwsCredentialSets < ActiveRecord::Migration[8.0]
  def change
    create_table :aws_credential_sets do |t|
      t.string :access_key_id
      t.string :secret_access_key
      t.string :session_token
      t.datetime :expires_at
      t.references :tax_account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
