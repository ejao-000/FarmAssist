import React, { useEffect, useState } from "react";
import { httpGet } from "../api/http_client.js";
import Table from "../components/Table.jsx";

export default function Inventory() {
  const [rows, setRows] = useState([]);
  const [err, setErr] = useState("");

  useEffect(() => {
    (async () => {
      try {
        const res = await httpGet("/api/inventory");
        setRows(res?.items ?? res ?? []);
      } catch (e) {
        setErr(e.message);
      }
    })();
  }, []);

  return (
    <div>
      <h2 style={{ margin: "8px 0 12px" }}>Inventory</h2>
      {err && <div style={{ color: "#9a1c1c", marginBottom: 12 }}>{err}</div>}
      <Table
        columns={[
          { key: "productName", header: "Product" },
          { key: "quantity", header: "Quantity" },
          { key: "unit", header: "Unit" },
          { key: "updatedAt", header: "Updated" },
        ]}
        rows={rows}
      />
    </div>
  );
}
