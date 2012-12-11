%generalized watershed method starting with colored image

%read image
I = imread('lilypad.jpg');

%convert RGB into grayscale
I = rgb2gray(I);

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

%create disk shaped morphological structuring element of size 6 - picked so
%not to over or under segment, disk shaped as target structure is round
se = strel('disk', 6);

%first method to open: (imopen)
Io = imopen(I, se);
imwrite(Io, 'Open_Disk6.jpg', 'jpg');
%figure, imshow(Io), title('Opening (Io)')

%second method to open: reconstructed (imerode)
Ie = imerode(I, se);
Iobr = imreconstruct(Ie, I);
imwrite(Iobr, 'MRI_OpenReconstuct_Disk6.jpg', 'jpg');
%figure, imshow(Iobr), title('Opening-by-reconstruction (Iobr)')

%first method of closing: (imclose)
Ioc = imclose(Io, se);
imwrite(Ioc, 'MRI_Close_Disk6.jpg', 'jpg');
%figure, imshow(Ioc), title('Opening-closing (Ioc)')

%second method to close: reconstructed (imdilate)
Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
imwrite(Iobrcbr, 'MRI_CloseReconstruct_Disk6.jpg', 'jpg');
%figure, imshow(Iobrcbr), title('Opening-closing by reconstruction (Iobrcbr)')

%use function to store maxima (foreground marker)
fgm = imregionalmax(Iobrcbr);
imwrite(fgm, 'MRI_Maxima.jpg', 'jpg');
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
fgm4 = bwareaopen(fgm3, 15);
I3 = I;
I3(fgm4) = 255;
imwrite(I3, 'MRI_MaxmimaSuperSmooth.jpg', 'jpg');
%figure, imshow(I3), title('Modified regional maxima superimposed on original image (fgm4)')

%identify background pixels - anything below a certain threshold is
%"background"
bw = im2bw(Iobrcbr, graythresh(Iobrcbr));
imwrite(bw, 'MRI_Background_Threshold.jpg', 'jpg');
%figure, imshow(bw), title('Thresholded opening-closing by reconstruction (bw)')

%adapt background to form watershed ridge lines (where there is little
%foreground, mark off)
D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;
imwrite(bgm, 'MRI_Watershed_Ridge_Lines.jpg', 'jpg');
%figure, imshow(bgm), title('Watershed ridge lines (bgm)')

%calculate watershed segmentation as before
gradmag2 = imimposemin(gradmag, bgm | fgm4);
L = watershed(gradmag2);
I4 = I;
I4(imdilate(L == 0, ones(3, 3)) | bgm | fgm4) = 255;
imwrite(I4, 'MRI_All_Markers_Super.jpg', 'jpg');
%figure, imshow(I4), title('Markers and object boundaries superimposed on original image (I4)')

%color image visualization
Lrgb = label2rgb(L, 'jet', 'w', 'shuffle');
imwrite(Lrgb, 'MRI_Color_Watershed.jpg', 'jpg');
%figure, imshow(Lrgb), title('Colored watershed label matrix (Lrgb)')

%superimpose color on original image to see what the shading represents
figure(1), imshow(Lrgb)
title('Color Watershed Superimposed on Original Image')
hold on;
handle = imshow(I);
alpha(0.5);
hold off;

%export this figure (couldn't export image due to transparency)
print (1, '-djpeg', 'result')