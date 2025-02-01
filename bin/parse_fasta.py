import sys
f = open(sys.argv[1])
gene = sys.argv[2]
species = sys.argv[3]
seqs = []
deflines = []
seq = ""
fs = f.readlines()
for s in fs:
    s = s.strip()
    if s[0] == ">":
        deflines.append(s)
        if seq != "":
            seqs.append(seq)
            seq = ""
    else:
        seq += s
seqs.append(seq)
seq = ""

for i,defline in enumerate(deflines):
    if gene in defline and species in defline:
        print(f"{defline}\n{seqs[i]}")