(defun c:ScaleAudit (/ ins_units units_str layout_name plt_scale vp_scale vp_obj)
  (vl-load-com)
  
  ;; 1. Get Model Space Units
  (setq ins_units (getvar "INSUNITS"))
  (setq units_str 
    (cond 
      ((= ins_units 4) "Millimeters")
      ((= ins_units 5) "Centimeters")
      ((= ins_units 6) "Meters")
      (t "Unknown/Unitless")
    )
  )

  ;; 2. Get Layout Info
  (setq layout_name (getvar "CTAB"))
  
  (princ "\n========================================")
  (princ (strcat "\n CAD ENVIRONMENT AUDIT FOR: " layout_name))
  (princ "\n========================================")
  (princ (strcat "\n MODEL UNITS: " units_str " (INSUNITS = " (itoa ins_units) ")"))

  (if (= layout_name "Model")
    (princ "\n STATUS: You are in Model Space (1:1 Drawing Zone)")
    (progn
      ;; 3. Check Paper Scale (Page Setup)
      (princ (strcat "\n PAPER SPACE: " layout_name))
      
      ;; 4. Try to find the Viewport Scale
      (setq ss (ssget "X" (list '(0 . "VIEWPORT") (cons 410 layout_name))))
      (if ss
        (progn
          (setq i 0)
          (repeat (sslength ss)
            (setq vp_ent (ssname ss i))
            (setq vp_data (entget vp_ent))
            (setq vp_scale (cdr (assoc 41 vp_data))) ;; Width/Height ratio
            (setq c_scale (vlax-get-property (vlax-ename->vla-object vp_ent) 'CustomScale))
            
            ;; The Math: (Paper Units / Model Units) * Custom Scale
            (if (> i 0) ;; Skip Viewport 0 (the layout itself)
              (progn
                (princ (strcat "\n --- Viewport #" (itoa i) " ---"))
                (princ (strcat "\n  Custom Scale Factor: " (rtos c_scale 2 4)))
                (princ (strcat "\n  Effective Math: 1 unit on paper = " (rtos (/ 1.0 c_scale) 2 2) " units in Model"))
              )
            )
            (setq i (1+ i))
          )
        )
        (princ "\n No Viewports found in this layout.")
      )
    )
  )
  (princ "\n========================================\n")
  (princ)
)