# frozen_string_literal: true

module Multivitamin
  module Vectors
    module_function

    def cosine(left, right)
      dot = left.zip(right).sum { |left_component, right_component| left_component * right_component }
      left_norm = Math.sqrt(left.sum { |component| component**2 })
      right_norm = Math.sqrt(right.sum { |component| component**2 })
      dot / (left_norm * right_norm)
    end
  end
end
