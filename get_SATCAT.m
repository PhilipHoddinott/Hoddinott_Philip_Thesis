    %% get_SATCAT.m
% By Philip Hoddinott
% This code gets SATCAT from NORARD Query via post requests. 
% This code was based off of the following code: https://github.com/jgte/matlab-sgp4/blob/master/get_tle.m

load('UserPass.mat') % load in username and password
baseURL='https://www.space-track.org/';
logURL=[baseURL,'ajaxauth/login'];
querySatcatURL=[baseURL,'basicspacedata/query/class/satcat/OBJECT_TYPE', '/debris/RCS_SIZE/small/LAUNCH_YEAR/>'];
querySatcatURL=[querySatcatURL,num2str(launchYear),'/orderby/DECAY asc/format/csv/metadata/false'];

URL='https://www.space-track.org/ajaxauth/login'; % URL for login

post={'identity',username, 'password',password,'query',querySatcatURL}; % Create Post Request

out=urlread(logURL,'Post',post,'Timeout',timeOutVal); % gets the output
outStr=convertCharsToStrings(out); % coverts output to string


newStr = strsplit(outStr,["\n"]); % split string by line break
for i=1:length(newStr) % split string by commas
    all_TLE(i,:) = strsplit(newStr(i),','); 
end


[m,n] = size(all_TLE); % get size of matrix
%% Remove " marks
for i=1:m % remove the " marks
    for j=1:n
        all_TLE(i,j)=strip(all_TLE(i,j),'left','"');
        all_TLE(i,j)=strip(all_TLE(i,j),'right','"');
    end
end

%%  find where the last decayed item is and remove it 
decay_loc=8;

for i=1:length(all_TLE(1,:)) % find the columm decay is located in, it should be in 8
    if all_TLE(1,i)=="DECAY"
        decay_loc = i;  % save decay loc
    end
end


decayEnd=m+10;
for i=2:length(newStr) % find the columm decay is located in, it should be in 8
    if all_TLE(i,decay_loc)~=[""] && decayEnd==m+10
        decayEnd=i-1; % get the last location where there is no yet decay
    end
end
all_TLE=all_TLE(1:decayEnd,:); % trim to only have debris that has not yet decayed


all_TLES=sortrows(all_TLE(2:end,:),2); % sort rows by NORAD ID
all_TLE=[all_TLE(1,:);all_TLES]; % save the sorted row by NORAD ID

%% save to a file
strNam = ['mat_files/SATCAT_',num2str(launchYear),'.mat'];
save(strNam,'all_TLE','decayEnd');
