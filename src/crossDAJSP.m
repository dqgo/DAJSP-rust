function chromos = crossDAJSP(chromos, Pcross)
    chromos_num = size(chromos, 1);

    for i = 1:ceil(chromos_num / 2)

        index = randperm(chromos_num, 2);
        p1 = chromos(index(1), :); p2 = chromos(index(2), :);

        p1_FA = p1{1}; p2_FA = p2{1};
        p1_PS = p1{2}; p2_PS = p2{2};
        p1_AS = p1{3}; p2_AS = p1{3};

        c_both_PS = POX4PSandAS([p1_PS; p2_PS], NaN, Pcross);
        c_both_AS = POX4PSandAS([p1_AS; p2_AS], NaN, Pcross);
        [c1_FA, c2_FA] = UC4FA(p1_FA, p2_FA, Pcross);
        c1 = {c1_FA [c_both_PS(1, :)] [c_both_AS(1, :)]}; c2 = {c2_FA [c_both_PS(2, :)] [c_both_AS(2, :)]};
        chromos(index, :) = [c1; c2];
    end

end

function [p1_FA, p2_FA] = UC4FA(p1_FA, p2_FA, Pcross)
    size_FA = size(p1_FA, 2);

    for i = 1:size_FA

        if rand() < Pcross
            temp = p1_FA(i); p1_FA(i) = p2_FA(i); p2_FA(i) = temp;
        end

    end

end

%% pox交叉
function Children_group1 = POX4PSandAS(Parent, ~, Pc)
    remain_pop = size(Parent, 1);
    Children_group1 = [];
    len_of_chromosome = size(Parent.', 1);
    randrow = randperm(remain_pop); %随机行索引
    p1 = Parent(randrow(1:(remain_pop) / 2), :);
    p2 = Parent(randrow((remain_pop) / 2 + 1:end), :); %随机分为两个父代集合

    for i = 1:(remain_pop) / 2 %选择父母个体
        num_of_jobs = max(Parent(i, :));
        % Rows=1:(PopSize)/2;
        % index_parent2 = Rows(randperm(numel(Rows),1)); %其他的一种找出父代1，2的方法：父代1从集合中按顺序选择，父代2随机从集合选择
        % for gene = 1:len_of_chromosome
        % Parent1(gene)=Parent(i,gene);
        % Parent2(gene)=Parent(i+(remain_pop)/2,gene); %从集合中前一半为父代1，后一半为父代2
        % end
        % Parent1=Parent(i,:);
        % Parent2=Parent(i+(remain_pop)/2,:);
        Parent1 = p1(i, :);
        Parent2 = p2(randi((remain_pop) / 2), :);

        Children1 = zeros(1, len_of_chromosome);
        Children2 = zeros(1, len_of_chromosome);

        if rand(1) <= Pc %和pc比较是否进行交叉
            num_J1 = randi([1, num_of_jobs]); %随机将工件 jobs {1,2,3...,n} 分为两个非空子集J1和J2.num_j1是j1的数目

            if num_J1 == num_of_jobs
                num_J1 = fix(num_of_jobs / 2); %fix四舍五入函数
            end

            J = randperm(num_of_jobs);
            J1 = J(1:num_J1); % J2 =J(num_J1+1:n);
            %将Parent1 包含J1的工件复制到 Children1,和 Parent2 包含在 J1 工件到 Children2 中，并将它们保持原来的位置不变.
            for index = 1:num_J1
                job = J1(index);

                for j = 1:len_of_chromosome

                    if job == Parent1(j) %查找 J1 中 Parent1 和 Parent2 包含的工件
                        Children1(j) = Parent1(j);
                        Parent1(j) = 0;
                    end

                    if job == Parent2(j)
                        Children2(j) = Parent2(j);
                        Parent2(j) = 0;
                    end

                end

            end

            %将 Parent1 包含在 J2 中的工件复制到 Children2，和 Parent2 按其顺序复制到 Children1 中。
            for index = 1:len_of_chromosome

                if Parent1(index) ~= 0

                    for j = 1:len_of_chromosome

                        if Children2(j) == 0 %如果子代2中当前j号基因位置空着就把父代的基因插入
                            Children2(j) = Parent1(index);
                            break;
                        end

                    end

                end

                if Parent2(index) ~= 0

                    for j = 1:len_of_chromosome

                        if Children1(j) == 0
                            Children1(j) = Parent2(index);
                            break;
                        end

                    end

                end

            end %POX交叉结束

        else
            Children1 = Parent1;
            Children2 = Parent2;
        end

        %交叉的子代集合
        % condtion = rand(1);随机存放
        for gene = 1:len_of_chromosome
            % if condtion>0.5
            % Children_group1(i, gene)=Children1(gene);
            % else
            % Children_group1(i, gene)=Children2(gene);
            % end
            Children_group1(2 * i - 1, gene) = Children1(gene); %奇数行为子代1，偶数行为子代2
            Children_group1(2 * i, gene) = Children2(gene);
        end

    end

end
