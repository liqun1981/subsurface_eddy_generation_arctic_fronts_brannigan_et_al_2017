C $Header: /u/gcmpack/MITgcm/pkg/autodiff/active_file_ad.F,v 1.9 2008/08/02 23:16:58 jmc Exp $
C $Name:  $

#include "AUTODIFF_OPTIONS.h"

c     ==================================================================
c
c     active_files_ad.F: Routines to handle the I/O of the active file
c                        for the adjoint calculations. All files are
c                        direct access files.
c
c     Routines
c
c     o  adactive_read_xy         - Adjoint of active_read_xy
c     o  adactive_read_xyz        - Adjoint of active_read_xyz
c     o  adactive_write_xy        - Adjoint of active_write_xy
c     o  adactive_write_xyz       - Adjoint of active_write_xyz
c
c     o  adactive_read_xz         - Adjoint of active_read_xz
c     o  adactive_read_yz         - Adjoint of active_read_yz
c     o  adactive_write_xz        - Adjoint of active_write_xz
c     o  adactive_write_yz        - Adjoint of active_write_yz
c
c        changed: Christian Eckert eckert@mit.edu 24-Apr-2000
c                 - Added routines that do active writes on tiles
c                   instead of a whole thread.
c        changed: Patrick Heimbach heimbach@mit.edu 27-May-2000
c                 - changed suboutine argument list:
c                   dropped mycurrentiter, mycurrenttime
c        changed: heimbach@mit.edu 25-Mar-2002
c                 - added active file handling of xz-/yz-arrays
c
c     ==================================================================

CBOP
C     !ROUTINE: adactive_read_xy
C     !INTERFACE:
#ifdef AUTODIFF_TAMC_COMPATIBILITY
      subroutine adactive_read_xy(
     I                             active_var_file,
     I                             irec,
     I                             doglobalread,
     I                             lAdInit,
     I                             myiter,
     I                             mythid,
     I                             adactive_var
     &                           )
#else
      subroutine adactive_read_xy(
     I                             active_var_file,
     I                             adactive_var,
     I                             irec,
     I                             doglobalread,
     I                             lAdInit,
     I                             myiter,
     I                             mythid
     &                           )
#endif

C     !DESCRIPTION: \bv
c     ==================================================================
c     SUBROUTINE adactive_read_xy
c     ==================================================================
c     o Adjoint of active_read_xy.
c     started: Christian Eckert eckert@mit.edu 24-May-1999
c     ==================================================================
C     \ev

C     !USES:
      implicit none

c     == global variables ==
#include "EEPARAMS.h"
#include "SIZE.h"

C     !INPUT/OUTPUT PARAMETERS:
c     == routine arguments ==
c     active_var_file: filename
c     adactive_var:    array
c     irec:            record number
c     myIter:          number of optimization iteration (default: 0)
c     mythid:          thread number for this instance
c     doglobalread:    flag for global or local read/write
c                      (default: .false.)
c     lAdInit:         initialisation of corresponding adjoint
c                      variable and write to active file
      character*(*) active_var_file
      _RL     adactive_var(1-olx:snx+olx,1-oly:sny+oly,nsx,nsy)
      integer irec
      integer myiter,mythid
      logical doglobalread
      logical lAdInit

C     !LOCAL VARIABLES:
c     == local variables ==
      integer mynr
      integer il
      integer ilnblnk
      character*(2) adpref
      character*(80) fname

c     == functions ==
      external ilnblnk

c     == end of interface ==
CEOP

      mynr   = 1
      adpref = 'ad'
      write(fname(1:80),'(a)') ' '

      il     = ilnblnk(active_var_file)

      write(fname(1:2),'(a)') adpref
      write(fname(3:2+il),'(a)') active_var_file(1:il)

      call active_read_rl( fname, adactive_var,
     &                     doglobalread, lAdInit, irec, mynr,
     &                     REVERSE_SIMULATION, myiter, mythid )

      end

CBOP
C     !ROUTINE: adactive_read_xyz
C     !INTERFACE:
#ifdef AUTODIFF_TAMC_COMPATIBILITY
      subroutine adactive_read_xyz(
     I                              active_var_file,
     I                              irec,
     I                              doglobalread,
     I                              lAdInit,
     I                              myiter,
     I                              mythid,
     I                              adactive_var
     &                            )
#else
      subroutine adactive_read_xyz(
     I                              active_var_file,
     I                              adactive_var,
     I                              irec,
     I                              doglobalread,
     I                              lAdInit,
     I                              myiter,
     I                              mythid
     &                            )
#endif

C     !DESCRIPTION: \bv
c     ==================================================================
c     SUBROUTINE adactive_read_xyz
c     ==================================================================
c     o Adjoint of active_read_xyz.
c     started: Christian Eckert eckert@mit.edu 24-May-1999
c     ==================================================================
C     \ev

