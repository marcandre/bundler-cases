class BundlerCase
  def self.define(&block)
    BundlerCase.new.tap { |c|
      c.instance_eval(&block)
    }
  end

  attr_reader :out_dir, :repo_dir

  def initialize
    @out_dir = File.expand_path('../out', __dir__)
    FileUtils.makedirs @out_dir
  end

  def given_gems(&block)
    instance_eval(&block)
  end

  def given_gemfile(&block)
    contents = block.call.outdent
    File.open(File.join(@out_dir, 'Gemfile'), 'w') { |f| f.print contents }
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

  private

  def fake_gem(name, versions, deps)
    @repo_dir = File.join(out_dir, 'repo')
    FileUtils.makedirs @repo_dir
    Array(versions).each do |ver|
      spec = Gem::Specification.new.tap do |s|
        s.name = name
        s.version = ver
        deps.each do |dep, *reqs|
          s.add_dependency dep, reqs
        end
      end

      Dir.chdir(@repo_dir) do
        Bundler.rubygems.build(spec, skip_validation = true)
      end
    end
  end
end

class String
  def outdent
    indent = scan(/^[ \t]*(?=\S)/).min.size || 0
    gsub(/^[ \t]{#{indent}}/, '')
  end
end
