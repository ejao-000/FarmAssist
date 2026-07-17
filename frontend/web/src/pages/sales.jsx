import React, { useEffect, useState } from "react";
import { httpGet } from "../api/http_client.js";
import Table from "../components/Table.jsx";

export default function Sales() {
  const [rows, setRows] = useState([]);
  const [err, setErr] = useState("");

  useEffect(() => {
    (async () => {
      try {
        const res = await httpGet("/api/sales");
        setRows(res?.receipts ?? res ?? []);
      } catch (e) {
        setErr(e.message);
      }
    })();
  }, []);

  return (
    <div>
      <h2 style={{ margin: "8px 0 12px" }}>Sales</h2>
      {err && <div style={{ color: "#9a1c1c", marginBottom: 12 }}>{err}</div>}
      <Table
        columns={[
          { key: "id", header: "Receipt ID" },
          { key: "customerName", header: "Customer" },
          { key: "total", header: "Total" },
          { key: "createdAt", header: "Date" },
        ]}
        rows={rows}
      />
    </div>
  );
}
