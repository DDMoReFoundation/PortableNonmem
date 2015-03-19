# Copyrights 2007-2014 by [Mark Overmeer].
#  For other contributors see ChangeLog.
# See the manual pages for details on the licensing terms.
# Pod stripped from pm file by OODoc 2.01.
use warnings;
use strict;

package Log::Report::Dispatcher::File;
use vars '$VERSION';
$VERSION = '1.05';

use base 'Log::Report::Dispatcher';

use Log::Report  'log-report';
use IO::File     ();
use POSIX        qw/strftime/;

use Encode       qw/find_encoding/;
use Fcntl        qw/:flock/;


sub init($)
{   my ($self, $args) = @_;

    if(!$args->{charset})
    {   my $lc = $ENV{LC_CTYPE} || $ENV{LC_ALL} || $ENV{LANG} || '';
        my $cs = $lc =~ m/\.([\w-]+)/ ? $1 : '';
        $args->{charset} = length $cs && find_encoding $cs ? $cs : undef;
    }

    $self->SUPER::init($args);

    my $name = $self->name;
    my $to   = delete $args->{to}
        or error __x"dispatcher {name} needs parameter 'to'", name => $name;

    if(ref $to)
    {   $self->{output} = $to;
        trace "opened dispatcher $name to a ".ref($to);
    }
    else
    {   $self->{filename} = $to;
        my $binmode = $args->{replace} ? '>' : '>>';

        my $f = $self->{output} = IO::File->new($to, $binmode)
            or fault __x"cannot write log into {file} with mode {binmode}"
                 , binmode => $binmode, file => $to;
        $f->autoflush;

        trace "opened dispatcher $name to $to with $binmode";
    }

    my $format = $args->{format} || sub { '['.localtime()."] $_[0]" };
    $self->{format}
      = ref $format eq 'CODE' ? $format
      : $format eq 'LONG'
      ? sub { my $msg    = shift;
              my $domain = shift || '-';
              my $stamp  = strftime "%FT%T", gmtime;
              "[$stamp $$] $domain $msg"
            }
      : error __x"unknown format parameter `{what}'"
          , what => ref $format || $format;

    $self;
}


sub filename() {shift->{filename}}
sub format()   {shift->{format}}
sub output()   {shift->{output}}


sub close()
{   my $self = shift;
    $self->SUPER::close or return;
    $self->output->close if $self->filename;
    $self;
}


sub rotate($)
{   my ($self, $new) = @_;

    my $log = $self->filename
        or error __x"cannot rotate log file which was opened as file-handle";

    trace "rotating $log to $new";

    rename $log, $new
        or fault __x"unable to rotate logfile {oldfn} to {newfn}"
              , oldfn => $log, newfn => $new;

    $self->output->close;   # close after move not possible on Windows?
    my $f = $self->{output} = IO::File->new($log, '>>')
        or fault __x"cannot write log into {file}", file => $log;
    $f->autoflush;
    $self;
}


sub log($$$$)
{   my ($self, $opts, $reason, $msg, $domain) = @_;
    my $text = $self->format->($self->translate($opts, $reason, $msg), $domain);
    my $out  = $self->output;
    flock $out, LOCK_EX;
    $out->print($text);
    flock $out, LOCK_UN;
}

1;
