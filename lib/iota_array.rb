# TODO: namespace pollution - wrap in a module (e.g., ArrayUtils.iota) or just use (0...n).to_a
def iota(n)
  Array.new(n) { |i| i }
end
