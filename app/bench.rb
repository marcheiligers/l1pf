require 'lib/iota_array'

def tick args
  if args.tick_count == 1
    # GTK.console.show
    GTK.benchmark iterations: 100_000,
      iota_array: lambda {
        arr = iota(50)
        arr[20]
      },
      range: lambda {
        arr = (0...50).to_a
      }

    GTK.request_quit
  end

end
