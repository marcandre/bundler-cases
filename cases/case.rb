BundlerCase.define do
  given_gems do
    fake_gem 'foo', versions: '1.2.3', deps: [['bar', '~> 2.0'], ['quux', '~> 2.0.1']]
    fake_gem 'bar', versions: '2.0.0'
    fake_gem 'qux', versions: %w(2.0.0 2.0.1 2.0.2)
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

  given_lockfile do
    <<-L
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
    L

    given_locked do
      gem 'rack', '1.4.1'
    end

    given_bundler_version do
      '1.13.0.rc.2'
    end

    given_new_gemfile do
      <<-G
        <<new gemfile>>
      G
    end

    execute_bundler do
      'bundle install --path'
    end

    expect_lockfile do
      '<<contents>>'
    end

    expect_locked do
      gem 'rack', '1.4.7'
    end
  end
end
