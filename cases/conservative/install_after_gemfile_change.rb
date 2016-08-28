# This case recreates the documented conservative updating case in bundle install
# documentation.
# see: http://bundler.io/v1.12/man/bundle-install.1.html#CONSERVATIVE-UPDATING
BundlerCase.define do
  # This must be run first to install the gems and pin activemerchant
  # to 1.5.1, and builder to 2.1.2, which appear to be the most current
  # gems at the time the docs were written.
  step do
    given_gemfile do
      <<-G
      source 'https://rubygems.org' do
        gem 'actionpack', '2.3.8'
        gem 'activemerchant', '1.5.1'
        gem 'builder', '2.1.2'
      end
      G
    end

    expect_locked do
      [%w(actionpack 2.3.8),
       %w(activemerchant 1.5.1),
       %w(rack 1.1.6),
       %w(activesupport 2.3.8)]
    end
  end

  # Re-run with this Gemfile to match the original Gemfile in the docs
  step do
    given_gemfile do
      <<-G
      source 'https://rubygems.org' do
        gem 'actionpack', '2.3.8'
        gem 'activemerchant'
      end
      G
    end

    expect_locked do
      [%w(activemerchant 1.5.1), %w(builder 2.1.2)]
    end
  end

  step do
    given_gemfile do
      <<-G
      source 'https://rubygems.org' do
        gem 'actionpack', '3.0.0.rc'
        gem 'activemerchant'
      end
      G
    end

     # expect_conflict - TODO

    execute_bundler do
      'bundle install'
    end
  end

  step do
    execute_bundler do
      'bundle update actionpack'
    end

    expect_locked do
      [%w(actionpack 3.0.0.rc), %w(rack 1.2.8), %w(activemerchant 1.5.1)]
    end
  end
end
