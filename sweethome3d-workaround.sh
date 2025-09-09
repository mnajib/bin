#!/usr/bin/env bash
#
# References:
#   - https://github.com/NixOS/nixpkgs/issues/71752
#

test_start_original() {
  XDG_DATA_DIRS=${XDG_DATA_DIRS:+':'$XDG_DATA_DIRS':'}
  XDG_DATA_DIRS=${XDG_DATA_DIRS/':''/nix/store/crnn65dvmch9y0y3d831156xa6hld9z4-gtk+3-3.24.43/share/gsettings-schemas/gtk+3-3.24.43'':'/':'}
  XDG_DATA_DIRS='/nix/store/crnn65dvmch9y0y3d831156xa6hld9z4-gtk+3-3.24.43/share/gsettings-schemas/gtk+3-3.24.43'$XDG_DATA_DIRS
  XDG_DATA_DIRS=${XDG_DATA_DIRS#':'}
  XDG_DATA_DIRS=${XDG_DATA_DIRS%':'}
  export XDG_DATA_DIRS

  XDG_DATA_DIRS=${XDG_DATA_DIRS:+':'$XDG_DATA_DIRS':'}
  XDG_DATA_DIRS=${XDG_DATA_DIRS/':''/nix/store/mfbc5gx2c3k9mnhbqdw9f26dnsijfb99-gsettings-desktop-schemas-47.1/share/gsettings-schemas/gsettings-desktop-schemas-47.1'':'/':'}
  XDG_DATA_DIRS='/nix/store/mfbc5gx2c3k9mnhbqdw9f26dnsijfb99-gsettings-desktop-schemas-47.1/share/gsettings-schemas/gsettings-desktop-schemas-47.1'$XDG_DATA_DIRS
  XDG_DATA_DIRS=${XDG_DATA_DIRS#':'}
  XDG_DATA_DIRS=${XDG_DATA_DIRS%':'}
  export XDG_DATA_DIRS

  XDG_DATA_DIRS=${XDG_DATA_DIRS:+':'$XDG_DATA_DIRS':'}
  XDG_DATA_DIRS=${XDG_DATA_DIRS/':''/nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share'':'/':'}
  XDG_DATA_DIRS='/nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share'$XDG_DATA_DIRS
  XDG_DATA_DIRS=${XDG_DATA_DIRS#':'}
  XDG_DATA_DIRS=${XDG_DATA_DIRS%':'}
  export XDG_DATA_DIRS

  XDG_DATA_DIRS=${XDG_DATA_DIRS:+':'$XDG_DATA_DIRS':'}
  XDG_DATA_DIRS=${XDG_DATA_DIRS/':''/nix/store/mfbc5gx2c3k9mnhbqdw9f26dnsijfb99-gsettings-desktop-schemas-47.1/share'':'/':'}
  XDG_DATA_DIRS='/nix/store/mfbc5gx2c3k9mnhbqdw9f26dnsijfb99-gsettings-desktop-schemas-47.1/share'$XDG_DATA_DIRS
  XDG_DATA_DIRS=${XDG_DATA_DIRS#':'}
  XDG_DATA_DIRS=${XDG_DATA_DIRS%':'}
  export XDG_DATA_DIRS

  XDG_DATA_DIRS=${XDG_DATA_DIRS:+':'$XDG_DATA_DIRS':'}
  XDG_DATA_DIRS=${XDG_DATA_DIRS/':''/nix/store/crnn65dvmch9y0y3d831156xa6hld9z4-gtk+3-3.24.43/share'':'/':'}
  XDG_DATA_DIRS='/nix/store/crnn65dvmch9y0y3d831156xa6hld9z4-gtk+3-3.24.43/share'$XDG_DATA_DIRS
  XDG_DATA_DIRS=${XDG_DATA_DIRS#':'}
  XDG_DATA_DIRS=${XDG_DATA_DIRS%':'}
  export XDG_DATA_DIRS

  LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+':'$LD_LIBRARY_PATH':'}
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH/':''/nix/store/gn0ldbvcycvb8zplaic6bk9hkl6ky5px-libglvnd-1.7.0/lib'':'/':'}
  LD_LIBRARY_PATH='/nix/store/gn0ldbvcycvb8zplaic6bk9hkl6ky5px-libglvnd-1.7.0/lib'$LD_LIBRARY_PATH
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH#':'}
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH%':'}
  export LD_LIBRARY_PATH

  #exec "/nix/store/kpz0k1m0l8d67qazlippkaq5a60rhs4d-openjdk-21.0.5+11/bin/java"  -Dsun.java2d.opengl=true -jar /nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/SweetHome3D-7.5.jar -cp /nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/Furniture.jar:/nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/Textures.jar:/nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/Help.jar -d64 "$@" 

  #exec "java"  -Dsun.java2d.opengl=true -jar /nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/SweetHome3D-7.5.jar -cp /nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/Furniture.jar:/nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/Textures.jar:/nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/Help.jar -d64 "$@"

  #exec "java"  -Dsun.java2d.opengl=false -jar /nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/SweetHome3D-7.5.jar -cp /nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/Furniture.jar:/nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/Textures.jar:/nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/Help.jar -d64 "$@"

  #exec "java" -jar /nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/SweetHome3D-7.5.jar -cp /nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/Furniture.jar:/nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/Textures.jar:/nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/Help.jar -d64 "$@"

  #exec "java" -Djogamp.gluegen.UseTempJarCache=false \
  #     -Djava.awt.headless=false \
  #     -Djogl.debug.DebugGL \
  #     -Dnewt.debug=all \
  #     -Dcom.eteks.sweethome3d.j3d.glProfile=GL2 \
  #     -jar /nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/SweetHome3D-7.5.jar -cp /nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/Furniture.jar:/nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/Textures.jar:/nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/Help.jar -d64 "$@"

  exec "java" \
       -Djogamp.gluegen.UseTempJarCache=false \
       -Djava.awt.headless=false \
       -Djogl.debug.DebugGL \
       -Dnewt.debug=all \
       -Dcom.eteks.sweethome3d.j3d.glProfile=GL2 \
       -jar /nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/SweetHome3D-7.5.jar -cp /nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/Furniture.jar:/nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/Textures.jar:/nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/Help.jar -d64 "$@"

  #exec "java" -Dcom.eteks.sweethome3d.j3d.softwareRenderer=true -jar /nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/SweetHome3D-7.5.jar
  #exec "java" -Dcom.eteks.sweethome3d.j3d.softwareRenderer=true -jar /nix/store/4x2hhjc5p7f9kdgb4zwaxsg3zz82iq6y-sweethome3d-application-7.5/share/java/SweetHome3D-7.5.jar
} # End test_start_original() { ... }

test_start_1() {
  export JAVA_TOOL_OPTIONS="-Dcom.eteks.sweethome3d.j3d.useOffScreen3DView=true"
  sweethome3d
}

test_start_2() {
  MESA_GL_VERSION_OVERRIDE=3.0 sweethome3d
}

test_start_1
