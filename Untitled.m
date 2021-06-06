caso = '1';
modes = ["BLACK", "WIDE", "MEDIUM", "NARROW"];
if length(caso)==1
    caso=['000',caso];
elseif length(caso)==2
    caso = ['00',caso];
elseif length(caso)==3
    caso = ['0',caso];
end

count = 1;
for i=caso
    if strcmp(i,'1')
        disp(strcat('mode',modes(count),'available'))
        []
    end
    count = count + 1;
end