classdef Kurios < handle
%--------------------------------------------------------------------------
% Syntax:       Kurios();
%
% Inputs:       none
%               
% Outputs:      
%           filt es un objeto creado a partir de la clase Kurios() con los siguientes metodos publicos:
%           confirm = filt.checkLink()
%           KURIOS GET
%                   filt.getSequence
%                   filt.getBwMode
%                   filt.getDefaultSequenceConfig
%                   filt.getId
%                   filt.getOpticalHeadType
%                   filt.getOutputMode
%                   filt.getSequenceLength
%                   filt.getSequenceStepData
%                   filt.getSpecification
%                   filt.getStatus
%                   filt.getTemperature
%                   filt.getTriggerMode
%                   filt.getWavelength
%--------------------------------------------------------------------------
%           KURIOS SET
%                   filt.setBwMode
%                   filt.setDefaultBw
%                   filt.setDefaultTs
%                   filt.setDefaultWavelength
%                   filt.deleteSequenceStep
%                   filt.insertSequenceStep
%                   filt.forceTrigger
%                   filt.setOutputMode
%                   filt.sequenceStepData
%                   filt.triggerMode
%                   filt.setWavelength
%--------------------------------------------------------------------------
%           OTRAS FUNCIONES
%                   filt.updateInfo()
%                   filt.showLib()

