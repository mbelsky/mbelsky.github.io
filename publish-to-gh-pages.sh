#!/bin/sh

# If a command fails then the deploy stops
set -e

if [ "`git status -s`" ]
then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

echo "Deleting old publication"
make clean
mkdir public
git worktree prune
rm -rf .git/worktrees/public/

echo "Checking out gh-pages branch into public"
git worktree add -B gh-pages public origin/gh-pages

# echo "Generating site"
make build

# echo "Updating gh-pages branch"
cd public && git add --all && git commit -m "Publishing to gh-pages (publish-to-gh-pages.sh)"

# echo "Pushing to github"
git push --all