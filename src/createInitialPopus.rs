use rand::seq::SliceRandom;
use rand::Rng;

mod changeDataFunction;


pub fn create_initial_popus(popu: usize, data: &Data) -> Vec<(Vec<usize>, Vec<usize>, Vec<usize>)> {
    let mut chromos = vec![(vec![], vec![], vec![]); popu];
    let factory_num = data.factory_num;
    let job_num = data.job_num;
    let work_num = data.work_num;
    let assembly_num = *data.assembly.iter().max().unwrap() as usize;

    for i in 0..popu {
        chromos[i].0 = (0..job_num).map(|_| rand::thread_rng().gen_range(1..=factory_num)).collect();

        chromos[i].1 = create_initial_popu(work_num, job_num);

        let mut assembly_vec: Vec<usize> = (1..=assembly_num).collect();
        assembly_vec.shuffle(&mut rand::thread_rng());
        chromos[i].2 = assembly_vec;
    }

    chromos
}

fn create_initial_popu(mach_num: usize, workpiece_num: usize) -> Vec<usize> {
    let length_chromo = mach_num * workpiece_num;
    let mut initial_popu: Vec<usize> = (1..=workpiece_num).flat_map(|x| vec![x; mach_num]).collect();
    initial_popu.shuffle(&mut rand::thread_rng());
    initial_popu
}

