#!/usr/bin/env bash

VAULT_ADDR=https://localhost:8200; export VAULT_ADDR
#use token to login to vault
#vault login -tls-skip-verify token=s.zzzzzzzzzzzzzzzzzzzzzzzzz

#SET VARIABLES
OLD_SECRET_PATH=secret/
NEW_SECRET_PATH=fra





array=()
array_TMP=()
array_FIN=()

get_list()
{
 DIR=$1
 list=`/u/app/teamcity/.local/bin/vault list -format=yaml -tls-skip-verify ${OLD_SECRET_PATH}/${DIR} | /usr/bin/cut -f2 -d" "`;
 echo $list

}


check_path ()
{

PATH=$1
if [[ "$PATH" == *\/ ]]; then
    echo $PATH "ended '\'."
    array_TMP+=($PATH)
else
    echo $PATH "NOT ended '\'."
    array_FIN+=($PATH)
fi


}


#MAIN

L1=`get_list`
for aa in $L1; do check_path "$aa" ; done

array=("${array_TMP[@]}")

echo "L1:" ${array[@]}

#cycle for full paths
while [ ${#array[@]} -gt 0 ]; do
	array_TMP=();
	for aa in ${array[@]}; do 
		L2=`get_list $aa`;
		for bb in $L2; do check_path "$aa/$bb";  done
	done

echo "L2:" ${array[@]}
echo "L2 TMP:" ${array[@]}
echo "L2 FIN:" ${array_FIN[@]}

array=("${array_TMP[@]}")
done
#END Cycle for full paths



#COPY secrets to NEW Engine.  Use parameter COPY in script
if [[ $1 == 'copy' ]];
 then 
 echo "!!!!COPY!!!!!";
  for nn in ${array_FIN[@]}; do 
   echo "copy secrets for $nn";
   /u/app/teamcity/.local/bin/vault kv get -format=json -field=data -tls-skip-verify ${OLD_SECRET_PATH}/${nn} | /u/app/teamcity/.local/bin/vault kv put -tls-skip-verify ${NEW_SECRET_PATH}/${nn} -;
  done
 else
 echo "NO COPY to new engine"
fi
