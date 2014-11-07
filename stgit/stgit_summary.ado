pr stgit_summary
	vers 9.2

	syntax, branch(str) sha(str)

	di
	di as txt "Branch: " as res "`branch'"
	di as txt "SHA-1 hash of commit: " as res "`sha'"
end
