#!/usr/bin/env python3

import os
import sys
import glob as gl
import argparse as ap
import itertools as it
import subprocess as sub
import multiprocessing as mul

def f(x, y, z, a, b):
	sub.call(["/home/galaxy/command_pipelines/pipeline_for_targeted_exons_using_GATK_from_MiSeq.sh", x, y, z, a, b])

def h(args):
	return(f(args[0], args[1], args[2], args[3], args[4]))

def setting():
	parser = ap.ArgumentParser(description = "Automatic analyzing exons.")
	parser.add_argument("-n", "--name", help = "Panel name")
	parser.add_argument("-t", "--target", help = "BED file for exons")
	parser.add_argument("-c", "--clinvar", help = "ClinVar file for IDs")
	parser.add_argument("-v", "--version", action = "version", 
			version = "2015-11", help = "Show version")
	a = parser.parse_args()

	if (a.clinvar == None or a.target == None or a.name == None):
		print("Please set panel name, target file and clinvar file!")
		sys.exit()

	return(a)

def main():
	a = os.popen("find . -name '*R1*fastq.gz' -print").readlines()
	b = os.popen("find . -name '*R2*fastq.gz' -print").readlines()
	z = setting()
	a.sort()
	b.sort()
	if (len(a) != len(b)):
		sys.exit()
	pool = mul.Pool(3)
	rel = pool.map(h, it.izip(a, b, it.repeat(z.name, len(a)), 
		it.repeat(z.target, len(a)), it.repeat(z.clinvar, len(a))))
	for i in gl.glob("*trimmed*"):
		sub.call(["rm", i])

if __name__ == "__main__":
	main()
