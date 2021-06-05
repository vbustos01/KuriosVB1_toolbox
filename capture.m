function capture(name)
%CAPTURE Summary of this function goes here
%   Detailed explanation goes here
% Escena
ima = imread('mage.png');
figure(1)
fig = gcf;
imshow(ima);
fig.ToolBar = 'none';
fig.Position = [50 0 300 300];
% Camara
vid = videoinput('pointgrey', 1, 'F7_Raw16_1920x1200_Mode7');
% src = getselectedsource(vid);
% preview_img = preview(vid);
% start(vid);
pause(2)
frame = getsnapshot(vid);
frame = double(frame);
figure(2)
fig = gcf;
imshow(frame,[]);
fig.Position = [50 350 540 400];
saveas(figure(2), strcat('Kurios_',name,'_caption.png'));
close all
end

