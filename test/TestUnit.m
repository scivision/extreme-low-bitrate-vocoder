classdef (SharedTestFixtures={ matlab.unittest.fixtures.PathFixture(fileparts(fileparts(mfilename('fullpath'))))}) ...
  TestUnit < matlab.unittest.TestCase

properties
refOutFile = 'ref/output.mat'
root
inputAudio
end


methods (TestMethodSetup)
function test_dirs(tc)
tc.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
tc.root = fileparts(fileparts(mfilename('fullpath')));
tc.inputAudio = fullfile(tc.root, "inputs/eeOrig.wav");
end
end


methods(Test)

function test_compare_output_waveform(tc)
ref = load(fullfile(tc.root, tc.refOutFile));

[xSynth, xSynthW, Excite, TractPoles, TractG] = Main(tc.inputAudio, false, false);

tc.assertEqual(xSynth, ref.xSynth, RelTol=0.0001)
tc.assertEqual(xSynthW, ref.xSynthW, RelTol=0.0001);
tc.assertEqual(Excite, ref.Excite, RelTol=0.0001);
tc.assertEqual(TractPoles, ref.TractPoles, RelTol=0.0001);
tc.assertEqual(TractG, ref.TractG, RelTol=0.0001);

end

end

end