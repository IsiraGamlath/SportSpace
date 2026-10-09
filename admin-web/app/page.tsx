"use client";

import { useEffect, useState } from "react";
import axios from "axios";
import { Users, Building2, DollarSign, Activity, CheckCircle, Clock } from "lucide-react";
import { useRouter } from "next/navigation";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api";

export default function DashboardPage() {
  const router = useRouter();
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchOverview() {
      try {
        const [overviewRes, paymentsRes, facilitiesRes, managersRes] = await Promise.all([
          axios.get(`${API_URL}/admin/overview`),
          axios.get(`${API_URL}/admin/payments`),
          axios.get(`${API_URL}/facilities`),
          axios.get(`${API_URL}/admin/managers`)
        ]);

        const overviewData = overviewRes.data;
        const paymentsData = paymentsRes.data;
        const facilities = facilitiesRes.data;
        const managers = managersRes.data;

        const bankPayments = paymentsData.filter((p: any) => 
          (p.paymentMethod === 'bank' || p.paymentMethod === 'bank_transfer') && 
          p.slipUrl && p.slipUrl !== 'manual_slip'
        );

        const mappedSlips = bankPayments.map((payment: any) => {
          const facility = facilities.find((f: any) => f.name === payment.courtName);
          let managerName = payment.managerName;
          if (facility && facility.managerId) {
            const manager = managers.find((m: any) => m.firebaseUid === facility.managerId);
            if (manager) managerName = manager.fullName;
          }
          return {
            _id: payment._id,
            facilityName: payment.courtName,
            managerName: managerName,
            amount: payment.amount,
            status: payment.managerStatus === 'Approved by Manager' ? 'Approved' : 
                    payment.managerStatus === 'Rejected by Manager' ? 'Rejected' : 'Pending'
          };
        }).slice(0, 5); // take top 5 recent

        overviewData.recentSlips = mappedSlips;
        setData(overviewData);
      } catch (err) {
        console.error("Failed to connect to backend API:", err);
      } finally {
        setLoading(false);
      }
    }
    fetchOverview();
  }, []);

  const stats = data?.stats;

  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold tracking-tight text-slate-900">System Overview</h1>
        <p className="text-slate-500 text-sm mt-1">Monitor platform metrics, revenues, and active users.</p>
      </div>

      {/* Stat Cards Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">
        <StatCard
          title="TOTAL PLAYERS"
          value={loading ? "..." : (stats?.totalPlayers ?? "1,248")}
          subtitle="+12% from last month"
          icon={Users}
        />
        <StatCard
          title="ACTIVE MANAGERS"
          value={loading ? "..." : (stats?.activeManagers ?? "84")}
          subtitle={`${stats?.pendingManagers ?? 3} pending approval`}
          icon={Building2}
        />
        <StatCard
          title="PLATFORM REVENUE"
          value={loading ? "..." : `LKR ${(stats?.platformCommission ?? 450000).toLocaleString()}`}
          subtitle="10% commission fee"
          icon={DollarSign}
        />
        <StatCard
          title="PENDING SLIPS"
          value={loading ? "..." : (stats?.pendingSlipsCount ?? "12")}
          subtitle="Requires verification"
          icon={Activity}
        />
      </div>

      {/* Main Content Area: Recent Transactions Table */}
      <div className="bg-white border border-slate-200 rounded-xl p-6 shadow-sm">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h2 className="text-lg font-semibold text-slate-900">Recent Payment Slips</h2>
            <p className="text-xs text-slate-500">Latest bank transfers submitted by facility managers</p>
          </div>
          <button 
            onClick={() => router.push("/payments")}
            className="text-xs font-semibold text-emerald-600 hover:underline"
          >
            View All Slips
          </button>
        </div>

        {/* Table */}
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-slate-600">
            <thead className="bg-slate-50 text-xs uppercase text-slate-500 font-semibold border-b border-slate-200">
              <tr>
                <th className="px-4 py-3 rounded-l-lg">Facility</th>
                <th className="px-4 py-3">Manager</th>
                <th className="px-4 py-3">Amount</th>
                <th className="px-4 py-3">Commission (10%)</th>
                <th className="px-4 py-3">Status</th>
                <th className="px-4 py-3 rounded-r-lg text-right">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {data?.recentSlips?.length > 0 ? (
                data.recentSlips.map((slip: any) => (
                  <TableRow
                    key={slip._id}
                    facility={slip.facilityName}
                    manager={slip.managerName}
                    amount={`LKR ${slip.amount?.toLocaleString()}`}
                    commission={`LKR ${(slip.amount * 0.1).toLocaleString()}`}
                    status={slip.status}
                  />
                ))
              ) : (
                <>
                  <TableRow
                    facility="Colombo Futsal Club"
                    manager="Sahan Perera"
                    amount="LKR 25,000"
                    commission="LKR 2,500"
                    status="Pending"
                  />
                  <TableRow
                    facility="Kandy Badminton Complex"
                    manager="Kamal Silva"
                    amount="LKR 18,000"
                    commission="LKR 1,800"
                    status="Approved"
                  />
                </>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

function StatCard({ title, value, subtitle, icon: Icon }: any) {
  return (
    <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm flex flex-col justify-between">
      <div className="flex items-center justify-between">
        <span className="text-xs font-semibold text-slate-500 tracking-wider uppercase">{title}</span>
        <Icon className="w-5 h-5 text-emerald-600" />
      </div>
      <div className="mt-4">
        <div className="text-3xl font-extrabold text-slate-900">{value}</div>
        <p className="text-xs text-slate-500 mt-1 font-medium">{subtitle}</p>
      </div>
    </div>
  );
}

function TableRow({ facility, manager, amount, commission, status }: any) {
  const router = useRouter();
  const isPending = status === "Pending";
  return (
    <tr className="hover:bg-slate-50 transition-colors">
      <td className="px-4 py-4 font-semibold text-slate-900">{facility}</td>
      <td className="px-4 py-4 text-slate-600">{manager}</td>
      <td className="px-4 py-4 text-slate-900 font-semibold">{amount}</td>
      <td className="px-4 py-4 text-emerald-600 font-semibold">{commission}</td>
      <td className="px-4 py-4">
        <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium ${isPending
            ? "bg-amber-50 text-amber-700 border border-amber-200"
            : "bg-emerald-50 text-emerald-700 border border-emerald-200"
          }`}>
          {isPending ? <Clock className="w-3 h-3 text-amber-600" /> : <CheckCircle className="w-3 h-3 text-emerald-600" />}
          {status}
        </span>
      </td>
      <td className="px-4 py-4 text-right">
        <button 
          onClick={() => router.push("/payments")}
          className="text-xs font-medium px-3 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-md border border-slate-200 transition-colors"
        >
          Review
        </button>
      </td>
    </tr>
  );
}