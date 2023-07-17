# Batch script to run a Matlab serial job under SGE.

# 1. Force bash as the executing shell.
#$ -S /bin/bash

# 2. Request hours of wallclock time (format hours:minutes:seconds).
#$ -l h_rt=72:0:0

# 3. Request 8 gigabytes of RAM.
#$ -l h_vmem=55G,tmem=55G

# 4. Set up the job array. In this instance we have requested 2000 tasks
# numbered 1 to 2000.
#$ -t 1:500

# 5. Set the name of the job.
#$ -N abcd_fair_modeA_pub_new

# 6. Have standard out and standard error merged into one file.
#$ -j y

# 7. Set the working directory. Use -cwd to set the current working directory or
#$ -cwd

# 8. Run the application.
/share/apps/matlabR2018b/bin/matlab -nodisplay -nodesktop -nosplash -singleCompThread -r  "abcdFinal" 
