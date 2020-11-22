#!/bin/bash -ex

if [ -z "$INPUT_PKGBUILD" ] || [ -z "$INPUT_OUTDIR" ] || [ -z "$GITHUB_SHA" ]; then
    echo 'Missing environment variables'
    exit 1
fi

# Resolve environment paths
INPUT_PKGBUILD="$(eval echo $INPUT_PKGBUILD)"
INPUT_OUTDIR="$(eval echo $INPUT_OUTDIR)"

# Prepare the environment
pacman -Syu --noconfirm --noprogressbar --needed base-devel devtools btrfs-progs dbus sudo

dbus-uuidgen --ensure=/etc/machine-id

sed -i "s|MAKEFLAGS=.*|MAKEFLAGS=-j$(nproc)|" /etc/makepkg.conf

useradd -m user
cd /home/user

# Enable auto-key-retrieve
mkdir .gnupg
cat <<EOF >> .gnupg/gpg.conf
keyserver-options auto-key-retrieve
auto-key-locate https://keyserver.ubuntu.com
EOF
chown -R user .gnupg
chmod 600 .gnupg/gpg.conf
export GNUPGHOME=/home/user/.gnupg

# Copy PKGBUILD and *.install scripts
cp "$INPUT_PKGBUILD"/* ./ || true
chown user PKGBUILD

# Build the package
extra-x86_64-build -- -U user $(echo $INPUT_PARAM)

# Save the artifacts
mkdir -p "$INPUT_OUTDIR"
cp $(ls *.pkg.* | grep -v '\.log$') "$INPUT_OUTDIR"/

pkg_path=$(ls -d "$INPUT_OUTDIR"/*)
pkg_name=$(ls "$INPUT_OUTDIR")
echo "::set-output name=pkg_path::$pkg_path"
echo "::set-output name=pkg_name::$pkg_name"
