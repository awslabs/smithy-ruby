# frozen_string_literal: true

require 'json'
require 'rspec'
require 'tmpdir'
require 'stringio'

require 'smithy'

require_relative 'support/be_in_documentation_matcher'

module SpecHelper
  class << self
    # @param [Array<String>] modules A list of modules for the generated code.
    #  For example, `['Company', 'Weather']` would generate code in the
    #  `Company::Weather` namespace.
    # @param [Symbol] type The type of service to generate. For example,
    #  :types`, `:client`, or `:server`.
    # @param [Hash] options Additional options to pass to the generator.
    # @option options [String] :fixture The name of the fixture to load.
    # @return [String] The path to the directory where the generated code was
    #  written to.
    def generate(modules, type, options = {})
      model = load_model(modules, options)
      plan = create_plan(modules, model, type, options)
      smith(plan)

      $LOAD_PATH << ("#{plan.options[:destination_root]}/lib")
      require "#{plan.options[:gem_name]}#{type == :types ? '-types' : ''}"
      setup_rbs_spytest(modules, plan.options[:destination_root])
      plan.options[:destination_root]
    end

    # @param [Array<String>] module_names A list of module names from the
    #  generated code to clean up.
    # @param [String] tmpdir The path to the tmp directory where the
    #  generated code was written to.
    def cleanup(module_names, tmpdir)
      if ENV['SMITHY_RUBY_KEEP_GENERATED_SOURCE']
        puts "Leaving generated service in: #{tmpdir}"
      else
        FileUtils.rm_rf(tmpdir)
      end
      $LOAD_PATH.delete("#{tmpdir}/lib")
      module_names.reverse.each_cons(2) do |child, parent|
        Object.const_get(parent).send(:remove_const, child)
      end
      Object.send(:remove_const, module_names.first)
    end

    def load_rbs_environment(sdk_dir, load_collection: true)
      require 'rbs'

      loader = RBS::EnvironmentLoader.new(core_root: RBS::EnvironmentLoader::DEFAULT_CORE_ROOT)
      loader.add(path: Pathname(File.join(__dir__, '../../smithy-client/sig')))
      loader.add(path: Pathname(File.join(sdk_dir, '/sig')))

      load_collection(loader) if load_collection

      RBS::Environment.from_loader(loader).resolve_type_names
    end

    private

    def with_captured_stdout
      original_stdout = $stdout
      $stdout = StringIO.new
      yield
    ensure
      $stdout = original_stdout
    end

    def load_model(modules, options)
      fixture = options[:fixture] || modules.map(&:underscore).join('/')
      model_dir = File.join(File.dirname(__FILE__), 'fixtures', fixture)
      JSON.load_file(File.join(model_dir, 'model.json'))
    end

    def create_plan(modules, model, type, options)
      plan_options = {
        gem_name: options.fetch(:gem_name, Smithy::Util::Namespace.gem_name_from_namespaces(modules)),
        gem_version: options.fetch(:gem_version, '1.0.0'),
        destination_root: options.fetch(:destination_root, Dir.mktmpdir)
      }
      Smithy::Plan.new(model, type, plan_options)
    end

    def smith(plan)
      if ENV['SMITHY_RUBY_DEBUG']
        Smithy.smith(plan)
      else
        with_captured_stdout { Smithy.smith(plan) }
      end
    end

    def load_collection(loader)
      collection_config_path = RBS::Collection::Config.find_config_path
      lock_path = RBS::Collection::Config.to_lockfile_path(collection_config_path)
      if lock_path.file?
        lock = RBS::Collection::Config::Lockfile.from_lockfile(lockfile_path: lock_path,
                                                               data: YAML.load_file(lock_path.to_s))
      end
      raise 'Missing RBS collection, ensure you have `rbs collection install`' unless lock

      loader.add_collection(lock)
    end

    def to_absolute_typename(type_name)
      RBS::Factory.new.type_name(type_name).absolute!
    end

    def classes_to_spy(mod, env, visited=Set.new)
      classes = []
      visited << mod
      mod.constants.each do |c|
        sub_mod = mod.const_get(c)
        next if !sub_mod.is_a?(Module) || visited.include?(sub_mod) || sub_mod == ::BasicObject # module includes classes

        rbs_name = to_absolute_typename(sub_mod.name)
        if env.module_name?(rbs_name)
          puts "Adding #{rbs_name}, def: #{env.type_name?(rbs_name)}"
          classes << sub_mod
          classes += classes_to_spy(sub_mod, env, visited)
        end
      end
      classes
    end

    def setup_rbs_spytest(modules, sdk_dir)
      require 'rbs/test'
      env = load_rbs_environment(sdk_dir)
      tester = RBS::Test::Tester.new(env: env)

      unchecked_classes = [
        '::RSpec::Mocks::Double',
        '::RSpec::Mocks::InstanceVerifyingDouble',
        '::RSpec::Mocks::ObjectVerifyingDouble',
        '::RSpec::Mocks::ClassVerifyingDouble',
      ] # rubocop:disable

      spy_modules = [modules.join('::'), 'Smithy::Client']
      spy_classes = []
      spy_modules.each do |module_name|
        spy_classes += classes_to_spy(Object.const_get(module_name), env)
      end

      spy_classes.each do |spy_class|
        puts "Installing for: #{spy_class}"
        tester.install!(spy_class, sample_size: RBS::Test::SetupHelper::DEFAULT_SAMPLE_SIZE, unchecked_classes: unchecked_classes)
      end
    end
  end
