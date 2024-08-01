% data={1[change_data] 2[job_num] 3[work_num] 4[factory_num] 5[assembly] 6[assembly_data]}
% schedule=[1工件号 2工序号  3机器号 4开工时间 5完工时间 6工厂号 7装配号 8属性(0加工/1装配)]
% if 8==1  schedule=[-1 -1 -1 4开工时间 5完工时间 -1 7装配号 8属性(1装配)]
% chromos={[FS] [Js] [AS]}
function schedule = createSchedule_in_greed(data, chromo)
    change_data = data{1, 1}; [job_num] = data{1, 2}; [work_num] = data{1, 3}; factory_num = data{1, 4}; assembly = data{1, 5}; assembly_data = data{1, 6};
    assembly_num = max(assembly);
    FS = chromo{1, 1};
    PS = chromo{1, 2};
    AS = chromo{1, 3};
    FSi = cell(1, factory_num);
    PSi = cell(1, factory_num);
    datai = cell(1, factory_num);
    % 首先分割为数个JSP问题
    for i = 1:job_num
        FSi{1, FS(i)} = [FSi{1, FS(i)} i];

    end

    % ------------------------------------------重写！
    for i = 1:factory_num
        PSi{1, i} = PS(ismember(PS, FSi{1, i}));
    end

    % -------------------------------------------分割PS

    for i = 1:factory_num
        datai{1, i} = change_data(PSi{1, i}, :);
    end

    % 现在PSi(i) & subdata(i)共同表示一个JSP问题，但是，工件号是不连续的，现在要把他变成连续的
    for i = 1:factory_num
        % 开始安排工厂i:FSi{1,i},PSi{1,i},datai{1,i}
        this_factory_job_sequence = FSi{1, i}; this_factory_work_sequence = PSi{1, i}; this_factory_data = datai{1, i};
        % this_factory_work_num = size(this_factory_work_sequence, 2);
        % this_factory_work_sequence_change=[this_factory_work_sequence;1:this_factory_work_num];
        % ---------------------------------------------------------------------------------------
        % 建立映射表

        % -----------------------------------------------------------------------------------
        [this_factory_work_sequence_unique, ~, index] = unique(this_factory_work_sequence);
        this_factory_job_num = size(this_factory_job_sequence, 2);
        this_factory_work_num = size(this_factory_work_sequence, 2) / this_factory_job_num;
        schedule_sub_factory{i} = zeros(size(this_factory_work_sequence, 2), 8);
        schedule_sub_factory{i}(:, 1:5) = createScheduleSubFactory(this_factory_data, index', this_factory_job_num, this_factory_work_num);
        schedule_sub_factory{i}(:, 1) = this_factory_work_sequence_unique(schedule_sub_factory{i}(:, 1)');

        %
        % [this_factory_work_sequence_unique,~,index]=unique(this_factory_work_sequence);
        % this_factory_work_sequence_change=[this_factory_work_sequence;index'];
        % this_factory_job_num=size(this_factory_job_sequence,2);
        % this_factory_work_num=size(this_factory_work_sequence,2)/this_factory_job_num;
        % schedule_sub_factory{i}=zeros(size(this_factory_work_sequence,2),8);
        % schedule_sub_factory{i}(:,1:5) = createScheduleSubFactory(this_factory_data,this_factory_work_sequence_change(2,:),this_factory_job_num,this_factory_work_num);
        %
        % shuffled_index = schedule_sub_factory{i}(:,1);
        % [~, restore_positions] = sort(index); % 获取原始索引位置
        % restored_index = shuffled_index(restore_positions);
        % restored_work_sequence = this_factory_work_sequence_unique(restored_index);
        % schedule_sub_factory{i}(:,1) = restored_work_sequence;

        schedule_sub_factory{i}(:, 6) = i; schedule_sub_factory{i}(:, 8) = 0; %工厂号 属性号
        % schedule_sub_factory(:,:,i) = createScheduleSubFactory(this_factory_data,this_factory_work_sequence_change(2,:),this_factory_job_num,this_factory_work_num);
        for j = 1:size(schedule_sub_factory{i}, 1)
            % ----NO要组装的话首要要确定好装配关系，这里假设的装配关系表来自data，是1 1 2 ...分别表工件i的装配关系号
            schedule_sub_factory{i}(j, 7) = assembly(schedule_sub_factory{i}(j, 1));
        end

    end

    % 现在安排好了每个工厂的schedule，开始进入组装
    schedule_withno_assembly = [];

    for i = 1:factory_num
        schedule_withno_assembly = cat(1, schedule_withno_assembly, schedule_sub_factory{i});
    end

    % 现在schedule_no_assembly表示了全部的，还包含了装配关系
    % schedule_withno_assembly(:,8)=1;
    sortrows(schedule_withno_assembly, [7, 5]);
    schedule_only_assembly = zeros(max(assembly), 8);
    schedule_only_assembly(:, 1:6) = -1;
    schedule_only_assembly(:, 7) = 1:assembly_num; % 按照装配号顺序来
    schedule_only_assembly(:, 8) = 1;
    % -------------------------------------------------------
    assembly_can_commence_time = zeros(assembly_num, 1);
    assembly_may_end_time = zeros(assembly_num, 1);

    for i = 1:assembly_num
        % 首先找到每个装配的开工时间和完工时间
        same_assembly_sub_schedule = schedule_withno_assembly(schedule_withno_assembly(:, 7) == i, :);
        assembly_can_commence_time(i) = max(same_assembly_sub_schedule(:, 5));
        assembly_may_end_time = assembly_can_commence_time + assembly_data;
    end

    % 进行装配车间的调度
    % --------------------------------------------------------
    schedule_only_assembly = assemblySchedule(schedule_only_assembly, assembly_can_commence_time, assembly_data);
    schedule = [schedule_withno_assembly; schedule_only_assembly];
end

% 问题类比为：对于一系列任务，知道它们的最早开工时间和加工时间，需要把这些任务全部完成，怎么做可以使得所有任务完成的时间最小。
% 按照贪心算法来看，按照完工时间从小到达排序，排序完成之后按顺序安排，如果有冲突的
% 该选择哪一个？对于没被选择到的，该怎么办？
% 现在来看 对于冲突时间最小的任务，将他后移
% AS的解码是半主动的！！！！！！！！！！！

function schedule_only_assembly = assemblySchedule(schedule_only_assembly, assembly_can_commence_time, assembly_data)
    n = length(assembly_can_commence_time);
    % 初始化当前时间
    current_time = 0;
    schedule = zeros(n, 3); % 第一列: 工件号, 第二列: 开工时间, 第三列: 完工时间
    % 初始化未完成任务的集合
    remaining_tasks = [(1:n)', assembly_can_commence_time, assembly_data'];
    % 按最早开工时间排序
    remaining_tasks = sortrows(remaining_tasks, 2);

    while ~isempty(remaining_tasks)
        % 可用任务
        available_tasks = remaining_tasks(remaining_tasks(:, 2) <= current_time, :);

        if isempty(available_tasks)
            % 当前时间内没有可开始的任务
            current_time = remaining_tasks(1, 2);
            available_tasks = remaining_tasks(remaining_tasks(:, 2) <= current_time, :);
        end

        % 选择加工时间最短的任务
        [~, min_idx] = min(available_tasks(:, 3));
        task = available_tasks(min_idx, :);
        % 任务号
        task_id = task(1);
        % 开工时间
        start_time = current_time;
        % 完工时间
        finish_time = current_time + task(3);
        % 记录任务完成时间
        schedule(task_id, :) = [task_id, start_time, finish_time];
        % 更新当前时间
        current_time = finish_time;
        % 从未完成任务中移除已完成任务
        remaining_tasks(remaining_tasks(:, 1) == task_id, :) = [];
    end

    schedule = sortrows(schedule, 1);
    schedule_only_assembly(:, 4:5) = schedule(:, 2:3);
end

% function schedule_only_assembly=assemblySchedule(schedule_only_assembly,assembly_can_commence_time,assembly_data,AS)
%     % 但是这里仅需要根据chromos={[FS] [Js] [AS]}中的AS数据
%     machine_idle_time_now=0;
%     for i=1:size(AS,2)
%         this_assembly_Number=AS(i);
%         this_assembly_JSP_can_commence_time=assembly_can_commence_time(this_assembly_Number);
%         this_assembly_commence_time=max(machine_idle_time_now,this_assembly_JSP_can_commence_time);
%         this_assembly_end_time=this_assembly_commence_time+assembly_data(this_assembly_Number);
%         machine_idle_time_now=this_assembly_end_time;
%         % schedule=[-1 -1 -1 4开工时间 5完工时间 -1 7装配号 8属性(1装配)]
%         schedule_only_assembly(this_assembly_Number,4:5)=[this_assembly_commence_time,this_assembly_end_time];
%     end
% end

% function schedule=createSchedule(data,chromo)
%     change_data=data{1,1}; [job_num]=data{1,2}; [work_num]=data{1,3};factory_num=data{1,4}; assembly_num=data{1,5};
%     FS=chromo{1,1};
%     PS=chromo{2,1};
%     factory=cell(factory_num,1);
%     PSi=cell{factory_num,1};
%     sub_change_data=cell{factory_num,1};
%     change_data=data{1,1};
%     % 首先分割为数个JSP问题
%     for i=1:job_num
%         factory{FS(i),1}=[factory{FS(i),1} i];
%         % factory indicate job2factory relation ,may==0,need consider
%         % now need construct job_No with job_No_really map
%         % above is FS diagram, now consider PS
%     end
%     for i=1:factory_num
%         for j=1:size(PS,2)
%             PSi{i,1}=PS{any(PS{j,1}==FS(i,1)),1};
%         end
%     end
%     for i=1:factory_num
%         sub_change_data{i,1}=change_data(PSi{i,1},:);
%     end
%     % now,PS(:,i)
% end
