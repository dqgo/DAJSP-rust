#[allow(warnings)]
use plotters::data;
use rand::seq::SliceRandom;
use rand::Rng;
use rayon::vec;
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
    let popu = 2;
    let max_iterate = 9999;
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
//-------------生成初始解----------------

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
//-------------计算适应度----------------

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
        PSi[i] = PS.iter()
                   .filter(|&&ps| FSi[i].contains(&ps))
                   .cloned()
                   .collect();
    }
    // 分割数据
    // for i in 0..factory_num {
    //     let ps_row = &PSi[i];
    //     let mut data_row = Vec::new();
        
    //     for ps in ps_row {
    //         let mut job_data = Vec::new();
    //         for &job_index in ps {
    //             job_data.push(change_data[job_index - 1].clone());
    //         }
    //         data_row.push(job_data);
    //     }
        
    //     datai[i] = data_row;
    // }
    for i in 0..factory_num {
        datai[i] = FSi[i].iter()
                         .map(|&index| change_data[index - 1].clone())
                         .collect();
    }
    println!("{:?}", datai[0]);
    vec![vec![0; 6]; 10]
}
