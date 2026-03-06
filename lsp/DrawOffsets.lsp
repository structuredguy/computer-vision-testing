(defun c:DrawOffsets ( / ss i ent pt x_list pt_y pt1 pt2 old_osnap)
  (prompt "\nSelect your Ordinate Dimensions: ")
  
  ;; 1. Filter selection to only grab Dimensions
  (if (setq ss (ssget '((0 . "DIMENSION"))))
    (progn
      (setq x_list '())
      (setq i 0)
      
      ;; 2. Loop through and extract the X-coordinates
      (while (< i (sslength ss))
        (setq ent (entget (ssname ss i)))
        (setq pt (cdr (assoc 13 ent))) ; Group code 13 is the feature point
        
        ;; Add to list if it's not a duplicate
        (if (not (vl-position (car pt) x_list)) 
          (setq x_list (cons (car pt) x_list))
        )
        (setq i (1+ i))
      )
      
      ;; 3. Sort the array of X-coordinates from smallest to largest
      (setq x_list (vl-sort x_list '<))

      ;; 4. Draw the new offsets
      (if (> (length x_list) 1)
        (progn
          (setq pt_y (getpoint "\nClick where you want the new offset dimension line to appear: "))
          
          ;; Turn OFF object snaps so the drawing command doesn't jump around
          (setq old_osnap (getvar "OSMODE"))
          (setvar "OSMODE" 0) 

          (setq i 0)
          ;; Loop through the array and draw linear dimensions between n and n+1
          (while (< i (1- (length x_list)))
            (setq pt1 (list (nth i x_list) (cadr pt_y) 0.0))
            (setq pt2 (list (nth (1+ i) x_list) (cadr pt_y) 0.0))
            
            ;; Execute the CAD command
            (command "_dimlinear" pt1 pt2 pt_y) 
            (setq i (1+ i))
          )

          ;; Turn snaps back on
          (setvar "OSMODE" old_osnap) 
          (prompt "\nOffset dimensions drawn successfully!")
        )
        (prompt "\nYou need to select at least 2 marks.")
      )
    )
  )
  (princ) ; Exit quietly
)