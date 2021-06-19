%% construccion del objeto:
clear all
filt = Kurios();

% atributos intrinsecos
% filt.id
% filt.limits
% filt.bwAvailable
% filt.spectrum

%% KURIOS GET
seq = filt.getSequence();
bwmode = filt.getBwMode();
[bw4seq, ts4seq, wavelength4seq] = filt.getDefaultSequenceConfig();
id = filt.getId();
[spec, bwAvailable] = filt.getOpticalHeadType();
ouptutMode = filt.getOutputMode();
seqL = filt.getSequenceLength();
% [n_wavelength, n_ts, n_bwmode] = filt.getSequenceStepData(1);
[lim_down, lim_up] = filt.getLimits();
status = filt.getStatus();
T = filt.getTemperature();
triggerMode = filt.getTriggerMode();
wavelength = filt.getWavelength();

%% KURIOS SET
%% cambiar ancho de banda
% 1 = BLACK mode
% 2 = WIDE mode
% 4 = MEDIUM mode
% 8 = NARROW mode
filt.setBwMode(2);
filt.bwMode
%% cambiar el modo de BW para todos los elementos de la secuencia
filt.setDefaultBw(8);
seq = filt.sequence
%% cambiar el tiempo para todos los elementos de la secuencia
filt.setDefaultTs(1000);
seq = filt.sequence
%% cambiar la longitud de onda para todos los elementos de la secuencia
filt.setDefaultWavelength(500);
seq = filt.sequence

%% insertar elementos en la secuencia en la posicion n
filt.insertSequenceStep(1, 710, 300, 4);
seq = filt.sequence
%% eliminar n-esimo elemento de la secuencia
% para eliminar todas las secuencias utilizar el 0
filt.deleteSequenceStep(0);
seq = filt.sequence

%% forzar el trigger
filt.forceTrigger()

%% cambiar el modo de salida del filtro
% 1 = modo manual
% 2 = modo secuencial con trigger interno
% 3 = modo secuencial con trigger externo
% 4 = modo secuencial con trigger interno
% 5 = modo secuencial con trigger externo
filt.setOutputMode(1)
ouptutMode = filt.OutputMode()

%% modificar un elemento de la secuencia
filt.deleteSequenceStep(0)
filt.insertSequenceStep(1, 450, 300, 4)
filt.insertSequenceStep(2, 500, 300, 4)
% se modifica el primer elemento
filt.setSequenceStepData(1,700,500,8)
seq = filt.Sequence

%% cambiar el modo de trigger
% 0 = modo normal
% 1 = modo invertido
filt.setTriggerMode(0)
triggerMode = filt.getTriggerMode()

%% cambiar longitud de onda
filt.setWavelength(550);
filt.Wavelength

%% TERMINAR CONEXION
% se destruye el objeto, la conexion y se libera la memoria, se puede usar
% ambos metodos:

%delete(filt);
clear all
