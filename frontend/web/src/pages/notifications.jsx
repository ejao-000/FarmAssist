import React, { useEffect, useState } from "react";
import { httpGet } from "../api/http_client.js";
import Table from "../components/Table.jsx";

export default function Notifications() {
  const [rows, setRows] = useState([]);
  const [err, setErr] = useState("");

  useEffect(() => {
    (async () => {
      try {
        const res = await httpGet("/api/notifications");
        setRows(res?.notifications ?? res ?? []);
      } catch (e) {
        setErr(e.message);
      }
    })();
  }, []);

  return (
    <div>
      <h2 style={{ margin: "8px 0 12px" }}>Notifications</h2>
      {err && <div style={{ color: "#9a1c1c", marginBottom: 12 }}>{err}</div>}

      <Table
        columns={[
          { key: "id", header: "ID" },
          { key: "title", header: "Title" },
          { key: "message", header: "Message" },
          { key: "createdAt", header: "Date" },
        ]}
        rows={rows}
      />
    </div>
  );
}
