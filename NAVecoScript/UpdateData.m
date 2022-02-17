function [] = UpdateData(AddresseDepart, AddresseArrive, ResolDistance, OrdreFiltre)

% pcPythonExe = 'C:\Users\smorakandagamag\Documents\Python\Python3.7\python.exe';
% [ver, exec, loaded]	= pyversion(pcPythonExe); 

%pyversion;

% Add folders to python system path.
pyLibraryFolder = 'C:\Users\crybelloceferin\Documents\MATLAB\Supun\E3Yesid';
insert(py.sys.path, int64(0), pyLibraryFolder);

% if count(py.sys.path,'')==0
%     insert(py.sys.path,int32(0),'');
% end

command = horzcat('python data_retrievalElevation.py ',' ',AddresseDepart,' ',AddresseArrive,' ',num2str(ResolDistance),' ',num2str(OrdreFiltre))
% command = 'python data_retrievalElevation.py ';
[status, commandOut] = system(command);
if status==0
     fprintf('Command out is %d\n',str2num(commandOut));
else
    fprintf('Command error %d\n',str2num(commandOut));
end
commandOut
%script, departure_adress, arrival_adress, inside_place, raining, pointsByRequest, geocode, directions, speed, elevation, distance_sample = argv
%'EXPLEO Montigny', 'Bibliotheque universitaire Saint-Quientin-en-Yvelines'
%EXPLEO/Montigny Bibliotheque/universitaire/Saint-Quientin-en-Yvelines False 20 1

end

