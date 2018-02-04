# -*- coding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = 'pslm'
  s.version     = '0.0.0'
  s.date        = '2013-11-16'
  s.summary     = "plain text psalm format formatter utility and library"
  s.authors     = ["Jakub Pavlík"]
  s.email       = 'jkb.pavlik@gmail.com'
  s.files       = Dir['lib/*.rb'] + Dir['lib/pslm/*.rb'] + Dir['lib/pslm/psalmtones/*.yml']
  s.executables = ['pslm.rb']
  s.homepage    =
    'http://github.com/igneus/pslm'
  s.licenses    = ['LGPL-3.0', 'MIT']

  s.add_runtime_dependency 'colorize'
  s.add_runtime_dependency 'deep_merge'
  s.add_runtime_dependency 'hashie', '> 3.4'

  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
end
