# Lockfile points at:
#
# foo 5.0.2 depends on bar >= 4.0
# bar 4.0.1
# Gemfile updates to point at foo 5.0.3, which depends on bar >= 4.0.1.
#
# Afterwards, I expect foo to update to 5.0.3 and bar to stay the same, even if bar 4.0.2 exists.
#
# https://github.com/bundler/bundler-features/issues/122#issuecomment-242278637

BundlerCase.define do
  step 'Setup to establish lockfile' do
    given_gems do
      fake_gem 'foo', %w(5.0.2 5.0.3), [['bar', '>= 4.0']]
      fake_gem 'bar', %w(4.0.1 4.0.2)
    end

    given_gemfile do
      <<-G
source 'fake' do
  gem 'foo', '5.0.2'
  gem 'bar', '4.0.1'
end
      G
    end

    expect_locked { ['foo 5.0.2', 'bar 4.0.1'] }
  end

  step do
    given_gemfile do
      <<-G
source 'fake' do
  gem 'foo', '5.0.2'
end
      G
    end

    expect_locked { ['foo 5.0.2', 'bar 4.0.1'] }
  end

  step do
    given_gemfile do
      <<-G
source 'fake' do
  gem 'foo', '5.0.3'
  # gem 'bar' - declaring this as a dependency will get jkeiser what he wants.
  #             if there was another gem that also depended on bar, then this
  #             would also keep bar steady.
end
      G
    end

    expect_locked { ['foo 5.0.3', 'bar 4.0.1'] }
  end
end
