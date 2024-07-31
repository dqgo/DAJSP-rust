% 构造邻域
% schedule=[1工件号 2工序号  3机器号 4开工时间 5完工时间 6工厂号 7装配号 8属性(0加工/1装配) 9是否关键块 ]
% 新的schedule=[1工件号 2工序号  3机器号 4开工时间 5完工时间 6工厂号 7装配号 8属性(0加工/1装配) 9是否关键块 10UVQ标识 0=U 1=Q 2=V -1=其他 ]
% 返回neighborhoodSign 0是v移动到u之前 1是u移动到v之后  -1是没有移动，即原始解

% if 8==1  schedule=[-1 -1 -1 4开工时间 5完工时间 -1 7装配号 8属性(1装配) 9是否关键块]
% data={1[change_data] 2[job_num] 3[work_num] 4[factory_num] 5[assembly] 6[assembly_data]}
% 对FA作业重新分配到其他工厂，对PS进行N5，对AS进行N1
% 对FA进行操作时，直接操作chromo，不用管schedule
% 对PS进行操作时，对基于机器的编码进行N5邻域结构之后，整理，输出nei_chromo
% 对AS进行操作时，不用管FA PS 只对schedule中only_assembly_schedule进行操作，并且单独拉出来，不参与后续的解码，节省点时间
function [nei_chromos, nei_schedule, nei_sign, PS_conmence_num] = create_nei(schedule, key_index, keyblock_schedule, chromo, data, schedule_right, Cmax)
    nei_chromos = [];
    nei_schedule = [];
    schedule(:, 10) = -1;
    keyblock_num = size(keyblock_schedule, 2);

    % FA----------------------------
    % 首先要知道关键上的工件号和工厂号
    factory_num = data{4};
    job_index = []; factory_index = [];
    % job_index=keyblock_schedule(:,1);
    for i = 1:keyblock_num
        this_block = keyblock_schedule{i};

        for j = 1:size(this_block, 1)
            this_scheudle = this_block(j, :);

            if this_scheudle(1) ~= -1
                % job_index=[job_index,this_scheudle(1)];
                % factory_index=[factory_index,this_scheudle(6)];
                this_job = this_scheudle(1); this_factory = this_scheudle(6);
                rand_factory = randperm(factory_num, 1);

                while (rand_factory == this_factory)
                    rand_factory = randperm(factory_num, 1);
                end

                this_nei_chromo = chromo;
                this_nei_chromo{1}(job_index) = rand_factory;
                nei_chromos = [nei_chromos; this_nei_chromo];
            end

        end

    end

    FA_nei_num = size(nei_chromos, 1); PS_conmence_num = FA_nei_num + 1;
    % 也就是说 FA_nei_num+1就是PS开始的染色体

    % PS---------------------------
    % 首先把schedule中的关键块拉出来，并且记录行号，然后执行交换移动 如果大小是2直接交换
    % 加入N7 加入UV Q的标识
    tail_data = [schedule_right(1:5), Cmax - schedule_right(5)];
    only_assembly_schedule = schedule(schedule(:, 8) == 1, :);
    % 返回neighborhoodSign 0是v移动到u之前 1是u移动到v之后
    nei_sign = [];

    for i = 1:keyblock_num
        this_nei_chromo = chromo;
        this_nei_schedule = schedule;
        this_nei_schedule_withno_assembly = schedule(schedule(:, 8) == 0, :);
        this_keyblock = keyblock_schedule{i}; this_keyblock(:, 10) = -1;
        this_keyblock_index = key_index{i};

        if this_keyblock_index(1) < size(chromo{2}, 2)

            if size(this_keyblock, 1) == 2
                u_schedule = this_keyblock(1, :); v_schedule = this_keyblock(2, :);
                isOk = can_V2Uper(u_schedule, v_schedule, schedule);

                if isOk
                    this_nei_schedule_withno_assembly(this_keyblock_index, :) = V2Uper(u_schedule, v_schedule);
                    this_nei_chromo{2} = this_nei_schedule_withno_assembly(:, 1)';
                    nei_chromos = [nei_chromos; this_nei_chromo];
                    nei_sign = [nei_sign, 1];
                    this_nei_schedule = [this_nei_schedule_withno_assembly; only_assembly_schedule];
                    nei_schedule = cat(3, nei_schedule, this_nei_schedule);
                end

            else

                % ----------------------------从这里开始都是关键块大于等于3的----------------------------
                this_block_size = size(this_keyblock, 1);

                for point = 2:this_block_size - 1

                    % -----------------1 u是头 v是point 头移内 u2vnext 前移-----------------
                    this_keyblock(:, 10) = -1; this_keyblock(1, 10) = 0; this_keyblock(2:point - 1, 10) = 1; this_keyblock(point, 10) = 2;
                    u_schedule = this_keyblock(1, :); v_schedule = this_keyblock(point, :);

                    if can_U2Vnext(u_schedule, v_schedule, tail_data)
                        this_move_forward_index = [2:point, 1, point + 1:this_block_size];
                        this_nei_schedule = schedule;
                        this_move_block_before_arrange = this_keyblock(this_move_forward_index, :);
                        this_move_block = [];
                        this_move_block(point + 1:this_block_size, :) = this_move_block_before_arrange(point + 1:end, :);

                        for st = point:-1:1
                            stTime = this_move_block(st + 1, 4);
                            this_move_block(st, :) = this_move_block_before_arrange(st, :);
                            this_move_block(st, 4:5) = [stTime - (this_move_block_before_arrange(st, 5) - this_move_block_before_arrange(st, 4)), stTime];
                        end

                        this_nei_schedule(this_keyblock_index, :) = this_move_block;
                        this_nei_chromo = chromo; this_nei_chromo{2} = this_nei_schedule(this_nei_schedule(:, 8) == 0, 1)';
                        nei_sign = [nei_sign, 1];
                        nei_chromos = [nei_chromos; this_nei_chromo];
                        nei_schedule = cat(3, nei_schedule, this_nei_schedule);
                    end

                    % -----------------2 u是point v是尾 内移尾 u2vnext 前移-----------------
                    this_keyblock(:, 10) = -1; this_keyblock(point, 10) = 0; this_keyblock(point + 1:end - 1, 10) = 1; this_keyblock(end, 10) = 2;
                    u_schedule = this_keyblock(point, :); v_schedule = this_keyblock(end, :);

                    if can_U2Vnext(u_schedule, v_schedule, tail_data)
                        this_move_forward_index = [1:point - 1, point + 1:this_block_size, point];
                        this_nei_schedule = schedule;
                        this_move_block_before_arrange = this_keyblock(this_move_forward_index, :);
                        this_move_block = [];
                        this_move_block = this_move_block_before_arrange(1:point - 1, :);

                        for re = point:this_block_size
                            reTime = this_move_block(end, 5);
                            this_move_block(re, :) = this_move_block_before_arrange(re, :);
                            this_move_block(re, 4:5) = [reTime, reTime + (this_move_block_before_arrange(re, 5) - this_move_block_before_arrange(re, 4))];
                        end

                        this_nei_schedule(this_keyblock_index, :) = this_move_block;
                        this_nei_chromo = chromo; this_nei_chromo{2} = this_nei_schedule(this_nei_schedule(:, 8) == 0, 1)';
                        nei_sign = [nei_sign, 1];
                        nei_chromos = [nei_chromos; this_nei_chromo];
                        nei_schedule = cat(3, nei_schedule, this_nei_schedule);
                    end

                    % -----------------3 u是头 v是point 内移首 v2uper 后移-----------------
                    this_keyblock(:, 10) = -1; this_keyblock(1, 10) = 0; this_keyblock(2:point - 1, 10) = 1; this_keyblock(point, 10) = 2;
                    u_schedule = this_keyblock(1, :); v_schedule = this_keyblock(point, :);

                    if can_V2Uper(u_schedule, v_schedule, schedule)
                        this_move_back_index = [point, 1:point - 1, point + 1:this_block_size];
                        this_nei_schedule = schedule;
                        this_move_block_before_arrange = this_keyblock(this_move_back_index, :);
                        this_move_block = [];
                        this_move_block(point + 1:this_block_size, :) = this_move_block_before_arrange(point + 1:end, :);

                        for st = point:-1:1
                            stTime = this_move_block(st + 1, 4); %安排完块的开始时间
                            this_move_block(st, :) = this_move_block_before_arrange(st, :);
                            this_move_block(st, 4:5) = [stTime - (this_move_block_before_arrange(st, 5) - this_move_block_before_arrange(st, 4)), stTime];
                        end

                        this_nei_schedule(this_keyblock_index, :) = this_move_block;
                        this_nei_chromo = chromo; this_nei_chromo{2} = this_nei_schedule(this_nei_schedule(:, 8) == 0, 1)';
                        nei_sign = [nei_sign, 0];
                        nei_chromos = [nei_chromos; this_nei_chromo];
                        nei_schedule = cat(3, nei_schedule, this_nei_schedule);
                    end

                    % -----------------4 u是point v是尾  v2uper 后移-----------------
                    this_keyblock(:, 10) = -1; this_keyblock(point, 10) = 0; this_keyblock(point + 1:end - 1, 10) = 1; this_keyblock(end, 10) = 2;
                    u_schedule = this_keyblock(point, :); v_schedule = this_keyblock(end, :);

                    if can_V2Uper(u_schedule, v_schedule, schedule)
                        this_move_back_index = [1:point - 1, this_block_size, point:this_block_size - 1];
                        this_nei_schedule = schedule;
                        this_move_block_before_arrange = this_keyblock(this_move_back_index, :);
                        this_move_block = [];
                        this_move_block = this_move_block_before_arrange(1:point - 1, :);

                        for re = point:this_block_size
                            reTime = this_move_block(end, 5); %剩余块的开始时间
                            this_move_block(re, :) = this_move_block_before_arrange(re, :);
                            this_move_block(re, 4:5) = [reTime, reTime + (this_move_block_before_arrange(re, 5) - this_move_block_before_arrange(re, 4))];
                        end

                        this_nei_schedule(this_keyblock_index, :) = this_move_block;
                        this_nei_chromo = chromo; this_nei_chromo{2} = this_nei_schedule(this_nei_schedule(:, 8) == 0, 1)';
                        nei_sign = [nei_sign, 0];
                        nei_chromos = [nei_chromos; this_nei_chromo];
                        nei_schedule = cat(3, nei_schedule, this_nei_schedule);
                    end

                end

            end

        end

    end

