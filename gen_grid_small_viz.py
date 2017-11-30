import numpy as np
import matplotlib.pyplot as plt
import struct

def vel_grid_to_vtk(basename, dx, dy, vx, vy):
    f = open(basename+".vtk", "w")
    f.write("# vtk DataFile Version 2.0\n")
    f.write("Grid-based velocities\n")
    f.write("ASCII\n")
    f.write("DATASET STRUCTURED_POINTS\n")
    f.write("DIMENSIONS "+str(vx.shape[0])+" "+str(vx.shape[1])+" 1\n")
    f.write("SPACING "+str(dx)+" "+str(dy)+" 1\n")
    f.write("ORIGIN 0 0 0\n")
    #f.write("ORIGIN "+str(vx.shape[0]/2)+" "+str(vx.shape[1]/2)+" 0\n")
    f.write("POINT_DATA "+str(vx.size)+"\n")
    f.write("VECTORS Veloctiy float\n")
    arr = np.vstack((vx.flatten(order='F'), vy.flatten(order='F'), np.zeros_like(vx).flatten(order='F'))).transpose()
    f.close()
    with open(basename+".vtk", "ab") as f:
        np.savetxt(f, arr.astype(np.float), fmt="%.4f", delimiter=" ")
    
nx=300
ny=300

lx=155.5
ly=155.5

dx, dy = lx/nx, ly/ny

omega = 0.5*0.001
lda = 8*10**5/10**6

xc, yc = 0.5*lx, 0.5*ly
ix, iy = np.indices((nx,ny))

rmag = np.sqrt((ix*dx - xc)**2 + (iy*dy-yc)**2)
rmag[rmag == 0] = 1e-10;

rxn = (ix*dx-xc)/rmag
ryn = (iy*dx-yc)/rmag
kx = -ryn
ky = rxn
prefac = np.minimum(omega*rmag, lda/rmag)
ugx = prefac*kx
ugy = prefac*ky

plt.quiver((ix*dx-xc)[::10,::10], (iy*dy-yc)[::10,::10], ugx[::10,::10], ugy[::10,::10])
plt.show()

vel_grid_to_vtk("test_grid_small",dx,dy,ugx,ugy)

