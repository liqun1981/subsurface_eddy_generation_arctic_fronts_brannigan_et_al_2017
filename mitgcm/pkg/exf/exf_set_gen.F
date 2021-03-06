C $Header: /u/gcmpack/MITgcm/pkg/exf/exf_set_gen.F,v 1.28 2009/09/02 19:18:39 jmc Exp $
C $Name:  $

#include "EXF_OPTIONS.h"

      subroutine exf_set_gen(
     &     genfile, genstartdate, genperiod,
     &     exf_inscal_gen, genremove_intercept, genremove_slope,
     &     genfld, gen0, gen1, genmask,
#ifdef USE_EXF_INTERPOLATION
     &     gen_lon0, gen_lon_inc, gen_lat0, gen_lat_inc,
     &     gen_nlon, gen_nlat, gen_xout, gen_yout, interp_method,
#endif
     &     mytime, myiter, mythid )

c     ==================================================================
c     SUBROUTINE exf_set_gen
c     ==================================================================
c
c     o set external forcing gen
c
c     started: Ralf.Giering@FastOpt.de 25-Mai-2000
c     changed: heimbach@mit.edu 10-Jan-2002
c              20-Dec-2002: mods for pkg/seaice, menemenlis@jpl.nasa.gov
c              heimbach@mit.edu: totally re-organized exf_set_...
c              replaced all routines by one generic routine
c              5-Aug-2003: added USE_EXF_INTERPOLATION for arbitrary
c                          input grid capability
c     11-Dec-2006 added time-mean and monthly-mean climatology options
c        genperiod=0 means input file is one time-constant field
c        genperiod=-12 means input file contains 12 monthly means

c     ==================================================================
c     SUBROUTINE exf_set_gen
c     ==================================================================

      implicit none

c     == global variables ==

#include "EEPARAMS.h"
#include "SIZE.h"
#include "PARAMS.h"
#include "GRID.h"

#include "EXF_PARAM.h"
#include "EXF_CONSTANTS.h"

c     == routine arguments ==

      _RL genstartdate, genperiod
      _RL exf_inscal_gen
      _RL genremove_intercept, genremove_slope
      _RL genfld(1-olx:snx+olx,1-oly:sny+oly,nsx,nsy)
      _RL gen0  (1-olx:snx+olx,1-oly:sny+oly,nsx,nsy)
      _RL gen1  (1-olx:snx+olx,1-oly:sny+oly,nsx,nsy)
      character*1 genmask
      character*(128) genfile
      _RL     mytime
      integer myiter
      integer mythid

#ifdef USE_EXF_INTERPOLATION
c     gen_lon_0 ,gen_lat_0 :: longitude and latitude of SouthWest
c                             corner of global input grid
c     gen_nlon, gen_nlat   :: input x-grid and y-grid size
c     gen_lon_inc          :: scalar x-grid increment
c     gen_lat_inc          :: vector y-grid increments
c     gen_xout, gen_yout   :: coordinates for output grid
      _RL gen_lon0, gen_lon_inc
      _RL gen_lat0, gen_lat_inc(MAX_LAT_INC)
      INTEGER gen_nlon, gen_nlat
      _RS gen_xout  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS gen_yout  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      integer interp_method
#endif /* USE_EXF_INTERPOLATION */

c     == local variables ==

      logical first, changed
      integer count0, count1
      integer year0, year1
      integer bi, bj, i, j
      _RL     fac
      character*(128) genfile0, genfile1

c     == external ==

      integer  ilnblnk
      external ilnblnk

c     == end of interface ==

      if ( genfile .NE. ' ' .and. genperiod .ne. 0 ) then

cph(
cph-exf-print         if (genfile .EQ. hfluxfile)  year0 = 3000
cph)

         if ( genperiod .eq. -12 ) then
c     genperiod=-12 means input file contains 12 monthly means
c     record numbers are assumed 1 to 12 corresponding to
c     Jan. through Dec.
            call cal_GetMonthsRec(
     O           fac, first, changed,
     O           count0, count1,
     I           mytime, myiter, mythid
     &           )

         elseif ( genperiod .lt. 0 ) then
            print *, 'genperiod is out of range'
            STOP 'ABNORMAL END: S/R EXF_SET_GEN'

         else
