% schedule=[1工件号 2工序号  3机器号 4开工时间 5完工时间 6工厂号 7装配号 8属性(0加工/1装配) 9是否关键块]
% if 8==1  schedule=[-1 -1 -1 4开工时间 5完工时间 -1 7装配号 8属性(1装配) 9是否关键块]
function indices = find_rows_in_schedule(a, b)
    % 初始化输出的行号数组
    indices = [];

    % 遍历矩阵a的每一行
    for i = 1:size(a, 1)
        % 获取当前行
        current_row = a(i, :);

        % 检查当前行是否存在于矩阵b中
        if ismember(current_row, b, 'rows')
            % 如果存在，则将其行号添加到indices中
            indices = [indices; i];
        end

    end

end

% function [schedule,schedule_right] = find_key_schedule(schedule,schedule_right)
%     % schedule=sortrows(schedule,4);
%     % schedule_right=sortrows(schedule_right,4);
%     schedule_num=size(schedule,1);
%     for i=1:schedule_num
%         if all(schedule(i,:)==schedule_right(i,:))
%             schedule(i,9)=1;schedule_right(i,9)=1;
%         end
%     end
% end
