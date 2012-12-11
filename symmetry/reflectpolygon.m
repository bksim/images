%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reflectpolygon.m
% brandon sim, 12/11/2012
% 
% Reflects a polygon across a line of given angle.
%
% usage: reflectpolygon(polygon, angle, centroid)
%
% polygon: an m-by-2 matrix, containing the (x,y) coordinates in each row
% of the m-th vertex of polygon1.
%
% angle: angle in degrees of axis of symmetry, measured from the
% horizontal (x-axis)
%
% centroid: a 2-by-1 matrix, containing the coordinates of the centroid of
% the image [x_c; y_c]
%
% returns: an m-by-2 matrix, containing the (x,y) coordinates in each row
% of the m-th vertex of the input polygon, reflected across a line going
% through the centroid with angle (angle).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function reflectedpolygon = reflectpolygon(polygon, angle, centroid)
    polygon = polygon';
    m = length(polygon);
    
    % subtracts [x_c; y_c] from each column in polygon
    % transforms to our shifted coordinate system
    polygonshift = polygon - repmat(centroid,1,m);
    
    % defines rotation matrix
    T = [cosd(2*angle) sind(2*angle);sind(2*angle) -cosd(2*angle)];
    
    % rotates the polygon's vertices across line,
    % transforms back to our original coordinate system
    reflectedpolygon = round(((T*polygonshift) + repmat(centroid,1,m))');
end
