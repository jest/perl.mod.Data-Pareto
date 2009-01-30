use Test::More 'no_plan';

use Data::Pareto;

# a helper method to calculate Pareto set from given vectors
sub _p {
	my $num = shift;
	my $opts = { };
	$opts = shift if @_ && ref($_[0]) eq 'HASH';
	my $p = new Data::Pareto({ cols => [ 0..$num-1 ], %$opts });
	$p->addAll([ @_ ]) if @_;
	return $p->getPareto();
}

# same as above, assuming duplicates are allowed
sub _p_dup {
	my $num = shift;
	return _p($num, { duplicates => 1 }, @_);
}

##### simple, <1 element sets

is_deeply (
	_p(2),
	[ ]
);

is_deeply (
	_p(2, [1,2]),
	[ [1,2] ]
);

is_deeply (
	_p(2, [1,2], [1,2]),
	[ [1,2] ]
);

is_deeply (
	_p_dup(2, [1,2], [1,2]),
	[ [1,2], [1,2] ]
);

##### simple, 2 element sets of different column values

is_deeply (
	_p(2, [1,2], [1,3]),
	[ [1,2] ]
);

is_deeply (
	_p(2, [1,2], [2,2]),
	[ [1,2] ]
);

is_deeply (
	_p(2, [1,3], [1,2]),
	[ [1,2] ]
);

is_deeply (
	_p(2, [2,2], [1,2]),
	[ [1,2] ]
);

##### adding element, removing element, tried to add again; in different confs.

is_deeply (
	_p(2, [2,2], [1,2], [2,2]),
	[ [1, 2] ]
);

is_deeply (
	_p_dup(2, [2,2], [2,2], [1,2]),
	[ [1,2] ]
);

is_deeply (
	_p_dup(2, [1,2], [2,2], [1,2], [2,2]),
	[ [1,2], [1,2] ]
);

##### many pareto vectors

is_deeply (
	_p(3, [1,2,9], [2,2,8], [3,3,7], [4,3,6], [5,7,5]),
	[ [1,2,9], [2,2,8], [3,3,7], [4,3,6], [5,7,5] ]
);
