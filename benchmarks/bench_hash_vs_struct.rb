MyStruct = Struct.new(:a, :b, :c, :d, :e)

class MyClass
  attr_reader :a, :b, :c, :d, :e
  def initialize(a, b, c, d, e)
    @a = a; @b = b; @c = c; @d = d; @e = e
  end
end

def tick(args)
  if args.tick_count == 1
    GTK.benchmark iterations: 100_000,
      hash_create: -> {
        h = { a: 1, b: 2, c: 3, d: 4, e: 5 }
        h.a + h.b + h.c + h.d + h.e
      },
      struct_create: -> {
        s = MyStruct.new(1, 2, 3, 4, 5)
        s.a + s.b + s.c + s.d + s.e
      },
      class_create: -> {
        c = MyClass.new(1, 2, 3, 4, 5)
        c.a + c.b + c.c + c.d + c.e
      }
    GTK.request_quit
  end
end
