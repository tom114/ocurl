#!/usr/bin/perl

use FindBin;
use lib $FindBin::Bin."/lib/lib/perl5/";
use OAuth::Lite2::Client::UsernameAndPassword;
use Term::ReadLine;
use Getopt::Long;
use strict;
use warnings;

my $client_id="testClient";
my $client_secret="testClientSecret";
my $username="admin";
my $password="password1";
my $token_url="http://localhost:8080/oauth/token";
my $token = undef;
my $help = undef;

Getopt::Long::Configure ('bundling');
GetOptions(
	'c|client=s'=>\$client_id,
	's|secret=s'=>\$client_secret,
	'u|user=s'=>\$username,
	'p|password=s'=>\$password,
	't|tokenURL=s'=>\$token_url,
	'k|token=s'=>\$token,
	'h|help'=>\$help
);

if($help){
	print <<USAGE;
ocurl.pl - OAuth2 curl using Username/Password grant
Arguments:
-c|--client: client_id (default $client_id)
-s|--secret: client_secret (default $client_secret)
-u|--user: username (default $username)
-p|--password: password (default $password)
-t|--tokenURL: token_url (default $token_url)
-k|--token: OAuth2 token to use (optional)
-h|--help: Display this help message
USAGE
	exit(0);
}

if(!defined $token){
	$token = getToken($client_id,$client_secret,$username,$password,$token_url);
	print "Got token: $token\n";
}
else{
	print "Using token: $token\n";
}

my $header = "Authorization: Bearer $token";
print "Enter URL or any other CURL parameters:\n";

my $cmd_base = "curl -H \"$header\" ";
my $term = Term::ReadLine->new('Simple Perl calc');
my $prompt = "curl ";
while(my $line = $term->readline($prompt)){
	if('q' eq lc $line || 'exit' eq lc $line){
		last;
	}
	my $cmd = "$cmd_base $line";
	system($cmd);
}

sub getToken{
	my $client_id=shift;
	my $client_secret = shift;
	my $username = shift;
	my $password = shift;
	my $token_url=shift;
	my $client = OAuth::Lite2::Client::UsernameAndPassword->new(
		id=>$client_id,
		secret=>$client_secret,
		access_token_uri=>$token_url
	);

	my $token = $client->get_access_token(username=>$username,password=>$password);

	if(!defined $token){
                print "Couldn't get OAuth token: " . $client->last_response->status_line . "\n";
                exit(1);
        }
        my $tokenstr = $token->access_token;
        
        return $tokenstr;
	
}
