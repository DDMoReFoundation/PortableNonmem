# NOTE: Derived from blib\lib\Log\Agent.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Log::Agent;

#line 400 "blib\lib\Log\Agent.pm (autosplit into blib\lib\auto\Log\Agent\bug.al)"
#
# bug
#
# Log bug, and die.
#
sub bug {
	my $ptag = prio_tag(priority_level(EMERG)) if defined $Priorities;
	my $str = tag_format_args($Caller, $ptag, $Tags, \@_);
	logerr("BUG: $str");
	die "${Prefix}: $str\n";
}

# end of Log::Agent::bug
1;
