package model::problem::thetap;

use Moose;
use MooseX::Params::Validate;

extends 'model::problem::theta';

no Moose;
__PACKAGE__->meta->make_immutable;
1;
