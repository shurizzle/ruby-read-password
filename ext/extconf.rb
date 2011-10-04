if RUBY_PLATFORM =~ /(?<!dar)win|w32|java/
  require 'mkmf'

  lib = 'noecho'

  File.open(File.join(Dir.pwd, 'Makefile'), 'w') {|f|
    f.write "all:\n\ninstall:\n\n"
  }
  if RUBY_PLATFORM =~ /(?<!dar)win|w32/
    File.open(File.join(Dir.pwd, lib + '.dll'), 'w') {}
    File.open(File.join(Dir.pwd, 'nmake.bat'), 'w') {}
  else
    File.open(File.join(Dir.pwd, 'make'), 'w') {|f|
      f.write '#!/bin/sh'
      f.chmod f.stat.mode | 0111
    }
    File.open(File.join(Dir.pwd, lib + '.so'), 'w') {}
  end
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
