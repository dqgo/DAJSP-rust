#![allow(warnings)]

use plotters::data;
use rand::seq::SliceRandom;
use rand::Rng;
use rayon::vec;
use std::collections::HashMap;
use std::io;
use std::time::{Duration, Instant};
#[derive(Debug)]

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
    let popu = 1_;
    let max_iterate = 1;
    let mut now_iterate = 0;
    let p_cross = 0.8;
    let mut p_mutate = 0.05;
    let p_elite = 0.1;
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
    //通过chromos[i]来访问第i个染色体，通过chromos[i].0来访问第i个染色体的工厂分配，通过chromos[i].1来访问第i个染色体的工序分配，通过chromos[i].2来访问第i个染色体的装配顺序

    //开始迭代
    while now_iterate < max_iterate {
        // 计算适应度
        let fitness = calc_fitness(&chromos, &data);

        now_iterate += 1;
        print!("迭代次数: {}/{}", now_iterate, max_iterate);
    }
    // 结束计时
    let duration = start.elapsed();
    println!("代码执行时间: {:#?}", duration);

    // 等待用户输入以保持窗口打开
    println!("按回车键退出...");
    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap();
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
// -------------生成数据----------------

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
    initial_popu.shuffle(&mut rand::thread_rng());
    initial_popu
}


//-------------计算适应度----------------
fn calc_fitness(chromos: &Vec<(Vec<usize>, Vec<usize>, Vec<usize>)>, data: &Data) -> Vec<i32> {
    let size_chromos = chromos.len();
    // let mut fitness: Vec<i32> = vec![0; size_chromos];
    let fitness: Vec<i32> = chromos
        .iter()
        .take(size_chromos - 1)
        .map(|chromo| {
            let schedule = create_schedule(chromo, &data);
            schedule.iter().map(|row| row[5]).max().unwrap()
        })
        .collect();
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
    let PS = &chromo.1;
    let AS = &chromo.2;

    let mut FSi: Vec<Vec<usize>> = vec![vec![]; factory_num];
    let mut PSi: Vec<Vec<usize>> = vec![vec![]; factory_num];
    let mut datai: Vec<Vec<Vec<i32>>> = vec![vec![vec![]]; factory_num];

    // 首先分割为数个JSP问题，分割工厂分配
    for i in 0..job_num {
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
        let this_factory_work_num = this_factory_work.len();
        let mut sub_schedule = creatScheduleSubFactory(new_factory_data, new_factory_work, this_factory_job_num, this_factory_work_num);

        // 将sub_schedule的工件号转换为原来的工件号
        for entry in &mut sub_schedule {
            entry[0] = reverse_mapping[&(entry[0] as usize)] as i32;
        }
        // 将工厂号、装配号、属性号添加到调度中
        //schedule=[1工件号 2工序号  3机器号 4开工时间 5完工时间 6工厂号 7装配号 8属性(0加工/1装配)]
        for row in &mut sub_schedule {
            row[5] = i as i32 + 1; 
            row[6] = AS[row[0] as usize] as i32;
            row[7] = 0;
        }

        schedule_withno_assembly.extend(sub_schedule);
    }
    //至此，得到没有装配的调度,现在来看装配工序
    // let mut schedule_only_assembly: Vec<Vec<Vec<i32>>> = vec![vec![-1; 8]; assembly_data.len()].iter().map(|_| vec![vec![0; 8]; 1]).collect();
    let mut schedule_only_assembly=vec![vec![-1;8];assembly_data.len()];
    let mut assembly_can_start_time = vec![0; assembly_data.len()];

    for i in 0.. assembly_data.len() {
        //找到每个装配工序的可以开始的时间

        //先找到该装备工序对应的所有工序
        let same_assembly_work_schedule= schedule_withno_assembly.iter().filter(|&x| x[6]==(i+1) as i32 ).collect::<Vec<_>>();
        assembly_can_start_time[i]=same_assembly_work_schedule.iter().map(|x| x[4]).max().unwrap();
    }
    //进行装配车间调度
    schedule_only_assembly=create_assembly_schedule(schedule_only_assembly,assembly_data,assembly_can_start_time);
    schedule=schedule_withno_assembly.extend(schedule_only_assembly);
    schedule
}


//-------------使用单机调度贪心算法生成装配调度----------------
fn create_assembly_schedule(
    mut schedule_only_assembly: Vec<Vec<i32>>,
    assembly_data: &Vec<i32>,
    assembly_can_start_time: Vec<i32>
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
        let min_task = available_tasks.iter().min_by_key(|&&(_, _, duration)| duration).unwrap();
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

fn creatScheduleSubFactory(change_data: Vec<Vec<i32>>, chromo: Vec<usize>, workpiece_num: usize, mach_num: usize) -> Vec<Vec<i32>> {
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
        let this_mach_can_start_time = mach_can_start_time[mach_id - 1];
        let start_time = if job_can_start_time > this_mach_can_start_time { job_can_start_time } else { this_mach_can_start_time };

        // 已经完成插入，更新表单时间
        job_now_can_start_time[job_id - 1] = start_time + work_speed_time;
        mach_can_start_time[mach_id - 1] = start_time + work_speed_time;
        schedule[i] = vec![job_id as i32, job_now_process[job_id - 1] as i32, mach_id as i32, start_time as i32, (start_time + work_speed_time) as i32, 0];
    }
    schedule
}



