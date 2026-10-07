"use client";

import { useEffect, useState, useMemo } from "react";
import axios from "axios";
import { Building2, ShieldCheck, Mail, Calendar, Hash, CheckCircle, XCircle, Clock } from "lucide-react";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api";

export default function ManagersPage() {
  const [managers, setManagers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  
  // Tab State: "Pending", "Active", "Suspended"
  const [activeTab, setActiveTab] = useState("Pending");

  useEffect(() => {
    fetchManagers();
  }, []);

  async function fetchManagers() {
    try {
      setLoading(true);
      const response = await axios.get(`${API_URL}/admin/managers`);
      setManagers(response.data);
    } catch (err) {
      console.error("Failed to fetch managers:", err);
    } finally {
      setLoading(false);
    }
  }

  const updateManagerStatus = async (id: string, isApproved: boolean) => {
    try {
      await axios.patch(`${API_URL}/admin/managers/${id}/status`, { isApproved });
      // Update local state to reflect the change
      setManagers(prev => prev.map(m => (m._id === id ? { ...m, isApproved } : m)));
    } catch (err) {
      console.error("Failed to update manager status:", err);
      alert("Failed to update manager status");
    }
  };

  const displayedManagers = useMemo(() => {
    return managers.filter(m => {
      if (activeTab === "Pending") return !m.isApproved;
      if (activeTab === "Active") return m.isApproved;
      if (activeTab === "Suspended") return m.isSuspended; // Note: if you have a suspended field in the future
      return true;
    });
  }, [managers, activeTab]);

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold tracking-tight text-slate-900">Facility Managers</h1>
        <p className="text-slate-500 text-sm mt-1">Review and manage verification for sports venue owners.</p>
      </div>

      <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
        {/* Tabs */}
        <div className="flex items-center border-b border-slate-200 bg-slate-50/50">
          <TabButton name="Pending" active={activeTab === "Pending"} onClick={() => setActiveTab("Pending")} />
          <TabButton name="Active" active={activeTab === "Active"} onClick={() => setActiveTab("Active")} />
        </div>

        <div className="p-6">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm text-slate-600">
              <thead className="bg-slate-50 text-xs uppercase text-slate-500 font-semibold border-b border-slate-200">
                <tr>
                  <th className="px-4 py-3 rounded-l-lg">Manager</th>
                  <th className="px-4 py-3">Assigned Venues</th>
                  <th className="px-4 py-3">Joined Date</th>
                  <th className="px-4 py-3">Status</th>
                  <th className="px-4 py-3 rounded-r-lg text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {loading ? (
                  <tr>
                    <td colSpan={5} className="text-center py-8 text-slate-500 font-medium">Loading managers...</td>
                  </tr>
                ) : displayedManagers.length > 0 ? (
                  displayedManagers.map((manager: any) => (
                    <TableRow 
                      key={manager._id} 
                      manager={manager} 
                      onApprove={() => updateManagerStatus(manager._id, true)} 
                      onReject={() => updateManagerStatus(manager._id, false)} 
                    />
                  ))
                ) : (
                  <tr>
                    <td colSpan={5} className="text-center py-12 text-slate-500">
                      <div className="flex flex-col items-center gap-2">
                        <CheckCircle className="w-8 h-8 text-slate-300" />
                        <span className="font-medium">No {activeTab.toLowerCase()} managers found.</span>
                      </div>
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}

function TabButton({ name, active, onClick }: { name: string, active: boolean, onClick: () => void }) {
  return (
    <button 
      onClick={onClick}
      className={`px-6 py-3.5 text-sm font-medium transition-colors border-b-2 ${
        active 
          ? "border-emerald-600 text-emerald-700 bg-white" 
          : "border-transparent text-slate-500 hover:text-slate-700 hover:bg-slate-50"
      }`}
    >
      {name}
    </button>
  );
}

function TableRow({ manager, onApprove, onReject }: { manager: any, onApprove: () => void, onReject: () => void }) {
  const isApproved = manager.isApproved;
  const numVenues = manager.assignedVenues?.length || 0;

  return (
    <tr className="hover:bg-slate-50 transition-colors">
      <td className="px-4 py-4">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-full bg-indigo-100 text-indigo-700 flex items-center justify-center font-bold">
            {manager.fullName?.charAt(0)?.toUpperCase() || "M"}
          </div>
          <div>
            <div className="font-semibold text-slate-900">{manager.fullName || "Unknown"}</div>
            <div className="text-xs text-slate-500 flex items-center gap-1 mt-0.5">
              <Mail className="w-3 h-3" />
              {manager.email}
            </div>
          </div>
        </div>
      </td>
      <td className="px-4 py-4">
        <div className="flex items-center gap-2 text-slate-700 font-medium">
          <Building2 className="w-4 h-4 text-slate-400" />
          {numVenues} {numVenues === 1 ? "Venue" : "Venues"}
        </div>
      </td>
      <td className="px-4 py-4">
        <div className="flex items-center gap-2 text-slate-600">
          <Calendar className="w-4 h-4 text-slate-400" />
          {new Date(manager.createdAt).toLocaleDateString()}
        </div>
      </td>
      <td className="px-4 py-4">
        <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium ${isApproved
            ? "bg-emerald-50 text-emerald-700 border border-emerald-200"
            : "bg-amber-50 text-amber-700 border border-amber-200"
          }`}>
          {isApproved ? <CheckCircle className="w-3 h-3 text-emerald-600" /> : <Clock className="w-3 h-3 text-amber-600" />}
          {isApproved ? "Approved" : "Pending Review"}
        </span>
      </td>
      <td className="px-4 py-4 text-right">
        {!isApproved ? (
          <div className="flex items-center justify-end gap-2">
            <button 
              onClick={onReject}
              className="text-xs font-medium px-3 py-1.5 bg-white hover:bg-rose-50 text-rose-600 rounded-md border border-slate-200 transition-colors"
            >
              Reject
            </button>
            <button 
              onClick={onApprove}
              className="text-xs font-medium px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-md transition-colors shadow-sm"
            >
              Approve
            </button>
          </div>
        ) : (
          <button 
            onClick={onReject}
            className="text-xs font-medium px-3 py-1.5 bg-white hover:bg-rose-50 text-rose-600 rounded-md border border-slate-200 transition-colors"
          >
            Suspend Venue Access
          </button>
        )}
      </td>
    </tr>
  );
}
