pr stgit9, rclass
	vers 9.2

	stgit_parse `0'
	foreach param in subcmd git_dir {
		mata: st_local("`param'", st_global("s(`param')"))
	}

	assert "`subcmd'" == "status"

	tempname fh
	file open `fh' using "`git_dir'/HEAD", r
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

	file open `fh' using "`git_dir'/`ref'", r
	file r `fh' sha
	file r `fh' blank
	loc eof = r(eof)
	file close `fh'
	if !regexm("`sha'", "^[a-z0-9]+$") | `:length loc blank' | !`eof' {
		di as err "`ref': invalid branch ref"
		ex 198
	}

	stgit_summary, branch(`branch') sha(`sha')

	ret loc git_dir "`git_dir'"
	ret loc branch "`branch'"
	ret loc sha `sha'
end
