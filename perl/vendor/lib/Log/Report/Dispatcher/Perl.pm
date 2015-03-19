# Copyrights 2007-2014 by [Mark Overmeer].
#  For other contributors see ChangeLog.
# See the manual pages for details on the licensing terms.
# Pod stripped from pm file by OODoc 2.01.
use warnings;
use strict;

package Log::Report::Dispatcher::Perl;
use vars '$VERSION';
$VERSION = '1.05';

use base 'Log::Report::Dispatcher';

use Log::Report 'log-report';
use IO::File;

my $singleton = 0;   # can be only one (per thread)


sub log($$$$)
{   my ($self, $opts, $reason, $message, $domain) = @_;
    print STDERR $self->translate($opts, $reason, $message);
}

1;
