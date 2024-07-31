% 规划data=data={1[change_data] 2[job_num] 3[work_num] 4[factory_num] 5[assembly] 6[assembly_data]}

% 1----------------------
% .
% . old.changeData_4_JSP
% .
% job_num----------------
% then assembly_sequence:1 1 4 2 1-----------
% assembly_time

function data = changeDataFunction()
    machine = [8 12 9 4 13 2 14 1 15 7 10 5 3 11 6 ;
13 2 12 10 7 4 3 5 6 9 14 15 11 1 8 ;
2 3 10 1 4 6 9 5 15 11 13 14 8 7 12 ;
14 11 7 3 15 8 5 12 1 6 10 4 9 2 13 ;
2 9 5 15 7 6 4 3 10 11 14 8 12 1 13 ;
6 15 3 13 11 2 12 5 7 10 1 14 9 4 8 ;
6 3 1 2 9 15 12 11 8 10 7 13 5 14 4 ;
5 8 11 2 10 9 3 15 12 4 6 7 14 13 1 ;
15 12 1 10 11 6 4 13 9 14 7 2 8 3 5 ;
10 1 4 11 13 14 6 2 7 15 9 12 3 8 5 ;
8 3 2 13 4 15 5 7 6 10 9 14 11 1 12 ;
1 9 15 13 10 6 7 11 8 12 4 5 2 14 3 ;
9 13 11 12 15 4 7 2 5 6 1 10 14 3 8 ;
14 3 12 1 15 11 4 2 13 5 6 7 8 10 9 ;
2 14 1 12 3 11 5 9 4 6 8 7 10 13 15  ];

    time = [69 81 81 62 80 3 38 62 54 66 88 82 3 12 88 ;
83 51 47 15 89 76 52 18 22 85 26 30 5 89 22 ;
62 47 93 54 38 78 71 96 19 33 44 71 90 9 21 ;
33 82 80 30 96 31 11 26 41 55 12 10 92 3 75 ;
36 49 10 43 69 72 19 65 37 57 32 11 73 89 12 ;
83 32 6 13 87 94 36 76 46 30 56 62 32 52 72 ;
29 78 21 27 17 43 14 15 16 49 72 19 99 38 64 ;
12 74 4 3 15 62 50 38 49 25 18 55 5 71 27 ;
69 13 33 47 86 31 97 48 25 40 94 22 61 59 16; 
27 4 35 80 49 46 84 46 96 72 18 23 96 74 23 ;
36 17 81 67 47 5 51 23 82 35 96 7 54 92 38 ;
78 58 62 43 1 56 76 49 80 26 79 9 24 24 42 ;
38 86 38 38 83 36 11 17 99 14 57 64 58 96 17; 
10 86 93 63 61 62 75 90 40 77 8 27 96 69 64 ;
73 12 14 71 3 47 84 84 53 58 95 87 90 68 75];
    change_data = combineMatrices(machine, time);
    assembly = [1 2 2 1 1 1 2 2 2 1 1 2 2 1 1 ];
    assembly_data = [968 166 ];
    job_num = size(change_data, 1);
    work_num = size(change_data, 2) / 2;
    factory_num = 2;
    data = {change_data job_num work_num factory_num assembly assembly_data};
end

function c = combineMatrices(a, b)
    % Get the number of rows and columns of a and b
    [rowsA, colsA] = size(a);
    [rowsB, colsB] = size(b);

    % Ensure a and b have the same number of rows
    if rowsA ~= rowsB
        error('Matrices a and b must have the same number of rows');
    end

    % Initialize the output matrix c
    c = zeros(rowsA, colsA + colsB);

    % Fill c with columns from a and b
    c(:, 1:2:end) = a; % Odd columns from a
    c(:, 2:2:end) = b; % Even columns from b
end
