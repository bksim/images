%% detectanomalies.m
% Brandon Sim
% Analyzes a set of images from an MRI scan and detects anomalies
% 
% result is centroiddata, a numfiles-by-3 array
% each line consists of 3 values: numfile, x-coord, y-coord
% 0's if centroid is not found
%
% dependencies: findcentroids.m
clear;

numfiles = 130;
centroiddata = zeros(numfiles,3);

for num = 0:(numfiles-1),
   filename = ['t2_axial',num2str(num),'.jpg']
   if num~=26 && num~=29
       [tempx tempy] = findcentroids(filename);
       centroiddata(num+1,:) = [num tempx tempy];
   end 
end
%%
% constructs a list with numfiles-1 element, with the distance between the
% 1st and 2nd point in the first slot, distance between 2nd and 3rd point
% in second slot, etc.
differences = zeros(size(centroiddata,1)-1,1);
for i = 1:size(centroiddata,1)-1,
    differences(i) = norm(centroiddata(i,2:3)-centroiddata(i+1,2:3));
end

threshold = 1;%if less than threshold, flag as anomaly
for i = 1:size(differences),
   if differences(i) < threshold && differences(i)~=0,
       ['Warning: possible tumor detected. Frames ', num2str(i), ', ', ...
           num2str(i+1), '; Difference: ', num2str(differences(i))]
      centroiddata(i,2:3)
      centroiddata(i+1,2:3)
   end
end