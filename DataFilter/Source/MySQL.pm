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

package DataFilter::Source::MySQL;
use strict;
use DBIx::Easy;

sub new {
	my $proto = shift;
	my $class = ref ($proto) || $proto;
	my $self = {@_};

	bless ($self, $class);

	$self->{_dbif_} = new DBIx::Easy ('mysql', $self->{name});
	
	return $self;
}

sub enum_records {
	my ($self, $table, $limit) = @_;
	my $sth;
	my $limitstr = $limit ? " limit $limit" : '';
	
	unless ($sth = $self->{_enums_}->{$table}) {
		$sth = $self->{_dbif_}->process ("select * from ${table}$limitstr");
		$self->{_enums_}->{$table} = $sth;
	}

	return $sth->fetchrow_hashref();
}

sub hash_records {
	my ($self, $pref) = @_;

	$self->{_dbif_}->makemap($pref->{table}, $pref->{key}, $pref->{value});
}

sub record {
	my ($self, $table, $key) = @_;
	my ($tblinfo_ref, @keys, $pri_name, $sth, $href);
	
	$tblinfo_ref = $self->{_dbif_}->describe_table($table);
	if (@keys = grep {$_->{Key} eq 'PRI'} @{$tblinfo_ref->{columns}}) {
		$pri_name = $keys[0]->{Field};
	} else {
		die "$0: no key found for $table\n";
	}
	
	$sth = $self->{_dbif_}->process("select * from $table where $pri_name = '$key'");
	if ($sth->rows()) {
		$href = $sth->fetchrow_hashref();
		$sth->finish();
		return $href;
	}

}

1;
