class AddMintVersionToSandboxes < ActiveRecord::Migration[6.0]
  def change
    add_column :sandboxes, :mint_version, :string, default: '0.16.1'
  end
end
