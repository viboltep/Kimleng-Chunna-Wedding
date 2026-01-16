#!/bin/bash
# Build script for Flutter web with disabled icon tree-shaking
# This is needed due to Khmer font compatibility issues

flutter build web --release --no-tree-shake-icons

echo "Build completed! Output is in build/web"
