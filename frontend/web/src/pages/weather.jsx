import React, { useEffect, useState } from "react";
import { httpGet } from "../api/http_client.js";

export default function Weather() {
  const [weather, setWeather] = useState(null);
  const [err, setErr] = useState("");

  useEffect(() => {
    (async () => {
      try {
        const res = await httpGet("/api/weather/current");
        setWeather(res);
      } catch (e) {
        setErr(e.message);
      }
    })();
  }, []);

  return (
    <div>
      <h2 style={{ margin: "8px 0 12px" }}>Weather</h2>
      {err && <div style={{ color: "#9a1c1c", marginBottom: 12 }}>{err}</div>}
      <pre style={{ background: "#f7fbff", padding: 12, borderRadius: 10 }}>
        {weather ? JSON.stringify(weather, null, 2) : "Loading..."}
      </pre>
    </div>
  );
}
