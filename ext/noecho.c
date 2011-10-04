#include <ruby.h>
#ifdef HAVE_RUBY_IO_H
# include "ruby/io.h"
#else
# include "rubyio.h"
#endif

#if defined HAVE_TERMIOS_H
# include <termios.h>
typedef struct termios conmode;
# define setattr(fd, t) (tcsetattr(fd, TCSAFLUSH, t) == 0)
# define getattr(fd, t) (tcgetattr(fd, t) == 0)
#elif defined HAVE_TERMIO_H
# include <termio.h>
typedef struct termio conmode;
# define setattr(fd, t) (ioctl(fd, TCSETAF, t) == 0)
# define getattr(fd, t) (ioctl(fd, TCGETA, t) == 0)
#elif defined HAVE_SGTTY_H
# include <sgtty.h>
typedef struct sgttyb conmode;
# ifdef HAVE_STTY
# define setattr(fd, t) (stty(fd, t) == 0)
# else
# define setattr(fd, t) (ioctl((fd), TIOCSETP, (t)) == 0)
# endif
# ifdef HAVE_GTTY
# define getattr(fd, t) (gtty(fd, t) == 0)
# else
# define getattr(fd, t) (ioctl((fd), TIOCGETP, (t)) == 0)
# endif
#endif

static void
set_noecho(conmode *t) {
#if defined HAVE_TERMIOS_H || defined HAVE_TERMIO_H
  t->c_lflag &= ~(ECHO | ECHOE | ECHOK | ECHONL);
#elif defined HAVE_SGTTY_H
  t->sg_flags &= ~ECHO;
#endif
}

static void
set_echo(conmode *t) {
#if defined HAVE_TERMIOS_H || defined HAVE_TERMIO_H
  t->c_lflag |= (ECHO | ECHOE | ECHOK | ECHONL);
#elif defined HAVE_SGTTY_H
  t->sg_flags |= ECHO;
#endif
}

static int
echo_p(conmode *t) {
#if defined HAVE_TERMIOS_H || defined HAVE_TERMIO_H
  return (t->c_lflag & (ECHO | ECHOE | ECHOK | ECHONL)) != 0;
#elif defined HAVE_SGTTY_H
  return (t->sg_flags & ECHO) != 0;
#endif
}

static int
get_fd(VALUE io) {
  return FIX2INT(rb_funcall(io, rb_intern("fileno"), 0));
}

static VALUE
console_noecho(VALUE io) {
  int fd = get_fd(io);
  conmode t;

  if (!getattr(fd, &t))
    rb_raise(rb_eIOError, "Can't get attributes");

  set_noecho(&t);
  setattr(fd, &t);
  return io;
}

static VALUE
console_echo(VALUE io) {
  int fd = get_fd(io);
  conmode t;

  if (!getattr(fd, &t))
    rb_raise(rb_eIOError, "Can't get attributes");

  set_echo(&t);
  setattr(fd, &t);
  return io;
}

static VALUE
console_echo_p(VALUE io) {
  int fd = get_fd(io);
  conmode t;

  if (!getattr(fd, &t))
    rb_raise(rb_eIOError, "Can't get attributes");

  return echo_p(&t) ? Qtrue : Qfalse;
}

static VALUE
console_set_echo(VALUE io, VALUE f) {
  if (RTEST(f))
    console_echo(io);
  else
    console_noecho(io);

  return io;
}


void
Init_noecho(void) {
  rb_define_method(rb_cIO, "echo=", console_set_echo, 1);
  rb_define_method(rb_cIO, "echo?", console_echo_p, 0);
  rb_define_method(rb_cIO, "echo", console_echo, 0);
  rb_define_method(rb_cIO, "noecho", console_noecho, 0);
}
