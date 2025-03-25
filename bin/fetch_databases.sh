#!/usr/bin/env bash
# Written by Gisela Gabernet and released under the MIT license (2020).
echo "Fetching databases..."

bash fetch_imgt.sh -o imgtdb_base
#wget https://github.com/Argentys/airrflow/raw/refs/heads/master/aux/imgtdb.tar.gz
#tar -xvzf imgtdb.tar.gz
#rm imgtdb.tar.gz

#fetch_igblastdb.sh -x -o igblast_base
wget https://github.com/Argentys/airrflow/raw/refs/heads/master/aux/igblast.tar.gz
tar -xvzf igblast.tar.gz 
rm igblast.tar.gz


#imgt2igblast.sh -i ./imgtdb_base -o igblast_base

echo "FetchDBs process finished. "
