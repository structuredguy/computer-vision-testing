(defun DrawFlight (ptOrigin tread riser numSteps throatThickness / ptCurrent i)
  
  ;; Start the Polyline command
  (command "_.PLINE" ptOrigin)
  
  (setq ptCurrent ptOrigin)
  (setq i 0)
  
  ;; Loop to draw the steps
  (while (< i numSteps)
    ;; Calculate Riser (Up)
    (setq ptCurrent (list (car ptCurrent) (+ (cadr ptCurrent) riser)))
    (command ptCurrent) ; send point to PLINE
    
    ;; Calculate Tread (Forward)
    (setq ptCurrent (list (+ (car ptCurrent) tread) (cadr ptCurrent)))
    (command ptCurrent) ; send point to PLINE
    
    (setq i (1+ i))
  )
  
  ;; Press Enter to finish the polyline
  (command "") 
  
  ;; (The trigonometry logic for the slanted slab would go here)
  (princ "\nFlight generated!")
  (princ)
)

;; A "Wrapper" command to run it from the AutoCAD prompt and ask for user input
(defun c:TESTFLIGHT ( / pt tr rs n th)
  (setq pt (getpoint "\nSelect origin point: "))
  (setq tr (getdist "\nEnter tread depth: "))
  (setq rs (getdist "\nEnter riser height: "))
  (setq n  (getint  "\nEnter number of steps: "))
  (setq th (getdist "\nEnter slab throat thickness: "))
  
  (DrawFlight pt tr rs n th)
)
