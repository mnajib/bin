
#
# On laptops with NVIDIA Optimus, Nouveau is installed by default. When you try to install closed-source driver of NVIDIA, it's possible to switch between NVIDIA and INTEL video driver via NVIDIA's control center.
# But what if I don't want to install the closed-source driver, will I be able to switch to INTEL driver from Nouveau? How?
#
# Yes you can. By default, the system will be use Intel as primary gfx of your system if you use Nouveau driver. If you want to use your Nvidia gfx you need to add DRI_PRIME=1 in front of your application launcher or executable like this one DRI_PRIME=1 yourApps. You can try doing test in your terminal using command bellow
#


#xrandr --setprovideroffloadsink nouveau Intel 


glxinfo | grep "OpenGL"
#OpenGL vendor string: Intel Open Source Technology Center
#OpenGL renderer string: Mesa DRI Intel(R) HD Graphics 4600 (HSW GT2)
#OpenGL core profile version string: 4.5 (Core Profile) Mesa 21.0.1
#OpenGL core profile shading language version string: 4.50
#OpenGL core profile context flags: (none)
#OpenGL core profile profile mask: core profile
#OpenGL core profile extensions:
#OpenGL version string: 3.0 Mesa 21.0.1
#OpenGL shading language version string: 1.30
#OpenGL context flags: (none)
#OpenGL extensions:
#OpenGL ES profile version string: OpenGL ES 3.1 Mesa 21.0.1
#OpenGL ES profile shading language version string: OpenGL ES GLSL ES 3.10
#OpenGL ES profile extensions:

echo ""
echo "--------------------------------------------------"
DRI_PRIME=1 glxinfo | grep "OpenGL"
#OpenGL vendor string: nouveau
#OpenGL renderer string: NVE6
#OpenGL core profile version string: 4.3 (Core Profile) Mesa 21.0.1
#OpenGL core profile shading language version string: 4.30
#OpenGL core profile context flags: (none)
#OpenGL core profile profile mask: core profile
#OpenGL core profile extensions:
#OpenGL version string: 4.3 (Compatibility Profile) Mesa 21.0.1
#OpenGL shading language version string: 4.30
#OpenGL context flags: (none)
#OpenGL profile mask: compatibility profile
#OpenGL extensions:
#OpenGL ES profile version string: OpenGL ES 3.2 Mesa 21.0.1
#OpenGL ES profile shading language version string: OpenGL ES GLSL ES 3.20
#OpenGL ES profile extensions:
