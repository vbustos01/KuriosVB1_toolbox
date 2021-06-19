function ima = capture(name,gain,shutter)
    %CAPTURE Summary of this function goes here
    %   Detailed explanation goes here
    % Escena
    scene = imread('peppers.png');
    % scene = imread('mage.png');
    figure(1)
    fig = gcf;
    imshow(scene);
    fig.ToolBar = 'none';
    fig.Position = [50 0 300 300];
    %% Camara
    vid = videoinput('pointgrey', 1, 'F7_Raw16_1920x1200_Mode7');
    src.Gain = gain;
    src.Shutter = shutter;
    vid.ROIPosition = [492 128 1184 986];
    ima = getsnapshot(vid);
    ima = double(frame);
    % figure(2)
    % fig = gcf;
    % imshow(frame,[]);
    % fig.Position = [50 350 540 400];
    % saveas(figure(2), strcat('Kurios_',name,'_caption.png'));
    close all
end
    
    