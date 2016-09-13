require 'yaml'

database_config_file = ENV['TRAVIS'] ? 'database.travis.yml' : 'database.yml'
database_config_file = File.join(File.dirname(__FILE__), database_config_file)
File.exists?(database_config_file) or raise "Missing database configuration file: #{database_config_file}"

database_config = YAML.load_file(database_config_file)

connection_config = {}

case ENV['BUNDLE_GEMFILE']
when /pg/, /postgres/
  connection_config = database_config['postgresql'].merge(adapter: 'postgresql')
when /mysql2/
  connection_config = database_config['mysql'].merge(adapter: 'mysql2', encoding: 'utf8')
else
  raise "Unknown database type in Gemfile suffix: #{ENV['BUNDLE_GEMFILE']}"
end

ActiveRecord::Base.establish_connection(connection_config)


connection = ::ActiveRecord::Base.connection
connection.tables.each do |table|
  connection.drop_table table
end

ActiveRecord::Migration.class_eval do

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
