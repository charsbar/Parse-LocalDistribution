use strict;
use warnings;
use Test::More;
use Parse::LocalDistribution;

plan skip_all => "requires WorePAN" unless eval "use WorePAN 0.03; 1";
my @tests = (
  ['M/ML/MLEHMANN/common-sense-3.72.tar.gz', 'common::sense', '3.72'],
);

for my $test (@tests) {
  my ($path, $package, $version) = @$test;
  note "downloading $path...";

  my $worepan = WorePAN->new(
    no_network => 0,
    use_backpan => 1,
    cleanup => 1,
    no_indices => 1,
    files => [$path],
  );

  note "parsing $path...";

  $worepan->walk(callback => sub {
    my $dir = shift;
    my $info = Parse::LocalDistribution->new($dir)->parse;
    ok !$@ && ref $info eq ref {} && $info->{$package}{version} eq '3.72', "parsed successfully in time";
    note $@ if $@;
    note explain $info;
  });
}

done_testing;
