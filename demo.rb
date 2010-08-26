p RUBY_DESCRIPTION
s = ARGV.shift

case s
when "1"
  p system("ruby kaboom.rb -b 1000 --speed 5 --rvalue-height 2 -v")
when "2"
  p system("ruby kaboom.rb -b 30000 -o 25 --speed 10")
when "3"
  p system("ruby kaboom.rb -b 750000 --speed 10")
end
