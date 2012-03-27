#!/usr/bin/perl

############################################################################
##
## check_imap_mailbox
##
## Checks the given mailbox for new mails and returns
## CRITICAL if new email has arrived.
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
##
############################################################################

use strict;
use warnings;
use Mail::IMAPClient;
use Getopt::Long;

## Print Usage if not all parameters are supplied
sub Usage() 
{
  print "\nUsage: check_imap_mailbox [PARAMETERS]

Parameters:
  --host=[HOSTNAME]      : Name or IP address of IMAP server
  --user=[USERNAME]      : Username to connect with
  --pass=[PASSWORD]      : Password to connect with
  --folder=[IMAP FOLDER] : The IMAP folder to check\n\n";
}

## Initialize the options
my $options = {
                'host'   => '',
                'user'   => '',
                'pass' 	 => '',
				'folder' => '',
              };

## Get the options
GetOptions ( $options, "host=s", "user=s", "pass=s", "folder=s" );

## Check if all parameters are supplied. Print usage if not
foreach (keys %{$options})
{
  if ( $options->{$_} eq '' )
  {
    print "\nError: Parameter missing --$_\n";
    Usage();
    exit(1);
  }
}


## Returns an unconnected Mail::IMAPClient object:
my $imap = Mail::IMAPClient->new;       
        
## Connect to server
$imap = Mail::IMAPClient->new (  
				Server  => $options->{host},
                User    => $options->{user},
                Password=> $options->{pass},
                Clear   => 5,   # Unnecessary since '5' is the default
        		) or die "Cannot connect to $options->{host} as $options->{user}: $@";


## Check if folder exists
if ( ! $imap->exists($options->{folder}) )
{
   print "CRIT: folder $options->{folder} doesn't exists";
   exit 2;
}

## Read the unseen messages in folder
my $unseen = $imap->unseen_count($options->{folder}) || "0";

## Now check the results
if ( $unseen == 0 )
{
   print "OK: $unseen unread messages";
   exit 0;
}
else
{
   print "CRIT: $unseen unread messages in $options->{folder}";
   exit 2;
}

