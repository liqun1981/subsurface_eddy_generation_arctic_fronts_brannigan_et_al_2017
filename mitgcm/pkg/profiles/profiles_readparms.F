C $Header: /u/gcmpack/MITgcm/pkg/profiles/profiles_readparms.F,v 1.7 2011/05/20 22:23:53 gforget Exp $
C $Name:  $

#include "PROFILES_OPTIONS.h"

      subroutine profiles_readparms( mythid )

c     ==================================================================
c     SUBROUTINE profiles_readparms
c     ==================================================================
c
c     o This routine initialises the package cost.
c     started: Ralf Giering 18-Jan-2001
c
c     ==================================================================
c     SUBROUTINE profiles_readparms
c     ==================================================================

      implicit none

c     == global variables ==

#include "EEPARAMS.h"
#include "SIZE.h"
#include "GRID.h"
#include "PARAMS.h"

cph#include "ecco_cost.h"
#include "profiles.h"

c     == routine arguments ==

      integer mythid

c     == local variables ==
C     msgBuf      - Informational/error meesage buffer
C     iUnit       - Work variable for IO unit number
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER iUnit, num_file, num_var

c     == end of interface ==

c--   Read the namelist input.
      namelist /profiles_nml/
     &                   profilesDir,
     &                   profilesfiles,
     &                   mult_profiles

      _BEGIN_MASTER( myThid )

c--     Set default values.
        profilesDir=' '

        do num_file=1,NFILESPROFMAX
          profilesfiles(num_file)      =    ' '
        enddo

        do num_file=1,NFILESPROFMAX
         do num_var=1,NVARMAX
          mult_profiles(num_file,num_var) = 0. _d 0
         enddo
        enddo

      prof_names(1)='prof_T'
      prof_names(2)='prof_S'
      prof_names(3)='prof_U'
      prof_names(4)='prof_V'
      prof_names(5)='prof_ptr'
      prof_names(6)='prof_ssh'
      prof_namesmask(1)='prof_Tmask'
      prof_namesmask(2)='prof_Smask'
      prof_namesmask(3)='prof_Umask'
      prof_namesmask(4)='prof_Vmask'
      prof_namesmask(5)='prof_ptrmask'
      prof_namesmask(6)='prof_sshmask'
      prof_namesweight(1)='prof_Tweight'
      prof_namesweight(2)='prof_Sweight'
      prof_namesweight(3)='prof_Uweight'
      prof_namesweight(4)='prof_Vweight'
      prof_namesweight(5)='prof_ptrweight'
      prof_namesweight(6)='prof_sshweight'
      profilesfile_equi_type=2

      if (NVARMAX.GT.6) then
        WRITE(msgBuf,'(A)')
     & 'PROFILES_READPARMS: you need to define variables 7 to NVARMAX'
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , 1)
        stop
      endif

c--     Next, read the cost data file.
        WRITE(msgBuf,'(A)') 'PROFILES_READPARMS: opening data.profiles'
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , 1)

        CALL OPEN_COPY_DATA_FILE(
     I                          'data.profiles', 'PROFILES_READPARMS',
     O                          iUnit,
     I                          myThid )

        READ(  iUnit, nml = profiles_nml )

        WRITE(msgBuf,'(2A)') 'PROFILES_READPARMS: ',
     &       'finished reading data.profiles'
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                  SQUEEZE_RIGHT , 1)

        CLOSE( iUnit )

      _END_MASTER( mythid )

      _BARRIER

      end
