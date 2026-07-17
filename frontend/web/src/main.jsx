import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";

import Dashboard from "./pages/dashboard.jsx";
import Users from "./pages/users.jsx";
import Products from "./pages/products.jsx";
import Inventory from "./pages/inventory.jsx";
import Sales from "./pages/sales.jsx";
import Weather from "./pages/weather.jsx";
import DiseaseResults from "./pages/disease_results.jsx";
import AiLogs from "./pages/ai_logs.jsx";
import Notifications from "./pages/notifications.jsx";

import Navbar from "./components/Navbar.jsx";

function AppLayout() {
  return (
    <div>
      <Navbar />
      <div style={{ maxWidth: 1100, margin: "16px auto", padding: "0 16px" }}>
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/users" element={<Users />} />
          <Route path="/products" element={<Products />} />
          <Route path="/inventory" element={<Inventory />} />
          <Route path="/sales" element={<Sales />} />
          <Route path="/weather" element={<Weather />} />
          <Route path="/disease-results" element={<DiseaseResults />} />
          <Route path="/ai-logs" element={<AiLogs />} />
          <Route path="/notifications" element={<Notifications />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </div>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <BrowserRouter>
      <AppLayout />
    </BrowserRouter>
  </React.StrictMode>
);
