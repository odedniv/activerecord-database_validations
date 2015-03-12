require 'active_record'

ActiveRecord::Schema.define do
  create_table "dummies", force: :cascade do |t|
    t.integer "not_null_integer",         null:  false, limit: 4
    t.string  "not_null_string",          null:  false, limit: 255

    t.integer "unique_single_integer",    limit: 4
    t.string  "unique_single_string",     limit: 255
    t.integer "unique_multiple_integer1", limit: 4
    t.integer "unique_multiple_integer2", limit: 4
    t.string  "unique_multiple_string1",  limit: 255
    t.string  "unique_multiple_string2",  limit: 255

    t.integer "foreign_key",              limit: 4

    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "dummies", ["unique_single_integer"], name: "index_dummies_on_unique_single_integer", unique: true, using: :btree
  add_index "dummies", ["unique_single_string"], name: "index_dummies_on_unique_single_string", unique: true, using: :btree
  add_index "dummies", ["unique_multiple_integer1", "unique_multiple_integer2"], name: "index_dummies_on_unique_multiple_integer", unique: true, using: :btree
  add_index "dummies", ["unique_multiple_string1", "unique_multiple_string2"], name: "index_dummies_on_unique_multiple_string", unique: true, using: :btree

  add_foreign_key "dummies", "dummies", column: "foreign_key"
end
