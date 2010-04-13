class CompanyAndTelephoneForUsers < ActiveRecord::Migration
  def self.up
    add_column "users", "company", :string
    add_column "users", "telephone", :string
  end

  def self.down
    remove_column "users", "company"
    remove_column "users", "telephone"
  end
end
