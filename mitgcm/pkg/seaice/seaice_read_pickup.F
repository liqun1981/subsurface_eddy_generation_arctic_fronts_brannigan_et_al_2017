C $Header: /u/gcmpack/MITgcm/pkg/seaice/seaice_read_pickup.F,v 1.12 2011/09/27 00:08:03 heimbach Exp $
C $Name:  $

#include "SEAICE_OPTIONS.h"

CBOP
C     !ROUTINE: SEAICE_READ_PICKUP
C     !INTERFACE:
      SUBROUTINE SEAICE_READ_PICKUP ( myThid )

C     !DESCRIPTION: \bv
C     *==========================================================*
C     | SUBROUTINE SEAICE_READ_PICKUP
C     | o Read in sea ice pickup file for restarting.
C     *==========================================================*
C     \ev

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
C     == Routine arguments ==
C     myThid :: My Thread Id. number
      INTEGER myThid

C     !LOCAL VARIABLES:
C     == Local variables ==
C     fp          :: pickup-file precision
C     fn          :: Temp. for building file name.
C     filePrec    :: pickup-file precision (read from meta file)
C     nbFields    :: number of fields in pickup file (read from meta file)
C     missFldList :: List of missing fields   (attempted to read but not found)
C     missFldDim  :: Dimension of missing fields list array: missFldList
C     nMissing    :: Number of missing fields (attempted to read but not found)
C     nj          :: record & field number
C     ioUnit      :: temp for writing msg unit
C     msgBuf      :: Informational/error message buffer
C     i,j,k       :: loop indices
C     bi,bj       :: tile indices
      INTEGER fp
      CHARACTER*(MAX_LEN_FNAM) fn
      INTEGER filePrec, nbFields
      INTEGER missFldDim, nMissing
      PARAMETER( missFldDim = 20 )
      CHARACTER*(8) missFldList(missFldDim)
      INTEGER nj, ioUnit
      CHARACTER*(MAX_LEN_MBUF) msgBuf
#if (defined (SEAICE_AGE) || defined (ALLOW_SITRACER))
      CHARACTER*(8) fldName
      INTEGER iTrac, kerr
#endif
CEOP

C--
      IF (pickupSuff .EQ. ' ') THEN
        WRITE(fn,'(A,I10.10)') 'pickup_seaice.',nIter0
      ELSE
        WRITE(fn,'(A,A10)') 'pickup_seaice.',pickupSuff
      ENDIF
      fp = precFloat64

C     Going to really do some IO. Make everyone except master thread wait.
      _BARRIER

c     IF ( seaice_pickup_read_mdsio ) THEN

C--    Read meta file (if exist) and prepare for reading Multi-Fields file
       CALL READ_MFLDS_SET(
     I                      fn,
     O                      nbFields, filePrec,
     I                      MULTDIM, nIter0, myThid )

       _BEGIN_MASTER( myThid )
       IF ( nbFields.GE.0 .AND. filePrec.NE.fp ) THEN
         WRITE(msgBuf,'(2A,I4)') 'SEAICE_READ_PICKUP: ',
     &    'pickup-file binary precision do not match !'
         CALL PRINT_ERROR( msgBuf, myThid )
         WRITE(msgBuf,'(A,2(A,I4))') 'SEAICE_READ_PICKUP: ',
     &    'file prec.=', filePrec, ' but expecting prec.=', fp
         CALL PRINT_ERROR( msgBuf, myThid )
         STOP 'ABNORMAL END: S/R SEAICE_READ_PICKUP (data-prec Pb)'
       ENDIF
       _END_MASTER( myThid )

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

       IF ( nbFields.LE.0 ) THEN
C-      No meta-file or old meta-file without List of Fields
        ioUnit = errorMessageUnit
        IF ( pickupStrictlyMatch ) THEN
          WRITE(msgBuf,'(4A)') 'SEAICE_READ_PICKUP: ',
     &      'no field-list found in meta-file',
     &      ' => cannot check for strict-matching'
          CALL PRINT_ERROR( msgBuf, myThid )
          WRITE(msgBuf,'(4A)') 'SEAICE_READ_PICKUP: ',
     &      'try with " pickupStrictlyMatch=.FALSE.,"',
     &      ' in file: "data", NameList: "PARM03"'
          CALL PRINT_MESSAGE( msgBuf, ioUnit, SQUEEZE_RIGHT, myThid )
          STOP 'ABNORMAL END: S/R SEAICE_READ_PICKUP'
        ELSE
          WRITE(msgBuf,'(4A)') 'WARNING >> SEAICE_READ_PICKUP: ',
     &      ' no field-list found'
          CALL PRINT_MESSAGE( msgBuf, ioUnit, SQUEEZE_RIGHT, myThid )
         IF ( nbFields.EQ.-1 ) THEN
C-      No meta-file
          WRITE(msgBuf,'(4A)') 'WARNING >> ',
     &      ' try to read pickup as currently written'
          CALL PRINT_MESSAGE( msgBuf, ioUnit, SQUEEZE_RIGHT, myThid )
         ELSE
