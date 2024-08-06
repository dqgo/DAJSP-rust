#![allow(warnings)]
use crossbeam::scope;
use crossbeam::thread::ScopedThreadBuilder;
use plotters::data;
use rand::seq::SliceRandom;
use rand::Rng;
use rayon::prelude::*;
use rayon::vec;
use std::collections::HashMap;
use std::io;
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};

#[derive(Debug, Clone)]
pub struct Data {
    change_data: Vec<Vec<i32>>,
    job_num: usize,
    work_num: usize,
    factory_num: usize,
    assembly: Vec<i32>,
    assembly_data: Vec<i32>,
}

fn main() {
    // ------------系列----------
    let popu = 5000__;
    let max_iterate = 5000;
    let mut now_iterate = 0;
    let p_cross = 0.45;
    let mut p_mutate = 0.05;
    let p_elite: f64 = 0.0;
    let break_iterate = 10;
    let tube_length = 14;
    let tube_threshold = 100;
    // ------------系列----------

    // 开始计时
    let start = Instant::now();

    //载入数据
    let data = change_data_function();
    // println!("{:?}", data);

    //初始化种群
    let mut chromos = create_initial_popus(popu, &data);
    // println!("{:?}", chromos);
    //通过chromos[i]来访问第i个染色体，通过chromos[i].0来访问第i个染色体的工厂分配，通过chromos[i].1来访问第i个染色体的工序分配，通过chromos[i].2来访问第i个染色体的装配顺序

    //开始迭代
    while now_iterate < max_iterate {
        // 禁忌搜索
        // 创建一个Arc<Mutex<Vec<...>>>来共享chromos
        let shared_chromos = Arc::new(Mutex::new(chromos));

        // 使用rayon进行并行计算
        (0..popu).into_par_iter().for_each(|i| {
            let shared_chromos = Arc::clone(&shared_chromos);
            let data = data.clone(); // data可以被克隆

            // 锁定并获取单个染色体
            let mut chromo = {
                let mut chromos = shared_chromos.lock().unwrap();
                chromos[i].clone()
            };

            // 传递单个染色体
            let result = tube_search(&mut chromo, &data, tube_length, tube_threshold);

            // 更新单个染色体
            let mut chromos = shared_chromos.lock().unwrap();
            chromos[i] = result;
        });

        // 解锁并获取更新后的chromos
        chromos = Arc::try_unwrap(shared_chromos)
            .unwrap()
            .into_inner()
            .unwrap();

        // 计算适应度
        let fitness: Vec<i32> = calc_fitness(&chromos, &data);
        // let fitness: Vec<i32> = calc_fitness_thread(&chromos, &data);
        // println!("适应度: {:?}", &fitness[1..5]);
        let the_best_fitness = fitness.iter().min().unwrap();
        let the_best_chromo = chromos[fitness
            .iter()
            .position(|&r| r == *the_best_fitness)
            .unwrap()]
        .clone();
        println!("当前最优适应度: {}", the_best_fitness);
        // 选择
        let (mut elite_chromos, mut selected_chromos) = select(&mut chromos, &fitness, &p_elite);

        // 交叉
        // println!("selected_chromos: {:?}", selected_chromos);
        selected_chromos = cross_chromos(&selected_chromos, &p_cross);

        // 变异
        selected_chromos = mutate_chromos(&selected_chromos, &p_mutate, &data.factory_num);
        chromos = selected_chromos;
        chromos.append(&mut elite_chromos);
        now_iterate += 1;
        // print!("迭代次数: {}/{}", now_iterate, max_iterate);
        // println!(" chromos[0]= {:?}", chromos[0]);
    }
    // 结束计时
    let duration = start.elapsed();
    println!("代码执行时间: {:#?}", duration);

    // 等待用户输入以保持窗口打开
    println!("按回车键退出...");
    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap();
}

//-------------禁忌搜索----------------
fn tube_search(
    chromo: &(Vec<usize>, Vec<usize>, Vec<usize>),
    data: &Data,
    tube_length: usize,
    tube_iter: i32,
) -> (Vec<usize>, Vec<usize>, Vec<usize>) {
    let mut best_chromo = chromo.clone();
    let mut best_fitness = 9999;
    let mut tube: Vec<(Vec<usize>, Vec<usize>, Vec<usize>)> = Vec::new();
    let mut tube_fitness: Vec<i32> = Vec::new();
    let mut now_iterate = 0;
    let mut now_threshold = 0;
    while now_threshold < tube_iter {
        //对当前染色体进行解码，生成shcedule
        let schedule = create_schedule((chromo), data);
        //对schedule进行右移，生成schedule_right
        let Cmax = schedule.iter().map(|x| x[4]).max().unwrap();
        let schedule_right = create_schedule_right(&schedule, &Cmax);
        //由schedule和schedule_right得到关键工序，并由此得到关键块
        let key_blocks: Vec<(Vec<Vec<i32>>, Vec<usize>)> = create_key_block(&schedule, &schedule_right, data);
        //由关键块对chromo进行N7邻域搜索，得到新的neighbor_chromos
        let (neighbor_chromos, neighbor_schedule, neighbor_sign, PS_start_num) =
            create_neighbor_chromos(
                &chromo,
                &schedule,
                &schedule_right,
                &key_blocks,
                data,
            );
        //计算neighbor_chromos的适应度，使用近似评价方法

        //选择适应度最好的neighbor_chromos，更新best_chromo和best_fitness

        //更新chromo为不在禁忌表中的适应度最好的neighbor_chromos

        //更新now_threshold和now_iterate

        //如果best_fitness连续threshold次没有更新，则跳出循环

        //更新禁忌表

        now_threshold += 1;
    }
    best_chromo
}

