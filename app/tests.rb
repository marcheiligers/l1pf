# To run the test: `./dragonruby mygame --eval app/tests.rb --no-tick`
#   or use the `./test` shell script

require 'app/tests/vertex.rb'
require 'app/tests/iota_array.rb'
require 'app/tests/permutations.rb'
require 'app/tests/graph.rb'
require 'app/tests/nd_array.rb'
require 'app/tests/last.rb'

$gtk.reset rand(1_000_000)
# $gtk.log_level = :off
$gtk.tests.start
