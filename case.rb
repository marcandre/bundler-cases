Given gems: # optional, and constructs fake gems in local source

  foo, 1.2.3, bar ~> 2.0
  bar, 2.0.0

Given Gemfile:

  source 'https://rubygems.org' do
    gem 'rack'
  end

Given Gemfile:

  source 'local' do
    gem 'foo'
  end

Given gemspec:

 ...
 

Given Gemfile.lock:

	GEM
	  remote: https://rubygems.org/
	  specs:
	    rack (1.4.1)

	PLATFORMS
	  ruby

	DEPENDENCIES
	  rack (= 1.4.1)!

	BUNDLED WITH
	   1.13.0.rc.2

Given locked:

  rack 1.4.1
  
Given bundler version:

  1.13.0.rc.2
  
When Gemfile:  
	   
  <<new gemfile>>
	   
When:

  bundle install --path

Expected Gemfile.lock:

  <<contents>>

Expected locked:

  rack 1.4.7
