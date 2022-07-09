# main file of the pslm library

module Pslm
end

require_relative 'pslm/config_hash'
require_relative 'pslm/pslmreader'
require_relative 'pslm/psalm'
require_relative 'pslm/psalmpointer'
require_relative 'pslm/psalmpatterns'

require_relative 'pslm/outputter'
require_relative 'pslm/latexoutputter'
require_relative 'pslm/pslmoutputter'
require_relative 'pslm/consoleoutputter'

require_relative 'pslm/structuredsetup'
require_relative 'pslm/joinedinput'
require_relative 'pslm/option_parser'
