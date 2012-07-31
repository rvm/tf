Gem::Specification.new do |s|
  s.name = "tf"
  s.version = "0.3.2"
  s.summary = "Testing Framework"
  s.email = "mpapis+tf@gmail.com"
  s.homepage = "http://github.com/mpapis/tf"
  s.description = "Testing Framework solely based on plugins. For now only tests using Bash."
  s.has_rdoc = false
  s.author = "Michal Papis"
  s.add_dependency('session','~> 3.1')
  s.files = Dir.glob("lib/**/*") + %w( bin/tf LICENSE README.md )
  s.executables  = %w( tf )
end
