# Changelog

## 0.4.4
date: 2017-01-21

 - update ruby versions
 - close sh session streams on unexpected exit
 - fix reseting colors in status plugin

## 0.4.3
date: 2013-08-23

 - fix resetting terminal colors #4, #5 - thanks @aspiers

## 0.4.2
date: 2013-03-02

 - fix stderr output #3 - thanks @infertux
 - switch to ruby 2.0.0

## 0.4.1
date: 2012-08-09

 - fix detecting environment variables names
 - fix detecting variables with numbers in names
 - fix filtering environment variables
 - add `TF_DEBUG` for troubleshooting

## 0.4.0
date: 2012-08-09

 - fix reading environment
 - extend testing environment: array & type
 - extend testing match stdout / stderr

## 0.3.2
date: 2012-07-30

 - fix loading env in zsh

## 0.3.1
date: 2012-07-30

 - add support for selecting runner shell via shebang line

## 0.3.0
date: 2012-05-28

 - rename to tf

## 0.2.0
date: 2012-03-28

 - add support for selecting output plugin --text, --dotted
 - improved detecting input plugins
 - improved error detection, count failed plugin search also as errors

## 0.1.3
date: 2012-02-02

 - fix sorting of errors

## 0.1.2
date: 2012-02-02

 - change the default output to be less verbose

## 0.1.1
date: 2012-01-31

 - support for more platforms
 - `status_output` plugin - print status line on the end

## 0.1.0
date: 2012-01-30

 - initial release - compability with rvm-test
