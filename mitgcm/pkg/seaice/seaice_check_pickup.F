C $Header: /u/gcmpack/MITgcm/pkg/seaice/seaice_check_pickup.F,v 1.5 2011/10/04 13:53:56 jmc Exp $
C $Name:  $

#include "SEAICE_OPTIONS.h"

CBOP
C     !ROUTINE: SEAICE_CHECK_PICKUP
C     !INTERFACE:
      SUBROUTINE SEAICE_CHECK_PICKUP(
     I                        missFldList,
     I                        nMissing, nbFields,
     I                        myIter, myThid )


C     !DESCRIPTION:
C     Check that fields that are needed to restart have been read.
C     In case some fields are missing, stop if pickupStrictlyMatch=T
C     or try, if possible, to restart without the missing field.

C     !USES:
      IMPLICIT NONE

C     == Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "SEAICE_SIZE.h"
#include "SEAICE_PARAMS.h"
#include "SEAICE.h"
#include "SEAICE_TRACER.h"

C     !INPUT/OUTPUT PARAMETERS:
C     missFldList :: List of missing fields   (attempted to read but not found)
C     nMissing    :: Number of missing fields (attempted to read but not found)
C     nbFields    :: number of fields in pickup file (read from meta file)
C     myIter      :: Iteration number
C     myThid      :: my Thread Id. number
      CHARACTER*(8) missFldList(*)
      INTEGER nMissing
      INTEGER nbFields
      INTEGER myIter
      INTEGER myThid
CEOP

C     !FUNCTIONS
      INTEGER  ILNBLNK
      EXTERNAL ILNBLNK

C     !LOCAL VARIABLES:
C     == Local variables ==
C     nj          :: record & field number
C     ioUnit      :: temp for writing msg unit
C     msgBuf      :: Informational/error message buffer
C     i,j,k       :: loop indices
C     bi,bj       :: tile indices
      INTEGER nj, ioUnit
      INTEGER tIceFlag, warnCnts
      LOGICAL stopFlag
c     LOGICAL oldIceAge
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      CHARACTER*(8) fldName
#if (defined SEAICE_MULTICATEGORY) || (defined SEAICE_AGE )
      INTEGER i,j,bi,bj
#endif
#ifdef SEAICE_MULTICATEGORY
      INTEGER k
#endif
#ifdef SEAICE_AGE
      INTEGER siTrac
      CHARACTER*(2) fldNum
#endif
CEOP

c     IF ( seaice_pickup_read_mdsio ) THEN

       IF ( nMissing.GE.1 ) THEN
        ioUnit = errorMessageUnit
        tIceFlag = 0
c       oldIceAge = .TRUE.
        DO nj=1,nMissing
         IF ( missFldList(nj).EQ.'siTICES ' ) tIceFlag = tIceFlag + 2
         IF ( missFldList(nj).EQ.'siTICE  ' ) tIceFlag = tIceFlag + 1
c        IF ( missFldList(nj).EQ.'siAGE   ' ) oldIceAge = .FALSE.
        ENDDO
        stopFlag = .FALSE.
        warnCnts = nMissing

        DO nj=1,nMissing
         fldName = missFldList(nj)
         IF     ( fldName.EQ.'siTICE  '
     &                      .AND. tIceFlag.LE.1 ) THEN
          IF ( .NOT.pickupStrictlyMatch ) THEN
           WRITE(msgBuf,'(4A)') '** WARNING ** SEAICE_CHECK_PICKUP:',
     &      ' restart with Tice from 1rst category'
           CALL PRINT_MESSAGE( msgBuf, ioUnit, SQUEEZE_RIGHT, myThid )
          ENDIF
         ELSEIF ( fldName.EQ.'siTICES '
     &                      .AND. tIceFlag.LE.2 ) THEN
#ifdef SEAICE_MULTICATEGORY
          IF ( .NOT.pickupStrictlyMatch ) THEN
           WRITE(msgBuf,'(4A)') '** WARNING ** SEAICE_CHECK_PICKUP:',
     &      ' restart from single category Tice (copied to TICES)'
           CALL PRINT_MESSAGE( msgBuf, ioUnit, SQUEEZE_RIGHT, myThid )
C      copy TICE -> TICES
           DO bj=myByLo(myThid),myByHi(myThid)
            DO bi=myBxLo(myThid),myBxHi(myThid)
             DO k=1,MULTDIM
              DO j=1-OLy,sNy+OLy
               DO i=1-OLx,sNx+OLx
                TICES(i,j,k,bi,bj) = TICE(i,j,bi,bj)
               ENDDO
              ENDDO
             ENDDO
            ENDDO
           ENDDO
          ENDIF
#endif
         ELSEIF ( fldName(1:6).EQ.'siSigm' ) THEN
