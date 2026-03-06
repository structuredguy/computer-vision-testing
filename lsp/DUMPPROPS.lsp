(defun c:DumpProps ( / sel obj )
  (vl-load-com)
  (prompt "\nSelect the Viewport (or any object) to extract properties: ")
  
  (if (setq sel (entsel))
    (progn
      ;; Convert standard CAD entity to a VLA (ActiveX) Object
      (setq obj (vlax-ename->vla-object (car sel)))
      
      ;; Force open the CAD text history window (like a terminal)
      (textpage) 
      
      (princ "\n========================================")
      (princ "\n       VLA OBJECT PROPERTIES DUMP       ")
      (princ "\n========================================\n")
      
      ;; Dump all properties (nil means don't dump methods, just properties)
      (vlax-dump-object obj nil) 
      
      (princ "\n========================================")
      (princ "\nSUCCESS! Highlight the text above, hit Ctrl+C, and paste it into Emacs/Notepad.")
      (princ "\n(Press F2 to close this text window and return to CAD)")
    )
    (prompt "\nYou didn't select anything.")
  )
  (princ) ; Exit quietly
)