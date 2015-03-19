# Copyrights 2007-2014 by [Mark Overmeer].
#  For other contributors see ChangeLog.
# See the manual pages for details on the licensing terms.
# Pod stripped from pm file by OODoc 2.01.
use warnings;
use strict;

package Log::Report::Die;
use vars '$VERSION';
$VERSION = '1.05';

use base 'Exporter';

our @EXPORT = qw/die_decode/;

use POSIX  qw/locale_h/;


sub die_decode($)
{   my @text   = split /\n/, $_[0];
    @text or return ();
    chomp $text[-1];

    my %opt    = (errno => $! + 0);
    my $err    = "$!";

    my $dietxt = $text[0];
    if($text[0] =~ s/ at (.+) line (\d+)\.?$// )
    {   $opt{location} = [undef, $1, $2, undef];
    }
    elsif(@text > 1 && $text[1] =~ m/^\s*at (.+) line (\d+)\.?$/ )
    {   # sometimes people carp/confess with \n, folding the line
        $opt{location} = [undef, $1, $2, undef];
        splice @text, 1, 1;
    }

    $text[0] =~ s/\s*[.:;]?\s*$err\s*$//  # the $err is translation sensitive
        or delete $opt{errno};

    my $msg = shift @text;
    length $msg or $msg = 'stopped';

    my @stack;
    foreach (@text)
    {   push @stack, [ $1, $2, $3 ]
            if m/^\s*(.*?)\s+called at (.*?) line (\d+)\s*$/;
    }
    $opt{stack}   = \@stack;
    $opt{classes} = [ 'perl', (@stack ? 'confess' : 'die') ];

    my $reason
      = @{$opt{stack}} ? ($opt{errno} ? 'ALERT' : 'PANIC')
      :                  ($opt{errno} ? 'FAULT' : 'ERROR');

    ($dietxt, \%opt, $reason, $msg);
}

"to die or not to die, that's the question";
