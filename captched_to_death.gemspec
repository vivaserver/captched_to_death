# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "captched_to_death/version"

Gem::Specification.new do |s|
  s.name        = "captched_to_death"
  s.version     = CaptchedToDeath::VERSION
  s.authors     = ["Cristian R. Arroyo"]
  s.email       = ["cristian.arroyo@vivaserver.com"]
  s.homepage    = "http://www.nicalert.com.ar"
  s.summary     = %q{A simple HTTP client to DeathByCaptcha.eu API}
  s.description = %q{A simple HTTP client to DeathByCaptcha.eu API}

  s.add_runtime_dependency 'rest-client', "~> 1.6"
  s.add_development_dependency "fakeweb"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
