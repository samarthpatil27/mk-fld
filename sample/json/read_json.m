% Read JSON using jsonlab 
% https://github.com/fangq/jsonlab

% Add jsonlab to PATH
addpath('../../third_party/jsonlab');

% Read from string
data = loadjson('{"obj":{"string":"value","array":[1,2,3]}}');
disp(data.obj.array(1)); % should be 1
disp(data.obj.string); % should be value

% Read from file 
dataAA5083 = loadjson('aa5083.json');
disp(dataAA5083);
disp(dataAA5083.name);
disp(dataAA5083.hardening);
% FIXME: it cannot parse numeric key value
disp(dataAA5083.r);
disp(dataAA5083.hardening(1));
s = 'voce';
disp(s);
disp(class(s));
disp(dataAA5083.(s));
% NOTE: this is a cell str not a str ...
s = dataAA5083.hardening(1);
disp(class(s));
disp(iscellstr(s));
disp(strcmp(s,'voce'));
disp(dataAA5083.voce);
% NOTE: Must convert to string ... http://cn.mathworks.com/help/matlab/ref/strjoin.html
s2 = strjoin(s);
disp(dataAA5083.(s2));
