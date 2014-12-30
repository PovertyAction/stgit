Contributing
============

Please contribute to `stgit` through issues or pull requests.

Certification script
--------------------

The [certification script](http://www.stata.com/help.cgi?cscript) of `stgit` is [`cscript/stgit.do`](/cscript/stgit.do). If you are new to certification scripts, you may find [this](http://www.stata-journal.com/sjpdf.html?articlenum=pr0001) Stata Journal article helpful.

When contributing code, adding associated cscript tests is much appreciated.

Stata environment
-----------------

Follow these steps to set up your Stata environment for `stgit` development.

### Repositories to clone

Clone these related repositories:

- [matthew-white/stgit-cscript](https://github.com/matthew-white/stgit-cscript)

### Java libraries

Download these Java libraries:

- [JGit](https://eclipse.org/jgit/download/)
- [stata-java](https://github.com/matthew-white/stata-java). You can also download stata-java through SSC (see below).

Add the `.jar` files to a [system directory](http://www.stata.com/help.cgi?sysdir) or your [ado-path](http://www.stata.com/help.cgi?adopath).

### User-written programs and ado-path

Type the following in Stata to install SSC packages used in `stgit` itself or the cscript:

```stata
ssc install statajava
ssc install fastcd
```

Now set up `fastcd` to run on your computer as follows:

```stata
* Change the working directory to the location of GitHub/stgit on your
* computer.
cd ...
c cur stgit

* Change the working directory to the location of GitHub/stgit-cscript on your
* computer.
cd ...
c cur stgit_cscript
```

After this, the command `c stgit` will change the working directory to `GitHub/stgit`; likewise for `c stgit_cscript` and `GitHub/stgit-cscript`.

`fastcd` is the name of the SSC package, not the command itself; the command is named `c`. To change the working directory, type `c` in Stata, not `fastcd`. To view the help file, type `help fastcd`, not `help c`.

Next, install [`matawarn`](https://github.com/matthew-white/matawarn), adding it to your ado-path.

Finally, add `stgit` to your ado-path:

```stata
c stgit
adopath ++ `"`c(pwd)'"'
```

You may wish to place these lines in your [`profile.do`](http://www.stata.com/support/faqs/programming/profile-do-file/) as follows:

```stata
local curdir "`c(pwd)'"
c stgit
adopath ++ `"`c(pwd)'"'
cd `"`curdir'"'
```
