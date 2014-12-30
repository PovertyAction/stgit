stgit
=====

`stgit` is a Stata program that retrieves information about a Git repository.

Contributing
------------

See the [contributing guide](/CONTRIBUTING.md) for advice on collaborating.

Stata help file
---------------

Converted automatically from SMCL:

```
log html stgit.sthlp stgit.md
```

The help file looks best when viewed in Stata as SMCL.

<pre>
<b><u>Title</u></b>
<p>
    <b>stgit</b> -- Retrieve information about a Git repository
<p>
<p>
<a name="syntax"></a><b><u>Syntax</u></b>
<p>
        <b>stgit</b> [<b>status</b>]<b>,</b> [<i>options</i>]
<p>
    <i>options</i>                     Description
    -------------------------------------------------------------------------
      <b>git_dir(</b><i>directory_name</i><b>)</b>   GIT_DIR, the directory containing the
                                  repository metadata
    -------------------------------------------------------------------------
<p>
<p>
<a name="description"></a><b><u>Description</u></b>
<p>
    <b>stgit</b> retrieves information about a Git repository, including the current
    branch and the SHA-1 hash of the current commit.  In Stata 13 and above,
    it uses the Java library JGit to return the status of the working tree.
<p>
<p>
<a name="remarks"></a><b><u>Remarks</u></b>
<p>
    In Stata 13 and above, <b>stgit</b> requires the SSC package <b>statajava</b>.  You
    must also download the JGit <b>.jar</b> file. (On the download page, it may be
    called the "raw API library.") Place the <b>.jar</b> file on your ado-path.  For
    instance, you may save it in your PERSONAL system directory.  On your
    computer, this is <b>C:\ado\personal/</b>.
<p>
    <b>stgit</b> respects version control when deciding which values to retrieve.
    Even in Stata 13 and above, if the command interpreter is set to before
    version 13, <b>stgit</b> does not use JGit, and returns limited information.
<p>
    One use of <b>stgit</b> is adding commit hashes to dataset notes and to exported
    results such as tables. This facilitates reproducible research,
    pinpointing the code that produced the files.
<p>
    The GitHub repository for <b>stgit</b> is here.
<p>
<p>
<a name="options"></a><b><u>Options</u></b>
<p>
    <b>git_dir()</b> specifies the path of GIT_DIR, the repository metadata
        directory. This is typically named <b>.git</b>.  If <b>git_dir()</b> is not
        specified, <b>stgit</b> attempts to find GIT_DIR; it assumes that the
        current working directory is within the Git repository.  Whether or
        not <b>git_dir()</b> is specified, <b>stgit</b> stores the absolute path of GIT_DIR
        in <b>r(git_dir)</b>.
<p>
<p>
<a name="examples"></a><b><u>Examples</u></b>
<p>
    Retrieve information about the repository within which the current
    working directory is located
        <b>stgit</b>
<p>
    Same as the previous <b>stgit</b> command
        <b>stgit status</b>
<p>
    Retrieve information about the repository whose GIT_DIR is
    <b>GitHub/cfout/.git</b>
        <b>stgit, git_dir("GitHub/cfout/.git")</b>
<p>
<p>
<a name="results"></a><b><u>Stored results</u></b>
<p>
    In Stata 9 and above, <b>stgit</b> stores the following in <b>r()</b>:
<p>
    Scalars
      <b>r(has_detached_head)</b>   <b>1</b> if HEAD is detached, <b>0</b> if not
<p>
    Macros
      <b>r(git_dir)</b>             absolute path of GIT_DIR
      <b>r(sha)</b>                 SHA-1 hash of current commit
      <b>r(branch)</b>              name of current branch or <b>r(sha)</b> if HEAD is
                               detached
<p>
    In Stata 13 and above, <b>stgit</b> also stores the following in <b>r()</b>.  <b>stgit</b>
    retrieves these values using the JGit class <b>org.eclipse.jgit.api.Status</b>,
    and much of the language below is copied from that class's API (version
    3.5.3).
<p>
    Scalars
      <b>r(is_clean)</b>                  <b>1</b> if no differences exist between the
                                     working tree, the index, and the current
                                     HEAD, <b>0</b> if differences do exist
      <b>r(has_uncommitted_changes)</b>   <b>1</b> if any tracked file is changed, <b>0</b> if not
<p>
    Macros
      <b>r(untracked)</b>              list of files that are not ignored and not in
                                  the index (e.g., what you get if you create
                                  a new file without adding it to the index)
      <b>r(untracked_folders)</b>      list of directories that are not ignored and
                                  not in the index
      <b>r(uncommitted_changes)</b>    list of files and folders that are known to
                                  the repository and changed either in the
                                  index or in the working tree
      <b>r(added)</b>                  list of files added to the index, not in HEAD
                                  (e.g., what you get if you call <b>git add ...</b>
                                  on a newly created file)
      <b>r(modified)</b>               list of files modified on disk relative to
                                  the index (e.g., what you get if you modify
                                  an existing file without adding it to the
                                  index)
      <b>r(changed)</b>                list of files changed from HEAD to index
                                  (e.g., what you get if you modify an
                                  existing file and call <b>git add ...</b> on it)
      <b>r(missing)</b>                list of files in index but not filesystem
                                  (e.g., what you get if you call <b>rm ...</b> on
                                  an existing file)
      <b>r(removed)</b>                list of files removed from index, but in HEAD
                                  (e.g., what you get if you call <b>git rm ...</b>
                                  on an existing file)
      <b>r(conflicting)</b>            list of files that are in conflict (e.g.,
                                  what you get if you modify a file that was
                                  modified by someone else in the meantime)
      <b>r(ignored_not_in_index)</b>   list of files and folders that are ignored
                                  and not in the index
<p>
<p>
<a name="author"></a><b><u>Author</u></b>
<p>
    Matthew White, Innovations for Poverty Action
    mwhite@poverty-action.org
<p>
<p>
<b><u>Also see</u></b>
<p>
    User-written:  <b>git</b>
</pre>
