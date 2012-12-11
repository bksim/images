%symmetry -bks
clear;
%read image
I = imread('original.jpg');

%using default threshold for now
%BW = edge(I,'sobel');

%cannyout = edge(I,'canny', 0.70);
cannyout = edge(I,'canny', [0.3  0.7], 2);

%figure, imshow(BW), title('Sobel, autothresh');
figure(1), imshow(cannyout), title('Canny');

imwrite(cannyout, 'cannyout.jpg', 'jpg');

% Link edge pixels together into lists of sequential edge points, one
% list for each edge contour. A contour/edgelist starts/stops at an 
% ending or a junction with another contour/edgelist.
% Here we discard contours less than 10 pixels long.

[edgelist, labelededgeim] = edgelink(cannyout, 10);

% Display the edgelists with random colours for each distinct edge 
% in figure 2
drawedgelist(edgelist, size(I), 1, 'rand', 2); axis off;

% Fit line segments to the edgelists
tol = 1;         % Line segments are fitted with maximum deviation from
                 % original edge of 1 pixels.
seglist = lineseg(edgelist, tol);

% Draw the fitted line segments stored in seglist in figure window 3 with
% a linewidth of 2 and random colours
drawedgelist(seglist, size(I), 1, 'rand', 3); axis off