//-------------使用N7生成邻域解----------------
fn create_neighbor_chromos(
    chromo: &(Vec<usize>, Vec<usize>, Vec<usize>),
    schedule: &Vec<Vec<i32>>,
    schedule_right: &Vec<Vec<i32>>,
    key_blocks: &Vec<(Vec<Vec<i32>>, Vec<usize>)>,
    data: &Data,
) -> (
    Vec<(Vec<usize>, Vec<usize>, Vec<usize>)>,
    Vec<Vec<i32>>,
    Vec<usize>,
    usize,
) {
    
}

//schedule=[1工件号 2工序号  3机器号 4开工时间 5完工时间 6工厂号 7装配号 8属性(0加工/1装配) 9-10预留]
//-------------生成关键块----------------
fn create_key_block(
    schedule: &Vec<Vec<i32>>,
    schedule_right: &Vec<Vec<i32>>,
    data: &Data,
) -> Vec<(Vec<Vec<i32>>, Vec<usize>)> {
    let key_job = create_key_job(schedule, schedule_right, data);
    let mut key_blocks = Vec::new();

    for (key_schedule, key_indices) in key_job {
        let mut current_block = Vec::new();
        let mut current_indices = Vec::new();

        for (i, job) in key_schedule.iter().enumerate() {
            if current_block.is_empty() {
                current_block.push(job.clone());
                current_indices.push(key_indices[i]);
            } else {
                let mut is_connected = false;
                for last_job in &current_block {
                    if job[6] == last_job[6] && job[3] == last_job[4] && job[3] == last_job[3] {
                        is_connected = true;
                        break;
                    }
                }
                if is_connected {
                    current_block.push(job.clone());
                    current_indices.push(key_indices[i]);
                } else {
                    if current_block.len() >= 2 {
                        key_blocks.push((current_block.clone(), current_indices.clone()));
                    }
                    current_block.clear();
                    current_indices.clear();
                    current_block.push(job.clone());
                    current_indices.push(key_indices[i]);
                }
            }
        }

        if current_block.len() >= 2 {
            key_blocks.push((current_block, current_indices));
        }
    }
    key_blocks.retain(|(block, _)| !block.iter().any(|job| job[5] == 1));
    key_blocks
}

//-------------生成关键工序----------------git push origin master --force
//返回的create_key_job
fn create_key_job(
    schedule: &Vec<Vec<i32>>,
    schedule_right: &Vec<Vec<i32>>,
    data: &Data,
) -> Vec<(Vec<Vec<i32>>, Vec<usize>)> {
    let mut schedule_this_fun = schedule.clone();
    let mut schedule_right_this_fun = schedule_right.clone();
    let (index, schedule_this_fun) = sortrows(schedule_this_fun, &[0, 1]);
    let (index_right, schedule_right_this_fun) = sortrows(schedule_right_this_fun, &[0, 1]);
    let mut key_index = Vec::new();
    for i in 0..schedule_this_fun.len() {
        if schedule_this_fun[i] == schedule_right_this_fun[i] {
            key_index.push(i);
        }
    }
    let key_index_in_schedule_under_sort: Vec<usize> =
        key_index.iter().map(|&i| index[i]).collect();
    let key_schedule: Vec<Vec<i32>> = key_index_in_schedule_under_sort
        .iter()
        .map(|&i| schedule[i].clone())
        .collect();
    vec![(key_schedule, key_index_in_schedule_under_sort)]
}

//-------------sortrows-------------
fn sortrows(matrix: Vec<Vec<i32>>, order: &[usize]) -> (Vec<usize>, Vec<Vec<i32>>) {
    let mut indexed_matrix: Vec<(usize, Vec<i32>)> = matrix.into_iter().enumerate().collect();

    indexed_matrix.sort_by(|a, b| {
        for &index in order {
            if a.1[index] != b.1[index] {
                return a.1[index].cmp(&b.1[index]);
            }
        }
        std::cmp::Ordering::Equal
    });
    let (indices, sorted_matrix): (Vec<usize>, Vec<Vec<i32>>) = indexed_matrix.into_iter().unzip();
    (indices, sorted_matrix)
}

