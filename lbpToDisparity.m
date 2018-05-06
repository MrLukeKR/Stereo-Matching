function disparity = lbpToDisparity(leftImage, rightImage, windowSize)
width = size(leftImage,2);
height = size(leftImage,1);
labels = 50;

propagations = 10;

messages = zeros(height, width, 5, labels);
disp = zeros(height, width);   

progressBar = waitbar(0,  'Initialising Loopy Belief Propagation...');

start = labels + windowSize / 2;
yEnd = height - labels - windowSize / 2;
xEnd = width - labels - windowSize / 2;
mesWidth = xEnd - start;
mesHeight = yEnd - start;

data = Direction("CENTER");

costs = zeros(height, width, labels);

%imshow(messages(:,:,5,1)./max(max(messages(:,:,5,1))));

for y = start : yEnd
    for x = start : xEnd
       for label = 1 : labels
           cost = DataCost(x, y, label - 1, leftImage, rightImage, windowSize);
           messages(y, x, data, label) = cost;
       end    
    end
    waitbar((y - start) / mesHeight, progressBar);
end

close(progressBar);

for i = 1 : labels
   %imshow(messages(:,:,5,i)./max(max(messages(:,:,5,i))));
end
  
    progressBar = waitbar(0,  'Performing Loopy Belief Propagation...');
    
for belief = 1 : propagations
    for d = 1 : 4
        messages = Propagate(d, width, height, labels, messages);
        waitbar(((belief - 1) * 4 + d) / (propagations * 4), progressBar);
    end
    disp = Map(height, width, labels, disp, messages);
end
close(progressBar);
disparity = disp./max(max(disp));
end

function dir = Direction(val)
    switch(val)
        case "UP"
            dir = 1;
        case "LEFT"
            dir = 2;
        case "DOWN"
            dir = 3;
        case "RIGHT"
            dir = 4;
        case "CENTER"
            dir = 5;
    end
end

function messages = Propagate(dir, width, height, labels, messages)
switch(dir)
    case Direction("RIGHT")
        for x = 1 : width - 1
           for y = 1 : height
               messages = PassMessage(x, y, dir, labels, messages);
           end
        end
    case Direction("LEFT")
        for x = width - 1 : -1 : 2
           for y = 1 : height
               messages = PassMessage(x, y, dir, labels, messages);
           end
        end
    case Direction("DOWN")
        for x = 1 : width
           for y = 1 : height - 1
               messages = PassMessage(x, y, dir, labels, messages);
           end
        end
    case Direction("UP")
        for x = 1 : width
           for y = height - 1 : -1 : 2
               messages = PassMessage(x, y, dir, labels, messages);
           end
        end
    otherwise
        warning('Invalid Direction!');
end
end

function messages = PassMessage(x, y, dir, labels, messages)
newMessage = zeros(labels, 1);
%norm = 1;

%checkMessageArray(messages);

for i = 1 : labels
    cost = realmax;
    for j = 1 : labels
        currCost = SmoothCost(i, j);
        
        for d = 1 : 5
            if(dir ~= d) 
                currCost = currCost + messages(y, x, d, j);
            end
        end
        cost = min(cost, currCost);
    end
    newMessage(i, 1) = cost;
end

for i = 1 : labels
switch(dir)
    case Direction("LEFT")
        messages(y, x - 1, Direction("RIGHT"), i) = newMessage(i, 1);
    case Direction("RIGHT")
        messages(y, x + 1, Direction("LEFT"), i) = newMessage(i, 1);
    case Direction("UP")
        messages(y - 1, x, Direction("DOWN"), i) = newMessage(i, 1);
    case Direction("DOWN")
        messages(y + 1, x, Direction("UP"), i) = newMessage(i, 1);
    otherwise
        warning('Invalid Direction');
end
end
end

function cost = DataCost(x, y, label, leftImage, rightImage, windowSize)
        halfWindow = windowSize / 2;
        yStartInd = y - halfWindow;
        yEndInd = y + halfWindow -1;
        xStartInd = x - halfWindow;
        xEndInd = x + halfWindow -1;
        
        leftSubImage = leftImage(yStartInd : yEndInd , xStartInd : xEndInd);
        rightSubImage = rightImage(yStartInd : yEndInd, xStartInd - label : xEndInd - label);
        diff   = double(leftSubImage) - double(rightSubImage);
        diffSq = diff .^2;
        cost = sum(sum(diffSq));
end

function disp = Map(height, width, labels, disp, messages)
for y = 1 : height
    for x = 1 : width
        bestBelief = realmax;
        for label = 1 : labels
            belief = sum(messages(y, x, :, label));
            if (belief < bestBelief)
                bestBelief = belief; 
                disp(y,x) = label - 1;
            end
        end
    end
end
imshow(disp./max(max(disp)));
end

function cost = SmoothCost(x, y)
    lambda = 15;
    truncation = 5;
    cost = lambda * min(abs(x - y), truncation);
end