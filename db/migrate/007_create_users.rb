class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column :login,                     :string
      t.column :email,                     :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
    end
    u = User.new
    u.login = "Terry"
    u.email = "tersmi1@gmail.com"
    u.remember_token_expires_at = 2.weeks.from_now.utc
    u.remember_token  = Digest::SHA1.hexdigest("#{u.email}--#{u.remember_token_expires_at}")
    u.salt = Digest::SHA1.hexdigest("wiffle-#{Time.now}")
    u.crypted_password = Digest::SHA1.hexdigest("--#{u.salt}--UJMJW0CKpad123386--")
    u.save
  end

  def self.down
    drop_table "users"
  end
end
