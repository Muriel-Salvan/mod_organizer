require "#{__dir__}/lib/mod_organizer/version"

Gem::Specification.new do |spec|
  spec.name = 'mod_organizer'
  spec.version = ModOrganizer::VERSION
  spec.authors = ['Muriel Salvan']
  spec.email = ['muriel@x-aeon.com']
  spec.license = 'BSD-3-Clause'
  spec.required_ruby_version = '>= 3.1'

  spec.summary = 'Ruby API accessing a Mod Organizer instance'
  spec.homepage = 'https://github.com/Muriel-Salvan/mod_organizer'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['*.md'] + Dir['{bin,docs,examples,lib,spec,tools}/**/*']
  spec.executables = Dir['bin/**/*'].map { |exec_name| File.basename(exec_name) }
  spec.extra_rdoc_files = Dir['*.md'] + Dir['{docs,examples}/**/*']

  spec.add_dependency 'inifile', '~> 3.0'
  spec.add_dependency 'memoist3', '~> 1.0'

  # Test framework
  spec.add_development_dependency 'rspec', '~> 3.12'
  # Automatic semantic releasing
  spec.add_development_dependency 'sem_ver_components', '~> 0.3'
  # Lint checker
  spec.add_development_dependency 'rubocop', '~> 1.42'
  # Lint checker for rspec
  spec.add_development_dependency 'rubocop-rspec', '~> 2.16'
end
