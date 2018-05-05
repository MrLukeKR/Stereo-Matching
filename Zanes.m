%%Cross correlation to form DSI
im=imread('im2.png');
im2=imread('im6.png');
imRect=rgb2gray(im);
im2Rect=rgb2gray(im2);
[imageHeight, imageWidth, channels] = size(imRect);
windowWidth = 32;
windowHeight = 32;
DSIWidth = imageWidth-windowWidth;
DSI = zeros(DSIWidth, DSIWidth);
DisparityMap = zeros(imageHeight-windowHeight, imageWidth-windowWidth);
%for r = windowHeight/2 + 1:imageHeight-windowHeight/2


r = windowHeight/2 + 1;
    for i = windowWidth/2 + 1:imageWidth-windowWidth/2
        window = imRect((r-windowHeight/2):(r+windowHeight/2 - 1), (i-windowWidth/2):(i+windowWidth/2 - 1));
        
        for x = windowWidth/2 + 1:imageWidth-windowWidth/2
            diffRect = im2Rect((r-windowHeight/2):(r+windowWidth/2 - 1), x-windowWidth/2:x+windowWidth/2 - 1);
            %figure;
            %subplot(1,2,1), imshow(window);
            %subplot(1,2,2), imshow(diffRect);
            diff = im2Rect((r-windowHeight/2):(r+windowWidth/2 - 1), x-windowWidth/2:x+windowWidth/2 - 1) - window;
            diffSquared = diff.*diff;
            sumDiff = sum(sum(diffSquared));
            DSI(x - windowWidth/2 ,i - windowWidth/2) = sumDiff / (windowWidth * windowHeight);
        end
    end
    DSIim = uint8(DSI);
    
    %%Dynamic Programming
    
    occlusionConstant = 150;
    
    lowestCost = zeros(DSIWidth, DSIWidth);
    from = zeros(DSIWidth, DSIWidth);
    for x = 2:DSIWidth
        lowestCost(1, x) = lowestCost(1, x-1) + occlusionConstant;
        lowestCost(x, 1) = lowestCost(x-1, 1) + occlusionConstant;
    end
    
    for i = 2:DSIWidth
        for j = 2:DSIWidth
            A = zeros(1, 3);
            A(1,1) = lowestCost(i-1, j-1) + DSI(i,j);
            A(1,2) = lowestCost(i-1, j) + occlusionConstant;
            A(1,3) = lowestCost(i, j-1) + occlusionConstant;
           [lowestCost(i, j), from(i,j)] = zanesMin(A(1,1), A(1,2), A(1,3));
        end
    end
    
    
    path = zeros(DSIWidth, DSIWidth);
    i = DSIWidth;
    j = DSIWidth;
    while (i ~= 1 && j ~= 1)
        path(i, j) = 1;
        switch from(i,j)
            case -1
                i = i-1;
            case 0
                i = i-1;
                j = j-1;
            case 1
                j = j-1;
        end
        DisparityMap(r, i) = j-i;
    end
    
    DM = uint8(DisparityMap);
    
%end