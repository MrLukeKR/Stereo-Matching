function disparity = intensityToDisparity(leftImage, rightImage, windowSize, maxSearchSpace)
width = size(leftImage,2);
height = size(leftImage,1);
featureSize = (windowSize ^ 2);

progressBar = waitbar(0,  'Performing Pixel Intensity Matching...');

disparity = zeros(height - windowSize, width - windowSize);

for y = 1 : height - windowSize
    leftDescriptors = zeros(featureSize, width - windowSize);
    rightDescriptors = zeros(featureSize, width - windowSize);
    disparityLine = zeros(1, width - windowSize);
    
    for x = 1 : width - windowSize
        leftSubImage = leftImage(y : y + windowSize - 1, x : x + windowSize - 1);
        leftDescriptors(:,x) = leftSubImage(:);
        
        rightSubImage = rightImage(y : y + windowSize - 1, x : x + windowSize - 1);
        rightDescriptors(:,x) = rightSubImage(:);
    end
    
    for rightX = 1 : width - windowSize
        SSDs = [];
        
        bound = maxSearchSpace + windowSize;
        
        for leftX = max(1, rightX) : min(rightX + bound, width - windowSize)
            diff = leftDescriptors(:, leftX) - rightDescriptors(:, rightX);
            diffSq = diff .^2;
            SSDs = [SSDs, sum(sum(diffSq))];
        end
            
        [val, loc] = min(SSDs);
        
        disparityLine(rightX) = loc;
    end
    
    disparity(y, :) = disparityLine;
    waitbar(y / height, progressBar);
end
close(progressBar);
disparity = disparity./max(max(disparity));
end