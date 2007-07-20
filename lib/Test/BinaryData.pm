
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

  $self->export_to_level(1, $self, @Test::BinaryData::EXPORT);
}

=head2 is_binary

  is_binary($got, $expected, $comment, \%arg);

This test behaves like Test::More's C<eq> test, but if the given data are not
string equal, the diagnostics emits four columns, describing the strings in
parallel, showing a simplified ASCII representation and a hexadecimal dump.
This is useful when looking for subtle errors in whitespace or other invisible
differences.

The C<$comment> and C<%arg> arguments are optional.  Valid arguments are:

  columns - the number of screen columns available
            if the COLUMNS environment variable is an positive integer, then
            COLUMNS - is used; otherwise, the default is 79

  max_diffs - if given, this is the maximum number of differing lines that will
              be compared; if output would have been given beyond this line, 
              it will be replaced with an elipsis ("...")

=cut

sub _widths {
  my ($total) = @_;

  $total = $total
         - 2 # the "# " that begins each diagnostics line
         - 3 # the " ! " or " = " line between got / expected
         - 2 # the space between hex/ascii representations
         ;

  my $sixth = int($total / 6);
  return ($sixth * 2, $sixth);
}

sub is_binary($$;$$) {
  my ($got, $expected, $comment, $arg) = @_;

  $arg ||= {};

  unless (defined $arg->{columns}) {
    if ($ENV{COLUMNS} =~ /\A\d+\z/ and $ENV{COLUMNS} > 0) {
      $arg->{columns} = $ENV{COLUMNS} - 1;
    } else {
      $arg->{columns} = 79;
    }
  }

  Carp::croak 'minimum columns is 44' if $arg->{columns} < 44;

  my ($hw, $aw) = _widths($arg->{columns});

  if ($got eq $expected) {
    return $Test->ok(1, $comment);
  }

  $Test->ok(0, $comment);

  my $max_length = (sort map { length } $got, $expected)[1];

  $Test->diag(
    sprintf "%-${hw}s %-${aw}s   %-${hw}s %-${aw}s",
      map {; "$_ (hex)", "$_" } qw(got expect)
  );

  my $seen_diffs = 0;
  CHUNK: for (my $pos = 0; $pos < $max_length; $pos += $aw) {
    if ($arg->{max_diffs} and $seen_diffs == $arg->{max_diffs}) {
      $Test->diag("...");
      last CHUNK;
    }

    my $g_substr = substr $got,      $pos, $aw;
    my $e_substr = substr $expected, $pos, $aw;

    my $eq = $g_substr eq $e_substr;

    my $g_hex = join '', map { sprintf '%02x', ord($_) } split //, $g_substr;
    my $e_hex = join '', map { sprintf '%02x', ord($_) } split //, $e_substr;

    $_ = join '', map { $_ =~ /\A[\x20-\x7e]\z/ ? $_ : '.' } split //, $_
      for ($g_substr, $e_substr);

    $_ = sprintf "%-${aw}s", $_ for ($g_substr, $e_substr);
    $_ .= '-' x ($hw - length) for ($g_hex, $e_hex);

    $Test->diag(
      "$g_hex $g_substr",
      ($eq ? ' = ' : ' ! '),
      "$e_hex $e_substr"
    );

    $seen_diffs++ unless $eq;
  }

  return;
}

1;

=head1 TODO

=over

=item * optional position markers

     got (hex)        got        expect (hex)     expect  
  00 46726f6d206d6169 From mai = 46726f6d206d6169 From mai
  08 3130353239406c6f 10529@lo = 3130353239406c6f 10529@lo
  16 63616c686f737420 calhost  = 63616c686f737420 calhost 
  24 5765642044656320 Wed Dec  = 5765642044656320 Wed Dec 
  32 31382031323a3037 18 12:07 = 31382031323a3037 18 12:07
  40 3a35352032303032 :55 2002 = 3a35352032303032 :55 2002
  48 0a52656365697665 .Receive ! 0d0a526563656976 ..Receiv

=item * investigate probably bugs with wide chars, multibyte strings

I wrote this primarily for detecting CRLF problems.  It would probably be
useful for wonky character encodings, but I know very little of them.  Patches
and tests welcome.

=back

=head1 AUTHOR

Ricardo SIGNES, C<< <rjbs at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2007, Ricardo SIGNES.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