C     !USES:
      implicit none

c     == global variables ==
#include "EEPARAMS.h"
#include "SIZE.h"

c     == routine arguments ==
c     active_var_file: filename
c     adactive_var:    array
c     irec:            record number
c     myIter:          number of optimization iteration (default: 0)
c     mythid:          thread number for this instance
c     doglobalread:    flag for global or local read/write
c                      (default: .false.)
c     lAdInit:         initialisation of corresponding adjoint
c                      variable and write to active file
      character*(*) active_var_file
      _RL     adactive_var(1-olx:snx+olx,1-oly:sny+oly,nr,nsx,nsy)
      integer irec
      integer myiter,mythid
      logical doglobalread
      logical lAdInit

C     !LOCAL VARIABLES:
c     == local variables ==
      integer mynr
      integer il
      integer ilnblnk
      character*(2) adpref
      character*(80) fname

c     == functions ==
      external ilnblnk

c     == end of interface ==
CEOP

      mynr   = nr
      adpref = 'ad'
      write(fname(1:80),'(a)') ' '

      il     = ilnblnk(active_var_file)

      write(fname(1:2),'(a)') adpref
      write(fname(3:2+il),'(a)') active_var_file(1:il)

      call active_read_rl( fname, adactive_var,
     &                     doglobalread, lAdInit, irec, mynr,
     &                     REVERSE_SIMULATION, myiter, mythid )

      end

CBOP
C     !ROUTINE: adactive_read_xz
C     !INTERFACE:
#ifdef AUTODIFF_TAMC_COMPATIBILITY
      subroutine adactive_read_xz(
     I                              active_var_file,
     I                              irec,
     I                              doglobalread,
     I                              lAdInit,
     I                              myiter,
     I                              mythid,
     I                              adactive_var
     &                            )
#else
      subroutine adactive_read_xz(
     I                              active_var_file,
     I                              adactive_var,
     I                              irec,
     I                              doglobalread,
     I                              lAdInit,
     I                              myiter,
     I                              mythid
     &                            )
#endif

C     !DESCRIPTION: \bv
c     ==================================================================
c     SUBROUTINE adactive_read_xz
c     ==================================================================
c     o Adjoint of active_read_xz.
c     started: heimbach@mit.edu 05-Mar-2001
c     ==================================================================
C     \ev

C     !USES:
      implicit none

c     == global variables ==
#include "EEPARAMS.h"
#include "SIZE.h"

c     == routine arguments ==
c     active_var_file: filename
c     adactive_var:    array
c     irec:            record number
c     myIter:          number of optimization iteration (default: 0)
c     mythid:          thread number for this instance
c     doglobalread:    flag for global or local read/write
c                      (default: .false.)
c     lAdInit:         initialisation of corresponding adjoint
c                      variable and write to active file
      character*(*) active_var_file
      _RL     adactive_var(1-olx:snx+olx,nr,nsx,nsy)
      integer irec
      integer myiter,mythid
      logical doglobalread
      logical lAdInit

C     !LOCAL VARIABLES:
c     == local variables ==
      integer mynr
      integer il
      integer ilnblnk
      character*(2) adpref
      character*(80) fname

c     == functions ==
      external ilnblnk

c     == end of interface ==
CEOP

      mynr   = nr
      adpref = 'ad'
      write(fname(1:80),'(a)') ' '

      il     = ilnblnk(active_var_file)

      write(fname(1:2),'(a)') adpref
      write(fname(3:2+il),'(a)') active_var_file(1:il)

      call active_read_xz_rl( fname, adactive_var,
     &                     doglobalread, lAdInit, irec, mynr,
     &                     REVERSE_SIMULATION, myiter, mythid )

      end

CBOP
C     !ROUTINE: adactive_read_yz
C     !INTERFACE:
#ifdef AUTODIFF_TAMC_COMPATIBILITY
      subroutine adactive_read_yz(
     I                              active_var_file,
     I                              irec,
     I                              doglobalread,
     I                              lAdInit,
     I                              myiter,
     I                              mythid,
     I                              adactive_var
     &                            )
#else
      subroutine adactive_read_yz(
     I                              active_var_file,
     I                              adactive_var,
     I                              irec,
     I                              doglobalread,
     I                              lAdInit,
     I                              myiter,
     I                              mythid
     &                            )
#endif

C     !DESCRIPTION: \bv
c     ==================================================================
c     SUBROUTINE adactive_read_yz
c     ==================================================================
c     o Adjoint of active_read_yz.
c     started: heimbach@mit.edu 05-Mar-2001
c     ==================================================================
C     \ev

C     !USES:
      implicit none

c     == global variables ==
#include "EEPARAMS.h"
#include "SIZE.h"

