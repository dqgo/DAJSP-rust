% schedule=[1工件号 2工序号  3机器号 4开工时间 5完工时间 6工厂号 7装配号 8属性(0加工/1装配)]
% if schedule(8)==1  schedule=[-1 -1 -1 4开工时间 5完工时间 -1 7装配号 8属性(1装配)]
function [keyblock_schedule, index] = find_keyblock(schedule)
    % 初始化 keyblock_schedule 和 index 元胞数组
    keyblock_schedule = {};
    index = {};

    % % 找出装配工序中的关键工序
    % assembly_schedule = schedule(schedule(:, 9) == 1 & schedule(:, 8) == 1, :);
    % assembly_indices = find(schedule(:, 9) == 1 & schedule(:, 8) == 1);
    %
    % % 初始化关键块
    % current_block = [];
    % current_indices = [];
    %
    % % 遍历装配工序
    % for i = 1:size(assembly_schedule, 1)
    %     if isempty(current_block)
    %         current_block = assembly_schedule(i, :);
    %         current_indices = assembly_indices(i);
    %     else
    %         % 判断是否连续
    %         if current_block(end, 5) == assembly_schedule(i, 4)
    %             current_block = [current_block; assembly_schedule(i, :)];
    %             current_indices = [current_indices; assembly_indices(i)];
    %         else
    %             if size(current_block, 1) > 1
    %                 keyblock_schedule{end+1} = current_block;
    %                 index{end+1} = current_indices;
    %             end
    %             current_block = assembly_schedule(i, :);
    %             current_indices = assembly_indices(i);
    %         end
    %     end
    % end
    %
    % % 最后一个关键块加入 keyblock_schedule
    % if ~isempty(current_block) && size(current_block, 1) > 1
    %     keyblock_schedule{end+1} = current_block;
    %     index{end+1} = current_indices;
    % end
    %
    % 找出加工工序中的关键工序
    machine_schedule = schedule(schedule(:, 9) == 1 & schedule(:, 8) == 0, :);
    machine_indices = find(schedule(:, 9) == 1 & schedule(:, 8) == 0);
    factories = unique(machine_schedule(:, 6));

    % 遍历所有工厂
    for f = 1:length(factories)
        current_factory = factories(f);
        factory_schedule = machine_schedule(machine_schedule(:, 6) == current_factory, :);
        factory_indices = machine_indices(machine_schedule(:, 6) == current_factory);
        machines = unique(factory_schedule(:, 3));

        % 遍历当前工厂的所有机器
        for m = 1:length(machines)
            current_machine = machines(m);
            machine_operations = factory_schedule(factory_schedule(:, 3) == current_machine, :);
            machine_op_indices = factory_indices(factory_schedule(:, 3) == current_machine);
            % 按开工时间排序
            [machine_operations, sort_order] = sortrows(machine_operations, 4);
            machine_op_indices = machine_op_indices(sort_order);
            current_block = [];
            current_indices = [];

            for i = 1:size(machine_operations, 1)

                if isempty(current_block)
                    current_block = machine_operations(i, :);
                    current_indices = machine_op_indices(i);
                else
                    % 判断是否连续
                    if current_block(end, 5) == machine_operations(i, 4)
                        current_block = [current_block; machine_operations(i, :)];
                        current_indices = [current_indices; machine_op_indices(i)];
                    else

                        if size(current_block, 1) > 1
                            keyblock_schedule{end + 1} = current_block;
                            index{end + 1} = current_indices;
                        end

                        current_block = machine_operations(i, :);
                        current_indices = machine_op_indices(i);
                    end

                end

            end

            % 最后一个关键块加入 keyblock_schedule
            if ~isempty(current_block) && size(current_block, 1) > 1
                keyblock_schedule{end + 1} = current_block;
                index{end + 1} = current_indices;
            end

        end

    end

end

