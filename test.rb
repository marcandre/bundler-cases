#!/usr/bin/env ruby

require 'bundler/setup'

require_relative 'lib/bundler_case'

filter = ARGV[0]

def execute_case(fn)
  c = eval(File.read(fn))
  passed = c.test
  puts "#{File.basename(fn)}: #{passed ? 'passed' : 'FAILED'}"
  unless passed
    puts c.failures
  end
end

Dir[File.expand_path('cases/**/*.rb', __dir__)].each do |fn|
  next if fn !~ /#{filter}/ if filter
  execute_case(fn)
end

