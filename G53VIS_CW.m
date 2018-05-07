close all;
clear;

%leftImage(:, :) = rgb2gray(imread('cones_left.png')); %Load in the left image
%rightImage(:, :) = rgb2gray(imread('cones_right.png')); %Load in the right image

leftImage(:, :) = rgb2gray(imread('teddy_left.png')); %Load in the left image
rightImage(:, :) = rgb2gray(imread('teddy_right.png')); %Load in the right image

%leftImage = imnoise(leftImage, 'gaussian');
%rightImage = imnoise(rightImage, 'gaussian');

maxSearchSpace = 50;

for x = 2 : 5
    windowSize = 2 ^ 2;
    disp = intensityToDisparity(leftImage, rightImage, windowSize, maxSearchSpace);
    figure('Name', sprintf('Disparity from Pixel Intensity Matching [%dx%d window]', windowSize, windowSize));
    imshow(disp);
end

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

for x = 2 : 5    
    windowSize = 2 ^ 2;
    disp = lbpToDisparity(leftImage, rightImage, windowSize);
    figure('Name', sprintf('Disparity from Loopy Belief Propagation(LBP) [%dx%d window]', windowSize, windowSize));
    imshow(disp);
end

for x = 2 : 5
    windowSize = 2 ^ x;
    disp = dpToDisparity(leftImage, rightImage, windowSize);
    figure('Name', sprintf('Disparity from Dynamic Programming (DP) [%dx%d window]', windowSize, windowSize));
    imshow(disp);
end