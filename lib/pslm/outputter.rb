# -*- coding: utf-8 -*-

module Pslm

  # abstract superclass of all outputters
  class Outputter

    DEFAULT_SETUP = {
      :no_formatting => false,
      :title => {
        :template => nil,
      },
      :pointing => {
        :accents => [2,2],
        :preparatory => [0,0],
        :accent_style => :underline, # :underline|:bold|:semantic
      },
      :break_hints => true,
      :parts => {
        :marks_type => :simple, # :simple|:semantic|:no
        :novydvur_newlines => false,
      },
      :verses => {
        :paragraphify => true
      },
      :skip_verses => 0,
      :strophes => {
        :dashes => false,
        :paragraph_space => true,
      },
      :wrapper => {
        :environment_name => 'psalmus'
      },
      :lettrine => false,
      :prepend_text => nil,
      :output_append_text => nil,
      :line_break_last_line => false,
      :guillemets => false,
      :mark_short_verses => false
    }

    def process(psalm, options={})
      raise RuntimeError.new "Abstract class. Method not implemented."
    end

  end
end