%% Master Program
% By Philip Hoddinott
% This is the Master program to aquire TLEs and turn them into usable
% keplerian elements. 
%% Setup
close all; clear all; clc; % clear workspace
%% get data
VarStore % run var store for stored variables, ugly but it works

%% check for existing data
if exist('mat_files/')~=7 % if the folder does not exist it will make it
    mkdir('mat_files/')% tle_text_files % note this will give a warning if folder already exists
end
strNam = ['mat_files/TLE_',num2str(launchYear),'.mat']; % get strNam
strNam_SC = ['mat_files/SATCAT_',num2str(launchYear),'.mat']; % get strNam

try % check the satcat tog;
    load(strNam_SC);
    tog_SC=0;
        
    try % try for TLE file
        load(strNam, 'tle_final','dateCreated'); % load in file
        cTime =datetime;
        if cTime>(dateCreated+calweeks(1)) % file out of date, rerun not SATCAT
            fprintf('File is one week out of date, auto running program\n');
            tog_All=1;
            tog_SC=1;
        else % file recent, no need to run any
            fprintf('The file %s, was created within the last week\n',strNam);
            tog_All=0;
            tog_SC=0;
        end
    catch ME % if tle not found or no date run all
        switch ME.identifier
            case 'MATLAB:load:couldNotReadFile'
                warning('TLE File does not exist, auto running program');
            case 'MATLAB:UndefinedFunction'
                warning('dateCreated not found, auto running program');          
        end
        tog_All=1;
        tog_SC=0;
    end

catch ME
    switch ME.identifier
        case 'MATLAB:load:couldNotReadFile'
            warning('SATCAT File does not exist, auto running program');
            tog_SC=1;
            tog_All=1;
    end
end
% assign values
get_SATCAT_tog =tog_SC; % toggle for get_SATCAT 1 = run, 0 = don't run
get_Multiple_TLE_from_Id_tog =tog_All;
readTLE_txt_tog=tog_All;
check_TLE_Edit_TLE_tog=tog_All;
    
%% func get_SATCAT
% Function to get a .mat file from the SATCAT

if get_SATCAT_tog==1 % if the satcat file is out of date, run this
    get_SATCAT % get SATCAT, comment out if already run
    fprintf('get_SATCAT.m has finished running\n'); % output SATCAT has run
else % if the satcat file is recent then no nead to run get_SATCAT
    load(strNam_SC,'all_TLE','decayEnd'); % load mat of SATCAT
    fprintf('get_SATCAT.m was not run\n'); % output SATCAT was not run
end

relDeb=str2num(char(all_TLE(2:decayEnd,2))); % used in get_TLE_fromNorID.m

%% func get_Multiple_TLE_from_Id
% Function to get tle txt files from the norat_cat_ids in the SATCAT
VarStore % run var store for stored variables, ugly but it works

if get_Multiple_TLE_from_Id_tog==1
   get_TLE_from_ID_Manager
   fprintf('get_TLE_from_ID_Manager.m has finished running\n');
else
    fprintf('get_TLE_from_ID_Manager.m was not run\n');
end

VarStore % run var store for stored variables, ugly but it works
strNam = ['mat_files/TLE_',num2str(launchYear),'.mat']; % get strNam

load(strNam, 'tle_final')
tle_view=tle_final;
tle_view_temp=["norad_cat_id","Epoch time","Inclination (deg)","RAAN (deg)","Eccentricity (deg)","Arg of perigee(deg)","Mean anomaly (deg)","Mean motion (rev/day)","Period of rev (s/rev)","Semi-major axis (meter)","Semi-minor axis (meter)","Perigee (meter)","Apogee (meter)"];

tle_view_str = [tle_view_temp;tle_view]; % useful for looking at numbers
save('master_output','tle_view_str')
