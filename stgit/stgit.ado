pr stgit, rclass
	vers 9.2

	loc command = cond(_caller() >= 13, "stgit13", "stgit9")
	vers `=_caller()': `command' `0'
	ret add
end
