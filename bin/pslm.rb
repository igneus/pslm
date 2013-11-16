# pslm - psalm processing utility

require 'pslm'
require 'optparse'

DEFAULT_SETUP = {
  :general => {
    :format => 'latex', # currently single available option
    :output_file => nil,
  },
  :input => {
    :has_title => true,
    :append_text => nil,
    :join => false,
    :skip_verses => nil,
  },
  :output => {
    :skip_title => false,
    :title_pattern => nil,
    :no_formatting => false,
    :accents => [2,2],
    :preparatory => [0,0],
    :accent_style => :underline,
    :lettrine => false,
    :novydvur_newlines => false,
    :prepend_text => nil,
    :output_append_text => nil,
    :line_break_last_line => false,
    :dashes => false,
    :paragraph_space => true,
    :guillemets => false,
    :mark_short_verses => false,
  }  
}
    
setup = DEFAULT_SETUP.dup

optparse = OptionParser.new do |opts|
  
  opts.separator "== General options"
  
  opts.on "-o", "--output FILE", "Save output to given path." do |out|
    setup[:output_file] = out
  end
  
  opts.separator "== Input interpretation"
  
  opts.on "-t", "--no-title", "Don't consider the first line to contain a psalm title" do
    setup[:has_title] = false
  end
  opts.on "-a", "--append TEXT", "Text to be appended at the end (before processing)." do |t|
    setup[:append_text] = t
  end
  opts.on "-j", "--join", "Join all given input files" do
    setup[:join] = true
  end
  opts.on "-k", "--skip-verses NUM", Integer, "Skip initial verses" do |i|
    setup[:skip_verses] = i
  end
  
  opts.separator "== Output formatting"
  
  opts.on "-q", "--skip-title", "Don't set the title" do
    setup[:skip_title] = true
  end
  opts.on "-T", "--title-template [TEMPLATE]", "Use a specified template instead of the default one." do |p|
    setup[:title_pattern] = p
  end
  opts.on "-f", "--no-formatting", "Just process accents and don't do anything else with the document" do
    setup[:no_formatting] = true
  end
  opts.on "-a", "--accents NUMS", "a:b - Numbers of accents to be pointed in each half-verse" do |str|
    a1, a2 = str.split ':'
    if a1 && a1 != "" then
      setup[:accents][0] = a1.to_i
    end
    if a2 && a2 != "" then
      setup[:accents][1] = a2.to_i
    end
  end
  # TODO merge with the previous option to a1[,p1]:a2[,p2]
  opts.on "-P", "--preparatory-syllables NUMS", "a:b - How many preparatory syllables in each half-verse" do |str|
    a1, a2 = str.split ':'
    if a1 && a1 != "" then
      setup[:preparatory][0] = a1.to_i
    end
    if a2 && a2 != "" then
      setup[:preparatory][1] = a2.to_i
    end
  end
  opts.on "-s", "--accents-style SYM", "underline (default) | bold" do |s|
    sym = s.to_sym
    unless UnderlineAccentsOutputStrategy::ACCENT_STYLES.include? sym 
      raise "Unknown style '#{sym}'"
    end
    setup[:accent_style] = sym
  end
  # Needs package lettrine!
  opts.on "-l", "--lettrine", "Large first character of the psalm." do
    setup[:lettrine] = true
  end
  opts.on "-S", "--split-verses", "Each verse part on it's own line" do
    setup[:novydvur_newlines] = true # like in the psalter of the Novy Dvur Trappist abbey
  end
  opts.on "-p", "--pretitle TEXT", "Text to be printed as beginning of the title." do |t|
    setup[:prepend_text] = t
  end
  opts.on "-A", "--output-append TEXT", "Text to be appended at the end (of the last line after processing)." do |t|
    setup[:output_append_text] = t
  end
  # This is useful when we want to append a doxology after the psalm
  # as a separate paragraph
  opts.on "-e", "--linebreak-at-the-end", "Make a line-break after the last line" do
    setup[:line_break_last_line] = true
  end
  opts.on "-d", "--dashes", "Dash at the end of each psalm paragraph" do
    setup[:dashes] = true
  end
  opts.on "-p", "--no-paragraph", "No empty line after each psalm paragraph." do
    setup[:paragraph_space] = false
  end
  opts.on "-g", "--guillemets", "Convert american quotes to french ones (guillemets)." do
    setup[:guillemets] = true
  end
  opts.on "-m", "--mark-short-verses", "Insert warning marks in verses that are too short" do
    setup[:mark_short_verses] = true
  end
end

optparse.parse!

if ARGV.empty? then
  raise "Program expects filenames as arguments."
end

Preprocessor.new(setup).preprocess(ARGV)