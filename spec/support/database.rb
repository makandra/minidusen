Gemika::Database.new.rewrite_schema! do

  create_table :users do |t|
    t.string :name
    t.string :email
    t.string :city
  end

  create_table :recipes do |t|
    t.string :name
    t.integer :category_id
  end

  create_table :recipe_ingredients do |t|
    t.string :name
    t.integer :recipe_id
  end

  create_table :recipe_categories do |t|
    t.string :name
  end

end
