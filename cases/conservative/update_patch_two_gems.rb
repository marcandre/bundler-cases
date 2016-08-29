BundlerCase.define do
  step 'Setup Gemfile' do
    given_gems do
      fake_gem 'foo', '1.4.3', [['bar', '~> 2.0']]
      fake_gem 'foo', '1.4.4', [['bar', '~> 2.0']]
      fake_gem 'foo', '1.4.5', [['bar', '~> 2.1']]
      fake_gem 'foo', '1.5.0', [['bar', '~> 2.1']]
      fake_gem 'foo', '1.5.1', [['bar', '~> 3.0']]
      fake_gem 'bar', %w(2.0.3 2.0.4 2.1.0 2.1.1 3.0.0)
    end

    given_bundler_version { '1.13.0.rc.2' }

    given_gemfile lock: ['foo 1.4.3', 'bar 2.0.3'] do
      <<-G
source 'fake' do
  gem 'foo'
end
      G
    end

    expect_locked { ['foo 1.4.3', 'bar 2.0.3'] }
  end

  step do
    execute_bundler { 'bundle update --patch --strict foo' }
    expect_locked { ['foo 1.4.4', 'bar 2.0.3'] }
  end

  step do
    execute_bundler { 'bundle update --patch --strict' }
    expect_locked { ['foo 1.4.4', 'bar 2.0.4'] }
  end

  step do
    execute_bundler { 'bundle update --patch' }
    expect_locked { ['foo 1.4.5', 'bar 2.1.1'] }
  end

  step do
    execute_bundler { 'bundle update --minor --strict' }
    expect_locked { ['foo 1.5.0', 'bar 2.1.1'] }
  end

  step do
    execute_bundler { 'bundle update --minor' }
    expect_locked { ['foo 1.5.1', 'bar 3.0.0'] }
  end
end
