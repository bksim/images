%baghdad
%edge + overlayed watershed transform = result

%read image
I = imread('1.jpg');

%using default threshold for now
BW = edge(I,'sobel');

%can also put threshold here like with canny
BW1 = edge(I,'canny', 0.70);

figure, imshow(BW), title('Sobel, autothresh');
figure, imshow(BW1), title('Canny, 0.7 thresh');

%imwrite(BW, 'sorbelOut.jpg','jpg');
%imwrite(BW1, 'cannyOut.jpg','jpg');

%horizontal edge filter
hy = fspecial('sobel');
%vertical component
hx = hy';

%use image filter, needs "double" input, filter, option
Iy = imfilter(double(I), hy, 'replicate');
Ix = imfilter(double(I), hx, 'replicate');

gradient = sqrt(Ix.^2 + Iy.^2);
figure, imshow(gradient,[]), title ('Gradient')

L = watershed(gradient);
Lrgb = label2rgb(L);
figure, imshow(Lrgb, []), title('Watershed Transform of Gradient');