C- Note: try to restart without Sigma1,2,12 (as if SEAICEuseEVPpickup=F)
C        An alternative would be to restart only if SEAICEuseEVPpickup=F:
C        if SEAICEuseEVPpickup then stop / else warning / endif
          IF ( .NOT.pickupStrictlyMatch ) THEN
           WRITE(msgBuf,'(4A)') '** WARNING ** SEAICE_CHECK_PICKUP:',
     &      ' restart without "',fldName,'" (set to zero)'
           CALL PRINT_MESSAGE( msgBuf, ioUnit, SQUEEZE_RIGHT, myThid )
          ENDIF
         ELSEIF ( fldName.EQ.'siTICES ' .OR.
     &            fldName.EQ.'siTICE  ' .OR.
     &            fldName.EQ.'siUICE  ' .OR.
     &            fldName.EQ.'siVICE  ' .OR.
     &            fldName.EQ.'siAREA  ' .OR.
     &            fldName.EQ.'siHEFF  ' .OR.
     &            fldName.EQ.'siHSNOW ' .OR.
     &            fldName.EQ.'siHSALT ' ) THEN
           stopFlag = .TRUE.
           WRITE(msgBuf,'(4A)') 'SEAICE_CHECK_PICKUP: ',
     &       'cannot restart without field "',fldName,'"'
           CALL PRINT_ERROR( msgBuf, myThid )
#ifdef SEAICE_AGE
         ELSEIF ( fldName.EQ.'siAGEt01' ) THEN
          IF ( .NOT.pickupStrictlyMatch ) THEN
           WRITE(msgBuf,'(4A)') '** WARNING ** SEAICE_CHECK_PICKUP:',
     &                  ' restart without "',fldName,'" (set to zero)'
           CALL PRINT_MESSAGE( msgBuf, ioUnit, SQUEEZE_RIGHT, myThid )
          ENDIF
         ELSEIF ( fldName(1:6).EQ.'siAGEt' ) THEN
           siTrac = 0
           DO i = 1, SEAICE_num
             WRITE(fldNum,'(I2.2)') i
             IF ( fldName(7:8).EQ.fldNum ) siTrac = i
           ENDDO
           IF ( siTrac.EQ.0 ) THEN
             stopFlag = .TRUE.
             WRITE(msgBuf,'(4A)') 'SEAICE_CHECK_PICKUP: ',
     &        'missing field "',fldName,'" not recognized'
             CALL PRINT_ERROR( msgBuf, myThid )
           ELSEIF ( .NOT.pickupStrictlyMatch ) THEN
             WRITE(msgBuf,'(2A,I3,A)')
     &        '** WARNING ** SEAICE_CHECK_PICKUP:',
     &        ' restart siTr=', siTrac,
     &        ' from IceAge (siTr=1 copied to IceAgeTr)'
             CALL PRINT_MESSAGE( msgBuf, ioUnit, SQUEEZE_RIGHT, myThid )
C      copy IceAgeTr(...,1) -> IceAgeTr(...,siTrac)
             DO bj=myByLo(myThid),myByHi(myThid)
              DO bi=myBxLo(myThid),myBxHi(myThid)
               DO j=1-OLy,sNy+OLy
                DO i=1-OLx,sNx+OLx
                 IceAgeTr(i,j,bi,bj,siTrac) = IceAgeTr(i,j,bi,bj,1)
                ENDDO
               ENDDO
              ENDDO
             ENDDO
           ENDIF
#endif /* SEAICE_AGE */
         ELSE
C-    not recognized fields:
           stopFlag = .TRUE.
           WRITE(msgBuf,'(4A)') 'SEAICE_CHECK_PICKUP: ',
     &       'missing field "',fldName,'" not recognized'
           CALL PRINT_ERROR( msgBuf, myThid )
         ENDIF
C-    end nj loop
        ENDDO

        IF ( stopFlag ) THEN
         STOP 'ABNORMAL END: S/R SEAICE_CHECK_PICKUP'
        ELSEIF ( pickupStrictlyMatch ) THEN
         WRITE(msgBuf,'(4A)') 'SEAICE_CHECK_PICKUP: ',
     &      'try with " pickupStrictlyMatch=.FALSE.,"',
     &      ' in file: "data", NameList: "PARM03"'
         CALL PRINT_ERROR( msgBuf, myThid )
         STOP 'ABNORMAL END: S/R SEAICE_CHECK_PICKUP'
        ELSEIF ( warnCnts .GT. 0 ) THEN
         WRITE(msgBuf,'(4A)') '** WARNING ** SEAICE_CHECK_PICKUP: ',
     &     'Will get only an approximated Restart'
         CALL PRINT_MESSAGE( msgBuf, ioUnit, SQUEEZE_RIGHT, myThid )
        ENDIF

       ENDIF

C--   end: seaice_pickup_read_mdsio
c     ENDIF

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

      RETURN
      END
