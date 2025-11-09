function plan = buildfile

plan = buildplan(localfunctions);

pkgDir = fullfile(plan.RootFolder);
test_root = fullfile(plan.RootFolder, 'test');
reportDir = fullfile(plan.RootFolder, 'reports');
if ~isfolder(reportDir)
  mkdir(reportDir);
end

if isMATLABReleaseOlderThan('R2023a')
  plan('test') = matlab.buildtool.Task(Actions=@(context) legacy_test(context, test_root));
else
  plan('test') = matlab.buildtool.tasks.TestTask(test_root, SourceFiles=pkgDir);
end

if ~isMATLABReleaseOlderThan('R2024a')

  coverageReport = fullfile(reportDir, 'coverage-report.html');
  try
    report = matlabtest.plugins.codecoverage.StandaloneReport(coverageReport);
  catch
    report = coverageReport;
  end
  plan('coverage') = plan('test').addCodeCoverage(report);
  plan('coverage').DisableIncremental = true;
end

end


function legacy_test(~, test_root)
r = runtests(test_root);

assert(~isempty(r), 'No tests were run')
assertSuccess(r)
end



function checkTask(context)
root = context.Plan.RootFolder;

c = codeIssues(root, IncludeSubfolders=true);

if isempty(c.Issues)
  fprintf('%d files checked OK with %s under %s\n', numel(c.Files), c.Release, root)
else
  disp(c.Issues)
  error("Errors found in " + join(c.Issues.Location, newline))
end

end
