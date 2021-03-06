C $Header: /u/gcmpack/MITgcm/pkg/atm2d/atm2d_init_vars.F,v 1.7 2011/06/13 15:29:23 jscott Exp $
C $Name:  $

#include "ctrparam.h"
C
      SUBROUTINE ATM2D_INIT_VARS(myThid)
C     |==========================================================|
C     | Initialization steps which depend on pickups loading.    |
C     \==========================================================/
      IMPLICIT NONE

#include "ATMSIZE.h"
#include "DRIVER.h"

C     !INPUT/OUTPUT PARAMETERS:
C     == Routine arguments ==
C     myThid - thread number for this instance of the routine.
      INTEGER myThid

C     === Local variables ===
      INTEGER j

#ifdef PREDICTED_AEROSOL
      print *,' Before eppaemission'
      CALL eppaemission (0)
#endif
      CALL atmosphere(0,0)   ! initialize the atmospheric model

#ifdef CLM
      CALL clm4mit2d           ! initialize CLM
#endif

#ifdef ML_2D
C    2D mixed layer model  initialization
      CALL ocean_ml(dtocn*3600.,dtatm*3600.)
#  ifdef CPL_OCEANCO2
      CALL zerogary
#  endif
#endif

#ifdef CPL_TEM
      PRINT *,' Start of tem_init'
      aocuav=0.0
      nepav=0.0
#  ifdef DATA4TEM
      nfile=1
#  endif
#  ifdef CPL_NEM
C      PRINT *,' Reading climate data to run NEM during '
C      PRINT *, '  TEM iInitialization'
C      CALL rd_rstrt_nem
#  endif
c      call tem_init(inyear,lyear)
      CALL temclm_init
      CALL lcluc_init
      CALL updatelcluc(0)
      CALL tem_init
      adupt=0.0
      PRINT *,' TEM initialization finished'
#  ifdef CPL_NEM
C      CALL tem2climate(0,11)
C      PRINT *,'CH4'
C      PRINT *,(temch4(j),j=1,jm0)
C      PRINT *,'N2O'
C      PRINT *,(temn2o(j),j=1,jm0)
C      PRINT *,'CO2'
C      PRINT *,(temco2(j),j=1,jm0)
#  endif
#endif

#ifdef OCEAN_3D
      CALL ATM2D_READ_PICKUP(myThid)
#endif

      RETURN
      END
