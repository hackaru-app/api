# frozen_string_literal: true

class RemoveDeviseTokenAuth < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :provider
    remove_column :users, :uid
    remove_column :users, :reset_password_token
    remove_column :users, :reset_password_sent_at
    remove_column :users, :allow_password_change
    remove_column :users, :remember_created_at
    remove_column :users, :sign_in_count
    remove_column :users, :current_sign_in_at
    remove_column :users, :current_sign_in_ip
    remove_column :users, :last_sign_in_at
    remove_column :users, :last_sign_in_ip
    remove_column :users, :confirmation_token
    remove_column :users, :confirmed_at
    remove_column :users, :confirmation_sent_at
    remove_column :users, :unconfirmed_email
    remove_column :users, :name
    remove_column :users, :nickname
    remove_column :users, :image
    remove_column :users, :tokens

    rename_column :users, :encrypted_password, :password_digest
    change_column_null :users, :email, false
  end
end
