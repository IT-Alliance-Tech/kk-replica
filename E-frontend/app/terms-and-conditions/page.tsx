export const metadata = {
  title: "Terms & Conditions | EDemo",
};

export default function TermsPage() {
  return (
    <div className="max-w-4xl mx-auto p-6 text-gray-700 space-y-4">
      <h1 className="text-3xl font-bold mb-4 text-emerald-700">
        Terms & Conditions
      </h1>
      <p>
        Welcome to <strong>EDemo.com</strong>, a demonstration e-commerce platform. By accessing our website or using our demo services, you agree to be bound by these Terms of Service.
      </p>

      <h2 className="text-xl font-semibold mt-6">1. User Agreement</h2>
      <p>
        By using our site, you agree to follow these terms and our related
        policies. &quot;You&quot; refers to the user, and &quot;We&quot; refers to EDemo.
      </p>

      <h2 className="text-xl font-semibold mt-6">2. Eligibility</h2>
      <p>
        Only individuals who can legally enter into contracts under the Indian
        Contract Act, 1872 may use our services. Minors (under 18) may transact
        only through a parent or guardian.
      </p>

      <h2 className="text-xl font-semibold mt-6">3. Account Responsibility</h2>
      <p>
        You are responsible for your account credentials. False information may
        result in suspension.
      </p>

      <h2 className="text-xl font-semibold mt-6">4. Pricing & Charges</h2>
      <ul className="list-disc ml-6 space-y-1">
        <li>
          Prices may change or include errors; we reserve the right to correct
          them.
        </li>
        <li>
          All prices are in INR. Applicable taxes are the buyer’s
          responsibility.
        </li>
      </ul>

      <h2 className="text-xl font-semibold mt-6">5. Payments & Refunds</h2>
      <ul className="list-disc ml-6 space-y-1">
        <li>All transactions are processed securely in INR.</li>
        <li>
          Refunds (if applicable) are made to the original payment method.
        </li>
      </ul>

      <h2 className="text-xl font-semibold mt-6">6. Limitation of Liability</h2>
      <p>
        EDemo is not liable for indirect or incidental damages arising
        from the use of our services or products.
      </p>

      <h2 className="text-xl font-semibold mt-6">7. Contact</h2>
      <p>
        Email:{" "}
        <a
          href="mailto:demo@edemo.com"
          className="text-emerald-600"
        >
          demo@edemo.com
        </a>
        <br />
        Phone: +91-8989889880
        <br />
        Address: EDemo, Demo Location, Demo City, India
      </p>
    </div>
  );
}
