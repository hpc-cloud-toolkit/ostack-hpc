AUTOMAKE_OPTIONS = foreign
ACLOCAL_AMFLAGS  = -I m4
AM_MAKEFLAGS     = --no-print-directory
SUBDIRS          =
TESTS            =

# Tests are broken up into those which require elevetated credentials
# versus those that run in normal userspace

if ROOT_ENABLED

if ADMIN_ENABLED
   TESTS   += admin/run
endif
if BOS_ENABLED
   TESTS   += bos/run
endif
if OOB_ENABLED
   TESTS   += oob/run
endif
if CLCK_ENABLED
   TESTS   += clck/run
endif
if LUSTRE_ENABLED
   TESTS   += lustre/run
endif
if SPACK_ENABLED
   TESTS   += admin/spack/run
endif

else # non root tests

if PACKAGING_ENABLED
   TESTS   += packaging/run
endif

if EASYBUILD_ENABLED
   TESTS   += dev-tools/easybuild/run
endif

if MODULES_ENABLED
   TESTS   += modules/run
endif

if USERENV_ENABLED
   TESTS   += user-env/run
endif

if ITAC_ENABLED
   TESTS   += perf-tools/intel-itac/run
endif

if ADVISOR_ENABLED
   TESTS   += perf-tools/intel-advisor/run
endif

#----------------------------------------------------------------------
# run HPC wrapper tests for embeded autotools project (e.g. those that
# have compiler and/or mpi dependencies)
#----------------------------------------------------------------------

if RMS_HARNESS_ENABLED
   TESTS += rms-harness/integration-tests/test_mpi_families
endif

if MINIFE_ENABLED
   TESTS += apps/miniFE/integration-tests/test_mpi_families
endif

if MINIDFT_ENABLED
   TESTS += apps/miniDFT/integration-tests/test_mpi_families
endif

if HPCG_ENABLED
   TESTS += apps/hpcg/run
endif

if PRK_ENABLED
   TESTS += apps/prk/integration-tests/test_mpi_families
endif

if COMPILERS_ENABLED
   TESTS += compilers/integration-tests/test_compiler_families
endif

if VALGRIND_ENABLED
   TESTS += dev-tools/valgrind/integration-tests/test_compiler_families
endif

if R_ENABLED
   TESTS += dev-tools/R-base/integration-tests/test_compiler_families
endif

if MPIP_ENABLED
   TESTS += perf-tools/mpiP/integration-tests/test_mpi_families
endif

if VTUNE_ENABLED
   TESTS += perf-tools/intel-vtune/integration-tests/test_mpi_families
endif

if FFTW_ENABLED
   TESTS += libs/fftw/integration-tests/test_mpi_families
endif

if ADIOS_ENABLED
   TESTS += libs/adios/integration-tests/test_mpi_families
endif

if BOOST_ENABLED
   TESTS += libs/boost/integration-tests/test_mpi_families
endif

if BOOST_MPI_ENABLED
   TESTS += libs/boost-mpi/integration-tests/test_mpi_families
endif

if GSL_ENABLED
   TESTS += libs/gsl/integration-tests/test_compiler_families
endif

if IMB_ENABLED
   TESTS += libs/imb/integration-tests/test_mpi_families
endif

if HDF5_ENABLED
   TESTS += libs/hdf5/integration-tests/test_compiler_families
endif

if PHDF5_ENABLED
   TESTS += libs/phdf5/integration-tests/test_mpi_families
endif

if HYPRE_ENABLED
   TESTS += libs/hypre/integration-tests/test_mpi_families
endif

if INSPECTOR_ENABLED
   TESTS += dev-tools/intel-inspector/integration-tests/test_compiler_families
endif

if METIS_ENABLED
   TESTS += libs/metis/integration-tests/test_compiler_families
endif

if MUMPS_ENABLED
   TESTS += libs/mumps/integration-tests/test_mpi_families
endif

if NETCDF_ENABLED
   TESTS += libs/netcdf/integration-tests/test_mpi_families
endif

#if OCR_ENABLED
#   TESTS += runtimes/ocr/integration-tests/test_compiler_families
#endif

if OPENBLAS_ENABLED
   TESTS += libs/openblas/integration-tests/test_compiler_families
endif

if OOM_ENABLED
   TESTS += user-env-oom/integration-tests/test_compiler_families
endif

if PAPI_ENABLED
   TESTS += perf-tools/papi/integration-tests/test_compiler_families
endif

if PETSC_ENABLED
   TESTS += libs/petsc/integration-tests/test_mpi_families
endif

if MPI_ENABLED
   TESTS += mpi/integration-tests/test_mpi_families
endif

if NUMPY_ENABLED
   TESTS += dev-tools/numpy/integration-tests/test_mpi_families
endif

if SCALAPACK_ENABLED
   TESTS += libs/scalapack/integration-tests/test_mpi_families
endif

if SCIPY_ENABLED
   TESTS += dev-tools/scipy/integration-tests/test_mpi_families
endif

if SUPERLU_ENABLED
   TESTS += libs/superlu/integration-tests/test_compiler_families
endif

if SUPERLU_DIST_ENABLED
   TESTS += libs/superlu_dist/integration-tests/test_mpi_families
endif

if TAU_ENABLED
   TESTS += perf-tools/tau/integration-tests/test_mpi_families
endif

if AUTOTOOLS_ENABLED
   TESTS += dev-tools/autotools/run
endif

if TBB_ENABLED
   TESTS += dev-tools/tbb/integration-tests/test_compiler_families
endif

if CILK_ENABLED
   TESTS += dev-tools/cilk/integration-tests/test_compiler_families
endif

if TRILINOS_ENABLED
   TESTS += libs/trilinos/integration-tests/test_mpi_families
endif

endif
