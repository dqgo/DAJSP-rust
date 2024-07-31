#[derive(Debug)]
pub struct Data {
    change_data: Vec<Vec<i32>>,
    job_num: usize,
    work_num: usize,
    factory_num: usize,
    assembly: Vec<i32>,
    assembly_data: Vec<i32>,
}