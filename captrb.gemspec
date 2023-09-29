# your_app.gemspec
Gem::Specification.new do |s|
  s.name        = 'captrb'
  s.version     = '0.1.0'
  s.summary     = 'captain\'s log'
  s.description = 'A longer description of your app'
  s.authors     = ['pugtech']
  s.email       = ['support@pugtech.co']
  s.homepage    = 'pugtech.co'
  s.license     = '?'

  s.files       = Dir['lib/**/*', 'bin/*']

  s.add_dependency 'sqlite3'
end

