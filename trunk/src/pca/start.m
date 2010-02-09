% Reading and creating are needed only once if moneydir is kept fixed.

doread = 1;
docreate = 1;

moneydir = '../moneyDivided/wholeplusborder/neur05';

%% ------------- READ TRAINING DATA -------------------

if (doread)
	fprintf('reading training data...\n');
	preprocessnew(moneydir);
end


% In DNB_demo, all parameters for the experiment can be set.
DNB_demo(docreate)

% NOTE: since we are working with huge matrices, memory issues can occur.
% In case for Windows, this can be solved by having Windows manage 
% the virtual memory by itself.
% My Computer -> 
%	Properties -> Advanced -> 
%		Performance Settings -> Advanced
%			Virtual Memory -> Change
%				Set System Managed Size
%
% Also keep track of what variables can be cleared and loaded during
% execution.

