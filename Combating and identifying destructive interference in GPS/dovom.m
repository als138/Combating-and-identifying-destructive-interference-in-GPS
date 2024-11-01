
columnToCheck = 5;
rowsToDelete = [];  % لیستی برای ذخیره اندیس‌های رد شده

for u = 1:size(B, 1)
    for f = u+1:size(B, 1)
        if B{u, columnToCheck} == B{f, columnToCheck}
            rowsToDelete = [rowsToDelete, f];
        end
    end    
end

B(rowsToDelete, :) = [];  % حذف رد شده‌ها از ماتریس B
%%%%%%%%%%%%%%%%%%%%%%%%%%%

function number = SNR(expression)
          pattern = '(\d+)';  % Regular expression to match digits (\d+).

% Using the 'regexp' function to find all matches of the pattern in the expression.
matches = regexp(expression, pattern, 'match');

% Display the detected number.
if ~isempty(matches)
    number = str2double(matches{1});
    disp(number);
else
    disp('Number not found.');
end
end