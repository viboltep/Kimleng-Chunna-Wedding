#!/bin/bash
# Build script for Flutter web with --no-tree-shake-icons flag
# This prevents IconTreeShakerException errors

flutter build web --release --no-tree-shake-icons
