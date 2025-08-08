#!/bin/bash

set -e

APP_NAME="projex"
VERSION="1.0.0"
VENV_DIR="packvenv"
LAUNCHER="projex-launcher.sh"

# 1. Clean up old build (optional)
rm -rf "$VENV_DIR" "$LAUNCHER" package-root

# 2. Create virtualenv
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

# 3. Install your package into the venv
pip install --upgrade pip
pip install .

deactivate

# 4. Create launcher script
cat > "$LAUNCHER" <<EOF
#!/bin/bash
DIR="\$(dirname "\$(realpath "\$0")")"
exec "\$DIR/../lib/$APP_NAME/$VENV_DIR/bin/python" -m $APP_NAME "\$@"
EOF

chmod +x "$LAUNCHER"

# 5. Arrange folder layout for packaging
mkdir -p package-root/usr/bin
mkdir -p package-root/usr/lib/$APP_NAME

cp "$LAUNCHER" package-root/usr/bin/$APP_NAME
cp -r "$VENV_DIR" package-root/usr/lib/$APP_NAME/

# 6. Package with FPM
fpm -s dir -t deb -n "$APP_NAME" -v "$VERSION" -C package-root \
    --prefix=/ \
    --description "Packaged Python app with built-in virtualenv" \
    --license "MIT" \
    --maintainer "you@example.com" \
    --after-install <(echo "#!/bin/true") \
    usr/

fpm -s dir -t rpm -n "$APP_NAME" -v "$VERSION" -C package-root \
    --prefix=/ usr/

fpm -s dir -t tar -n "$APP_NAME" -v "$VERSION" -C package-root \
    --prefix=/ usr/
