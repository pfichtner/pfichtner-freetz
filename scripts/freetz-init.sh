
f="freetz-ng"
git clone https://github.com/Freetz-NG/${f}.git

# move not src dirs out of sight
cd ${f}

# visable from outside
[ ! -L images ] && ln -s ~/images .
# TODO config

# invisable from host but inside container
for d in build dl packages source toolchain ; do
  [ -L "${d}" ] && continue
  mkdir -p ~/.freetz-"${d}"
  ln -s ~/.freetz-"${d}" ./"${d}"
done