% function keyblock_schedule = find_keyblock(keypath_schedule)
%     % 初始化 keyblock_schedule 元胞数组
%     keyblock_schedule = {};
%
%     % 找出装配工序
%     assembly_schedule = keypath_schedule(keypath_schedule(:,8) == 1, :);
%     % 初始化关键块
%     current_block = [];
%
%     % 遍历装配工序
%     for i = 1:size(assembly_schedule, 1)
%         if isempty(current_block)
%             current_block = assembly_schedule(i, :);
%         else
%             % 判断是否连续
%             if current_block(end, 5) == assembly_schedule(i, 4)
%                 current_block = [current_block; assembly_schedule(i, :)];
%             else
%                 if size(current_block, 1) > 1
%                     keyblock_schedule{end+1} = current_block;
%                 end
%                 current_block = assembly_schedule(i, :);
%             end
%         end
%     end
%
%     % 最后一个关键块加入 keyblock_schedule
%     if ~isempty(current_block) && size(current_block, 1) > 1
%         keyblock_schedule{end+1} = current_block;
%     end
%
%     % 找出加工工序
%     machine_schedule = keypath_schedule(keypath_schedule(:,8) == 0, :);
%     factories = unique(machine_schedule(:, 6));
%
%     % 遍历所有工厂
%     for f = 1:length(factories)
%         current_factory = factories(f);
%         factory_schedule = machine_schedule(machine_schedule(:, 6) == current_factory, :);
%         machines = unique(factory_schedule(:, 3));
%
%         % 遍历当前工厂的所有机器
%         for m = 1:length(machines)
%             current_machine = machines(m);
%             machine_operations = factory_schedule(factory_schedule(:, 3) == current_machine, :);
%             % 按开工时间排序
%             machine_operations = sortrows(machine_operations, 4);
%             current_block = [];
%
%             for i = 1:size(machine_operations, 1)
%                 if isempty(current_block)
%                     current_block = machine_operations(i, :);
%                 else
%                     % 判断是否连续
%                     if current_block(end, 5) == machine_operations(i, 4)
%                         current_block = [current_block; machine_operations(i, :)];
%                     else
%                         if size(current_block, 1) > 1
%                             keyblock_schedule{end+1} = current_block;
%                         end
%                         current_block = machine_operations(i, :);
%                     end
%                 end
%             end
%
%             % 最后一个关键块加入 keyblock_schedule
%             if ~isempty(current_block) && size(current_block, 1) > 1
%                 keyblock_schedule{end+1} = current_block;
%             end
%         end
%     end
% end
%
%

% function keyblock_schedule = find_keyblock(keypath_schedule)
%     % 初始化 keyblock_schedule 元胞数组
%     keyblock_schedule = {};
%
%     % 找出装配工序
%     assembly_schedule = keypath_schedule(keypath_schedule(:,8) == 1, :);
%     % 初始化关键块
%     current_block = [];
%
%     % 遍历装配工序
%     for i = 1:size(assembly_schedule, 1)
%         if isempty(current_block)
%             current_block = assembly_schedule(i, :);
%         else
%             % 判断是否连续
%             if current_block(end, 5) == assembly_schedule(i, 4)
%                 current_block = [current_block; assembly_schedule(i, :)];
%             else
%                 if size(current_block, 1) > 1
%                     keyblock_schedule{end+1} = current_block;
%                 end
%                 current_block = assembly_schedule(i, :);
%             end
%         end
%     end
%
%     % 最后一个关键块加入 keyblock_schedule
%     if ~isempty(current_block) && size(current_block, 1) > 1
%         keyblock_schedule{end+1} = current_block;
%     end
%
%     % 找出加工工序
%     machine_schedule = keypath_schedule(keypath_schedule(:,8) == 0, :);
%     machines = unique(machine_schedule(:, 3));
%
%     % 遍历所有机器
%     for m = 1:length(machines)
%         current_machine = machines(m);
%         machine_operations = machine_schedule(machine_schedule(:, 3) == current_machine, :);
%         % 按开工时间排序
%         machine_operations = sortrows(machine_operations, 4);
%         current_block = [];
%
%         for i = 1:size(machine_operations, 1)
%             if isempty(current_block)
%                 current_block = machine_operations(i, :);
%             else
%                 % 判断是否连续
%                 if current_block(end, 5) == machine_operations(i, 4)
%                     current_block = [current_block; machine_operations(i, :)];
%                 else
%                     if size(current_block, 1) > 1
%                         keyblock_schedule{end+1} = current_block;
%                     end
%                     current_block = machine_operations(i, :);
%                 end
%             end
%         end
%
%         % 最后一个关键块加入 keyblock_schedule
%         if ~isempty(current_block) && size(current_block, 1) > 1
%             keyblock_schedule{end+1} = current_block;
%         end
%     end
% end

