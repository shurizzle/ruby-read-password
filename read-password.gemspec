Gem::Specification.new {|g|
    g.name          = 'read-password'
    g.version       = '0.0.1'
    g.author        = 'shura'
    g.email         = 'shura1991@gmail.com'
    g.homepage      = 'http://github.com/shurizzle/ruby-read-password'
    g.platform      = Gem::Platform::RUBY
    g.description   = 'Silently read a password on all Ruby implementations and platforms'
    g.summary       = g.description
    g.files         = Dir.glob('lib/**/*') + Dir.glob('ext/*')
    g.require_path  = 'lib'
    g.executables   = []
    g.extensions    = 'ext/extconf.rb'

    g.add_dependency('fakext')
}
