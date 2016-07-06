#!/bin/bash
#
# This script compiles MOM6 using either gfortran on ccrc175 or
# matht265. Or using mpifort on raijin.
#
# Run from MOM6 base directory

if echo "$HOSTNAME" | grep -q "raijin"; then

    # RAIJIN:
    mkdir -p build/intel
    echo > build/intel/env
    mkdir -p build/intel/shared/repro/
    mkdir -p build/intel/ocean_only/repro/

    module purge
    module load openmpi/1.8.4
    module load intel-fc
    module load intel-cc
    module load hdf5
    module load netcdf

    (cd build/intel/shared/repro/; rm -f path_names; \
     ../../../../src/mkmf/bin/list_paths ../../../../src/FMS; \
     ../../../../src/mkmf/bin/mkmf -t ../../../../src/mkmf/templates/raijin-intel.mk -p libfms.a -c "-Duse_libMPI -Duse_netCDF -DSPMD" path_names)

    (cd build/intel/shared/repro/; source ../../env; make NETCDF=4 REPRO=1 libfms.a -j)

    (cd build/intel/ocean_only/repro/; rm -f path_names; \
     ../../../../src/mkmf/bin/list_paths ./ ../../../../src/MOM6/{config_src/dynamic,config_src/solo_driver,src/{*,*/*}}/ ; \
     ../../../../src/mkmf/bin/mkmf -t ../../../../src/mkmf/templates/raijin-intel.mk -o '-I../../shared/repro' -p 'MOM6 -L../../shared/repro -lfms' -c "-Duse_libMPI -Duse_netCDF -DSPMD" path_names)

    (cd build/intel/ocean_only/repro/; source ../../env; make NETCDF=4 REPRO=1 MOM6 -j)

else
    # CCRC175 and MATHT265:
    mkdir -p build/gnu
    echo > build/gnu/env
    mkdir -p build/gnu/shared/repro/
    mkdir -p build/gnu/ocean_only/repro/

    (cd build/gnu/shared/repro/; rm -f path_names; \
     ../../../../src/mkmf/bin/list_paths ../../../../src/FMS; \
     ../../../../src/mkmf/bin/mkmf -t ../../../../src/mkmf/templates/linux-gnu.mk -p libfms.a -c "-Duse_libMPI -Duse_netCDF -DSPMD" path_names)

    (cd build/gnu/shared/repro/; source ../../env; make NETCDF=3 REPRO=1 FC=mpif90 CC=mpicc libfms.a -j)
    
    (cd build/gnu/ocean_only/repro/; rm -f path_names; \
     ../../../../src/mkmf/bin/list_paths ./ ../../../../src/MOM6/{config_src/dynamic,config_src/solo_driver,src/{*,*/*}}/ ; \
     ../../../../src/mkmf/bin/mkmf -t ../../../../src/mkmf/templates/linux-gnu.mk -o '-I../../shared/repro' -p 'MOM6 -L../../shared/repro -lfms' -c "-Duse_libMPI -Duse_netCDF -DSPMD" path_names)

    (cd build/gnu/ocean_only/repro/; source ../../env; make NETCDF=3 REPRO=1 FC=mpif90 LD=mpif90 MOM6 -j)
fi

