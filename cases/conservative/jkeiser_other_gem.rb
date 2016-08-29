BundlerCase.define do
  step 'Setup to establish lockfile' do
    given_gems do
      fake_gem 'foo', %w(5.0.2 5.0.3), [['bar', '>= 4.0']]
      fake_gem 'qux', '2.1.0', [['bar', '>= 4.0']]
      fake_gem 'bar', %w(4.0.1 4.0.2)
    end

    given_gemfile do
      <<-G
source 'fake' do
  gem 'foo', '5.0.2'
  gem 'qux'
  gem 'bar', '4.0.1'
end
      G
    end

    expect_locked { ['foo 5.0.2', 'bar 4.0.1', 'qux 2.1.0'] }
  end

  step do
    given_gemfile do
      <<-G
source 'fake' do
  gem 'foo', '5.0.2'
  gem 'qux'
end
      G
    end

    expect_locked { ['foo 5.0.2', 'bar 4.0.1', 'qux 2.1.0'] }
  end

  step do
    given_gemfile do
      <<-G
source 'fake' do
  gem 'foo', '5.0.3'
  gem 'qux'
end
      G
    end

    expect_locked { ['foo 5.0.3', 'bar 4.0.1', 'qux 2.1.0'] }
  end
end