end

# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# See https://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # The settings below are suggested to provide a good initial experience
  # with RSpec, but feel free to customize to your heart's content.
  #   # This allows you to limit a spec run to individual examples or groups
  #   # you care about by tagging them with `:focus` metadata. When nothing
  #   # is tagged with `:focus`, all examples get run. RSpec also provides
  #   # aliases for `it`, `describe`, and `context` that include `:focus`
  #   # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  #   config.filter_run_when_matching :focus
  #
  #   # Allows RSpec to persist some state between runs in order to support
  #   # the `--only-failures` and `--next-failure` CLI options. We recommend
  #   # you configure your source control system to ignore this file.
  #   config.example_status_persistence_file_path = "spec/examples.txt"
  #
  #   # Limits the available syntax to the non-monkey patched syntax that is
  #   # recommended. For more details, see:
  #   # https://rspec.info/features/3-12/rspec-core/configuration/zero-monkey-patching-mode/
  #   config.disable_monkey_patching!
  #
  #   # This setting enables warnings. It's recommended, but in some cases may
  #   # be too noisy due to issues in dependencies.
  #   config.warnings = true
  #
  #   # Many RSpec users commonly either run the entire suite or an individual
  #   # file, and it's useful to allow more verbose output when running an
  #   # individual spec file.
  #   if config.files_to_run.one?
  #     # Use the documentation formatter for detailed output,
  #     # unless a formatter has already been configured
  #     # (e.g. via a command-line flag).
  #     config.default_formatter = "doc"
  #   end
  #
  #   # Print the 10 slowest examples and example groups at the
  #   # end of the spec run, to help surface which specs are running
  #   # particularly slow.
  #   config.profile_examples = 10
  #
  #   # Run specs in random order to surface order dependencies. If you find an
  #   # order dependency and want to debug it, you can fix the order by providing
  #   # the seed, which is printed after each run.
  #   #     --seed 1234
  #   config.order = :random
  #
  #   # Seed global randomization in this process using the `--seed` CLI option.
  #   # Setting this allows you to use `--seed` to deterministically reproduce
  #   # test failures related to randomization by passing the same `--seed` value
  #   # as the one that triggered the failure.
  #   Kernel.srand config.seed
end
