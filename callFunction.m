function callFunction(fn, varargin)
    % callFunction - utilizar cualquier funcion de la libreria
    %
    % Syntax: callFunction()
    %
    % Long description
    disp(strcat('funcion:   ',fn))
    disp(varargin{1})
    for i=varargin
        disp(i)
    end
    disp('usando un argumento:')
    x = dec2bin(varargin{1})
end