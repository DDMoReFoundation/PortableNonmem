package Math::Prime::Util::PPFE;
use strict;
use warnings;
use Math::Prime::Util::PP;
use Carp qw/carp croak confess/;

# The PP front end, only loaded if XS is not used.
# It is intended to load directly into the MPU namespace.

package Math::Prime::Util;

*_validate_num = \&Math::Prime::Util::PP::_validate_num;
*_validate_integer = \&Math::Prime::Util::PP::_validate_integer;
*_prime_memfreeall = \&Math::Prime::Util::PP::_prime_memfreeall;
*prime_memfree  = \&Math::Prime::Util::PP::prime_memfree;
*prime_precalc  = \&Math::Prime::Util::PP::prime_precalc;


sub moebius {
  if (scalar @_ <= 1) {
    my($n) = @_;
    return 0 if defined $n && $n < 0;
    _validate_num($n) || _validate_positive_integer($n);
    return Math::Prime::Util::PP::moebius($n);
  }
  my($lo, $hi) = @_;
  _validate_num($lo) || _validate_positive_integer($lo);
  _validate_num($hi) || _validate_positive_integer($hi);
  return Math::Prime::Util::PP::moebius_range($lo, $hi);
}

sub euler_phi {
  if (scalar @_ <= 1) {
    my($n) = @_;
    return 0 if defined $n && $n < 0;
    _validate_num($n) || _validate_positive_integer($n);
    return Math::Prime::Util::PP::euler_phi($n);
  }
  my($lo, $hi) = @_;
  _validate_num($lo) || _validate_positive_integer($lo);
  _validate_num($hi) || _validate_positive_integer($hi);
  return Math::Prime::Util::PP::euler_phi_range($lo, $hi);
}
sub jordan_totient {
  my($k, $n) = @_;
  _validate_positive_integer($k);
  return 0 if defined $n && $n < 0;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::jordan_totient($k, $n);
}
sub carmichael_lambda {
  my($n) = @_;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::carmichael_lambda($n);
}
sub mertens {
  my($n) = @_;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::mertens($n);
}
sub liouville {
  my($n) = @_;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::liouville($n);
}
sub exp_mangoldt {
  my($n) = @_;
  return 1 if defined $n && $n <= 1;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::exp_mangoldt($n);
}


sub nth_prime {
  my($n) = @_;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::nth_prime($n);
}
sub nth_prime_lower {
  my($n) = @_;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::nth_prime_lower($n);
}
sub nth_prime_upper {
  my($n) = @_;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::nth_prime_upper($n);
}
sub nth_prime_approx {
  my($n) = @_;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::nth_prime_approx($n);
}
sub prime_count_lower {
  my($n) = @_;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::prime_count_lower($n);
}
sub prime_count_upper {
  my($n) = @_;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::prime_count_upper($n);
}
sub prime_count_approx {
  my($n) = @_;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::prime_count_approx($n);
}
sub twin_prime_count {
  my($low,$high) = @_;
  if (scalar @_ > 1) {
    _validate_positive_integer($low);
    _validate_positive_integer($high);
  } else {
    ($low,$high) = (2, $low);
    _validate_positive_integer($high);
  }
  return Math::Prime::Util::PP::twin_prime_count($low,$high);
}
sub twin_prime_count_approx {
  my($n) = @_;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::twin_prime_count_approx($n);
}
sub nth_twin_prime {
  my($n) = @_;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::nth_twin_prime($n);
}
sub nth_twin_prime_approx {
  my($n) = @_;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::nth_twin_prime_approx($n);
}


sub is_prime {
  my($n) = @_;
  return 0 if defined $n && int($n) < 0;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::is_prime($n);
}
sub is_prob_prime {
  my($n) = @_;
  return 0 if defined $n && int($n) < 0;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::is_prob_prime($n);
}
sub is_pseudoprime {
  my($n, $base) = @_;
  return 0 if defined $n && int($n) < 0;
  _validate_positive_integer($n);
  _validate_positive_integer($base) if defined $base;
  return Math::Prime::Util::PP::is_pseudoprime($n, $base);
}
sub is_strong_pseudoprime {
  my($n, @bases) = @_;
  return 0 if defined $n && int($n) < 0;
  _validate_positive_integer($n);
  croak "No bases given to is_strong_pseudoprime" unless @bases;
  return Math::Prime::Util::PP::is_strong_pseudoprime($n, @bases);
}
sub is_lucas_pseudoprime {
  my($n) = @_;
  return 0 if defined $n && int($n) < 0;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::is_lucas_pseudoprime($n);
}
sub is_strong_lucas_pseudoprime {
  my($n) = @_;
  return 0 if defined $n && int($n) < 0;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::is_strong_lucas_pseudoprime($n);
}
sub is_extra_strong_lucas_pseudoprime {
  my($n) = @_;
  return 0 if defined $n && int($n) < 0;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::is_extra_strong_lucas_pseudoprime($n);
}
sub is_almost_extra_strong_lucas_pseudoprime {
  my($n, $increment) = @_;
  return 0 if defined $n && int($n) < 0;
  _validate_positive_integer($n);
  if (defined $increment) { _validate_positive_integer($increment, 1, 256);
  } else                  { $increment = 1; }
  return Math::Prime::Util::PP::is_almost_extra_strong_lucas_pseudoprime($n, $increment);
}
sub is_frobenius_underwood_pseudoprime {
  my($n) = @_;
  return 0 if defined $n && int($n) < 0;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::is_frobenius_underwood_pseudoprime($n);
}
sub is_aks_prime {
  my($n) = @_;
  return 0 if defined $n && int($n) < 0;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::is_aks_prime($n);
}


