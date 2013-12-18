# -*- coding: utf-8 -*-

module Pslm

  # abstract superclass of all outputters
  class Outputter

    DEFAULT_SETUP = {
      :no_formatting => false,
      :title => {
        :template => :semantic,
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
        :end_marks => false,
        :paragraph_space => true,
        :mark_last_strophe => false,
      },
      :wrapper => {
        :environment_name => 'psalmus'
      },
      :lettrine => nil,
      :prepend_text => nil,
      :output_append_text => nil,
      :line_break_last_line => false,
      :quote => false, # :single|:double|:guillemets|:czech|:delete
      :mark_short_verses => false
    }

    def process(psalm, options={})
      raise RuntimeError.new "Abstract class. Method not implemented."
    end

  end
end