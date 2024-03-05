#!/usr/bin/env bash
#
# References:
#   - https://github.com/NixOS/nixpkgs/issues/71752
#

export JAVA_TOOL_OPTIONS="-Dcom.eteks.sweethome3d.j3d.useOffScreen3DView=true"
sweethome3d

#MESA_GL_VERSION_OVERRIDE=3.0 sweethome3d
