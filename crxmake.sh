#!/bin/bash -e
#
# Purpose: Pack a Chromium extension directory into crx format
#


# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
#  find bash working directory and build from there
#
bash_source="${BASH_SOURCE[0]}"
# resolve $bash_source until the file is no longer a symlink
while [ -h "$bash_source" ]; do
	cwd="$(cd -P "$(dirname "$bash_source")" && pwd)"
	bash_source="$(readlink "$bash_source")"
	# if $bash_source was a relative symlink, we need to resolve it relative to the path where the symlink file was located
	[[ $bash_source != /* ]] && bash_source="$cwd/$bash_source"
done
cwd="$(cd -P "$(dirname "$bash_source" )" && pwd)"

# args
if test $# -lt 2; then
	echo "Usage:"
	echo "crxmake.sh <extension dir> <pem path> [output.crx]"
	echo ""
	echo "crxmake.sh src extension/slackdraw.js.pem extension/slackdraw.js.crx"
	echo "crxmake.sh src extension/slackdraw.js.pem extension/slackdraw.js.crx version.txt"
	echo ""
	exit 1
else
	src=$1
	pem=$2

	if test $# -eq 3; then
		dest=$3
	elif test $# -eq 4; then
		dest=$3
		fver=$4
	fi
fi

# do build versioning
if test ${#fver} -gt 0; then
	# sed increment build revision
	orig_version=$(head -n 1 "$cwd/$fver")
	(sed -r -i"" 's/^([0-9]+\.[0-9]\.)([0-9]+)/echo \1$((\2+1))/e' "$cwd/$fver")
	new_version=$(head -n 1 "$cwd/$fver")

	# bump update_manifest
	sed_update_manifest="s/\.crx\" version=\".*\\?\"/\.crx\" version=\"$new_version\"/"
	(sed -i"" "$sed_update_manifest" "$cwd/update_manifest.xml")

	# bump manifest
	sed_src_manifest="s/\"version\": \".*\\?\"/\"version\": \"$new_version\"/"
	(sed -i"" "$sed_src_manifest" "$cwd/src/manifest.json")
fi

# build vars
name=$(basename "$src")
crx="$name.crx"
pub="$name.pub"
sig="$name.sig"
zip="$name.zip"
trap 'rm -f "$pub" "$sig" "$zip"' EXIT

# zip up the crx dir
(cd "$src" && zip -qr -9 -X "$cwd/$zip" .  -x \*.rcs\*)

# signature
openssl sha1 -sha1 -binary -sign "$pem" < "$zip" > "$sig"

# public key
openssl rsa -pubout -outform DER < "$pem" > "$pub" 2>/dev/null

# byte swap
byte_swap () {
	# take "abcdefgh" and return it as "ghefcdab"
	echo "${1:6:2}${1:4:2}${1:2:2}${1:0:2}"
}

crmagic_hex="4372 3234" # Cr24
version_hex="0200 0000" # 2
pub_len_hex=$(byte_swap $(printf '%08x\n' $(ls -l "$pub" | awk '{print $5}')))
sig_len_hex=$(byte_swap $(printf '%08x\n' $(ls -l "$sig" | awk '{print $5}')))
(
	echo "$crmagic_hex $version_hex $pub_len_hex $sig_len_hex" | xxd -r -p
	cat "$pub" "$sig" "$zip"
) > "$crx"


if test ${#dest} -gt 0; then
	mv "$crx" "$dest"
	echo "Wrote $dest"
else
	echo "Wrote $crx"
fi
