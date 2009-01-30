package Data::Pareto;

use 5.006000;
use strict;
use warnings;

our $VERSION = '0.01';

=head1 NAME

Data::Pareto - Selecting Pareto sets in Perl

=head1 SYNOPSIS

  use Data::Pareto;
  
  # only first and third columns are used in comparison
  my $set = new Data::Pareto(cols => [0, 2]);
  $set->add(
      [ 5, "pareto", 10, 11 ],
      [ 5, "dominated", 11, 9 ],
      [ 4, "pareto2", 12, 12 ] 
  );

  # this returns [ [ 5, "pareto", 10, 11 ], [ 4, "pareto2", 12, 12 ] ]
  $set->get_pareto;     

=head1 DESCRIPTION

This simple module makes calculation of Pareto set. Given a set of vectors
(i.e. arrays of simple scalars), Pareto set is all the vectors from the given
set which are not dominated by any other vector of the set. A vector C<X> is
said to be dominated by C<Y>, iff C<< X[i] >= Y[i] >> for all C<i> and
C<< X[i] > Y[i] >> for at least one C<i>.

Pareto sets play an important role in multiobjective optimization, where
each non-dominated (i.e. Pareto) vector describes objectives value of
"optimal" solution to the given problem.

This module allows occurance of duplicates in the set - this makes it
rather a bag than a set, but is useful in practice (e.g. when we want to
preserve two solutions giving the same objectives value, but structurally
different). This assumption influences dominance definition given above:
two duplicates never dominate each other and hence can be present in the Pareto
set. This is controlled by C<duplicates> option passed to L<new>: if set to
C<true> value, duplicates are allowed in Pareto set; otherwise, only the first
element of the subset of duplicated vectors is preserved in Pareto set.

=head2 EXPORT

None.

=head2 METHODS

The vectors are passed around as refs to arrays of consecutive values. This
means you shouldn't mess with them after passing to C<add> method.

=over

=cut

=item new

Creates a new object for calculating Pareto set.

The argument passed is a hashref with options the recognized options are:

=over

=item * C<cols>

Arrayref containing column numbers which should be used for determining
domination and duplication. Column numbers are C<0>-based array indexes to
data vectors.

Only values at those positions will be ever compared between vectors.
Any other data in the vectors may be present and is not used in any way.

At least one column number should be passed, for obvious reasons.

=item * C<duplicates>

If set to C<true> value, duplicated vectors are all put in Pareto set (if they
are Pareto, of course). If set to C<false>, duplicates of already Pareto
vector are discarded.

=back

=cut

sub new {
	my ($class, $attrs) = @_;
	my $self = { %$attrs };
	$self->{pareto} = [ ];
	$self->{vectorStatus} = { };
	return bless $self, $class;
}

=item add

Tests passed as arguments vectors and adds the non-dominated ones to the
Pareto set.

=cut

sub add {	
	my $self = shift;
	$self->_update_pareto($_) for @_;
}

=item get_pareto

Returns the current content of Pareto set as a list of vectors.

=cut

sub get_pareto {
	my ($self) = @_;
	return (@{$self->{pareto}});
}

=item get_pareto_ref

Returns the current content of Pareto set as a ref to array with vectors.
The return value references the original array, so treat it as read-only! 

=cut

sub get_pareto_ref {
	my ($self) = @_;
	return $self->{pareto};	
}

sub _update_pareto {
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
			if ($self->is_dominated($o, $NV)) {
				$self->_ban_vector($o);
			} else {
				push @newP, $o;
			}
		} else {
			# stop processing with unchanged Pareto set if the new vector is dominated by the current one
			return if $self->is_dominated($NV, $o);
			
			# mark new vector as "sure Pareto" only if it dominates the current vector
			if ($self->is_dominated($o, $NV)) {
				$surePareto = 1;
				# ...and hence we don't preserve the dominated current vector
				$self->_ban_vector($o);
				next;
			}
			
			# otherwise, the current vector is for sure Pareto still, so preserve it
			push @newP, $o;
		}
	}

	push @newP, $NV;
	$self->_mark_vector($NV);
	$self->{pareto} = \@newP;
}

sub is_dominated {
	my ($self, $dominated, $by) = @_;
	for my $c (@{$self->{cols}}) {
		return 0 if $dominated->[$c] < $by->[$c];
	}

	1;
}

sub _vector_key {
	my ($self, $v) = @_;
	my @cols = ( );
	for my $c (@{$self->{cols}}) {
		push @cols, $v->[$c];
	}
	
	return join ';', @cols;
}

sub hasDuplicates {
	my ($self, $v) = @_;
	my $key = $self->_vector_key($v);
	return (exists $self->{vectorStatus}{$key} && $self->{vectorStatus}{$key} > 0);
}

sub _ban_vector {
	my ($self, $v) = @_;
	my $key = $self->_vector_key($v);
	$self->{vectorStatus}{$key} = 0;
}

sub _mark_vector {
	my ($self, $v) = @_;
	my $key = $self->_vector_key($v);
	$self->{vectorStatus}{$key} = 1;
}

=back

=cut

1;
__END__

=head1 TODO

For large data sets calculations become time-intensive. There are a couple
of techniques which might be applied to improve the performance:

=over

=item * defer the phase of removing vectors dominated by newly added vectors
to L<get_pareto> call; this results in smaller number of arrays rewritings.

=item * split the set of vectors being added into smaller subsets, calculate
Pareto sets for such subsets, and then apply insertion of resulting Pareto
subsets to the main set; this results in smaller number of useless tries of
adding dominated vectors into the set.

=back

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
