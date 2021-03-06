C $Header: /u/gcmpack/MITgcm/pkg/generic_advdiff/gad_dst3_adv_y.F,v 1.13 2011/03/29 15:47:19 jmc Exp $
C $Name:  $

#include "GAD_OPTIONS.h"

CBOP
C !ROUTINE: GAD_DST3_ADV_Y

C !INTERFACE: ==========================================================
      SUBROUTINE GAD_DST3_ADV_Y(
     I           bi,bj,k, calcCFL, deltaTloc,
     I           vTrans, vFld,
     I           maskLocS, tracer,
     O           vT,
     I           myThid )
C !DESCRIPTION:
C  Calculates the area integrated Meridional flux due to advection of a
C  tracer using 3rd-order Direct Space and Time (DST-3) Advection Scheme

C !USES: ===============================================================
      IMPLICIT NONE

C     == GLobal variables ==
#include "SIZE.h"
#ifdef OLD_DST3_FORMULATION
#include "EEPARAMS.h"
#include "PARAMS.h"
#endif
#include "GRID.h"
#include "GAD.h"

C     == Routine arguments ==
C !INPUT PARAMETERS: ===================================================
C  bi,bj             :: tile indices
C  k                 :: vertical level
C  calcCFL           :: =T: calculate CFL number ; =F: take vFld as CFL
C  deltaTloc         :: local time-step (s)
C  vTrans            :: meridional volume transport
C  vFld              :: meridional flow / CFL number
C  tracer            :: tracer field
C  myThid            :: thread number
      INTEGER bi,bj,k
      LOGICAL calcCFL
      _RL deltaTloc
      _RL vTrans(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL vFld  (1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RS maskLocS(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL tracer(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      INTEGER myThid

C !OUTPUT PARAMETERS: ==================================================
C  vT                :: meridional advective flux
      _RL vT    (1-OLx:sNx+OLx,1-OLy:sNy+OLy)

C     == Local variables ==
C !LOCAL VARIABLES: ====================================================
C  i,j               :: loop indices
C  vCFL              :: Courant-Friedrich-Levy number
      INTEGER i,j
      _RL Rjm,Rj,Rjp,vCFL,d0,d1
#ifdef OLD_DST3_FORMULATION
      _RL psiP,psiM,thetaP,thetaM
      _RL smallNo
c     _RL Rjjm,Rjjp

      IF (inAdMode) THEN
       smallNo = 1.0D-20
      ELSE
       smallNo = 1.0D-20
      ENDIF
#endif

      DO i=1-Olx,sNx+Olx
       vT(i,1-Oly)=0.
       vT(i,2-Oly)=0.
       vT(i,sNy+Oly)=0.
      ENDDO
      DO j=1-Oly+2,sNy+Oly-1
       DO i=1-Olx,sNx+Olx
        Rjp=(tracer(i,j+1)-tracer(i, j ))*maskLocS(i,j+1)
        Rj =(tracer(i, j )-tracer(i,j-1))*maskLocS(i, j )
        Rjm=(tracer(i,j-1)-tracer(i,j-2))*maskLocS(i,j-1)

        vCFL = vFld(i,j)
        IF ( calcCFL ) vCFL = ABS( vFld(i,j)*deltaTloc
     &                  *recip_dyC(i,j,bi,bj)*recip_deepFacC(k) )
        d0=(2.-vCFL)*(1.-vCFL)*oneSixth
        d1=(1.-vCFL*vCFL)*oneSixth
#ifdef OLD_DST3_FORMULATION
        IF ( ABS(Rj).LT.smallNo .OR.
     &       ABS(Rjm).LT.smallNo ) THEN
         thetaP=0.
         psiP=0.
        ELSE
         thetaP=(Rjm+smallNo)/(smallNo+Rj)
         psiP=d0+d1*thetaP
        ENDIF
        IF ( ABS(Rj).LT.smallNo .OR.
     &       ABS(Rjp).LT.smallNo ) THEN
         thetaM=0.
         psiM=0.
        ELSE
         thetaM=(Rjp+smallNo)/(smallNo+Rj)
         psiM=d0+d1*thetaM
        ENDIF
        vT(i,j)=
     &   0.5*(vTrans(i,j)+ABS(vTrans(i,j)))
     &      *( Tracer(i,j-1) + psiP*Rj )
     &  +0.5*(vTrans(i,j)-ABS(vTrans(i,j)))
     &      *( Tracer(i, j ) - psiM*Rj )
#else /* OLD_DST3_FORMULATION */
        vT(i,j)=
     &   0.5*(vTrans(i,j)+ABS(vTrans(i,j)))
     &      *( Tracer(i,j-1) + (d0*Rj+d1*Rjm) )
     &  +0.5*(vTrans(i,j)-ABS(vTrans(i,j)))
     &      *( Tracer(i, j ) - (d0*Rj+d1*Rjp) )
#endif /* OLD_DST3_FORMULATION */

       ENDDO
      ENDDO

      RETURN
      END
