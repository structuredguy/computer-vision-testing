(defun c:LoadProject ( / folderPath fileList fullPath LANG)
  
  ;; EN: Toggle switch
  ;; ES: Interruptor de idioma
  (setq LANG "EN") ;; Options: "EN" or "ES"

  ;; EN: Define your VS Code project folder path here.
  ;; ES: Define la ruta de tu carpeta de proyecto de VS Code aquí.
  ;; IMPORTANT: Use double backslashes for Windows paths!
  (setq folderPath "C:\\dev\\computer-vision-testing\\lsp\\") 

  ;; EN: Fetch all .lsp files in the directory
  ;; ES: Obtener todos los archivos .lsp en el directorio
  (setq fileList (vl-directory-files folderPath "*.lsp" 0))

  (if fileList
    (progn
      (foreach file fileList
        ;; Prevent the loader from loading itself if it's in the same folder
        (if (not (wcmatch (strcase file) "_LOADALL.LSP"))
          (progn
            (setq fullPath (strcat folderPath file))
            (load fullPath)
            
            ;; Console Output
            (if (= LANG "EN")
                (princ (strcat "\nLoaded: " file))
                (princ (strcat "\nCargado: " file))
            )
          )
        )
      )
      ;; Summary Output
      (if (= LANG "EN")
          (princ (strcat "\nSuccessfully loaded " (itoa (length fileList)) " files."))
          (princ (strcat "\nCargados con éxito " (itoa (length fileList)) " archivos."))
      )
    )
    ;; Error Output
    (if (= LANG "EN")
        (princ "\nNo LISP files found in the directory.")
        (princ "\nNo se encontraron archivos LISP en el directorio.")
    )
  )
  (princ)
)