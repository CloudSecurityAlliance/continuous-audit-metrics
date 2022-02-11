require 'yaml'
require 'json'


if ARGV.length!=1
  puts "Missing YAML file"
  exit false
end

metrics = YAML.load_file ARGV[0]

puts JSON.pretty_generate(metrics)
