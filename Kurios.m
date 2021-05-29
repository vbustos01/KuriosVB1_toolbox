classdef Kurios
%--------------------------------------------------------------------------
% Syntax:       Kurios();
%
% Inputs:       none
%               
% Outputs:      filt es un objeto con los siguientes metodos publicos:
%               
%                 filt.setBandwidth();              % Cambiar la longitud de onda
%                 filt.showLib();                   % Mostrar las funciones de la libreria
%             T = filt.getTemperature(FENstr);      % Obtener la temperatura del filtro
%               
% Note:         Esta libreria fue programada para el filtro ajustable
%               Kurios VB1 by thorlabs, si se desea utilizar con otro
%               modelo se deben realizar las modificaciones respectivas
%               
% Author:       Victor M. Bustos
%               v.bustos01@ufromail.cl
%               
% Release:      
%--------------------------------------------------------------------------
    properties
        libname
        hfile
        isOperative
        deviceHandle
        buffer
        bwMode
        Temperature
    end

    methods     
        function obj = Kurios()
            % este metodo es el constructor (__init__), se utiliza
            % para relacionar el objeto Kurios, la libreria y el dispositivo
            
            obj.libname = 'KURIOS_COMMAND_LIB_Win64';
            obj.hfile   = 'KURIOS_COMMAND_LIB.h';
            
            % carga de la libreria
            if libisloaded(obj.libname)
                unloadlibrary(obj.libname);
            end
            loadlibrary(strcat(obj.libname,'.dll'),obj.hfile);
            % conexion con el dispositivo
            
            try
                obj.buffer = libpointer('voidPtr',uint8(zeros(1, 255)));
                check = calllib(obj.libname,'common_List',obj.buffer);
                ports= [];
                % condicional, si se detecta un dispositivo
                if check>=1
                    ports = strsplit(char(obj.buffer.Value),',')';
                else
                    error('No se pudo conectar el dispositivo')
                end
                serialNo = char(ports(1,1));
                obj.deviceHandle = calllib(obj.libname,'common_Open',serialNo,115200,3);
                disp('[+]conexion lista king')
                obj.isOperative = true;
                clear obj.buffer
            catch 
                warning('Hubo un error al conectar, intente crear un nuevo objeto.');
            end
        end

        function list = showLib(obj)
            % showLib - Mostrar las funciones de la libreria
            %
            % Syntax: showLib()
            %
            % Long description
            % esta funcion se utiliza para mostrar todas las funciones
            % disponibles en la libreria
            list = libfunctions(obj.libname);
        end

        %KURIOS GET
        function sequence = getAllSequenceData(obj)
            % getAllSequenceData - obtener la data de la secuencia completa
            %
            % Syntax: seqData = getAllSequenceData(input)
            %
            % Long description
            if obj.isOperative
                try
                    pbuffer = libpointer('voidptr',uint8(zeros(1, 255)));
                    bSuccess = calllib(obj.libname,'kurios_Get_AllSequenceData',obj.deviceHandle,pbuffer);
                    if(bSuccess~=0)
                        sequence = NaN;
                        error('fallo al obtener la secuencia')
                    end
                    clear('pbuffer')
                catch
                    warning('La secuencia no se pudo obtener correctamente')
                end
            else
                sequence = NaN;
                disp('[+] El dispositivo no esta disponible. intente reinicializar la conexion')
            end
                
        end

        function bwMode = getBwMode(obj)
            %getBwMode - Obtener el modo de ancho de banda
            %
            % Syntax: bwMode = getBwMode()
            %
            % Long description
            if obj.isOperative
                try
                    pbuffer = libpointer('voidptr',int32(zeros(1, 255)));
                    bSuccess = calllib(obj.libname,'kurios_Get_BandwidthMode',obj.deviceHandle,pbuffer);
                    if(bSuccess~=0)
                        bwMode = NaN;
                        error('fallo al obtener el ancho de banda')
                    end
                    clear('pbuffer')
                catch
                    warning('el ancho de banda no se pudo obtener correctamente')
                end
            else
                bwMode = NaN;
                disp('[+] El dispositivo no esta disponible. intente reinicializar la conexion')
            end      
        end

        function bw4sequence = defaultBwForSequence(obj)
            %defaultBwForSequence - Description
            %
            % Syntax: bw4sequence = defaultBwForSequence()
            %
            % Long description
            if obj.isOperative
                try
                    pbuffer = libpointer('voidptr',int32(zeros(1, 255)));
                    bSuccess = calllib(obj.libname,'kurios_Get_DefaultBandwidthForSequence',obj.deviceHandle,pbuffer);
                    if(bSuccess~=0)
                        bw4sequence = NaN;
                        error('fallo al obtener el ancho de banda determinado para la secuencia')
                    end
                    clear('pbuffer')
                catch
                    warning('el ancho de banda determinado para la secuencia no se pudo obtener correctamente')
                end
            else
                bw4sequence = NaN;
                disp('[+] El dispositivo no esta disponible. intente reinicializar la conexion')
            end  
        end

        function ts4Sequence = defaultTimeIntervalForSequence(obj)
            %defaultTimeIntervalForSequence - Description
            %
            % Syntax: ts4Sequence = defaultTimeIntervalForSequence()
            %
            % Long description
            if obj.isOperative
                try
                    pbuffer = libpointer('voidptr',int32(zeros(1, 255)));
                    bSuccess = calllib(obj.libname,'kurios_Get_DefaultTimeIntervalForSequence',obj.deviceHandle,pbuffer);
                    if(bSuccess~=0)
                        ts4Sequence = NaN;
                        error('fallo al obtener el intervalo de tiempo determinado para la secuencia')
                    end
                    clear('pbuffer')
                catch
                    warning('el intervalo de tiempo determinado para la secuencia no se pudo obtener correctamente')
                end
            else
                ts4Sequence = NaN;
                disp('[+] El dispositivo no esta disponible. intente reinicializar la conexion')
            end  
        end

        function wavelenght4Sequence = defaultWavelengthForSequence(obj)
            %defaultWavelengthForSequence - Description
            %
            % Syntax: wavelenght4Sequence = defaultWavelengthForSequence()
            %
            % Long description
            if obj.isOperative
                try
                    pbuffer = libpointer('voidptr',int32(zeros(1, 255)));
                    bSuccess = calllib(obj.libname,'kurios_Get_DefaultWavelengthForSequence',obj.deviceHandle,pbuffer);
                    if(bSuccess~=0)
                        wavelenght4Sequence = NaN;
                        error('fallo al obtener la longitud de onda determinada para la secuencia')
                    end
                    clear('pbuffer')
                catch
                    warning('la longitud de onda determinado para la secuencia no se pudo obtener correctamente')
                end
            else
                wavelenght4Sequence = NaN;
                disp('[+] El dispositivo no esta disponible. intente reinicializar la conexion')
            end    
        end

        function id = getId(obj)
            %getId - Obtener la ID del dispositivo
            %
            % Syntax: id = filt.getId()
            %
            % La funcion permite obtener el numero de modelo, la version de hardware
            % y la version de firmware del dispositivo.
            if obj.isOperative
                try
                    pbuffer = libpointer('voidptr',uint8(zeros(1, 255)));
                    bSuccess = calllib(obj.libname,'kurios_Get_ID',obj.deviceHandle,pbuffer);
                    if(bSuccess~=0)
                        id = NaN;
                        error('fallo al obtener la ID')
                    end
                    clear('pbuffer')
                catch
                    warning('La ID no se pudo obtener correctamente')
                end
            else
                id = NaN;
                disp('[+] El dispositivo no esta disponible. intente reinicializar la conexion')
            end
        end

        function opticalHeadType = getOpticalHeadType(obj)
            %GetOpticalHeadType - Description
            %
            % Syntax: opticalHeadType = GetOpticalHeadType()
            %
            % Long description
            if obj.isOperative
                try
                    pbuffer1 = libpointer('voidptr',uint8(zeros(1, 255)));
                    pbuffer2 = libpointer('voidptr',uint8(zeros(1, 255)));
                    bSuccess = calllib(obj.libname, 'kurios_Get_ID', obj.deviceHandle, pbuffer1, pbuffer2);
                    if(bSuccess~=0)
                        opticalHeadType = NaN;
                        error('fallo al obtener el tipo de cabezal optico')
                    end
                    clear('pbuffer')
                catch
                    warning('El tipo de cabezal optico no se pudo obtener correctamente')
                end
            else
                opticalHeadType = NaN;
                disp('[+] El dispositivo no esta disponible. intente reinicializar la conexion')
            end
        end

        function output = getOutputMode(obj)
        %getOutputMode - Description
        %
        % Syntax: output = getOutputMode()
        %
        % Long description
            
        end

        function output = getSequenceLength(obj)
        %getSequenceLength - Description
        %
        % Syntax: output = getSequenceLength(input)
        %
        % Long description
            
        end

        function output = getSequenceStepData(obj)
        %getSequenceStepData - Description
        %
        % Syntax: output = getSequenceStepData(input)
        %
        % Long description
            
        end

        function output = getSpecification(obj)
        %getSpecification - Description
        %
        % Syntax: output = getSpecification()
        %
        % Long description
            
        end

        function output = getStatus(obj)
        %getStatus - Description
        %
        % Syntax: output = getStatus()
        %
        % Long description
            
        end

        function T = getTemperature(obj)
            % getTemperature - Obtener la temperatura del filtro
            %
            % Syntax: T = getTemperature()
            %
            % Long description
            if obj.isOperative
                try
                    pbuffer = libpointer('voidptr',double(zeros(1, 255)));
                    bSuccess = calllib(obj.libname,'kurios_Get_Temperature',obj.deviceHandle,pbuffer);
                    if(bSuccess~=0)
                        T = NaN;
                        error('fallo al obtener la temperatura')
                    end
                    T = obj.buffer.Value;
                    clear('pbuffer')
                catch
                    warning('La temperatura no se pudo obtener correctamente')
                end
            else
                T = NaN;
                disp('[+] El dispositivo no esta disponible. intente reinicializar la conexion')
            end
        end

        function output = getTriggerOutSignalMode(obj)
        %getTriggerOutSignalMode - Description
        %
        % Syntax: output = getTriggerOutSignalMode()
        %
        % Long description
            
        end

        function wl = getWavelength(obj)
        %getWavelength - Description
        %
        % Syntax: wl = getWavelength()
        %
        % Long description
            
        end

        %% KURIOS SET
        function setBandwidth(obj, mode)
            % setBandwidth - configurar el ancho de banda del filtro
            %
            % Syntax: setBandwidth(mode)
            %
            % esta funcion es para modificar el ancho de banda del filtro,
            % se cuenta con los siguientes modos:
            % 1 = BLACK mode
            % 2 = WIDE mode
            % 4 = MEDIUM mode
            % 8 = NARROW mode
            if obj.isOperative
                try
                    bSuccess = calllib(obj.libname,'kurios_Set_BandwidthMode',obj.deviceHandle,mode);
                    if(bSuccess~=0)

                        error('fallo al cambiar el ancho de banda')
                    end
                catch
                    warning('El ancho de banda no cambio')
                end
            else
                disp('[+] El dispositivo no esta disponible. intente reinicializar la conexion')
            end
        end

        function forceTrigger(obj)
            % forceTrigger - Forzar el disparo
            %
            % Syntax: forceTrigger()
            %
            % Long description
            if obj.isOperative
                try
                    bSuccess = calllib(obj.libname,'kurios_Set_ForceTrigger',obj.deviceHandle);
                    if(bSuccess~=0)
                        error('fallo al forzar el trigger')
                    end
                catch
                    warning('No se pudo forzar el trigger')
                end
            else
                disp('[+] El dispositivo no esta disponible. intente reinicializar la conexion')
            end
        end

        function setWavelength(obj, wavelength)
            % setWavelength - configurar el ancho de banda del filtro
            %
            % Syntax: setWavelength(mode)
            %
            % esta funcion es para modificar la frecuencia central del filtro, este valor
            % debe pertenecer al intervalo [420,730] que es el rango del filtro
            if (wavelength < 420)|(wavelength > 730)
                error('la longitud de onda ingresada no es valida, intente con un numero entre 430 y 720')
            end

            if obj.isOperative
                try
                    bSuccess = calllib(obj.libname,'kurios_Set_Wavelength',obj.deviceHandle,wavelength);
                    if(bSuccess~=0)

                        error('fallo al cambiar la longitud de onda')
                    end
                catch
                    warning('La longitud de onda no cambio')
                end
            else
                disp('[+] El dispositivo no esta disponible. intente reinicializar la conexion')
            end
        end

        %% funciones propias

        function getAll(obj)
        %getAll - obtener todos los parametros del objeto
        %
        % Syntax: filt.getAll()
        %
        % a traves de este metodo se actualizan los atributos del objeto filt
        obj.bwMode      = obj.getBwMode()
        obj.temperature = obj.getTemperature()

            
        end
        function delete(obj)
            % esta funcion se ejectuta cuando el objeto se elimina
            % para eliminar un objeto se utiliza el comando delete(objeto)
            % en este caso cierra la conexion con el dispositivo y cierra la
            % libreria
            if obj.deviceHandle>=0
                bCloseSuccess = calllib(obj.libname,'common_Close',obj.deviceHandle);
            end
            if libisloaded('KURIOS_COMMAND_LIB_Win64') && ~isempty('KURIOS_COMMAND_LIB_Win64')
                unloadlibrary(obj.libname);
            end
            disp('[+]Libreria y conexion cerrada')
        end
    end
end
