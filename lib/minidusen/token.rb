module Minidusen
  class Token

    attr_reader :field, :value, :exclude, :phrase

    def initialize(options)
      @value = options.fetch(:value)
      @exclude = options.fetch(:exclude, false)
      @field = options.fetch(:field).to_s
      @phrase = options.fetch(:phrase, false)
    end

    def to_s
      value
    end

    def text?
      field == 'text'
    end

    def exclude?
      exclude
    end

    def phrase?
      phrase
    end

  end
end
