import sys

with open('image', 'wb') as f, open('os.bin', 'rb') as loader:
  f.write(loader.read())
  for i in sys.argv[1:]:
    i = (bytes(i, encoding="ascii") + bytes(1) * 32)[:32]
    f.write(i)
  f.write(bytes(1) * (512 - (len(sys.argv)- 1) * 32))
  for i in sys.argv[1:]:
    with open(i, 'rb') as a:
      data = a.read()
      f.write(data)
      f.write(bytes(1) * (5120 - len(data)))
