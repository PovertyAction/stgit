package org.matthewjwhite.stata.git;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.Set;

import com.stata.sfi.Macro;

import org.eclipse.jgit.api.Git;
import org.eclipse.jgit.api.Status;
import org.eclipse.jgit.api.errors.GitAPIException;
import org.eclipse.jgit.lib.ObjectId;
import org.eclipse.jgit.lib.Repository;
import org.eclipse.jgit.storage.file.FileRepositoryBuilder;
import org.matthewjwhite.stata.macro.MacroList;
import org.matthewjwhite.stata.util.Conversion;

// An exception that can be passed to -stgit_error- in Stata
class StGitException extends Exception {
	private static final long serialVersionUID = 1L;
	private final String code;

	public StGitException(String code, Throwable cause) {
		this.code = code;
		initCause(cause);
	}

	public StGitException(String code) {
		this(code, null);
	}

	public StGitException(Throwable cause) {
		this("java", cause);
	}

	public String getCode() {
		return code;
	}
}

class StGitExceptionHandler {
	private final String codeLocal, messageLocal;

	public StGitExceptionHandler(String codeLocal, String messageLocal) {
		this.codeLocal    = codeLocal;
		this.messageLocal = messageLocal;
	}

	/*
	Passes the exception to Stata.

	A typical -javacall- method will return immediately after calling
	stata(). stata() returns 0 to allow

 	return whatever.stata(e);

 	rather than

 	whatever.stata(e);
 	return 0;
	*/
	public int stata(StGitException e) {
		Macro.setLocal(codeLocal, e.getCode());
		Throwable cause = e.getCause();
		String message = cause != null ? cause.getMessage() : "";
		Macro.setLocal(messageLocal, message);
		return 0;
	}
}

public class StGit {
	@SuppressWarnings("unchecked")
	private static <T> T getValue(Object obj, String getter, T result) {
		try {
			return (T) obj.getClass().getMethod(getter, new Class[] {}).
				invoke(obj);
		}
		catch (NoSuchMethodException|SecurityException|IllegalAccessException|
			IllegalArgumentException|InvocationTargetException e) {
			throw new RuntimeException("reflection exception");
		}
	}

	private static String camelToSnake(String camel) {
		StringBuilder snake = new StringBuilder(camel);
		for (int i = 0; i < snake.length(); i++) {
			char c = snake.charAt(i);
			if ('A' <= c && c <= 'Z') {
				snake.replace(i, i + 1, String.valueOf(c).toLowerCase());
				snake.insert(i, '_');
				i++;
			}
		}

		return snake.toString();
	}

	private static void status(Repository repo) throws StGitException {
		String branch = null;
		try {
			branch = repo.getBranch();
		}
		catch (IOException e) {
			throw new StGitException("invalid_branch", e);
		}
		Macro.setLocal("branch", branch);

		ObjectId head = null;
		try {
			head = repo.resolve("HEAD");
		}
		catch (IOException e) {
			throw new StGitException("invalid_head", e);
		}
		if (head == null)
			throw new StGitException("retrieve_head");
		Macro.setLocal("sha", head.name());

		Status status = null;
		try {
			status = new Git(repo).status().call();
		}
		catch (GitAPIException e) {
			throw new StGitException(e);
		}
		class Result {
			public final String getter, result;

			public Result(String getter, String result) {
				this.getter = getter;
				this.result = result;
			}
		}
		ArrayList<Result> results = new ArrayList<Result>();
		String[] getters = {"isClean", "hasUncommittedChanges"};
		for (String getter : getters) {
			Boolean res = null;
			res = getValue(status, getter, res);
			results.add(new Result(getter, Conversion.string(res)));
		}
		getters = new String[] {"Added", "Changed", "Conflicting",
			"IgnoredNotInIndex", "Missing", "Modified", "Removed",
			"UncommittedChanges", "Untracked", "UntrackedFolders"};
		for (String getter : getters) {
			String full = "get" + getter;
			Set<String> files = null;
			files = getValue(status, full, files);
			results.add(new Result(full,
				MacroList.invtokens(files.toArray(new String[0]))));
		}
		for (Result res : results) {
			StringBuilder name = new StringBuilder(camelToSnake(res.getter));
			if (name.substring(0, 4).equals("get_"))
				name.delete(0, name.indexOf("_") + 1);
			Macro.setLocal(name.toString(), res.result);
		}
	}

	public static int javacall(String args[]) {
		if (args.length != 4)
			throw new IllegalArgumentException("invalid number of arguments");
		String subcmd     = args[0];
		String gitDirName = args[1];
		StGitExceptionHandler stGitError =
			new StGitExceptionHandler(args[2], args[3]);

		// Initialize access to the repo.
		FileRepositoryBuilder builder = new FileRepositoryBuilder().
			readEnvironment().setGitDir(new File(gitDirName));
		Repository repo = null;
		try {
			repo = builder.build();
		}
		catch (IOException e) {
			return stGitError.
				stata(new StGitException("invalid_repository", e));
		}

		try {
			switch (subcmd) {
				case "status":
					status(repo);
					break;
				default:
					throw new IllegalArgumentException("invalid subcommand");
			}
		}
		catch (StGitException e) {
			return stGitError.stata(e);
		}

		return 0;
	}
}
