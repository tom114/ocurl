#!/usr/bin/perl

use FindBin;
use strict;
use warnings;

#Install PERL packages
my @requiredPackages = ("OAuth::Lite2::Client::UsernameAndPassword","Term::ReadLine");

my $binLoc = $FindBin::Bin;
my $defaultLib = "$binLoc/../lib/";
my $libDir = textOption("Perl library location?",$defaultLib);

if(!-d $libDir){
	die "Library path $libDir is not a valid directory!";
}

print "Using $libDir as library\n";
foreach my $pack(@requiredPackages){
	##INSTALL Config::Simple
	eval("use $pack");

	if($@){
		my $ret = option("Package $pack is not installed. Would you like to try to install it using cpanm?","y");

		if($ret eq "y"){
			my $cmd = "cpanm -L $libDir $pack";
			print "Running command: $cmd\n";
			system($cmd);
		}
	}
}

sub textOption{
	my $message = shift;
	my $default = shift;
	print "$message [$default] ";

	my $input = <>;
	chomp $input;
	my $return = $default;
	if($input ne ""){
		$return = $input;
	}

	return $return;
}

sub option{
	my $msg = shift;
	my $default = shift;
	
	if(lc($default) eq "y"){
		$msg .= " [Y,n] ";
	}
	else{
		$msg .= " [y,N] ";
	}

	print $msg;
	my $input;
	my $valid = 0;
	do{
		$input = <>;
		chomp $input;
		$input = lc($input);
		if($input eq ""){
			$input = $default;
		}

		if($input eq "y" or $input eq "n"){
			$valid = 1;
		}
		else{
			print "Invalid entry: $input\n";
		}
	}
	while(!$valid);

	return $input;
}
