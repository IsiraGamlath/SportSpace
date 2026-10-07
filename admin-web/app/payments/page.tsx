"use client";

import { useEffect, useState } from "react";
import axios from "axios";
import { Building2, UserCircle, Calendar, DollarSign, CreditCard, CheckCircle, Clock, XCircle, Eye, X } from "lucide-react";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api";

export default function PaymentsPage() {
  const [payments, setPayments] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  
  // Modal state
  const [selectedSlip, setSelectedSlip] = useState<{ url: string, booking: any } | null>(null);

  useEffect(() => {
    fetchPayments();
  }, []);

  async function fetchPayments() {
    try {
      setLoading(true);
      const response = await axios.get(`${API_URL}/admin/payments`);
      setPayments(response.data);
    } catch (err) {
      console.error("Failed to fetch payments:", err);
    } finally {
      setLoading(false);
    }
  }

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-LK', { style: 'currency', currency: 'LKR' }).format(amount);
  };

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold tracking-tight text-slate-900">Master Payment Audit</h1>
        <p className="text-slate-500 text-sm mt-1">Complete top-down auditability over every single transaction in SportSpace.</p>
      </div>

      {!loading && payments.length > 0 && (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="bg-white border border-slate-200 rounded-xl p-5 shadow-sm flex items-center gap-4">
            <div className="w-12 h-12 rounded-full bg-indigo-50 flex items-center justify-center">
              <DollarSign className="w-6 h-6 text-indigo-600" />
            </div>
            <div>
              <p className="text-sm font-medium text-slate-500 uppercase tracking-wider">Total Booking Volume</p>
              <h2 className="text-2xl font-bold text-slate-900 mt-1">
                {formatCurrency(payments.reduce((sum, p) => sum + (p.amount || 0), 0))}
              </h2>
            </div>
          </div>
          
          <div className="bg-white border border-slate-200 rounded-xl p-5 shadow-sm flex items-center gap-4">
            <div className="w-12 h-12 rounded-full bg-emerald-50 flex items-center justify-center">
              <DollarSign className="w-6 h-6 text-emerald-600" />
            </div>
            <div>
              <p className="text-sm font-medium text-slate-500 uppercase tracking-wider">Total Platform Commission</p>
              <h2 className="text-2xl font-bold text-emerald-600 mt-1">
                {formatCurrency(payments.reduce((sum, p) => sum + (p.commission || 0), 0))}
              </h2>
            </div>
          </div>
        </div>
      )}

      <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
        <div className="p-6">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm text-slate-600">
              <thead className="bg-slate-50 text-xs uppercase text-slate-500 font-semibold border-b border-slate-200">
                <tr>
                  <th className="px-4 py-3 rounded-l-lg">Facility & Court</th>
                  <th className="px-4 py-3">Owner / Manager</th>
                  <th className="px-4 py-3">Player</th>
                  <th className="px-4 py-3">Slot Details</th>
                  <th className="px-4 py-3">Financials</th>
                  <th className="px-4 py-3">Payment Method</th>
                  <th className="px-4 py-3">Manager Status</th>
                  <th className="px-4 py-3 rounded-r-lg text-right">Slip</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {loading ? (
                  <tr>
                    <td colSpan={8} className="text-center py-8 text-slate-500 font-medium">Loading transactions...</td>
                  </tr>
                ) : payments.length > 0 ? (
                  payments.map((payment: any) => (
                    <tr key={payment._id} className="hover:bg-slate-50 transition-colors">
                      <td className="px-4 py-4 font-medium text-slate-900">
                        <div className="flex items-center gap-2">
                          <Building2 className="w-4 h-4 text-indigo-500" />
                          {payment.courtName}
                        </div>
                      </td>
                      <td className="px-4 py-4 text-slate-700">
                        <div className="flex items-center gap-2">
                          <UserCircle className="w-4 h-4 text-slate-400" />
                          {payment.managerName}
                        </div>
                      </td>
                      <td className="px-4 py-4 text-slate-700">
                        {payment.playerName}
                      </td>
                      <td className="px-4 py-4">
                        <div className="flex items-center gap-2 text-slate-600">
                          <Calendar className="w-4 h-4 text-slate-400" />
                          <span className="whitespace-nowrap">{payment.slotDetails}</span>
                        </div>
                      </td>
                      <td className="px-4 py-4">
                        <div className="flex flex-col gap-1">
                          <div className="font-semibold text-slate-900 flex items-center gap-1">
                            <DollarSign className="w-3.5 h-3.5 text-emerald-500" />
                            {formatCurrency(payment.amount)}
                          </div>
                          <div className="text-xs text-slate-500">
                            Commission: <span className="font-medium text-emerald-600">{formatCurrency(payment.commission)}</span>
                          </div>
                        </div>
                      </td>
                      <td className="px-4 py-4">
                        <div className="flex items-center gap-1.5">
                          <CreditCard className="w-4 h-4 text-slate-400" />
                          <span className="capitalize">{payment.paymentMethod.replace('_', ' ')}</span>
                        </div>
                      </td>
                      <td className="px-4 py-4">
                        {payment.paymentMethod === 'bank_transfer' ? (
                          <StatusBadge status={payment.managerStatus} />
                        ) : (
                          <span className="text-xs text-slate-400 italic">Auto-verified</span>
                        )}
                      </td>
                      <td className="px-4 py-4 text-right">
                        {payment.slipUrl && payment.paymentMethod === 'bank_transfer' && (
                          <button 
                            onClick={() => setSelectedSlip({ url: payment.slipUrl, booking: payment })}
                            className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-indigo-50 text-indigo-700 hover:bg-indigo-100 rounded-md font-medium text-xs transition-colors"
                          >
                            <Eye className="w-3.5 h-3.5" />
                            Inspect
                          </button>
                        )}
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan={8} className="text-center py-12 text-slate-500">
                      <div className="flex flex-col items-center gap-2">
                        <DollarSign className="w-8 h-8 text-slate-300" />
                        <span className="font-medium">No transactions found.</span>
                      </div>
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* Slip Viewer Modal */}
      {selectedSlip && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-sm">
          <div className="bg-white rounded-2xl shadow-xl w-full max-w-4xl max-h-[90vh] flex flex-col overflow-hidden animate-in fade-in zoom-in duration-200">
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100">
              <h2 className="text-lg font-semibold text-slate-900">Slip Inspection</h2>
              <button 
                onClick={() => setSelectedSlip(null)}
                className="p-2 text-slate-400 hover:bg-slate-100 hover:text-slate-600 rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            
            <div className="flex-1 overflow-auto p-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                {/* Left side: Invoice Data */}
                <div className="space-y-6">
                  <div>
                    <h3 className="text-sm font-medium uppercase tracking-wider text-slate-500 mb-4">Booking Invoice</h3>
                    <div className="bg-slate-50 rounded-xl p-5 space-y-4 border border-slate-100">
                      <DetailRow label="Booking ID" value={selectedSlip.booking.bookingId} />
                      <DetailRow label="Facility" value={selectedSlip.booking.courtName} />
                      <DetailRow label="Manager" value={selectedSlip.booking.managerName} />
                      <DetailRow label="Player" value={selectedSlip.booking.playerName} />
                      <DetailRow label="Date & Time" value={selectedSlip.booking.slotDetails} />
                      <div className="pt-3 border-t border-slate-200">
                        <div className="flex justify-between items-center text-sm">
                          <span className="text-slate-600 font-medium">Total Amount Due</span>
                          <span className="text-lg font-bold text-slate-900">{formatCurrency(selectedSlip.booking.amount)}</span>
                        </div>
                      </div>
                    </div>
                  </div>
                  
                  <div>
                    <h3 className="text-sm font-medium uppercase tracking-wider text-slate-500 mb-3">Verification Status</h3>
                    <StatusBadge status={selectedSlip.booking.managerStatus} />
                  </div>
                </div>

                {/* Right side: Slip Image */}
                <div>
                  <h3 className="text-sm font-medium uppercase tracking-wider text-slate-500 mb-4">Uploaded Slip</h3>
                  <div className="bg-slate-100 rounded-xl overflow-hidden border border-slate-200 flex items-center justify-center min-h-[400px]">
                    {selectedSlip.url === 'manual_slip' ? (
                      <div className="text-slate-400 flex flex-col items-center gap-2 p-8 text-center">
                        <Eye className="w-12 h-12 opacity-50" />
                        <p>Slip image not available in current mock data.</p>
                      </div>
                    ) : (
                      <img 
                        src={selectedSlip.url} 
                        alt="Bank Transfer Slip" 
                        className="w-full h-auto object-contain max-h-[500px]"
                        onError={(e) => {
                          (e.target as HTMLImageElement).style.display = 'none';
                          (e.target as HTMLImageElement).parentElement!.innerHTML = '<div class="text-slate-400 flex flex-col items-center gap-2 p-8 text-center"><p>Failed to load image.</p></div>';
                        }}
                      />
                    )}
                  </div>
                </div>
              </div>
            </div>
            
            <div className="px-6 py-4 border-t border-slate-100 bg-slate-50 flex justify-end">
              <button 
                onClick={() => setSelectedSlip(null)}
                className="px-5 py-2.5 bg-slate-900 hover:bg-slate-800 text-white rounded-lg font-medium text-sm transition-colors"
              >
                Close Inspector
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function DetailRow({ label, value }: { label: string, value: string }) {
  return (
    <div className="flex justify-between items-start gap-4 text-sm">
      <span className="text-slate-500">{label}</span>
      <span className="text-slate-900 font-medium text-right">{value}</span>
    </div>
  );
}

function StatusBadge({ status }: { status: string }) {
  if (status === 'Pending Manager Review') {
    return (
      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-amber-50 text-amber-700 border border-amber-200">
        <Clock className="w-3 h-3 text-amber-600" />
        {status}
      </span>
    );
  }
  if (status === 'Approved by Manager') {
    return (
      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-emerald-50 text-emerald-700 border border-emerald-200">
        <CheckCircle className="w-3 h-3 text-emerald-600" />
        {status}
      </span>
    );
  }
  if (status === 'Rejected by Manager') {
    return (
      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-rose-50 text-rose-700 border border-rose-200">
        <XCircle className="w-3 h-3 text-rose-600" />
        {status}
      </span>
    );
  }
  
  return (
    <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-slate-100 text-slate-600 border border-slate-200">
      {status}
    </span>
  );
}
