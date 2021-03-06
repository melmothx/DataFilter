#
# SQL.pm - base class for RDBMS
#
# Copyright 2007-2010 by Stefan Hornburg (Racke) <racke@linuxia.de>
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

package DataFilter::Source::SQL;
use strict;
use DBIx::Easy;

sub tables {
	my ($self) = @_;

	return $self->{_dbif_}->tables();
}

sub purge {
	my ($self, $table) = @_;

	$self->{_dbif_}->delete($table);
}

sub serial {
	my ($self, $table, $sequence) = @_;

	$self->{_dbif_}->serial($table, $sequence);
}

sub delete {
	my ($self, $table, $conditions) = @_;

	$self->{_dbif_}->delete($table, $conditions);
}
	
1;
	
