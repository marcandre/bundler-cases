# This case recreates the documented conservative updating case in bundle install
# documentation.
# see: http://bundler.io/v1.12/man/bundle-install.1.html#CONSERVATIVE-UPDATING
BundlerCase.define do
  given_gemfile do
    <<-G
    source 'https://rubygems.org' do
      gem 'actionpack', '2.3.8'
      gem 'activemerchant', '1.5.1'
    end
    G
  end
end.test
