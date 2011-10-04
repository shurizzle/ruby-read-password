if RUBY_PLATFORM =~ /(?<!dar)win|w32|java/
  require 'mkmf'
  require 'fakext'

  Gem.fakext('noecho')
else
  require 'mkmf'

  ok = true

  case
  when %w[termios.h termio.h].find {|h| have_header(h) } then nil
  when have_header('sgtty.h') then %w[stty gtty].each {|f| have_func(f, 'sgtty.h') }
  else ok = false
  end

  have_header('sys/ioctl.h')
  have_func("rb_io_get_write_io", "ruby/io.h")

  create_makefile('io/noecho') if ok
end
