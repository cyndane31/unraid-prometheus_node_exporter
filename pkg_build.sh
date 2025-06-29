# Clone repository and compile Node Exporter
BASE_GITURL='https://github.com/prometheus/node_exporter'
PLUGIN_NAME=prometheus_node_exporter
ARCH='linux-amd64'
WORKING_DIR="$(pwd)"

# Get latest version number from prometheus github
VERSION=$(curl -Ls -o /dev/null -w '%{url_effective}' "$BASE_GITURL/releases/latest")
VERSION="${VERSION##*/}"

BUILD_DIR="${BUILD_DIR:-/tmp/unraid-$PLUGIN_NAME/$VERSION}"

DOWNLOAD_FILE="node_exporter-${VERSION:1}.$ARCH.tar.gz"

curl -fsSLO --create-dirs --output-dir "$BUILD_DIR" "$BASE_GITURL/releases/download/$VERSION/$DOWNLOAD_FILE"
mkdir -p $WORKING_DIR/source/usr/bin $WORKING_DIR/packages
tar -xvzf "$BUILD_DIR/$DOWNLOAD_FILE" --strip-components=1 -C "source/usr/bin" "${DOWNLOAD_FILE%%.tar*}/node_exporter"

cd $WORKING_DIR/source

DATE=$(date +'%Y.%m.%d')
makepkg -l y -c y "$WORKING_DIR/packages/$PLUGIN_NAME-$DATE.tgz"
MD5=$(md5sum "$WORKING_DIR/packages/$PLUGIN_NAME-$DATE.tgz" | awk '{print $1}')
echo "$MD5" >"$WORKING_DIR/packages/$PLUGIN_NAME-$DATE.tgz.md5"

sed -i -r "s/(ENTITY version\s*\")[^\"]+\"/\1$DATE\"/" "$WORKING_DIR/prometheus_node_exporter.plg"
sed -i -r "s/(ENTITY md5\s*\")[^\"]+\"/\1$MD5\"/" "$WORKING_DIR/prometheus_node_exporter.plg"
