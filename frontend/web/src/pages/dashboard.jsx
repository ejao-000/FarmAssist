import React, { useEffect, useState } from "react";
import { httpGet } from "../api/http_client.js";
import StatusPill from "../components/StatusPill.jsx";

export default function Dashboard() {
  const [data, setData] = useState(null);
  const [err, setErr] = useState("");

  useEffect(() => {
    (async () => {
      try {
        // adjust endpoint when you confirm ROUTES.md
        const res = await httpGet("/api/dashboard/summary");
        setData(res);
      } catch (e) {
        setErr(e.message);
      }
    })();
  }, []);

  return (
    <div>
      <h2 style={{ margin: "8px 0 12px" }}>Dashboard</h2>
      {err && <div style={{ color: "#9a1c1c", marginBottom: 12 }}>{err}</div>}
      <div style={{ display: "grid", gridTemplateColumns: "repeat(3, minmax(0, 1fr))", gap: 12 }}>
        <div style={{ border: "1px solid #e7edf4", borderRadius: 12, padding: 14 }}>
          <div style={{ color: "#6b7785", fontSize: 12 }}>Inventory Items</div>
          <div style={{ fontSize: 28, fontWeight: 900 }}>{data?.inventoryCount ?? "-"}</div>
          <div style={{ marginTop: 8 }}><StatusPill status="ok" text="Healthy" /></div>
        </div>
        <div style={{ border: "1px solid #e7edf4", borderRadius: 12, padding: 14 }}>
          <div style={{ color: "#6b7785", fontSize: 12 }}>Sales Today</div>
          <div style={{ fontSize: 28, fontWeight: 900 }}>{data?.salesToday ?? "-"}</div>
          <div style={{ marginTop: 8 }}><StatusPill status="info" text="Tracking" /></div>
        </div>
        <div style={{ border: "1px solid #e7edf4", borderRadius: 12, padding: 14 }}>
          <div style={{ color: "#6b7785", fontSize: 12 }}>New Inferences</div>
          <div style={{ fontSize: 28, fontWeight: 900 }}>{data?.inferenceCount ?? "-"}</div>
          <div style={{ marginTop: 8 }}><StatusPill status="warn" text="Review queue" /></div>
        </div>
      </div>
    </div>
  );
}
