package Messaging::Twitter::Help;

use strict;
use base qw( Messaging::Twitter );

=head2 help/test
=cut

sub test {
    return { ok => 'true' };
}

1;
__END__
