* -stgit- cscript

* -version- intentionally omitted for -cscript-.

* 1 to execute profile.do after completion; 0 not to.
local profile 1


/* -------------------------------------------------------------------------- */
					/* initialize			*/

* Check the parameters.
assert inlist(`profile', 0, 1)

* Set the working directory to the stgit directory.
c stgit
cd cscript

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
		mata: st_local("ext", pathsuffix(st_local("file")))
		if inlist("`ext'", ".ado", ".mata") {
			matawarn "`dir'/`file'"
			assert !r(warn)
		}
	}
	cscript
}

* Restore globals.
glo FASTCDPATH : copy loc FASTCDPATH

mata: dirs = J(1, 0, "")
* Syntax: pushd: cmd
* Adds the working directory to a stack of directories, then executes
* the command cmd to change the working directory.
pr pushd
	_on_colon_parse `0'
	mata: if (strlen(st_global("s(before)"))) ///
		exit(error(198));;
	mata: dirs = dirs, pwd()
	`s(after)'
end
* Syntax: popd
* Changes the working directory to the directory at the top of the stack of
* directories.
pr popd
	syntax
	mata: st_local("n", strofreal(length(dirs)))
	mata: chdir(dirs[`n'])
	* -chdir()- does not update the working directory bar in the GUI.
	cd .
	if `n' > 1 ///
		mata: dirs = dirs[|1 \ `n' - 1|]
	else ///
		mata: dirs = J(1, 0, "")
end
* Syntax: touch filename
* Creates the new empty file filename.
pr touch
	syntax anything(name=fn id=filename)

	gettoken fn rest : fn
	if `:length loc rest' ///
		err 198

	tempname fh
	file open `fh' using `"`fn'"', w
	file close `fh'
end
* Syntax: assert13 ...
* Executes -assert- if and only if the Stata version is 13 or above.
pr assert13
	if c(stata_version) < 13 ///
		ex
	assert `0'
end


/* -------------------------------------------------------------------------- */
					/* tests				*/

pushd: c stgit_cscript

!git reset --hard
!git clean -dxf
!git checkout master

* Simple test of -stgit status-
stgit status
mata: st_global("git_dir", pathjoin(pwd(), ".git"))
glo sha 2f4069329e877d25890d80811b84cec03f55eec7
pr check_results9
	assert `"`r(git_dir)'"' == `"$git_dir"'
	assert !r(has_detached_head)
	assert "`r(branch)'"    == "master"
	assert "`r(sha)'"       == "$sha"
end
pr check_results_clean
	check_results9

	if c(stata_version) >= 13 {
		assert r(is_clean) == 1
		assert r(has_uncommitted_changes) == 0
		assert "`r(uncommitted_changes)'" == ""
	}
end
check_results_clean

* The -status- subcommand is implied.
stgit
check_results_clean

* Change the working directory to a repository subdirectory.
cd dir
stgit
check_results_clean
* Deprecated syntax
stgit ..
check_results_clean
cd ..

* Test -stgit status, git_dir()-.
foreach root in . "" dir/.. `"`c(pwd)'"' {
	mata: st_local("git_dir", pathjoin(st_local("root"), ".git"))
	stgit status, git_dir(`"`git_dir'"')
	check_results_clean
	stgit, git_dir(`"`git_dir'"')
	check_results_clean

	* Deprecated syntax
	stgit `"`root'"'
	check_results_clean
}
* Nonexistent GIT_DIR
rcof "noi stgit, git_dir(./.git_dir)" == 601
* Bad GIT_DIR
rcof "noi stgit, git_dir(.)" == 198

* Cannot find GIT_DIR.
if c(os) == "Windows" ///
	loc dir C:\
else ///
	loc dir ~
pushd: cd "`dir'"
mata: assert(!direxists(".git"))
rcof "noi stgit" == 601
popd

* Invalid second token
rcof "noi stgit status status" == 101
rcof "noi stgit . ." == 101
rcof "noi stgit ., git_dir(./.git)" == 101
rcof "noi stgit .,git_dir(./.git)" == 101

* Different branch
loc branch master-copy
!git checkout `branch'
stgit
assert !r(has_detached_head)
assert "`r(branch)'" == "`branch'"
!git checkout master
stgit
check_results_clean

* Detached head
!git checkout $sha
stgit
assert `"`r(git_dir)'"' == `"$git_dir"'
assert r(has_detached_head) == 1
assert "`r(branch)'"    == "$sha"
assert "`r(sha)'"       == "$sha"
assert13 r(is_clean) == 1
assert13 !r(has_uncommitted_changes)
!git checkout master

* New files
* Untracked
touch new.txt
stgit
check_results9
assert13 !r(is_clean)
assert13 !r(has_uncommitted_changes)
assert13 "`r(uncommitted_changes)'" == ""
assert13 r(untracked) == "new.txt"
* Added
!git add new.txt
stgit
check_results9
assert13 !r(is_clean)
assert13 r(has_uncommitted_changes) == 1
assert13 r(uncommitted_changes) == "new.txt"
assert13 "`r(untracked)'" == ""
assert13 r(added) == "new.txt"
* Both
touch "new too.txt"
stgit
check_results9
assert13 !r(is_clean)
assert13 r(has_uncommitted_changes) == 1
assert13 r(uncommitted_changes) == "new.txt"
assert13 r(untracked) == `""new too.txt""'
assert13 r(added) == "new.txt"
!git add "new too.txt"
stgit
check_results9
assert13 !r(is_clean)
assert13 r(has_uncommitted_changes) == 1
assert13 r(uncommitted_changes) == `""new too.txt" new.txt"'
assert13 "`r(untracked)'" == ""
assert13 r(added) == `""new too.txt" new.txt"'
* Clean up.
!git reset --hard

* New directory
mkdir new
stgit
check_results_clean
assert13 "`r(untracked)'" == ""
assert13 r(untracked_folders) == "new"
* Second directory
mkdir new2
stgit
check_results_clean
assert13 r(untracked_folders) == "new2 new"
* New file
touch new/new.txt
stgit
check_results9
assert13 !r(is_clean)
assert13 !r(has_uncommitted_changes)
assert13 "`r(uncommitted_changes)'" == ""
assert13 r(untracked) == "new/new.txt"
assert13 r(untracked_folders) == "new2 new"
* Clean up.
!git clean -df

* Remove/modify a tracked file.
* Missing
erase README.md
stgit
check_results9
assert13 !r(is_clean)
assert13 r(has_uncommitted_changes) == 1
assert13 r(uncommitted_changes) == "README.md"
assert13 r(missing) == "README.md"
assert13 "`r(removed)'"  == ""
assert13 "`r(modified)'" == ""
assert13 "`r(changed)'"  == ""
* Removed
!git rm README.md
stgit
check_results9
assert13 !r(is_clean)
assert13 r(has_uncommitted_changes) == 1
assert13 r(uncommitted_changes) == "README.md"
assert13 "`r(missing)'"  == ""
assert13 r(removed) == "README.md"
assert13 "`r(modified)'" == ""
assert13 "`r(changed)'"  == ""
* Modified
!git reset HEAD README.md
touch README.md
stgit
check_results9
assert13 !r(is_clean)
assert13 r(has_uncommitted_changes) == 1
assert13 r(uncommitted_changes) == "README.md"
assert13 "`r(missing)'" == ""
assert13 "`r(removed)'" == ""
assert13 r(modified) == "README.md"
assert13 "`r(changed)'" == ""
* Changed
!git add README.md
stgit
check_results9
assert13 !r(is_clean)
assert13 r(has_uncommitted_changes) == 1
assert13 r(uncommitted_changes) == "README.md"
assert13 "`r(missing)'"  == ""
assert13 "`r(removed)'"  == ""
assert13 "`r(modified)'" == ""
assert13 r(changed) == "README.md"
* Clean up.
!git reset --hard

* Ignored files
* Tracked before .gitignore
tempname fh
file open `fh' using dir/empty.asc, w append
file w `fh' "stgit" _n
file close `fh'
!git add dir/empty.asc
stgit
check_results9
assert13 !r(is_clean)
assert13 r(has_uncommitted_changes) == 1
assert13 r(uncommitted_changes) == "dir/empty.asc"
assert13 r(changed) == "dir/empty.asc"
assert13 "`r(ignored_not_in_index)'" == ""
assert13 "`r(untracked)'" == ""
!git reset --hard
* New ignored file
touch new.asc
stgit
check_results_clean
assert13 r(ignored_not_in_index) == "new.asc"
assert13 "`r(untracked)'" == ""
assert13 "`r(added)'"     == ""
!git clean -xf

* Conflicting files
!git merge conflict
stgit
check_results9
assert13 !r(is_clean)
assert13 r(has_uncommitted_changes) == 1
assert13 r(uncommitted_changes) == ".gitignore"
assert13 r(conflicting)         == ".gitignore"
assert13 "`r(modified)'" == ""
assert13 "`r(changed)'"  == ""
!git merge --abort

popd


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