C-      Old meta-file without List of Fields
          WRITE(msgBuf,'(4A)') 'WARNING >> ',
     &      ' try to read pickup as it used to be written'
          CALL PRINT_MESSAGE( msgBuf, ioUnit, SQUEEZE_RIGHT, myThid )
          WRITE(msgBuf,'(4A)') 'WARNING >> ',
     &      ' until checkpoint59j (2007 Nov 25)'
          CALL PRINT_MESSAGE( msgBuf, ioUnit, SQUEEZE_RIGHT, myThid )
         ENDIF
        ENDIF
       ENDIF

#ifdef SEAICE_AGE
       IF ( nbFields.GT.0 ) THEN
C--    ice age field has been re-named:
         CALL READ_MFLDS_RENAME( 'siAGE   ', 'siAGEt01', kerr, myThid )
         IF ( kerr.GE.2 ) THEN
          WRITE(msgBuf,'(2A,I4)') 'SEAICE_READ_PICKUP: ',
     &      'renaming siAGE -> siAGEt01 return error:', kerr
          CALL PRINT_ERROR( msgBuf, myThid )
          STOP 'ABNORMAL END: S/R SEAICE_READ_PICKUP'
         ENDIF
       ENDIF
#endif

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

C---   Old way to read seaice fields:
       IF ( nbFields.EQ.0 ) THEN

C--    Read ice model fields
        nj = 1
#ifdef SEAICE_MULTICATEGORY
        CALL READ_REC_3D_RL( fn,fp,MULTDIM, TICES, nj, nIter0, myThid )
        nj = nj + MULTDIM
#else
        CALL READ_REC_3D_RL( fn, fp, 1, TICE     , nj, nIter0, myThid )
        nj = nj + 1
#endif /* SEAICE_MULTICATEGORY */
c       CALL READ_REC_3D_RL( fn, fp, 1, YNEG     , nj, nIter0, myThid )
        nj = nj + 1
        CALL READ_REC_3D_RL( fn, fp, 1, HSNOW    , nj, nIter0, myThid )
        nj = nj + 1
        CALL READ_REC_3D_RL( fn, fp, 1, UICE    , nj, nIter0, myThid )
        nj = nj + 3
        CALL READ_REC_3D_RL( fn, fp, 1, VICE    , nj, nIter0, myThid )
        nj = nj + 3
        CALL READ_REC_3D_RL( fn, fp, 1, HEFF    , nj, nIter0, myThid )
        nj = nj + 3
        CALL READ_REC_3D_RL( fn, fp, 1, AREA    , nj, nIter0, myThid )
        nj = nj + 3
#if (defined(SEAICE_CGRID) && defined(SEAICE_ALLOW_EVP))
        IF ( SEAICEuseEVP .AND. SEAICEuseEVPpickup ) THEN
         CALL READ_REC_3D_RL(fn,fp,1,seaice_sigma1,nj, nIter0, myThid )
         nj = nj + 1
         CALL READ_REC_3D_RL(fn,fp,1,seaice_sigma2,nj, nIter0, myThid )
         nj = nj + 1
         CALL READ_REC_3D_RL(fn,fp,1,seaice_sigma12,nj,nIter0, myThid )
         nj = nj + 1
        ENDIF
#endif /* SEAICE_ALLOW_EVP */
#ifdef SEAICE_VARIABLE_SALINITY
        CALL READ_REC_3D_RL( fn, fp, 1, HSALT    , nj, nIter0, myThid )
        nj = nj + 1
#endif
#ifdef SEAICE_AGE
        CALL READ_REC_3D_RL( fn, fp, 1,
     &    IceAgeTr(1-Olx,1-Oly,1,1,1),
     &    nj, nIter0, myThid )
#endif

       ELSE
C---   New way to read model fields:
         nj = 0
C--    read Sea-Ice Thermodynamics State variables, starting with 3-D fields:
        IF ( .NOT.useThSIce ) THEN
#ifdef SEAICE_MULTICATEGORY
         CALL READ_MFLDS_3D_RL( 'siTICES ', TICES,
     &                                nj, fp, MULTDIM, nIter0, myThid )
         nj = nj*MULTDIM
         IF ( nj.EQ.0 ) THEN
         CALL READ_MFLDS_3D_RL( 'siTICE  ', TICE,
     &                                      nj, fp, 1, nIter0, myThid )
         ENDIF
#else /* SEAICE_MULTICATEGORY */
         CALL READ_MFLDS_3D_RL( 'siTICE  ', TICE,
     &                                      nj, fp, 1, nIter0, myThid )
         IF ( nj.EQ.0 ) THEN
         CALL READ_MFLDS_3D_RL( 'siTICES ', TICE,
     &                                      nj, fp, 1, nIter0, myThid )
         ENDIF
