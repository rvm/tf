Gem::Specification.new do |s|
  s.name = "dtf"
  s.version = "0.1.3"
  s.date = "2012-02-02"
  s.summary = "Deryl Testing Framework"
  s.email = "mpapis+dtf@gmail.com"
  s.homepage = "http://github.com/dtf-gems/DTF"
  s.description = "Testing Framework solely based on plugins. For now only tests using Bash."
  s.has_rdoc = false
  s.authors = ["Deryl R. Doucette", "Michal Papis"]
  s.add_dependency('session','~> 3.0')
  s.files = Dir.glob("lib/**/*") + %w( bin/dtf LICENSE README.md )
  s.executables  = %w( dtf )
end
