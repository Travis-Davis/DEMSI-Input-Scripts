clear
clc

num_particles = 10000;
density = 900;
n = (1:num_particles)';
diam = [];

for i = 1:length(n);
    diam(i) = abs(random('Normal',5000,1000));
end

mass = pi*(diam/2).^2*density;
zlim = max(diam)/2;
dia = max(diam)
minmass = min(mass);

fileID = fopen('atoms.in','w');

fprintf(fileID,'###################\n');
fprintf(fileID,'# Atom Parameters #\n');
fprintf(fileID,'###################\n\n');

fprintf(fileID,'boundary f f p\n\n');

fprintf(fileID,sprintf('variable minmass equal %f\n',minmass))
fprintf(fileID,sprintf('variable zlim equal %f\n',zlim))
fprintf(fileID,sprintf('variable dia equal %f\n',dia))

fprintf(fileID,'variable x0 equal 0\n')
fprintf(fileID,'variable x1 equal ${simlx}\n')
fprintf(fileID,'variable y0 equal 0\n')
fprintf(fileID,'variable y1 equal ${simly}\n\n')

fprintf(fileID,'region simbox block ${x0} ${x1} ${y0} ${y1} -${zlim} ${zlim}\n')
fprintf(fileID,'region atmbox block ${ax0} ${ax1} ${ay0} ${ay1} -${zlim} ${zlim}\n\n')

fprintf(fileID,'create_box 1 simbox\n\n')

fprintf(fileID,'lattice hex ${zlim} origin 0.5 0.5 0\n')
fprintf(fileID,'create_atoms 1 region atmbox\n\n')
%fprintf(fileID,'create_atoms 1 random ${natom} 1 atmbox\n\n')

for i =  1:num_particles
    fprintf(fileID,sprintf('set   atom %G diameter %f\n',n(i),diam(i)));
    fprintf(fileID,sprintf('set   atom %G mass %f\n',n(i),mass(i)));
end

fprintf(fileID,'\ncompute rad all property/atom radius\n')
fprintf(fileID,'variable area atom PI*c_rad^2')