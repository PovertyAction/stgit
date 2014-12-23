pr stgit_error
	vers 9.2

	syntax name(name=code id=code)

	loc rc 198
	if "`code'" == "retrieve_head" {
		di as err "cannot retrieve HEAD"
		di as err "check path of GIT_DIR"
	}
	else if "`code'" == "invalid_head" {
		di as err "invalid HEAD"
	}
	else if "`code'" == "invalid_branch" {
		di as err "invalid branch"
	}
	else {
		di as err "invalid stgit_error code"
	}

	conf n `rc'
	ex `rc'
end
