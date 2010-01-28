use strict;
use warnings;

use inc::Module::Install;

name      ('Test-BinaryData');
all_from  ('lib/Test/BinaryData.pm');
author    ('Ricardo SIGNES <rjbs@cpan.org>');

requires(Encode => 0.000); # minimum unknown
test_requires('Test::Tester'     => 0.107); # recent ::Builder compat

auto_manifest;
extra_tests;

WriteAll();
