function [] = SegmentData(seg_speed_ext, seg_slope_ext, seg_slope_sample, constant_slope_ext, duration_user)

% pcPythonExe = 'C:\Users\smorakandagamag\Documents\Python\Python3.7\python.exe';
% [ver, exec, loaded]	= pyversion(pcPythonExe); 

%pyversion;

% Add folders to python system path.
pyLibraryFolder = 'C:\Users\crybelloceferin\Documents\MATLAB\Supun\NAVecoScript';
insert(py.sys.path, int64(0), pyLibraryFolder);

% if count(py.sys.path,'')==0
%     insert(py.sys.path,int32(0),'');
% end

command = horzcat('python segmentation.py ',' ',seg_speed_ext,' ',seg_slope_ext,' ',seg_slope_sample,' ',constant_slope_ext,' ',duration_user)
% command = 'python data_retrievalElevation.py ';
[status, commandOut] = system(command);
if status==0
     fprintf('Command out is %d\n',str2num(commandOut));
else
    fprintf('Command error %d\n',str2num(commandOut));
end
commandOut

end

