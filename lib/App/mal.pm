package App::mal;

use strict;
use warnings;
use 5.010;

our $VERSION = '0.01';

use Moose;
use namespace::autoclean;
use MooseX::StrictConstructor;
use Module::Loader;

my %cmd_registry;

sub register_commands {
    my $cmd_module_prefix = __PACKAGE__ . '::Command';
    my $loader            = Module::Loader->new();
    my @cmd_classes       = $loader->find_modules($cmd_module_prefix);

    for my $cmd_class (@cmd_classes) {
        my $cmd_name = lc(
            substr( $cmd_class, length($cmd_module_prefix) + 2 ) =~
                s/::/-/gr );
        $cmd_registry{$cmd_name} = undef;
        __PACKAGE__->meta->add_method(
            "cmd_$cmd_name" => sub {
                my ( $self, @args ) = @_;

                # lazy load the command module
                if ( !defined $cmd_registry{$cmd_name} ) {
                    $loader->load($cmd_class);
                    $cmd_registry{$cmd_name} = $cmd_class->new;
                }
                return $cmd_registry{$cmd_name}->execute(@args);
            }
        );
    }

    return;
}

register_commands();

__PACKAGE__->meta->make_immutable();

1;

__END__

=head1 SEE ALSO

C<mal> script in this distribution.

=head1 AUTHOR

Jozef Kutej

=head1 CONTRIBUTORS

The following people have contributed to the App::mal by committing their
code, sending patches, reporting bugs, asking questions, suggesting useful
advises, nitpicking, chatting on IRC or commenting on my blog (in no particular
order):

	AI
	you?

=head1 LICENSE AND COPYRIGHT

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