% function keyblock_schedule = find_keyblock(keypath_schedule)
%     % 初始化 keyblock_schedule 元胞数组
%     keyblock_schedule = {};
%     % 找出装配工序
%     assembly_schedule = keypath_schedule(keypath_schedule(:,8) == 1, :);
%     % 初始化关键块
%     current_block = [];
%     % 遍历装配工序
%     for i = 1:size(assembly_schedule, 1)
%         if isempty(current_block)
%             current_block = assembly_schedule(i, :);
%         else
%             % 判断是否连续
%             if current_block(end, 5) == assembly_schedule(i, 4)
%                 current_block = [current_block; assembly_schedule(i, :)];
%             else
%                 keyblock_schedule{end+1} = current_block;
%                 current_block = assembly_schedule(i, :);
%             end
%         end
%     end
%     % 最后一个关键块加入 keyblock_schedule
%     if ~isempty(current_block)
%         keyblock_schedule{end+1} = current_block;
%     end
%     % 找出加工工序
%     machine_schedule = keypath_schedule(keypath_schedule(:,8) == 0, :);
%     machines = unique(machine_schedule(:, 3));
%     % 遍历所有机器
%     for m = 1:length(machines)
%         current_machine = machines(m);
%         machine_operations = machine_schedule(machine_schedule(:, 3) == current_machine, :);
%         % 按开工时间排序
%         machine_operations = sortrows(machine_operations, 4);
%         current_block = [];
%         for i = 1:size(machine_operations, 1)
%             if isempty(current_block)
%                 current_block = machine_operations(i, :);
%             else
%                 % 判断是否连续
%                 if current_block(end, 5) == machine_operations(i, 4)
%                     current_block = [current_block; machine_operations(i, :)];
%                 else
%                     keyblock_schedule{end+1} = current_block;
%                     current_block = machine_operations(i, :);
%                 end
%             end
%         end
%         % 最后一个关键块加入 keyblock_schedule
%         if ~isempty(current_block)
%             keyblock_schedule{end+1} = current_block;
%         end
%     end
% end

% function keyblock_schedule=find_keyblock(keypath_schedule)
%     keypath_schedule_num=size(keypath_schedule,1);
%     keyblock_schedule=cell(1,keypath_schedule_num);
%     j=1;
%     for i=1:keypath_schedule_num
%
%     end
% end

% 用MATLAB写一个函function keyblock_schedule=find_keyblock(keypath_schedule)，把装配车间问题(AJSP)的关键路径分割为关键块，
% 函数输入keypath_schedule，是二维数组，表述AJSP问题中的调度表，他的意义是：[1工件号 2工序号  3机器号 4开工时间 5完工时间 6工厂号 7装配号 8属性(0代表加工工序/1代表装配)]
% 函数要输出keyblock_schedule元胞数组，元胞数组每一个元素表示一个关键块。
% 关键块是在同一机器上连续（连续的定义是：在同一机器上，a的完工时间等于b的开工时间）的最大工序块
% 其中，装配机器只有1个，所以在schedule(8)==1的情况下是这样的：schedule=[-1 -1 -1 4开工时间 5完工时间 -1 7装配号 8属性(1装配)]
