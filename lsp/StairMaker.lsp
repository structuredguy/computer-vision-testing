;; ==========================================
;; THE CORE ENGINE (Pure Logic, No UI)
;; ==========================================
(defun DrawFlight3D (ptOrigin tread riser stairWidth numSteps throatThickness / 
                     oldOs ptCurrent i pitchAngle perpAngle 
                     ptSlabTop ptSlabBottom myStairProfile my3DSolid)

  ;; 1. SAFEGUARD: Save OSNAP and turn off
  (setq oldOs (getvar "OSMODE"))
  (setvar "OSMODE" 0)

  ;; 2. DRAW THE 2D PROFILE (The Zigzag)
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

  ;; 3. CALCULATE THE SLAB (Trigonometry)
  (setq pitchAngle (atan riser tread))
  (setq perpAngle (- pitchAngle (/ pi 2.0)))

  (setq ptSlabTop (polar ptCurrent perpAngle throatThickness))
  (setq ptSlabBottom (polar ptOrigin perpAngle throatThickness))

  ;; 4. CLOSE THE LOOP
  (command ptSlabTop ptSlabBottom "C")

  ;; 5. EXTRUDE INTO 3D
  (setq myStairProfile (entlast))
  (command "_.EXTRUDE" myStairProfile "" stairWidth)

  ;; -> THE FIX: Grab the brand-new 3D Solid from the database! <-
  (setq my3DSolid (entlast))

  ;; 6. STAND IT UP (Rotate 90 degrees around X)
  ;; Pass 'my3DSolid' instead of 'myStairProfile'
  (command "_.ROTATE3D" my3DSolid "" "_X" ptOrigin 90)
  
  ;; 7. CLEANUP: Restore OSNAP
  (setvar "OSMODE" oldOs)

  (princ) ; Exits cleanly returning nothing
)

;; ==========================================
;; THE WRAPPERS (The UI Commands)
;; ==========================================

;; The Test Wrapper: Instantly runs with hardcoded values
(defun c:TESTSTAIRS ()
  (princ "\nRunning test stair generation...")
  
  ;; Calling the core engine with your specific arguments
  (DrawFlight3D '(0.0 0.0 0.0) 0.30 0.17 0.90 6 0.15)
  
  (princ "\nTest successful!")
  (princ)
)