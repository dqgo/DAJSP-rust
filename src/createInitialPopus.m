% chromos={[FS] [PS] [AS]}
% data=data={1[change_data] 2[job_num] 3[work_num] 4[factory_num] 5[assembly] 6[assembly_data]}
function [chromos] = createInitialPopus(popu, data)
    chromos = cell(popu, 3);
    factory_num = data{1, 4}; [job_num] = data{1, 2}; [work_num] = data{1, 3}; assembly_num = max(data{1, 5});

    for i = 1:popu
        chromos{i, 1} = randi(factory_num, 1, job_num);

        for j = 1:job_num
            chromos{i, 2} = createInitialPopu(work_num, job_num);
        end

        chromos{i, 3} = randperm(assembly_num, assembly_num);
    end

end

% 生成第一个染色体，随机
function initialPopu = createInitialPopu(machNum, workpieceNum)
    lengthChromo = machNum * workpieceNum;
    % 使用 repelem 生成重复的工件编号
    initialPopu = repelem(1:workpieceNum, machNum);
    % 随机排列生成染色体
    initialPopu = initialPopu(randperm(lengthChromo));
end


