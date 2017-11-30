clear
clc
close all

%% Coastline Gen
res = 100;   % Resolution of Coastline to be fed to LAMMPS
dim = 5000; % Mean Floe Diameter
%% Test Case
% Coast Starting Point
lx = 100*dim;
x_direct = 0;
y_direct = lx/4;

% Only positive x values to keep coastline left to right
for i = 1:res
    x_direct(i+1) = x_direct(i) + abs(random('Normal',5000,1000));
    y_direct(i+1) = y_direct(i) + random('Normal',0,2000);
end

% Coastline normalization for simulation domain
x_direct = x_direct * lx/x_direct(end-1);
y_direct = y_direct * lx/x_direct(end-1);

%% Box Generation
for i = 1:res
    box_i = 2*(i-1);
    if i == 1
        x_box(i) = x_direct(i);
        y_box(i) = y_direct(i);
    elseif i == res
        x_box(box_i) = x_direct(i);
        y_box(box_i) = y_direct(i);
    else
        x_box(box_i)   = x_direct(i);
        x_box(box_i+1) = x_direct(i);
        y_box(box_i)   = y_box(box_i-1);
        y_box(box_i+1) = y_direct(i+1);
    end
end

%% Validation
figure
hold on
plot(x_direct(1:end-1),y_direct(1:end-1),[0,lx],[lx/2,lx/2],'-r')
axis([0,lx,0,lx])

% draw regions
% Small regions centered on coast
% for i = 1:res-1
%     x_dim = x_direct(i+1) - x_direct(i);
%     if y_direct(i+1) > y_direct(i)
%         y_dim = y_direct(i+1) - y_direct(i);
%         rectangle('Position',[x_direct(i),y_direct(i),x_dim,y_dim])
%     else
%         y_dim = y_direct(i) - y_direct(i+1);
%         rectangle('Position',[x_direct(i),y_direct(i+1),x_dim,y_dim])
%     end
% end

% Large regions that extend from coast south to boundary
% for i = 1:res-1
%     x_dim = x_direct(i+1) - x_direct(i);
%     if y_direct(i+1) > y_direct(i)
%         y_dim = y_direct(i+1);
%         rectangle('Position',[x_direct(i),0,x_dim,y_dim])
%     else
%         y_dim = y_direct(i);
%         rectangle('Position',[x_direct(i),0,x_dim,y_dim])
%     end
% end

% Large regions that extend from coast north to boundary
for i = 1:res-1
    x_dim = x_direct(i+1) - x_direct(i);
    if y_direct(i+1) > y_direct(i) % positive slope
        y_dim = lx - y_direct(i);
        rectangle('Position',[x_direct(i),y_direct(i+1),x_dim,y_dim])
    else % negative slope
        y_dim = lx - y_direct(i+1);
        rectangle('Position',[x_direct(i),y_direct(i),x_dim,y_dim])
    end
end
hold off

%% LAMMPS .in Generation

fileID = fopen('coast.in','w');
fprintf(fileID,'###################\n')
fprintf(fileID,'#    Coastline    #\n')
fprintf(fileID,'###################\n')

% Small Regions centered on coast line
% for i = 1:res-1
%     x_dim = x_direct(i+1) - x_direct(i);
%     if y_direct(i+1) > y_direct(i)
%         y_dim = y_direct(i+1) - y_direct(i);
%         fprintf(fileID,'region coast%g block %f %f %f %f %f %f\n',...
%             i,x_direct(i),x_direct(i)+x_dim,...
%             y_direct(i),y_direct(i)+y_dim,...
%             -dim/2,dim/2)
%     else
%         y_dim = y_direct(i) - y_direct(i+1);
%         fprintf(fileID,'region coast%g block %f %f %f %f %f %f\n',...
%             i,x_direct(i),x_direct(i)+x_dim,...
%             y_direct(i+1),y_direct(i+1)+y_dim,...
%             -dim/2,dim/2)
%     end
% end

% Large Regions that extend from coast south to boundary
% for i = 1:res-1
%     x_dim = x_direct(i+1) - x_direct(i);
%     if y_direct(i+1) > y_direct(i)
%         y_dim = y_direct(i+1) - y_direct(i);
%         fprintf(fileID,'region coast%g block %f %f %f %f %f %f units box\n',...
%             i,x_direct(i),x_direct(i)+x_dim,...
%             0,y_direct(i)+y_dim,...
%             -dim/2,dim/2)
%     else
%         y_dim = y_direct(i) - y_direct(i+1);
%         fprintf(fileID,'region coast%g block %f %f %f %f %f %f units box\n',...
%             i,x_direct(i),x_direct(i)+x_dim,...
%             0,y_direct(i+1)+y_dim,...
%             -dim/2,dim/2)
%     end
% end

% Large Regions that extend from coast north to boundary
for i = 1:res-1
    if y_direct(i+1) > y_direct(i)
        y_dim = y_direct(i+1) - y_direct(i);
        fprintf(fileID,'region coast%g block %f %f %f %f %f %f units box\n',...
            i,floor(x_direct(i)),ceil(x_direct(i+1)),...
            y_direct(i+1),lx,...
            -dim/2,dim/2)
    else
        y_dim = y_direct(i) - y_direct(i+1);
        fprintf(fileID,'region coast%g block %f %f %f %f %f %f units box\n',...
            i,floor(x_direct(i)),ceil(x_direct(i+1)),...
            y_direct(i),lx,...
            -dim/2,dim/2)
    end
end

fprintf(fileID,'region coast union %g ',res-1)
for i = 1:res-1
    fprintf(fileID,'coast%g ',i)
end

%fprintf(fileID,'\n\nregion sim_box intersect 2 coast boxreg')
fprintf(fileID,'\nfix wall all wall/gran/region hooke ${kn} ${kt} ${damp} 0 ${coeffFric} 1 region coast')
%fprintf(fileID,'\ncreate_box	1 sim_box')