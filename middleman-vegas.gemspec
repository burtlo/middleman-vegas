
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "middleman-vegas/version"

Gem::Specification.new do |spec|
  spec.name          = "middleman-vegas"
  spec.version       = Middleman::Vegas::VERSION
  spec.authors       = ["Franklin Webber"]
  spec.email         = ["franklin.webber@gmail.com"]

  spec.summary       = %q{Add code highlighting to your middleman application.}
  spec.description   = %q{This brings the powerful features found in the Octopress Code Highlighter to Middleman. This allows you to specify code fences with additional metadata to provide a richer experience when using code to tell your stories.}
  spec.homepage      = "https://github.com/burtlo/middleman-vegas"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency("middleman-core", ["~> 4.0"])
  spec.add_runtime_dependency("rouge", ["~> 3.0"])
  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"

end
