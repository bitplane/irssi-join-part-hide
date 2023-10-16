use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION = "1.0";
%IRSSI = (
    authors     => 'Gareth Davidson',
    name        => 'hide_join_part',
    description => 'Hide join/part messages unless user recently spoke',
);

my %recent_speakers;
my $time_limit = 60*60*24;

sub prune_old_speakers {
    my $now = time;
    foreach my $nick (keys %recent_speakers) {
        if ($now - $recent_speakers{$nick} > $time_limit) {
            delete $recent_speakers{$nick};
        }
    }
}

sub msg_public {
    my ($server, $msg, $nick, $address, $target) = @_;
    $recent_speakers{$nick} = time;
    prune_old_speakers();
}

sub hide_join_part {
    my ($type, $text, $server, $witem, $nick) = @_;
    prune_old_speakers();

    if (exists $recent_speakers{$nick}) {
        Irssi::signal_continue(@_);
    } else {
        Irssi::signal_stop();
    }
}

Irssi::signal_add('message public', 'msg_public');
Irssi::signal_add_first('message join', sub { hide_join_part('join', @_); });
Irssi::signal_add_first('message part', sub { hide_join_part('part', @_); });
