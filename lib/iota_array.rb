module ArrayUtils
  def self.iota(n)
    Array.new(n) { |i| i }
  end
end
