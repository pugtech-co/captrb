# your_app.gemspec
Gem::Specification.new do |s|
  s.name        = 'captrb'
  s.version     = '0.1.3'
  s.summary     = 'captain\'s log'
  s.description = 'A longer description of your app'
  s.authors     = ['pugtech']
  s.email       = ['support@pugtech.co']
  s.homepage    = 'https://pugtech.co'
  s.license     = 'Nonstandard'

  s.files       = Dir['lib/**/*', 'bin/*']

  s.add_dependency 'sqlite3', "~> 1.4"
  s.add_dependency 'slop', "~> 4.10.1"
  s.executables = ['captrb']
end