sub kronecker {
  my($a, $b) = @_;
  my ($va, $vb) = ($a, $b);
  $va = -$va if defined $va && $va < 0;
  $vb = -$vb if defined $vb && $vb < 0;
  _validate_positive_integer($va);
  _validate_positive_integer($vb);
  return Math::Prime::Util::PP::kronecker(@_);
}

sub binomial {
  my($n, $k) = @_;
  _validate_integer($n);
  _validate_integer($k);
  return Math::Prime::Util::PP::binomial($n, $k);
}

sub znorder {
  my($a, $n) = @_;
  _validate_positive_integer($a);
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::znorder($a, $n);
}

sub znlog {
  my($a, $g, $p) = @_;
  _validate_positive_integer($a);
  _validate_positive_integer($g);
  _validate_positive_integer($p);
  return Math::Prime::Util::PP::znlog($a, $g, $p);
}

sub znprimroot {
  my($n) = @_;
  $n = -$n if defined $n && $n =~ /^-\d+/;   # TODO: fix this for string bigints
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::znprimroot($n);
}

sub trial_factor {
  my($n, $maxlim) = @_;
  _validate_positive_integer($n);
  if (defined $maxlim) {
    _validate_positive_integer($maxlim);
    return Math::Prime::Util::PP::trial_factor($n, $maxlim);
  }
  return Math::Prime::Util::PP::trial_factor($n);
}
sub fermat_factor {
  my($n, $rounds) = @_;
  _validate_positive_integer($n);
  if (defined $rounds) {
    _validate_positive_integer($rounds);
    return Math::Prime::Util::PP::fermat_factor($n, $rounds);
  }
  return Math::Prime::Util::PP::fermat_factor($n);
}
sub holf_factor {
  my($n, $rounds) = @_;
  _validate_positive_integer($n);
  if (defined $rounds) {
    _validate_positive_integer($rounds);
    return Math::Prime::Util::PP::holf_factor($n, $rounds);
  }
  return Math::Prime::Util::PP::holf_factor($n);
}
sub squfof_factor {
  my($n, $rounds) = @_;
  _validate_positive_integer($n);
  if (defined $rounds) {
    _validate_positive_integer($rounds);
    return Math::Prime::Util::PP::squfof_factor($n, $rounds);
  }
  return Math::Prime::Util::PP::squfof_factor($n);
}
sub pbrent_factor {
  my($n, $rounds, $pa) = @_;
  _validate_positive_integer($n);
  if (defined $rounds) { _validate_positive_integer($rounds);
  } else               { $rounds = 4*1024*1024; }
  if (defined $pa    ) { _validate_positive_integer($pa);
  } else               { $pa = 3; }
  return Math::Prime::Util::PP::pbrent_factor($n, $rounds, $pa);
}
sub prho_factor {
  my($n, $rounds, $pa) = @_;
  _validate_positive_integer($n);
  if (defined $rounds) { _validate_positive_integer($rounds);
  } else               { $rounds = 4*1024*1024; }
  if (defined $pa    ) { _validate_positive_integer($pa);
  } else               { $pa = 3; }
  return Math::Prime::Util::PP::prho_factor($n, $rounds, $pa);
}
sub pminus1_factor {
  my($n, $B1, $B2) = @_;
  _validate_positive_integer($n);
  _validate_positive_integer($B1) if defined $B1;
  _validate_positive_integer($B2) if defined $B2;
  Math::Prime::Util::PP::pminus1_factor($n, $B1, $B2);
}
*pplus1_factor = \&pminus1_factor;
sub ecm_factor {
  my($n, $B1, $B2, $ncurves) = @_;
  _validate_positive_integer($n);
  _validate_positive_integer($B1) if defined $B1;
  _validate_positive_integer($B2) if defined $B2;
  _validate_positive_integer($ncurves) if defined $ncurves;
  Math::Prime::Util::PP::ecm_factor($n, $B1, $B2, $ncurves);
}

sub divisors {
  my($n) = @_;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::divisors($n);
}

sub divisor_sum {
  my($n, $k) = @_;
  _validate_positive_integer($n);
  _validate_positive_integer($k) if defined $k && ref($k) ne 'CODE';
  return Math::Prime::Util::PP::divisor_sum($n, $k);
}