//-------------生成右移schedule_right----------------
//schedule=[1工件号 2工序号  3机器号 4开工时间 5完工时间 6工厂号 7装配号 8属性(0加工/1装配) 9-10预留]
fn create_schedule_right(schedule: &Vec<Vec<i32>>, Cmax: &i32) -> Vec<Vec<i32>> {
    let mut schedule_right: Vec<Vec<i32>> = Vec::new();
    let mut schedule_this_fun = schedule.clone();
    for i in (0..schedule_this_fun.len()).rev() {
        let mut this_schedule = schedule_this_fun[i].clone();
        let this_job_id = this_schedule[0];
        let this_word_id = this_schedule[1];
        let this_assembly_id = this_schedule[6];
        //如果是装配工序
        if this_schedule[7] == 1 {
            //只需要找到MS
            let same_machine_schedule: Vec<Vec<i32>> = schedule_right
                .iter()
                .filter(|schedule| schedule[7] == 1)
                .cloned()
                .collect();
            if same_machine_schedule.len() == 0 {
                this_schedule[4] = *Cmax;
                this_schedule[3] = this_schedule[4] - (this_schedule[4] - this_schedule[3]);
            } else {
                this_schedule[4] = same_machine_schedule
                    .iter()
                    .map(|schedule| schedule[3])
                    .max()
                    .unwrap();
                this_schedule[3] = this_schedule[4] - (this_schedule[4] - this_schedule[3]);
            }
        } else {
            // 对于加工工序，找到MS JS和AS
            // 找到MS
            let same_machine_schedule: Vec<Vec<i32>> = schedule_right
                .iter()
                .filter(|schedule| {
                    schedule[6] == this_schedule[6] && schedule[2] == this_schedule[2]
                })
                .cloned()
                .collect();

            let MS_can_end_time = if same_machine_schedule.len() == 0 {
                Cmax
            } else {
                same_machine_schedule
                    .iter()
                    .map(|schedule| &schedule[4])
                    .min()
                    .unwrap()
            };

            // 找到JS
            let JS_schedule: Option<&Vec<i32>> = schedule_right.iter().find(|schedule| {
                schedule[0] == this_schedule[0] && schedule[1] == this_schedule[1] + 1
            });

            let JS_can_end_time = if let Some(schedule) = JS_schedule {
                schedule[3]
            } else {
                *Cmax
            };

            // 找到AS
            let AS_schedule: Option<&Vec<i32>> = schedule_right
                .iter()
                .find(|schedule| schedule[6] == this_schedule[6] && schedule[7] == 1);

            let AS_can_end_time = if let Some(schedule) = AS_schedule {
                schedule[3]
            } else {
                *Cmax
            };

            // 找到最大的开始时间
            let can_end_times = vec![MS_can_end_time, &JS_can_end_time, &AS_can_end_time];
            let can_end_time = can_end_times.iter().min().unwrap();
            this_schedule[4] = **can_end_time;
            this_schedule[3] = this_schedule[4] - (this_schedule[4] - this_schedule[3]);
            // 插入到schedule_right的第一个位置
            schedule_right.insert(0, this_schedule);
        }
    }
    schedule_right
}
//-------------变异----------------
// 对FA向量应用单点随机突变算子，该算子用相关作业的不同工厂索引随机替换元素。
// 此外，对PS和AS向量使用交换运算符，它随机交换编码向量的两个元素
fn mutate_chromos(
    chromos: &Vec<(Vec<usize>, Vec<usize>, Vec<usize>)>,
    p_mutate: &f64,
    factory_num: &usize,
) -> Vec<(Vec<usize>, Vec<usize>, Vec<usize>)> {
    let mut return_chromos = chromos.clone();
    // let factory_num=chromos[0].0.iter().max().unwrap();
    for i in 0..chromos.len() {
        let mut rng = rand::thread_rng();
        let random_number: f64 = rng.gen_range(0.0..1.0);
        if random_number <= *p_mutate {
            let chromo = &mut return_chromos[i];
            // 变异FA
            let fa: &mut Vec<usize> = &mut chromo.0;
            let pos = rng.gen_range(0..fa.len());
            let current_factory = fa[pos];
            let mut new_factory = current_factory;
            while new_factory == current_factory {
                new_factory = rng.gen_range(1..=*factory_num);
            }
            // assert!(current_factory == 1 || current_factory == 2);
            fa[pos] = new_factory;
            // 变异PS
            let ps = &mut chromo.1;
            if ps.len() > 1 {
                let pos1 = rng.gen_range(0..ps.len());
                let mut pos2 = rng.gen_range(0..ps.len());
                while pos1 == pos2 {
                    pos2 = rng.gen_range(0..ps.len());
                }
                // println!("交换前的PS: {:?}", ps);
                // println!("交换位置索引: pos1 = {}, pos2 = {}", pos1, pos2);
                ps.swap(pos1, pos2);
                // println!("交换后的PS: {:?}", ps);
            }
        }
    }
    return_chromos
    
}

