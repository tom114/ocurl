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
my $token_url="http://localhost:8080/api/oauth/token";
my $quit=undef;
my $token = undef;
my $help = undef;
my $verbose = 0;
my $readpw = 0;
my $file;

Getopt::Long::Configure ('bundling');
GetOptions(
	'c|client=s'=>\$client_id,
	's|secret=s'=>\$client_secret,
	'u|user=s'=>\$username,
	'p|password=s'=>\$password,
	'r|rp'=>\$readpw,
	't|tokenURL=s'=>\$token_url,
	'k|token=s'=>\$token,
	'f|file=s'=>\$file,
	'v|verbose'=>\$verbose,
	'q|quit'=>\$quit,
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
-r|--rp: read password in application
-t|--tokenURL: token_url (default $token_url)
-k|--token: OAuth2 token to use (optional)
-f|--file: File to use for curl inputs
-q|--quit: Enter q to quit instead of blank line
-h|--help: Display this help message
USAGE
	exit(0);
}

if($file){
	open(FILE, $file) or die "Cannot read file: $!";
}

my $term = Term::ReadLine->new('OAuth2 Curl manager');

if($readpw){
	$password = $term->readline("Enter Password :");
}

if(!defined $token){
	$token = getToken($client_id,$client_secret,$username,$password,$token_url);
}
else{
	print "Using token: $token\n";
}

my $cmd_base = setHeader($token);
print "Enter URL or any other CURL parameters:\n";

if($token_url =~ /^(.*)\/oauth\/token/){
	$term->addhistory($1);
}
else{
	$term->addhistory("http://localhost:8080");
}

my $prompt = "curl ";
while(1){
	my $line;
	if(!$file){
		$line = $term->readline($prompt);
	}
	else{
		$line = <FILE>;
		chomp $line;
	}

	if($line){
		if('q' eq lc $line || 'exit' eq lc $line){
			last;
		}
		elsif('t' eq lc $line || 'token' eq lc $line){
			$token = getToken($client_id,$client_secret,$username,$password,$token_url);
			$cmd_base = setHeader($token);
		}
		else{
			my $cmd = "$cmd_base $line";
			system($cmd);
			print "\n";
		}
	}
	else{
		if($quit){
			print "Type 'q' to exit\n";
		}
		else{
			last;
		}
	}
}

print "\n";

sub setHeader{
	my $token = shift;

	my $header = "Authorization: Bearer $token";
	my $cmd_base = "curl -H \"$header\" ";

	return $cmd_base;
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
		print $client->last_response->as_string if $verbose;
                exit(1);
        }
        my $tokenstr = $token->access_token;
	
	print "Got token: $tokenstr\n";

	if(defined $token->refresh_token){
		print "Refresh token: ".$token->refresh_token."\n";
	}
        
        return $tokenstr;
	
}
