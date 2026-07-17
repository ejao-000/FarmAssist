import React from "react";
import { Link, NavLink } from "react-router-dom";

const linkStyle = ({ isActive }) => ({
  padding: "10px 12px",
  textDecoration: "none",
  color: isActive ? "#0b5fff" : "#243041",
  fontWeight: isActive ? 700 : 500,
});

export default function Navbar() {
  return (
    <div
      style={{
        position: "sticky",
        top: 0,
        background: "#fff",
        borderBottom: "1px solid #e7edf4",
        zIndex: 10,
      }}
    >
      <div style={{ maxWidth: 1100, margin: "0 auto", padding: "10px 16px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 16 }}>
          <div style={{ fontWeight: 800, letterSpacing: 0.2 }}>FarmAssist</div>
          <nav style={{ display: "flex", flexWrap: "wrap", gap: 4 }}>
            <NavLink to="/" style={linkStyle}>
              Dashboard
            </NavLink>
            <NavLink to="/inventory" style={linkStyle}>
              Inventory
            </NavLink>
            <NavLink to="/sales" style={linkStyle}>
              Sales
            </NavLink>
            <NavLink to="/weather" style={linkStyle}>
              Weather
            </NavLink>
            <NavLink to="/disease-results" style={linkStyle}>
              Disease
            </NavLink>
            <NavLink to="/ai-logs" style={linkStyle}>
              AI Logs
            </NavLink>
            <NavLink to="/notifications" style={linkStyle}>
              Notifications
            </NavLink>
            <NavLink to="/users" style={linkStyle}>
              Users
            </NavLink>
            <NavLink to="/products" style={linkStyle}>
              Products
            </NavLink>
          </nav>
          <div style={{ marginLeft: "auto", color: "#6b7785", fontSize: 12 }}>
            Web Admin
          </div>
        </div>
      </div>
    </div>
  );
}
