#! /usr/bin/perl
#
# Copyright 2005,2006,2007,2008 by Stefan Hornburg (Racke) <racke@linuxia.de>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Free
# Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA  02111-1307  USA.

package DataFilter::Magic;
use strict;
use warnings;

use File::MMagic;

sub new {
	my $proto = shift;
	my $class = ref ($proto) || $proto;
	my $self = {};

	$self->{ft} = new File::MMagic();

	# add magic entries
	# - DBase 3 data file
	$self->{ft}->addMagicEntry(join("\t", 0, 'byte', '', '0x03', 'application/x-dbf'));
	# - self extracting ZIP archives
	$self->{ft}->addMagicEntry(join("\t", 0, 'string', 'MZ', '', 'application/ms-dos-executable'));

	bless ($self, $class);
}

sub type {
	my ($self, $filename, $typeref, $parmsref) = @_;
	my ($ft_type, $data);

	$data = $self->slurp($filename);

	unless (defined($data)) {
		return;
	}
	
	$ft_type = $self->{ft}->checktype_contents($data);
	
	if (ref($typeref) eq 'SCALAR') {
		$$typeref = $ft_type;
	}

	# handle encodings first (second alternative is a big kludge)
	if ($ft_type eq 'application/x-zip'
	   || $ft_type eq 'application/ms-dos-executable') {
		return 'ZIP';
	}

	# database files
	if ($ft_type eq 'application/x-dbf') {
		return 'XBase';
	}
	
	if ($ft_type eq 'application/msword'
		|| $ft_type eq 'application/octet-stream') {
		# most likely XLS
		return 'XLS';
	}

	if ($ft_type eq 'text/plain') {
		my ($tabs, $commas, $colons);
		
		# TAB or CSV style
		open (FILE, $filename)
			|| die "$0: failed to open $filename\n";

		while (<FILE>) {
			$tabs = tr/\t/\t/;
			$commas = tr/,/,/;
			$colons = tr/;/;/;
			last;
		}

		close (FILE);
		
		if ($tabs) {
			return 'TAB';
		} elsif ($commas) {
			return 'CSV';
		} elsif ($colons) {
			if (ref($parmsref) eq 'HASH') {
				$parmsref->{delimiter} = ';';
			}
			return 'CSV';
		}
	}

	return;
}

sub slurp {
	my ($self, $filename) = @_;
	my $content;

	unless (open (FH, $filename)) {
		return;
	}
	
	local $/;
	$content = <FH>;
	close (FH);

	return $content;
}

1;
