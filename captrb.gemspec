# your_app.gemspec
Gem::Specification.new do |s|
  s.name        = 'captrb'
  s.version     = '0.1.1'
  s.summary     = 'captain\'s log'
  s.description = 'A longer description of your app'
  s.authors     = ['pugtech']
  s.email       = ['support@pugtech.co']
  s.homepage    = 'https://pugtech.co'
  s.license     = nil

  s.files       = Dir['lib/**/*', 'bin/*']

  s.add_dependency 'sqlite3', "~> 1.4"
end

