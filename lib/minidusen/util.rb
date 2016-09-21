module Minidusen
  module Util
    extend self

    def postgresql?(scope)
      adapter_name = scope.connection.class.name
      adapter_name =~ /postgres/i
    end

    def like_expression(phrase)
      "%#{escape_for_like_query(phrase)}%"
    end

    def ilike_operator(scope)
      if postgresql?(scope)
        'ILIKE'
      else
        'LIKE'
      end
    end

    def regexp_operator(scope)
      if postgresql?(scope)
        '~'
      else
        'REGEXP'
      end
    end

    def escape_with_backslash(phrase, characters)
      characters << '\\'
      pattern = /[#{characters.collect(&Regexp.method(:quote)).join('')}]/
      # debugger
      phrase.gsub(pattern) do |match|
        "\\#{match}"
      end
    end

    def escape_for_like_query(phrase)
      # phrase.gsub("%", "\\%").gsub("_", "\\_")
      escape_with_backslash(phrase, ['%', '_'])
    end

    def qualify_column_name(model, column_name)
      column_name = column_name.to_s
      unless column_name.include?('.')
        quoted_table_name = model.connection.quote_table_name(model.table_name)
        quoted_column_name = model.connection.quote_column_name(column_name)
        column_name = "#{quoted_table_name}.#{quoted_column_name}"
      end
      column_name
    end

  end
end
