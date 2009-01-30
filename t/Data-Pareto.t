use Test::More tests => 16;

use Data::Pareto;

# a helper method to calculate Pareto set from given vectors
sub _p_obj {
	my $num = shift;
	my $opts = { };
	$opts = shift if @_ && ref($_[0]) eq 'HASH';
	my $p = Data::Pareto->new({ cols => [ 0..$num-1 ], %$opts });
	$p->add(@_) if @_;
	return $p
}
sub _p {
	_p_obj(@_)->get_pareto_ref();
}

# same as above, assuming duplicates are allowed
sub _p_dup {
	my $num = shift;
	my $opts = { };
	$opts = shift if @_ && ref($_[0]) eq 'HASH';
	return _p($num, { duplicates => 1, %$opts }, @_);
}

##### call context tests
{
	# list context
	my @arr = _p_obj(2, [1,2], [2,1])->get_pareto();
	my $arr = _p_obj(2, [1,2], [2,1])->get_pareto();
	is_deeply(
		\@arr,
		[ [1,2], [2,1] ]
	);
	is($arr, 2);
	
	# scalar context
	my   $scl = _p_obj(2, [1,2], [2,1])->get_pareto_ref();
	my (@scl) = _p_obj(2, [1,2], [2,1])->get_pareto_ref();
	is_deeply(
		$scl,
		[ [1,2], [2,1] ]
	);
	is_deeply(
		\@scl,
		[
			[ [1,2], [2,1] ]
		]
	);
	
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
