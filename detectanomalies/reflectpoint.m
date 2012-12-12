%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reflectpoint.m
% brandon sim, 12/11/2012
% 
% Reflects a point across a line of given angle.
%
% usage: reflectpolygon(point, angle, centroid)
%
% polygon: a 1-by-2 matrix, containing the (x,y) coordinates of the point
%
% angle: angle in degrees of axis of symmetry, measured from the
% horizontal (x-axis)
%
% centroid: a 2-by-1 matrix, containing the coordinates of the centroid of
% the image [x_c; y_c]
% where [x_c; y_c] is standard image format where (0,0) is top left and x
% increases going right, y increases going down
%
% returns: an 1-by-2 matrix, containing the (x,y) coordinates reflected 
% across a line going through the centroid with angle (angle).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function reflectedpoint = reflectpoint(point, angle, centroid)
    point = point';
    
    % (x,y) -> (x-x_c, y_c-y)
    % transforms to our shifted coordinate system
    pointshift = [1 0;0 -1]*point + [-centroid(1);centroid(2)];
    
    % defines rotation matrix
    T = [cosd(2*angle) sind(2*angle);sind(2*angle) -cosd(2*angle)];
    
    % rotates the point across line,
    % transforms back to our original coordinate system
    reflectedpoint = round(([1 0;0 -1]*(T*pointshift) + centroid)');
end
