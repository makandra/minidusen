module Minidusen
  module Filter
    module ClassMethods

      private

      attr_accessor :minidusen_syntax

      def filter(field, &block)
        minidusen_syntax.learn_field(field, &block)
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
