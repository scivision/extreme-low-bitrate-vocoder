classdef (SharedTestFixtures={ matlab.unittest.fixtures.PathFixture(fileparts(fileparts(mfilename('fullpath'))))}) ...
  TestUnit < matlab.unittest.TestCase

properties
root
inputAudio
end


properties (TestParameter)
procType = {'keps', 'LPC'}
end


methods (TestMethodSetup)
function test_dirs(tc)
tc.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
tc.root = fileparts(fileparts(mfilename('fullpath')));
tc.inputAudio = fullfile(tc.root, "inputs/eeOrig.wav");
end
end


methods(Test)

function test_compare_output_waveform(tc, procType)
refFile = fullfile(tc.root, "ref", procType, "output.mat");

ref = load(refFile);

[~, xSynth, xSynthW, Excite, TractPoles, TractG] = Main(tc.inputAudio, procType, false, false);

tc.assertEqual(xSynth, ref.xSynth, RelTol=0.0001, AbsTol=1e-6)
tc.assertEqual(xSynthW, ref.xSynthW, RelTol=0.0001, AbsTol=1e-6)
tc.assertEqual(Excite, ref.Excite, RelTol=0.0001, AbsTol=1e-6)
tc.assertEqual(TractPoles, ref.TractPoles, RelTol=0.0001, AbsTol=1e-6)
tc.assertEqual(TractG, ref.TractG, RelTol=0.0001, AbsTol=1e-6)

end

end

end