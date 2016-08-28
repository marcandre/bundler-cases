class BundlerCase
  def self.define(&block)
    BundlerCase.new.tap { |c|
      c.instance_eval(&block)
    }
  end

  attr_reader :out_dir, :repo_dir, :failures

  def initialize
    recreate_out_dir
    @failures = []
    @expected_specs = []
    @cmd = 'bundle install --path .bundle'
  end

  def given_gems(&block)
    instance_eval(&block)
    Dir.chdir(@repo_dir) do
      system 'gem generate_index'
    end
  end

  def given_gemfile(&block)
    contents = block.call.outdent
    swap_in_fake_repo(contents)
    File.open(gem_filename, 'w') { |f| f.print contents }
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

  def execute_bundler(&block)
    @cmd = block.call
  end

  def expect_lockfile

  end

  def expect_locked(&block)
    @expected_specs.concat(block.call.map do |name, ver|
      Gem::Specification.new(name, ver)
    end)
  end

  def test
    Bundler.with_clean_env do
      ENV['BUNDLE_GEMFILE'] = gem_filename
      Dir.chdir(@out_dir) do
        system @cmd
      end
    end

    lockfile = File.join(@out_dir, 'Gemfile.lock')
    parser = Bundler::LockfileParser.new(Bundler.read_file(lockfile))
    @failures = ExpectedSpecs.new.failures(@expected_specs, parser.specs)
    @failures.empty?
  end

  private

  def recreate_out_dir
    @out_dir = File.expand_path('../out', __dir__)
    FileUtils.remove_entry_secure(@out_dir) if File.exist?(@out_dir)
    FileUtils.makedirs @out_dir
  end

  def fake_gem(name, versions, deps=[])
    make_repo_dir
    Array(versions).each do |ver|
      spec = Gem::Specification.new.tap do |s|
        s.name = name
        s.version = ver
        deps.each do |dep, *reqs|
          s.add_dependency dep, reqs
        end
      end

      Dir.chdir(@repo_gems_dir) do
        Bundler.rubygems.build(spec, skip_validation = true)
      end
    end
  end

  def make_repo_dir
    @repo_dir = File.join(out_dir, 'repo')
    FileUtils.makedirs @repo_dir

    @repo_gems_dir = File.join(@repo_dir, 'gems')
    FileUtils.makedirs @repo_gems_dir
  end

  def gem_filename
    File.join(@out_dir, 'Gemfile')
  end

  def swap_in_fake_repo(contents)
    make_repo_dir
    contents.gsub!(/source +['"]fake["']/, %Q(source "file://#{@repo_dir}"))
  end
end

class String
  def outdent
    indent = scan(/^[ \t]*(?=\S)/).min.size || 0
    gsub(/^[ \t]{#{indent}}/, '')
  end
end

class ExpectedSpecs
  def failures(expected, actual)
    res = []
    expected.each do |expect|
      found = actual.detect { |s| s.name == expect.name && s.version == expect.version }
      unless found
        found = actual.detect { |s| s.name == expect.name }
        if found
          res << "Expected #{expect.name} #{expect.version}, found #{found.name} #{found.version}"
        else
          res << "Expected #{expect.name} #{expect.version}, gem not found"
        end
      end
    end
    res
  end
end
