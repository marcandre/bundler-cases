BundlerCase.define do
  setup = step 'Setup Gemfile' do
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

  # why doesn't `--patch --strict foo` push this to 2.0.4? it pushes foo to 1.4.4.
  # theory: because bar starts as locked, and the foo requirement DOESN'T CHANGE so bar stays locked.
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

  repeat_step setup

  # bar moves in this case, even though it starts locked, because it's unlocked when foo's REQUIREMENT for bar changes,
  # AND nothing else keeps it put, because it's not a declared dependency.
  # TODO: double check this ^^
  step do
    execute_bundler { 'bundle update --patch foo' }
    # expect_locked { ['foo 1.4.4', 'bar 2.0.3'] } <= what i thought based on non-dependent case (rack, addressable)
    expect_locked { ['foo 1.4.5', 'bar 2.1.1'] }
  end
end
