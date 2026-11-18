const fs = require('node:fs');
const path = require('node:path');

const reportPath = process.argv[2];
if (!reportPath) {
  throw new Error('Usage: node scripts/summarize-coverage.cjs <elm-coverage-jsonl>');
}

const events = fs
  .readFileSync(reportPath, 'utf8')
  .split(/\r?\n/)
  .filter(Boolean)
  .map((line) => JSON.parse(line));
const report = events.findLast((event) => event.event === 'coverage');
if (!report?.coverageData) {
  throw new Error('Elm coverage report did not contain coverage data.');
}

const expressions = Object.values(report.coverageData).flat();
const covered = expressions.filter((expression) => expression.count > 0).length;
const total = expressions.length;
if (total === 0) {
  throw new Error('Elm coverage report did not contain any expressions.');
}

const percentage = Math.round((covered / total) * 100);
const color = percentage >= 80 ? 'brightgreen' : percentage >= 60 ? 'yellow' : 'red';
const badge = {
  schemaVersion: 1,
  label: 'Elm test coverage',
  message: `${percentage}%`,
  color,
};

const outputPath = path.join('coverage', 'coverage-badge.json');
fs.mkdirSync(path.dirname(outputPath), { recursive: true });
fs.writeFileSync(outputPath, `${JSON.stringify(badge, null, 2)}\n`);
fs.appendFileSync(process.env.GITHUB_STEP_SUMMARY ?? '/dev/null',
  `## Elm test coverage\n\n**${percentage}%** (${covered}/${total} instrumented expressions)\n`);
console.log(`Elm test coverage: ${percentage}% (${covered}/${total} instrumented expressions)`);
