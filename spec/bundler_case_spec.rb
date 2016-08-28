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
    expect(c.gemfile).to eql "gemfile contents\n"
  end

  it 'given gems' do
    c = BundlerCase.define do
      given_gems do
        fake_gem 'foo', %w(1.0.0 1.0.1), [['bar', '~> 1.0']]
      end
    end
    expect(File.exist?(File.join(c.repo_dir, 'foo-1.0.0.gem'))).to be_true
    expect(File.exist?(File.join(c.repo_dir, 'foo-1.0.1.gem'))).to be_true
  end
end
