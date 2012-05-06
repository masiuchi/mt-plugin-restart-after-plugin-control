package MT::Plugin::RestartAfterPluginControl;
use strict;
use warnings;
use base 'MT::Plugin';

our $VERSION = '0.02';
our $NAME    = ( split /::/, __PACKAGE__ )[-1];

my $plugin = __PACKAGE__->new({
    name     => $NAME,
    id       => lc $NAME,
    key      => lc $NAME,
    version  => $VERSION,
    author_name => 'masiuchi',
    author_link => 'https://github.com/masiuchi',
    plugin_link => 'https://github.com/masiuchi/mt-plugin-restart-after-plugin-control',
    description => 'Restart FastCGI process after changing plugin status.',
});
MT->add_plugin( $plugin );

sub init_registry {
    my ( $p ) = @_;

    my $pkg = '$' . $NAME . '::' . $NAME;
    $p->registry({
        applications => {
            cms => {
                methods => {
                    plugin_control => $pkg . '::CMS::plugin_control',
                },
            },
        },
    });
}

1;
__END__
