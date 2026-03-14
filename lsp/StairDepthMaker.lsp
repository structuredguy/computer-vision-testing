;; ==========================================
;; 1. THE MAIN FLIGHT (Steps 2 to N)
;; ==========================================
(defun DrawFlight3D (ptOrigin tread riser stairWidth numSteps landingThickness / 
                     oldOs ptCurrent i vertDepth ptBaseBack ptTopBack ptTopFront myStairProfile my3DSolid)

  (setq oldOs (getvar "OSMODE"))
  (setvar "OSMODE" 0)

  ;; 1. Draw the jagged steps
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

  ;; 2. The User's Golden Ratio Underbelly
  ;; The vertical depth is simply equal to the riser height
  (setq vertDepth riser)

  ;; 3. Calculate Slab Profile Points
  ;; Top Landing Connection
  (setq ptTopBack (list (car ptCurrent) (- (cadr ptCurrent) landingThickness)))
  
  ;; Bottom Vertical Drop (Drop straight down from origin by exactly one riser)
  (setq ptBaseBack (list (car ptOrigin) (- (cadr ptOrigin) vertDepth)))

  ;; NEW: The "Dust Wedge" Filler (Extends horizontally by exactly one tread)
  (setq ptBaseFlat (list (+ (car ptBaseBack) tread) (cadr ptBaseBack)))
  
  ;; 4. Find the Top Front Intersection
  ;; The waistline is defined by ptBaseBack and the slope of one step (tread, riser)
  (setq ptTopFront (inters 
                     ptTopBack (list (- (car ptTopBack) 1.0) (cadr ptTopBack)) 
                     ; ptBaseBack (list (+ (car ptBaseBack) tread) (+ (cadr ptBaseBack) riser)) 
                     ptBaseFlat (list (+ (car ptBaseFlat) tread) (+ (cadr ptBaseFlat) riser))
                     nil))

  ;; 5. Close the profile perfectly
  (command ptTopBack)
  (command ptTopFront)   ; <--- Meets the landing horizontally
  (command ptBaseFlat)   ; <--- Slopes down to the new flat base
  (command ptBaseBack)   ; <--- Fills the dust wedge
  (command "_C")         ; Close the polyline back to ptOrigin
  
  ;; 6. Extrude into 3D (Negative width flips it to +Y)
  (setq myStairProfile (entlast))
  (command "_.EXTRUDE" myStairProfile "" (- stairWidth))

  ;; 7. Stand it up
  (setq my3DSolid (entlast))
  (command "_.ROTATE3D" my3DSolid "" "_X" ptOrigin 90)

  ;; 8. THE MAGIC: Move the entire 3D Solid UP by exactly one riser
  ;; This brings the dropped base `(0, -riser)` up to rest perfectly flat at `Z=0`
  (command "_.MOVE" my3DSolid "" '(0.0 0.0 0.0) (list 0.0 0.0 riser))
  
  (setvar "OSMODE" oldOs)
  (princ)
)

;; ==========================================
;; 2. THE BULLNOSE STEP (Single Polyline Method)
;; ==========================================
(defun DrawBullnoseStep (ptOrigin tread riser stairWidth / 
                         oldOs w w_half pt2 pt3 pt4 ptCenter pt5 pt6 stepSolid)

  (setq oldOs (getvar "OSMODE"))
  (setvar "OSMODE" 0)

  ;; Helper variables for your math
  (setq w stairWidth)
  (setq w_half (/ stairWidth 2.0))

  ;; 1. Map your exact counter-clockwise coordinates
  (setq pt2 (list (car ptOrigin) (+ (cadr ptOrigin) w)))                           ; (0, w)
  (setq pt3 (list (- (car ptOrigin) (- w tread)) (+ (cadr ptOrigin) w)))           ; (-(w-t), w)
  (setq pt4 (list (- (car ptOrigin) (- w tread)) (+ (cadr ptOrigin) w_half)))      ; (-(w-t), w/2)
  (setq ptCenter (list (+ (car ptOrigin) tread) (+ (cadr ptOrigin) w_half)))       ; Center: (t, w/2)
  (setq pt5 (list (+ (car ptOrigin) tread) (- (cadr ptOrigin) w_half)))            ; (t, -w/2)
  (setq pt6 (list (+ (car ptOrigin) tread) (cadr ptOrigin)))                       ; (t, 0)

  ;; 2. The Continuous Polyline Execution
  (command "_.PLINE" 
           ptOrigin 
           pt2 
           pt3 
           pt4 
           "_A" "_CE" ptCenter pt5   ; Switch to Arc, define Center, click End
           "_L" pt6                  ; Switch back to Line mode
           "_C")                     ; Close back to ptOrigin (0,0)

  ;; 3. Extrude the flawless boundary into a 3D block
  (setq stepSolid (entlast))
  (command "_.EXTRUDE" stepSolid "" riser)

  (setvar "OSMODE" oldOs)
  (princ)
)

;; ==========================================
;; 4. THE INTERACTIVE COMMAND
;; ==========================================
(defun c:MAKEFLIGHT ( / pt tr ri w steps thick)
  (princ "\n--- Interactive Stair Maker ---")
  
  ;; 1. Prompt the user for the variables
  (setq pt (getpoint "\nSpecify insertion point (bottom left of flight): "))
  
  ;; Use getdist or getreal for measurements. 
  ;; We can even provide your standard defaults if they just press Enter!
  (setq tr (getreal "\nEnter tread depth in mm <300>: "))
  (if (not tr) (setq tr 300.0)) ; Default to 300 if they just press Enter
  
  (setq ri (getreal "\nEnter riser height in mm <170>: "))
  (if (not ri) (setq ri 170.0))
  
  (setq w (getreal "\nEnter staircase width in mm <900>: "))
  (if (not w) (setq w 900.0))
  
  (setq steps (getint "\nEnter number of steps: "))
  
  (setq thick (getreal "\nEnter landing connection thickness in mm <170>: "))
  (if (not thick) (setq thick 170.0))

  ;; 2. Feed the gathered variables into your existing non-interactive engine
  (if (and pt steps) ; Ensure they at least clicked a point and entered steps
    (progn
      (princ "\nGenerating flight...")
      (DrawFlight3D pt tr ri w steps thick)
      (princ "\nFlight generated perfectly!")
    )
    (princ "\nCommand cancelled: Missing required inputs.")
  )
  
  (princ)
)

;; ==========================================
;; 4. THE INTERACTIVE COMMAND
;; ==========================================
(defun c:MAKEDEPTHFLIGHT ( / pt tr ri w steps thick)
  (princ "\n--- Interactive Stair Maker ---")
  
  ;; 1. Prompt the user for the variables
  (setq pt (getpoint "\nSpecify insertion point (bottom left of flight): "))
  
  ;; Use getdist or getreal for measurements. 
  ;; We can even provide your standard defaults if they just press Enter!
  (setq tr (getreal "\nEnter tread depth in mm <300>: "))
  (if (not tr) (setq tr 300.0)) ; Default to 300 if they just press Enter
  
  (setq ri (getreal "\nEnter riser height in mm <170>: "))
  (if (not ri) (setq ri 170.0))
  
  (setq w (getreal "\nEnter staircase width in mm <900>: "))
  (if (not w) (setq w 900.0))
  
  (setq steps (getint "\nEnter number of steps: "))
  
  (setq thick (getreal "\nEnter landing connection thickness in mm <170>: "))
  (if (not thick) (setq thick 170.0))

  ;; 2. Feed the gathered variables into your existing non-interactive engine
  (if (and pt steps) ; Ensure they at least clicked a point and entered steps
    (progn
      (princ "\nGenerating flight...")
      (DrawFlight3D pt tr ri w steps thick)
      (princ "\nFlight generated perfectly!")
    )
    (princ "\nCommand cancelled: Missing required inputs.")
  )
  
  (princ)
)

;; ==========================================
;; 3. THE WORKFLOW WRAPPER
;; ==========================================
(defun c:TESTSDEPTHSTAIRS ()
  (princ "\nGenerating modular staircase...")
  
  ;; Origin, Tread, Riser, Width, Steps, LandingThickness
  (DrawFlight3D '(0.0 0.0 0.0) 0.30e3 0.17e3 0.90e3 6 0.17e3)
  
  ;; Generate Step 1
  (DrawBullnoseStep '(1800 0.0 1360) 0.30e3 0.17e3 0.90e3)
  
  (princ "\nGeometry generated perfectly!")
  (princ)
)