module Minidusen
  class Syntax

    def initialize
      @scopers = {}
      @alias_count = 0
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
      primary_key = excluded_records.primary_key
      join_alias = "exclude_#{@alias_count += 1}"
      # due to performance reasons on big tables this needs to be implemented as an anti-join
      # will generate SQL like
      # LEFT JOIN (SELECT "users"."id" FROM "users" WHERE $condition) excluded
      # ON "users"."id" = "excluded"."id"
      # WHERE "excluded"."id" IS NULL
      matches
        .joins(<<~SQL)
          LEFT JOIN (#{excluded_records.select(primary_key).to_sql}) #{join_alias}
          ON #{Util.qualify_column_name(excluded_records, primary_key)} = #{Util.qualify_column_name(excluded_records, primary_key, table_name: join_alias)}
        SQL
        .where(join_alias => { primary_key => nil })
    end

  end
end
