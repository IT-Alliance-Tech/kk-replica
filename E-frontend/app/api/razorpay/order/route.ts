// app/api/razorpay/order/route.ts
// Delegator: routes to mock or real implementation based on USE_RAZORPAY_MOCK env var

import { POST as POST_MOCK } from "./order.route.mock";
import { POST as POST_REAL } from "./order.route.real";

export const dynamic = "force-dynamic";

export async function POST(req: Request) {
  const useMock = process.env.USE_RAZORPAY_MOCK === "true";

  if (useMock) {
    return POST_MOCK(req);
  } else {
    return POST_REAL(req);
  }
}
