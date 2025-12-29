// app/api/razorpay/order/order.route.mock.ts
import { NextResponse } from "next/server";

export const dynamic = "force-dynamic";

export async function POST(req: Request) {
  const { orderId } = await req.json().catch(() => ({}));
  return NextResponse.json({
    id: `order_test_${Date.now()}`,
    amount: 10000,
    currency: "INR",
    receipt: `rcpt_${orderId || "demo"}`,
  });
}
