# pslm - psalm processing utility

require 'pslm'
require 'optparse'

DEFAULT_SETUP = {
  :general => {
    :format => 'latex', # latex|pslm
    :output_file => nil,
  },
  :input => {
    :has_title => true,
    :join => false,
  },
  :output => Pslm::Outputter::DEFAULT_SETUP.dup
}

setup = DEFAULT_SETUP.dup

# TODO the setup below doesn't yet respect the structure of the options above
# TODO many of the options aren't implemented yet, some will never be
optparse = OptionParser.new do |opts|

  opts.separator "== General options"

  opts.on "-o", "--output FILE", "Save output to given path." do |out|
    setup[:general][:output_file] = out
  end

  opts.separator "== Input interpretation"

  opts.on "--no-title", "Don't consider the first line to contain a psalm title" do
    setup[:input][:has_title] = false
  end
  opts.on "-a", "--append TEXT", "Text to be appended at the end (before processing)." do |t|
    setup[:input][:append_text] = t
  end
  opts.on "-j", "--join", "Join all given input files" do
    setup[:input][:join] = true
  end

  opts.separator "== Output formatting"

  opts.on "--skip-title", "Don't set the title" do
    setup[:output][:title][:template] = :no
  end
  # TODO
  opts.on "--title-template [TEMPLATE]", "Use a specified template instead of the default one." do |p|
    setup[:output][:title_pattern] = p
  end
  opts.on "-k", "--skip-verses NUM", Integer, "Skip initial verses" do |i|
    setup[:output][:skip_verses] = i
  end
  # TODO
  opts.on "--no-formatting", "Just process accents and don't do anything else with the document" do
    setup[:output][:no_formatting] = true
  end
  opts.on "-c", "--accents NUMS", "a:b - Numbers of accents to be pointed in each half-verse" do |str|
    a1, a2 = str.split ':'
    if a1 && a1 != "" then
      setup[:output][:pointing][:accents][0] = a1.to_i
    end
    if a2 && a2 != "" then
      setup[:output][:pointing][:accents][1] = a2.to_i
    end
  end
  # TODO merge with the previous option to a1[,p1]:a2[,p2]
  opts.on "-p", "--preparatory-syllables NUMS", "a:b - How many preparatory syllables in each half-verse" do |str|
    a1, a2 = str.split ':'
    if a1 && a1 != "" then
      setup[:output][:pointing][:preparatory][0] = a1.to_i
    end
    if a2 && a2 != "" then
      setup[:output][:pointing][:preparatory][1] = a2.to_i
    end
  end
  opts.on "-s", "--accents-style SYM", "underline (default) | bold" do |s|
    sym = s.to_sym
    setup[:output][:pointing][:accent_style] = sym
  end
  # Needs LaTeX package lettrine!
  # TODO
  opts.on "--lettrine", "Large first character of the psalm." do
    setup[:output][:lettrine] = true
  end
  opts.on "--split-verses", "Each verse part on it's own line" do
    setup[:output][:parts][:novydvur_newlines] = true # like in the psalter of the Novy Dvur Trappist abbey
  end
  # TODO
  opts.on "--pretitle TEXT", "Text to be printed as beginning of the title." do |t|
    setup[:output][:prepend_text] = t
  end
  # TODO
  opts.on "--output-append TEXT", "Text to be appended at the end (of the last line after processing)." do |t|
    setup[:output][:output_append_text] = t
  end
  # This is useful when we want to append a doxology after the psalm
  # as a separate paragraph
  # TODO
  opts.on "--linebreak-at-the-end", "Make a line-break after the last line" do
    setup[:output][:line_break_last_line] = true
  end
  # TODO
  opts.on "--dashes", "Dash at the end of each psalm paragraph" do
    setup[:output][:dashes] = true
  end
  # TODO
  opts.on "--no-paragraph", "No empty line after each psalm paragraph." do
    setup[:output][:paragraph_space] = false
  end
  # TODO
  opts.on "--guillemets", "Convert american quotes to french ones (guillemets)." do
    setup[:output][:guillemets] = true
  end
  # TODO
  opts.on "-m", "--mark-short-verses", "Insert warning marks in verses that are too short" do
    setup[:output][:mark_short_verses] = true
  end
end

optparse.parse!

if ARGV.empty? then
  raise "Program expects filenames as arguments."
end

Pslm::PsalmPointer.new(setup).process(ARGV)
