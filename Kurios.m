classdef Kurios
%--------------------------------------------------------------------------
% Syntax:       Kurios();
%
% Inputs:       none
%               
% Outputs:      filt es un objeto con los siguientes metodos publicos:
%               
%                 filt.bwMode();              % Cambiar la longitud de onda
%                 filt.showLib();                   % Mostrar las funciones de la libreria
%             T = filt.getTemperature(FENstr);      % Obtener la temperatura del filtro
%               
% Note:         Esta libreria fue programada para el filtro ajustable
%               Kuri        os VB1 by thorlabs, si se desea utilizar con otro
%               modelo se deben realizar las modificaciones respectivas
%               
%               La libreria permite la realizacion de Secuencias, las cuales consisten
%               en barridos de longitud de onda a cierto intervalo de tiempo y con
%               un ajuste de ancho de banda predeterminado
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
        % del filtro
        sequence
        bwMode
        % for sequence
        bw4sequence 
        ts4sequence 
        wavelength4Sequence
        id
        spectrum
        bwAvailable
        outputMode
        sequenceLength
        sequenceStepData
        specification
        status
        temperature
        triggerMode
        wavelength
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
            obj.isOperative = true;
            clear('pbuffer')
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
        end

        %% KURIOS GET
        function sequence = getSequence(obj)
            % getSequence - obtener la data de la secuencia completa
            %
            % Syntax: seqData = getSequence(input)
            %
            % Long description
            pbuffer = libpointer('uint8Ptr',uint8(zeros(1, 8)));
            check = calllib(obj.libname,'kurios_Get_AllSequenceData',obj.deviceHandle,pbuffer);
            if(check~=0)
                sequence = NaN;
                error('fallo al obtener la secuencia')
            end
            sequence = char(pbuffer.Value);
            clear('pbuffer')
        end

        function bwMode = getBwMode(obj)
            %getBwMode - Obtener el modo de ancho de banda
            %
            % Syntax: bwMode = getBwMode()
            %
            % Long description
            pbuffer = libpointer('int32Ptr',int32(NaN));
            check = calllib(obj.libname,'kurios_Get_BandwidthMode',obj.deviceHandle,pbuffer);
            if(check~=0)
                bwMode = NaN;
                error('fallo al obtener el ancho de banda')
            end
            bwMode = pbuffer.Value;
            clear('pbuffer')
        end

        function [bw, ts, wavelength] = getDefaultSequenceConfig(obj)
            %getDefaultSequenceConfig - obtener la configuracion predeterminada para realizar una secuencia
            %
            % Syntax: [bw, ts, wavelength] = getDefaultSequenceConfig(input)
            %
            % Long description
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
            clear('pbuffer1')
            clear('pbuffer2')
            clear('pbuffer3')
        end

        function id = getId(obj)
            %getId - Obtener la ID del dispositivo
            %
            % Syntax: id = filt.getId()
            %
            % La funcion permite obtener el numero de modelo, la version de hardware
            % y la version de firmware del dispositivo.
            pbuffer = libpointer('uint8Ptr',uint8(zeros(1, 53)));
            check = calllib(obj.libname,'kurios_Get_ID',obj.deviceHandle,pbuffer);
            if(check~=0)
                id = NaN;
                error('fallo al obtener la ID')
            end
            id = char(pbuffer.Value);
            clear('pbuffer')
        end

        function [spectrum, bwModeAvailable] = getOpticalHeadType(obj)
            %GetOpticalHeadType - Description
            %
            % Syntax: opticalHeadType = GetOpticalHeadType()
            %
            % Long description
            pbuffer1 = libpointer('uint8Ptr',uint8(zeros(1,8)));
            pbuffer2 = libpointer('uint8Ptr',uint8(zeros(1,8)));
            check = calllib(obj.libname, 'kurios_Get_OpticalHeadType', obj.deviceHandle, pbuffer1, pbuffer2);
            if(check~=0)
                opticalHeadType = NaN;
                error('fallo al obtener el tipo de cabezal optico')
            end
            spectrum = pbuffer1.Value;
            bwModeAvailable = pbuffer2.Value;
            clear('pbuffer')
        end

        function outputMode = getOutputMode(obj)
            %getOutputMode - obtener el modo de salida del filtro
            %
            % Syntax: outputMode = getOutputMode()
            %
            % Long description
            pbuffer = libpointer('int32Ptr',int32(NaN));
            check = calllib(obj.libname,'kurios_Get_OutputMode',obj.deviceHandle,pbuffer);
            if(check~=0)
                outputMode = NaN;
                error('fallo al obtener el modo de salida')
            end
            outputMode = pbuffer.Value;
            clear('pbuffer')
        end

        function sequenceLength = getSequenceLength(obj)
            %getSequenceLength - Description
            %
            % Syntax: sequenceLength = getSequenceLength(input)
            %
            % Long description
            pbuffer = libpointer('int32Ptr',int32(zeros(1,16)));
            check = calllib(obj.libname,'kurios_Get_SequenceLength',obj.deviceHandle,pbuffer);
            if(check~=0)
                sequenceLength = NaN;
                error('fallo al obtener el largo de la secuencia')
            end
            sequenceLength = pbuffer.Value;
            clear('pbuffer')
        end

        function [a b c] = getSequenceStepData(obj)
            %getSequenceStepData - Description
            %
            % Syntax: [a b c] = getSequenceStepData(input)
            %
            % Long description
            pbuffer1 = libpointer('int32Ptr',int32(zeros(1,64)));
            pbuffer2 = libpointer('int32Ptr',int32(zeros(1,64)));
            pbuffer3 = libpointer('int32Ptr',int32(zeros(1,64)));
            check = calllib(obj.libname, 'kurios_Get_SequenceStepData', int32(0), pbuffer1, pbuffer2, pbuffer3);
            if(check~=0)
                opticalHeadType = NaN;
                error('fallo al obtener el tiempo de muestreo del trigger')
            end
            a = pbuffer1.Value;
            b = pbuffer2.Value;
            c = pbuffer3.Value;
            clear('pbuffer')
        end

        function [lim_down, lim_up] = getSpecification(obj)
            %getSpecification - obtener el rango de longitud de onda
            %
            % Syntax: [lim_down, lim_up] = filt.getSpecification()
            %
            % Long description
            pbuffer1 = libpointer('int32Ptr',int32(NaN));
            pbuffer2 = libpointer('int32Ptr',int32(NaN));
            check = calllib(obj.libname, 'kurios_Get_Specification', obj.deviceHandle, pbuffer1, pbuffer2);
            if(check~=0)
                [lim_down, lim_down] = NaN;
                error('fallo al obtener el rango de longitud de onda del filtro')
            end
            lim_down = pbuffer1.Value;
            lim_up = pbuffer2.Value;
            clear('pbuffer')
        end

        function status = getStatus(obj)
            %getStatus - Description
            %
            % Syntax: status = filt.getStatus()
            %
            % Long description
            pbuffer = libpointer('int32Ptr',int32(NaN));
            check = calllib(obj.libname,'kurios_Get_Status',obj.deviceHandle,pbuffer);
            if(check~=0)
                status = NaN;
                error('fallo al obtener el estado del filtro')
            end
            status = pbuffer.Value;
            clear('pbuffer')
        end

        function T = getTemperature(obj)
            % getTemperature - Obtener la temperatura del filtro
            %
            % Syntax: T = filt.getTemperature()
            %
            % Long description
            pbuffer = libpointer('doublePtr',double(0));
            check = calllib(obj.libname,'kurios_Get_Temperature',obj.deviceHandle,pbuffer);
            if(check~=0)
                T = NaN;
                error('fallo al obtener la temperatura')
            end
            T = pbuffer.Value;
            clear('pbuffer')
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
            clear('pbuffer')
        end

        function wavelength = getWavelength(obj)
            %getWavelength - Description
            %
            % Syntax: wavelength = filt.getWavelength()
            %
            % Long description
            pbuffer = libpointer('int32Ptr',int32(NaN));
            check = calllib(obj.libname,'kurios_Get_Wavelength',obj.deviceHandle,pbuffer);
            if(check~=0)
                wavelength = NaN;
                error('fallo al obtener la longitud de onda del filtro')
            end
            wavelength = pbuffer.Value;
            clear('pbuffer')
        end

        %% KURIOS SET
        function setBwMode(obj, mode)
            % bwMode - configurar el ancho de banda del filtro
            %
            % Syntax: bwMode(mode)
            %
            % esta funcion es para modificar el ancho de banda del filtro,
            % se cuenta con los siguientes modos:
            % 1 = BLACK mode
            % 2 = WIDE mode
            % 4 = MEDIUM mode
            % 8 = NARROW mode
            check = calllib(obj.libname,'kurios_Set_BandwidthMode',obj.deviceHandle,mode);
            pause(1);
            if(check~=0)
                error('fallo al cambiar el ancho de banda')
            end
        end

        function setDefaultBw(obj,bwmode)
            %setDefaultBw - Establecer el modo de ancho de banda predeterminado para todos los elementos de la secuencia.
            %
            % Syntax: setDefaultBw(bwmode)
            %
            % Long description
            check = calllib(obj.libname,'kurios_Set_DefaultBandwidthForSequence',obj.deviceHandle,bwmode);
            if(check~=0)
                error('fallo al cambiar el ancho de banda por defecto en la secuencia')
            end
        end

        function setDefaultTs(obj,ts)
            %setDefaultTs - Establecer el intervalo de tiempo predeterminado para todos los elementos de la secuencia.
            %
            % Syntax: setDefaultTs(ts)
            %
            % Long description
            check = calllib(obj.libname,'kurios_Set_DefaultTimeIntervalForSequence',obj.deviceHandle,ts);
            if(check~=0)
                error('fallo al cambiar el intervalo de tiempo por defecto en la secuencia')
            end
        end

        function setDefaultWavelength(obj,wavelength)
            %setDefaultWavelength - Establecer la longitud de onda predeterminada para todos los elementos de la secuencia.
            %
            % Syntax: setDefaultWavelength(wavelength)
            %
            % Long description
            check = calllib(obj.libname,'kurios_Set_DefaultWavelengthForSequence',obj.deviceHandle,wavelength);
            if(check~=0)
                error('fallo al cambiar la longitud de onda por defecto en la secuencia')
            end
        end

        function deleteSequenceStep(obj,n)
        %deleteSequenceStep - elimina la n-esima entrada en la lista de secuencias.
        %
        % Syntax: deleteSequenceStep(n)
        %
        % esta funcion sirve para eliminar cualquier elemento que se haya agregado a la secuencia
        % para borrar la secuencia completa se utiliza n=0
        % n: numero entre 1 y 1024
        check = calllib(obj.libname,'kurios_Set_DeleteSequenceStep',obj.deviceHandle,n);
        if(check~=0)
            error('fallo al eliminar elemento en la secuencia')
        end
        end

        function insertSequenceStep(obj,n,wavelength,ts,bwmode)
            % insertSequenceStep - Insertar una orden a la lista de secuencias en la n-esima posicion.
            %
            % Syntax: insertSequenceStep()
            %
            % cada una de las ordenes que ingresemos en la secuencia se ejecutara
            % de forma secuencial cuando el modo de salida del filtro sea el MODO SECUENCIA (sequence mode)
            % n: numero entre 1 y 1024
            check = calllib(obj.libname,'kurios_Set_InsertSequenceStep',obj.deviceHandle,n,wavelength,ts,bwmode);
            if(check~=0)
                error('fallo al agregar elemento en la secuencia')
            end
        end

        function forceTrigger(obj)
            % forceTrigger - Forzar el disparo
            %
            % Syntax: forceTrigger()
            %
            % Long description

            check = calllib(obj.libname,'kurios_Set_ForceTrigger',obj.deviceHandle);
            if(check~=0)
                error('fallo al forzar el trigger')
            end
        end

        function setOutputMode(obj, mode)
            % esta funcion es para modificar el modo de funcionamiento del filtro
            % se cuenta con los siguientes modos:
            % 1 = Manual mode
            % 2 = Sequenced internal trigger mode
            % 3 = Sequenced external trigger mode
            % 4 = Analog signal internal trigger mode
            % 5 = Analog signal external trigger mode
            check = calllib(obj.libname,'kurios_Set_OutputMode',obj.deviceHandle,mode);
            if(check~=0)
                error('fallo al cambiar el modo de salida del filtro.')
            end      
        end
        
        function setSequenceStepData(obj,n,wavelength,ts,bwmode)
            %sequenceStepData - modifica los datos de un elemento de la secuencia en particular.
            %
            % Syntax: sequenceStepData()
            %
            % esta funcion permite cambiar tanto la longitud de onda, el intervalo de tiempo y el modo
            % de ancho de banda de un elemento n-esimo de la secuencia
            % n: numero entero entre 1 y 1024
            check = calllib(obj.libname,'kurios_Set_SequenceStepData',obj.deviceHandle,n,wavelength,ts,bwmode);
            if(check~=0)
                error('fallo al cambiar la configuracion del elemento en la secuencia.')
            end          
        end

        function setTriggerMode(obj, mode)
            %triggerMode - Description
            %
            % Syntax: triggerMode(mode)
            %
            % esta funcion sirve para modificar el modo de trigger del filtro,
            % se cuenta con los siguientes modos:
            % 0 = modo normal
            % 1 = modo invertido
            check = calllib(obj.libname,'kurios_Set_TriggerOutSignalMode',obj.deviceHandle, mode);
            if(check~=0)
                error('fallo al cambiar el modo de trigger.')
            end
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
        end


        %% funciones propias
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

        function obj = getAll(obj)
            %getAll - obtener todos los parametros del objeto
            %
            % Syntax: filt.getAll()
            %
            % a traves de este metodo se actualizan los atributos del objeto filt
            obj.sequence                =   obj.getSequence()
            obj.bwMode                  =   obj.getBwMode()
            [obj.bw4sequence obj.ts4sequence obj.wavelength4Sequence]   =   obj.getDefaultSequenceConfig()
            obj.id                      =   obj.getId()
            [obj.spectrum obj.bwAvailable]         =   obj.getOpticalHeadType()
            obj.outputMode              =   obj.getOutputMode()
            obj.sequenceLength          =   obj.getSequenceLength()
            %obj.sequenceStepData        =   obj.getSequenceStepData()
            obj.specification           =   obj.getSpecification()
            obj.status                  =   obj.getStatus()
            obj.temperature             =   obj.getTemperature()
            obj.triggerMode             =   obj.getTriggerMode()
            obj.wavelength              =   obj.getWavelength()
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
