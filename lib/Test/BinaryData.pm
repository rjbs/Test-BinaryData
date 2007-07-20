
use strict;
package Test::BinaryData;

=head1 NAME

Test::BinaryData - compare two things, give hex dumps if they differ

=head1 VERSION

version 0.001

 $Id: /my/cs/projects/Test-MinimumVersion/trunk/lib/Test/MinimumVersion.pm 31951 2007-07-03T21:47:09.752107Z rjbs  $

=cut

use vars qw($VERSION);
$VERSION = '0.001';

=head1 SYNOPSIS

  use Test::BinaryData;
  
  my $computed_data = do_something_complicated;
  my $expected_data = read_file('correct.data');

  is_binary(
    $computed_data,
    $expected_data,
    "basic data computation",
  );

=cut

use Test::Builder;
require Exporter;
@Test::BinaryData::ISA = qw(Exporter);
@Test::BinaryData::EXPORT = qw(
  is_binary
);

my $Test = Test::Builder->new;

sub import {
  my($self) = shift;
  my $pack = caller;

  $Test->exported_to($pack);
  $Test->plan(@_);

  $self->export_to_level(1, $self, @Test::MinimumVersion::EXPORT);
}

=head2 is_binary

  is_binary($got, $expected, $comment);

=cut

sub is_binary($$;$$) {
  my $got      = shift;
  my $expected = shift;
  my $arg      = shift if ref $_[0];
  my $comment  = shift;

  if ($got eq $expected) {
    return $Test->ok(1, $comment);
  }

  $Test->ok(0, $comment);

  my $max_length = (sort map { length } $got, $expected)[1];

  for (my $pos = 0; $pos < $max_length; $pos += 12) {
    my $g_substr = substr $got,      $pos, 12;
    my $e_substr = substr $expected, $pos, 12;

    my $eq = $g_substr eq $e_substr;

    my $g_hex = join '', map { sprintf '%02x', ord($_) } split //, $g_substr;
    my $e_hex = join '', map { sprintf '%02x', ord($_) } split //, $e_substr;

    $_ = join '', map { $_ =~ /\A[\x20-\x7e]\z/ ? $_ : '.' } split //, $_
      for ($g_substr, $e_substr);

    $_ = sprintf '%-12s', $_ for ($g_substr, $e_substr);
    $_ .= '-' x (24 - length) for ($g_hex, $e_hex);

    $Test->diag(
      "$g_hex $g_substr",
      ($eq ? ' = ' : ' ! '),
      "$e_hex $e_substr\n"
    );
  }

  return;
}

1;