//-------------交叉----------------
fn cross_chromos(
    chromos: &Vec<(Vec<usize>, Vec<usize>, Vec<usize>)>,
    p_cross: &f64,
) -> Vec<(Vec<usize>, Vec<usize>, Vec<usize>)> {
    let mut return_chromos = Vec::with_capacity(chromos.len());
    for i in (0..chromos.len() - 1).step_by(2) {
        let mut rng = rand::thread_rng();
        let random_number: f64 = rng.gen_range(0.0..1.0);
        if random_number <= *p_cross {
            let p1 = chromos[i].clone();
            let p2 = chromos[i + 1].clone();
            // println!(" p1: {:?}", p1);
            // println!(" p2: {:?}", p2);
            let p1_fa = &p1.0;
            let p1_ps = &p1.1;
            let p2_fa = &p2.0;
            let p2_ps = &p2.1;
            // let (c1_fa, c2_fa) = pox_2(p1_fa, p2_fa);
            // //当c1_fa和c2_fa中有元素为0，崩溃
            // if c1_fa.contains(&0) || c2_fa.contains(&0){
            //     println!("c1_fa: {:?}, c2_fa: {:?}", c1_fa, c2_fa);
            //     eprintln!("c1_fa or c2_fa contains 0");
            //     std::process::exit(1);
            // }
            let (c1_ps, c2_ps) = pox_2(p1_ps, p2_ps);
            let c1 = (p1.0.clone(), c1_ps, p1.2.clone());
            let c2 = (p2.0.clone(), c2_ps, p2.2.clone());
            return_chromos.push(c1);
            return_chromos.push(c2);
        } else {
            return_chromos.push(chromos[i].clone());
            return_chromos.push(chromos[i + 1].clone());
        }
    }
    return_chromos
}
// dqgo:pox逐步生成法
fn pox_2(p1: &Vec<usize>, p2: &Vec<usize>) -> (Vec<usize>, Vec<usize>) {
    // 初始化随机数生成器
    let mut rng = rand::thread_rng();

    // 获取染色体长度
    let len_of_chromosome = p1.len();

    // 初始化子代染色体
    let mut c1 = vec![0; len_of_chromosome];
    let mut c2 = vec![0; len_of_chromosome];

    // 获取工件集 J
    let max_value = *p1.iter().max().unwrap();
    let j: Vec<usize> = (1..=max_value).collect();

    // 从 J 中随机选取几位构成 J1，其余的构成 J2
    let num_j1 = rng.gen_range(1..=j.len());
    let mut shuffled_j = j.clone();
    shuffled_j.shuffle(&mut rng);
    let j1: Vec<usize> = shuffled_j.iter().take(num_j1).cloned().collect();
    let j2: Vec<usize> = shuffled_j.iter().skip(num_j1).cloned().collect();

    // 打印 p1 p2 J1 和 J2
    // println!("p1: {:?}", p1);
    // println!("p2: {:?}", p2);
    // println!("J1: {:?}", j1);
    // println!("J2: {:?}", j2);

    // 遍历 p1，对于在 p1 位置 i 上的元素，检查其是否属于工件集 j1，若是，将其值赋给 c1 的位置 i
    for (i, &gene) in p1.iter().enumerate() {
        if j1.contains(&gene) {
            c1[i] = gene;
        }
    }

    // 遍历 p2，对于在 p2 位置 i 上的元素，检查其是否属于工件集 j1，若是，将其值赋给 c2 的位置 i
    for (i, &gene) in p2.iter().enumerate() {
        if j1.contains(&gene) {
            c2[i] = gene;
        }
    }

    // 打印目前的 c1 和 c2
    // println!("当前的 c1: {:?}", c1);
    // println!("当前的 c2: {:?}", c2);

    // 遍历 p2，对于每个元素，检查其是否属于工件集 j2，若属于，则将其放在 c1 中第一个元素值为 0 的地方
    for &gene in p2.iter() {
        if j2.contains(&gene) {
            if let Some(pos) = c1.iter().position(|&x| x == 0) {
                c1[pos] = gene;
            }
        }
    }

    // 遍历 p1，对于每个元素，检查其是否属于工件集 j2，若属于，则将其放在 c2 中第一个元素值为 0 的地方
    for &gene in p1.iter() {
        if j2.contains(&gene) {
            if let Some(pos) = c2.iter().position(|&x| x == 0) {
                c2[pos] = gene;
            }
        }
    }

    // 打印最终的 c1 和 c2
    // println!("最终的 c1: {:?}", c1);
    // println!("最终的 c2: {:?}", c2);

    (c1, c2)
}

