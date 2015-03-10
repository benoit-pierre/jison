#! /bin/bash

set -x

[ -r "$HOME/.makepkg.conf" ] && . "$HOME/.makepkg.conf"

cd "$(dirname "$0")" &&
. ./PKGBUILD &&
pkgver="$(python2 -c "import json; print json.load(open('../package.json'))['version']")" &&
verrev="$(git blame -L '/^\s*"version": /,+1' -l ../package.json | cut -c -40)" &&
pkgver="$pkgver.$(git rev-list --count "$verrev..").$(git log -1 --pretty='format:%h')" &&
src="src/$pkgname-$pkgver" &&
rm -rf src pkg &&
mkdir -p "$src" &&
sed "s/^pkgver=.*\$/pkgver=$pkgver/" PKGBUILD >PKGBUILD.tmp &&
(cd "$OLDPWD" && git ls-files -z | xargs -0 cp -a --no-dereference --parents --target-directory="$OLDPWD/$src") &&
export PACKAGER="${PACKAGER:-`git config user.name` <`git config user.email`>}" &&
makepkg --noextract --force -p PKGBUILD.tmp &&
rm -rf src pkg PKGBUILD.tmp &&
sudo pacman -U --noconfirm "$pkgname-$pkgver-$pkgrel-any${PKGEXT:-.pkg.tar.xz}"

