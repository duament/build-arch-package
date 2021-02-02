#!/bin/bash -ex

if [ -z "$INPUT_DIR" ] || [ -z "$TOKEN" ] || [ -z "$GITHUB_TOKEN" ] || [ -z "$GITHUB_API_URL" ] || [ -z "$GITHUB_REPOSITORY" ]; then
    echo 'Missing environment variables'
    exit 1
fi

# Resolve environment paths
INPUT_DIR="$(eval echo $INPUT_DIR)"

# Add custom repo
self_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cp $self_dir/pacman-duama.conf /etc/pacman.conf

# Prepare the environment
pacman -Syu --noconfirm --noprogressbar --needed base-devel devtools devtools-duama btrfs-progs dbus sudo jq

dbus-uuidgen --ensure=/etc/machine-id

sed -i "s|MAKEFLAGS=.*|MAKEFLAGS=-j$(nproc)|" /etc/makepkg.conf

useradd -m user
cd /home/user

# Copy PKGBUILD and other files
cp "$INPUT_DIR"/* ./ || true
chown user PKGBUILD

# Build the package
duama-x86_64-build -- -U user

rm -f *.log

basename=$(basename "$INPUT_DIR")
first_pkg_filename=$(ls *.pkg.tar.* | head -n 1)
t=${first_pkg_filename%-*}
pkgrel=${t##*-}
t=${t%-*}
pkgver=${t##*-}

# Create a release
res=$(curl \
    -X POST \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Content-type: application/json" \
    "$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/releases" \
    -d "{\"tag_name\":\"$basename-$(date +%Y%m%d%H%M)\", \"name\":\"$basename: $pkgver-$pkgrel\"}")

upload_url=$(echo "$res" | jq -r '.upload_url')
upload_url=${upload_url%\{*}

for filename in *.pkg.tar.*
do
    # Upload release asset
    res=$(curl \
        -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "Content-Type: $(file -b --mime-type $filename)" \
        --data-binary @$filename \
	"$upload_url?name=$filename")
    
    browser_download_url=$(echo "res" | jq -r '.browser_download_url')
    
    # Trigger repo-add
    curl \
        -X POST \
        -H "Token: $TOKEN" \
        'https://repo.duama.top/repo-add' \
        -d "$browser_download_url"
done

