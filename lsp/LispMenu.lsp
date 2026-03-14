(defun c:LispMenu ( / folderPath fileList fullPath fp lineStr commentPos cmdPos cmdStr endPos LANG)
  
  ;; EN: Language toggle switch
  ;; ES: Interruptor de idioma
  (setq LANG "EN") ;; Options: "EN" or "ES"

  ;; EN: Define your VS Code project folder path
  ;; ES: Define la ruta de tu carpeta de proyecto
  (setq folderPath "C:\\dev\\computer-vision-testing\\lsp\\") 
  (setq fileList (vl-directory-files folderPath "*.lsp" 1))

  (if (= LANG "EN")
      (princ "\n\n=== CUSTOM LISP COMMANDS MENU ===")
      (princ "\n\n=== MENÚ DE COMANDOS LISP PERSONALIZADOS ===")
  )

  (if fileList
    (foreach file fileList
      (setq fullPath (strcat folderPath file))
      (setq fp (open fullPath "r")) 
      (if fp
        (progn
          (while (setq lineStr (read-line fp))
            (setq lineStr (strcase lineStr)) 
            
            ;; 1. Strip out comments to avoid reading text after semi-colons
            (setq commentPos (vl-string-search ";" lineStr))
            (if commentPos
              (setq lineStr (substr lineStr 1 commentPos))
            )
            
            ;; 2. Construct the search term to avoid self-referencing
            (setq cmdPos (vl-string-search (strcat "(DEFUN " "C:") lineStr))
            
            (if cmdPos
              (progn
                ;; Extract everything after the syntax
                (setq cmdStr (vl-string-trim " \t" (substr lineStr (+ cmdPos 10))))
                
                ;; 3. Clean up the command name by stripping parameters
                (setq endPos 0)
                (while (and (< endPos (strlen cmdStr))
                            (not (member (substr cmdStr (1+ endPos) 1) '(" " "(" "\t"))))
                  (setq endPos (1+ endPos))
                )
                (if (> endPos 0)
                  (setq cmdStr (substr cmdStr 1 endPos))
                )
                
                (if (= LANG "EN")
                    (princ (strcat "\n > Command: " cmdStr "  [File: " file "]"))
                    (princ (strcat "\n > Comando: " cmdStr "  [Archivo: " file "]"))
                )
              )
            )
          )
          (close fp)
        )
      )
    )
    (if (= LANG "EN")
        (princ "\nError: No files found. Check your folderPath.")
        (princ "\nError: No se encontraron archivos. Verifica tu folderPath.")
    )
  )
  
  (princ "\n=================================\n")
  (textscr)
  (princ)
)