c     == routine arguments ==
c     active_var_file: filename
c     adactive_var:    array
c     irec:            record number
c     myIter:          number of optimization iteration (default: 0)
c     mythid:          thread number for this instance
c     doglobalread:    flag for global or local read/write
c                      (default: .false.)
c     lAdInit:         initialisation of corresponding adjoint
c                      variable and write to active file
      character*(*) active_var_file
      _RL     adactive_var(1-oly:sny+oly,nr,nsx,nsy)
      integer irec
      integer myiter,mythid
      logical doglobalread
      logical lAdInit

C     !LOCAL VARIABLES:
c     == local variables ==
      integer mynr
      integer il
      integer ilnblnk
      character*(2) adpref
      character*(80) fname

c     == functions ==
      external ilnblnk

c     == end of interface ==
CEOP

      mynr   = nr
      adpref = 'ad'
      write(fname(1:80),'(a)') ' '

      il     = ilnblnk(active_var_file)

      write(fname(1:2),'(a)') adpref
      write(fname(3:2+il),'(a)') active_var_file(1:il)

      call active_read_yz_rl( fname, adactive_var,
     &                     doglobalread, lAdInit, irec, mynr,
     &                     REVERSE_SIMULATION, myiter, mythid )

      end

CBOP
C     !ROUTINE: adactive_read_xy
C     !INTERFACE:
#ifdef AUTODIFF_TAMC_COMPATIBILITY
      subroutine adactive_write_xy(
     I                              active_var_file,
     I                              irec,
     I                              myiter,
     I                              mythid,
     U                              adactive_var,
     I                              dummy
     &                            )
#else
      subroutine adactive_write_xy(
     I                              active_var_file,
     U                              adactive_var,
     I                              irec,
     I                              myiter,
     I                              mythid,
     I                              dummy
     &                            )
#endif


C     !DESCRIPTION: \bv
c     ==================================================================
c     SUBROUTINE adactive_write_xy
c     ==================================================================
c     o Adjoint of active_write_xy.
c     started: Christian Eckert eckert@mit.edu 24-May-1999
c     ==================================================================
C     \ev

C     !USES:
      implicit none

c     == global variables ==
#include "EEPARAMS.h"
#include "SIZE.h"

c     == routine arguments ==
c     active_var_file: filename
c     adactive_var:    array
c     irec:            record number
c     myIter:          number of optimization iteration (default: 0)
c     mythid:          thread number for this instance
      character*(*) active_var_file
      _RL     adactive_var(1-olx:snx+olx,1-oly:sny+oly,nsx,nsy)
      integer irec
      integer myiter,mythid
      _RL     dummy

C     !LOCAL VARIABLES:
c     == local variables ==
      integer mynr
      integer il
      integer ilnblnk
      character*(2) adpref
      character*(80) fname
      logical globalfile

c     == functions ==
      external ilnblnk

c     == end of interface ==
CEOP

      mynr   = 1
      adpref = 'ad'
      write(fname(1:80),'(a)') ' '

      il     = ilnblnk(active_var_file)

      write(fname(1:2),'(a)') adpref
      write(fname(3:2+il),'(a)') active_var_file(1:il)

      globalfile = .false.

      call active_write_rl( fname, adactive_var,
     &                      globalfile, irec, mynr,
     &                      REVERSE_SIMULATION, myiter, mythid )

      end

CBOP
C     !ROUTINE: adactive_read_xyz
C     !INTERFACE:
#ifdef AUTODIFF_TAMC_COMPATIBILITY
      subroutine adactive_write_xyz(
     I                               active_var_file,
     I                               irec,
     I                               myiter,
     I                               mythid,
     U                               adactive_var,
     I                               dummy
     &                             )
#else
      subroutine adactive_write_xyz(
     I                               active_var_file,
     U                               adactive_var,
     I                               irec,
     I                               myiter,
     I                               mythid,
     I                               dummy
     &                             )
#endif


C     !DESCRIPTION: \bv
c     ==================================================================
c     SUBROUTINE adactive_write_xyz
c     ==================================================================
c     o Adjoint of active_write_xyz.
c     started: Christian Eckert eckert@mit.edu 24-May-1999
c     ==================================================================
C     \ev

C     !USES:
      implicit none

c     == global variables ==
#include "EEPARAMS.h"
#include "SIZE.h"

c     == routine arguments ==
c     active_var_file: filename
c     adactive_var:    array
c     irec:            record number
c     myIter:          number of optimization iteration (default: 0)
c     mythid:          thread number for this instance
      character*(*) active_var_file
      _RL     adactive_var(1-olx:snx+olx,1-oly:sny+oly,nr,nsx,nsy)
      integer irec
      integer myiter,mythid
      _RL dummy

