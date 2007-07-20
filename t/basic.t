#!perl -T
use strict;
use warnings;

use Test::More tests => 3;
use Test::BinaryData;

is_binary('abc','abc');
is_binary("abc\n", "abc\x0d\x0a");

my $original = do { local $/; <DATA> };
(my $crlfed = $original) =~ s/\n/\x0d\x0a/g;

is_binary($original, $crlfed);

__DATA__
From mail-miner-10529@localhost Wed Dec 18 12:07:55 2002
Received: from mailman.opengroup.org ([192.153.166.9])
	by deep-dark-truthful-mirror.pad with smtp (Exim 3.36 #1 (Debian))
	id 18Buh5-0006Zr-00
	for <posix@simon-cozens.org>; Wed, 13 Nov 2002 10:24:23 +0000
Received: (qmail 1679 invoked by uid 503); 13 Nov 2002 10:10:49 -0000
Resent-Date: 13 Nov 2002 10:10:49 -0000
Date: Wed, 13 Nov 2002 10:06:51 GMT
From: Andrew Josey <ajosey@rdg.opengroup.org>
Message-Id: <1021113100650.ZM12997@skye.rdg.opengroup.org>
In-Reply-To: Joanna Farley's message as of Nov 13,  9:56am.
References:
        <200211120937.JAA28130@xoneweb.opengroup.org> 
	<1021112125524.ZM7503@skye.rdg.opengroup.org> 
	<3DD221BB.13116D47@sun.com>
X-Mailer: Z-Mail (5.0.0 30July97)
To: austin-group-l@opengroup.org
Subject: Re: Defect in XBD lround
MIME-Version: 1.0
Resent-Message-ID: <gZGK1B.A.uY.iUi09@mailman>
Resent-To: austin-group-l@opengroup.org
Resent-From: austin-group-l@opengroup.org
X-Mailing-List: austin-group-l:archive/latest/4823
X-Loop: austin-group-l@opengroup.org
Precedence: list
Resent-Sender: austin-group-l-request@opengroup.org
Content-Type: text/plain; charset=us-ascii

Joanna, All

Thanks. I got the following response from Fred Tydeman.

C99 Defect Report (DR) 240 covers this.  The main body of C99
(7.12.9.7) says range error, while Annex F (F.9.6.7 and F.9.6.5)
says "invalid" (domain error).  The result was to change 7.12.9.7
to allow for either range or domain error.  The preferred error
is domain error (so as match Annex F).  So, no need to change XBD.

regards
Andrew