% Note:         Esta libreria fue programada para el filtro ajustable
%               Kuri        os VB1 by thorlabs, si se desea utilizar con otro
%               modelo se deben realizar las modificaciones respectivas.
%               
%               La libreria permite la realizacion de Secuencias, las cuales consisten
%               en barridos de longitud de onda a cierto intervalo de tiempo y con
%               un ajuste de ancho de banda predeterminado
%               
%               si desea ayuda con un metodo utilice el comando help:
%                   help filt.setDefaultBw()
%               
% Author:       Victor M. Bustos
%               v.bustos01@ufromail.cl
%               
% Release:      
%--------------------------------------------------------------------------
    properties
        % de la libreria
        libname
        hfile
        isOperative
        deviceHandle
        % intrinsecos
        id
        limits
        bwAvailable
        spectrum
        % estado del filtro
        temperature
        status
        % config
        bwMode
        wavelength
        triggerMode
        outputMode
        % sequence
        sequence
        sequenceLength
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
            pbuffer = libpointer('voidPtr',uint8(zeros(1, 255)));
            check = calllib(obj.libname,'common_List',pbuffer);
            ports= [];
            if check>=1
                ports = strsplit(char(pbuffer.Value),',')';
            else
                error('No se pudo conectar el dispositivo')
            end
            serialNo = char(ports(1,1));
            obj.deviceHandle = calllib(obj.libname,'common_Open',serialNo,115200,3);
            obj.isOperative =   true;
            list = libfunctions(obj.libname);
            obj.id = obj.getId();
            [obj.spectrum, obj.bwAvailable] = obj.getOpticalHeadType();
            [aux1,aux2]=obj.getLimits()
            obj.limits=[aux1,aux2]
        end

        function confirm = checkLink()
            %checkLink - verificar el enlace con el dispositivo
            %
            % Syntax: confirm = filt.checkLink()
            %
            % esta funcion utiliza el metodo IsOpen() de la libreria para verificar si
            % la conexion con el filtro aun se encuentra disponible
            pbuffer = libpointer('cstring',char(zeros(1, 255)));
            check = calllib(obj.libname,'common_IsOpen',pbuffer);
            confirm = pbuffer.Value;
            if confirm == 1
                obj.isOperative = true;
            else
                obj.isOperative = false;
            end 
        end

        function fastCheck(obj,check)

        end

        %% KURIOS GET
        function sequence = getSequence(obj)
            % getSequence - obtener la lista de elementos de la secuencia
            %
            % Syntax: seqData = filt.getSequence(input)
            %
            % con este metodo es posible obtener una lista de todos los
            % elementos que hayan sido agregados a la secuencia, cuando el
            % filtro se encuentra en modo secuencia realizara uno por uno
            % los modos configurados en esta lista.
            obj.getSequenceLength(); % se refresca el largo actual de la secuencia
            pbuffer = libpointer('uint8Ptr',uint8(zeros(1, obj.sequenceLength+10)));
            check = calllib(obj.libname,'kurios_Get_AllSequenceData',obj.deviceHandle,pbuffer);
            if(check~=0)
                sequence = NaN;
                error('fallo al obtener la secuencia')
            end
            sequence = char(pbuffer.Value);
            % obj update
            obj.sequence = sequence;
        end

        function bwMode = getBwMode(obj)
            %getBwMode - Obtener el modo de ancho de banda
            %
            % Syntax: bwMode = filt.getBwMode()
            %
            % la funcion devolvera un numero segun el modo:
            % 1 = modo negro
            % 2 = modo ancho
            % 4 = modo mediano
            % 8 = modo angosto
            pbuffer = libpointer('int32Ptr',int32(NaN));
            check = calllib(obj.libname,'kurios_Get_BandwidthMode',obj.deviceHandle,pbuffer);
            if(check~=0)
                bwMode = NaN;
                error('fallo al obtener el ancho de banda')
            end
            modes = ["BLACK", "WIDE", "MEDIUM", "NARROW"];
            bwMode = modes(log2(pbuffer.Value)+1);
            % obj update
            obj.bwMode=bwMode;
        end

        function [bw, ts, wavelength] = getDefaultSequenceConfig(obj)
            %getDefaultSequenceConfig - obtener la configuracion predeterminada para realizar una secuencia
            %
            % Syntax: [bw, ts, wavelength] = filt.getDefaultSequenceConfig(input)
            %
            % esta funcion devuelve la configuracion por default de los elementos de la lista de secuencia
            % devuelve el ancho de banda por defecto (bw), el intervalo de tiempo (ts) y la longitud
            % de onda por defecto (wavelength).
            pbuffer1 = libpointer('int32Ptr',int32(NaN));
            pbuffer2 = libpointer('int32Ptr',int32(NaN));
            pbuffer3 = libpointer('int32Ptr',int32(NaN));
            check = calllib(obj.libname,'kurios_Get_DefaultBandwidthForSequence',obj.deviceHandle,pbuffer1);
            if(check~=0)
                bw = NaN;
                error('fallo al obtener el ancho de banda determinado para la secuencia')
            end
            check = calllib(obj.libname,'kurios_Get_DefaultTimeIntervalForSequence',obj.deviceHandle,pbuffer2);
            if(check~=0)
                ts = NaN;
                error('fallo al obtener el tiempo de muestreo determinado para la secuencia')
            end
            check = calllib(obj.libname,'kurios_Get_DefaultWavelengthForSequence',obj.deviceHandle,pbuffer3);
            if(check~=0)
                wavelength = NaN;
                error('fallo al obtener la longitud de onda determinada para la secuencia')
            end
            bw = char(pbuffer1.Value);
            ts = pbuffer2.Value;
            wavelength = pbuffer3.Value;
        end

        function id = getId(obj)
            %getId - Obtener la ID del dispositivo
            %
            % Syntax: id = filt.getId()
            %
            % La funcion permite obtener el numero de modelo, la version de hardware
            % y la version de firmware del dispositivo.
            pbuffer = libpointer('uint8Ptr',uint8(zeros(1, 128)));
            check = calllib(obj.libname,'kurios_Get_ID',obj.deviceHandle,pbuffer);
            if(check~=0)
                id = NaN;
                error('fallo al obtener la ID')
            end
            id = char(pbuffer.Value);
        end

        function [spectrum, bwModeAvailable] = getOpticalHeadType(obj)
            %GetOpticalHeadType - Description
            %
            % Syntax: opticalHeadType = filt.getOpticalHeadType()
            %
            % Esta funcion devuelve el tipo de espectro que posee el filtro, puede
            % ser de tipo VIS o NIR, tambien devuelve los modos de ancho de banda
            % disponibles en el filtro.
            pbuffer1 = libpointer('uint8Ptr',uint8(NaN));
            pbuffer2 = libpointer('uint8Ptr',uint8(NaN));
            check = calllib(obj.libname, 'kurios_Get_OpticalHeadType', obj.deviceHandle, pbuffer1, pbuffer2);
            if(check~=0)
                opticalHeadType = NaN;
                error('fallo al obtener el tipo de cabezal optico')
            end
            if pbuffer1.Value==1
                spectrum='NIR';
            else
                spectrum='VIS';
            end
            aux = dec2bin(pbuffer2.Value);modes = ["BLACK", "WIDE", "MEDIUM", "NARROW"];
            if length(aux)==1
                aux=['000',aux];
            elseif length(aux)==2
                aux = ['00',aux];
            elseif length(aux)==3
                aux = ['0',aux];
            end
            count=1;bwModeAvailable=[];
            for i=aux
                if strcmp(i,'1')
                    bwModeAvailable=[bwModeAvailable, modes(count)];
                end
                count=count+1;
            end            
        end

        function outputMode = getOutputMode(obj)
            %getOutputMode - obtener el modo de salida del filtro
            %
            % Syntax: outputMode = filt.getOutputMode()
            %
            % 1 = modo manual
            % 2 = modo secuencial con trigger interno
            % 3 = modo secuencial con trigger externo
            % 4 = modo secuencial con trigger interno
            % 5 = modo secuencial con trigger externo
            pbuffer = libpointer('int32Ptr',int32(NaN));
            check = calllib(obj.libname,'kurios_Get_OutputMode',obj.deviceHandle,pbuffer);
            if(check~=0)
                outputMode = NaN;
                error('fallo al obtener el modo de salida')
            end
            outputMode = pbuffer.Value;
            % obj update
            obj.ouptutMode = outputMode;
        end

        function sequenceLength = getSequenceLength(obj)
            %getSequenceLength - devuelve el numero de elementos en la
            %lista de secuencia
            %
            % Syntax: sequenceLength = filt.getSequenceLength()
            %
            % esta funcion devuelve el largo actual de la secuencia
            pbuffer = libpointer('int32Ptr',int32(NaN));
            check = calllib(obj.libname,'kurios_Get_SequenceLength',obj.deviceHandle,pbuffer);
            if(check~=0)
                sequenceLength = NaN;
                error('fallo al obtener el largo de la secuencia')
            end
            sequenceLength = pbuffer.Value;
            obj.sequenceLength = sequenceLength;
        end

        function [wavelength, ts, bwmode] = getSequenceStepData(obj,n)
            %getSequenceStepData - obtener la configuracion del n-esimo
            %elemento de  la secuencia.
            %
            % Syntax: [wavelength ts bwmode] = filt.getSequenceStepData(input)
            %
            % con esa funcion es posible obtener los parametros de un determinado elemento de la secuencia
            pbuffer1 = libpointer('int32Ptr',int32(NaN));
            pbuffer2 = libpointer('int32Ptr',int32(NaN));
            pbuffer3 = libpointer('int32Ptr',int32(NaN));
            check = calllib(obj.libname,'kurios_Get_SequenceStepData',obj.deviceHandle,n,pbuffer1,pbuffer2,pbuffer3);
            if(check~=0)
                wavelength=NaN;ts=NaN;bwmode=NaN;
                error('fallo al obtener el tiempo de muestreo del trigger')
            end
            wavelength = pbuffer1.Value;
            ts = pbuffer2.Value;
            bwmode = pbuffer3.Value;
        end

        function [lim_down, lim_up] = getLimits(obj)
            %getSpecification - obtener el rango de longitud de onda
            %
            % Syntax: [lim_down, lim_up] = filt.getLimits()
            %
            % esta funcion retorna los limites de ancho de banda configurables en el filtro
            pbuffer1 = libpointer('int32Ptr',int32(NaN));
            pbuffer2 = libpointer('int32Ptr',int32(NaN));
            check = calllib(obj.libname, 'kurios_Get_Specification', obj.deviceHandle, pbuffer1, pbuffer2);
            if(check~=0)
                lim_down=NaN;lim_up=NaN;
                error('fallo al obtener el rango de longitud de onda del filtro')
            end
            lim_down = double(pbuffer1.Value);
            lim_up = double(pbuffer2.Value);
        end

        function status = getStatus(obj)
            %getStatus - Description
            %
            % Syntax: status = filt.getStatus()
            %
            % esta funcion permite obtener el estado actual del filtro, pueden ser tres opciones:
            % 'initialization'  :   el filtro se encuentra inicializando
            % 'warming up'      :   el filtro esta alcanzando su temperatura de operacion
            % 'ready'           :   se ha alcanzado la temperatura de operacion y ya se puede utilizar el filtro
            pbuffer = libpointer('int32Ptr',int32(NaN));
            check = calllib(obj.libname,'kurios_Get_Status',obj.deviceHandle,pbuffer);
            if(check~=0)
                status = NaN;
                error('fallo al obtener el estado del filtro')
            end
            status = pbuffer.Value;
            switch status
            case status==0
                obj.status = 'initialization';
            case status==1
                obj.status = 'warming up';
            case status==2
                obj.status = 'ready';
            end
        end

        function T = getTemperature(obj)
            % getTemperature - Obtener la temperatura del filtro
            %
            % Syntax: T = filt.getTemperature()
            %
            % esta funcion permite obtener la temperatura actual del filtro.
            pbuffer = libpointer('doublePtr',double(0));
            check = calllib(obj.libname,'kurios_Get_Temperature',obj.deviceHandle,pbuffer);
            if(check~=0)
                T = NaN;
                error('fallo al obtener la temperatura')
            end
            T = pbuffer.Value;
            obj.temperature = T;
        end

        function triggerMode = getTriggerMode(obj)
            %getTriggerMode - obtener el modo de trigger
            %
            % Syntax: triggerMode = filt.getTriggerMode()
            %
            % devuelve el modo de trigger configurado
            % 0 :   normal
            % 1 :   invertido
            pbuffer = libpointer('int32Ptr',int32(NaN));
            check = calllib(obj.libname,'kurios_Get_TriggerOutSignalMode',obj.deviceHandle,pbuffer);
            if(check~=0)
                triggerMode = NaN;
                error('fallo al obtener el modo de trigger')
            end
            triggerMode = pbuffer.Value;
            obj.triggerMode = triggerMode;
        end

        function wavelength = getWavelength(obj)
            %getWavelength - obtener la longitud de onda central del filtro
            %
            % Syntax: wavelength = filt.getWavelength()
            %
            % esta funcion permite obtener la longitud de onda central del filtro, es
            % decir, la componente del espectro que esta dejando pasar el filtro segun
            % el ancho de banda configurado.
            pbuffer = libpointer('int32Ptr',int32(NaN));
            check = calllib(obj.libname,'kurios_Get_Wavelength',obj.deviceHandle,pbuffer);
            if(check~=0)
                wavelength = NaN;
                error('fallo al obtener la longitud de onda del filtro')
            end
            wavelength = pbuffer.Value;
            obj.wavelength = wavelength;
        end

        %% KURIOS SET
        function setBwMode(obj, mode)
            % bwMode - configurar el ancho de banda del filtro
            %
            % Syntax: bwMode(mode)
            %
            % esta funcion es para modificar el ancho de banda del filtro,
            % se cuenta con los siguientes modos:
            % 1 = modo negro
            % 2 = modo ancho
            % 4 = modo mediano
            % 8 = modo angosto
            check = calllib(obj.libname,'kurios_Set_BandwidthMode',obj.deviceHandle,mode);
            pause(1);
            if(check~=0)
                error('fallo al cambiar el ancho de banda')
            end
            obj.bwMode = mode;
        end

        function setDefaultBw(obj,bwmode)
            %setDefaultBw - Establecer el modo de ancho de banda predeterminado para todos los elementos de la secuencia.
            %
            % Syntax: filt.setDefaultBw(bwmode)
            %
            % 1 = modo negro
            % 2 = modo ancho
            % 4 = modo mediano
            % 8 = modo angosto
            check = calllib(obj.libname,'kurios_Set_DefaultBandwidthForSequence',obj.deviceHandle,bwmode);
            if(check~=0)
                error('fallo al cambiar el ancho de banda por defecto en la secuencia')
            end
            obj.getSequence();
        end
        

        function setDefaultTs(obj,ts)
            %setDefaultTs - Establecer el intervalo de tiempo predeterminado para todos los elementos de la secuencia.
            %
            % Syntax: filt.setDefaultTs(ts)
            %
            % Cambia el tiempo que tomara cada uno de los elementos de la
            % secuencia
            % ts: tiempo en milisegundos
            check = calllib(obj.libname,'kurios_Set_DefaultTimeIntervalForSequence',obj.deviceHandle,ts);
            if(check~=0)
                error('fallo al cambiar el intervalo de tiempo por defecto en la secuencia')
            end
            obj.getSequence();
        end

        function setDefaultWavelength(obj,wavelength)
            %setDefaultWavelength - Establecer la longitud de onda predeterminada para todos los elementos de la secuencia.
            %
            % Syntax: filt.setDefaultWavelength(wavelength)
            %
            check = calllib(obj.libname,'kurios_Set_DefaultWavelengthForSequence',obj.deviceHandle,wavelength);
            if(check~=0)
                error('fallo al cambiar la longitud de onda por defecto en la secuencia')
            end
            obj.getSequence();
        end

        function deleteSequenceStep(obj,n)
            %deleteSequenceStep - elimina la n-esima entrada en la lista de secuencias.
            %
            % Syntax: filt.deleteSequenceStep(n)
            %
            % esta funcion sirve para eliminar cualquier elemento que se haya agregado a la secuencia
            % para borrar la secuencia completa se utiliza n=0
            % n: numero entre 1 y 1024
            check = calllib(obj.libname,'kurios_Set_DeleteSequenceStep',obj.deviceHandle,n);
            if(check~=0)
                error('fallo al eliminar elemento en la secuencia')
            end
            obj.getSequence();
        end

        function insertSequenceStep(obj,n,wavelength,ts,bwmode)
            % insertSequenceStep - Insertar una orden a la lista de secuencias en la n-esima posicion.
            %
            % Syntax: filt.insertSequenceStep()
            %
            % cada una de las ordenes que ingresemos en la secuencia se ejecutara
            % de forma secuencial cuando el modo de salida del filtro sea el MODO SECUENCIA (sequence mode)
            % n: numero entre 1 y 1024
            check = calllib(obj.libname,'kurios_Set_InsertSequenceStep',obj.deviceHandle,n,wavelength,ts,bwmode);
            if(check~=0)
                error('fallo al agregar elemento en la secuencia')
            end
            obj.getSequence();
        end

        function forceTrigger(obj)
            % forceTrigger - Forzar el trigger
            %
            % Syntax: filt.forceTrigger()
            %
            % Esta funcion realiza un forzado del trigger, es decir, si se
            % encuentra en el modo secuencial o el modo analogo se
            % efectuara un pulso de disparo que pasara al siguiente
            % elemento de la secuencia sin esperar el tiempo
            % predeterminado.
            check = calllib(obj.libname,'kurios_Set_ForceTrigger',obj.deviceHandle);
            if(check~=0)
                error('fallo al forzar el trigger')
            end
        end

        function setOutputMode(obj, mode)
            % setOutputMode - Establecer el modo de salida del filtro
            %
            % Syntax: filt.setOutputMode()
            %
            % esta funcion es para modificar el modo de funcionamiento del filtro
            % se cuenta con los siguientes modos:
            % 1 = modo manual
            % 2 = modo secuencial con trigger interno
            % 3 = modo secuencial con trigger externo
            % 4 = modo secuencial con trigger interno
            % 5 = modo secuencial con trigger externo
            check = calllib(obj.libname,'kurios_Set_OutputMode',obj.deviceHandle,mode);
            if(check~=0)
                error('fallo al cambiar el modo de salida del filtro.')
            end      
            obj.outputMode = mode;
        end
        
        function setSequenceStepData(obj,n,wavelength,ts,bwmode)
            %sequenceStepData - modifica los datos de un elemento de la secuencia en particular.
            %
            % Syntax: filt.setSequenceStepData(n,wavelength,ts,bwmode)
            %
            % esta funcion permite cambiar tanto la longitud de onda, el intervalo de tiempo y el modo
            % de ancho de banda de un elemento n-esimo de la secuencia
            % n: numero entero entre 1 y 1024
            check = calllib(obj.libname,'kurios_Set_SequenceStepData',obj.deviceHandle,n,wavelength,ts,bwmode);
            if(check~=0)
                error('fallo al cambiar la configuracion del elemento en la secuencia.')
            end       
            obj.getSequence();   
        end

        function setTriggerMode(obj, mode)
            %triggerMode - Description
            %
            % Syntax: filt.setTriggerMode(mode)
            %
            % esta funcion sirve para modificar el modo de trigger del filtro,
            % se cuenta con los siguientes modos:
            % 0 = modo normal
            % 1 = modo invertido
            check = calllib(obj.libname,'kurios_Set_TriggerOutSignalMode',obj.deviceHandle, mode);
            if(check~=0)
                error('fallo al cambiar el modo de trigger.')
            end
            obj.triggerMode = mode;
        end

        function setWavelength(obj, wavelength)
            % wavelength - configurar el ancho de banda del filtro
            %
            % Syntax: wavelength(mode)
            %
            % esta funcion es para modificar la frecuencia central del filtro, este valor
            % debe pertenecer al intervalo [420,730] que es el rango del filtro
            if (wavelength < 420)|(wavelength > 730)
                error('la longitud de onda ingresada no es valida, intente con un numero entre 430 y 720')
            end
            check = calllib(obj.libname,'kurios_Set_Wavelength',obj.deviceHandle,wavelength);
            pause(1);
            if(check~=0)
                error('fallo al cambiar la longitud de onda')
            end
            obj.wavelength = wavelength;
        end

        function delete(obj)
            % esta funcion se ejectuta cuando el objeto se elimina
            % para eliminar un objeto se utiliza el comando delete(objeto)
            % en este aux cierra la conexion con el dispositivo y cierra la
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
