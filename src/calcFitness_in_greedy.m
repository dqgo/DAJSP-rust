function fitness = calcFitness_in_greedy(chromos, data)
    popu = size(chromos, 1);
    fitness = zeros(popu, 1);

    for i = 1:popu
        schedule = createSchedule_in_greedy(data, chromos(i, :));
        fitness(i, 1) = max(schedule(:, 5));
    end

end
