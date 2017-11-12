gulp = require 'gulp'
coffee = require 'gulp-coffee'
pug = require 'gulp-pug'
connect = require 'gulp-connect'
uglify = require 'gulp-uglify'
stylus = require 'gulp-stylus'
imagemin = require 'gulp-imagemin'
pngquant = require 'imagemin-pngquant'
cleanCss = require 'gulp-clean-css'
concat = require 'gulp-concat'
bower = require 'gulp-bower'

gulp.task 'connect', ->
  connect.server
    port: 1337
    livereload: yes
    root: './dist'

gulp.task 'coffee', ->
  gulp.src 'coffee/*.coffee'
  .pipe do coffee
  .pipe do uglify
  .pipe gulp.dest 'dist/js'
  .pipe do connect.reload

gulp.task 'pug', ->
  gulp.src 'pug/*.pug'
  .pipe do pug
  .pipe gulp.dest 'dist'
  .pipe do connect.reload

gulp.task 'stylus', ->
  gulp.src 'stylus/*.styl'
    .pipe stylus compress: yes
    .pipe gulp.dest 'dist/css'
    .pipe do connect.reload

gulp.task 'bower', ->
  bower './libs'

gulp.task 'buildcss', ->
  gulp.src ['libs/humane-js/themes/bigbox.css']
    .pipe do cleanCss
    .pipe concat 'libs.min.css'
    .pipe gulp.dest 'dist/css/'

gulp.task 'img', ->
  gulp.src 'images/**/*'
    .pipe imagemin([
      imagemin.jpegtran({progressive: yes}),
      imagemin.svgo({
        plugins: [
          {removeViewBox: true},
          {cleanupIDs: false},
          {collapseGroups: true},
          {removeDimensions: true},
          {removeAttrs: {attrs: "transform"}}
        ]
      })
  ])
    .pipe gulp.dest 'dist/img'

gulp.task 'buildjs', ->
  gulp.src ['libs/Snap.svg/dist/snap.svg.js', 'libs/humane-js/humane.js']
  .pipe concat 'libs.js'
  .pipe do uglify
  .pipe gulp.dest 'dist/js'

gulp.task 'watch', ->
  gulp.watch 'coffee/*.coffee', ['coffee']
  gulp.watch 'stylus/*.styl', ['stylus']
  gulp.watch 'pug/*.pug', ['pug']

gulp.task 'build', ['bower', 'buildcss', 'buildjs', 'img']

gulp.task 'default', ['pug', 'coffee', 'stylus', 'connect', 'watch']