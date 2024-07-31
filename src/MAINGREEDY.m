%%DAJSP
% GA with TS
% 2024年6月20日
function MAINRETUNE = MAINGREEDY()
    tic
    
    thisMinCmax = 9999;
    previous_fitness = 9999;
    %%%%%%%%%%%%%%%%%%%%%系数%%%%%%%%%%%%%%%%%%%%%
    popu = 400; %得是偶数，并且popu*(1-pElite)也要是偶数要不然交叉就错了
    maxIterate = inf;
    nowIterate = 0;
    Pcross = 0.9;
    % PmutaPMX=0.25;
    Pmuta = 0.05;
    % muteNum=3;
    % numCross=10;
    % immigrantNum=2;
    % immigrantSize=0.2;
    % count=0;
    pElite = 0.1;
    breakIterate = 10;
    tournament_size = 3;
    iterate_num = 5000;
    tubeSearchLength = 14;
    threshold = 50;
    %%%%%%%%%%%%%%%%%%%%%系数%%%%%%%%%%%%%%%%%%%%%
    %载入算例
    [data] = changeDataFunction();
    % data={1[change_data] 2[job_num] 3[work_num] 4[factory_num] 5[assembly] 6[assembly_data]}
    % 初始化种群
    [chromos] = createInitialPopus(popu, data);

    while all(nowIterate < maxIterate)

        %% -------------------------------GA+TS with greedy-----------------------------------------------------------

        parfor i = 1:popu
            chromos(i, :) = TS_with_greedy4DAJSP(chromos(i, :), iterate_num, threshold, data, tubeSearchLength);
        end

        %计算适应度
        fitness = calcFitness_in_greedy(chromos, data);

        %选择操作
        [chromos_withno_elite, eliteChromos,thisMinCmax] = selectChromos(chromos, fitness, pElite, tournament_size);
        nowMinCmax(nowIterate + 1) = thisMinCmax;
        MINCmax(nowIterate + 1) = min(nowMinCmax);
        refreshdata
        drawnow

        %交叉操作 %动态的交叉概率 %随机选择一种交叉方式 %多次交叉
        chromos_withno_elite = crossDAJSP(chromos_withno_elite, Pcross);

        %变异操作 %动态的变异概率
        chromos_withno_elite = muteDAJSP(chromos_withno_elite, Pmuta, data{1, 4});

        %% ------------------------------------------------------------------------------------------
        chromos = [chromos_withno_elite; eliteChromos];
        index = randperm(size(chromos, 1));
        chromos = chromos(index, :);

        nowIterate = nowIterate + 1;
        % % % % 打印在这里
        % disp(nowMinCmax(nowIterate));%disp(nowIterate);

        plot(1:nowIterate, MINCmax)
        % plot(1:nowIterate,nowMinCmax);
        % MINCmax

        % % 计算适应度是否有改变，若无改变则连续计数器加一，否则重置计数器
        if MINCmax(end) == previous_fitness
            unchanged_count = unchanged_count + 1;
        else
            unchanged_count = 0;
        end

        % 检查连续不变动的次数是否达到阈值，如果是则跳出循环
        if unchanged_count >= breakIterate
            % disp('连续没有变动，跳出循环');
            % disp(i);

            break;

        end

        previous_fitness = MINCmax(end); % 更新上一次的适应度
    end

    %至此，已完成，下面找出种群内的最优解染色体和最优解数目，并输出gant图
    % MAINEND(popu,chromos,changeData,workpieceNum,machNum);
    disp(MINCmax(end));
    MAINRETUNE = MINCmax(end);
    toc
end


