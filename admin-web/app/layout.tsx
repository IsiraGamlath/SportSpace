import type { Metadata } from "next";
import { Geist } from "next/font/google";
import Sidebar from "@/components/Sidebar";
import "./globals.css";

const geist = Geist({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "SportSpace Admin Portal",
  description: "Management dashboard for SportSpace platform",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="light" style={{ colorScheme: "light" }}>
      <body className={`${geist.className} flex bg-slate-50 min-h-screen text-slate-900`}>
        <Sidebar />
        <main className="flex-1 p-8 overflow-y-auto bg-slate-50 text-slate-900">
          {children}
        </main>
      </body>
    </html>
  );
}