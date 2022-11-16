use std::sync::atomic::{AtomicBool, AtomicUsize, Ordering};
use std::sync::Arc;
use std::thread;

use criterion::{black_box, criterion_group, criterion_main, BatchSize, BenchmarkId, Criterion};
use hytra::TrAdder;
use risingwave_pb::expr::expr_node::Type::Or;
use tokio::runtime::Runtime;

const THREAD_NUM: usize = 20;

fn bench_atomic_counter(c: &mut Criterion) {
    let counter = Arc::new(AtomicUsize::new(0));
    let stop = Arc::new(AtomicBool::new(false));
    for _ in 0..THREAD_NUM {
        let c = counter.clone();
        let s = stop.clone();
        thread::spawn(move || loop {
            for _ in 0..1000 {
                black_box(c.fetch_add(100, Ordering::SeqCst));
            }
            if s.load(Ordering::SeqCst) {
                break;
            }
        });
    }

    c.bench_function("Add atomic counter", |b| {
        b.iter(|| black_box(counter.fetch_add(100, Ordering::SeqCst)))
    });

    stop.store(true, Ordering::SeqCst);
}

fn bench_add_hytra(c: &mut Criterion) {
    let counter = Arc::new(TrAdder::new());
    let stop = Arc::new(AtomicBool::new(false));
    for _ in 0..THREAD_NUM {
        let c = counter.clone();
        let s = stop.clone();
        thread::spawn(move || loop {
            for _ in 0..1000 {
                c.inc(100);
            }
            if s.load(Ordering::SeqCst) {
                break;
            }
        });
    }

    c.bench_function("Add tradder", |b| b.iter(|| counter.inc(100)));

    stop.store(true, Ordering::SeqCst);
}

fn bench_get_hytra(c: &mut Criterion) {
    let counter = Arc::new(TrAdder::new());
    let stop = Arc::new(AtomicBool::new(false));
    for _ in 0..THREAD_NUM {
        let c = counter.clone();
        let s = stop.clone();
        thread::spawn(move || loop {
            for _ in 0..1000 {
                c.inc(100);
            }
            if s.load(Ordering::SeqCst) {
                break;
            }
        });
    }

    c.bench_function("Add tradder", |b| b.iter(|| black_box(counter.get())));

    stop.store(true, Ordering::SeqCst);
}

fn bench_add_usize(c: &mut Criterion) {
    c.bench_function("Add num", |b| {
        b.iter(|| {
            let mut a = 100usize;
            a += 1;
            black_box(a)
        })
    });
}

criterion_group!(
    benches,
    bench_atomic_counter,
    bench_add_hytra,
    bench_add_usize,
    bench_get_hytra
);
criterion_main!(benches);
