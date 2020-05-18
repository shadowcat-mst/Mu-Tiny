package Mu::Tiny::Object;

use strict;
use warnings;
use Carp ();

sub __Mu__Tiny__attrs { () }

my %spec;

sub new {
  my $class = shift;
  my ($attr, $req) = @{$spec{$class} ||= do {
    my %attrs = $class->__Mu__Tiny__attrs;
    [[ sort keys %attrs ], [ sort grep $attrs{$_}, keys %attrs ]];
  }};
  my %args = @_ ? @_ > 1 ? @_ : %{$_[0]} : ();
  my @missing = grep !exists($args{$_}), @$req;
  Carp::croak "Missing required attributes: ".join(', ', @missing) if @missing;
  my %new = map { exists($args{$_}) ? ($_ => $args{$_}) : () } @$attr;
  bless(\%new, ref($class) || $class);
}

1;