c     get record numbers and interpolation factor for gen
            call exf_GetFFieldRec(
     I           genstartdate, genperiod
     I           , useExfYearlyFields
     O           , fac, first, changed
     O           , count0, count1, year0, year1
     I           , mytime, myiter, mythid
     &           )

         endif

         if ( first ) then
            call exf_GetYearlyFieldName(
     I         useExfYearlyFields, twoDigitYear, genperiod, year0,
     I         genfile,
     O         genfile0,
     I         mytime, myiter, mythid )

#ifdef USE_EXF_INTERPOLATION
            call exf_interp( genfile0, exf_iprec
     &           , gen1, count0, gen_xout, gen_yout
     &           , gen_lon0,gen_lon_inc
     &           , gen_lat0,gen_lat_inc
     &           , gen_nlon,gen_nlat,interp_method,mythid
     &           )
#else
            IF (exf_yftype .EQ. 'RL') THEN
              CALL READ_REC_3D_RL( genfile0, exf_iprec, 1,
     &                             gen1, count0, myIter, myThid )
            ELSE
c             CALL READ_REC_3D_RS( genfile0, exf_iprec, 1,
c    &                             gen1, count0, myIter, myThid )
              STOP 'S/R EXF_SET_GEN: invalid exf_yftype'
            ENDIF
#endif /* USE_EXF_INTERPOLATION */

            if (exf_yftype .eq. 'RL') then
               call exf_filter_rl( gen1, genmask, mythid )
c           else
c              call exf_filter_rs( gen1, genmask, mythid )
            end if
         endif

         if (( first ) .or. ( changed )) then
            call exf_SwapFFields( gen0, gen1, mythid )

            call exf_GetYearlyFieldName(
     I         useExfYearlyFields, twoDigitYear, genperiod, year1,
     I         genfile,
     O         genfile1,
     I         mytime, myiter, mythid )

#ifdef USE_EXF_INTERPOLATION
            call exf_interp( genfile1, exf_iprec
     &           , gen1, count1, gen_xout, gen_yout
     &           , gen_lon0,gen_lon_inc
     &           , gen_lat0,gen_lat_inc
     &           , gen_nlon,gen_nlat,interp_method,mythid
     &           )
#else
            IF (exf_yftype .EQ. 'RL') THEN
              CALL READ_REC_3D_RL( genfile1, exf_iprec, 1,
     &                             gen1, count1, myIter, myThid )
            ELSE
c             CALL READ_REC_3D_RS( genfile1, exf_iprec, 1,
c    &                             gen1, count1, myIter, myThid )
              STOP 'S/R EXF_SET_GEN: invalid exf_yftype'
            ENDIF
#endif /* USE_EXF_INTERPOLATION */

            if (exf_yftype .eq. 'RL') then
               call exf_filter_rl( gen1, genmask, mythid )
c           else
c              call exf_filter_rs( gen1, genmask, mythid )
            end if
         endif

c     Loop over tiles.
         do bj = mybylo(mythid),mybyhi(mythid)
          do bi = mybxlo(mythid),mybxhi(mythid)
           do j = 1,sny
            do i = 1,snx
c     Interpolate linearly onto the  time.
             genfld(i,j,bi,bj) = exf_inscal_gen * (
     &                          fac * gen0(i,j,bi,bj) +
     &              (exf_one - fac) * gen1(i,j,bi,bj) )
             genfld(i,j,bi,bj) =
     &            genfld(i,j,bi,bj) -
     &            exf_inscal_gen * ( genremove_intercept +
     &            genremove_slope*(mytime-starttime) )
            enddo
           enddo
          enddo
         enddo

      endif

      RETURN
      END

