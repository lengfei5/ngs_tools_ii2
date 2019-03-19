#########################################
# download ngs raw data wiht URL links
# input: text file with url download links
# output: downloaed bam files in the current directory
# updated for ii2 and run a job for each file
#########################################
file_urls="$1";
nb_cores=1;
jobName='raw_download'
DIR_cwd=`pwd`;
dir_logs=$PWD/logs
mkdir -p $dir_logs

while read -r line; do
    #echo $line;
    url=`echo "$line" | tr '\t' '\n'|grep "http\|ftp"`
    #url=${url/gecko/gecko.imp.univie.ac.at}
    echo url is : $url
    if [ -n "$url" ]; then
	file=`basename $url`
  	ext="${file##*.}"
	if [ ! -e "$file" ]; then
	    #echo "here"
	    #echo $url
	    echo $file
	    #echo $ext
	    
	    script=${dir_logs}/${file}_${jobName}.sh
	    cat <<EOF > $script
#!/usr/bin/bash

#SBATCH --cpus-per-task=$nb_cores
#SBATCH --time=60
#SBATCH --mem=2000
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH -o ${dir_logs}/${file}.out
#SBATCH -e ${dir_logs}/${file}.err
#SBATCH --job-name $jobName

wget --retry-connrefused -t 0 -c --no-check-certificate --auth-no-challenge $url; 
touch $file; 
if [ '$ext' == 'gz' ]; then 
   gunzip $file; 
fi

EOF

	    cat $script;
	    sbatch $script
	    
	else
	    echo "$file -- downloaded !!!"
	fi
    fi
    
    break;
    
done < "$file_urls"