//-------------选择----------------
fn select(
    chromos: &mut Vec<(Vec<usize>, Vec<usize>, Vec<usize>)>,
    fitness: &Vec<i32>,
    p_elite: &f64,
) -> (
    Vec<(Vec<usize>, Vec<usize>, Vec<usize>)>,
    Vec<(Vec<usize>, Vec<usize>, Vec<usize>)>,
) {
    let total_fitness: i32 = fitness.iter().sum();
    let elite_num = (chromos.len() as f64 * p_elite) as usize;

    let mut elite_chromos: Vec<(Vec<usize>, Vec<usize>, Vec<usize>)> = Vec::new();
    let mut selected_chromos: Vec<(Vec<usize>, Vec<usize>, Vec<usize>)> = Vec::new();

    // Combine chromos and fitness into a single vector of tuples
    let mut combined: Vec<(&(Vec<usize>, Vec<usize>, Vec<usize>), &i32)> =
        chromos.iter().zip(fitness.iter()).collect();

    // Sort by fitness (ascending order)
    combined.sort_by_key(|&(_, fit)| fit);

    // Select elite chromosomes (with the smallest fitness values)
    elite_chromos.extend(
        combined
            .iter()
            .take(elite_num)
            .map(|&(chromo, _)| chromo.clone()),
    );

    // Calculate the inverse of fitness values
    let max_fitness = *fitness.iter().max().unwrap();
    let inverse_fitness: Vec<i32> = fitness.iter().map(|&fit| max_fitness - fit + 1).collect();
    let total_inverse_fitness: i32 = inverse_fitness.iter().sum();

    // Select remaining chromosomes using roulette wheel selection based on inverse fitness
    let mut rng = rand::thread_rng();
    for _ in elite_num..chromos.len() {
        let random_fitness = rng.gen_range(0..total_inverse_fitness);
        let mut cumulative_fitness = 0;
        let mut index = 0;
        while cumulative_fitness < random_fitness {
            cumulative_fitness += inverse_fitness[index];
            index += 1;
        }
        if index > 0 {
            selected_chromos.push(chromos[index - 1].clone());
        }
    }

    (elite_chromos, selected_chromos)
}

// -------------生成数据----------------
fn change_data_function() -> Data {
    let machine = vec![
        vec![8, 12, 9, 4, 13, 2, 14, 1, 15, 7, 10, 5, 3, 11, 6],
        vec![13, 2, 12, 10, 7, 4, 3, 5, 6, 9, 14, 15, 11, 1, 8],
        vec![2, 3, 10, 1, 4, 6, 9, 5, 15, 11, 13, 14, 8, 7, 12],
        vec![14, 11, 7, 3, 15, 8, 5, 12, 1, 6, 10, 4, 9, 2, 13],
        vec![2, 9, 5, 15, 7, 6, 4, 3, 10, 11, 14, 8, 12, 1, 13],
        vec![6, 15, 3, 13, 11, 2, 12, 5, 7, 10, 1, 14, 9, 4, 8],
        vec![6, 3, 1, 2, 9, 15, 12, 11, 8, 10, 7, 13, 5, 14, 4],
        vec![5, 8, 11, 2, 10, 9, 3, 15, 12, 4, 6, 7, 14, 13, 1],
        vec![15, 12, 1, 10, 11, 6, 4, 13, 9, 14, 7, 2, 8, 3, 5],
        vec![10, 1, 4, 11, 13, 14, 6, 2, 7, 15, 9, 12, 3, 8, 5],
        vec![8, 3, 2, 13, 4, 15, 5, 7, 6, 10, 9, 14, 11, 1, 12],
        vec![1, 9, 15, 13, 10, 6, 7, 11, 8, 12, 4, 5, 2, 14, 3],
        vec![9, 13, 11, 12, 15, 4, 7, 2, 5, 6, 1, 10, 14, 3, 8],
        vec![14, 3, 12, 1, 15, 11, 4, 2, 13, 5, 6, 7, 8, 10, 9],
        vec![2, 14, 1, 12, 3, 11, 5, 9, 4, 6, 8, 7, 10, 13, 15],
    ];

    let time = vec![
        vec![69, 81, 81, 62, 80, 3, 38, 62, 54, 66, 88, 82, 3, 12, 88],
        vec![83, 51, 47, 15, 89, 76, 52, 18, 22, 85, 26, 30, 5, 89, 22],
        vec![62, 47, 93, 54, 38, 78, 71, 96, 19, 33, 44, 71, 90, 9, 21],
        vec![33, 82, 80, 30, 96, 31, 11, 26, 41, 55, 12, 10, 92, 3, 75],
        vec![36, 49, 10, 43, 69, 72, 19, 65, 37, 57, 32, 11, 73, 89, 12],
        vec![83, 32, 6, 13, 87, 94, 36, 76, 46, 30, 56, 62, 32, 52, 72],
        vec![29, 78, 21, 27, 17, 43, 14, 15, 16, 49, 72, 19, 99, 38, 64],
        vec![12, 74, 4, 3, 15, 62, 50, 38, 49, 25, 18, 55, 5, 71, 27],
        vec![69, 13, 33, 47, 86, 31, 97, 48, 25, 40, 94, 22, 61, 59, 16],
        vec![27, 4, 35, 80, 49, 46, 84, 46, 96, 72, 18, 23, 96, 74, 23],
        vec![36, 17, 81, 67, 47, 5, 51, 23, 82, 35, 96, 7, 54, 92, 38],
        vec![78, 58, 62, 43, 1, 56, 76, 49, 80, 26, 79, 9, 24, 24, 42],
        vec![38, 86, 38, 38, 83, 36, 11, 17, 99, 14, 57, 64, 58, 96, 17],
        vec![10, 86, 93, 63, 61, 62, 75, 90, 40, 77, 8, 27, 96, 69, 64],
        vec![73, 12, 14, 71, 3, 47, 84, 84, 53, 58, 95, 87, 90, 68, 75],
    ];

    let change_data = combine_matrices(&machine, &time);
    let assembly = vec![1, 2, 2, 1, 1, 1, 2, 2, 2, 1, 1, 2, 2, 1, 1];
    let assembly_data = vec![968, 166];
    let job_num = change_data.len();
    let work_num = change_data[0].len() / 2;
    let factory_num = 2;

    Data {
        change_data,
        job_num,
        work_num,
        factory_num,
        assembly,
        assembly_data,
    }
}

