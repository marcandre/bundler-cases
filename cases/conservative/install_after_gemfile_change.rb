# This case recreates the documented conservative updating case in bundle install
# documentation.
# see: http://bundler.io/v1.12/man/bundle-install.1.html#CONSERVATIVE-UPDATING
#
# The example at the time doesn't pin activemerchant to 1.5.1...TODO
BundlerCase.define do
  given_gemfile do
    <<-G
    source 'https://rubygems.org' do
      gem 'actionpack', '2.3.8'
      gem 'activemerchant', '1.5.1'
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
