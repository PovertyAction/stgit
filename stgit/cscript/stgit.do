* -stgit- cscript

* -version- intentionally omitted for -cscript-.

* 1 to execute profile.do after completion; 0 not to.
local profile 1


/* -------------------------------------------------------------------------- */
					/* initialize			*/

* Check the parameters.
assert inlist(`profile', 0, 1)

* Set the working directory to the stata-git-tools directory.
c sgt
cd stgit/cscript

cap log close stgit
log using stgit, name(stgit) s replace
di "`c(username)'"
di "`:environment computername'"

clear
if c(stata_version) >= 11 ///
	clear matrix
clear mata
set varabbrev off
set type float
vers 9.2: set seed 234553473
set more off

cd ..
adopath ++ `"`c(pwd)'"'
* Make sure to install -matawarn- (https://github.com/matthew-white/matawarn),
* adding it to a system directory or your ado-path.
cd cscript

timer clear 1
timer on 1

* Preserve select globals.
loc FASTCDPATH : copy glo FASTCDPATH

cscript stgit adofile stgit

* Check that Mata issues no warning messages about the source code.
if c(stata_version) >= 13 {
	loc dir ..
	loc files : dir "`dir'" file *
	foreach file of loc files {
		matawarn "`dir'/`file'"
		assert !r(warn)
	}
	cscript
}

* Restore globals.
glo FASTCDPATH : copy loc FASTCDPATH


/* -------------------------------------------------------------------------- */
					/* tests				*/

// ...


/* -------------------------------------------------------------------------- */
					/* finish up			*/

cd ..

timer off 1
timer list 1

if `profile' {
	cap conf f C:\ado\profile.do
	if !_rc ///
		run C:\ado\profile
}

timer list 1

log close stgit
