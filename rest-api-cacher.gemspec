# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rest-api-cacher}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Cardinal Blue", "Lin Jen-Shin (aka godfat 真常)"]
  s.date = %q{2010-07-30}
  s.description = %q{}
  s.email = %q{dev (XD) cardinalblue.com}
  s.extra_rdoc_files = ["CHANGES", "Gemfile", "README", "config.ru", "start.sh"]
  s.files = ["CHANGES", "Gemfile", "README", "README.rdoc", "Rakefile", "config.ru", "lib/rest-api-cacher.rb", "lib/rest-api-cacher/version.rb", "rainbows.rb", "start.sh"]
  s.homepage = %q{http://github.com/cardinalblue/rest-api-cacher}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rest-api-cacher}
  s.rubygems_version = %q{1.3.7}
  s.summary = nil

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 1.2.1"])
      s.add_runtime_dependency(%q<eventmachine>, [">= 0.12.10"])
      s.add_runtime_dependency(%q<em-http-request>, [">= 0.2.10"])
      s.add_runtime_dependency(%q<em-mongo>, [">= 0.2.12"])
      s.add_development_dependency(%q<bson_ext>, [">= 1.0.4"])
      s.add_development_dependency(%q<bacon>, [">= 1.1.0"])
      s.add_development_dependency(%q<rr>, [">= 0.10.11"])
      s.add_development_dependency(%q<webmock>, [">= 1.3.2"])
      s.add_development_dependency(%q<bones>, [">= 3.4.7"])
    else
      s.add_dependency(%q<rack>, [">= 1.2.1"])
      s.add_dependency(%q<eventmachine>, [">= 0.12.10"])
      s.add_dependency(%q<em-http-request>, [">= 0.2.10"])
      s.add_dependency(%q<em-mongo>, [">= 0.2.12"])
      s.add_dependency(%q<bson_ext>, [">= 1.0.4"])
      s.add_dependency(%q<bacon>, [">= 1.1.0"])
      s.add_dependency(%q<rr>, [">= 0.10.11"])
      s.add_dependency(%q<webmock>, [">= 1.3.2"])
      s.add_dependency(%q<bones>, [">= 3.4.7"])
    end
  else
    s.add_dependency(%q<rack>, [">= 1.2.1"])
    s.add_dependency(%q<eventmachine>, [">= 0.12.10"])
    s.add_dependency(%q<em-http-request>, [">= 0.2.10"])
    s.add_dependency(%q<em-mongo>, [">= 0.2.12"])
    s.add_dependency(%q<bson_ext>, [">= 1.0.4"])
    s.add_dependency(%q<bacon>, [">= 1.1.0"])
    s.add_dependency(%q<rr>, [">= 0.10.11"])
    s.add_dependency(%q<webmock>, [">= 1.3.2"])
    s.add_dependency(%q<bones>, [">= 3.4.7"])
  end
end
