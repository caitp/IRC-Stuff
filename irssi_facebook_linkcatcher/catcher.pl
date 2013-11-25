#use Facebook::Graph;
use LWP::Simple;                # From CPAN
use JSON qw( decode_json );     # From CPAN
use Data::Dumper;               # Perl core module
#use strict;                     # Good practice
use warnings;                   # Good practice
use Irssi 20010120.0250 ();
use URI::Encode;

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
#print URLLOG time." $where $channel $lasturl\n";
#close(URLLOG);
    sendto_facebook_stream($where, $channel, $url);
#TODO send to facebook stream
}

sub get_config 
{
    local $/;
    open(FILE, $api_key);
    my $json = <FILE>;
    close(FILE);  
    my $decoded_json = decode_json( $json );
#TODO this shit does not work but php's worsk every fucking time.... so easy
#my $decoded_json->{'return_url'} = URI::Encode->new( { double_encode => 0 } )->encode($decoded_json->{'return_url'});
    return $decoded_json;
}

# @ENV{qw/WFA_API_KEY WFA_SECRET WFA_DESKTOP/} are the initial values,
# so use those if you only have one app and don't want to pass in values
# to constructor

sub sendto_facebook_stream 
{
    my($where,$channel,$url) = @_;
    my $config = get_config();
    if (!exists($config->{'token'}))
    {
#TODO implement IO::Async for login but not right now since I already have a token. 
#my $fb = Facebook::Graph->new(
#          app_id => $config->{'app_id'},
#          secret => $config->{'app_secret'},
#          postback => $config->{'return_url'}
#          );
#  my $uri = $fb->authorize
#      ->extend_permissions(qw( email publish_stream ))
#      ->set_display('popup')
#      ->uri_as_string;
#  return URI::Encode->new( { encode_reserved => 0 } )->encode($uri);

        @cmd ="curl -s \"https://graph.facebook.com/oauth/access_token?client_id=$config->{'app_id'}&client_secret=$config->{'app_secret'}&grant_type=client_credentials\"";
        print @cmd;
        print "now set your token in your config";
#        return;
#        my $response = timeout_command($timeout, @cmd);
#        print "$response" if (defined $response);

    }
    else 
    {
# exec("perl -e \"
# use Facebook::Graph;
# Facebook::Graph->new(
#         app_id => '" . $config->{'app_id'} . "',
#         secret => '" . $config->{'app_secret'} . "',  # fuck no, this ain't php 
#         postback => '" . $config->{'return_url'} . "',
#         )->access_token(\"" . $config->{'token'} . "\")->fb->add_post->set_message('" . $url . "')->publish; \" & ");

#http://search.cpan.org/~sparky/Net-Curl-Simple-0.13/lib/Net/Curl/Simple/Async.pm so many choices, which one is the right one.
        my $timeout = 10;
        my $auth_token = $config->{'token'};
        my $title = $where . ' ' . $channel;
#https://developers.facebook.com/docs/reference/api/post/
        @cmd ="curl -s -F \"access_token=$auth_token\" -F \"link=$url\" -F \"name=$title\" -F \"caption=Caption for the link\" \"https://graph.facebook.com/irclinks/feed\"";
        print @cmd;
#        return;
        my $response = timeout_command($timeout, @cmd);
        print "$response" if (defined $response);

    }
}

# a way to run commands asynchronously from perl, but will it work from irssi... 
#http://stackoverflow.com/questions/1752357/how-can-i-run-a-system-command-in-perl-asynchronously
sub timeout_command {
    my $timeout = (shift);
    my @command = @_;
    undef $@;
    my $return  = eval {
        local($SIG{ALRM}) = sub {die "timeout";};
        alarm($timeout);
        my $response;
        open(CMD, '-|', @command) || die "couldn't run @command: $!\n";
        while(<CMD>) {
            $response .= $_;
        }
        close(CMD) || die "Couldn't close execution of @command: $!\n";
        $response;
    };
    alarm(0);
    if ($@) {
        warn "@cmd failure: $@\n";
    }
    return $return;
}

#handlers 
Irssi::signal_add_last("message public", "url_public");
Irssi::signal_add_last("message private", "url_private");
#Irssi::command_bind("url", "url_cmd");
#print "loaded and ready.";



# TODO uncomment this then load script to get request permission URL, then add auth token to json config
#print sendto_facebook_stream();
