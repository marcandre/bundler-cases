class BundlerCase
  def self.define
    _case = BundlerCase.new
    _case.instance_eval(&block)
  end

  def given_gems

  end

  def given_gemfile

  end

  def given_gemspec

  end

  def given_lockfile

  end

  def given_locked

  end

  def given_new_gemfile

  end

  def given_bundler_version

  end

  def execute_bundler

  end

  def expect_lockfile

  end

  def expect_locked

  end
end
