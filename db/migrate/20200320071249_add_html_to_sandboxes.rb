class AddHtmlToSandboxes < ActiveRecord::Migration[6.0]
  def change
  	add_column :sandboxes, :html, :string
  end
end
