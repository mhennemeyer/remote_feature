Gem::Specification.new do |s|
  s.name     = "remote_feature"
  s.version  = "0.1.6"
  s.date     = "2008-11-15"
  s.summary  = "Run Cucumber Features that are defined in Writeboards"
  s.email    = "mhennemeyer@gmail.com"
  s.homepage = "http://github.com/mhennemeyer/remote_feature"
  s.description = "Run Cucumber Features that are defined in Writeboards"
  s.has_rdoc = false
  s.authors  = ["Matthias Hennemeyer"]
  s.files    = [ 
		"README",  
		"remote_feature.gemspec", 
		"lib/remote_feature.rb"]
  s.test_files = ["spec/remote_feature_spec.rb"]
  s.add_dependency("mhennemeyer-rwriteboard", ["> 0.1.3"])
end