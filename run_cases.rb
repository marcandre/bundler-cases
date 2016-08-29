#!/usr/bin/env ruby

require 'bundler/setup'

require_relative 'lib/bundler_case'

filter = ARGV[0]

def puts_title(title)
  width = [title.length, 80].max
  puts '=' * width
  puts title.center(width)
  puts '=' * width
end

def execute_case(fn)
  c = eval(File.read(fn))
  title = File.basename(fn, '.rb').gsub(/_/, ' ').split(/ /).map(&:capitalize).join(' ')
  puts_title(title)
  passed = c.test
  puts "#{title}: #{passed ? 'Passed' : 'FAILED'}"
  unless passed
    puts c.failures
  end
end

Dir[File.expand_path('cases/**/*.rb', __dir__)].each do |fn|
  next if fn !~ /#{filter}/ if filter
  execute_case(fn)
end

