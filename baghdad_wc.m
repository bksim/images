%baghdad
%edge + overlayed watershed transform = result

%read image
I = imread('lilypad.jpg');

I = rgb2gray(I);

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

gradmag = sqrt(Ix.^2 + Iy.^2);
figure, imshow(gradmag,[]), title ('Gradient Magnitude')

L = watershed(gradmag);
Lrgb = label2rgb(L);
figure, imshow(Lrgb, []), title('Watershed Transform of Gradient')

se = strel('disk', 4);
Io = imopen(I, se);
figure, imshow(Io), title('Opening (Io)')

Ie = imerode(I, se);
Iobr = imreconstruct(Ie, I);
figure, imshow(Iobr), title('Opening-by-reconstruction (Iobr)')

Ioc = imclose(Io, se);
figure, imshow(Ioc), title('Opening-closing (Ioc)')

Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
figure, imshow(Iobrcbr), title('Opening-closing by reconstruction (Iobrcbr)')

fgm = imregionalmax(Iobrcbr);
figure, imshow(fgm), title('Regional maxima of opening-closing by reconstruction (fgm)')

I2 = I;
I2(fgm) = 255;
figure, imshow(I2), title('Regional maxima superimposed on original image (I2)')

se2 = strel(ones(3,3));
fgm2 = imclose(fgm, se2);
fgm3 = imerode(fgm2, se2);
figure, imshow(I2), title('Regional maxima superimposed on original image after Erosion (I2)')

fgm4 = bwareaopen(fgm3, 20);
I3 = I;
I3(fgm4) = 255;
figure, imshow(I3)
title('Modified regional maxima superimposed on original image (fgm4)')


%this next step should be unnecessary as no need to mark already black
%background
bw = im2bw(Iobrcbr, graythresh(Iobrcbr));
figure, imshow(bw), title('Thresholded opening-closing by reconstruction (bw)')

D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;
figure, imshow(bgm), title('Watershed ridge lines (bgm)')

gradmag2 = imimposemin(gradmag, bgm | fgm4);
L = watershed(gradmag2);

I4 = I;
I4(imdilate(L == 0, ones(3, 3)) | bgm | fgm4) = 255;
figure, imshow(I4)
title('Markers and object boundaries superimposed on original image (I4)')

Lrgb = label2rgb(L, 'jet', 'w', 'shuffle');
figure, imshow(Lrgb)
title('Colored watershed label matrix (Lrgb)')
hold on;
handle = imshow(I);
alpha(0.5);
hold off;