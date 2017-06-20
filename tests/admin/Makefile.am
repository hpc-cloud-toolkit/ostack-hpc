TESTS_ENVIRONMENT = BATS_NO_SUMMARY=1

TESTS = init.sh

#TESTS  += genders # cloud hpc, pdsh is not yet enabled

if SLURM_ENABLED
TESTS  += mrsh
endif
