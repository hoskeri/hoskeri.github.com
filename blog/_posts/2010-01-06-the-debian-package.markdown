---
title: The Debian Package.
layout: post
---

<p>The Apt (Advanced Packaging Tool) is immensely powerful. In fact you can
solve <a href="http://algebraicthunk.net/~dburrows/blog/entry/package-management-sudoku/">Sudoku
Puzzles</a>
in it. Yet the entire system is simple, easy to understand, and quite hackable.</p>

<p>Debian packages are very simple creatures. They consist of an <code>ar</code>
archive which contains three files: <code>debian-binary</code>, a <code>data.tar.gz</code> and
a <code>control.tar.gz</code>. The <code>debian-binary</code> contains the version number of
the package format. For current packages it is '2.0'.</p>

<p><code>data.tar.gz</code> contains the actual payload of the package. That is the
actual files and directories that go in the file system.</p>

<p><code>control.tar.gz</code> contains a bunch of shell scripts which are run when
the package is being installed and some other meta-data. This is the
<em>interesting</em> part of the package. Lets have a look at what it contains:</p>

<pre><code class='code-block'>  abhijit@azad:~/downloads/tmp&#036; ar x openarena_0.7.7-1~hardy1_i386.deb 
  abhijit@azad:~/downloads/tmp&#036; ls
  control.tar.gz    data.tar.gz  debian-binary  openarena_0.7.7-1~hardy1_i386.deb
  abhijit@azad:~/downloads/tmp&#036; tar -ztvf data.tar.gz 
  drwxr-xr-x root/root         0 2009-05-30 22:43 ./
  drwxr-xr-x root/root         0 2009-05-30 22:43 ./usr/
  drwxr-xr-x root/root         0 2009-05-30 22:43 ./usr/games/
  lrwxrwxrwx root/root         0 2009-05-30 22:43 ./usr/share/doc/openarena/CREDITS -&gt; ../openarena-data/CREDITS
  ...
  &lt;snipped&gt;

  abhijit@azad:~/downloads/tmp&#036;
  abhijit@azad:~/downloads/tmp&#036; tar -zxvf control.tar.gz 
  ./
  ./control
  ./md5sums
  ./postinst
  ./postrm
  abhijit@azad:~/downloads/tmp&#036;
</code></pre>

<p>As packages go, this one is pretty simple. The file named <code>control</code> is
the most important. Its format resembles the rfc 2822 email header
specification.</p>

<p>For example, for this package it would look like this:</p>

<pre><code class='code-block'>Package: openarena
Priority: optional
Section: games
Installed-Size: 1592
Maintainer: Ubuntu MOTU Developers &lt;ubuntu-motu@lists.ubuntu.com&gt;
Architecture: i386
Version: 0.7.7-1~hardy1
</code></pre>

<p>All of these are pretty self explanatory. There are more fields than
this one, of course. You can see for yourself from your favourite
package.</p>

<p>The next file, <code>md5sums</code> contains a list of md5sums of each file in the
package's payload. This allows you to verify the integrity of the
files in the package if you suspect it has been changed by some body.</p>

<p>The other two files, <code>postinst</code> and <code>prerm</code>, are executables, usually
written in shell but may also be in perl for some complicated
scripts. You can write the scripts in any language you want, but if they 
are in any language other than shell or perl, you have to specify a
'Pre-Depends' on that languages' package, so that it is available when
your package is being installed.</p>

<p>When you install your package using dpkg -i packagename.deb, the
following happens, roughly in order:</p>

<ul>
<li><p>The files in <code>control.tar.gz</code> is extracted into <code>/var/lib/dpkg/info</code></p></li>
<li><p>Next, a file list is extracted from <code>data.tar.gz</code> and is compared with
an internal database for conflicts with other files in the system. You
cannot install the package if it contains a file already 'owned' by
any other package.</p></li>
<li><p>If all is okay, then the <code>preinst install</code> is run. If it fails the
<code>postrm abort-install</code> is run.</p></li>
<li><p>If the <code>preinst</code> succeeded, the the files in the data.tar.gz are
unpacked into /.</p></li>
<li><p>Then <code>postinst configure</code> is run which configures the package. If it
exits successfully, then the package is said to be installed,
otherwise an error message is shown and the package is left in a 'half
installed' state. You can attempt to configure the package again by
running the command <code>apt-get install -f</code> which will attempt to run the
maintainer scripts again (usually) or may offer to remove the package
if it can't find any other solution.</p></li>
</ul>

<p>Of course, the above is the simplest possible workflow. There are more
complicated possiblities such as upgrades. See
<a href="http://women.debian.org/wiki/English/MaintainerScripts">here</a> for more
complicated scenarios. Especially 'Upgrades' if you want your head
exploded.</p>

<p>Next Episode: Package dependencies and relationships</p>