fn combine_matrices(a: &Vec<Vec<i32>>, b: &Vec<Vec<i32>>) -> Vec<Vec<i32>> {
    let rows_a = a.len();
    let cols_a = a[0].len();
    let rows_b = b.len();
    let cols_b = b[0].len();

    if rows_a != rows_b {
        panic!("Matrices a and b must have the same number of rows");
    }

    let mut c = vec![vec![0; cols_a + cols_b]; rows_a];

    for i in 0..rows_a {
        for j in 0..cols_a {
            c[i][2 * j] = a[i][j];
        }
        for j in 0..cols_b {
            c[i][2 * j + 1] = b[i][j];
        }
    }

    c
}

//-------------生成初始解----------------
pub fn create_initial_popus(popu: usize, data: &Data) -> Vec<(Vec<usize>, Vec<usize>, Vec<usize>)> {
    let mut chromos = vec![(vec![], vec![], vec![]); popu];
    let factory_num = data.factory_num;
    let job_num = data.job_num;
    let work_num = data.work_num;
    let assembly_num = *data.assembly.iter().max().unwrap() as usize;

    for i in 0..popu {
        chromos[i].0 = (0..job_num)
            .map(|_| rand::thread_rng().gen_range(1..=factory_num))
            .collect();

        chromos[i].1 = create_initial_popu(work_num, job_num);

        let mut assembly_vec: Vec<usize> = (1..=assembly_num).collect();
        assembly_vec.shuffle(&mut rand::thread_rng());
        chromos[i].2 = assembly_vec;
    }

    chromos
}

fn create_initial_popu(mach_num: usize, workpiece_num: usize) -> Vec<usize> {
    let length_chromo = mach_num * workpiece_num;
    let mut initial_popu: Vec<usize> = (1..=workpiece_num)
        .flat_map(|x| vec![x; mach_num])
        .collect();
    // println!("initial_popu: {:?}", initial_popu);
    initial_popu.shuffle(&mut rand::thread_rng());
    // println!("initial_popu_shuffle: {:?}", initial_popu);
    initial_popu
}

//-------------计算适应度----------------
fn calc_fitness(chromos: &Vec<(Vec<usize>, Vec<usize>, Vec<usize>)>, data: &Data) -> Vec<i32> {
    let size_chromos = chromos.len();

    let mut fitness: Vec<i32> = Vec::new();

    // 遍历 chromos 向量中的每个元素，直到倒数第二个元素
    for chromo in chromos.iter().take(size_chromos - 1) {
        // 为当前 chromo 创建一个调度表
        let schedule = create_schedule(chromo, &data);
        // println!("{:?}", schedule);
        // 找到调度表中第五列的最大值
        let max_value = schedule.iter().map(|row| row[4]).max().unwrap();

        // 将最大值添加到 fitness 向量中
        fitness.push(max_value);
    }
    fitness
}
//-------------计算适应度，多线程版----------------
fn calc_fitness_thread(
    chromos: &Vec<(Vec<usize>, Vec<usize>, Vec<usize>)>,
    data: &Data,
) -> Vec<i32> {
    let size_chromos = chromos.len();
    let mut fitness: Vec<i32> = Vec::with_capacity(size_chromos - 1);

    scope(|s| {
        let mut handles = vec![];

        for chromo in chromos.iter().take(size_chromos - 1) {
            let data = data.clone(); // 假设 Data 实现了 Clone trait
            let chromo = chromo.clone(); // 假设 chromo 元素实现了 Clone trait

            let handle = s.spawn(move |_| {
                let schedule = create_schedule(&chromo, &data);
                let max_value = schedule.iter().map(|row| row[4]).max().unwrap();
                max_value
            });

            handles.push(handle);
        }

        for handle in handles {
            fitness.push(handle.join().unwrap());
        }
    })
    .unwrap();

    fitness
}

