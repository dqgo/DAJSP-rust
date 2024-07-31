% chromos={[FS] [PS] [AS]}
function [chromos_withon_elite, elite_population,thisMinCmax] = selectChromos(chromos, fitness, elite_ratio, tournament_size)
    % function new_population = tournamentSelection(population, fitness, tournament_size, elite_ratio)
    % population: 输入的种群，每行表示一个个体，每列表示一个基因
    % fitness: 每个个体的适应度
    % tournament_size: 锦标赛选择的大小
    % elite_ratio: 精英保留系数，例如0.1表示保留最优的10%

    
    thisAGVCmax = mean(fitness);
    thisMinCmax = min(fitness);
    population = chromos;
    population_size = size(population, 1);

    % 计算要保留的精英数量
    elite_count = ceil(population_size * elite_ratio);

    % 选取精英
    [~, elite_indices] = sort(fitness);
    elite_population = population(elite_indices(1:elite_count), :);

    % 创建新种群
    new_population = cell(size(population));

    % 进行锦标赛选择
    for i = 1:population_size
        tournament_indices = randperm(population_size, tournament_size);
        tournament_fitness = fitness(tournament_indices);
        [~, winner_index] = min(tournament_fitness);
        new_population(i, :) = population(tournament_indices(winner_index), :);
    end

    % 将精英加入新种群

    % new_population(1:elite_count, :) = elite_population;
    chromos_withon_elite = population(elite_count + 1:end, :);

end

% function [outChromos,eliteChromos] = selectChromos(inChromos, popu, changeData, workpieceNum, machNum,fitness,pElite,bc,nowIterate)
%     roulette = zeros(popu, 5);
%     % fitness = calcFitness(inChromos, popu, changeData, workpieceNum, machNum);
%     global thisAGVCmax;
%     global thisMinCmax;
%     thisAGVCmax=mean(fitness);
%     thisMinCmax=min(fitness);
%
%     % 适应度缩放
%     % scaledFitness = 1 ./ (fitness + min(fitness));
%     scaledFitness = 1 ./ (fitness + (min(fitness)+max(fitness)/2));
%     % scaledFitness = 1 ./ (fitness);
%     roulette(:, 2) = fitness; % 适应度
%     roulette(:, 1) = 1:popu; % 伪指针
%     roulette(:, 3) = scaledFitness.*1.00 ; % 伪适应度，可以根据问题的特性调整缩放参数
%     sumFitness = sum(roulette(:, 3)); % 伪适应度之和
%     roulette(:, 4) = roulette(:, 3) / sumFitness;
%     roulette(1, 5) = roulette(1, 4);
%     roulette(:, 5) = cumsum(roulette(:, 4));
%
%     % 使用 rand 一次性生成所有的指针
%     pointers = rand(1, popu);
%
%     % 使用 histcounts 进行选择
%     [~, ~, idx] = histcounts(pointers, [0; roulette(:, 5)]);
%
%     % 精英选择，将上一代中的最优两个个体直接复制到下一代中
%     [~, eliteIdx] = sort(fitness);
%     eliteCount = round(pElite*popu); % 保留最优的几个个体
%     eliteChromos = inChromos(eliteIdx(1:eliteCount), :);
%     insertRand=randperm(5,1);
%     if nowIterate>insertRand+7 && thisMinCmax<=938 || nowIterate>insertRand+15 && thisMinCmax<=941
%         eliteChromos(end,:)=bc;
%     end
%
%     % 遗传下去，除了精英个体外的其他个体
%     outChromos = inChromos(roulette(idx, 1), :);
%
%     % 将精英个体插入到新种群中
%     outChromos(end - eliteCount + 1:end, :) = eliteChromos;
% end

%选择操作：输入一个种群，得到一个新种群
% function new_population = rouletteWheelSelection(population, fitness, elite_ratio)
%     % population: 输入的种群，每行表示一个个体，每列表示一个基因
%     % fitness: 每个个体的适应度，越小越好
%     % elite_ratio: 精英保留系数，例如0.1表示保留最优的10%
%
%     global thisAGVCmax;
%     global thisMinCmax;
%     thisAGVCmax=mean(fitness);
%     thisMinCmax=min(fitness);
%     % 计算轮盘赌概率
%     total_fitness = sum(fitness);
%     selection_prob = fitness / total_fitness;
%
%     % 计算每个个体的累积概率
%     cumulative_prob = cumsum(selection_prob);
%
%     % 计算要保留的精英数量
%     elite_count = ceil(size(population, 1) * elite_ratio);
%
%     % 选取精英
%     [~, elite_indices] = sort(fitness);
%     elite_population = population(elite_indices(1:elite_count), :);
%
%     % 使用轮盘赌选择新的个体
%     new_population = zeros(size(population));
%     for i = 1:size(population, 1)
%         r = rand();
%         for j = 1:size(population, 1)
%             if r <= cumulative_prob(j)
%                 new_population(i, :) = population(j, :);
%                 break;
%             end
%         end
%     end
%
%     % 将精英加入新的种群
%     new_population(1:elite_count, :) = elite_population;
% end

% 锦标赛
% function new_population = tournamentSelection(population, fitness, tournament_size, elite_ratio)
%     % population: 输入的种群，每行表示一个个体，每列表示一个基因
%     % fitness: 每个个体的适应度
%     % tournament_size: 锦标赛选择的大小
%     % elite_ratio: 精英保留系数，例如0.1表示保留最优的10%
%
%     global thisAGVCmax;
%     global thisMinCmax;
%     thisAGVCmax=mean(fitness);
%     thisMinCmax=min(fitness);
%
%     population_size = size(population, 1);
%
%     % 计算要保留的精英数量
%     elite_count = ceil(population_size * elite_ratio);
%
%     % 选取精英
%     [~, elite_indices] = sort(fitness);
%     elite_population = population(elite_indices(1:elite_count), :);
%
%     % 创建新种群
%     new_population = zeros(size(population));
%
%     % 进行锦标赛选择
%     for i = 1:population_size
%         tournament_indices = randperm(population_size, tournament_size);
%         tournament_fitness = fitness(tournament_indices);
%         [~, winner_index] = min(tournament_fitness);
%         new_population(i, :) = population(tournament_indices(winner_index), :);
%     end
%
%     % 将精英加入新种群
%     new_population(1:elite_count, :) = elite_population;
% end
