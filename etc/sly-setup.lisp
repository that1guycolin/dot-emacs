(pushnew #p"/home/colin-l/.config/emacs/var/elpaca/builds/sly/slynk/"
         asdf:*central-registry*)
(asdf:load-system :slynk)
(slynk:create-server :port 4008)
