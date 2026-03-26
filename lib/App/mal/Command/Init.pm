package App::mal::Command::Init;

use strict;
use warnings;
use 5.010;

our $VERSION = '0.01';

use Moose;
use namespace::autoclean;
use MooseX::StrictConstructor;

sub execute {
    my ($self, @args) = @_;

    say 'TODO: init with: ', join(' ', @args);

    return;
}

__PACKAGE__->meta->make_immutable();

1;
