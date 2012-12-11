%baghdad
%edge + overlayed watershed transform = result

%read image
I = imread('original.jpg');

%using default threshold for now
%BW = edge(I,'sobel');

%can also put threshold here like with canny
cannyout = edge(I,'canny', 0.70);

%figure, imshow(BW), title('Sobel, autothresh');
figure, imshow(cannyout), title('Canny, 0.7 thresh');

%imwrite(BW, 'sorbelOut.jpg','jpg');
%imwrite(BW1, 'cannyOut.jpg','jpg');