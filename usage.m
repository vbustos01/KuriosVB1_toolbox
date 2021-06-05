% clear all
% construccion del objeto
filt = Kurios();

%% metodos
% mostrar las funciones del fabricante
% a.showLib

%% cambiar ancho de banda
% 1 = BLACK mode
% 2 = WIDE mode
% 4 = MEDIUM mode
% 8 = NARROW mode
filt.setBwMode(2);

%% cambiar longitud de onda
filt.setWavelength(500);

%% perform sequence
seqmode = 4;
time_step = 2;
in_wavelength = 430;
wavestep = 20;

for i = in_wavelength:wavestep:730
    filt.setWavelength(i);
    pause(time_step);
end

%% metdos get
T = filt.getTemperature();
bwmode = filt.getBwMode();
[bw4seq, ts4seq, wavelength4seq] = filt.getDefaultSequenceConfig();
id = filt.getId();
[spec, bwAvailable] = filt.getOpticalHeadType();
ouptutMode = filt.getOutputMode();
seqL = filt.getSequenceLength();
%[a b c] = filt.getSequenceStepData();
[lim_down, lim_up] = filt.getSpecification();
status = filt.getStatus();
T = filt.getTemperature();
triggerMode = filt.getTriggerMode();
wavelength = filt.getWavelength();
seq = filt.getSequence();
%% actualizar el objeto
filt.getAll()

%% delete object
% se destruye el objeto, la conexion y se libera la memoria
delete(filt);