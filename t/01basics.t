use strict;
use warnings;
use Test::More qw(no_plan);

BEGIN {
  package Foo;

  use Mu::Tiny;

  ro 'foo';
  ro 'bar';
  lazy baz => sub { 4 };
  lazy quux => sub { 6 };
}

my $ok = eval { Foo->new; 1 };

my $err= $@;

ok !$ok, 'new() failed';

ok +($err =~ /foo/ and $err =~ /bar/), 'both missing required attrs reported';

my $obj = Foo->new(foo => 1, bar => 2);

ok exists($obj->{foo}), 'constructor populated slot';
ok exists($obj->{bar}), 'constructor populated slot 2';
ok !exists($obj->{baz}), 'lazy builder slot unpopulated';
ok !exists($obj->{quux}), 'lazy builder slot unpopulated 2';

is $obj->foo, 1, 'constructor populated value';
is $obj->bar, 2, 'constructor populated value 2';
is $obj->baz, 4, 'lazy builder population';
is $obj->quux, 6, 'lazy builder population 2';

is $obj->{baz}, 4, 'lazy builder slot value';
is $obj->{quux}, 6, 'lazy builder slot value 2';
