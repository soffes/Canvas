require 'open-uri'

desc 'Compile index.html'
task :html do
  sharejs = open('https://raw.githubusercontent.com/usecanvas/sharejs-wrapper/v1.0.7/dist/index.js').read.chomp
  editor = File.read('Support/canvas.js').chomp

  html = %Q{<!DOCTYPE html>
<html lang="en-US">
  <head>
    <meta charset="utf-8">
    <title>Canvas</title>
    <script>
#{sharejs}

////////////////////////////////////////////////////////////////////////////////

#{editor}
    </script>
  </head>
  <body></body>
</html>
}

  file = File.new('Support/index.html', 'w')
  file.write(html)
  file.close
end
