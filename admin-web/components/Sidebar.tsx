"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
    LayoutDashboard,
    Users,
    Building2,
    CreditCard,
    Percent,
    Settings
} from "lucide-react";

const navigation = [
    { name: "Dashboard", href: "/", icon: LayoutDashboard },
    { name: "Users", href: "/users", icon: Users },
    { name: "Facility Managers", href: "/managers", icon: Building2 },
    { name: "Payment Audit", href: "/payments", icon: CreditCard },
    { name: "Settings", href: "/settings", icon: Settings },
];

export default function Sidebar() {
    const pathname = usePathname();

    return (
        <aside className="w-64 bg-white border-r border-slate-200 text-slate-700 min-h-screen p-4 flex flex-col">
            <div className="mb-8 px-2">
                <h1 className="text-xl font-bold tracking-wider text-emerald-600">SportSpace</h1>
                <p className="text-xs text-slate-500 font-medium">Admin Portal</p>
            </div>

            <nav className="space-y-1 flex-1">
                {navigation.map((item) => {
                    const isActive = pathname === item.href;
                    const Icon = item.icon;
                    return (
                        <Link
                            key={item.name}
                            href={item.href}
                            className={`flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors ${isActive
                                ? "bg-emerald-50 text-emerald-700 font-semibold"
                                : "text-slate-600 hover:bg-slate-100 hover:text-slate-900"
                                }`}
                        >
                            <Icon className={`w-5 h-5 ${isActive ? "text-emerald-600" : "text-slate-400"}`} />
                            {item.name}
                        </Link>
                    );
                })}
            </nav>
        </aside>
    );
}