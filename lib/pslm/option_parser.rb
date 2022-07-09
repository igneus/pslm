require 'optparse'

module Pslm
  # Parses command line options and arguments, produces setup.
  class OptionParser
    DEFAULT_SETUP = {
      :general => {
        :format => 'latex', # latex|pslm
      },
      :input => {
        :has_title => true,
        :title => nil, # to overwrite the title loaded from the input file
        :join => false,
      },
      :output => Pslm::Outputter::DEFAULT_SETUP.dup
    }.freeze

    def self.parse(argv)
      setup = StructuredSetup.new DEFAULT_SETUP
      [:accents, :preparatory].each do |o|
        setup[:output][:pointing].delete o
      end

      # TODO the setup below doesn't yet respect the structure of the options above
      # TODO many of the options aren't implemented yet, some will never be
      optparse = ::OptionParser.new do |opts|

        opts.separator "== General options"

        opts.on "-o", "--output FILE", "Save output to given path." do |out|
          setup[:general][:output_file] = out
        end

        opts.on "-f", "--format F", "Select output format (latex | console)." do |f|
          setup[:general][:format] = f
        end

        opts.separator "== Input interpretation"

        opts.on "--no-title", "Don't consider the first line to contain a psalm title" do
          setup[:input][:has_title] = false
        end
        opts.on "--set-title TITLE", "Manually set title" do |t|
          setup[:input][:title] = t
        end
        opts.on "--append TEXT", "Text to be appended at the end (before processing)." do |t|
          setup[:input][:append] = t
        end
        opts.on "-j", "--join", "Join all given input files" do
          setup[:input][:join] = true
        end

        opts.separator "== Output formatting"

        opts.on "--skip-title", "Don't set the title" do
          setup[:output][:title][:template] = :no
        end
        opts.on "--title-template [TEMPLATE]", "Use a specified template instead of the default one." do |p|
          setup[:output][:title][:template] = p
        end
        opts.on "-k", "--skip-verses NUM", Integer, "Skip initial verses" do |i|
          setup[:output][:skip_verses] = i
        end

        opts.on "-a", "--accents NUMS", "a:b - Numbers of accents to be pointed in each half-verse" do |str|
          a1, a2 = str.split ':'
          if a1 && a1 != "" then
            setup.get_dv(:output, :pointing, :accents, [])[0] = a1.to_i
          end
          if a2 && a2 != "" then
            setup.get_dv(:output, :pointing, :accents, [])[1] = a2.to_i
          end
        end
        # TODO merge with the previous option to a1[,p1]:a2[,p2]
        opts.on "-p", "--preparatory-syllables NUMS", "a:b - How many preparatory syllables in each half-verse" do |str|
          a1, a2 = str.split ':'
          if a1 && a1 != "" then
            setup.get_dv(:output, :pointing, :preparatory, [])[0] = a1.to_i
          end
          if a2 && a2 != "" then
            setup.get_dv(:output, :pointing, :preparatory, [])[1] = a2.to_i
          end
        end
        opts.on "-t", "--tone TONE", "point accents and preparatory syllables for a given psalm tone (like I.f or VIII.G)" do |str|
          setup[:output][:pointing][:tone] = str
        end

        opts.on "-s", "--accents-style SYM", "underline (default) | bold" do |s|
          sym = s.to_sym
          setup[:output][:pointing][:accent_style] = sym
        end
        # Needs LaTeX package lettrine!
        # TODO
        opts.on "--lettrine", "Large first character of the psalm." do
          setup[:output][:lettrine] = {}
        end
        opts.on "--split-verses", "Each verse part on it's own line" do
          setup[:output][:parts][:novydvur_newlines] = true # like in the psalter of the Novy Dvur Trappist abbey
        end
        # TODO
        opts.on "--pretitle TEXT", "Text to be printed as beginning of the title." do |t|
          setup[:output][:prepend_text] = t
        end
        opts.on "--output-append TEXT", "Text to be appended at the end (of the last line after processing)." do |t|
          setup[:output][:final_add_content] = {:append => t}
        end
        # This is useful when we want to append a doxology after the psalm
        # as a separate paragraph
        # TODO
        opts.on "--linebreak-at-the-end", "Make a line-break after the last line" do
          setup[:output][:line_break_last_line] = true
        end
        opts.on "--dashes", "Dash at the end of each psalm paragraph" do
          setup[:output][:strophes][:end_marks] = :semantic
        end
        # TODO
        opts.on "--no-paragraph", "No empty line after each psalm paragraph." do
          setup[:output][:paragraph_space] = false
        end
        opts.on "--guillemets", "Convert american quotes to french ones (guillemets)." do
          setup[:output][:quote] = :guillemets
        end
        # TODO
        opts.on "-m", "--mark-short-verses", "Insert warning marks in verses that are too short" do
          setup[:output][:mark_short_verses] = true
        end
        opts.on "--wrapper NAME", "Wrap output in a wrapper with the given name" do |n|
          setup[:output][:wrapper][:environment_name] = n
        end
      end

      args = optparse.parse argv

      # use default pointing setup if necessary
      unless setup[:output][:pointing].has_key? :tone
        [:accents, :preparatory].each do |o|
          unless setup[:output][:pointing].has_key? o
            setup[:output][:pointing][o] = DEFAULT_SETUP[:output][:pointing][o].dup
          end
        end
      end

      [setup, args]
    end
  end
end
