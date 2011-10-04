if RUBY_PLATFORM =~ /(?<!dar)win|w32/
  require 'Win32API'

  module Kernel
    module API
      GetStdHandle = Win32API.new('kernel32', 'GetStdHandle', ['l'], 'p')
      GetConsoleMode = Win32API.new('kernel32', 'GetConsoleMode', ['l', 'p'], 'l')
      SetConsoleMode = Win32API.new('kernel32', 'SetConsoleMode', ['l', 'l'], 'l')
      ReadConsole = Win32API.new('kernel32', 'ReadConsole', ['l', 'p', 'l', 'p', 'p'], 'l')

      class << self
        def get_std_handle(handle)
          GetStdHandle.call(handle)
        end

        def get_console_mode(handle)
          lp_mode = ' ' * 4
          GetConsoleMode.call(handle, lp_mode)
          lp_mode.unpack('L').first
        end

        def set_console_mode(handle, lp_mode)
          SetConsoleMode.call(handle, lp_mode)
        end

        def read_console(handle, n)
          buf = ' ' * n
          nocr = ' ' * 4
          reserved = ' ' * 4
          ReadConsole.call(handle, buf, n, nocr, reserved)
          buf
        end
      end
    end

    ENABLE_ECHO_INPUT = 0x0004

    def self.password(prompt='Password: ')
      handle = API.get_std_handle(0xFFFFFFF6)
      mode = API.get_console_mode(handle) rescue 9999

      res = if (mode & ENABLE_ECHO_INPUT) == ENABLE_ECHO_INPUT
              API.set_console_mode(handle, mode & ~ENABLE_ECHO_INPUT)
              STDIN.gets.chomp.tap {
                API.set_console_mode(handle, mode)
              }
            else
              STDIN.gets.chomp
            end
      STDOUT.puts

      res
    end
  end
elsif RUBY_PLATFORM =~ /java/
  module Kernel
    def self.password(prompt='Password: ')
      Java::java.lang.String.new(Java::java.lang.System.console.readPassword(prompt)).to_s
    rescue
      raise RuntimeError, "Cannot read password"
    end
  end
else
  require 'io/noecho'

  module Kernel
    def self.password(prompt='Password: ')
      STDOUT.print(prompt)

      res = if STDIN.echo?
              STDIN.noecho
              STDIN.gets.chomp.tap {
                STDIN.echo
              }
            else
              STDIN.gets.chomp
            end

      STDOUT.puts
      res
    end
  end
end
