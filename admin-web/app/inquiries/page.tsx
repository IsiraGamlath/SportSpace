"use client";

import { useEffect, useState, useMemo } from "react";
import axios from "axios";
import {
  HelpCircle,
  Accessibility,
  MessageSquare,
  Clock,
  User,
  Filter,
  ArrowUpDown,
  CheckCircle,
  AlertCircle,
  Clock3,
  Search,
  Eye,
  Trash2,
  X,
  Building2,
  Send,
  RefreshCw,
  Sparkles,
} from "lucide-react";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api";

interface Inquiry {
  _id: string;
  id: string;
  facilityId: string;
  facilityName?: string;
  userId: string;
  type: "generalEnquiry" | "accessibilityRequest";
  message: string;
  status: "pending" | "in_review" | "resolved";
  createdAt: string;
  updatedAt: string;
  userName?: string;
  userEmail?: string;
  userRole?: string;
}

export default function InquiriesPage() {
  const [inquiries, setInquiries] = useState<Inquiry[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  // Filters & Search
  const [searchQuery, setSearchQuery] = useState("");
  const [typeFilter, setTypeFilter] = useState<string>("All");
  const [statusFilter, setStatusFilter] = useState<string>("All");
  const [sortOrder, setSortOrder] = useState<"Newest" | "Oldest">("Newest");

  // Selected Inquiry Modal
  const [selectedInquiry, setSelectedInquiry] = useState<Inquiry | null>(null);
  const [isUpdatingStatus, setIsUpdatingStatus] = useState(false);

  useEffect(() => {
    fetchInquiries();
  }, []);

  async function fetchInquiries() {
    try {
      setLoading(true);
      const res = await axios.get(`${API_URL}/contact-requests`);
      setInquiries(Array.isArray(res.data) ? res.data : []);
    } catch (err) {
      console.error("Failed to fetch contact inquiries:", err);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }

  const handleRefresh = () => {
    setRefreshing(true);
    fetchInquiries();
  };

  const handleStatusUpdate = async (id: string, newStatus: "pending" | "in_review" | "resolved") => {
    try {
      setIsUpdatingStatus(true);
      await axios.put(`${API_URL}/contact-requests/${id}`, { status: newStatus });
      setInquiries((prev) =>
        prev.map((item) => (item.id === id || item._id === id ? { ...item, status: newStatus } : item))
      );
      if (selectedInquiry && (selectedInquiry.id === id || selectedInquiry._id === id)) {
        setSelectedInquiry((prev) => (prev ? { ...prev, status: newStatus } : null));
      }
    } catch (err) {
      console.error("Failed to update status:", err);
      alert("Failed to update inquiry status. Please try again.");
    } finally {
      setIsUpdatingStatus(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Are you sure you want to delete this submission?")) return;
    try {
      await axios.delete(`${API_URL}/contact-requests/${id}`);
      setInquiries((prev) => prev.filter((item) => item.id !== id && item._id !== id));
      if (selectedInquiry && (selectedInquiry.id === id || selectedInquiry._id === id)) {
        setSelectedInquiry(null);
      }
    } catch (err) {
      console.error("Failed to delete inquiry:", err);
      alert("Failed to delete inquiry. Please try again.");
    }
  };

  // Filter and sort inquiries
  const displayedInquiries = useMemo(() => {
    let result = [...inquiries];

    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      result = result.filter(
        (i) =>
          i.message?.toLowerCase().includes(q) ||
          i.userName?.toLowerCase().includes(q) ||
          i.userEmail?.toLowerCase().includes(q) ||
          i.facilityId?.toLowerCase().includes(q) ||
          i.facilityName?.toLowerCase().includes(q)
      );
    }

    if (typeFilter !== "All") {
      result = result.filter((i) => i.type === typeFilter);
    }

    if (statusFilter !== "All") {
      result = result.filter((i) => i.status === statusFilter);
    }

    result.sort((a, b) => {
      const dateA = new Date(a.createdAt).getTime();
      const dateB = new Date(b.createdAt).getTime();
      return sortOrder === "Newest" ? dateB - dateA : dateA - dateB;
    });

    return result;
  }, [inquiries, searchQuery, typeFilter, statusFilter, sortOrder]);

  // Stats
  const stats = useMemo(() => {
    const total = inquiries.length;
    const general = inquiries.filter((i) => i.type === "generalEnquiry").length;
    const accessibility = inquiries.filter((i) => i.type === "accessibilityRequest").length;
    const pending = inquiries.filter((i) => i.status === "pending" || !i.status).length;
    const resolved = inquiries.filter((i) => i.status === "resolved").length;
    return { total, general, accessibility, pending, resolved };
  }, [inquiries]);

  const formatDate = (isoString: string) => {
    if (!isoString) return "N/A";
    const date = new Date(isoString);
    return date.toLocaleDateString("en-US", {
      month: "short",
      day: "numeric",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  const formatFacilityName = (facilityId: string, facilityName?: string) => {
    if (facilityName && facilityName.trim()) return facilityName;
    if (!facilityId || facilityId === "general") return "General Venue Enquiry";
    return facilityId
      .split("_")
      .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
      .join(" ");
  };

  return (
    <div className="space-y-8 max-w-7xl mx-auto">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2.5">
            <h1 className="text-3xl font-bold tracking-tight text-slate-900">Inquiries</h1>
            <span className="px-2.5 py-0.5 text-xs font-semibold rounded-full bg-emerald-100 text-emerald-800">
              Community / Public
            </span>
          </div>
          <p className="text-slate-500 text-sm mt-1">
            Review and respond to all General Enquiries and Accessibility Requests submitted by Community / Tertiary Users.
          </p>
        </div>

        <button
          onClick={handleRefresh}
          disabled={loading || refreshing}
          className="inline-flex items-center gap-2 px-3.5 py-2 text-sm font-medium text-slate-700 bg-white border border-slate-200 rounded-lg hover:bg-slate-50 transition-colors shadow-sm cursor-pointer disabled:opacity-50"
        >
          <RefreshCw className={`w-4 h-4 text-slate-500 ${refreshing ? "animate-spin text-emerald-600" : ""}`} />
          Refresh Submissions
        </button>
      </div>

      {/* Metric Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="bg-white border border-slate-200 rounded-xl p-5 shadow-sm hover:shadow-md transition-shadow">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Total Submissions</span>
            <div className="w-8 h-8 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center">
              <MessageSquare className="w-4 h-4" />
            </div>
          </div>
          <div className="mt-3">
            <span className="text-2xl font-bold text-slate-900">{stats.total}</span>
            <p className="text-xs text-slate-500 mt-1">From Community & Tertiary Users</p>
          </div>
        </div>

        <div className="bg-white border border-slate-200 rounded-xl p-5 shadow-sm hover:shadow-md transition-shadow">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-slate-500 uppercase tracking-wider">General Enquiries</span>
            <div className="w-8 h-8 rounded-lg bg-sky-50 text-sky-600 flex items-center justify-center">
              <HelpCircle className="w-4 h-4" />
            </div>
          </div>
          <div className="mt-3">
            <span className="text-2xl font-bold text-sky-700">{stats.general}</span>
            <p className="text-xs text-slate-500 mt-1">Venue, parking & general questions</p>
          </div>
        </div>

        <div className="bg-white border border-slate-200 rounded-xl p-5 shadow-sm hover:shadow-md transition-shadow">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Accessibility Requests</span>
            <div className="w-8 h-8 rounded-lg bg-purple-50 text-purple-600 flex items-center justify-center">
              <Accessibility className="w-4 h-4" />
            </div>
          </div>
          <div className="mt-3">
            <span className="text-2xl font-bold text-purple-700">{stats.accessibility}</span>
            <p className="text-xs text-slate-500 mt-1">Ramp, parking & special accommodations</p>
          </div>
        </div>

        <div className="bg-white border border-slate-200 rounded-xl p-5 shadow-sm hover:shadow-md transition-shadow">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Pending Attention</span>
            <div className="w-8 h-8 rounded-lg bg-amber-50 text-amber-600 flex items-center justify-center">
              <AlertCircle className="w-4 h-4" />
            </div>
          </div>
          <div className="mt-3">
            <div className="flex items-baseline gap-2">
              <span className="text-2xl font-bold text-amber-600">{stats.pending}</span>
              <span className="text-xs text-slate-400">/ {stats.resolved} resolved</span>
            </div>
            <p className="text-xs text-slate-500 mt-1">Awaiting staff review or response</p>
          </div>
        </div>
      </div>

      {/* Main Table Card */}
      <div className="bg-white border border-slate-200 rounded-xl p-6 shadow-sm space-y-6">
        {/* Table Controls */}
        <div className="flex flex-col lg:flex-row items-stretch lg:items-center justify-between gap-4">
          {/* Search bar */}
          <div className="relative flex-1 max-w-md">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              placeholder="Search by message body, user, or facility..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:bg-white transition-all"
            />
            {searchQuery && (
              <button
                onClick={() => setSearchQuery("")}
                className="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 cursor-pointer"
              >
                <X className="w-3.5 h-3.5" />
              </button>
            )}
          </div>

          {/* Filter options */}
          <div className="flex flex-wrap items-center gap-3">
            {/* Category / Type Filter */}
            <div className="flex items-center bg-slate-50 border border-slate-200 rounded-lg px-3 py-1.5 gap-2">
              <Filter className="w-4 h-4 text-slate-400" />
              <select
                value={typeFilter}
                onChange={(e) => setTypeFilter(e.target.value)}
                className="bg-transparent text-sm text-slate-700 font-medium focus:outline-none cursor-pointer"
              >
                <option value="All">All Types</option>
                <option value="generalEnquiry">General Enquiries</option>
                <option value="accessibilityRequest">Accessibility Requests</option>
              </select>
            </div>

            {/* Status Filter */}
            <div className="flex items-center bg-slate-50 border border-slate-200 rounded-lg px-3 py-1.5 gap-2">
              <span className="w-2 h-2 rounded-full bg-slate-400" />
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                className="bg-transparent text-sm text-slate-700 font-medium focus:outline-none cursor-pointer"
              >
                <option value="All">All Statuses</option>
                <option value="pending">Pending</option>
                <option value="in_review">In Review</option>
                <option value="resolved">Resolved</option>
              </select>
            </div>

            {/* Sort order */}
            <div className="flex items-center bg-slate-50 border border-slate-200 rounded-lg px-3 py-1.5 gap-2">
              <ArrowUpDown className="w-4 h-4 text-slate-400" />
              <select
                value={sortOrder}
                onChange={(e) => setSortOrder(e.target.value as "Newest" | "Oldest")}
                className="bg-transparent text-sm text-slate-700 font-medium focus:outline-none cursor-pointer"
              >
                <option value="Newest">Newest First</option>
                <option value="Oldest">Oldest First</option>
              </select>
            </div>
          </div>
        </div>

        {/* Table list */}
        <div className="overflow-x-auto rounded-lg border border-slate-200">
          <table className="w-full text-left text-sm text-slate-600">
            <thead className="bg-slate-50 text-xs uppercase text-slate-500 font-semibold border-b border-slate-200">
              <tr>
                <th className="px-4 py-3.5">Category</th>
                <th className="px-4 py-3.5 max-w-xs">Message / Body</th>
                <th className="px-4 py-3.5">Added User / Tertiary</th>
                <th className="px-4 py-3.5">Facility</th>
                <th className="px-4 py-3.5">Submitted Time</th>
                <th className="px-4 py-3.5">Status</th>
                <th className="px-4 py-3.5 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200">
              {loading ? (
                <tr>
                  <td colSpan={7} className="text-center py-12 text-slate-400">
                    <div className="flex flex-col items-center justify-center gap-2">
                      <RefreshCw className="w-6 h-6 animate-spin text-emerald-600" />
                      <p className="text-sm font-medium text-slate-600">Loading submissions from database...</p>
                    </div>
                  </td>
                </tr>
              ) : displayedInquiries.length === 0 ? (
                <tr>
                  <td colSpan={7} className="text-center py-16 text-slate-400">
                    <div className="flex flex-col items-center justify-center max-w-sm mx-auto text-center">
                      <div className="w-12 h-12 rounded-full bg-slate-100 flex items-center justify-center mb-3 text-slate-400">
                        <MessageSquare className="w-6 h-6" />
                      </div>
                      <p className="text-base font-semibold text-slate-800">No submissions found</p>
                      <p className="text-xs text-slate-500 mt-1">
                        {searchQuery || typeFilter !== "All" || statusFilter !== "All"
                          ? "Try adjusting your search terms or filters."
                          : "Submissions from Community / Tertiary users will appear here."}
                      </p>
                    </div>
                  </td>
                </tr>
              ) : (
                displayedInquiries.map((inquiry) => {
                  const isAccessibility = inquiry.type === "accessibilityRequest";
                  return (
                    <tr
                      key={inquiry.id || inquiry._id}
                      className="hover:bg-slate-50/80 transition-colors group cursor-pointer"
                      onClick={() => setSelectedInquiry(inquiry)}
                    >
                      {/* Type Badge */}
                      <td className="px-4 py-4 whitespace-nowrap">
                        {isAccessibility ? (
                          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-purple-50 text-purple-700 border border-purple-200">
                            <Accessibility className="w-3.5 h-3.5 text-purple-600" />
                            Accessibility
                          </span>
                        ) : (
                          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-sky-50 text-sky-700 border border-sky-200">
                            <HelpCircle className="w-3.5 h-3.5 text-sky-600" />
                            General Enquiry
                          </span>
                        )}
                      </td>

                      {/* Message Body */}
                      <td className="px-4 py-4 max-w-xs">
                        <p className="text-slate-900 font-medium line-clamp-2 text-sm leading-relaxed">
                          {inquiry.message}
                        </p>
                      </td>

                      {/* Added User / Tertiary */}
                      <td className="px-4 py-4 whitespace-nowrap">
                        <div className="flex items-center gap-2.5">
                          <div className="w-8 h-8 rounded-full bg-slate-100 border border-slate-200 flex items-center justify-center text-slate-600 font-semibold text-xs">
                            {inquiry.userName ? inquiry.userName.charAt(0).toUpperCase() : "U"}
                          </div>
                          <div>
                            <div className="text-xs font-semibold text-slate-800">
                              {inquiry.userName || "Community User"}
                            </div>
                            <div className="flex items-center gap-1 mt-0.5">
                              <span className="text-[11px] font-medium text-emerald-700 bg-emerald-50 px-1.5 py-0.2 rounded border border-emerald-200">
                                {inquiry.userRole || "Community / Public User"}
                              </span>
                            </div>
                            {inquiry.userEmail && (
                              <div className="text-[11px] text-slate-400 mt-0.5">{inquiry.userEmail}</div>
                            )}
                          </div>
                        </div>
                      </td>

                      {/* Facility */}
                      <td className="px-4 py-4 whitespace-nowrap text-xs text-slate-600">
                        <div className="flex items-center gap-1.5 font-medium text-slate-700">
                          <Building2 className="w-3.5 h-3.5 text-slate-400" />
                          {formatFacilityName(inquiry.facilityId, inquiry.facilityName)}
                        </div>
                      </td>

                      {/* Time */}
                      <td className="px-4 py-4 whitespace-nowrap text-xs text-slate-500">
                        <div className="flex items-center gap-1.5">
                          <Clock className="w-3.5 h-3.5 text-slate-400" />
                          <span>{formatDate(inquiry.createdAt)}</span>
                        </div>
                      </td>

                      {/* Status */}
                      <td className="px-4 py-4 whitespace-nowrap">
                        <span
                          className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium ${
                            inquiry.status === "resolved"
                              ? "bg-emerald-50 text-emerald-700 border border-emerald-200"
                              : inquiry.status === "in_review"
                              ? "bg-blue-50 text-blue-700 border border-blue-200"
                              : "bg-amber-50 text-amber-700 border border-amber-200"
                          }`}
                        >
                          <span
                            className={`w-1.5 h-1.5 rounded-full ${
                              inquiry.status === "resolved"
                                ? "bg-emerald-500"
                                : inquiry.status === "in_review"
                                ? "bg-blue-500"
                                : "bg-amber-500"
                            }`}
                          />
                          {inquiry.status === "resolved"
                            ? "Resolved"
                            : inquiry.status === "in_review"
                            ? "In Review"
                            : "Pending"}
                        </span>
                      </td>

                      {/* Actions */}
                      <td
                        className="px-4 py-4 whitespace-nowrap text-right"
                        onClick={(e) => e.stopPropagation()}
                      >
                        <div className="flex items-center justify-end gap-1.5">
                          <button
                            onClick={() => setSelectedInquiry(inquiry)}
                            className="p-1.5 text-slate-400 hover:text-slate-700 hover:bg-slate-100 rounded-md transition-colors cursor-pointer"
                            title="View Full Details"
                          >
                            <Eye className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => handleDelete(inquiry.id || inquiry._id)}
                            className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-md transition-colors cursor-pointer"
                            title="Delete submission"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Details & Status Modal */}
      {selectedInquiry && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/40 backdrop-blur-xs">
          <div
            className="bg-white rounded-2xl max-w-xl w-full p-6 shadow-2xl border border-slate-200 space-y-6 animate-in fade-in zoom-in duration-150"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Modal Header */}
            <div className="flex items-start justify-between">
              <div className="space-y-1">
                <div className="flex items-center gap-2">
                  {selectedInquiry.type === "accessibilityRequest" ? (
                    <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-purple-50 text-purple-700 border border-purple-200">
                      <Accessibility className="w-3.5 h-3.5 text-purple-600" />
                      Accessibility Request
                    </span>
                  ) : (
                    <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-sky-50 text-sky-700 border border-sky-200">
                      <HelpCircle className="w-3.5 h-3.5 text-sky-600" />
                      General Enquiry
                    </span>
                  )}
                  <span className="text-xs text-slate-400">ID: {selectedInquiry.id || selectedInquiry._id}</span>
                </div>
                <h3 className="text-lg font-bold text-slate-900">Inquiry Details</h3>
              </div>
              <button
                onClick={() => setSelectedInquiry(null)}
                className="p-1.5 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-100 transition-colors cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Message Body Box */}
            <div className="space-y-2">
              <label className="text-xs font-semibold uppercase tracking-wider text-slate-500">
                Submission Message (Body)
              </label>
              <div className="p-4 bg-slate-50 border border-slate-200 rounded-xl text-slate-900 text-sm leading-relaxed whitespace-pre-wrap font-normal">
                {selectedInquiry.message}
              </div>
            </div>

            {/* Metadata Grid */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
              {/* User info */}
              <div className="p-3.5 bg-slate-50 rounded-xl border border-slate-200 space-y-1">
                <span className="text-slate-400 uppercase font-semibold text-[10px] tracking-wider">
                  Added User / Tertiary
                </span>
                <div className="font-semibold text-slate-800 text-sm">
                  {selectedInquiry.userName || "Community User"}
                </div>
                <div className="inline-block mt-0.5 px-2 py-0.5 bg-emerald-50 text-emerald-700 border border-emerald-200 rounded text-[11px] font-medium">
                  {selectedInquiry.userRole || "Community / Public User"}
                </div>
                {selectedInquiry.userEmail && (
                  <div className="text-slate-500 text-[11px]">{selectedInquiry.userEmail}</div>
                )}
                <div className="text-slate-400 text-[10px] font-mono">UID: {selectedInquiry.userId}</div>
              </div>

              {/* Time & Venue */}
              <div className="p-3.5 bg-slate-50 rounded-xl border border-slate-200 space-y-1">
                <span className="text-slate-400 uppercase font-semibold text-[10px] tracking-wider">
                  Submission Time & Venue
                </span>
                <div className="flex items-center gap-1.5 font-medium text-slate-800 text-xs">
                  <Clock className="w-3.5 h-3.5 text-slate-400" />
                  {formatDate(selectedInquiry.createdAt)}
                </div>
                <div className="flex items-center gap-1.5 text-slate-600 text-xs pt-1">
                  <Building2 className="w-3.5 h-3.5 text-slate-400" />
                  {formatFacilityName(selectedInquiry.facilityId, selectedInquiry.facilityName)}
                </div>
                {selectedInquiry.updatedAt && selectedInquiry.updatedAt !== selectedInquiry.createdAt && (
                  <div className="text-slate-400 text-[10px] pt-0.5">
                    Updated: {formatDate(selectedInquiry.updatedAt)}
                  </div>
                )}
              </div>
            </div>

            {/* Change Status Section */}
            <div className="space-y-2 pt-2 border-t border-slate-100">
              <label className="text-xs font-semibold uppercase tracking-wider text-slate-500">
                Update Status
              </label>
              <div className="grid grid-cols-3 gap-2">
                <button
                  type="button"
                  disabled={isUpdatingStatus}
                  onClick={() =>
                    handleStatusUpdate(selectedInquiry.id || selectedInquiry._id, "pending")
                  }
                  className={`py-2 px-3 rounded-lg text-xs font-semibold border flex items-center justify-center gap-1.5 transition-all cursor-pointer ${
                    selectedInquiry.status === "pending" || !selectedInquiry.status
                      ? "bg-amber-500 text-white border-amber-600 shadow-sm"
                      : "bg-white text-slate-600 border-slate-200 hover:bg-slate-50"
                  }`}
                >
                  <AlertCircle className="w-3.5 h-3.5" />
                  Pending
                </button>

                <button
                  type="button"
                  disabled={isUpdatingStatus}
                  onClick={() =>
                    handleStatusUpdate(selectedInquiry.id || selectedInquiry._id, "in_review")
                  }
                  className={`py-2 px-3 rounded-lg text-xs font-semibold border flex items-center justify-center gap-1.5 transition-all cursor-pointer ${
                    selectedInquiry.status === "in_review"
                      ? "bg-blue-600 text-white border-blue-700 shadow-sm"
                      : "bg-white text-slate-600 border-slate-200 hover:bg-slate-50"
                  }`}
                >
                  <Clock3 className="w-3.5 h-3.5" />
                  In Review
                </button>

                <button
                  type="button"
                  disabled={isUpdatingStatus}
                  onClick={() =>
                    handleStatusUpdate(selectedInquiry.id || selectedInquiry._id, "resolved")
                  }
                  className={`py-2 px-3 rounded-lg text-xs font-semibold border flex items-center justify-center gap-1.5 transition-all cursor-pointer ${
                    selectedInquiry.status === "resolved"
                      ? "bg-emerald-600 text-white border-emerald-700 shadow-sm"
                      : "bg-white text-slate-600 border-slate-200 hover:bg-slate-50"
                  }`}
                >
                  <CheckCircle className="w-3.5 h-3.5" />
                  Resolved
                </button>
              </div>
            </div>

            {/* Modal Actions */}
            <div className="flex items-center justify-between pt-4 border-t border-slate-100">
              <button
                type="button"
                onClick={() => handleDelete(selectedInquiry.id || selectedInquiry._id)}
                className="inline-flex items-center gap-1.5 text-xs font-medium text-rose-600 hover:text-rose-700 hover:bg-rose-50 px-3 py-2 rounded-lg transition-colors cursor-pointer"
              >
                <Trash2 className="w-4 h-4" />
                Delete Submission
              </button>

              <button
                type="button"
                onClick={() => setSelectedInquiry(null)}
                className="px-4 py-2 bg-slate-900 text-white text-xs font-medium rounded-lg hover:bg-slate-800 transition-colors cursor-pointer"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
