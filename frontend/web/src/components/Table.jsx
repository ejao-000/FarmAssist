import React from "react";

export default function Table({ columns, rows }) {
  return (
    <div style={{ overflowX: "auto", border: "1px solid #e7edf4", borderRadius: 10 }}>
      <table style={{ width: "100%", borderCollapse: "collapse", minWidth: 700 }}>
        <thead style={{ background: "#f7fbff" }}>
          <tr>
            {columns.map((c) => (
              <th
                key={c.key}
                style={{
                  textAlign: "left",
                  padding: "12px 14px",
                  borderBottom: "1px solid #e7edf4",
                  fontSize: 12,
                  color: "#4d5a6b",
                  fontWeight: 800,
                }}
              >
                {c.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {(rows || []).map((r, i) => (
            <tr key={r.id ?? i}>
              {columns.map((c) => (
                <td key={c.key} style={{ padding: "12px 14px", borderBottom: "1px solid #f0f5fa", fontSize: 13 }}>
                  {c.render ? c.render(r) : r[c.key]}
                </td>
              ))}
            </tr>
          ))}
          {(rows || []).length === 0 && (
            <tr>
              <td colSpan={columns.length} style={{ padding: 16, color: "#6b7785" }}>
                No data.
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
