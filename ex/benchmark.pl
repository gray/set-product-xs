#!/usr/bin/env perl
use strict;
use warnings;

use Algorithm::Loops qw(NestedLoops);
use Benchmark::Dumb qw(:all);
use List::Gen ();
use Math::Cartesian::Product 1.009 ();
use Set::CrossProduct;
use Set::Product::PP ();
use Set::Product::XS ();
use Set::Scalar;

my @set = (
    [qw(one two three four)],
    [qw(a b c d e)],
    [qw(foo bar blah)],
    [1..5], [1..3], [1..4]
);

cmpthese 0, {
    'Set::Crossproduct' => sub {
        my $it = Set::CrossProduct->new(\@set);
        while (my @s = $it->get) {
            my $str = "@s";
        }
    },
    'List::Gen' => sub {
        my $it = List::Gen::cartesian { @_ } @set;
        while (my @s = $it->next) {
            my $str = "@s";
        }
    },
    'Set::Scalar' => sub {
        my $it = Set::Scalar->cartesian_product_iterator(
            map { Set::Scalar->new(@$_) } @set
        );
        while (my @s = $it->()) {
            my $str = "@s";
        }
    },
    'Algorithm::Loops' => sub {
        NestedLoops(\@set, sub {
            my $str = "@_";
        });
    },
    'Math::Cartesian::Product' => sub {
        Math::Cartesian::Product::cartesian {
            my $str = "@_";
        } @set;
    },
    'Set::Product::PP' => sub {
        Set::Product::PP::product {
            my $str = "@_";
        } @set;
    },
    'Set::Product::XS' => sub {
        Set::Product::XS::product {
            my $str = "@_";
        } @set;
    },
};

__END__

=head1 BENCHMARKS

                                    Rate Set::Crossproduct   List::Gen Algorithm::Loops Set::Scalar Math::Cartesian::Product Set::Product::PP Set::Product::XS
    Set::Crossproduct          45.61+-0.3/s                --      -24.9%           -33.2%      -54.7%                   -77.6%           -83.4%           -93.7%
    List::Gen                 60.75+-0.51/s        33.2+-1.4%          --           -11.1%      -39.7%                   -70.1%           -77.9%           -91.6%
    Algorithm::Loops          68.32+-0.56/s        49.8+-1.6%  12.5+-1.3%               --      -32.2%                   -66.4%           -75.2%           -90.6%
    Set::Scalar                100.8+-1.4/s         121+-3.5%  65.9+-2.8%       47.5+-2.4%          --                   -50.4%           -63.4%           -86.1%
    Math::Cartesian::Product   203.2+-3.4/s       345.6+-8.1% 234.5+-6.3%      197.5+-5.6% 101.6+-4.5%                       --           -26.2%           -72.0%
    Set::Product::PP           275.4+-1.3/s       503.7+-4.9% 353.3+-4.4%      303.1+-3.8% 173.2+-4.1%               35.5+-2.4%               --           -62.0%
    Set::Product::XS         724.96+-0.43/s         1489+-11%   1093+-10%      961.1+-8.8%    619+-10%                256.7+-6%      163.3+-1.3%               --

=cut
