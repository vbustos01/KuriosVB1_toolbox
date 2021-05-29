clear all
% construccion del objeto
a = Kurios();

%% metodos
% mostrar las funciones del fabricante
% a.showLib

% cambiar ancho de banda
% 1 = BLACK mode
% 2 = WIDE mode
% 4 = MEDIUM mode
% 8 = NARROW mode
a.setBandwidth(2);

% obtener la temperatura del dispositivo
T = a.getTemperature();

% forzar el trigger
a.forceTrigger();

%% llamar funcion x con varios argumentos
% la funcion imprime todos los argumentos
% ademas utiliza el primer argumento dentro de dec2bin()
% callFunction('funcionX', 8,2,'helloWorld')

%% delete object
% se destruye el objeto, la conexion y se libera la memoria
delete(a);