# frozen_string_literal: true

# Utility to setup RBS spy test on generated code.
module RbsSpyTest
  class << self
    def setup(modules, sdk_dir)
      require 'rbs/test'
      env = load_rbs_environment(sdk_dir)
      tester = RBS::Test::Tester.new(env: env)

      unchecked_classes = [
        '::RSpec::Mocks::Double',
        '::RSpec::Mocks::InstanceVerifyingDouble',
        '::RSpec::Mocks::ObjectVerifyingDouble',
        '::RSpec::Mocks::ClassVerifyingDouble'
      ] # rubocop:disable

      spy_modules = [modules.join('::'), 'Smithy::Client']
      spy_classes = []
      spy_modules.each do |module_name|
        spy_classes += classes_to_spy(Object.const_get(module_name), env)
      end

      spy_classes.each do |spy_class|
        tester.install!(
          spy_class,
          sample_size: RBS::Test::SetupHelper::DEFAULT_SAMPLE_SIZE,
          unchecked_classes: unchecked_classes
        )
      end
    end

    private

    def load_rbs_environment(sdk_dir, load_collection: true)
      require 'rbs'

      loader = RBS::EnvironmentLoader.new(core_root: RBS::EnvironmentLoader::DEFAULT_CORE_ROOT)
      loader.add(path: Pathname(File.join(__dir__.to_s, '../../../smithy-client/sig')))
      loader.add(path: Pathname(File.join(sdk_dir, '/sig')))

      load_collection(loader) if load_collection

      RBS::Environment.from_loader(loader).resolve_type_names
    end

    def load_collection(loader)
      collection_config_path = RBS::Collection::Config.find_config_path
      lock_path = RBS::Collection::Config.to_lockfile_path(collection_config_path)
      if lock_path.file?
        lock = RBS::Collection::Config::Lockfile.from_lockfile(
          lockfile_path: lock_path,
          data: YAML.load_file(lock_path.to_s)
        )
      end
      raise 'Missing RBS collection, ensure you have `rbs collection install`' unless lock

      loader.add_collection(lock)
    end

    def to_absolute_typename(type_name)
      RBS::Factory.new.type_name(type_name).absolute!
    end

    def classes_to_spy(mod, env, visited = Set.new)
      classes = []
      visited << mod
      mod.constants.each do |c|
        sub_mod = mod.const_get(c)
        # module includes classes
        next if !sub_mod.is_a?(Module) || visited.include?(sub_mod) || sub_mod == ::BasicObject

        rbs_name = to_absolute_typename(sub_mod.name)
        if env.module_name?(rbs_name)
          classes << sub_mod
          classes += classes_to_spy(sub_mod, env, visited)
        end
      end
      classes
    end
  end
end