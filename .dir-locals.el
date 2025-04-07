;;; Directory Local Variables            -*- no-byte-compile: t -*-
;;; For more information see (info "(emacs) Directory Variables")

((prog-mode . ((fill-column . 100)
			   (eval . (progn (indent-tabs-mode 1)
							  (add-hook 'before-save-hook
										(lambda () (when eglot--managed-mode (eglot-format-buffer)))
										nil t))))))
