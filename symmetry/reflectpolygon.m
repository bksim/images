%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reflectpolygon.m
% brandon sim, 12/11/2012
% 
% Reflects a polygon across a line of given angle.
%
% usage: reflectpolygon(polygon, angle, centroid)
%
% polygon: an m-by-2 matrix, containing the (r,c) coordinates in each row
% of the m-th vertex of polygon1.
%
% where (r,c) is the (row, col) of the matrix containing the image
%
% angle: angle in degrees of axis of symmetry, measured from the
% horizontal (x-axis)
%
% centroid: a 2-by-1 matrix, containing the coordinates of the centroid of
% the image [x_c; y_c]
% where [x_c; y_c] is standard image format where (0,0) is top left and x
% increases going right, y increases going down
%
% returns: an m-by-2 matrix, containing the (r,c) coordinates in each row
% of the m-th vertex of the input polygon, reflected across a line going
% through the centroid with angle (angle).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function reflectedpolygon = reflectpolygon(polygon, angle, centroid)
    polygon = polygon';
    
    m = size(polygon,2);
    
    % (r,c)->(c-x_c, -r+y_c)
    % transforms to our shifted coordinate system
    polygonshift = [0 1;-1 0]*polygon + ...
        repmat([-centroid(1);centroid(2)],1,m);
    
    % defines rotation matrix
    T = [cosd(2*angle) sind(2*angle);sind(2*angle) -cosd(2*angle)];
    
    % rotates the polygon's vertices across line,
    % transforms back to our original coordinate system
    reflectedpolygon = round(([0 -1;1 0]*(T*polygonshift) + ...
        repmat([centroid(2);centroid(1)],1,m))');
end
