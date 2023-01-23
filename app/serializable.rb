module Serializable
  SERIALIZABLE_IGNORE = %i[@args @data].freeze
  SERIALIZABLE_SHALLOW_TYPES = [Numeric, String, Symbol, TrueClass, FalseClass].freeze

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def serializable_ignore(vars)
      @serializable_ignore = vars
    end

    def serializable_ignored
      @serializable_ignore
    end
  end


  def serialize
    serialized = {}
    ignore = self.class.serializable_ignored || SERIALIZABLE_IGNORE

    instance_variables.map do |var|
      if ignore.include?(var)
        nil
      else
        val = instance_variable_get(var)
        if serialized.include?(val.object_id)
          [var, '...']
        else
          serialized[val.object_id] = true unless SERIALIZABLE_SHALLOW_TYPES.detect { |t| val.is_a?(t) }
          [var, val]
        end
      end
    end.compact.to_h
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end
