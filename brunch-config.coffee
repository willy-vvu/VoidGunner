exports.config =
  # See http://brunch.io/#documentation for docs.
  files:
    javascripts:
      joinTo: 'app.js'
      # joinTo:
      #   'app.js': /^app|^bower_components/
      #   'controller.js': /^app[\\/]controller|^bower_components/
    stylesheets:
      joinTo:
        'controller.css': /^app[\\/]controller/
        'app.css': /^app/
    templates:
      joinTo: 'app.js'
