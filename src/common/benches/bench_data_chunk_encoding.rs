use criterion::{criterion_group, criterion_main, Criterion};
use risingwave_common::test_utils::rand_chunk;
use risingwave_common::types::DataType;

static SEED: u64 = 998244353u64;
static CHUNK_SIZES: &[usize] = &[128, 1024];
static NULL_RATIOS: &[f64] = &[0.0, 0.01, 0.1];

struct DataChunkBenchCase {
    pub name: String,
    pub data_types: Vec<DataType>,
}

impl DataChunkBenchCase {
    pub fn new(name: &str, data_types: Vec<DataType>) -> Self {
        Self {
            name: name.to_string(),
            data_types: data_types,
        }
    }
}

fn bench_data_chunk_encoding(c: &mut Criterion) {
    let test_cases = vec![
        DataChunkBenchCase::new("Int16", vec![DataType::Int16]),
        DataChunkBenchCase::new("Int16 and String", vec![DataType::Int16, DataType::Varchar]),
    ];
    for case in test_cases {
        for null_ratio in NULL_RATIOS {
            for chunk_size in CHUNK_SIZES {
                let id = format!(
                    "data chunk encoding: {}, {} rows, Pr[null]={}",
                    case.name, chunk_size, null_ratio
                );
                let chunk = rand_chunk::gen_chunk(&case.data_types, *chunk_size, SEED, *null_ratio);
                c.bench_function(&id, |b| b.iter(|| chunk.serialize()));
            }
        }
    }
}

// `cargo bench -- "vec ser[\s\S]*KeySerialized[\s\S]*null ratio 0$"` bench all the
// `KeySerialized` hash key vectorized serialize cases with data's null ratio is 0,001
criterion_group!(benches, bench_data_chunk_encoding);
criterion_main!(benches);
