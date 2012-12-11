%% findcentroids.m
%
% usage: findcentroid(jpgfilename)
% returns (x,y) coordinate of centroid, or (-1, -1) if nothing found

function [xc yc] = findcentroids(jpgfilename)
    % Reads image and displays initial results of Canny edge detection
    im = imread(jpgfilename);
    im = rgb2gray(im);
    
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
end
