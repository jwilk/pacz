#!/usr/bin/env perl

# Copyright © 2021-2024 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

no lib '.';  # CVE-2016-1238

use strict;
use warnings;
use v5.14;

use B::Deparse ();
use English qw(-no_match_vars);
use FindBin ();
use threads ();

use Test::More;

use IO::Socket::SSL;

do "$FindBin::Bin/../pacz" or die;
my %host2ca;
while (my ($name, $glob) = each %carrier::) {
    $name =~ /\A_/ and next;
    my $code = \&{$glob};
    state $deparse = B::Deparse->new;
    my $body = $deparse->coderef2text($code);
    my $ca = undef;
    while ($body =~ m{\buseca[(]'([\w-]+)'[)]|\bhttps://([^/]+)}g) {
        if (defined $1) {
            $ca = $1;
        } else {
            $host2ca{$2} = $ca;
        }
    }
}
my $var = 'PACZ_NETWORK_TESTING';
if ($ENV{$var}) {
    plan tests => scalar keys %host2ca;
} else {
    plan skip_all => "set $var=1 to enable tests that exercise network";
}
my $cadir = '/usr/share/ca-certificates/mozilla';
sub check_host
{
    my ($host, $cafile) = @_;
    my $socket = IO::Socket::SSL->new(
        PeerHost => $host,
        PeerPort => 'https',
        SSL_verify_mode => IO::Socket::SSL::SSL_VERIFY_PEER,
        SSL_ca_file => $cafile,
    );
    if ($socket) {
        $socket->close();
        return 1;
    } else {
        return (undef, $IO::Socket::SSL::SSL_ERROR);
    }
}
my %host2thread;
for my $host (sort keys %host2ca) {
    my $ca = $host2ca{$host};
    if (not defined $ca) {
        next;
    }
    my $cafile = "$cadir/$ca.crt";
    stat $cafile or die "$cafile: $ERRNO";
    $host2thread{$host} = threads->create(
        {context => 'list'},
        \&check_host, $host, $cafile
    );
}
for my $host (sort keys %host2ca) {
    my $ca = $host2ca{$host};
    if (not defined $ca) {
        fail("$host uses no CA");
        next;
    }
    my $thread = $host2thread{$host};
    my ($ok, $error) = $thread->join();
    ok($ok, "$host uses $ca");
    if (not $ok) {
        $error //= 'unknown error';
        diag("$host: $error");
    }
}

# vim:ts=4 sts=4 sw=4 et
