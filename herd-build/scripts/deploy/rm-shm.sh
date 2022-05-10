echo "Removing SHM key 24 (request region hugepages)"
ipcrm -M 24

echo "Removing SHM keys used by MICA"
for i in `seq 0 28`; do
	key=`expr 3185 + $i`
	ipcrm -M $key 2>/dev/null
	key=`expr 4185 + $i`
	ipcrm -M $key 2>/dev/null
done
