module Minidusen
  module ActiveRecordExtensions
    module ClassMethods

      def where_like(conditions, options = {})
        scope = scoped

        ilike_operator = Util.ilike_operator(scope)

        if options[:negate]
          match_operator = "NOT #{ilike_operator}"
          join_operator = 'AND'
        else
          match_operator = ilike_operator
          join_operator = 'OR'
        end

        conditions.each do |field_or_fields, query|
          fields = Array(field_or_fields).collect do |field|
            Util.qualify_column_name(scope, field)
          end
          Array.wrap(query).each do |phrase|
            phrase_with_placeholders = fields.collect { |field|
              "#{field} #{match_operator} ?"
            }.join(" #{join_operator} ")
            like_expression = Minidusen::Util.like_expression(phrase)
            bindings = [like_expression] * fields.size
            conditions = [ phrase_with_placeholders, *bindings ]
            scope = scope.where(conditions)
          end
        end
        scope
      end

    end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:extend, Minidusen::ActiveRecordExtensions::ClassMethods)
end