//-------------生成调度----------------
fn create_schedule(chromo: &(Vec<usize>, Vec<usize>, Vec<usize>), data: &Data) -> Vec<Vec<i32>> {
    //使用半主动解码，所有工厂、机器号、工件号、工序号都是从1开始
    //schedule[i] = [工件号、工序号、机器号、工厂号、开工时间、完工时间]
    let factory_num = data.factory_num;
    let job_num = data.job_num;
    let work_num = data.work_num;
    let assembly = &data.assembly;
    let assembly_data = &data.assembly_data;
    let change_data = &data.change_data;
    let FS = &chromo.0;
    // println!("FS: {:?}", FS);
    let PS = &chromo.1;
    let AS = &chromo.2;

    let mut FSi: Vec<Vec<usize>> = vec![vec![]; factory_num];
    let mut PSi: Vec<Vec<usize>> = vec![vec![]; factory_num];
    let mut datai: Vec<Vec<Vec<i32>>> = vec![vec![vec![]]; factory_num];

    // 首先分割为数个JSP问题，分割工厂分配
    for i in 0..job_num {
        // println!("FSi[0]: {:?},FSi[1]: {:?}",FSi[0],FSi[1]);
        if (FS[i] - 1) < 0 || (FS[i] - 1) >= factory_num {
            println!(
                "ERROR!!!!!!!!! FS[{}] is {:?},FS={:?},chromo={:?}",
                i, FS[i], FS, &chromo
            );
        }
        FSi[FS[i] - 1].push(i + 1);
    }
    // 分割工序分配
    for i in 0..factory_num {
        PSi[i] = PS
            .iter()
            .filter(|&&ps| FSi[i].contains(&ps))
            .cloned()
            .collect();
    }
    // 分割数据

    for i in 0..factory_num {
        datai[i] = FSi[i]
            .iter()
            .map(|&index| change_data[index - 1].clone())
            .collect();
    }
    // 注意 datai的某一行的某个subdatai，他的第i行并不代表是工件i的数据！！！
    // 而是该工厂的FA中的第i个工件的数据！！！
    // MATLAB上的程序也有这个问题！！！2024年7月31日 明天看看

    // 现在PSi(i) & subdata(i)共同表示一个JSP问题，
    //但是，工件号是不连续的，现在要把他变成连续的，并且datai的第i行不一定代表工厂中第i个工件的数据！！！

    let mut schedule_withno_assembly: Vec<Vec<i32>> = Vec::new();

    for i in 0..factory_num {
        //开始安排工厂i
        let this_factory_job = &FSi[i];
        let this_factory_work = &PSi[i];
        let this_factory_data = &datai[i];

        //现在要将this_factory_job、this_factory_work和this_factory_data的数据一一对应起来
        let mut job_mapping = HashMap::new();
        let mut reverse_mapping = HashMap::new();
        for (new_index, &job) in this_factory_job.iter().enumerate() {
            job_mapping.insert(job, new_index + 1);
            reverse_mapping.insert(new_index + 1, job);
        }

        // 更新 this_factory_work
        let new_factory_work: Vec<_> = this_factory_work
            .iter()
            .map(|&work| *job_mapping.get(&work).unwrap())
            .collect();

        // 重新排列 this_factory_data
        let mut new_factory_data = vec![vec![]; this_factory_job.len()];
        for (old_index, &job) in this_factory_job.iter().enumerate() {
            let new_index = job_mapping[&job] - 1;
            new_factory_data[new_index] = this_factory_data[old_index].clone();
        }

        // 新的 job
        let new_job: Vec<_> = (1..=this_factory_job.len()).collect();

        // 使用反向映射找到原来的工件号
        let original_job: Vec<_> = new_job
            .iter()
            .map(|&new_index| reverse_mapping[&new_index])
            .collect();

        let this_factory_job_num = this_factory_job.len();
        let this_factory_mach_num: usize;

        if this_factory_job_num == 0 {
            this_factory_mach_num = 0;
        } else {
            this_factory_mach_num = this_factory_work.len() / this_factory_job_num;
        }

        let mut sub_schedule = creatScheduleSubFactory(
            new_factory_data,
            new_factory_work,
            this_factory_job_num,
            this_factory_mach_num,
        );

        // 将sub_schedule的工件号转换为原来的工件号
        for entry in &mut sub_schedule {
            entry[0] = reverse_mapping[&(entry[0] as usize)] as i32;
        }
        // 将工厂号、装配号、属性号添加到调度中
        //schedule=[1工件号 2工序号  3机器号 4开工时间 5完工时间 6工厂号 7装配号 8属性(0加工/1装配) 9-10预留]
        for row in &mut sub_schedule {
            row[5] = i as i32 + 1;
            // row[6] = AS[row[0] as usize] as i32;
            row[6] = assembly[(row[0] - 1) as usize] as i32;
            row[7] = 0;
        }

        schedule_withno_assembly.extend(sub_schedule);
    }
    //至此，得到没有装配的调度,现在来看装配工序
    // let mut schedule_only_assembly: Vec<Vec<Vec<i32>>> = vec![vec![-1; 8]; assembly_data.len()].iter().map(|_| vec![vec![0; 8]; 1]).collect();
    let mut schedule_only_assembly = vec![vec![-1; 8]; assembly_data.len()];
    let mut assembly_can_start_time = vec![0; assembly_data.len()];

    for i in 0..assembly_data.len() {
        //找到每个装配工序的可以开始的时间

        //先找到该装备工序对应的所有工序
        let same_assembly_work_schedule = schedule_withno_assembly
            .iter()
            .filter(|&x| x[6] == (i + 1) as i32)
            .collect::<Vec<_>>();
        assembly_can_start_time[i] = same_assembly_work_schedule
            .iter()
            .map(|x| x[4])
            .max()
            .unwrap();
    }
    //进行装配车间调度
    schedule_only_assembly = create_assembly_schedule(
        schedule_only_assembly,
        assembly_data,
        assembly_can_start_time,
    );
    // let schedule=schedule_withno_assembly.extend(schedule_only_assembly);
    schedule_withno_assembly.extend(schedule_only_assembly);
    let schedule = schedule_withno_assembly;
    schedule
}

