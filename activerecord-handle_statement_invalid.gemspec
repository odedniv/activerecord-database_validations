# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord/handle_statement_invalid/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord-handle_statement_invalid"
  spec.version       = Activerecord::HandleStatementInvalid::VERSION
  spec.authors       = ["Oded Niv"]
  spec.email         = ["oded.niv@gmail.com"]

  spec.summary       = %q{Handle ActiveRecord::StatementInvalid}
  spec.description   = %q{Convert ActiveRecord::StatementInvalid into ActiveRecord::RecordInvalid}
  spec.homepage      = "https://github.com/odedniv/activerecord-handle_statement_invalid"
  spec.license       = "UNLICENSE"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activerecord", ENV['ACTIVE_RECORD_VERSION'] || "< 5"

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "rspec-its", "~> 1.2"
end
