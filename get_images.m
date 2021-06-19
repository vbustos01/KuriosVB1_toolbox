warning('off')
filt = Kurios();                    % se crea una instancia del filtro
%%
filt.setBwMode(2);                  % modo banda ancha
filt.setWavelength(filt.limits(1)); % se posiciona el filtro en el limite inferior
% wavelength = 420:10:730;
wavelength = 420:40:730;
gain = 25;
shutter = 997;
%%
for i=wavelength
    filt.setWavelength(i);
    capture(num2str(i),gain,shutter);
    pause(2)
end

