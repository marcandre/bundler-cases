require_relative 'spec_helper'

describe BundlerCase do
  after do
    dir = BundlerCase.new.out_dir
    FileUtils.remove_entry_secure(dir) if File.exist?(dir)
  end

  it 'given gems' do
    c = BundlerCase.define do
      given_gems do
        fake_gem 'foo', %w(1.0.0 1.0.1), [['bar', '~> 1.0']]
      end
    end
    c.test
    gems_dir = File.join(c.repo_dir, 'gems')
    expect(File.exist?(File.join(gems_dir, 'foo-1.0.0.gem'))).to be_true
    expect(File.exist?(File.join(gems_dir, 'foo-1.0.1.gem'))).to be_true
  end

  it 'integration success' do
    c = BundlerCase.define do
      step do
        given_gems do
          fake_gem 'foo', '1.0.0', [['bar', '~> 1.0']]
          fake_gem 'bar', '1.0.1'
        end

        given_gemfile do
          <<-G
          source 'fake' do
            gem 'foo'
          end
          G
        end

        execute_bundler do
          'bundle install --path zz'
        end

        expect_locked do
          [%w(foo 1.0.0), %w(bar 1.0.1)]
        end
      end

      step do
        given_gems do
          fake_gem 'foo', '1.1.0'
        end

        execute_bundler do
          'bundle update'
        end

        expect_locked do
          [%w(foo 1.1.0)]
        end

        expect_not_locked do
          %w(bar)
        end
      end
    end
    result = c.test
    expect(result).to be_true
    expect(c.failures).to be_empty

    dest = File.join(c.out_dir, 'zz', 'ruby', '*', 'gems', 'foo-1.0.0')
    expect(File.exist?(Dir[dest].first)).to be_true
  end

  it 'integration failure' do
    c = BundlerCase.define do
      given_gems do
        fake_gem 'foo', '1.0.0', [['bar', '~> 1.0']]
        fake_gem 'bar', '1.0.1'
      end

      given_gemfile do
        <<-G
          source 'fake' do
            gem 'foo'
          end
        G
      end

      execute_bundler do
        'bundle install --path zz'
      end

      expect_locked do
        [%w(foo 1.0.0), %w(bar 1.1.0)]
      end
    end
    expect(c.test).to_not be_true
    expect(c.failures).to_not be_empty
    expect(c.failures.first).to eql 'Expected bar 1.1.0, found bar 1.0.1'

    dest = File.join(c.out_dir, 'zz', 'ruby', '*', 'gems', 'foo-1.0.0')
    expect(File.exist?(Dir[dest].first)).to be_true
  end

end

describe ExpectedSpecs do
  def spec(name, version)
    Gem::Specification.new(name, version)
  end

  it 'reports no errors by default' do
    expect(ExpectedSpecs.new.failures([], [])).to eql []
  end

  it 'reports errors for diff version' do
    failures = ExpectedSpecs.new.failures([spec('foo', '1.0.0')], [spec('foo', '1.0.1')])
    expect(failures).to eql ['Expected foo 1.0.0, found foo 1.0.1']
  end

  it 'reports errors for missing gem' do
    failures = ExpectedSpecs.new.failures([spec('foo', '1.0.0')], [])
    expect(failures).to eql ['Expected foo 1.0.0, gem not found']
  end
end
