%%%%%%%%%%%%%%%%%%%%%%
%%%Tabulate captured data and separate $GPGSV from others
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%serialport_data2;
%M=serialport_data1;
filename = 'ORGorg.txt';
M=fileread(filename);
det='$';
serial1 = split(M,det);
str = "GPGSV";
filter_serial= serial1(contains(serial1,str));
A = filter_serial;
delimiter = ','; % دلیمیتر مورد نظر
max_num_delimiters = 19; % بیشترین تعداد دلیمیترها در المان‌های متنی
B = cell(numel(A), max_num_delimiters); % ماتریس خروجی
for i = 1:numel(A)
    row = A{i};
    split_row = strsplit(row, delimiter);
    num_delimiters = numel(split_row);
    for j = 1:num_delimiters
        % بررسی درستی عددی بودن هر رشته
        if isnumeric(str2double(split_row{j}))
            B{i,j} = split_row{j};
        end
    end
end


%%disp(B);
%%%%%%%%%%%%%%%%%%%%%
%%%Putting zero in the elements that are empty in the table
%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
for i =1 : size(B,1)
    for j = 1:size(B,2)
        if isempty (B{i,j}) == true
            B{i,j} = '0';
        end

    end
end
%%%%%%%%%%%%%%%%%%%%
%%%%Deleting rows whose satellite IDs are the same
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%
rtd=[];
for g=1:size(B,1)
    if B{g, columnToCheck} == '0'
        rtd=[rtd,g];
    end
end
B(rtd,:)=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%Copying the noise carrier in a separate array and copying the ID of all satellites in a separate array
%%%%%%%%%%%%%%%%%%%%
CNR = {};
k = 1;

for i = 1:size(B, 1)
    for j = 1:size(B, 2)
        if ischar(B{i, j}) && contains(B{i, j}, '*')
            CNR{k} = B{i, j};
            k = k + 1;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sat_id = {};
w = 1;
for p = 1:size(B, 1)
    sat_id{w} = B{p, columnToCheck};
    w = w + 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cnr={};
for i=1:size(CNR,2)
    cnr{i}=SNR(CNR{i});
end
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x= categorical(sat_id);
cnr1 = cellfun(@num2str, cnr, 'UniformOutput', false);
p=str2double(cnr1);
figure;
bar(x,p);
title("data_org1");
