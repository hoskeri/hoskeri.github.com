---
title: Package Dependencies and Relationships
layout: default
---


<p>There are two distinct philosophies to getting software into the users'
hands. Adherents of either philosophy are bitterly divided by their
relationship with the users of the software.</p>

<p>Software developers would like the layout of their user environment to
basically be an exact copy of their development environments, with all
dependencies and their versions being known quantities. This means that
all dependencies are bundled with the software distribution so that a)
there are no surprises and b) its possible to get the whole system
running from their distribution alone, without involving any third
parties.</p>

<p>People like software distributors and systems administrators, on the
other hand, are not comfortable with that attitude. The packages they
would get, while being self contained, also tend to take over the whole
system - i.e., assume that it is the only package installed on the
machine. The other side effect is that the distributions would be very
large and have multiple copies of the same component or library. This
makes patching security holes in the libraries on the machine next to
impossible. Unfortunately, almost all proprietary software is
distributed this way.</p>

<p>What we would like is for software packages to include their own code
alone, and point to dependencies and their versions elsewhere. This
allows the system administrator to make intelligent decisions about
preparing patches and updates and means that the set of libraries
installed on the machine is always a known quantity.</p>

<p>While efficient, trying to build systems like this presents some
difficulties. One of the obvious ones if the problem of dependency
hell. The other, trickier one, happens when different software depends
on <em>different</em> versions of the same dependency or library.</p>

<p>One way of solving this problem is to design 'suites' of commonly used
dependencies and allow the developers to point at the version of this
'suite' as their dependency. This is how it works in the Windows
world. For example, a particular package 'Evil Virus 2000' may specify
that it works on 'Windows 2000', but wont work on 'Windows Vista' or
newer.</p>

<p>But the disadvantage with this is that it is very easy to end up in
situations where you cannot run two different software packages on the
same machine because they depend on conflicting versions of the suite.</p>

<p>Those who work in free software cannot afford to make such
compromises. They also have very demanding users who need very fine
grained control over how their software is installed, and at the same
time, it is all expected to work 'out of the box'.</p>

<pre><code class='code-block'>  Package: courier-mta
  Priority: extra
  Section: mail
  ...
  Architecture: i386
  Source: courier
  Version: 0.60.0-2
  Replaces: mail-transport-agent
  Provides: mail-transport-agent
  Depends: libc6 (&gt;= 2.7-1), libgcc1 (&gt;= 1:4.1.1), libgdbm3,
           libperl5.10 (&gt;= 5.10.0), libstdc++6 (&gt;= 4.2.1),
           courier-base (&gt;= 0.60.0)
  Suggests: mail-reader, courier-doc, courier-filter-perl
  Conflicts: courier-faxmail (&lt;= 0.42.2-6), mail-transport-agent
  ...
  Description: Courier mail server - ESMTP daemon
</code></pre>

<p>So, this is the description of a package for Sam Varshavchik's Courier
mail transport agent. <code>apt-get install courier-mta</code>, will, needless to
say install all its dependencies from the <code>Depends</code> line. But that is
not the wonderful thing. The really cool thing here is that there is
<em>absolutely no mention</em> of any suite, or release name, or version.
'Sarge', 'Etch' or even 'Breezy', 'Jaunty' have no meaning to apt. They
are only what you would call, 'marketing' names.</p>

<p>This means, you, as a user can freely mix packages that were built 10
years ago on the same system as a package which was released yesterday,
the only limitation to this being the nature of the software itself!</p>

<p>But what if,  say our ancient package depends on perl  5.6 where as this
package clearly  depends on perl  5.10? This problem  is not one  that a
package  system  can solve  by  itself. It  takes  some  doing and  some
foresight  on the  part of  the maintainer  who builds  it. She  must be
careful,   every  time   a  software   developer   significantly  breaks
compatibility,  to   version  the  names  of  the   packages  and  their
constituent files such that it is  possible to install both of the them,
side by side. This is essential for libraries.</p>

<p>There are two ways in which a software developer can break
compatibility. One of them is to break the API, which means
functions/classes have been renamed or the whole framework has been
redesigned.</p>

<p>The other, more subtle kind of change is to break the ABI (Application
Binary Interface). Here the function call parameters dont change, but
the binary interface changes. Free software, has a great advantage here
in that we have the source and build infrastructure for every piece of
the puzzle. ABI breakage is solved simply by re-compiling all dependent
software on this new version and changing their dependencies to depend
on this new library.</p>

<p>Since the ELF format supports version numbers for individual symbols in
a library, such re-compiling and re-versioning is minimal and done only
when breakage is detected.</p>

<h2>Playing well with others</h2>

<p>I chose the example of a mail transport agent above because they have a
fairly rare property: Only one mail transport agent can be
installed at any given point. There are several reasons for this: All
MTA's have to listen on port 25, and obviously only one process can bind
to it at any given point in time. Then there is the 'sendmail interface',
the /usr/sbin/sendmail executable that has become the de-facto interface
for sending out email on Unix systems.</p>

<p>Apart from this, other packages are typically not interested in which
MTA is installed, but just want to be sure that <em>some</em> MTA is available.</p>

<p>Because of this, all MTA packages provide a <code>mail-transport-agent</code>,
which other packages can depend on. To prevent installation of any other
MTA, each MTA package also conflicts with <code>mail-transport-agent</code>. And
finally, each MTA package also 'Replaces' other m-t-a packages because
they have common path between them: /usr/sbin/sendmail.</p>

<p>courier-mta itself is  part of a large suite of  software written by Sam
Varshavchik. It includes  apart from the m-t-a itself,  an IMAP and POP3
server,  standalone   webmail,  fax  service,  mailing   lists,  and  an
implementation of  PCP (personal calendar protocol). It  also provides a
central authentication  service with bindings  to support authentication
databases in mysql, postgres, ldap, bdb, etc. All of this released as one
single tarball by the authors.</p>

<p>Yet the package maintainers cannot assume that just because a user wants
to use the m-t-a portion of the suite does not mean, that he wants to
the rest of the suite installed too. For example, the user may want the
courier-mta but may want to use dovecot-imapd as his IMAP server. He may
set up his server to authenticate from an LDAP database, in which case he
won't be interested in all the other authentication bindings and
dependencies such as mysql, postgres etc.</p>

<p>To make this possible the courier source tarball is built into the
following set of packages:</p>

<pre><code class='code-block'>      courier-authdaemon          courier-filter-perl
      courier-authlib             courier-imap
      courier-authlib-dev         courier-imap-authldap
      courier-authlib-ldap        courier-imap-ssl
      courier-authlib-mysql       courier-ldap
      courier-authlib-pipe        courier-maildrop
      courier-authlib-postgresql  courier-mlm
      courier-authlib-userdb      courier-mta
      courier-authmysql           courier-mta-ssl
      courier-authpostgresql      courier-pcp
      courier-base                courier-pop
      courier-debug               courier-pop-ssl
      courier-doc                 courier-ssl
      courier-faxmail             courier-webadmin
</code></pre>

<p>Whew! But this is what it takes for a package system to satisfy the
needs of its demanding users, who want to be able to do a lot of strange
things on their computer, and to do it easily.</p>
