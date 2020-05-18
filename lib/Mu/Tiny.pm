package Mu::Tiny;

use strict;
use warnings;
use Carp ();
use Mu::Tiny::Object;

sub import {
  my $targ = caller;
  no strict 'refs';
  @$_ or @$_ = ('Mu::Tiny::Object') for my $isa = \@{"${targ}::ISA"};
  my $attrs;
  *{"${targ}::extends"} = sub {
    Carp::croak "Can't call extends after attributes" if $attrs;
    Carp::croak "No superclass list passed to extends" unless @_;
    @$isa = @_;
  };
  *{"${targ}::ro"} = sub {
    Carp::croak "No name passed to ro" unless my $name = shift;
    Carp::croak "Extra args passed to ro" if @_;
    ($attrs||=_setup_attrs($targ))->{$name} = 1;
    *{"${targ}::${name}"} = sub { $_[0]->{$name} };
  };
  *{"${targ}::lazy"} = sub {
    Carp::croak "No name passed to lazy" unless my $name = shift;
    Carp::croak "No builder passed to lazy" unless my $builder = shift;
    Carp::croak "Extra args passed to lazy" if @_;
    ($attrs||=_setup_attrs($targ))->{$name} = 0;
    if (ref($builder) eq 'CODE') {
      my $method = "_build_${name}";
      *{"${targ}::${method}"} = $builder;
      $builder = $method;
    } elsif (ref($builder)) {
      Carp::croak "Builder passed to lazy must be name or code, not ${builder}";
    }
    *{"${targ}::${name}"} = sub {
      exists $_[0]->{$name}
        ? $_[0]->{name}
        : $_[0]->{name} = $_[0]->$builder
    };
  };
}

my $ATTRS = '__Mu__Tiny__attrs';

sub _setup_attrs {
  my ($targ) = @_;
  my $attrs = {};
  my $orig = $targ->can($ATTRS);
  Carp::croak "Can't find Mu::Tiny attrs method ${ATTRS} in ${targ}"
    unless $orig;
  no strict 'refs';
  *{"${targ}::${ATTRS}"} = sub { $_[0]->$orig, %$attrs };
  $attrs;
}

1;
