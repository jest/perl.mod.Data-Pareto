package Data::Pareto;

use 5.006000;
use strict;
use warnings;

our $VERSION = '0.01';

sub new {
	my ($class, $attrs) = @_;
	my $self = { %$attrs };
	$self->{pareto} = [ ];
	$self->{vectorStatus} = { };
	return bless $self, $class;
}

sub add {
	my ($self, $v) = @_;
	$self->updatePareto($v);	
}

sub addAll {	
	my ($self, $allV) = @_;
	$self->updatePareto($_) for @$allV;
}

sub getPareto {
	my ($self) = @_;
	return $self->{pareto};
}

sub updatePareto {
	my ($self, $NV) = @_;
	
	# check if we already have a duplicate?
	if ($self->hasDuplicates($NV)) {
		# ...then it depends on the policy
		if ($self->{duplicates}) {
			# add the duplicated vector to the pareto set
			push @{$self->{pareto}}, $NV;
		} else {
			# simply disgard the new vector
		}
		return;
	}
	
	my @newP = ( );
	my $surePareto = 0;
	
	# check with every vector considered pareto so far
	for my $o (@{$self->{pareto}}) {
		if ($surePareto) {
			# preserve the current vector only if it is not dominated by new (now Pareto) vector
			if ($self->isDominated($o, $NV)) {
				$self->banVector($o);
			} else {
				push @newP, $o;
			}
		} else {
			# stop processing with unchanged Pareto set if the new vector is dominated by the current one
			return if $self->isDominated($NV, $o);
			
			# mark new vector as "sure Pareto" only if it dominates the current vector
			if ($self->isDominated($o, $NV)) {
				$surePareto = 1;
				# ...and hence we don't preserve the dominated current vector
				$self->banVector($o);
				next;
			}
			
			# otherwise, the current vector is for sure Pareto still, so preserve it
			push @newP, $o;
		}
	}

	push @newP, $NV;
	$self->markVector($NV);
	$self->{pareto} = \@newP;
}

sub isDominated {
	my ($self, $dominated, $by) = @_;
	for my $c (@{$self->{cols}}) {
		return 0 if $dominated->[$c] < $by->[$c];
	}

	1;
}

sub vectorKey {
	my ($self, $v) = @_;
	my @cols = ( );
	for my $c (@{$self->{cols}}) {
		push @cols, $v->[$c];
	}
	
	return join ';', @cols;
}

sub hasDuplicates {
	my ($self, $v) = @_;
	my $key = $self->vectorKey($v);
	return (exists $self->{vectorStatus}{$key} && $self->{vectorStatus}{$key} > 0);
}

sub banVector {
	my ($self, $v) = @_;
	my $key = $self->vectorKey($v);
	$self->{vectorStatus}{$key} = 0;
}

sub markVector {
	my ($self, $v) = @_;
	my $key = $self->vectorKey($v);
	$self->{vectorStatus}{$key} = 1;
}

1;
__END__

=head1 NAME

Data::Pareto - Selecting Pareto sets in Perl

=head1 SYNOPSIS

  use Data::Pareto;
  my $set = new Data::Pareto(cols => [0, 2]);
  $set->add_all([
      [ 5, "pareto", 10, 11 ],
      [ 5, "dominated", 11, 9 ],
      [ 4, "pareto2", 12, 12 ] 
  ]);
  
  # returns [ [ 5, "pareto", 10, 11 ], [ 4, "pareto2", 12, 12 ] ]
  $set->get_pareto;     

=head1 DESCRIPTION

This simple module makes calculation of Pareto set. Given a set of vectors
(i.e. arrays of simple scalars), Pareto set is all the vectors from the given
set which are not dominated by any other vector of the set. A vector C<X> is
said to be dominated by C<Y>, iff C<< X[i] >= Y[i] >> for all C<i> and C<X[i] < Y[i]> for
at least one C<i>.

Pareto sets play an important role in multiobjective optimization, where
each non-dominated (i.e. Pareto) vector describes objectives value of
"optimal" solution to the given problem.

=head2 EXPORT

None.

=head1 SEE ALSO

TODO

=head1 AUTHOR

Przemyslaw Wesolek, <jest@go.art.pl>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Przemyslaw Wesolek

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
