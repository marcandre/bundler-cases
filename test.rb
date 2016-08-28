#!/usr/bin/env ruby

require_relative 'lib/bundler_case'

filter = ARGV[0]

Dir[File.expand_path('cases/**/*.rb', __dir__)].each do |fn|
  next if fn =~ /#{filter}/ if filter
  require fn
end
