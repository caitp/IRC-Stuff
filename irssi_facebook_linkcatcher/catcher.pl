use WWW::Facebook::API;
use LWP::Simple;                # From CPAN
use JSON qw( decode_json );     # From CPAN
use Data::Dumper;               # Perl core module
#use strict;                     # Good practice
use warnings;                   # Good practice
use Irssi 20010120.0250 ();
$VERSION = "0.2";

%IRSSI = (
        authors     => 'David Leadbeater, erratic',
        contact     => 'dgl@dgl.cx, paigeadele@gmail.com',
        name        => 'urlgrab2FBPage',
        description => 'Captures urls said in channel and priv msgs and sends it to face book page',
        license     => 'GNU GPLv2 or later',
        url         => 'https://www.facebook.com/irclinks',
        );

my $lasturl = '';

# Change the file path below if needed
my $file = "$ENV{HOME}/.urllog";
my $api_key = "$ENV{HOME}/.fb_api_key";

sub url_public 
{
    my($server,$text,$nick,$hostmask,$channel)=@_;
    my $url = find_url($text);
    url_log($nick, $channel, $url) if defined $url;
}

sub url_private 
{
    my($server,$text,$nick,$hostmask)=@_;
    my $url = find_url($text);
    url_log($nick, $server->{nick}, $url) if defined $url;
}

sub url_cmd 
{
    if(!$lasturl) 
    {
        Irssi::print("No url captured yet");
        return;
    }
#deprecated from this script
    return;
#system("netscape-remote -remote 'openURL($lasturl)' &>/dev/null");
}

sub find_url 
{
    my $text = shift;
    if($text =~ /((ftp|http):\/\/[a-zA-Z0-9\/\\\:\?\%\.\&\;=#\-\_\!\+\~]*)/i)
    {
        return $1;
    }
    elsif($text =~ /(www\.[a-zA-Z0-9\/\\\:\?\%\.\&\;=#\-\_\!\+\~]*)/i)
    {
        return "http://".$1;
    }
    return undef;
}

sub url_log 
{
    my($where,$channel,$url) = @_;
    return if lc $url eq lc $lasturl; # a tiny bit of protection from spam/flood
        $lasturl = $url;
#open(URLLOG, ">>$file") or return;
#print URLLOG time." $where $channel $lasturl\n";
#close(URLLOG);
#TODO send to facebook stream
}

sub get_config 
{
    local $/;
    open(FILE, $api_key);
    my $json = <FILE>;
    close(FILE);  
    my $decoded_json = decode_json( $json );
    return $decoded_json;
}

# @ENV{qw/WFA_API_KEY WFA_SECRET WFA_DESKTOP/} are the initial values,
# so use those if you only have one app and don't want to pass in values
# to constructor

sub sendto_facebook_stream 
{
    my $config = get_config();
    print $config;
    my $client = WWW::Facebook::API->new(
            desktop => 0,
            api_key => $config->{'app_id'},
            secret => $config->{'app_secret'},
            postback => $config->{'return_url'}
            );
    print Dumper($client);
    return;
# Change API key and secret
#print "Enter your public API key: ";
#chomp( my $val = <STDIN> );
    #$client->api_key($val);
#print "Enter your API secret: ";
#chomp($val = <STDIN> );
    #$client->secret($val);

# not needed if web app (see $client->canvas->get_fb_params)
    #$client->auth->get_session( $token );

#use Data::Dumper;
#my $friends_perl = $client->friends->get;
#print Dumper $friends_perl;

#my $notifications_perl = $client->notifications->get;
#print Dumper $notifications_perl;

# Current user's quotes
#my $quotes_perl = $client->users->get_info(
#    uids   => $friends_perl,
#    fields => ['quotes']
#    );
#print Dumper $quotes_perl;

    $client->auth->logout;
}

#handlers 
#Irssi::signal_add_last("message public", "url_public");
#Irssi::signal_add_last("message private", "url_private");
#Irssi::command_bind("url", "url_cmd");
print "loaded and ready.";
my $testconfig = get_config(); 
print Dumper($testconfig);
print "$testconfig->{'app_id'}";
sendto_facebook_stream();
