import React from "react";

const colors = {
  ok: { bg: "#e9fff2", fg: "#167a3a", bd: "#b9f3cd" },
  warn: { bg: "#fff7e6", fg: "#7a4a00", bd: "#ffe2a8" },
  bad: { bg: "#ffecec", fg: "#9a1c1c", bd: "#ffbaba" },
  info: { bg: "#eef3ff", fg: "#214b9b", bd: "#ccd9ff" },
};

export default function StatusPill({ status = "info", text }) {
  const c = colors[status] || colors.info;
  return (
    <span
      style={{
        display: "inline-flex",
        alignItems: "center",
        border: `1px solid ${c.bd}`,
        background: c.bg,
        color: c.fg,
        padding: "4px 10px",
        borderRadius: 999,
        fontSize: 12,
        fontWeight: 700,
      }}
    >
      {text || status}
    </span>
  );
}
