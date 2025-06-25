# Clone repository and compile Node Exporter
BASE_GITURL='https://github.com/prometheus/node_exporter'
PLUGIN_NAME=prometheus_node_exporter
ARCH='linux-amd64'
PWD="$(pwd)"

# Get latest version number from prometheus github
VERSION=$(curl -Ls -o /dev/null -w '%{url_effective}' "$BASE_GITURL/releases/latest")
VERSION="${VERSION##*/}"

BUILD_DIR="${BUILD_DIR:-/tmp/unraid-$PLUGIN_NAME/$VERSION}"

DOWNLOAD_FILE="node_exporter-${VERSION:1}.$ARCH.tar.gz"

curl -fsSLO --create-dirs --output-dir "$BUILD_DIR" "$BASE_GITURL/releases/download/$VERSION/$DOWNLOAD_FILE"
mkdir -p $PWD/source/usr/bin $PWD/packages
tar -xvzf "$BUILD_DIR/$DOWNLOAD_FILE" --strip-components=1 -C "source/usr/bin" "${DOWNLOAD_FILE%%.tar*}/node_exporter"

cd $PWD/source

makepkg -l y -c y "$PWD/packages/$PLUGIN_NAME-$VERSION.tgz"
MD5=$(md5sum "$PWD/packages/$PLUGIN_NAME-$VERSION.tgz" | awk '{print $1}')
echo "$MD5" >"$PWD/packages/$PLUGIN_NAME-$VERSION.tgz.md5"

sed -i -e "s/(ENTITY version \")[^\"]+\"/\1$LATEST\"/" "$PWD/prometheus_node_exporter.plg"
sed -i -e "s/(ENTITY md5 \")[^\"]+\"/\1$MD5\"/" "$PWD/prometheus_node_exporter.plg"

# sed -r 's/(enable-welcome-root=")[^"]+"/\1true"/'
# sed    's/\(enable-welcome-root="\)[^"]+"/\1true"/'
# <!ENTITY md5       "bc7fe61f4dc29b2960e33b5dab8a9263">

# Usage: makepkg package_name.tgz
#        (or: package_name.tbz, package_name.tlz, package_name.txz)

# Makes a Slackware compatible package containing the contents of the current
# and all subdirectories. If symbolic links exist, they will be removed and
# an installation script will be made to recreate them later. This script will
# be called "install/doinst.sh". You may add any of your own ash-compatible
# shell scripts to this file and rebuild the package if you wish.

# options:  -l, --linkadd y|n (moves symlinks into doinst.sh: recommended)
#           -p, --prepend (prepend rather than append symlinks to an existing
#                doinst.sh.  Useful to link libraries needed by programs in
#                the doinst.sh script)
#           -c, --chown y|n (resets all permissions to root:root 755 - not
#                generally recommended)
#           --threads <number> For xz/plzip compressed packages, set the max
#                number of threads to be used for compression. Only has an
#                effect on large packages. For plzip, the default is equal to
#                the number of CPU threads available on the machine. For xz,
#                the default is equal to 2 (due to commonly occuring memory
#                related failures when using many threads with multi-threaded
#                xz compression).
#           --compress <option> Supply a custom option to the compressor.
#                This will be used in place of the default, which is: -9
#           --acls Support storing POSIX ACLs in the package. The resulting
#                package will not be compatible with pkgtools version < 15.0.
#           --xattrs Support storing extended attributes in the package. The
#                resulting package will not be compatible with pkgtools
#                version < 15.0.
#           --remove-rpaths (remove all rpaths from ELF objects)
#           --remove-tmp-rpaths (remove rpaths from ELF objects if we find one
#                that contains '/tmp')

# If these options are not set, makepkg will prompt if appropriate.
# # Create directories and copy files to destination
# mkdir -p "${BUILD_DIR}/v${VERSION}"
# mkdir -p "${BUILD_DIR}/${VERSION}/usr/bin"
# mkdir -p "${BUILD_DIR}/${VERSION}/usr/local/emhttp/plugins/prometheus_node_exporter/images"
# cp "${BUILD_DIR}/node_exporter/node_exporter" "${BUILD_DIR}/$VERSION/usr/bin/prometheus_node_exporter"

# # Download icon to destination
# cp prometheus.png "${BUILD_DIR}/${VERSION}/usr/local/emhttp/plugins/prometheus_node_exporter/images/prometheus_node_exporter.png"
# cd "${BUILD_DIR}/${VERSION}"
# chmod -R 755 "${BUILD_DIR}/$VERSION"

# # Create Slackware package
# makepkg -l y -c y "${BUILD_DIR}/v$VERSION/$PLUGIN_NAME-$VERSION.tgz"
# cd "${BUILD_DIR}/v$VERSION"
# md5sum "$PLUGIN_NAME-$VERSION.tgz" | awk '{print $1}' >"$PLUGIN_NAME-$VERSION.tgz.md5"

# OUTPUT_DIR="/tmp/$EXE/"

# if [ "$CURRENT" == "$VERSION" -a -x /usr/local/bin/$EXE ]; then
#   echo "$EXE already installed"
# else
#   echo "$VERSION" >"$VERS_FILE"
#   echo "Extracting to /usr/local/bin"
#   chmod +x "/usr/local/bin/$EXE"
#   echo "$EXE installed to /usr/local/bin"
# fi
