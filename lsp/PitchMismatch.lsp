(defun c:PitchMismatch ( / ptRend rInner treadWidth straightRise straightRun semiHeight rOuter rMid pitchStr pitchIn pitchOut pitchMid ptIn ptMid ptOut vLen pStrIn pStrMid pStrOut pSemiIn pSemiMid pSemiOut)

  ;; EN: User Inputs
  ;; ES: Entradas del Usuario
  (setq ptRend (getpoint "\nSelect rendezvous center point: "))
  (setq rInner (getreal "\nEnter semicircular inner radius: "))
  (setq treadWidth (getreal "\nEnter tread width: "))
  (setq straightRise (getreal "\nEnter straight step rise: "))
  (setq straightRun (getreal "\nEnter straight step run: "))
  (setq semiHeight (getreal "\nEnter total semicircular flight height: "))

  ;; EN: Calculate radii and pitches
  ;; ES: Calcular radios y pendientes
  (setq rOuter (+ rInner treadWidth))
  (setq rMid (+ rInner (/ treadWidth 2.0)))
  
  (setq pitchStr (/ straightRise straightRun))
  (setq pitchIn (/ semiHeight (* pi rInner)))
  (setq pitchOut (/ semiHeight (* pi rOuter)))
  (setq pitchMid (/ semiHeight (* pi rMid)))

  ;; EN: Define rendezvous points across the width
  ;; ES: Definir puntos de encuentro a lo ancho
  (setq ptMid ptRend)
  (setq ptIn (list (- (car ptRend) (/ treadWidth 2.0)) (cadr ptRend) (caddr ptRend)))
  (setq ptOut (list (+ (car ptRend) (/ treadWidth 2.0)) (cadr ptRend) (caddr ptRend)))

  ;; EN: Vector length for clear visual representation
  ;; ES: Longitud del vector para representación visual
  (setq vLen (* straightRun 4.0))

  ;; EN: Calculate vector endpoints 
  ;; (Straight flight descends to -Y, Semi ascends to +Y)
  ;; ES: Calcular extremos de vectores
  (setq pStrIn (list (car ptIn) (- (cadr ptIn) vLen) (- (caddr ptIn) (* vLen pitchStr))))
  (setq pStrMid (list (car ptMid) (- (cadr ptMid) vLen) (- (caddr ptMid) (* vLen pitchStr))))
  (setq pStrOut (list (car ptOut) (- (cadr ptOut) vLen) (- (caddr ptOut) (* vLen pitchStr))))

  (setq pSemiIn (list (car ptIn) (+ (cadr ptIn) vLen) (+ (caddr ptIn) (* vLen pitchIn))))
  (setq pSemiMid (list (car ptMid) (+ (cadr ptMid) vLen) (+ (caddr ptMid) (* vLen pitchMid))))
  (setq pSemiOut (list (car ptOut) (+ (cadr ptOut) vLen) (+ (caddr ptOut) (* vLen pitchOut))))

  ;; EN: Draw Straight Flight Vectors (Red)
  ;; ES: Dibujar vectores del tramo recto (Rojo)
  (command "._COLOR" "1") 
  (command "._LINE" ptIn pStrIn "")
  (command "._LINE" ptMid pStrMid "")
  (command "._LINE" ptOut pStrOut "")

  ;; EN: Draw Semicircular Flight Vectors (Blue)
  ;; ES: Dibujar vectores del tramo semicircular (Azul)
  (command "._COLOR" "5") 
  (command "._LINE" ptIn pSemiIn "")
  (command "._LINE" ptMid pSemiMid "")
  (command "._LINE" ptOut pSemiOut "")

  (command "._COLOR" "BYLAYER")

  ;; EN: Output the mathematical mismatch to the command line
  ;; ES: Imprimir el desfase matemático en la línea de comandos
  (princ (strcat "\nPitch Straight (Uniform): " (rtos pitchStr 2 4)))
  (princ (strcat "\nPitch Semicircle Inner:  " (rtos pitchIn 2 4)))
  (princ (strcat "\nPitch Semicircle Outer:  " (rtos pitchOut 2 4)))
  (princ "\nRed lines = Straight Pitch | Blue lines = Semicircular Pitches")
  (princ)
)