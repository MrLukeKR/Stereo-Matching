function disparity = lbpToDisparity(leftImage, rightImage, windowSize)
width = size(leftImage,2);
height = size(leftImage,1);
labels = 60;

propagations = 5;

messages = zeros(height, width, 5, labels, 2);
disp = zeros(height, width);   

progressBar = waitbar(0,  'Initialising Loopy Belief Propagation...');

start = labels;
yEnd = height - labels;
xEnd = width - labels;
mesHeight = yEnd - start;

costs = zeros(labels,1);

for y = start : yEnd
    for x = start : xEnd
       for label = 1 : labels
           cost = DataCost(x, y, label - 1, leftImage, rightImage, windowSize) / windowSize;
           costs(label) = cost;
           messages(y, x, 5, label, 1) = cost;
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
    messages = transferNewMessages(messages,height,width,labels);
    disp = Map(height, width, labels, messages);
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

function messages = transferNewMessages(messages, height, width, labels)
    for x = 1 : width
        for y = 1 : height
           for l = 1 : labels
              for d = 1 : 5
                 messages(y,x,d,l,1) = messages(y,x,d,l,2);
              end
           end
        end
    end
end

function dir = Direction(val)
    switch(val)
        case "RIGHT"
            dir = 1;
        case "LEFT"
            dir = 2;
        case "UP"
            dir = 3;
        case "DOWN"
            dir = 4;
        case "CENTER"
            dir = 5;
    end
end

function messages = Propagate(dir, width, height, labels, messages)
switch(dir)
    case Direction("RIGHT")
        for y = 1 : height
            for x = 1 : width - 1
               messages = PassMessage(x, y, dir, labels, messages);
           end
        end
    case Direction("LEFT")
        for y = 1 : height
            for x = width : -1 : 2           
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
%checkMessageArray(messages, labels);
end

function checkMessageArray(message, labels)
mont = [];

for l = 1 : labels
row = [];
    for i = 1 : 5
    row = [row , message(:,:,i, l, 1)./max(max(message(:,:,i, l, 1)))];
    end
mont = [mont ; row];

end
montage(mont);
end

function messages = PassMessage(x, y, dir, labels, messages)
newMessage = zeros(labels, 1);

width = 450;

for i = 1 : labels
    cost = realmax;
    for j = 1 : labels
        currCost = messages(y, x, 5, j, 1);
        smooth = SmoothCost(i, j);
        currCost = currCost + smooth;
        
        for d = 1 : 4
            if(dir ~= d)
                currCost = currCost + messages(y, x, d, j, 1);
            end
        end
  
            cost = min(cost, currCost);
    end
    newMessage(i, 1) = cost;
end

switch(dir)
    case Direction("LEFT")
        messages(y, x - 1, Direction("RIGHT"), :, 2) = newMessage(:, 1);
    case Direction("RIGHT")
        messages(y, x + 1, Direction("LEFT"), :, 2) = newMessage(:, 1);
    case Direction("UP")
        messages(y - 1, x, Direction("DOWN"), :, 2) = newMessage(:, 1);
    case Direction("DOWN")
        messages(y + 1, x, Direction("UP"), :, 2) = newMessage(:, 1);
    otherwise
        warning('Invalid Direction');
end
end

function cost = DataCost(x, y, label, leftImage, rightImage, windowSize)
    leftSubImage = leftImage(y : y + windowSize - 1, x : x + windowSize - 1);
    rightSubImage = rightImage(y : y + windowSize - 1, x - label : x + windowSize - 1 - label);
    diff   = double(leftSubImage) - double(rightSubImage);
    diffSq = diff .^2;
    cost = sum(sum(diffSq));
end

function assignments = Map(height, width, labels, messages)
assignments = zeros(height, width);    
    for y = 1 : height
        for x = 1 : width
            bestBelief = realmax;
            for label = 1 : labels
                belief = sum(messages(y, x, :, label));
                if (belief < bestBelief)
                    bestBelief = belief; 
                    assignments(y,x) = label - 1;
                end
            end
        end
    end
end

function cost = SmoothCost(x, y)
    lambda = 10;
    truncation = 1;
    cost = lambda * min(abs(x - y), truncation);
end