end

% tail_data=[schedule_right(1:5),Cmax-schedule_right(5)];
function isOK = can_V2Uper(u_schedule, v_schedule, schedule)
    % if r(jpv)<=r(u)+Pu    is OK
    index = ismember(schedule(1:2), [v_schedule(1), v_schedule(2) - 1], 'rows');
    isOK = false;

    if any(index) %如果存在
        jpv_schedule = schedule(index, :);
        jpv_head_leagth = jpv_schedule(4);
    else
        jpv_head_leagth = 0;
    end

    pu = u_schedule(5) - u_schedule(4);

    if jpv_head_leagth <= u_schedule(4) + pu
        isOK = true;
    end

end

% tail_data=[schedule_right(1:5),Cmax-schedule_right(5)];
function isOK = can_U2Vnext(u_schedule, v_schedule, tail_data)
    % if tjs(u)+pjs(u)<=tv+pv    is OK
    index = ismember(u_schedule(1:2), [tail_data(1), tail_data(2) + 1], 'rows');
    indexv = ismember(v_schedule(1:2), tail_data(:, 1:2), 'rows');
    isOK = false;

    if any(index) %如果存在
        jsu_tail_leagth = tail_data(index, 6);
        pjsu = tail_data(index, 5) - tail_data(index, 4);
    else
        jsu_tail_leagth = 0; pjsu = 0;
    end

    tv = tail_data(indexv, 6);
    pv = v_schedule(5) - v_schedule(4);

    if jsu_tail_leagth + pjsu <= tv + pv
        isOK = true;
    end

end

function new_schedule = V2Uper(u_schedule, v_schedule)
    v_schedule(4:5) = [u_schedule(4), u_schedule(4) + v_schedule(5) - v_schedule(4)]; v_schedule(10) = 2;
    u_schedule(4:5) = [v_schedule(5), v_schedule(5) + u_schedule(5) - u_schedule(4)]; u_schedule(10) = 0;
    new_schedule = [v_schedule; u_schedule];
end
