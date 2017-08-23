# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shotengai/version'

Gem::Specification.new do |spec|
  spec.name          = 'shotengai'
  spec.version       = Shotengai::VERSION
  spec.authors       = ['ivan Lan']
  spec.email         = ['mumumumushu@gmail.com']

  spec.summary       = %q{}
  spec.description   = %q{}
  spec.homepage      = 'https://git.tallty.com/open-source/shotengai'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://git.tallty.com/open-source/shotengai'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = 'git ls-files -z'.split('\x0').reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  
  spec.add_dependency 'aasm'
  spec.add_dependency 'acts-as-taggable-on'
  spec.add_dependency 'rails'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'factory_girl_rails'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency "rspec", "~> 3.0"
  # spec.add_development_dependency 'rspec-rails-swagger', git: 'git://github.com/tallty/rspec-rails-swagger'
  # spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'mysql2'
  
  
end
