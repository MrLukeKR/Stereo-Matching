close all;
clear;

leftImage(:, :) = rgb2gray(imread('im2.png')); %Load in the left image
rightImage(:, :) = rgb2gray(imread('im6.png')); %Load in the right image

maxSearchSpace = 50;

for x = 2 : 5
    windowSize = 2 ^ x;
    disp = gradientFeaturesToDisparity(leftImage, rightImage, windowSize, maxSearchSpace);
    figure('Name', sprintf('Disparity from Gradient Feature Matching [%dx%d window]', windowSize, windowSize));
    imshow(disp);
end

for x = 2 : 5
    windowSize = 2 ^ x;
    disp = hogFeaturesToDisparity(leftImage, rightImage, windowSize, maxSearchSpace);
    figure('Name', sprintf('Disparity from Histogram of Oriented Gradient (HOG) Feature Matching [%dx%d window]', windowSize, windowSize));
    imshow(disp);
end

%disp = surfFeaturesToDisparity(leftImage, rightImage, 40, maxSearchSpace);
%figure('Name', 'Disparity from Speeded Up Robust Features (SURF) Feature Matching');
%imshow(disp);

for x = 2 : 5    
    windowSize = 2 ^ x;
    disp = lbpToDisparity(leftImage, rightImage, windowSize);
    figure('Name', sprintf('Disparity from Loopy Belief Propagation(LBP) [%dx%d window]', windowSize, windowSize));
    imshow(disp);
end

for x = 2 : 5
    windowSize = 2 ^ x;
    disp = dpToDisparity(leftImage, rightImage, windowSize);
    figure('Name', 'Disparity from Dynamic Programming (DP) [%dx%d window]', windowSize, windowSize');
    imshow(disp);
end