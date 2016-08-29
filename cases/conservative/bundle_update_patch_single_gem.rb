BundlerCase.define do
  step 'Setup: create versions of foo and starter bundle pinned to 1.4.3' do
    given_gems do
      fake_gem 'foo', %w(1.4.3 1.4.4 1.4.5 1.5.0 1.5.1 2.0.0)
    end

    given_bundler_version { '1.13.0.rc.2' }

    given_gemfile do
      <<-G
source 'fake' do
  gem 'foo', '1.4.3'
end
      G
    end

    expect_locked { [%w(foo 1.4.3)] }
  end

  step 'Setup: change Gemfile to not have a requirement' do
    given_gemfile do
      <<-G
source 'fake' do
  gem 'foo'
end
      G
    end

    expect_locked { [%w(foo 1.4.3)] }
  end

  step '`bundle update --patch` moves up to 1.4.5' do
    execute_bundler { 'bundle update --patch' }
    expect_locked { [%w(foo 1.4.5)] }
  end

  step '`bundle update --minor` moves up to 1.5.1' do
    execute_bundler { 'bundle update --minor' }
    expect_locked { [%w(foo 1.5.1)] }
  end

  step '`bundle update` moves up to 2.0.0' do
    execute_bundler { 'bundle update' }
    expect_locked { [%w(foo 2.0.0)] }
  end
end
