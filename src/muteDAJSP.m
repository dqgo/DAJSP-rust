% 对FA向量应用单点随机突变算子，该算子用相关作业的不同工厂索引随机替换元素。
% 此外，对PS和AS向量使用交换运算符，它随机交换编码向量的两个元素
function chromos_withno_elite = muteDAJSP(chromos_withno_elite, Pmute, factory_num)
    PS = 2;
    AS = 3;
    chromos_withno_elite = mutePoint(chromos_withno_elite, factory_num, Pmute);
    chromos_withno_elite = muteSwap(chromos_withno_elite, Pmute, PS);
    chromos_withno_elite = muteSwap(chromos_withno_elite, Pmute, AS);
end

function chromos = mutePoint(chromos, factory_num, Pmute)
    FS_size = size(chromos{1, 1}, 2);

    for i = 1:size(chromos, 1)

        if rand() < Pmute
            chromos{i, 1}(randperm(FS_size, 1)) = randperm(factory_num, 1);
        end

    end

end

function chromos = muteSwap(chromos, Pmute, PSorAS)
    this_size = size(chromos{1, PSorAS}, 2);

    for i = 1:size(chromos, 1)

        if rand() < Pmute
            rand_index = randperm(this_size, 2);
            temp = chromos{i, PSorAS}(rand_index(1));
            chromos{i, PSorAS}(rand_index(1)) = chromos{i, PSorAS}(rand_index(2));
            chromos{i, PSorAS}(rand_index(2)) = temp;
        end

    end

end
