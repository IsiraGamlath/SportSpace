"use client";

import { useEffect, useState, useMemo } from "react";
import axios from "axios";
import { User, Shield, ShieldCheck, Mail, Calendar, Hash, Filter, ArrowUpDown } from "lucide-react";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api";

export default function UsersPage() {
  const [users, setUsers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  
  // Filtering and Sorting State
  const [roleFilter, setRoleFilter] = useState("All");
  const [dateSort, setDateSort] = useState("Newest");

  useEffect(() => {
    async function fetchUsers() {
      try {
        const response = await axios.get(`${API_URL}/admin/users`);
        setUsers(response.data);
      } catch (err) {
        console.error("Failed to fetch users:", err);
      } finally {
        setLoading(false);
      }
    }
    fetchUsers();
  }, []);

  // Compute the filtered and sorted users
  const displayedUsers = useMemo(() => {
    let filtered = [...users];
    
    if (roleFilter !== "All") {
      filtered = filtered.filter(u => u.role === roleFilter);
    }

    filtered.sort((a, b) => {
      const dateA = new Date(a.createdAt).getTime();
      const dateB = new Date(b.createdAt).getTime();
      return dateSort === "Newest" ? dateB - dateA : dateA - dateB;
    });

    return filtered;
  }, [users, roleFilter, dateSort]);

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold tracking-tight text-slate-900">Users</h1>
        <p className="text-slate-500 text-sm mt-1">Manage all registered players and facility managers.</p>
      </div>

      <div className="bg-white border border-slate-200 rounded-xl p-6 shadow-sm">
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6">
          <div>
            <h2 className="text-lg font-semibold text-slate-900">All Users</h2>
            <p className="text-xs text-slate-500">A complete list of users in the system</p>
          </div>
          
          <div className="flex flex-wrap items-center gap-3">
            <div className="flex items-center bg-slate-50 border border-slate-200 rounded-lg px-3 py-1.5 gap-2">
              <Filter className="w-4 h-4 text-slate-400" />
              <select 
                value={roleFilter}
                onChange={(e) => setRoleFilter(e.target.value)}
                className="bg-transparent text-sm text-slate-700 font-medium focus:outline-none cursor-pointer"
              >
                <option value="All">All Roles</option>
                <option value="Player">Players</option>
                <option value="Facility Manager">Facility Managers</option>
              </select>
            </div>

            <div className="flex items-center bg-slate-50 border border-slate-200 rounded-lg px-3 py-1.5 gap-2">
              <ArrowUpDown className="w-4 h-4 text-slate-400" />
              <select 
                value={dateSort}
                onChange={(e) => setDateSort(e.target.value)}
                className="bg-transparent text-sm text-slate-700 font-medium focus:outline-none cursor-pointer"
              >
                <option value="Newest">Newest Joined</option>
                <option value="Oldest">Oldest Joined</option>
              </select>
            </div>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-slate-600">
            <thead className="bg-slate-50 text-xs uppercase text-slate-500 font-semibold border-b border-slate-200">
              <tr>
                <th className="px-4 py-3 rounded-l-lg">User</th>
                <th className="px-4 py-3">Role</th>
                <th className="px-4 py-3">Email</th>
                <th className="px-4 py-3">Joined Date</th>
                <th className="px-4 py-3 rounded-r-lg text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {loading ? (
                <tr>
                  <td colSpan={5} className="text-center py-8 text-slate-500 font-medium">Loading users...</td>
                </tr>
              ) : displayedUsers.length > 0 ? (
                displayedUsers.map((user: any) => (
                  <TableRow key={user._id} user={user} />
                ))
              ) : (
                <tr>
                  <td colSpan={5} className="text-center py-8 text-slate-500 font-medium">No users match your filters.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

function TableRow({ user }: { user: any }) {
  const isManager = user.role === "Facility Manager";

  return (
    <tr className="hover:bg-slate-50 transition-colors">
      <td className="px-4 py-4">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center font-bold">
            {user.fullName?.charAt(0)?.toUpperCase() || "U"}
          </div>
          <div>
            <div className="font-semibold text-slate-900">{user.fullName || "Unknown"}</div>
            <div className="text-xs text-slate-500 flex items-center gap-1 mt-0.5">
              <Hash className="w-3 h-3" />
              {user.firebaseUid?.substring(0, 8) || "N/A"}...
            </div>
          </div>
        </div>
      </td>
      <td className="px-4 py-4">
        <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium ${isManager
            ? "bg-indigo-50 text-indigo-700 border border-indigo-200"
            : "bg-emerald-50 text-emerald-700 border border-emerald-200"
          }`}>
          {isManager ? <ShieldCheck className="w-3 h-3 text-indigo-600" /> : <User className="w-3 h-3 text-emerald-600" />}
          {user.role}
        </span>
      </td>
      <td className="px-4 py-4">
        <div className="flex items-center gap-2 text-slate-600">
          <Mail className="w-4 h-4 text-slate-400" />
          {user.email}
        </div>
      </td>
      <td className="px-4 py-4">
        <div className="flex items-center gap-2 text-slate-600">
          <Calendar className="w-4 h-4 text-slate-400" />
          {new Date(user.createdAt).toLocaleDateString()}
        </div>
      </td>
      <td className="px-4 py-4 text-right">
        <button className="text-xs font-medium px-3 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-md border border-slate-200 transition-colors">
          View Profile
        </button>
      </td>
    </tr>
  );
}
