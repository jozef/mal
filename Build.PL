use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name       => 'App::mal',
    license           => 'perl',
    dist_author       => 'Jozef Kutej <jkutej@cpan.org>',
    dist_version_from => 'script/mal',

    build_requires => { 'Test::Most' => 0, },
    requires       => {
        'File::Spec'   => 0,
        'Getopt::Long' => 0,
        'Pod::Usage'   => 0,
    },
    configure_requires => { 'Module::Build' => '0.38' },
    script_files       => [ 'script/mal', ],
    add_to_cleanup     => ['App-mal-*'],
    create_readme      => 1,
    meta_merge         => {
        resources => {
            repository => 'http://github.com/jozef/mal/',
            bugtracker => 'http://github.com/jozef/mal/issues',
        },
        keywords => [qw/ app mal perl module /],
    },
);

$builder->create_build_script();
