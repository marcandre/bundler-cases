case do
	given_gems do
	  # specs, right?
	  gem 'foo', '1.2.3', ['bar', '~> 2.0'], ['quux', '~> 2.0.1']
	  gem 'bar', '2.0.0'
	  gem 'qux', '2.0.0', '2.0.1', '2.0.2'
	end

	given_gemfile do
	  <<-G
	    source 'https://rubygems.org' do
	      gem 'rack'
	    end
	  G
	end

	given_gemfile do
	  <<-G
	    source 'local' do
	      gem 'foo'
	    end
	  G
	end

	given_gemspec do
	end
 

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
end	
