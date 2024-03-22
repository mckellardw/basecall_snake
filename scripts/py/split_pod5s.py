import os
import sys

chunksize = sys.argv[0]
indirs = sys.argv[1:]

for indir in indirs:
  chunk_index = 1
  pod5_files = os.listdir(indir)
  while len(pod5_files) > chunksize:
    chunkdir = f'{indir}/chunk_{chunk_index}'
    os.mkdir(chunkdir)
    for pod5_file in pod5_files[0:10]:
      os.rename(pod5_file, f'{chunkdir}/{pod5_file}')
    chunk_index += 1

  