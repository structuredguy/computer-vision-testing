;; ==========================================
;; THE CORE ENGINE (Pure Logic, No UI)
;; ==========================================
(defun DrawTrhoatFlight3D (ptOrigin tread riser stairWidth numSteps throatThickness 
                     landingThickness baseDepth / 
                     oldOs ptCurrent i pitchAngle perpAngle 
                     ptWaistTop ptWaistBottom 
                     ptTopBack ptTopFront ptBaseFront ptBaseBack myStairProfile my3DSolid)

  ;; 1. SAFEGUARD
  (setq oldOs (getvar "OSMODE"))
  (setvar "OSMODE" 0)

  ;; 2. DRAW THE JAGGED STEPS
  (command "_.PLINE" ptOrigin)
  (setq ptCurrent ptOrigin)
  (setq i 0)

  (while (< i numSteps)
    (setq ptCurrent (list (car ptCurrent) (+ (cadr ptCurrent) riser)))
    (command ptCurrent)
    (setq ptCurrent (list (+ (car ptCurrent) tread) (cadr ptCurrent)))
    (command ptCurrent)
    (setq i (1+ i))
  )

  ;; 3. CALCULATE THE PURE SLANTED WAIST VECTORS
  (setq pitchAngle (atan riser tread))
  (setq perpAngle (- pitchAngle (/ pi 2.0)))
  
  ;; We define the infinite slanted line using two points
  (setq ptWaistTop (polar ptCurrent perpAngle throatThickness))
  (setq ptWaistBottom (polar ptOrigin perpAngle throatThickness))

  ;; 4. CALCULATE THE TOP LANDING CONNECTION
  ;; Drop straight down from the top step by the landing thickness
  (setq ptTopBack (list (car ptCurrent) (- (cadr ptCurrent) landingThickness)))
  
  ;; Shoot a horizontal vector left to intersect the slanted waist line
  (setq ptTopFront (inters ptTopBack (list (- (car ptTopBack) 1) (cadr ptTopBack)) 
                           ptWaistTop ptWaistBottom nil))

  ;; 5. CALCULATE THE BOTTOM FOUNDATION (KICKER)
  ;; Drop straight down from the origin to create the vertical face
  (setq ptBaseFront (list (car ptOrigin) (- (cadr ptOrigin) baseDepth)))
  
  ;; Shoot a horizontal vector left to intersect the slanted waist line
  (setq ptBaseBack (inters ptBaseFront (list (- (car ptBaseFront) 1) (cadr ptBaseFront)) 
                           ptWaistTop ptWaistBottom nil))

  ;; 6. CLOSE THE PROFILE
  ;; Feed our beautifully calculated points into the PLINE command in order
  (command ptTopBack ptTopFront ptBaseBack ptBaseFront "C")

  ;; 7. EXTRUDE INTO 3D
  (setq myStairProfile (entlast))
  (command "_.EXTRUDE" myStairProfile "" (- stairWidth))

  ;; 8. STAND IT UP
  ;; Grab the newly created 3D Solid, not the deleted 2D Profile!
  (setq my3DSolid (entlast))
  (command "_.ROTATE3D" my3DSolid "" "_X" ptOrigin 90)
  
  ;; 9. CLEANUP
  (setvar "OSMODE" oldOs)
  (princ)
)

;; ==========================================
;; THE TEST WRAPPER
;; ==========================================
(defun c:TESTTHROATSTAIRS ()
  (princ "\nRunning test stair generation with foundation and landing cut...")
  
  ;; Arguments: Origin, Tread, Riser, Width, Steps, Throat, LandingThickness, BaseDepth
  ;; BaseDepth = 0.10 means the foundation drops 10cm below the floor line
  (DrawThroatFlight3D '(0.0 0.0 0.0) 0.30 0.17 0.90 7 0.15 0.17 0.10)
  
  (princ "\nGeometry generated successfully!")
  (princ)
)