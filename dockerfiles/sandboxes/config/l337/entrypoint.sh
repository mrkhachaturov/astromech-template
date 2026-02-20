#!/bin/bash
set -euo pipefail

hvault start >/proc/1/fd/1 2>/proc/1/fd/2 &

exec "$@"
