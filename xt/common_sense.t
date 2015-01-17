use strict;
use warnings;
use Test::More;
use Parse::LocalDistribution;

plan skip_all => "requires WorePAN" unless eval "use WorePAN 0.03; 1";
my @tests = (
  ['M/ML/MLEHMANN/common-sense-3.72.tar.gz', 'common::sense', '3.72'],
  ['B/BE/BEPPU/Squatting-0.82.tar.gz', 'Squatting', '0.82'],
  ['R/RK/RKINYON/Tree-Compat-1.00.tar.gz', 'Tree::Compat', '1.00'],

  ['E/ET/ETHER/Hash-Util-FieldHash-Compat-0.05.tar.gz', 'Hash::Util::FieldHash::Compat', '0.05'],

  # malformatted provides field
  ['D/DJ/DJERIUS/Lua-API-0.02.tar.gz', 'Lua::API', undef],
  ['M/MU/MURPHY/Syntax-SourceHighlight-1.0.1.tar.gz', 'Syntax::SourceHighlight', undef],

  # invalid version
  ['P/PI/PIP/XML-Tidy-1.12.B55J2qn.tgz', 'XML::Tidy', 'undef', 1],
  ['C/CF/CFUHRMAN/Log-Fine-0.64.tar.gz', 'Log::Fine::Formatter', 'undef', 1],

  ['R/RI/RIBASUSHI/DBIx-Class-Manual-SQLHackers-1.3.tar.gz', '', undef, 1],

  # overriden by another non-simile package version
  ['GFUJI/Text-Xslate-3.2.0.tar.gz', 'Text::Xslate', '3.002000'],

  # (illegal) no_index entries with backslashes
  ['DAGOLDEN/Class-InsideOut-0.90_01.tar.gz', 'Class::InsideOut', '0.90_01', 1],
);

for my $test (@tests) {
  my ($path, $package, $version, $has_error) = @$test;
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
    my @warnings;
    local $SIG{__WARN__} = sub { push @warnings, @_ };
    my $info = eval { Parse::LocalDistribution->new($dir)->parse };
    if ($package) {
      if (defined $version) {
        ok !$@ && ref $info eq ref {} && $info->{$package}{version} eq $version, "parsed successfully in time";
      } else {
        ok !$@ && ref $info eq ref {} && !defined $info->{$package}{version}, "parsed successfully in time";
        if ($has_error) {
          ok !$@ && ref $info eq ref {} && defined $info->{$package}{parse_version_error}, "invalid version is stored";
        }
      }
    }
    ok !@warnings;
    note explain \@warnings if @warnings;
    note $@ if $@;
    note explain $info;
  }, developer_releases => 1);
}

done_testing;
