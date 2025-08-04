module Minidusen
  module Filter
    module ClassMethods

      private

      attr_accessor :minidusen_syntax

      def filter(*fields, &block)
        fields.each do |field|
          minidusen_syntax.learn_field(field, &block)
        end
      end

    end

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:minidusen_syntax=, Syntax.new)
    end

    def filter(scope, query)
      minidusen_syntax.search(self, scope, query)
    end

    private

    def minidusen_syntax
      self.class.send(:minidusen_syntax)
    end

  end
end
