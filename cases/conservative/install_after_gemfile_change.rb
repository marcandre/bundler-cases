# This case recreates the documented conservative updating case in bundle install documentation.
# see: http://bundler.io/v1.12/man/bundle-install.1.html#CONSERVATIVE-UPDATING
BundlerCase.define do
  step 'Setup: Original Gemfile' do
    given_gemfile lock: ['activemerchant 1.5.1', 'builder 2.1.2'] do
      <<-G
      source 'https://rubygems.org' do
        gem 'actionpack', '2.3.8'
        gem 'activemerchant'
      end
      G
    end

    expect_locked { ['activemerchant 1.5.1', 'builder 2.1.2'] }
  end

  step "Change actionpack, `bundle install` won't work due to keeping activemerchant and its dependencies locked" do
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

  step '`bundle update actionpack` will work because it will not care about activemerchant dependencies being upgraded' do
    execute_bundler do
      'bundle update actionpack'
    end

    expect_locked do
      ['actionpack 3.0.0.rc', 'rack 1.2.8', 'activemerchant 1.5.1']
    end
  end
end
