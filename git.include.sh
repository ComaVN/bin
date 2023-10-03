# shared functions for including in git helper scripts.

DEFAULT_REMOTE_NAMES='origin upstream'
DEFAULT_BRANCH_NAMES='main master'

get_default_remote() {
    remotes=$(git remote)
    if [ -z "$remotes" ]; then
        # echo "DEBUG: No remotes." >&2
        return
    fi
    for r in $DEFAULT_REMOTE_NAMES; do
        if printf -- '%s' "$remotes" | grep "^$r$" > /dev/null; then
            # echo "DEBUG: Found default remote '$r'." >&2
            printf -- '%s' "$r"
            return
        fi
    done
    # echo "DEBUG: No remote with a customary name found. Use the first remote instead." >&2
    printf -- '%s' "$remotes" | head -n1
}

get_default_branch() {
    local remote=$1
    if [ -z "$remote" ]; then
        printf -- ' *** ERROR: First argument to get_default_branch must be the name of a remote.\n\n' >&2
        exit 1
    fi
    if ! git check-ref-format "$remote/foo"; then
        printf -- ' *** ERROR: Invalid name for remote.\n\n' >&2
        exit 1
    fi
    if b=$(git symbolic-ref --short --quiet "refs/remotes/$remote/HEAD"); then
        # echo "DEBUG: Found the default branch '$b' of remote '$remote'." >&2
        printf -- '%s' "$b" | sed -E 's/^[^/]+\///'
        return
    fi
    # echo "DEBUG: No default branch defined on remote '$remote'." >&2
    # See <https://stackoverflow.com/questions/17639383/how-to-add-missing-origin-head-in-git-repo/17639471#17639471>.
    # TL;DR: <remote>/HEAD only exists on cloned repos.
    branches=$(git branch --remote --format='%(refname:short)')
    for b in $DEFAULT_BRANCH_NAMES; do
        if printf -- '%s' "$branches" | grep "^$remote/$b$" > /dev/null; then
            printf -- '%s' "$b"
            # echo "DEBUG: Found default branch '$b' on remote '$remote'." >&2
            return
        fi
    done
    # echo "DEBUG: no branch with a customary name found on remote '$remote'. Trying local branches instead." >&2
    branches=$(git branch --format='%(refname:short)')
    for b in $DEFAULT_BRANCH_NAMES; do
        if printf -- '%s' "$branches" | grep "^$b$" > /dev/null; then
            printf -- '%s' "$b"
            # echo "DEBUG: Found default branch '$b' locally." >&2
            return
        fi
    done
    # echo "DEBUG: No branch with a customary name found at all, locally or on remote '$remote'." >&2
}
