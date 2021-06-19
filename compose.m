load ima.mat
% %% subplots
% % figure(1)
% % for i=1:8
% %     pBuff = ima(:,:,i);
% %     subplot(2,4,i)
% %         imshow(pBuff,[]);
% %         xlabel(380+40*i)
% % end
% %% transformada de fourier
% % figure(2)
% % for i=1:8
% %     spec(:,:,i) = fftshift(fft2(ima(:,:,i)));
% %     specdb = log10(abs(spec(:,:,i)).^2);
% %     subplot(2,4,i)
% %         imshow(specdb,[])
% % end
% % saveas(figure(2), strcat('','.tif'))
%% filtrado de ruido
for i=1:8
    pBuffer = ima(:,:,i);
    pBuffer = double(pBuffer);
    pBuffer = imgaussfilt(pBuffer, 1);
    ima(:,:,i) = pBuffer;
end
%% imagen a color artificial
wavelength = [420,460,500,540,580,620,660,700];
hcube = hypercube(ima,wavelength);
imaComp = colorize(hcube);
figure;fig = gcf;imshow(imaComp);saveas(fig,'imagenCompuesta.tif')