close all; clear all; clc;

filename = 'dumb_face.png';
dir = 'C:\Users\joshu\Documents\GitHub\FlappyBird\Flappy_Bird2\assets\sprites';
finaldims = 30;

%% open webcam- and take photo

%get list of webcams
camlist = webcamlist;
fprintf('found %i webcam(s), ', length(camlist));
fprintf('connecting to %s\n', camlist{1});

%open webcam preview in figure window
cam = webcam(1);
fig = figure('NumberTitle','off','MenuBar','none');
fig.Name = 'Webcam Preview';

ax = axes(fig);         %get axes from figure
frame = snapshot(cam);  %take a temp snapshot to figure out image size
camout = image(ax,zeros(size(frame),'uint8')); 
axis(ax, 'image');

disp('opening webcam preview...');
previewImageObject = preview(cam, camout);

%Set image to be a mirror image view
previewImageObject.Parent.XDir='reverse';

setappdata(fig, 'cam', cam);

count = 4;
for i = 0:count
    htext = text(100,100,num2str(count - i));
    pause(1);
    delete(htext);
end

% take a photo
img = snapshot(cam);
disp('photo has been taken, detecting your face now...');


%% face detection
% create cascade detector object.
faceDetector = vision.CascadeObjectDetector();

% run the detector to create bounding box.
bbox = step(faceDetector, img);     %[x, y, width, height]

noseX = bbox(1)+bbox(3)./2;
noseY = bbox(2)+bbox(4)./2;
Radius = 1.1.*bbox(4)./2;
% Draw the bounding box around the detected face.
%imgout = insertObjectAnnotation(img,'rectangle',bbox, '');

% Draw circle around the face
imgout = insertShape(img, 'circle', [noseX, noseY, Radius], 'LineWidth', 1);

close all;
%figure

%imshow(imgout);
%title('Detected face');

%% change hue to detect skin tone vs background

% [hueChannel,~,~] = rgb2hsv(img);
% 
% % Display the Hue Channel data and draw the bounding box around the face.
% figure, imshow(hueChannel), title('Hue channel data');
% rectangle('Position',bbox(1,:),'LineWidth',2,'EdgeColor',[1 1 0]);
% hold on;
% 
% plot(bbox(1)+bbox(3)./2, bbox(2)+bbox(4)./2, 'ro', 'MarkerSize', 20);


%% output image to file

%make radius a little larger
bbox(3) = round(1.1*bbox(3));
bbox(4) = round(1.1*bbox(4));

%crop image to just face (square)
img = imcrop(img,bbox);

[y, x, ~] = size(img);
rad = floor(bbox(4)/2);

centerX = round(x./2);
centerY = round(y./2);

disp('extracting face');

for i=1:x
    for j = 1:y
        if(dist2(i,j,centerX,centerY) >= rad)    
            img(j,i,1) = 0;
            img(j,i,2) = 0;
            img(j,i,3) = 0;
        end
    end
end

%imshow(img);

%% resize to (20 x 20 px)

center = finaldims/2;

img = imresize(img,[finaldims finaldims]);
[height, width, ~] = size(img);

A = ones(height, width);

for i=1:width
    for j = 1:height
        if(dist2(i,j,center,center) >= finaldims/2)    
            A(i,j) = 0;
        end
    end
end

%% output image (with transparent pixels as .png)

fullFileName = fullfile(dir, filename);

fprintf('Writing file %s to %s...\n',filename, fullFileName);

imwrite(img, fullFileName, 'Alpha', A);

pause(0);
disp('Finished!');


%% clear everything

clear cam

pause(0);
disp('Goodbye');


%% run flappy bird python script

system('python Flappy_Bird2.py');













%% functions

function out = dist2(x1,y1,x2,y2)
    out = sqrt((x1-x2).^2 + (y1-y2).^2);
end

function out = dist3(r1,g1,b1,r2,g2,b2)
    out = sqrt((r1-r2).^2 + (g1-g2).^2 + (b1-b2).^2);
end