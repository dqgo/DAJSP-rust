% 新的schedule=[1工件号 2工序号  3机器号 4开工时间 5完工时间 6工厂号 7装配号 8属性(0加工/1装配) 9是否关键块 10UVQ标识 0=U 1=Q 2=V -1=其他 ]
% 返回neighborhoodSign 0是v移动到u之前 1是u移动到v之后  -1是没有移动，即原始解
function fitness = approximate_fitness(nei_schedule, nei_sign, schedule, data, schedule_right, Cmax)
    nei_num = size(nei_sign, 1);
    fitness = [];

    if nei_num == 0
        fitness = 99999;
    else

        for i = 1:size(nei_sign,2)
            this_sign = nei_sign(i);
            this_nei_schedule=nei_schedule(:,:,i);
            u_schedule = this_nei_schedule(this_nei_schedule(:, 10) == 0, :); l_schedule = this_nei_schedule(this_nei_schedule(:, 10) == 1, :); v_schedule = this_nei_schedule(this_nei_schedule(:, 10) == 2, :);

            if this_sign
                %如果是u移动到v之后
                this_Q = [l_schedule; v_schedule; u_schedule];
            else %如果是v移动到u之前
                this_Q = [v_schedule; u_schedule; l_schedule];
            end

            this_nei_head_leagth = approximate_head_length(this_Q, this_nei_schedule, schedule, data, schedule_right, Cmax, u_schedule, l_schedule, v_schedule);
            this_nei_tail_leagth = approximate_tail_length(this_Q, this_nei_schedule, schedule, data, schedule_right, Cmax, u_schedule, l_schedule, v_schedule);
            this_nei_Cmax = max([this_nei_head_leagth + this_nei_tail_leagth]);
            fitness = [fitness; this_nei_Cmax];
        end

    end

end

function this_nei_head_leagth = approximate_head_length(this_Q, nei_schedule, schedule, data, schedule_right, Cmax, u_schedule, l_schedule, v_schedule)
    this_Q_size = size(this_Q, 1);
    %第一步 获取第一个的工序的头长，即自己的JP和U之前的MP
    the_first_schedule = this_Q(1, :);
    %先在原schedule中找到u的mp
    the_same_machine_schedule = schedule(schedule(:, 6) == u_schedule(6) & schedule(:, 3) == u_schedule(3), :);
    [urow, ~] = find(u_schedule(1) == the_same_machine_schedule(:, 1));

    if urow == 1
        the_first_schedule_head_leagth_1 = 0;
    else
        MP_u_schedule = the_same_machine_schedule(urow - 1, :);
        the_first_schedule_head_leagth_1 = MP_u_schedule(5);
    end

    %现在来寻找第一个工序的JP
    JP_first_work_schedule = schedule(schedule(:, 1) == the_first_schedule(1) & schedule(:, 2) == the_first_schedule(2) - 1, :);

    if isempty(JP_first_work_schedule)
        the_first_schedule_head_leagth_2 = 0;
    else
        the_first_schedule_head_leagth_2 = JP_first_work_schedule(5);
    end

    the_first_schedule_head_leagth = max([the_first_schedule_head_leagth_1, the_first_schedule_head_leagth_2]);
    this_nei_head_leagth = the_first_schedule_head_leagth;
    this_MP_head_leagth_add_work_time = the_first_schedule_head_leagth+the_first_schedule(5)-the_first_schedule(4);

    for i = 2:this_Q_size
        this_work_schedule = this_Q(i, :);
        %只需要找到JP即可
        JP_this_work_schedule = schedule(schedule(:, 1) == this_work_schedule(1) & schedule(:, 2) == this_work_schedule(2) - 1, :);
        if isempty(JP_this_work_schedule)
            JP_this_work_head_leagth=0;
        else
            JP_this_work_head_leagth=JP_this_work_schedule(5);
        end
        this_work_head_leageh = max([JP_this_work_head_leagth, this_MP_head_leagth_add_work_time]);
        this_nei_head_leagth = [this_nei_head_leagth; this_work_head_leageh];
        this_MP_head_leagth_add_work_time = this_work_head_leageh+this_work_schedule(5)-this_work_schedule(4);
    end

end

% 新的schedule=[1工件号 2工序号  3机器号 4开工时间 5完工时间 6工厂号 7装配号 8属性(0加工/1装配) 9是否关键块 10UVQ标识 0=U 1=Q 2=V -1=其他 ]
function this_nei_tail_leagth = approximate_tail_length(this_Q, nei_schedule, schedule, data, schedule_right, Cmax, u_schedule, l_schedule, v_schedule)
    % ！！！这里的尾长是从开始时间开始的
    tail_data = schedule_right; tail_data(:, 11) = Cmax - schedule_right(:, 4);
    % 尾长有三个约束：AS MS和JS
    % 首先还是看最后一个工序 分别JS、AS 和V的MS
    this_Q_size = size(this_Q, 1);
    the_same_machine_schedule = tail_data(tail_data(:, 6) == v_schedule(6) & tail_data(:, 3) == v_schedule(3), :);
    [vrow, ~] = find(v_schedule(1) == the_same_machine_schedule(:, 1));

    if vrow == size(the_same_machine_schedule, 1)
        the_last_schedule_tail_leagth_1 = 0;
    else
        MS_v_schedule = the_same_machine_schedule(vrow + 1, :);
        the_last_schedule_tail_leagth_1 = MS_v_schedule(11);
    end

    % 现在来找AS
    this_work_schedule = this_Q(end, :);
    only_assembly_tail_schedule = tail_data(tail_data(:, 8) == 1, :);
    the_last_schedule_tail_leagth_2 = only_assembly_tail_schedule(only_assembly_tail_schedule(:, 7) == this_work_schedule(7), 11);
    % 现在找JS
    JS_end_work_tail_schedule = tail_data(tail_data(:, 1) == this_work_schedule(1) & tail_data(:, 2) == this_work_schedule(2) + 1, :);

    if isempty(JS_end_work_tail_schedule)
        the_last_schedule_tail_leagth_3 = 0;
    else
        the_last_schedule_tail_leagth_3 = JS_end_work_tail_schedule(11);
    end

    the_last_schedule_tail_leagth = max([the_last_schedule_tail_leagth_1 the_last_schedule_tail_leagth_2 the_last_schedule_tail_leagth_3])+this_work_schedule(5)-this_work_schedule(4);
    this_nei_tail_leagth = the_last_schedule_tail_leagth;
    this_MS_tail_leageh = the_last_schedule_tail_leagth;

    for i = this_Q_size - 1:-1:1
        this_work_schedule = this_Q(i, :);
        this_work_tail_leagth_2 = only_assembly_tail_schedule(only_assembly_tail_schedule(:, 7) == this_work_schedule(7), 11);
        JS_this_work_tail_schedule = tail_data(tail_data(:, 1) == this_work_schedule(1) & tail_data(:, 2) == this_work_schedule(2) + 1, :);

        if isempty(JS_this_work_tail_schedule)
            this_work_tail_leagth_3 = 0;
        else
            this_work_tail_leagth_3 = JS_this_work_tail_schedule(11);
        end

        this_work_tail_leagth = max([this_MS_tail_leageh, this_work_tail_leagth_2, this_work_tail_leagth_3])+this_work_schedule(5)-this_work_schedule(4);
        this_nei_tail_leagth = [this_work_tail_leagth;this_nei_tail_leagth];
        this_MS_tail_leageh = this_work_tail_leagth;
    end

end
