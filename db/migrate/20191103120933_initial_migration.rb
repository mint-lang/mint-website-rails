class InitialMigration < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.json :data

      t.timestamps null: false
    end

    create_table :packages do |t|
      t.string :string
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
