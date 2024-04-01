setup.
fly postgres create
select Production (High Availability) - 3 nodes, 2x shared CPUs, 4GB RAM, 40GB disk

x regions 3 times
fly machine clone <machine ID> --region <region> --app <app name>

testing.
coonect locally
fly proxy 15432:5432 -a blue-cherry-6374

python3 test.py

./failover.sh
