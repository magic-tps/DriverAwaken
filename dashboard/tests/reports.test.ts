import { describe, expect, it } from 'vitest';
import { demoReducer, initialDemo } from '../src/lib/demo';
import { csvCell, incidentCsv } from '../src/lib/reports';
describe('safe operational report exports', () => {
  it('neutralizes spreadsheet formula injection including leading whitespace', () => {
    for (const payload of ['=1+1', '+cmd', '-formula', '@SUM(A1)', '  =1', '\t=1', '\r\n=1']) expect(csvCell(payload)).toBe(`"'${payload}"`);
    expect(csvCell('BUS-001')).toBe('"BUS-001"');
    expect(csvCell('quote " and, newline\n')).toBe('"quote "" and, newline\n"');
  });
  it('keeps detection and reception separate, exports derived status and no fabricated rows', () => {
    expect(incidentCsv([], []).split('\r\n')).toHaveLength(1);
    const state = demoReducer(demoReducer(demoReducer(initialDemo(), { type: 'START_TRIP' }), { type: 'DISCONNECT' }), { type: 'CRITICAL' });
    const csv = incidentCsv(state.incidents, []);
    expect(csv.split('\r\n')).toHaveLength(2);
    expect(csv).toContain(`"${state.incidents[0].id}"`);
    expect(csv).toContain('"85","NEW"');
    expect(csv).toContain(',"","85"');
    expect(csv).not.toContain('driver-demo-01');
  });
});
