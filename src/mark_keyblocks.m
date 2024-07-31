function updated_schedule = mark_keyblocks(schedule, keyblock_schedule)
    % 初始化第九列为0
    schedule(:, 9) = 0;

    % 遍历 keyblock_schedule 中的每个关键块
    for i = 1:length(keyblock_schedule)
        keyblock = keyblock_schedule{i};

        % 遍历关键块中的每个工序
        for j = 1:size(keyblock, 1)
            keyblock_operation = keyblock(j, :);

            % 找到 schedule 中对应的工序并将第九列置为1
            for k = 1:size(schedule, 1)

                if isequal(schedule(k, 1:8), keyblock_operation)
                    schedule(k, 9) = 1;
                    break;
                end

            end

        end

    end

    % 返回更新后的 schedule
    updated_schedule = schedule;
end
