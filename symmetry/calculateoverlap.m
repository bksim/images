%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculateoverlap.m
% brandon sim, 12/11/2012
% 
% Calculates overlap (in number of pixels) between the coordinates of the
% vertices of two polygons.
%
% usage: calculateoverlap(polygon1, polygon2, imageX, imageY)
%
% polygon1: an m-by-2 matrix, containing the (x,y) coordinates in each row
% of the m-th vertex of polygon1.
%
% polygon2: an n-by-2 matrix, containing the (x,y) coordinates in each row
% of the n-th vertex of polygon2.
%
% imageX: an integer representing the horizontal # of pixels
% imageY: an integer representing the vertical # of pixels
%
% returns: an integer representing the # of pixels in image that lie inside
% both polygons.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pix = calculateoverlap(polygon1, polygon2, imageX, imageY)
    xv1 = polygon1(:,1);
    yv1 = polygon1(:,2);
    xv2 = polygon2(:,1);
    yv2 = polygon2(:,2);
    
    tempX = ones(1,imageX);
    tempY = ones(imageY,1);
    X = zeros(imageY,imageX);
    Y = zeros(imageY,imageX);
    for tempi = 1:imageY,
        X(tempi,:) = tempi.*tempX;
    end
    for tempj = 1:imageX,
        Y(:,tempj) = tempj.*tempY; 
    end
    
    in1 = inpolygon(X,Y,xv1,yv1);
    in2 = inpolygon(X,Y,xv2,yv2);
    
    intersection = in1.*in2; %multiplies elementwise to apply 'AND' filter
    
    pix = nnz(intersection); %returns number of nonzero elements
end

