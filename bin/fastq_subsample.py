#! /usr/bin/env python3

import random
import sys
import gzip

def write_random_records(fqa, fqb, N):
    sample = fqa.split("_")[:-1]
    """get random headers without reading the whole thing into memory"""
    records = sum(1 for _ in gzip.open(fqa, 'rb')) // 4
    rand_records = sorted([random.randint(0, records - 1) for _ in range(N)])

    fha, fhb = gzip.open(fqa, 'rb'), gzip.open(fqb, 'rb')
    suba, subb = gzip.open(sample[0] + "_subset_R1.fastq.gz", "wb"), gzip.open(sample[0] + "_subset_R2.fastq.gz", "wb")
    rec_no = - 1
    for rr in rand_records:
        while rec_no < rr:
            rec_no += 1
            for i in range(4): fha.readline()
            for i in range(4): fhb.readline()
        for i in range(4):
            suba.write(fha.readline())
            subb.write(fhb.readline())
        rec_no += 1
    suba.close()
    subb.close()

if __name__ == "__main__":
    N = 100 if len(sys.argv) < 4 else int(sys.argv[3])
    write_random_records(sys.argv[1], sys.argv[2], N)