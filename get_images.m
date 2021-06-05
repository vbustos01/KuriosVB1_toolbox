
filt = Kurios();
filt.setBwMode(2);
filt.setWavelength(470);
capture('470')
pause(2)
delete(filt);