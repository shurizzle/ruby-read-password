Gem::Specification.new {|g|
    g.name          = 'ruby-password'
    g.version       = '0.0.1'
    g.author        = 'shura'
    g.email         = 'shura1991@gmail.com'
    g.homepage      = 'http://github.com/shurizzle/ruby-password'
    g.platform      = Gem::Platform::RUBY
    g.description   = 'Read silently password on all ruby implementations and OS'
    g.summary       = g.description
    g.files         = Dir.glob('lib/**/*') + Dir.glob('ext/*')
    g.require_path  = 'lib'
    g.executables   = []
    g.extensions    = 'ext/extconf.rb'

    g.add_dependency('fakext')
}
