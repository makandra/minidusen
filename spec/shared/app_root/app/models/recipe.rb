class Recipe < ActiveRecord::Base

  validates_presence_of :name

  has_many :ingredients, :class_name => 'Recipe::Ingredient', :inverse_of => :recipe
  belongs_to :category, :class_name => 'Recipe::Category', :inverse_of => :recipes


  search_syntax do

    search_by :text do |scope, text|
      scope.where_like(:name => text)
    end

    search_by :category do |scope, category_name|
      scope.joins(:category).where('recipe_categories.name = ?', category_name)
    end

  end

end
