use plotters::data;
mod load_data;

use load_data::change_data_function;

fn main() {
    // ------------系列----------
    let popu = 100;
    let max_iterate = 9999;
    let mut now_iterate = 0;
    let p_cross = 0.8;
    let mut p_mutate = 0.05;
    let p_elite = 0.1;
    let break_iterate = 10;
    let tube_length = 14;
    let tube_threshold = 100;
    // ------------系列----------

    //载入数据
    let data = change_data_function();
    println!("{:?}", data);

    //初始化种群
    // let mut chromos = init_population(data, popu);

    //开始迭代
    while now_iterate < max_iterate {
        now_iterate += 1;
    }
}

