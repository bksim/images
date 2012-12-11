%apply watershed segmentation on the MRI image
clear;

%read image
I = imread('original.jpg');

%horizontal edge filter
hy = fspecial('sobel');
%vertical component
hx = hy';

%use image filter, needs "double" input, filter, option
Iy = imfilter(double(I), hy, 'replicate');
Ix = imfilter(double(I), hx, 'replicate');

%calculate gradient
gradmag = sqrt(Ix.^2 + Iy.^2);
imwrite(gradmag, 'MRI_Gradient_Mag.jpg','jpg');
%figure, imshow(gradmag,[]), title ('Gradient Magnitude')

%demonstrate oversegmentation of direct watershed of gradient
L = watershed(gradmag);
Lrgb = label2rgb(L);
imwrite(Lrgb, 'MRI_OversegWatershed.jpg', 'jpg');
%figure, imshow(Lrgb, []), title('Watershed Transform of Gradient - oversegmentation')

%create disk shaped morphological structuring element of size 4 - picked so
%not to over or under segment, disk shaped as target structure is round
se = strel('disk', 4);

%first method to open: (imopen)
Io = imopen(I, se);
imwrite(Io, 'Open_Disk4.jpg', 'jpg');
%figure, imshow(Io), title('Opening (Io)')

%second method to open: reconstructed (imerode)
Ie = imerode(I, se);
Iobr = imreconstruct(Ie, I);
imwrite(Iobr, 'MRI_OpenReconstuct_Disk4.jpg', 'jpg');
%figure, imshow(Iobr), title('Opening-by-reconstruction (Iobr)')

%first method of closing: (imclose)
Ioc = imclose(Io, se);
imwrite(Ioc, 'MRI_Close_Disk4.jpg', 'jpg');
%figure, imshow(Ioc), title('Opening-closing (Ioc)')

%second method to close: reconstructed (imdilate)
Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
imwrite(Iobrcbr, 'MRI_CloseReconstruct_Disk4.jpg', 'jpg');
%figure, imshow(Iobrcbr), title('Opening-closing by reconstruction (Iobrcbr)')

%use function to store maxima (foreground marker)
fgm = imregionalmax(Iobrcbr);
imwrite(Lrgb, 'MRI_Maxima', 'jpg');
%figure, imshow(fgm), title('Regional maxima of opening-closing by reconstruction (fgm)')

%copy image and superimpose to form new working image
I2 = I;
I2(fgm) = 255;
imwrite(I2, 'MRI_MaximaSuperimposed.jpg', 'jpg');
%figure, imshow(I2), title('Regional maxima superimposed on original image (I2)')

%create a new morphological element to smooth out the foreground markers
se2 = strel(ones(3,3));

%smooth out the foreground markers superimposed
fgm2 = imclose(fgm, se2);
fgm3 = imerode(fgm2, se2);
fgm4 = bwareaopen(fgm3, 20);
I3 = I;
I3(fgm4) = 255;
imwrite(I2, 'MRI_MaxmimaSuperSmooth.jpg', 'jpg');
%figure, imshow(I3), title('Modified regional maxima superimposed on original image (fgm4)')


bw = im2bw(Iobrcbr, graythresh(Iobrcbr));
%figure, imshow(bw), title('Thresholded opening-closing by reconstruction (bw)')

D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;
%figure, imshow(bgm), title('Watershed ridge lines (bgm)')

gradmag2 = imimposemin(gradmag, bgm | fgm4);
L = watershed(gradmag2);

I4 = I;
I4(imdilate(L == 0, ones(3, 3)) | bgm | fgm4) = 255;
%figure, imshow(I4), title('Markers and object boundaries superimposed on original image (I4)')

Lrgb = label2rgb(L, 'jet', 'w', 'shuffle');
%figure, imshow(Lrgb), title('Colored watershed label matrix (Lrgb)')

figure(1)
imshow(Lrgb);
title('Colored watershed label matrix (Lrgb) superimposed')
hold on;
handle = imshow(I);
f = getframe(1);
alpha(0.5);

hold off;

im = frame2im(f);
figure(2)
imshow(im);