C+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      subroutine exf_init_gen (
     &     genfile, genperiod, exf_inscal_gen, genmask,
     &     genconst, genfld, gen0, gen1,
#ifdef USE_EXF_INTERPOLATION
     &     gen_lon0, gen_lon_inc, gen_lat0, gen_lat_inc,
     &     gen_nlon, gen_nlat, gen_xout, gen_yout, interp_method,
#endif
     &     mythid )


c     ==================================================================
c     SUBROUTINE exf_init_gen
c     ==================================================================
c
c     o
c
c     started: Ralf.Giering@FastOpt.de 25-Mai-2000
c     changed: heimbach@mit.edu 10-Jan-2002
c              heimbach@mit.edu: totally re-organized exf_set_...
c              replaced all routines by one generic routine
c
c     ==================================================================
c     SUBROUTINE exf_init_gen
c     ==================================================================

      implicit none

c     == global variables ==

#include "EEPARAMS.h"
#include "SIZE.h"

#include "EXF_PARAM.h"

c     == routine arguments ==

      _RL genperiod, exf_inscal_gen, genconst
      _RL genfld(1-olx:snx+olx,1-oly:sny+oly,nsx,nsy)
      _RL gen0  (1-olx:snx+olx,1-oly:sny+oly,nsx,nsy)
      _RL gen1  (1-olx:snx+olx,1-oly:sny+oly,nsx,nsy)
      character*1 genmask
      character*(128) genfile
      integer mythid

#ifdef USE_EXF_INTERPOLATION
c     gen_lon_0 ,gen_lat_0 :: longitude and latitude of SouthWest
c                             corner of global input grid
c     gen_nlon, gen_nlat   :: input x-grid and y-grid size
c     gen_lon_inc          :: scalar x-grid increment
c     gen_lat_inc          :: vector y-grid increments
c     gen_xout, gen_yout   :: coordinates for output grid
      _RL gen_lon0, gen_lon_inc
      _RL gen_lat0, gen_lat_inc(MAX_LAT_INC)
      INTEGER gen_nlon, gen_nlat
      _RS gen_xout  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS gen_yout  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      integer interp_method
#endif /* USE_EXF_INTERPOLATION */

c     == local variables ==

      integer bi, bj, i, j, count

c     == end of interface ==

      do bj = mybylo(mythid), mybyhi(mythid)
        do bi = mybxlo(mythid), mybxhi(mythid)
          do j = 1-oly, sny+oly
            do i = 1-olx, snx+olx
              genfld(i,j,bi,bj)  = genconst
              gen0(i,j,bi,bj)    = genconst
              gen1(i,j,bi,bj)    = genconst
            enddo
          enddo
        enddo
      enddo

      if ( genfile .NE. ' ' .and. genperiod .eq. 0. ) then
         count = 1

#ifdef USE_EXF_INTERPOLATION
         call exf_interp( genfile, exf_iprec
     &        , genfld, count, gen_xout, gen_yout
     &        , gen_lon0,gen_lon_inc
     &        , gen_lat0,gen_lat_inc
     &        , gen_nlon,gen_nlat,interp_method,mythid
     &        )
#else
         IF (exf_yftype .EQ. 'RL') THEN
            CALL READ_REC_3D_RL( genfile, exf_iprec, 1,
     &                             genfld, count, 0, myThid )
         ELSE
c           CALL READ_REC_3D_RS( genfile, exf_iprec, 1,
c    &                             genfld, count, 0, myThid )
            STOP 'S/R EXF_INIT_GEN: invalid exf_yftype'
         ENDIF
#endif /* USE_EXF_INTERPOLATION */

         if (exf_yftype .eq. 'RL') then
            call exf_filter_rl( genfld, genmask, mythid )
c        else
c           call exf_filter_rs( genfld, genmask, mythid )
         end if

c     Loop over tiles and scale genfld
         do bj = mybylo(mythid),mybyhi(mythid)
            do bi = mybxlo(mythid),mybxhi(mythid)
               do j = 1,sny
                  do i = 1,snx
                     genfld(i,j,bi,bj) =
     &                    exf_inscal_gen * genfld(i,j,bi,bj)
                  enddo
               enddo
            enddo
         enddo

      endif

      RETURN
      END
