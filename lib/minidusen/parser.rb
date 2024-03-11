module Minidusen
  class Parser

    class CannotParse < StandardError; end

    TEXT_QUERY = /(?:(\-)?"([^"]+)"|(\-)?([\S]+))/
    FIELD_QUERY = /(?:\s|^|(\-))(\w+):(?!:)#{TEXT_QUERY}/

    class << self

      def parse(object)
        case object
        when Query
          object
        when String
          parse_string(object)
        when Array
          parse_array(object)
        else
          raise CannotParse, "Cannot parse #{object.inspect}"
        end
      end

      private

      def parse_string(string)
        string = string.dup # we are going to delete substrings in-place
        string = string.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
        query = Query.new
        extract_field_query_tokens(string, query)
        extract_text_query_tokens(string, query)
        query
      end

      def parse_array(array)
        tokens = array.map { |string|
          string.is_a?(String) or raise CannotParse, "Cannot parse an array of #{string.class}"
          Token.new(:field => 'text', :value => string)
        }
        Query.new(tokens)
      end

      def extract_text_query_tokens(query_string, query)
        while query_string.sub!(TEXT_QUERY, '')
          value = "#{$2}#{$4}"
          exclude = "#{$1}#{$3}" == "-"
          options = { :field => 'text', :value => value, :exclude => exclude }
          query << Token.new(options)
        end
      end

      def extract_field_query_tokens(query_string, query)
        while query_string.sub!(FIELD_QUERY, '')
          field = $2
          value = "#{$4}#{$6}"
          exclude = "#{$1}" == "-"
          options = { :field => field, :value => value, :exclude => exclude }
          query << Token.new(options)
        end
      end

    end

  end
end
