use strict;
use warnings;
use Test::More;
use Set::Product::XS qw(product);

ok defined &product, 'product() is exported';

{
    my @set = ();
    my @out; product { push @out, "@_" } @set;
    is_deeply \@out, [], 'empty list'
}

{
    my @set = ([1..3]);
    my @out; product { push @out, "@_" } @set;
    is_deeply \@out, [1..3], 'single list'
}

{
    my @set = map { [$_] } 1..5;
    my @out; product { push @out, "@_" } @set;
    is_deeply \@out, ['1 2 3 4 5'], 'all lists with single element';
}

{
    my @set = ([1,2], [3,4,5], []);
    my @out; product { push @out, "@_" } @set;
    is_deeply \@out, [], 'non-empty lists with empty list'
}

{
    my @set = ([1,2], [3,4,5]);
    my @out; product { push @out, "@_" } @set;
    is_deeply \@out, ['1 3', '1 4', '1 5', '2 3', '2 4', '2 5'],
        'non-empty lists';
}

{
    my @set = (1, 2, 3);
    my @out; eval { product { push @out, "@_" } @set };
    like $@, qr/^Not an array reference/, 'bad list';
}

done_testing;
