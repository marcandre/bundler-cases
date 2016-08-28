require_relative 'spec_helper'

describe BundlerCase do
  after do
    dir = BundlerCase.new.out_dir
    FileUtils.remove_entry_secure(dir) if File.exist?(dir)
  end

  it 'given gemfile' do
    c = BundlerCase.define do
      given_gemfile do
        <<-G
          gemfile contents
        G
      end
    end
    expect(File.read(File.join(c.out_dir, 'Gemfile'))).to eql "gemfile contents\n"
  end

  it 'given gemfile with local source points to local repo' do
    c = BundlerCase.define do
      given_gemfile do
        <<-G
          source 'local'
        G
      end
    end
    expect(File.read(File.join(c.out_dir, 'Gemfile'))).to eql "source \"file://#{c.repo_dir}\"\n"
  end

  it 'given gems' do
    c = BundlerCase.define do
      given_gems do
        fake_gem 'foo', %w(1.0.0 1.0.1), [['bar', '~> 1.0']]
      end
    end
    gems_dir = File.join(c.repo_dir, 'gems')
    expect(File.exist?(File.join(gems_dir, 'foo-1.0.0.gem'))).to be_true
    expect(File.exist?(File.join(gems_dir, 'foo-1.0.1.gem'))).to be_true
  end

  it 'integration' do
    c = BundlerCase.define do
      given_gems do
        fake_gem 'foo', '1.0.0', [['bar', '~> 1.0']]
        fake_gem 'bar', '1.0.1'
      end

      given_gemfile do
        <<-G
          source 'local' do
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
    expect(c.test).to be_true
    expect(c.failures).to be_empty

    dest = File.join(c.out_dir, 'zz', 'ruby', '*', 'gems', 'foo-1.0.0')
    expect(File.exist?(Dir[dest].first)).to be_true
  end
end