sub gcd {
  my(@v) = @_;
  _validate_integer($_) for @v;
  return Math::Prime::Util::PP::gcd(@v);
}
sub lcm {
  my(@v) = @_;
  _validate_integer($_) for @v;
  return Math::Prime::Util::PP::lcm(@v);
}
sub gcdext {
  my($a,$b) = @_;
  _validate_integer($a);
  _validate_integer($b);
  return Math::Prime::Util::PP::gcdext($a,$b);
}
sub chinese {
  # TODO: make sure we're not modding their data
  foreach my $aref (@_) {
    die "chinese arguments are two-element array references"
      unless ref($aref) eq 'ARRAY' && scalar @$aref == 2;
    _validate_integer($aref->[0]);
    _validate_integer($aref->[1]);
  }
  return Math::Prime::Util::PP::chinese(@_);
}
sub vecsum {
  my(@v) = @_;
  _validate_integer($_) for @v;
  return Math::Prime::Util::PP::vecsum(@v);
}
sub invmod {
  my ($a, $n) = @_;
  _validate_integer($a);
  _validate_integer($n);
  return Math::Prime::Util::PP::invmod($a,$n);
}

sub legendre_phi {
  my($x, $a) = @_;
  _validate_positive_integer($x);
  _validate_positive_integer($a);
  return Math::Prime::Util::PP::legendre_phi($x, $a);
}

sub chebyshev_theta {
  my($n) = @_;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::chebyshev_theta($n);
}
sub chebyshev_psi {
  my($n) = @_;
  _validate_positive_integer($n);
  return Math::Prime::Util::PP::chebyshev_psi($n);
}

sub is_power {
  my($n, $a) = @_;
  return 0 if defined $n && $n < 0;
  _validate_positive_integer($n);
  _validate_positive_integer($a) if defined $a;
  return Math::Prime::Util::PP::is_power($n, $a);
}
sub valuation {
  my($n, $k) = @_;
  $n = -$n if defined $n && $n < 0;
  $k = -$k if defined $k && $k < 0;
  _validate_positive_integer($n);
  _validate_positive_integer($k);
  return Math::Prime::Util::PP::valuation($n, $k);
}

#############################################################################

sub forprimes (&$;$) {    ## no critic qw(ProhibitSubroutinePrototypes)
  my($sub, $beg, $end) = @_;
  if (!defined $end) { $end = $beg; $beg = 2; }
  _validate_num($beg) || _validate_positive_integer($beg);
  _validate_num($end) || _validate_positive_integer($end);
  $beg = 2 if $beg < 2;
  {
    my $pp;
    local *_ = \$pp;
    for (my $p = next_prime($beg-1);  $p <= $end;  $p = next_prime($p)) {
      $pp = $p;
      $sub->();
    }
  }
}

sub forcomposites(&$;$) { ## no critic qw(ProhibitSubroutinePrototypes)
  my($sub, $beg, $end) = @_;
  if (!defined $end) { $end = $beg; $beg = 4; }
  _validate_num($beg) || _validate_positive_integer($beg);
  _validate_num($end) || _validate_positive_integer($end);
  $beg = 4 if $beg < 4;
  $end = Math::BigInt->new(''.~0) if ref($end) ne 'Math::BigInt' && $end == ~0;
  {
    my $pp;
    local *_ = \$pp;
    for ( ; $beg <= $end ; $beg++ ) {
      if (!is_prime($beg)) {
        $pp = $beg;
        $sub->();
      }
    }
  }
}

sub foroddcomposites(&$;$) { ## no critic qw(ProhibitSubroutinePrototypes)
  my($sub, $beg, $end) = @_;
  if (!defined $end) { $end = $beg; $beg = 9; }
  _validate_num($beg) || _validate_positive_integer($beg);
  _validate_num($end) || _validate_positive_integer($end);
  $beg = 9 if $beg < 9;
  $beg++ unless $beg & 1;
  $end = Math::BigInt->new(''.~0) if ref($end) ne 'Math::BigInt' && $end == ~0;
  {
    my $pp;
    local *_ = \$pp;
    for ( ; $beg <= $end ; $beg += 2 ) {
      if (!is_prime($beg)) {
        $pp = $beg;
        $sub->();
      }
    }
  }
}

sub fordivisors (&$) {    ## no critic qw(ProhibitSubroutinePrototypes)
  my($sub, $n) = @_;
  _validate_num($n) || _validate_positive_integer($n);
  my @divisors = divisors($n);
  {
    my $pp;
    local *_ = \$pp;
    foreach my $d (@divisors) {
      $pp = $d;
      $sub->();
    }
  }
}

sub forpart (&$;$) {    ## no critic qw(ProhibitSubroutinePrototypes)
  Math::Prime::Util::PP::forpart(@_);
}

1;

__END__

=pod

=head1 NAME

Math::Prime::Util::PPFE - PP front end for Math::Prime::Util

=head1 SYNOPSIS

This loads the PP code and adds input validation front ends.  It is only
meant to be used when XS is not used.

=head1 DESCRIPTION

Loads PP module and implements PP front-end functions for all XS code.
This is used only if the XS code is not loaded.

=head1 SEE ALSO

L<Math::Prime::Util>

L<Math::Prime::Util::PP>

=head1 AUTHORS

Dana Jacobsen E<lt>dana@acm.orgE<gt>


=head1 COPYRIGHT

Copyright 2014 by Dana Jacobsen E<lt>dana@acm.orgE<gt>

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
