pr stgit9, rclass
	vers 9

	syntax anything(name=dir id="repository directory")

	gettoken dir rest : dir
	if `:length loc rest' {
		di as err "invalid repository directory"
		ex 198
	}

	loc gitdir "`dir'/.git"
	mata: st_local("exists", strofreal(direxists(st_local("gitdir"))))
	if !`exists' {
		di as err "directory `gitdir' not found"
		ex 601
	}

	tempname fh
	file open `fh' using "`gitdir'/HEAD", r
	file r `fh' ref
	file r `fh' blank
	loc eof = r(eof)
	file close `fh'
	if !strmatch("`ref'", "ref: refs/heads/*") | `:length loc blank' | !`eof' {
		di as err "invalid HEAD"
		ex 198
	}
	loc ref = subinstr("`ref'", "ref: ", "", 1)
	loc branch = subinstr("`ref'", "refs/heads/", "", 1)

	file open `fh' using "`gitdir'/`ref'", r
	file r `fh' sha
	file r `fh' blank
	loc eof = r(eof)
	file close `fh'
	if !regexm("`sha'", "^[a-z0-9]+$") | `:length loc blank' | !`eof' {
		di as err "`ref': invalid branch ref"
		ex 198
	}

	di
	di as txt "Branch: " as res "`branch'"
	di as txt "SHA-1 hash of last commit: " as res "`sha'"

	ret loc branch "`branch'"
	ret loc sha `sha'
end
