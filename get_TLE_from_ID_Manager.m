%% get_TLE_from_ID_Manager
% By Philip Hoddinott
% This code handles getMultiple_TLE_from_ID and deals with url read time outs. urlread is an older function, however it works best with post requets. 

load('UserPass.mat') % load in username and password

tle_final=[];
strNam = ['mat_files/TLE_',num2str(launchYear),'.mat']; % save the TLE as a .mat
save(strNam,'tle_final');
tleA = 1:tle_inc:decayEnd;
tleA=[tleA,decayEnd];

jStart =1; % starting value, will get reset if the connection times out
jEnd=length(tleA)-1; % end val
j_GMTFI=jStart;

while j_GMTFI~=jEnd % ensures that try catch keeps running untill it has gone all the way though
    fprintf('While loop, j = %d, jE = %d\n',j_GMTFI,jEnd);
    try
        for j_GMTFI = jStart:jEnd % try normal loop
            fprintf('Try for, j = %d, jE = %d\n',j_GMTFI,jEnd);
            load(strNam,'tle_final');
            tle_current=tle_final;
            get_TLE_from_NorID % get TLE from current set of NORAD IDs
            tle_final=[tle_current;tle_final];
            save(strNam,'tle_final'); % save the tle every loop through
        end
    catch ME      % time out catch
    fprintf('catch ME, j = %d, jE = %d\n',j_GMTFI,jEnd);
       switch ME.identifier
            case 'MATLAB:urlread:Timeout'
               warning('connection timed out at j = %d, trying again',j_GMTFI);
               jStart=j_GMTFI;
       end
    end
end
load(strNam,'tle_final');
[C,ia,ic]=unique(tle_final(:,1),'rows'); % sort by row by norard cat id
tle_final = tle_final(ia,:);
tle_final=sortrows(tle_final);
dateCreated=datetime; % save date created
save(strNam,'tle_final','dateCreated');