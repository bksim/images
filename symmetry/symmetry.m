%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% symmetry.m
% brandon sim, 12/11/2012
%
% Attempts to detect and identify tumor in MRI scan with the following 
% original algorithm:
%
% (1) Detect axis of symmetry in image. We use the Canny edge detector
% operator with an extremely high \sigma, which specifies the standard
% deviation of the Gaussian filter. (\sigma = 15). This \sigma
% represents the smoothing parameter - we choose a high value (for
% comparison, default value in MATLAB is \sqrt{2}) because we want to
% smooth all the features into the brain's shape. We then find the ellipse
% that has the same normalized second central moment as that region, then
% calculate its major and minor axes as well as its orientation (defined as
% the angle between x-axis and the major axis). The major axis is defined
% as the axis of orientation.
%
% (2) Use the Canny edge detector operator (Canny, 1986) to detect edges
%
% (3) Detect all closed objects
% 
% (4) Reflect each closed objects across axis of symmetry and calculate
% overlap in area of each reflected object with any other closed object
%
% (5) Clustering - calculate centroids of each object to verify results
%
% Those closed objects with large area overlaps are most likely not tumors,
% as it is unlikely that a tumor will be symmetric across the middle of a
% brain, so we will sort the closed objects in ascending order of amount of
% overlap - the one with least overlap will be our most likely tumor
% candidate
%
% dependencies: 
% calculateoverlap.m, reflectpolygon.m,
% written by Brandon Sim,
%
% edgelink.m, drawedgelist.m, lineseg.m, maxlinedev.m,
% findendsjunctions.m, cleanedgelist.m 
% (http://www.csse.uwa.edu.au/~pk/research/matlabfns/)
% 
% Other sources: 
% (http://blogs.mathworks.com/steve/2010/07/30/visualizing-regionprops...
% -ellipse-measurements/)
%
% Rest of code, such as closed edge detection, and all other code in this 
% file written by ~bks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;

%% Reads image and displays initial results of Canny edge detection
% read image
im = imread('original.jpg');
%im = imread('t2_axial95.jpg');

%im = rgb2gray(im);
% Canny edge detection for features, with normal settings
cannyout = edge(im,'canny', [0.3  0.7], 2);
% Canny edge detection for brain outline, with extremely high smoothing
% parameter \sigma
cannyPerimeter = edge(im, 'canny', [0.1 0.9], 15);

% displays results
figure, 
imshow(cannyout), 
title('Canny edge detection with thresholds [0.3  0.7], \sigma = 2');

figure,
imshow(cannyPerimeter),
title('Canny edge detection with thresholds [0.1 0.9], \sigma = 15');

% write results to output files
imwrite(cannyout, 'cannyout_thres_0.3_0.7_sigma_2.jpg', 'jpg');
imwrite(cannyPerimeter, 'cannyout_perimeter_thres_0.1_0.9_sigma_15.jpg', ...
    'jpg');

%% Draws ellipse described above (with same second moment, etc) around the
% edge of the brain, finds its orientation (detect axis of orientation)
figure(97),
drawimage = cannyPerimeter;
s = regionprops(drawimage, 'Orientation', 'MajorAxisLength', ...
    'MinorAxisLength', 'Eccentricity', 'Centroid');

imshow(drawimage)
hold on

phi = linspace(0,2*pi,50);
cosphi = cos(phi);
sinphi = sin(phi);

for k = 1:length(s)
    xbar = s(k).Centroid(1);
    ybar = s(k).Centroid(2);

    a = s(k).MajorAxisLength/2;
    b = s(k).MinorAxisLength/2;

    theta = pi*s(k).Orientation/180;
    R = [ cos(theta)   sin(theta)
         -sin(theta)   cos(theta)];

    xy = [a*cosphi; b*sinphi];
    xy = R*xy;

    x = xy(1,:) + xbar;
    y = xy(2,:) + ybar;

    plot(x,y,'r','LineWidth',2);
end
hold off
title('Ellipse generated for brain perimeter');
print(97,'-djpeg','ellipse_perimeter');

%%
%%Draws ellipses around canny output (interior)
figure(98),
drawimage = cannyout;
s_int = regionprops(drawimage, 'Orientation', 'MajorAxisLength', ...
    'MinorAxisLength', 'Eccentricity', 'Centroid');

imshow(drawimage)
hold on

phi = linspace(0,2*pi,50);
cosphi = cos(phi);
sinphi = sin(phi);

for k = 1:length(s_int)
    xbar = s_int(k).Centroid(1);
    ybar = s_int(k).Centroid(2);

    a = s_int(k).MajorAxisLength/2;
    b = s_int(k).MinorAxisLength/2;

    theta = pi*s_int(k).Orientation/180;
    R = [ cos(theta)   sin(theta)
         -sin(theta)   cos(theta)];

    xy = [a*cosphi; b*sinphi];
    xy = R*xy;

    x = xy(1,:) + xbar;
    y = xy(2,:) + ybar;

    plot(x,y,'r','LineWidth',2);
end
hold off
title('Ellipse generated for brain perimeter');
print(98,'-djpeg','ellipse_interior');

%%
% Links edge pixels together into lists of sequential edge points, one
% list for each edge contour. A contour/edgelist starts/stops at an 
% ending or a junction with another contour/edgelist.
% Threshold edge length is 10 pixels; those edges less than 10 pixels are
% discarded.

[edgelist, labelededgeim] = edgelink(cannyout, 10);

% Detects if edges are closed by checking if first and last elements in
% each edge are equal
% Draws each region that is closed and calculates their enclosed area
figure(99)
imshow(im);
colors = {'red';'cyan';'green'}; %temporary
tempcounter = 1;
hold on
for i = 1:length(edgelist),
    temp = edgelist{i};
    if temp(1,:) == temp(length(temp),:)
        drawedgelist(edgelist(i), size(im), 1, colors{tempcounter}); 
        axis off; %draw
        %stores all closed objects into cell array
        closedobjects{tempcounter} = edgelist{i}; 
        areas{tempcounter} = num2str(polyarea(temp(:,1), temp(:,2)));
        tempcounter = tempcounter + 1;
        %calculates area of enclosed regions and stores for later use
    end
end
hold off
title('Closed regions, with areas in legend');
legend(areas, 'Location', 'SouthEast');
print(99,'-djpeg','closedregions');
%% takes closedobjects cell array and checks pairwise for overlap
numclosed = length(closedobjects);
paircounter = 1;
% generates all (n choose 2) pairwise combinations and checks for overlap
% (n choose 2)-by-3 matrix in format:
% object1# object2# pixelOverlap
% object1# object2# pixelOverlap
% ...
overlapresults = zeros(nchoosek(numclosed,2),3);
theta = s.Orientation;
centroidbrain = [s.Centroid(1);s.Centroid(2)];
imsize = size(im);
figure(100),
imshow(im);
hold on
for pairi = 1:numclosed,
    for pairj = 1:(pairi-1),
        polygon = closedobjects{pairi};
        polygon2 = closedobjects{pairj};
        % flips first in pair
        polygon1 = reflectpolygon(polygon, theta, centroidbrain);
        drawedgelist({polygon2}, size(im), 1, 'cyan');axis off;
        drawedgelist({polygon1}, size(im), 1, 'red');axis off;
        
        % calculates overlap of the pair and stores in overlapresults
        tempoverlap = calculateoverlap(polygon1,polygon2,imsize(1),imsize(2));
        overlapresults(paircounter,:) = [pairi pairj tempoverlap];
 
        paircounter = paircounter+1;
    end
end
drawedgelist(closedobjects(3), size(im), 1, 'cyan'); axis off;
hold off
legend('Original', 'Reflected', 'Location', 'Southeast');
title('Original and Reflected closed regions for area overlap detection');
print(100, '-djpeg', 'reflection')
%% Finds the centroids of the regions left after Canny edge detection to
% corroborate results
s_canny  = regionprops(cannyout, 'centroid');
centroids = cat(1, s_canny.Centroid);
figure(150)
imshow(im)
hold on
plot(centroids(:,1), centroids(:,2), 'r*')
hold off
title('Centroids of regions after Canny edge detection');
print(150, '-djpeg', 'centroids')

%% Below code is optional: unnecessary at the moment (12/11/2012)
% Fit line segments to the edgelists
%tol = 1;         % Line segments are fitted with maximum deviation from
                 % original edge of 1 pixels.
%seglist = lineseg(edgelist, tol);

% Draw the fitted line segments stored in seglist in figure window 3 with
% a linewidth of 2 and random colours
%drawedgelist(seglist, size(im), 1, 'rand', 3); axis off