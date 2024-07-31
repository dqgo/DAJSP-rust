% schedule=[1工件号 2工序号  3机器号 4开工时间 5完工时间 6工厂号 7装配号 8属性(0加工/1装配) 9是否关键块]
% if 8==1  schedule=[-1 -1 -1 4开工时间 5完工时间 -1 7装配号 8属性(1装配) 9是否关键块]
% data={1[change_data] 2[job_num] 3[work_num] 4[factory_num] 5[assembly] 6[assembly_data]}
function schedule_right = right_schedule(schedule, Cmax, data)
    schedule_num = size(schedule, 1);
    schedule_right = [];
    schedule = sortrows(schedule, 4);
    % 先求得每一个工件的最后装配工序
    assembly_num = max(data{5});
    the_end_4_assembly_work = zeros(assembly_num, 2);

    for i = 1:assembly_num
        this_assembly_about_schedule = schedule(schedule(:, 7) == i, :);
        this_assembly_about_schedule = sortrows(this_assembly_about_schedule, 5);
        the_end_4_assembly_work(i, :) = this_assembly_about_schedule(end - 1, 1:2);
    end

    % the_end_4_assembly_work(i,:)是第i个装配号的最后一道加工工序

    for i = schedule_num:-1:1
        this_schedule = schedule(i, :);
        this_schedule_work_time = this_schedule(5) - this_schedule(4);

        if this_schedule(8) %如果是装配的话,仅需检查MS

            if isempty(schedule_right) %如果现在sr是空的，那么这道工序就是最后一道工序了
                schedule_right = this_schedule;
            else %非空的话最少有一道装配工序
                schedule_right_assembly = schedule_right(schedule_right(:, 8) == 1, :);
                this_schedule_can_end_time = schedule_right_assembly(1, 4);
                this_schedule_can_conmence_time = this_schedule_can_end_time - this_schedule_work_time;
                this_schedule_right = this_schedule;
                this_schedule_right(4:5) = [this_schedule_can_conmence_time, this_schedule_can_end_time];
                schedule_right = [this_schedule_right; schedule_right];
            end

        else %如果是 加工工序 1检查MS 2检查JS 3检查AS

            % 1 MS--------------------
            % 注意：机器应当是同工厂的机器！
            this_schedule_same_machine_schedule = schedule_right(schedule_right(:, 6) == this_schedule(6) & schedule_right(:, 3) == this_schedule(3), :);

            if isempty(this_schedule_same_machine_schedule)
                this_schedule_can_end_time_4_MS = Cmax;
            else
                this_schedule_can_end_time_4_MS = this_schedule_same_machine_schedule(1, 4);
            end

            % 2 JS-------------------
            this_schedule_JS_schedule = schedule_right(schedule_right(:, 1) == this_schedule(1) & schedule_right(:, 2) == this_schedule(2) + 1, :);

            if isempty(this_schedule_JS_schedule)
                this_schedule_can_end_time_4_JS = Cmax;
            else
                this_schedule_can_end_time_4_JS = this_schedule_JS_schedule(1, 4);
            end

            % 3 AS-------------------
            % 不管是不是装配前的最后一道工序，都智能作左移到装配开始之前
            this_schedule_assembly_schedule = schedule_right(schedule_right(:, 7) == this_schedule(7) & schedule_right(:, 8), :);
            this_schedule_can_end_time_4_AS = this_schedule_assembly_schedule(4);

            % this_schedule_is_end_4_assembly = isequal(this_schedule(1:2), the_end_4_assembly_work(this_schedule(7),1:2));
            % if this_schedule_is_end_4_assembly %如果是装配前的最后一道工序
            %     this_schedule_can_end_time_4_AS = schedule_right(schedule_right(:,7)==this_schedule(7) & schedule_right(:,8),4);
            % else
            %     this_schedule_can_end_time_4_AS=Cmax;
            % end

            % All---------------------
            this_schedule_can_end_time = min([this_schedule_can_end_time_4_MS, this_schedule_can_end_time_4_JS, this_schedule_can_end_time_4_AS]);
            this_schedule_can_conmence_time = this_schedule_can_end_time - this_schedule_work_time;
            this_schedule_right = this_schedule;
            this_schedule_right(4:5) = [this_schedule_can_conmence_time, this_schedule_can_end_time];

            schedule_right = [this_schedule_right; schedule_right];
        end

    end

end