C     !LOCAL VARIABLES:
c     == local variables ==
      integer mynr
      integer il
      integer ilnblnk
      character*(2) adpref
      character*(80) fname
      logical globalfile

c     == functions ==
      external ilnblnk

c     == end of interface ==
CEOP

      mynr   = nr
      adpref = 'ad'
      write(fname(1:80),'(a)') ' '

      il     = ilnblnk(active_var_file)

      write(fname(1:2),'(a)') adpref
      write(fname(3:2+il),'(a)') active_var_file(1:il)

      globalfile = .false.

      call active_write_rl( fname, adactive_var,
     &                      globalfile, irec, mynr,
     &                      REVERSE_SIMULATION, myiter, mythid )

      end

CBOP
C     !ROUTINE: adactive_read_xz
C     !INTERFACE:
#ifdef AUTODIFF_TAMC_COMPATIBILITY
      subroutine adactive_write_xz(
     I                               active_var_file,
     I                               irec,
     I                               myiter,
     I                               mythid,
     U                               adactive_var,
     I                               dummy
     &                             )
#else
      subroutine adactive_write_xz(
     I                               active_var_file,
     U                               adactive_var,
     I                               irec,
     I                               myiter,
     I                               mythid,
     I                               dummy
     &                             )
#endif

C     !DESCRIPTION: \bv
c     ==================================================================
c     SUBROUTINE adactive_write_xz
c     ==================================================================
c     o Adjoint of active_write_xz.
c     started: heimbach@mit.edu 05-Mar-2001
c     ==================================================================
C     \ev

C     !USES:
      implicit none

c     == global variables ==
#include "EEPARAMS.h"
#include "SIZE.h"

c     == routine arguments ==
c     active_var_file: filename
c     adactive_var:    array
c     irec:            record number
c     myIter:          number of optimization iteration (default: 0)
c     mythid:          thread number for this instance
      character*(*) active_var_file
      _RL     adactive_var(1-olx:snx+olx,nr,nsx,nsy)
      integer irec
      integer myiter,mythid
      _RL dummy

C     !LOCAL VARIABLES:
c     == local variables ==
      integer mynr
      integer il
      integer ilnblnk
      character*(2) adpref
      character*(80) fname
      logical globalfile

c     == functions ==
      external ilnblnk

c     == end of interface ==
CEOP

      mynr   = nr
      adpref = 'ad'
      write(fname(1:80),'(a)') ' '

      il     = ilnblnk(active_var_file)

      write(fname(1:2),'(a)') adpref
      write(fname(3:2+il),'(a)') active_var_file(1:il)

      globalfile = .false.

      call active_write_xz_rl( fname, adactive_var,
     &                      globalfile, irec, mynr,
     &                      REVERSE_SIMULATION, myiter, mythid )

      end

CBOP
C     !ROUTINE: adactive_read_yz
C     !INTERFACE:
#ifdef AUTODIFF_TAMC_COMPATIBILITY
      subroutine adactive_write_yz(
     I                               active_var_file,
     I                               irec,
     I                               myiter,
     I                               mythid,
     U                               adactive_var,
     I                               dummy
     &                             )
#else
      subroutine adactive_write_yz(
     I                               active_var_file,
     U                               adactive_var,
     I                               irec,
     I                               myiter,
     I                               mythid,
     I                               dummy
     &                             )
#endif


C     !DESCRIPTION: \bv
c     ==================================================================
c     SUBROUTINE adactive_write_yz
c     ==================================================================
c     o Adjoint of active_write_yz.
c     started: heimbach@mit.edu 05-Mar-2001
c     ==================================================================
C     \ev

C     !USES:
      implicit none

c     == global variables ==
#include "EEPARAMS.h"
#include "SIZE.h"

c     == routine arguments ==
c     active_var_file: filename
c     adactive_var:    array
c     irec:            record number
c     myIter:          number of optimization iteration (default: 0)
c     mythid:          thread number for this instance
      character*(*) active_var_file
      _RL     adactive_var(1-oly:sny+oly,nr,nsx,nsy)
      integer irec
      integer myiter,mythid
      _RL dummy

C     !LOCAL VARIABLES:
c     == local variables ==
      integer mynr
      integer il
      integer ilnblnk
      character*(2) adpref
      character*(80) fname
      logical globalfile

c     == functions ==
      external ilnblnk

c     == end of interface ==
CEOP

      mynr   = nr
      adpref = 'ad'
      write(fname(1:80),'(a)') ' '

      il     = ilnblnk(active_var_file)

      write(fname(1:2),'(a)') adpref
      write(fname(3:2+il),'(a)') active_var_file(1:il)

      globalfile = .false.

      call active_write_yz_rl( fname, adactive_var,
     &                      globalfile, irec, mynr,
     &                      REVERSE_SIMULATION, myiter, mythid )

      end


