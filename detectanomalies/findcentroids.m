%% findcentroids.m
% Brandon Sim
% usage: findcentroid(jpgfilename)
% returns (x,y) coordinate of centroid, or (-1, -1) if nothing found
% dependency: reflectpolygon.m

function [xc yc] = findcentroids(jpgfilename)
    % Reads image and displays initial results of Canny edge detection
    im = imread(jpgfilename);
    im = rgb2gray(im);
    
    % Canny edge detection for features, with normal settings
    cannyout = edge(im,'canny', [0.3  0.6], 2);
    % Canny edge detection for brain outline, with extremely high smoothing
    % parameter \sigma
    cannyPerimeter = edge(im, 'canny', [0.1 0.9], 20);

    %displays results
    %figure, 
    %imshow(cannyout), 
    %title('Canny edge detection with thresholds [0.3  0.7], \sigma = 2');

    %figure,
    %imshow(cannyPerimeter),
    %title('Canny edge detection with thresholds [0.1 0.9], \sigma = 20');
    
    % Finds the centroids of the regions left after Canny edge detection to
    % corroborate results
    s_canny  = regionprops(cannyout, 'centroid', 'majoraxislength');
    centroids = cat(1, s_canny.Centroid);
    axeslength = cat(1, s_canny.MajorAxisLength);
%     figure,
%     imshow(im)
%     hold on
%     plot(centroids(:,1), centroids(:,2), 'r*')
%     hold off
%     title('Centroids of regions after Canny edge detection');
    
    % Draws ellipse described above (with same second moment, etc) around 
    % the edge of the brain, finds its orientation 
    % (detect axis of orientation)
    drawimage = cannyPerimeter;
    s = regionprops(drawimage, 'Orientation', 'MajorAxisLength', ...
        'MinorAxisLength', 'Eccentricity', 'Centroid');
    
    % flips centroid across axis of symmetry, gets minimum distance from
    % flipped point to the other centroids
    numcentroids = length(s_canny);
    mindistances = zeros(length(s_canny),1);
    theta = s.Orientation;
    centroidbrain = [s.Centroid(1);s.Centroid(2)];
    centroids = cat(1, s_canny.Centroid);
    for i=1:numcentroids,
        % reflects each centroid
        c2=reflectpoint(centroids(i,:), theta, centroidbrain);
        % calculates minimum distance from reflected point to each of the
        % original points and stores in mindistances
        for j=1:numcentroids,
            temp(j) = norm(c2-centroids(j,:));
        end
        temp;
        mindistances(i) = min(temp);
    end
    [maxval, index] = max(mindistances);
    
    % threshold to ensure it's not getting the entire brain
    axeslength(index)/s.MajorAxisLength
    if axeslength(index)/s.MajorAxisLength < 0.5
        xc = centroids(index,1);
        yc = centroids(index,2);
    else
        xc = 0;
        yc = 0;
    end
end
