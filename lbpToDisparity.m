function disparity = lbpToDisparity(leftImage, rightImage, windowSize)
width = size(leftImage,2);
height = size(leftImage,1);
labels = 15;

propagations = 40;

%messages = (struct)
messages = zeros(height * width, 5, labels);
disp = zeros(height, width);   

progressBar = waitbar(0,  'Initialising Loopy Belief Propagation...');

start = labels + 1;
yEnd = height - labels;
xEnd = width - labels;
mesHeight = yEnd - start;

data = Direction("CENTER");

for y = start : yEnd
    for x = start : xEnd
       for label = 1 : labels
           cost = DataCost(x, y, label - 1, leftImage, rightImage, windowSize);
           messages((y-1) * width + x, data, label) = cost;
       end    
    end
    waitbar((y - start) / mesHeight, progressBar);
end

close(progressBar);

progressBar = waitbar(0,  'Performing Loopy Belief Propagation...');
    
for belief = 1 : propagations
    for d = 1 : 4
        messages = Propagate(d, width, height, labels, messages);
        waitbar(((belief - 1) * 4 + d) / (propagations * 4), progressBar);
    end
    disp = Map(height, width, labels, disp, messages);
    figure(1);
    imshow(disp./max(max(disp)));
end
close(progressBar);
disparity = AssignmentsToDisparity(disp, height, width, labels, windowSize);
end

function disparity = AssignmentsToDisparity(assignments, height, width, labels, windowSize)
    disparity = zeros(height,width);
    norm = max(max(assignments));
    for y = labels + windowSize / 2 : height - labels - windowSize /2
       for x = labels + windowSize / 2 : width - labels - windowSize / 2
           disparity(y, x) = assignments(y, x) / norm; 
       end
    end
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
        for x = width : -1 : 2
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
           for y = height : -1 : 2
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

width = size(messages, 2);

%checkMessageArray(messages);

for i = 1 : labels
    cost = realmax;
    for j = 1 : labels
        currCost = SmoothCost(i, j) + messages((y-1) * width + x, 5, j);
        
        for d = 1 : 4
            if(dir ~= d) 
                currCost = currCost + messages((y-1) * width + x, d, j);
            end
        end
        
        cost = min(cost, currCost);
    end
    newMessage(i, 1) = cost;

end

switch(dir)
    case Direction("LEFT")
        messages((y-1) * width + x - 1, Direction("RIGHT"), :) = newMessage(:, 1);
    case Direction("RIGHT")
        messages((y-1) * width + x + 1, Direction("LEFT"), :) = newMessage(:, 1);
    case Direction("UP")
        messages((y - 2) * width + x, Direction("DOWN"), :) = newMessage(:, 1);
    case Direction("DOWN")
        messages(y * width + x, Direction("UP"), :) = newMessage(:, 1);
    otherwise
        warning('Invalid Direction');
end
end

function cost = DataCost(x, y, label, leftImage, rightImage, windowSize)
    halfWindow = windowSize / 2;
    yStartInd = y - halfWindow + 1;
    yEndInd = y + halfWindow;
    xStartInd = x - halfWindow + 1;
    xEndInd = x + halfWindow;
        
    leftSubImage = leftImage(yStartInd : yEndInd , xStartInd : xEndInd);
    rightSubImage = rightImage(yStartInd : yEndInd, xStartInd - label : xEndInd - label);
    diff   = double(leftSubImage) - double(rightSubImage);
    diffSq = diff .^2;
    cost = sum(sum(diffSq));
end

function assignments = Map(height, width, labels, assignments, messages)
    for y = 1 : height
        for x = 1 : width
            bestBelief = realmax;
            for label = 1 : labels
                belief = sum(messages((y - 1) * width + x, :, label));
                if (belief < bestBelief)
                    bestBelief = belief; 
                    assignments(y,x) = label - 1;
                end
            end
        end
    end
end

function cost = SmoothCost(x, y)
    lambda = 15;
    truncation = 5;
    cost = lambda * min(abs(x - y), truncation);
end