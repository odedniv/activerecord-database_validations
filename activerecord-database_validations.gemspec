# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord/database_validations/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord-database_validations"
  spec.version       = ActiveRecord::DatabaseValidations::VERSION
  spec.authors       = ["Oded Niv"]
  spec.email         = ["oded.niv@gmail.com"]

  spec.summary       = %q{Handle database validations}
  spec.description   = %q{Use database validations and convert ActiveRecord::StatementInvalid into ActiveRecord::RecordInvalid}
  spec.homepage      = "https://github.com/odedniv/activerecord-database_validations"
  spec.license       = "Unlicense"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activerecord", "~> 4.2", ">= 4.2.0"

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "byebug", "~> 3.5"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "simplecov", "~> 0.9"
  spec.add_development_dependency "database_cleaner", "~> 1.4"

  spec.add_development_dependency "mysql2", "~> 0.3"
  spec.add_development_dependency "pg", "~> 0.18"
end
