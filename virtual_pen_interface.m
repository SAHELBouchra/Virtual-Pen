clc
clear all
close all
warning off

% Create the webcam object
c = webcam;

% Initialize the pointData structure
pointData = struct('x', {}, 'y', {}, 'color', {});

% Set the default color
global currentColor;
currentColor = 'r';

% Create the GUI figure
figure('Name', 'Virtual Pen', 'NumberTitle', 'off', 'KeyPressFcn', @keyPressCallback, 'CloseRequestFcn', @closeFigureCallback, 'Color', 'white');
% Create the title

titleText = 'Virtual';
titlePosition = [0.5, 0.87, 0, 0];
titleColor = [0 0.48 1]; % Bleu clair

annotation('textbox', titlePosition, 'String', titleText, 'FontSize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', titleColor);

titleText = 'pen';
titleColor = [0 0.48 1]; % Bleu clair

titlePosition = [0.6, 0.87, 0, 0];
annotation('textbox', titlePosition, 'String', titleText, 'FontSize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', titleColor);



% Create the color dropdown menu
colorOptions = {'Red', 'Green', 'Blue', 'Yellow','cyan', 'magenta','white','black'};
colorDropdown = uicontrol('Style', 'popupmenu', 'String', colorOptions, 'Position', [100 40 120 20], 'BackgroundColor', [0 0.45 0.74], 'ForegroundColor', 'white', 'Callback', @colorDropdownCallback);

% Create the "Save" button
saveButton = uicontrol('Style', 'pushbutton', 'String', 'Save Drawing', 'Position', [250 40 120 20], 'BackgroundColor',[0 0.45 0.74], 'ForegroundColor', 'white', 'Callback', @saveButtonCallback);

% Create the "Quit" button
quitButton = uicontrol('Style', 'pushbutton', 'String', 'Quit', 'Position', [400 40 70 20], 'BackgroundColor',[0 0.45 0.74], 'ForegroundColor', 'white', 'Callback', @quitButtonCallback);



% Main loop
while true
    % Capture a video frame
    e = snapshot(c);
    
    % Process the frame
    mkdir = createMask(e);
    mkdir = imfill(mkdir, 'holes');
    mkdir = bwareaopen(mkdir, 20);
    BW = bwareafilt(mkdir, 1);
    L = bwlabel(BW);
    s = regionprops(L, 'centroid');
    centroids = cat(1, s.Centroid);
    
    if ~isempty(centroids)
        % Add the new coordinates to the pointData structure
        for i = 1:size(centroids, 1)
            pointData(end+1).x = centroids(i, 1);
            pointData(end).y = centroids(i, 2);
            pointData(end).color = currentColor;
        end
    end
    
    % Display the video frame
    imshow(e);
    hold on
    
    % Draw the lines connecting the points
    for i = 2:numel(pointData)
        color = pointData(i).color;
        x = [pointData(i-1).x, pointData(i).x];
        y = [pointData(i-1).y, pointData(i).y];
        plot(x, y, 'Color', color, 'LineWidth', 2);
    end
    
    hold off
    drawnow;
end


function closeFigureCallback(~, ~)
    % Clean up and close the figure
    clc
    clear all
    close all
    warning on
    delete(gcf);
end

function colorDropdownCallback(hObject, ~)
    % Get the selected color from the dropdown menu
    colors = {'red', 'green', 'blue','yellow','cyan', 'magenta','white','black'};
    global currentColor;
    currentColor = colors{get(hObject, 'Value')};
end

function saveButtonCallback(~, ~)
    % Save the drawing to a file
    global pointData;
    filename = uiputfile('*.mat', 'Save Drawing');
    if filename ~= 0
        save(filename, 'pointData');
    end
end

function quitButtonCallback(~, ~)
    % Clean up and close the figure
    clc
    clear all
    close all
    warning on
    delete(gcf);
end