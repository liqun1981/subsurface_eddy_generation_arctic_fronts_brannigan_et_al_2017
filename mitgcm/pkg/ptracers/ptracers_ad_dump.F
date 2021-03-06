C $Header: /u/gcmpack/MITgcm/pkg/ptracers/ptracers_ad_dump.F,v 1.2 2011/08/18 09:10:26 heimbach Exp $
C $Name:  $

#include "AD_CONFIG.h"
#include "PACKAGES_CONFIG.h"
#include "PTRACERS_OPTIONS.h"

CBOP
C     !ROUTINE: ptracers_ad_dump
C     !INTERFACE:
      subroutine ptracers_ad_dump( mytime, myiter, myThid )

C     !DESCRIPTION: \bv
C     *==========================================================*
C     | SUBROUTINE ptracers_ad_dump                           |
C     *==========================================================*
C     Extract adjoint variable from TAMC/TAF-generated
C     adjoint common blocks, contained in adcommon.h
C     and write fields to file;
C     Make sure common blocks in adcommon.h are up-to-date
C     w.r.t. current adjoint code.
C     *==========================================================*
C     | SUBROUTINE ptracers_ad_dump                           |
C     *==========================================================*
C     \ev

C     !USES:
      IMPLICIT NONE

C     == Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#ifdef ALLOW_MNC
#include "MNC_PARAMS.h"
#endif
#include "GRID.h"
#ifdef ALLOW_AUTODIFF_MONITOR
# include "ptracers_adcommon.h"
#endif

      LOGICAL  DIFFERENT_MULTIPLE
      EXTERNAL DIFFERENT_MULTIPLE
      INTEGER  IO_ERRCOUNT
      EXTERNAL IO_ERRCOUNT

C     !INPUT/OUTPUT PARAMETERS:
C     == Routine arguments ==
C     myIter - iteration counter for this thread
C     myTime - time counter for this thread
C     myThid - Thread number for this instance of the routine.
      integer myThid
      integer myiter
      _RL     mytime

#if (defined (ALLOW_ADJOINT_RUN) || defined (ALLOW_ADMTLM))
#ifdef ALLOW_AUTODIFF_MONITOR

C     !LOCAL VARIABLES:
c     == local variables ==
C     suff - Hold suffix part of a filename
C     beginIOErrCount - Begin and end IO error counts
C     endIOErrCount
C     msgBuf - Error message buffer
      INTEGER ip
      CHARACTER*(MAX_LEN_FNAM) suff1,suff2
      INTEGER beginIOErrCount
      INTEGER endIOErrCount
      CHARACTER*(MAX_LEN_MBUF) msgBuf

c     == end of interface ==
CEOP

      call TIMER_START('I/O (WRITE)        [ADJOINT LOOP]', myThid )

      IF (
     &  DIFFERENT_MULTIPLE(adjDumpFreq,mytime,deltaTClock)
     & ) THEN

C--     Set suffix for this set of data files.
        WRITE(suff1,'(I10.10)') myIter
        writeBinaryPrec = writeStatePrec

        DO ip = 1, PTRACERS_numInUse
         WRITE(suff2,'(A10,A2,A1)') 
     &          'ADJptracer',PTRACERS_ioLabel(ip),'.'

         CALL WRITE_FLD_XYZ_RL(
     &        suff2,suff1, 
     &        adptracer(1-OLx,1-OLy,1,1,1,ip), 1, myThid)

        ENDDO

C--     Read IO error counter
        beginIOErrCount = IO_ERRCOUNT(myThid)

      ENDIF

      CALL TIMER_STOP( 'I/O (WRITE)        [ADJOINT LOOP]', myThid )

#endif /* ALLOW_AUTODIFF_MONITOR */
#endif /* ALLOW_ADJOINT_RUN */

      RETURN
      END
