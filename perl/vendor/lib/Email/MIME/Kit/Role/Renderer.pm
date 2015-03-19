package Email::MIME::Kit::Role::Renderer;
# ABSTRACT: things that render templates into contents
$Email::MIME::Kit::Role::Renderer::VERSION = '2.102014';
use Moose::Role;
with 'Email::MIME::Kit::Role::Component';

#pod =head1 IMPLEMENTING
#pod
#pod This role also performs L<Email::MIME::Kit::Role::Component>.
#pod
#pod Classes implementing this role must provide a C<render> method, which is
#pod expected to turn a template and arguments into rendered output.  The method is
#pod used like this:
#pod
#pod   my $output_ref = $renderer->render($input_ref, \%arg);
#pod
#pod =cut

requires 'render';

no Moose::Role;
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Email::MIME::Kit::Role::Renderer - things that render templates into contents

=head1 VERSION

version 2.102014

=head1 IMPLEMENTING

This role also performs L<Email::MIME::Kit::Role::Component>.

Classes implementing this role must provide a C<render> method, which is
expected to turn a template and arguments into rendered output.  The method is
used like this:

  my $output_ref = $renderer->render($input_ref, \%arg);

=head1 AUTHOR

Ricardo Signes <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Ricardo Signes.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
