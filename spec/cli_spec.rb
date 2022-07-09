# coding: utf-8
require 'aruba/rspec'

describe 'CLI', type: :aruba do
  let(:psalm_path) { File.expand_path '../psalms/ps116.pslm', __FILE__ }

  describe 'minimum input' do
    describe 'no options or arguments' do
      it 'fails' do
        run_command_and_stop('pslm.rb', fail_on_error: false)
        expect(last_command_started.exit_status).to eq 1
        expect(all_stderr).to include 'Program expects filenames'
      end
    end

    describe 'single filename' do
      it 'prints default LaTeX output' do
        run_command_and_stop("pslm.rb #{psalm_path}")
        expect(all_stdout).to include 'Lau\-dá\-te Dó\-mi\-num, \underline{om}\-nes \underline{Gen}\-tes:\asterisk'
      end
    end
  end
end
