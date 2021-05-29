clear all;close all;
warning('off')
%% variables temporales
fs = 1e03;
ts = 1/fs;
t = 0:ts:2;


%% variables de imagen
% imagen RGB
[corn_rgb] = imread('corn.tif',2);
figure(1)
    imshow(corn_rgb)

% imagen indexada
[peppers peppers_map] = imread('peppers.png');
figure(2)
    imshow(peppers, peppers_map) % en este caso pp_map es []
%% animacion
[x y index] = size(peppers);
figure(3)
for i=1:x
    for j=1:y
        a = categorical({'R' ,'G','B'});
        b = [peppers(i,j,1), peppers(i,j,2), peppers(i,j,3)];
        stem(a,b)
            title('Animacion')
            ylim([0 255])
        pause(.1)
    end
end