
        #! /bin/bash -e

        ##################### AMBER22 Setup ############################################
        source /usr/local/amber/amber22/amber.sh
        export CUDA_HOME="/usr/local/cuda"
        export CUDA_VISIBLE_DEVICES=0
        export LD_LIBRARY_PATH="/usr/local/amber/amber22/lib:/usr/local/cuda/lib64:$LD_LIBRARY_PATH"

        ./min.sh
        ./heat.sh
        ./eq.sh
        ./md.sh
