#!/usr/bin/env perl
# web0 2011-12-1 according to ISO 8601, because the standard way we use dates is just stupid
use strict;
use warnings;
use encoding 'utf8';
require Encode;
binmode(STDOUT, ":utf8");


# POE Love
use POE;
use Data::Dumper;
use POE::Component::IRC::State;
use POE::Component::IRC::Plugin::AutoJoin;
use POE::Component::IRC::Plugin::Connector;
# POE Needed.. and I need it because I love it dearly
use IO::Prompt;

my @downchars = ("\x{0316}","\x{0317}","\x{0318}","\x{0319}","\x{031c}","\x{031d}","\x{031e}","\x{031f}","\x{0320}","\x{0324}","\x{0325}","\x{0326}","\x{0329}","\x{032a}","\x{032b}","\x{032c}","\x{032d}","\x{032e}","\x{032f}","\x{0330}","\x{0331}","\x{0332}","\x{0333}","\x{0339}","\x{033a}","\x{033b}","\x{033c}","\x{0345}","\x{0347}","\x{0348}","\x{0349}","\x{034d}","\x{034e}","\x{0353}","\x{0354}","\x{0355}","\x{0356}","\x{0359}","\x{035a}",);
my @upchars = ("\x{030d}","\x{030e}","\x{0304}","\x{0305}","\x{033f}","\x{0311}","\x{0306}","\x{0310}","\x{0352}","\x{0357}","\x{0351}","\x{0307}","\x{0308}","\x{030a}","\x{0342}","\x{0343}","\x{0344}","\x{034a}","\x{034b}","\x{034c}","\x{0303}","\x{0302}","\x{030c}","\x{0350}","\x{0300}","\x{0301}","\x{030b}","\x{030f}","\x{0312}","\x{0313}","\x{0314}","\x{033d}","\x{0309}","\x{0363}","\x{0364}","\x{0365}","\x{0366}","\x{0367}","\x{0368}","\x{0369}","\x{036a}","\x{036b}","\x{036c}","\x{036d}","\x{036e}","\x{036f}","\x{033e}","\x{035b}","\x{0346}",);

my ($channel, $nick, $server, $debuglevel);

$channel = "#crackhouse";
$nick = "kupkakke";
$server = "irc.synirc.net";
print "Trying to conect to $server as $nick";

my $irc         = POE::Component::IRC::State->spawn(
        Nick    => $nick,
        Server  => $server,
);

POE::Session->create(
        package_states => [ main => [qw(_start irc_public irc_001 irc_msg irc_join)], ],
);


$poe_kernel->run();

sub _start {
        $irc->plugin_add( 'Autojoin', POE::Component::IRC::Plugin::AutoJoin->new( Channels => [$channel] ) );
        $irc->plugin_add( 'Connector', POE::Component::IRC::Plugin::Connector->new() );
        $irc->yield( register => 'all' );
        $irc->yield( connect  => {} );
}

sub irc_001 {
    $irc->yield( join => $channel );
}

sub irc_public {
        # We saw a message! Let's pack all the info about it into convenience little variables and put bows on them
        my(     $kernel,$sender,$who, $where,$msg ) =
        @_[ KERNEL, SENDER, ARG0, ARG1,  ARG2 ];

        # Who the fuck said that?!?
        my $nick = ( split /!/, $who )[0];
        # Where the hell did that just come from?!
        my $channel = $where->[0];

        # So we have what was said saved as $msg, but lets split them words up into an array, hurray
        my @args = split /\s+/, $msg; # Splittin on whitespace

        # Let's take that array and see if the first word was a command, we're going to call it one either way
        my $command = shift @args;

    if ($command eq '!annoying') {
                my $zalgomsg = "weeeeeeeeeeee";
                for(@downchars){
                        my $decode = Encode::decode_utf8($_);
                        for(my $i=0;$i<30;$i++){
                                $zalgomsg = $zalgomsg . $_;
                        }
                }
                $zalgomsg = $zalgomsg . "eeeeee";
                $kernel->post( $irc => privmsg => $channel => "$zalgomsg" );
                $zalgomsg = "  weeeeee";
                for(@upchars){
                        my $decode = Encode::decode_utf8($_);
                        for(my $i=0;$i<30;$i++){
                                $zalgomsg = $zalgomsg . $_;
                        }
                }
                $zalgomsg = $zalgomsg . "eeeeeeeeee";
                $kernel->post( $irc => privmsg => $channel => "$zalgomsg" );
        }
        if ($command =~ /^!fuck/){
                my $size = shift @args || '5';
                my $superfuck = 0;
                if($size eq 'you'){
                        $size = 44;
                        $superfuck = shift @args || 40;
                }
                for(0..$superfuck){
                        my $zal = "IM A B";
                        $zal = $zal . zal('down',$size);
                        $zal = $zal . "IG F";
                        $zal = $zal . zal('up',$size);
                        $zal = $zal . "A";
                        $zal = $zal . zal('down',$size);
                        $zal = $zal . "T";
                        $zal = $zal . zal('up',$size);
                        $zal = $zal . " DI";
                        $zal = $zal . zal('down',$size);
                        $zal = $zal . "C";
                        $zal = $zal . zal('up',$size);
                        $zal = $zal . "K";
                        $kernel->post( $irc => privmsg => $channel => "$zal" );
                        $size++;
                }
        }
    if ($command eq '!topic') {
                my $zal = "                             ";
                $zal = $zal . zal('down',);
                $kernel->post( $irc => topic => $channel => "$zal" );
        }
    if ($command =~ /^!testing/) {
                my $argtest = shift @args || '';
                $kernel->post( $irc => topic => $channel => "Suck it - $argtest" );
        }
}

sub irc_msg {

}

sub irc_join {

}

sub zal{
        my $size = 20;
        my $direction = shift;
        if($_[0]){$size = $_[0]}
        my @chars;
        if($direction eq 'up'){
                @chars = @upchars;
        }
        elsif($direction eq 'down'){
                @chars = @downchars;
        }
        for(my $i=0;$size > scalar(@chars);$i++){
                push(@chars,$chars[$i]);
                if($i>=scalar(@chars)){
                        $i = 0;
                }
        }
        my $zalgomsg;
        for(my $i=0;$i<$size;$i++){
                my $decode = Encode::decode_utf8($chars[$i]);
                $zalgomsg = $zalgomsg . $decode;
        }
        return $zalgomsg;
}
