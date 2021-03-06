#! /usr/bin/perl
#
# Copyright 2004 by Stefan Hornburg (Racke) <racke@linuxia.de>
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

package DataFilter::Config::AppConfig;
use strict;
use AppConfig qw(:argcount);

sub new {
	my $proto = shift;
	my $class = ref ($proto) || $proto;
	my $self = {@_};
	my %configuration;
	
	$self->{_confobj_} = new AppConfig ({CREATE => 1, GLOBAL => {ARGCOUNT => ARGCOUNT_ONE}});
	
	if ($self->{file}) {
		open (CFG, $self->{file})
			|| die qq{$0: failed to open configuration file $self->{file}: $! \n};
		$self->{_confobj_}->file (\*CFG);

		for (qw(source target custom)) {
			$configuration{$_} = {$self->{_confobj_}->varlist("^${_}_", 1)};
		}

		close (CFG);
	}

	$self->{_configuration_} = \%configuration;
	
	bless ($self, $class);
	return $self;
}

1;
