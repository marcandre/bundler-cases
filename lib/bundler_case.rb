class BundlerCase
  extend Forwardable

  def self.define(&block)
    c = BundlerCase.new
    c.instance_eval(&block)
    c
  end

  attr_reader :out_dir, :repo_dir, :failures

  def initialize
    recreate_out_dir
    make_repo_dir

    # prolly should only support top-level step for non-step default
    # behavior OR nested ... but ... we'll see how this plays out
    @nested = []
    @step = Step.new(self)
  end

  def step(description=nil, &block)
    @nested << Step.new(self, description).tap { |c| c.instance_eval(&block) }
  end

  def test
    @failures = []
    steps = @nested.empty? ? Array(@step) : @nested
    steps.each do |s|
      if s.description
        puts '#' * s.description.length
        puts s.description
        puts '#' * s.description.length
      end
      @failures = s.test
      break unless @failures.empty?
      puts
    end
    @failures.empty?
  end

  def gem_filename
    File.join(@out_dir, 'Gemfile')
  end

  private

  def recreate_out_dir
    @out_dir = File.expand_path('../out', __dir__)
    FileUtils.remove_entry_secure(@out_dir) if File.exist?(@out_dir)
    FileUtils.makedirs @out_dir
  end

  def make_repo_dir
    @repo_dir = File.join(out_dir, 'repo')
    FileUtils.makedirs @repo_dir

    gems_dir = File.join(@repo_dir, 'gems')
    FileUtils.makedirs gems_dir
  end

  class Step
    attr_reader :description

    def initialize(bundler_case, description=nil)
      @bundler_case = bundler_case
      @description = description
      @failures = []
      @expected_specs = []
      @expected_not_specs = []
      @cmd = -> { cmd = 'bundle install --path .bundle'; puts "=> #{cmd}"; system cmd }
      @procs = []
    end

    def given_gems(&block)
      @procs << -> {
        instance_eval(&block)
        Dir.chdir(@bundler_case.repo_dir) do
          system 'gem generate_index'
        end
      }
    end

    def given_gemfile(&block)
      contents = block.call.outdent
      swap_in_fake_repo(contents)
      @procs << -> { File.open(@bundler_case.gem_filename, 'w') { |f| f.print contents } }
    end

    def given_gemspec

    end

    def given_lockfile

    end

    def given_locked

    end

    def given_bundler_version

    end

    def execute_bundler(&block)
      cmd = block.call
      @cmd = -> { puts "=> #{cmd}"; system cmd }
    end

    def expect_lockfile

    end

    def expect_locked(&block)
      @expected_specs.concat(block.call.map do |name, ver|
        Gem::Specification.new(name, ver)
      end)
    end

    def expect_not_locked(&block)
      @expected_not_specs.concat(block.call.map do |name, ver|
        Gem::Specification.new(name, ver)
      end)
    end

    def test
      Bundler.with_clean_env do
        ENV['BUNDLE_GEMFILE'] = @bundler_case.gem_filename
        Dir.chdir(@bundler_case.out_dir) do
          @procs.map(&:call)
          @cmd.call
        end
      end

      if @expected_specs.empty?
        []
      else
        lockfile = File.join(@bundler_case.out_dir, 'Gemfile.lock')
        parser = Bundler::LockfileParser.new(Bundler.read_file(lockfile))
        ExpectedSpecs.new.failures(@expected_specs, parser.specs)
      end
    end

    private

    def fake_gem(name, versions, deps=[])
      Array(versions).each do |ver|
        spec = Gem::Specification.new.tap do |s|
          s.name = name
          s.version = ver
          deps.each do |dep, *reqs|
            s.add_dependency dep, reqs
          end
        end

        gems_dir = File.join(@bundler_case.repo_dir, 'gems')
        Dir.chdir(gems_dir) do
          Bundler.rubygems.build(spec, skip_validation = true)
        end
      end
    end

    def swap_in_fake_repo(contents)
      contents.gsub!(/source +['"]fake["']/, %Q(source "file://#{@bundler_case.repo_dir}"))
    end
  end

  def_delegators :@step, *(Step.public_instance_methods(include_super = false) - [:test])
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
