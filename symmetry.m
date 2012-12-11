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

%imwrite(BW, 'sorbelOut.jpg','jpg');
%imwrite(BW1, 'cannyOut.jpg','jpg');