//-------------使用单机调度贪心算法生成装配调度----------------
fn create_assembly_schedule(
    mut schedule_only_assembly: Vec<Vec<i32>>,
    assembly_data: &Vec<i32>,
    assembly_can_start_time: Vec<i32>,
) -> Vec<Vec<i32>> {
    let n = assembly_can_start_time.len();
    let mut current_time = 0;
    let mut schedule = vec![vec![0; 3]; n]; // 第一列: 工件号, 第二列: 开工时间, 第三列: 完工时间

    // 初始化未完成任务的集合
    let mut remaining_tasks: Vec<(usize, i32, i32)> = (0..n)
        .map(|i| (i, assembly_can_start_time[i], assembly_data[i]))
        .collect();

    // 按最早开工时间排序
    remaining_tasks.sort_by_key(|k| k.1);

    while !remaining_tasks.is_empty() {
        // 可用任务
        let available_tasks: Vec<_> = remaining_tasks
            .iter()
            .filter(|&&(_, start_time, _)| start_time <= current_time)
            .cloned()
            .collect();

        if available_tasks.is_empty() {
            // 当前时间内没有可开始的任务
            current_time = remaining_tasks[0].1;
            continue;
        }

        // 选择加工时间最短的任务
        let min_task = available_tasks
            .iter()
            .min_by_key(|&&(_, _, duration)| duration)
            .unwrap();
        let task_id = min_task.0;
        let start_time = current_time;
        let finish_time = current_time + min_task.2;

        // 记录任务完成时间
        schedule[task_id] = vec![task_id as i32, start_time, finish_time];

        // 更新当前时间
        current_time = finish_time;

        // 从未完成任务中移除已完成任务
        remaining_tasks.retain(|&(id, _, _)| id != task_id);
    }

    // 按任务号排序
    schedule.sort_by_key(|k| k[0]);

    // 更新 schedule_only_assembly
    for (i, task) in schedule.iter().enumerate() {
        schedule_only_assembly[i][3] = task[1];
        schedule_only_assembly[i][4] = task[2];
    }

    schedule_only_assembly
}

//-------------半主动生成子工厂调度----------------

fn creatScheduleSubFactory(
    change_data: Vec<Vec<i32>>,
    chromo: Vec<usize>,
    workpiece_num: usize,
    mach_num: usize,
) -> Vec<Vec<i32>> {
    let length_num = chromo.len();
    let mut schedule = vec![vec![0; 6]; length_num];
    let mut job_now_process = vec![0; workpiece_num];
    let mut job_now_can_start_time = vec![0; workpiece_num];
    let mut mach_can_start_time = vec![0; mach_num];

    for i in 0..length_num {
        let job_id = chromo[i];
        job_now_process[job_id - 1] += 1;
        let mach_id: usize = change_data[job_id - 1][2 * job_now_process[job_id - 1] - 2] as usize;
        let work_speed_time = change_data[job_id - 1][2 * job_now_process[job_id - 1] - 1];

        let job_can_start_time = job_now_can_start_time[job_id - 1];
        if mach_id - 1 < 0 || mach_id - 1 >= mach_num {
            println!("ERROR!!!!!!!!! mach_id-1 is 0,mach_id-1={:?}", mach_id - 1);
        }
        let this_mach_can_start_time = mach_can_start_time[mach_id - 1];
        let start_time = if job_can_start_time > this_mach_can_start_time {
            job_can_start_time
        } else {
            this_mach_can_start_time
        };

        // 已经完成插入，更新表单时间
        job_now_can_start_time[job_id - 1] = start_time + work_speed_time;
        mach_can_start_time[mach_id - 1] = start_time + work_speed_time;
        schedule[i] = vec![
            job_id as i32,
            job_now_process[job_id - 1] as i32,
            mach_id as i32,
            start_time as i32,
            (start_time + work_speed_time) as i32,
            0,
            0,
            0,
            0,
            0,
        ];
    }
    schedule
}
