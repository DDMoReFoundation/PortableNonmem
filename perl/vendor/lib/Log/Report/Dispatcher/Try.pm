# Copyrights 2007-2014 by [Mark Overmeer].
#  For other contributors see ChangeLog.
# See the manual pages for details on the licensing terms.
# Pod stripped from pm file by OODoc 2.01.
use warnings;
use strict;

package Log::Report::Dispatcher::Try;
use vars '$VERSION';
$VERSION = '1.05';

use base 'Log::Report::Dispatcher';

use Log::Report 'log-report', syntax => 'SHORT';
use Log::Report::Exception;


use overload
    bool     => 'failed'
  , '""'     => 'showStatus'
  , fallback => 1;

#-----------------

sub init($)
{   my ($self, $args) = @_;
    defined $self->SUPER::init($args) or return;
    $self->{exceptions} = delete $args->{exceptions} || [];
    $self->{died}       = delete $args->{died};
    $self;
}


sub close()
{   my $self = shift;
    $self->SUPER::close or return;
    $self;
}

#-----------------

sub died(;$)
{   my $self = shift;
    @_ ? ($self->{died} = shift) : $self->{died};
}


sub exceptions() { @{shift->{exceptions}} }

#-----------------

sub log($$$$)
{   my ($self, $opts, $reason, $message, $domain) = @_;

    # If "try" does not want a stack, because of its mode,
    # then don't produce one later!  (too late)
    $opts->{stack}    ||= [];
    $opts->{location} ||= '';

    my $e = Log::Report::Exception->new
     ( reason      => $reason
     , report_opts => $opts
     , message     => $message
     );

    my $is_fatal = exists $opts->{is_fatal} ? $opts->{is_fatal} : $e->isFatal;

    push @{$self->{exceptions}}, $e;

    # later changed into nice message
    $self->{died} ||= $opts->{is_fatal};
    $self;
}


sub reportFatal(@) { $_->throw(@_) for shift->wasFatal   }
sub reportAll(@)   { $_->throw(@_) for shift->exceptions }

#-----------------

sub failed()  {   shift->{died}}
sub success() { ! shift->{died}}


sub wasFatal(@)
{   my ($self, %args) = @_;
    $self->{died} or return ();
    my $ex = $self->{exceptions}[-1];
    (!$args{class} || $ex->inClass($args{class})) ? $ex : ();
}


sub showStatus()
{   my $self  = shift;
    my $fatal = $self->wasFatal or return '';
    __x"try-block stopped with {reason}: {text}"
      , reason => $fatal->reason
      , text   => $self->died;
}

1;
