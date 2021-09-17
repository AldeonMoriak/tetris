#!/usr/bin/env sh

# abort on errors
set -e

# build
npm run build --base=/tetris/

# navigate into the build output directory
cd dist

# if you are deploying to a custom domain
# echo 'www.example.com' > CNAME

git init
git add .
git commit -m 'deploy'
git checkout -b gh-pages

# if you are deploying to https://<USERNAME>.github.io
# git push -f git@github.com:<USERNAME>/<USERNAME>.github.io.git master

# if you are deploying to https://<USERNAME>.github.io/<REPO>
git push -f https://github.com/AldeonMoriak/tetris.git gh-pages

cd -