(defun c:DROPLANDING ( / pt width thickness ptOpposite oldOs)
  (setq pt (getpoint "\nClick to drop Landing: "))
  (if pt
    (progn
      (setq width (getdist pt "\nEnter Landing width (e.g., matching stair width): "))
      (setq thickness (getdist pt "\nEnter Landing thickness: "))
      
      (setq oldOs (getvar "OSMODE"))
      (setvar "OSMODE" 0)
      
      ;; Calculate the opposite diagonal corner for the 3D Box
      (setq ptOpposite (list (+ (car pt) width) (+ (cadr pt) width) (- (caddr pt) thickness)))
      
      ;; Draw the 3D parallelepiped
      (command "_.BOX" pt ptOpposite)
      
      (setvar "OSMODE" oldOs)
    )
  )
  (princ "\nLanding generated.")
  (princ)
)