
# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cron_kubernetes/version"

Gem::Specification.new do |spec|
  spec.name          = "cron-kubernetes"
  spec.version       = CronKubernetes::VERSION
  spec.authors       = ["Jeremy Wadsack"]
  spec.email         = ["jeremy.wadsack@gmail.com"]

  spec.summary       = "Configure and deploy Kubernetes CronJobs from ruby."
  spec.description   = "Configure and deploy Kubernetes CronJobs from ruby"
  spec.homepage      = "https://github.com/keylimetoolbox/cron-kubernetes"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "bundler-audit", "~> 0"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.7"
  spec.add_development_dependency "rubocop", "~> 0.52", ">= 0.52.1"
end
