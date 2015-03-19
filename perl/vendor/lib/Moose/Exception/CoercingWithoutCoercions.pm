package Moose::Exception::CoercingWithoutCoercions;
BEGIN {
  $Moose::Exception::CoercingWithoutCoercions::AUTHORITY = 'cpan:STEVAN';
}
$Moose::Exception::CoercingWithoutCoercions::VERSION = '2.1211';
use Moose;
extends 'Moose::Exception';
with 'Moose::Exception::Role::TypeConstraint';

sub _build_message {
    my $self = shift;
    "Cannot coerce without a type coercion";
}
1;
