# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "sequel-mysql_generated_columns"
  spec.version       = "0.1.0"
  spec.authors       = ["Damián Silvani"]
  spec.email         = ["munshkr@gmail.com"]

  spec.summary       = %q{Sequel extension that adds support for MySQL generated columns.}
  spec.homepage      = "https://github.com/munshkr/sequel-mysql_generated_columns"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_dependency "sequel", ">= 4"
end
