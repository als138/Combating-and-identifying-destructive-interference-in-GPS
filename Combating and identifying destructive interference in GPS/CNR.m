function number = CNR(expression)
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