#!/bin/bash
#
# This script compiles MOM6 assuming no build directory
#
# Run from MOM6 base directory

mkdir -p build/gnu
echo > build/gnu/env
mkdir -p build/gnu/shared/repro/

(cd build/gnu/shared/repro/; rm -f path_names; \
        ../../../../src/mkmf/bin/list_paths ../../../../src/FMS; \
        ../../../../src/mkmf/bin/mkmf -t ../../../../src/mkmf/templates/linux-gnu.mk -p libfms.a -c "-Duse_libMPI -Duse_netCDF -DSPMD" path_names)

(cd build/gnu/shared/repro/; source ../../env; make NETCDF=3 REPRO=1 FC=mpif90 CC=mpicc libfms.a -j)

mkdir -p build/gnu/ocean_only/repro/

(cd build/gnu/ocean_only/repro/; rm -f path_names; \
        ../../../../src/mkmf/bin/list_paths ./ ../../../../src/MOM6/{config_src/dynamic,config_src/solo_driver,src/{*,*/*}}/ ; \
        ../../../../src/mkmf/bin/mkmf -t ../../../../src/mkmf/templates/linux-gnu.mk -o '-I../../shared/repro' -p 'MOM6 -L../../shared/repro -lfms' -c "-Duse_libMPI -Duse_netCDF -DSPMD" path_names)

(cd build/gnu/ocean_only/repro/; source ../../env; make NETCDF=3 REPRO=1 FC=mpif90 LD=mpif90 MOM6 -j)

