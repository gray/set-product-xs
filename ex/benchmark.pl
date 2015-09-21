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
    'Set::CrossProduct' => sub {
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

                                        Rate Set::CrossProduct    List::Gen Algorithm::Loops   Set::Scalar Math::Cartesian::Product Set::Product::PP Set::Product::XS
    Set::CrossProduct           45.1+-0.62/s                --       -28.7%           -38.1%        -59.6%                   -77.6%           -84.2%           -95.9%
    List::Gen                  63.21+-0.42/s        40.2+-2.2%           --           -13.3%        -43.4%                   -68.7%           -77.8%           -94.3%
    Algorithm::Loops           72.87+-0.34/s        61.6+-2.4% 15.29+-0.94%               --        -34.8%                   -63.9%           -74.5%           -93.4%
    Set::Scalar               111.75+-0.18/s       147.8+-3.5%   76.8+-1.2%     53.35+-0.77%            --                   -44.6%           -60.8%           -89.9%
    Math::Cartesian::Product    201.7+-2.8/s       347.2+-8.8%    219.1+-5%      176.8+-4.1%    80.5+-2.6%                       --           -29.3%           -81.8%
    Set::Product::PP          285.25+-0.12/s       532.5+-8.8%    351.3+-3%      291.4+-1.9% 155.27+-0.44%                 41.4+-2%               --           -74.2%
    Set::Product::XS         1106.72+-0.52/s         2354+-34%    1651+-12%     1418.7+-7.2%   890.4+-1.7%              448.7+-7.7%           288.0%               --

=cut
