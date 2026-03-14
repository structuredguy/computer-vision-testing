(defun c:SemiCircularStair ( / ptCenter rInner treadWidth totalHeight numSteps dTheta dZ currentAngle currentZ i p1 p2 p3 p4)
  
  ;; EN: User Inputs
  ;; ES: Entradas del Usuario
  (setq ptCenter (getpoint "\nSelect center point of the stair: "))
  (setq rInner (getreal "\nEnter inner radius: "))
  (setq treadWidth (getreal "\nEnter tread width: "))
  (setq totalHeight (getreal "\nEnter total height of the flight: "))
  (setq numSteps (getint "\nEnter number of steps: "))

  ;; EN: Calculate angular and vertical increments (Pi radians for a semicircle)
  ;; ES: Calcular incrementos angulares y verticales (Pi radianes para un semicírculo)
  (setq dTheta (/ pi numSteps))
  (setq dZ (/ totalHeight numSteps))
  
  (setq currentAngle 0.0)
  (setq currentZ (caddr ptCenter))
  
  ;; EN: Loop to draw each tread
  ;; ES: Bucle para dibujar cada escalón
  (setq i 0)
  (while (< i numSteps)
    
    ;; EN: Calculate the 4 corners of the current tread
    ;; ES: Calcular las 4 esquinas del escalón actual
    (setq p1 (list 
               (+ (car ptCenter) (* rInner (cos currentAngle))) 
               (+ (cadr ptCenter) (* rInner (sin currentAngle))) 
               currentZ))
               
    (setq p2 (list 
               (+ (car ptCenter) (* (+ rInner treadWidth) (cos currentAngle))) 
               (+ (cadr ptCenter) (* (+ rInner treadWidth) (sin currentAngle))) 
               currentZ))
               
    (setq p3 (list 
               (+ (car ptCenter) (* (+ rInner treadWidth) (cos (+ currentAngle dTheta)))) 
               (+ (cadr ptCenter) (* (+ rInner treadWidth) (sin (+ currentAngle dTheta)))) 
               currentZ))
               
    (setq p4 (list 
               (+ (car ptCenter) (* rInner (cos (+ currentAngle dTheta)))) 
               (+ (cadr ptCenter) (* rInner (sin (+ currentAngle dTheta)))) 
               currentZ))

    ;; EN: Draw the tread as a 3D Face
    ;; ES: Dibujar el escalón como una Cara 3D
    (command "._3DFACE" p1 p2 p3 p4 "")

    ;; EN: Step up the angle and elevation for the next tread
    ;; ES: Aumentar el ángulo y la elevación para el siguiente escalón
    (setq currentAngle (+ currentAngle dTheta))
    (setq currentZ (+ currentZ dZ))
    (setq i (1+ i))
  )
  
  (princ "\nSemicircular stair generated.")
  (princ)
)

;; ==========================================
;; 3. THE WORKFLOW WRAPPER
;; ==========================================
; (defun c:TESTSEMICIRCULARSTAIRS ()
;   (princ "\nGenerating modular staircase...")
  
;   ;; Origin, Tread, Riser, Width, Steps, LandingThickness
;   (DrawFlight3D '(0.0 0.0 0.0) 0.30e3 0.17e3 0.90e3 6 0.17e3)
  
;   ;; Generate Step 1
;   (DrawBullnoseStep '(1800 0.0 1360) 0.30e3 0.17e3 0.90e3)
  
;   (princ "\nGeometry generated perfectly!")
;   (princ)
; )