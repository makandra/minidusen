module Minidusen
  class Syntax

    def initialize
      @scopers = {}
    end

    def learn_field(field, &scoper)
      field = field.to_s
      @scopers[field] = scoper
    end

    def search(instance, root_scope, query)
      query = parse(query)
      query = query.condensed
      matches = apply_query(instance, root_scope, query.include)
      if query.exclude.any?
        matches = append_excludes(instance, matches, query.exclude)
      end
      matches
    end

    def fields
      @scopers
    end

    def parse(query)
      Parser.parse(query)
    end

    private

    NONE = lambda do |scope, *args|
      scope.where('1=2')
    end

    def apply_query(instance, root_scope, query)
      scope = root_scope
      query.each do |token|
        scoper = @scopers[token.field] || NONE
        scope = instance.instance_exec(scope, token.value, &scoper)
      end
      scope
    end

    def append_excludes(instance, matches, exclude_query)
      excluded_records = apply_query(instance, matches.origin_class, exclude_query)
      qualified_id_field = Util.qualify_column_name(excluded_records, excluded_records.primary_key)
      exclude_sql = "#{qualified_id_field} NOT IN (#{excluded_records.select(qualified_id_field).to_sql})"
      matches.where(exclude_sql)
    end

  end
end
