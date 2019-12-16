class InitialMigration < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :uid
      t.string :nickname
      t.string :image

      t.timestamps null: false
    end

    create_table :sandboxes, id: :string do |t|
      t.string :content
      t.string :title

      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end

    create_table :packages do |t|
      t.string :repository
      t.integer :stars
      t.datetime :pushed_at

      t.timestamps null: false
    end

    create_table :versions do |t|
      t.references :package, index: true, foreign_key: true

      t.string :version
      t.text :readme

      t.json :mint_json
      t.json :documentation

      t.timestamps null: false
    end
  end
end