#endif /* SEAICE_MULTICATEGORY */
C--    continue with 2-D fields:
         CALL READ_MFLDS_3D_RL( 'siAREA  ', AREA,
     &                                      nj, fp, 1, nIter0, myThid )
         CALL READ_MFLDS_3D_RL( 'siHEFF  ', HEFF,
     &                                      nj, fp, 1, nIter0, myThid )
         CALL READ_MFLDS_3D_RL( 'siHSNOW ', HSNOW,
     &                                      nj, fp, 1, nIter0, myThid )
#ifdef SEAICE_VARIABLE_SALINITY
         CALL READ_MFLDS_3D_RL( 'siHSALT ', HSALT,
     &                                      nj, fp, 1, nIter0, myThid )
#endif
#ifdef SEAICE_AGE
         DO iTrac = 1, SEAICE_num
          WRITE(fldName,'(A6,I2.2)') 'siAGEt', iTrac
          CALL READ_MFLDS_3D_RL( fldName,
     &         IceAgeTr(1-Olx,1-Oly,1,1,iTrac),
     &         nj, fp, 1, nIter0, myThid )
          _EXCH_XY_RL(IceAgeTr(1-Olx,1-Oly,1,1,iTrac),myThid)
         ENDDO
#endif /* SEAICE_AGE */
#ifdef ALLOW_SITRACER
         DO iTrac = 1, SItrMaxNum
          WRITE(fldName,'(A6,I2.2)') 'siTrac', iTrac
          CALL READ_MFLDS_3D_RL( fldName,
     &         SItracer(1-Olx,1-Oly,1,1,iTrac),
     &         nj, fp, 1, nIter0, myThid )
          _EXCH_XY_RL(SItracer(1-Olx,1-Oly,1,1,iTrac),myThid)
         ENDDO
#endif /* ALLOW_SITRACER */

        ENDIF

C--    read Sea-Ice Dynamics variables (all 2-D fields):
         CALL READ_MFLDS_3D_RL( 'siUICE  ', UICE,
     &                                      nj, fp, 1, nIter0, myThid )
         CALL READ_MFLDS_3D_RL( 'siVICE  ', VICE,
     &                                      nj, fp, 1, nIter0, myThid )
#if (defined(SEAICE_CGRID) && defined(SEAICE_ALLOW_EVP))
        IF ( SEAICEuseEVP ) THEN
         CALL READ_MFLDS_3D_RL( 'siSigm1 ', seaice_sigma1,
     &                                      nj, fp, 1, nIter0, myThid )
         CALL READ_MFLDS_3D_RL( 'siSigm2 ', seaice_sigma2,
     &                                      nj, fp, 1, nIter0, myThid )
         CALL READ_MFLDS_3D_RL( 'siSigm12', seaice_sigma12,
     &                                      nj, fp, 1, nIter0, myThid )
        ENDIF
#endif /* SEAICE_CGRID & SEAICE_ALLOW_EVP */

C---   end: new way to read pickup file
       ENDIF

C--    Check for missing fields:
       nMissing = missFldDim
       CALL READ_MFLDS_CHECK(
     O                    missFldList,
     U                    nMissing,
     I                    nIter0, myThid )
       IF ( nMissing.GT.missFldDim ) THEN
         WRITE(msgBuf,'(2A,I4)') 'SEAICE_READ_PICKUP: ',
     &     'missing fields list has been truncated to', missFldDim
         CALL PRINT_ERROR( msgBuf, myThid )
         STOP 'ABNORMAL END: S/R SEAICE_READ_PICKUP (list-size Pb)'
       ENDIF
       CALL SEAICE_CHECK_PICKUP(
     I                    missFldList,
     I                    nMissing, nbFields,
     I                    nIter0, myThid )

C--   end: seaice_pickup_read_mdsio
c     ENDIF

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

C--    Update overlap regions
       CALL EXCH_UV_XY_RL( uIce, vIce,.TRUE.,myThid)
       _EXCH_XY_RL( HEFF, myThid )
       _EXCH_XY_RL( AREA, myThid )
#ifdef SEAICE_MULTICATEGORY
       CALL EXCH_3D_RL   ( TICES, MULTDIM, myThid )
#else
       _EXCH_XY_RL(TICE , myThid )
#endif /* SEAICE_MULTICATEGORY */
c      _EXCH_XY_RL(YNEG , myThid )
       _EXCH_XY_RL(HSNOW, myThid )
#if (defined(SEAICE_CGRID) && defined(SEAICE_ALLOW_EVP))
       IF ( SEAICEuseEVP ) THEN
          _EXCH_XY_RL(seaice_sigma1 , myThid )
          _EXCH_XY_RL(seaice_sigma2 , myThid )
          _EXCH_XY_RL(seaice_sigma12, myThid )
       ENDIF
#endif /* SEAICE_CGRID SEAICE_ALLOW_EVP */
#ifdef SEAICE_VARIABLE_SALINITY
       _EXCH_XY_RL(HSALT, myThid )
#endif

      RETURN
      END
